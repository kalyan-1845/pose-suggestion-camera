import 'dart:async';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import '../../core/constants/app_colors.dart';
import '../../data/models/pose_template.dart';
import '../../data/models/pose_match_result.dart';
import '../../data/repositories/template_repository.dart';
import '../../domain/pose_detector_service.dart';
import '../../domain/pose_matching_engine.dart';
import '../../domain/auto_capture_controller.dart';
import '../widgets/skeleton_painter.dart';
import '../widgets/ghost_pose_overlay.dart';
import '../widgets/feedback_overlay.dart';
import '../widgets/match_score_indicator.dart';
import '../widgets/pose_effects_slider.dart';
import '../animations/countdown_overlay.dart';
import '../animations/capture_flash.dart';
import 'preview_screen.dart';
import 'collage_preview_screen.dart';
import 'package:image_picker/image_picker.dart';
import 'mini_gallery_screen.dart';
import 'pro_settings_screen.dart';

/// Main camera screen mimicking standard OS camera with a "Poses" mode
class MainCameraScreen extends StatefulWidget {
  const MainCameraScreen({super.key});

  @override
  State<MainCameraScreen> createState() => _MainCameraScreenState();
}

class _MainCameraScreenState extends State<MainCameraScreen> with WidgetsBindingObserver {
  CameraController? _cameraController;
  List<CameraDescription> _cameras = [];
  int _currentCameraIndex = 0;

  final PoseDetectorService _poseDetectorService = PoseDetectorService();
  AutoCaptureController? _autoCaptureController;

  bool _isInitialized = false;

  // Camera Modes
  final List<String> _cameraModes = ['Video', 'Photo', 'Portrait', 'Poses', 'Photo Booth'];
  int _selectedModeIndex = 3; // Default to 'Poses'

  // Photo Booth State
  List<String> _photoBoothImages = [];

  // Invisible Cameraman (Auto-Framing)
  bool _autoFramingEnabled = false;
  Offset _framingOffset = Offset.zero;
  double _framingScale = 1.0;

  // Manual Zoom & Focus
  double _minZoomLevel = 1.0;
  double _maxZoomLevel = 1.0;
  double _currentZoomLevel = 1.0;
  double _baseZoomLevel = 1.0;

  // Video State
  bool _isRecordingVideo = false;
  int _videoRecordSeconds = 0;
  Timer? _videoTimer;

  // Pose Specific State
  List<PoseTemplate> _allTemplates = [];
  PoseTemplate? _selectedTemplate;
  Pose? _currentPose;
  PoseMatchResult _matchResult = PoseMatchResult.empty;
  bool _showGhostPose = true;

  // Auto Capture State
  bool _showCountdown = false;
  int _countdownValue = 3;
  bool _showFlash = false;
  Size _imageSize = Size.zero;
  InputImageRotation _imageRotation = InputImageRotation.rotation0deg;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _allTemplates = TemplateRepository.all;
    _initCamera();
    _poseDetectorService.initialize();
  }

  Future<void> _initCamera() async {
    _cameras = await availableCameras();
    if (_cameras.isEmpty) return;

    // Start with front camera if available
    _currentCameraIndex = _cameras.length > 1 ? 1 : 0;
    await _setupCamera(_cameras[_currentCameraIndex]);
  }

  Future<void> _setupCamera(CameraDescription camera) async {
    _cameraController?.dispose();

    _cameraController = CameraController(
      camera,
      ResolutionPreset.max, // Flagship Ultra Clarity
      enableAudio: true, // Needed for video
      imageFormatGroup: ImageFormatGroup.nv21,
    );

    try {
      await _cameraController!.initialize();
      
      _minZoomLevel = await _cameraController!.getMinZoomLevel();
      _maxZoomLevel = await _cameraController!.getMaxZoomLevel();
      _currentZoomLevel = _minZoomLevel;

      // Setup auto-capture
      _autoCaptureController?.dispose();
      _autoCaptureController = AutoCaptureController(
        cameraController: _cameraController!,
        onCaptured: _onPhotoCaptured,
        onCountdownTick: (seconds) {
          if (mounted) setState(() => _countdownValue = seconds);
        },
        onCountdownStart: () {
          if (mounted) setState(() => _showCountdown = true);
        },
        onCountdownCancel: () {
          if (mounted) setState(() => _showCountdown = false);
        },
      );

      // Only process frames for poses if we are in "Poses" mode
      await _cameraController!.startImageStream(_processFrame);

      if (mounted) {
        setState(() => _isInitialized = true);
      }
    } catch (e) {
      debugPrint('Camera init error: $e');
    }
  }

  void _processFrame(CameraImage image) {
    if (!_poseDetectorService.isInitialized) return;
    final mode = _cameraModes[_selectedModeIndex];
    final isPoseMode = mode == 'Poses' || mode == 'Photo Booth';

    if (!isPoseMode || _selectedTemplate == null) {
      // Free up resources if not in pose mode or no template selected
      if (_currentPose != null) {
         setState(() {
           _currentPose = null;
           _matchResult = PoseMatchResult.empty;
         });
      }
      return;
    }

    final camera = _cameras[_currentCameraIndex];
    final sensorOrientation = camera.sensorOrientation;

    _imageSize = Size(image.width.toDouble(), image.height.toDouble());
    _imageRotation = InputImageRotation.values.firstWhere(
      (r) => r.rawValue == sensorOrientation,
      orElse: () => InputImageRotation.rotation0deg,
    );

    _poseDetectorService.processFrame(image, camera, sensorOrientation).then((poses) {
      if (!mounted) return;

      if (poses.isNotEmpty && _selectedTemplate != null) {
        final pose = poses.first;
        final result = PoseMatchingEngine.compare(pose, _selectedTemplate!);

        setState(() {
          _currentPose = pose;
          _matchResult = result;
          _updateAutoFraming(pose);
        });

        // Update auto-capture with score
        _autoCaptureController?.updateScore(result.score);
      } else {
        setState(() {
          _currentPose = null;
          _matchResult = PoseMatchResult.empty;
          _framingScale = 1.0;
          _framingOffset = Offset.zero;
        });
      }
    });
  }

  void _updateAutoFraming(Pose pose) {
    if (!_autoFramingEnabled || _imageSize == Size.zero) {
      _framingScale = 1.0;
      _framingOffset = Offset.zero;
      return;
    }

    double minX = double.infinity, minY = double.infinity;
    double maxX = -double.infinity, maxY = -double.infinity;
    for (var landmark in pose.landmarks.values) {
      if (landmark.likelihood > 0.5) {
        if (landmark.x < minX) minX = landmark.x;
        if (landmark.x > maxX) maxX = landmark.x;
        if (landmark.y < minY) minY = landmark.y;
        if (landmark.y > maxY) maxY = landmark.y;
      }
    }

    if (minX == double.infinity) return;

    // Determine the center of the pose
    double poseCenterX = (minX + maxX) / 2;
    // Map to normalized coordinates (0 to 1) based on image sensor size
    // Note: ML kit coordinates depend on rotation, roughly treating X/Y directly for horizontal pan
    double normalizedX = poseCenterX / _imageSize.width;
    
    // Zoom in by 1.3x and offset based on how far from center (0.5) the pose is
    _framingScale = 1.3;
    // Calculate offset required to bring the centroid to the middle
    double dx = (0.5 - normalizedX) * 200; // rough pixel shift

    // Front camera is mirrored, flip the pan direction
    if (_currentCameraIndex == 1) dx = -dx;

    _framingOffset = Offset(dx, 0); // pan horizontally
  }

  void _onPhotoCaptured(String path) {
    if (!mounted) return;

    setState(() {
      _showFlash = true;
      _showCountdown = false;
    });

    // Flash effect
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) setState(() => _showFlash = false);
    });

    final mode = _cameraModes[_selectedModeIndex];

    if (mode == 'Photo Booth') {
      _photoBoothImages.add(path);
      
      if (_photoBoothImages.length < 4) {
         // Cycle to next template for variety
         int nextIndex = (_allTemplates.indexOf(_selectedTemplate!) + 1) % _allTemplates.length;
         setState(() {
           _selectedTemplate = _allTemplates[nextIndex];
           _matchResult = PoseMatchResult.empty;
         });
         _autoCaptureController?.reset();
         return; // Don't navigate yet!
      } else {
         // We have 4 images, push to CollagePreview!
         _cameraController?.stopImageStream().then((_) {
            if (mounted) {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => CollagePreviewScreen(imagePaths: _photoBoothImages),
                )
              ).then((_) {
                 _photoBoothImages.clear();
                 _showGhostPose = true;
                 _autoCaptureController?.reset();
                 if (_cameraController != null && _cameraController!.value.isInitialized) {
                     _cameraController!.startImageStream(_processFrame).catchError((e){});
                 }
              });
            }
         });
         return;
      }
    }

    // Stop image stream before navigating to standard preview
    _cameraController?.stopImageStream().then((_) {
      if (mounted) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => PreviewScreen(
              imagePath: path,
              templateId: _selectedTemplate?.id ?? 'custom',
              templateName: _selectedTemplate?.name ?? 'Standard Photo',
              matchScore: mode == 'Poses' ? _matchResult.score : 100.0,
              isFrontCamera: _currentCameraIndex == 1,
            ),
          ),
        ).then((_) {
           // Resume camera stream when returning
           _showGhostPose = true; // reset ghost
           _autoCaptureController?.reset();
           if (_cameraController != null && _cameraController!.value.isInitialized) {
               _cameraController!.startImageStream(_processFrame).catchError((e){});
           }
        });
      }
    });
  }

  void _switchCamera() async {
    if (_cameras.length < 2) return;

    await _cameraController?.stopImageStream();
    _currentCameraIndex = (_currentCameraIndex + 1) % _cameras.length;
    await _setupCamera(_cameras[_currentCameraIndex]);
  }

  void _toggleGhostPose() {
    setState(() => _showGhostPose = !_showGhostPose);
  }

  void _onModeSelected(int index) {
    if (_isRecordingVideo) return; // Prevent switching while recording

    setState(() {
      _selectedModeIndex = index;
      final mode = _cameraModes[index];
      if ((mode == 'Poses' || mode == 'Photo Booth') && _selectedTemplate == null) {
        _selectedTemplate = _allTemplates.first;
      }
      
      // Force clear photobooth images if switching out
      if (mode != 'Photo Booth') {
        _photoBoothImages.clear();
      }
    });
  }

  Future<void> _startVideoRecording() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized) return;
    if (_isRecordingVideo) return;

    try {
      await _cameraController!.stopImageStream();
      await _cameraController!.startVideoRecording();
      setState(() {
        _isRecordingVideo = true;
        _videoRecordSeconds = 0;
      });
      
      _videoTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
        setState(() => _videoRecordSeconds++);
      });
    } catch (e) {
      debugPrint('Error starting video: $e');
    }
  }

  Future<void> _stopVideoRecording() async {
    if (_cameraController == null || !_isRecordingVideo) return;

    _videoTimer?.cancel();

    try {
      final file = await _cameraController!.stopVideoRecording();
      setState(() => _isRecordingVideo = false);
      
      // Handle video file (could pass to PreviewScreen, but keeping it simple and starting stream again to not break flow)
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Video saved: ${file.path}')),
      );

      await _cameraController!.startImageStream(_processFrame);
    } catch (e) {
      debugPrint('Error stopping video: $e');
    }
  }

  Future<void> _openGallery() async {
    Navigator.push(
       context,
       MaterialPageRoute(builder: (_) => MiniGalleryScreen()),
    );
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.inactive) {
      _cameraController?.dispose();
    } else if (state == AppLifecycleState.resumed) {
      if (_cameraController != null) {
        _setupCamera(_cameras[_currentCameraIndex]);
      }
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _videoTimer?.cancel();
    _cameraController?.dispose();
    _poseDetectorService.dispose();
    _autoCaptureController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized || _cameraController == null || !_cameraController!.value.isInitialized) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: CircularProgressIndicator(color: AppColors.accentCyan),
        ),
      );
    }

    final mode = _cameraModes[_selectedModeIndex];
    final isPoseMode = mode == 'Poses' || mode == 'Photo Booth';

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // ── Camera Preview (with Auto-Framing and Zoom support) ──
          GestureDetector(
            onDoubleTap: _switchCamera,
            onScaleStart: (details) {
              _baseZoomLevel = _currentZoomLevel;
            },
            onScaleUpdate: (details) async {
              if (_cameraController == null) return;
              double zoomLevel = _baseZoomLevel * details.scale;
              if (zoomLevel < _minZoomLevel) zoomLevel = _minZoomLevel;
              if (zoomLevel > _maxZoomLevel) zoomLevel = _maxZoomLevel;
              
              if (zoomLevel != _currentZoomLevel) {
                 _currentZoomLevel = zoomLevel;
                 await _cameraController!.setZoomLevel(_currentZoomLevel);
              }
            },
            onTapDown: (details) async {
               if (_cameraController == null) return;
               // Map tap to 0..1 range
               final Size size = MediaQuery.of(context).size;
               final offset = Offset(
                 details.localPosition.dx / size.width,
                 details.localPosition.dy / size.height,
               );
               try {
                  await _cameraController!.setFocusPoint(offset);
                  await _cameraController!.setExposurePoint(offset);
               } catch (e) {
                  debugPrint('Focus error: $e');
               }
            },
            child: ClipRect(
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOut,
                transform: Matrix4.identity()
                  ..translate(_framingOffset.dx, _framingOffset.dy)
                  ..scale(_framingScale),
                alignment: Alignment.center,
                child: Center(
                  child: CameraPreview(_cameraController!),
                ),
              ),
            ),
          ),

          // ── Pose Mode Specific Overlays ──
          if (isPoseMode && _selectedTemplate != null) ...[
            // Ghost Pose Outline
            if (_showGhostPose)
              Positioned.fill(
                child: GhostPoseOverlay(
                  template: _selectedTemplate!,
                  imageSize: _imageSize,
                  rotation: _imageRotation,
                  isFrontCamera: _currentCameraIndex == 1,
                ),
              ),

            // Live User Skeleton/Outline
            if (_currentPose != null)
              Positioned.fill(
                child: CustomPaint(
                  painter: SkeletonPainter(
                    pose: _currentPose!,
                    imageSize: _imageSize,
                    rotation: _imageRotation,
                    matchResult: _matchResult,
                    isFrontCamera: _currentCameraIndex == 1,
                  ),
                ),
              ),

            // Match Score Indicator (top right)
            Positioned(
              top: MediaQuery.of(context).padding.top + 60,
              right: 16,
              child: MatchScoreIndicator(score: _matchResult.score),
            ),

            // Ghost toggle button
            Positioned(
              top: MediaQuery.of(context).padding.top + 60,
              left: 16,
              child: GestureDetector(
                onTap: _toggleGhostPose,
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _showGhostPose
                          ? AppColors.accentCyan.withOpacity(0.5)
                          : Colors.white.withOpacity(0.2),
                    ),
                  ),
                  child: Icon(
                    Icons.visibility,
                    color: _showGhostPose ? AppColors.accentCyan : Colors.white54,
                    size: 22,
                  ),
                ),
              ),
            ),

            // Feedback Overlay just above slider
            Positioned(
              bottom: 210, // Above slider and capture button
              left: 20,
              right: 20,
              child: FeedbackOverlay(
                feedback: _matchResult.feedback,
                scoreLabel: _matchResult.scoreLabel,
              ),
            ),
          ],

          // ── Top Action Bar ──
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top + 8,
                left: 16,
                right: 16,
                bottom: 12,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      IconButton(
                        onPressed: () {
                           Navigator.push(context, MaterialPageRoute(builder: (_) => const ProSettingsScreen()));
                        },
                        icon: const Icon(Icons.settings, color: Colors.white, size: 24),
                      ),
                      // Invisible Cameraman Toggle
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _autoFramingEnabled = !_autoFramingEnabled;
                            if (!_autoFramingEnabled) {
                               _framingScale = 1.0;
                               _framingOffset = Offset.zero;
                            }
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: _autoFramingEnabled ? AppColors.accentCyan.withOpacity(0.3) : Colors.black45,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: _autoFramingEnabled ? AppColors.accentCyan : Colors.white24,
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.face_retouching_natural, 
                                   color: _autoFramingEnabled ? AppColors.accentCyan : Colors.white, size: 18),
                              const SizedBox(width: 6),
                              Text('AI Cameraman', style: TextStyle(
                                color: _autoFramingEnabled ? AppColors.accentCyan : Colors.white,
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                              )),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      IconButton(
                        onPressed: () {}, // Flash toggle could go here
                        icon: const Icon(Icons.flash_off, color: Colors.white, size: 24),
                      ),
                      IconButton(
                        onPressed: _switchCamera,
                        icon: const Icon(Icons.cameraswitch, color: Colors.white, size: 24),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // ── Bottom UI (Modes, Slider, Capture Button) ──
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom + 20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    Colors.black.withOpacity(0.8),
                    Colors.black.withOpacity(0.4),
                    Colors.transparent,
                  ],
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Pose Effects Slider (Instagram style)
                  if (isPoseMode)
                    PoseEffectsSlider(
                      templates: _allTemplates,
                      selectedTemplate: _selectedTemplate,
                      onTemplateSelected: (template) {
                        setState(() {
                             _selectedTemplate = template;
                             _matchResult = PoseMatchResult.empty;
                        });
                        _autoCaptureController?.reset();
                      },
                    )
                  else
                     const SizedBox(height: 110), // Placeholder to keep button stable

                  const SizedBox(height: 20),

                  const SizedBox(height: 12),

                  // Photo Booth mode counter badge
                  if (mode == 'Photo Booth')
                    Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.accentPurple,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'Photo ${_photoBoothImages.length + 1} of 4',
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                    ),

                  // Capture Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // Gallery Thumbnail Button
                      GestureDetector(
                        onTap: _openGallery,
                        child: Container(
                          width: 46,
                          height: 46,
                          decoration: BoxDecoration(
                            shape: BoxShape.rectangle,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.white, width: 2),
                            color: Colors.white24,
                          ),
                          child: const Icon(Icons.photo_library, color: Colors.white70, size: 20),
                        ),
                      ),
                      
                      // Shutter Button
                      GestureDetector(
                        onTap: () {
                           if (mode == 'Video') {
                              if (_isRecordingVideo) {
                                 _stopVideoRecording();
                              } else {
                                 _startVideoRecording();
                              }
                           } else {
                              _autoCaptureController?.manualCapture();
                           }
                        },
                        child: Container(
                          width: 76,
                          height: 76,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: _isRecordingVideo ? Colors.red : Colors.white, width: 4),
                            color: isPoseMode ? AppColors.accentCyan.withOpacity(0.2) : Colors.white24,
                          ),
                          child: Container(
                            margin: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              // Change shape to rounded square if recording video
                              borderRadius: _isRecordingVideo ? BorderRadius.circular(12) : BorderRadius.circular(40),
                              color: _isRecordingVideo ? Colors.red : (isPoseMode ? AppColors.accentCyan : Colors.white),
                            ),
                            child: isPoseMode && _showCountdown
                                ? Center(
                                    child: Text(
                                      '$_countdownValue',
                                      style: const TextStyle(
                                          color: Colors.white, fontSize: 24, fontWeight: FontWeight.w700),
                                    ),
                                  )
                                : null,
                          ),
                        ),
                      ),
                      
                      // Empty space for symmetry (like camera switch icon is normally here in some apps)
                      const SizedBox(width: 46),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Video Timer if Recording
                  if (_isRecordingVideo)
                    Container(
                       margin: const EdgeInsets.only(bottom: 12),
                       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                       decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(16)),
                       child: Text(
                          '${(_videoRecordSeconds ~/ 60).toString().padLeft(2, '0')}:${(_videoRecordSeconds % 60).toString().padLeft(2, '0')}',
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                       ),
                    ),

                  // Text Mode Selector
                  SizedBox(
                    height: 30,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 50), // Center the short list roughly
                      itemCount: _cameraModes.length,
                      itemBuilder: (context, index) {
                        final isSelected = index == _selectedModeIndex;
                        return GestureDetector(
                          onTap: () => _onModeSelected(index),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  _cameraModes[index],
                                  style: TextStyle(
                                    color: isSelected ? Colors.white : Colors.white54,
                                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                                    fontSize: 15,
                                  ),
                                ),
                                if (isSelected)
                                  Container(
                                    margin: const EdgeInsets.only(top: 4),
                                    width: 4,
                                    height: 4,
                                    decoration: const BoxDecoration(
                                      color: Colors.white,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Countdown Overlay (Big center) ──
          if (_showCountdown)
            CountdownOverlay(value: _countdownValue),

          // ── Capture Flash ──
          if (_showFlash)
            const CaptureFlash(),
        ],
      ),
    );
  }
}
