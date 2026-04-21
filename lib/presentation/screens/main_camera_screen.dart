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
import 'wifi_share_screen.dart';
import 'package:gal/gal.dart';
import 'package:android_intent_plus/android_intent.dart';
import 'package:android_intent_plus/flag.dart';

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
  double _digitalZoomScale = 1.0; // For Super Zoom beyond hardware limits

  // Pro UI State
  bool _isCleanView = false;
  Offset? _focusPoint;
  double _exposureValue = 0.0;
  double _minExposure = 0.0;
  double _maxExposure = 0.0;
  bool _showFocusUI = false;
  Timer? _focusTimer;
  bool _isZoomDragging = false;

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
      ResolutionPreset.ultraHigh, // Pro 4K/2K Quality
      enableAudio: true,
      imageFormatGroup: ImageFormatGroup.nv21,
    );

    try {
      await _cameraController!.initialize();
      
      _minZoomLevel = await _cameraController!.getMinZoomLevel();
      _maxZoomLevel = await _cameraController!.getMaxZoomLevel();
      _currentZoomLevel = _minZoomLevel;

      _minExposure = await _cameraController!.getMinExposureOffset();
      _maxExposure = await _cameraController!.getMaxExposureOffset();
      _exposureValue = 0.0;

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
    if (_isRecordingVideo) return; // Optimization: Pause AI during video recording for max clarity
    
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

  void _openReceiveScreen() {
    _cameraController?.stopImageStream().then((_) {
      if (mounted) {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => WifiShareScreen()),
        ).then((_) {
          if (_cameraController != null && _cameraController!.value.isInitialized) {
            _cameraController!.startImageStream(_processFrame).catchError((e) {});
          }
        });
      }
    });
  }

  void _toggleCleanView() {
    setState(() => _isCleanView = !_isCleanView);
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
      
      // Handle video file natively
      await Gal.putVideo(file.path);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Video saved to System Gallery!')),
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

  Future<void> _setExposure(double value) async {
    if (_cameraController == null) return;
    setState(() => _exposureValue = value);
    try {
      await _cameraController!.setExposureOffset(value);
    } catch (e) {
      debugPrint('Exposure error: $e');
    }
    // Reset focus UI timer so it doesn't disappear while adjusting exposure
    _focusTimer?.cancel();
    _focusTimer = Timer(const Duration(seconds: 3), () {
      if (mounted) setState(() => _showFocusUI = false);
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    }
  }

  Future<void> _setZoom(double value) async {
    if (_cameraController == null) return;
    
    // Clamp to hardware limits for the controller
    final hardwareZoom = value.clamp(_minZoomLevel, _maxZoomLevel);
    
    // Calculate digital scale for "Super Zoom"
    final digitalScale = value > _maxZoomLevel ? (value / _maxZoomLevel) : 1.0;

    setState(() {
      _currentZoomLevel = value;
      _digitalZoomScale = digitalScale;
    });

    try {
      await _cameraController!.setZoomLevel(hardwareZoom);
    } catch (e) {
      debugPrint('Zoom error: $e');
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

  FlashMode _flashMode = FlashMode.off;

  Future<void> _toggleFlash() async {
    if (_cameraController == null) return;
    
    FlashMode nextMode;
    switch (_flashMode) {
      case FlashMode.off:
        nextMode = FlashMode.always;
        break;
      case FlashMode.always:
        nextMode = FlashMode.auto;
        break;
      case FlashMode.auto:
        nextMode = FlashMode.torch;
        break;
      case FlashMode.torch:
        nextMode = FlashMode.off;
        break;
    }
    
    try {
      await _cameraController!.setFlashMode(nextMode);
      setState(() => _flashMode = nextMode);
    } catch (e) {
      debugPrint('Flash error: $e');
    }
  }

  IconData _getFlashIcon() {
    switch (_flashMode) {
      case FlashMode.off: return Icons.flash_off;
      case FlashMode.always: return Icons.flash_on;
      case FlashMode.auto: return Icons.flash_auto;
      case FlashMode.torch: return Icons.flashlight_on;
    }
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
              if (zoomLevel > 100.0) zoomLevel = 100.0;
              
              if (zoomLevel != _currentZoomLevel) {
                 _setZoom(zoomLevel);
              }
            },
            onTapDown: (details) async {
               if (_cameraController == null) return;
               
               // Map tap to 0..1 range for camera controller
               final Size size = MediaQuery.of(context).size;
               final offset = Offset(
                 details.localPosition.dx / size.width,
                 details.localPosition.dy / size.height,
               );

               setState(() {
                 _focusPoint = details.localPosition;
                 _showFocusUI = true;
               });

               try {
                  await _cameraController!.setFocusPoint(offset);
                  await _cameraController!.setExposurePoint(offset);
               } catch (e) {
                  debugPrint('Focus error: $e');
               }

               // Hide UI after 3 seconds of inactivity
               _focusTimer?.cancel();
               _focusTimer = Timer(const Duration(seconds: 3), () {
                 if (mounted) setState(() => _showFocusUI = false);
               });
            },
            child: ClipRect(
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOut,
                transform: Matrix4.identity()
                  ..translate(_framingOffset.dx, _framingOffset.dy)
                  ..scale(_framingScale * _digitalZoomScale),
                alignment: Alignment.center,
                child: Center(
                  child: CameraPreview(_cameraController!),
                ),
              ),
            ),
          ),

          // ── Top Action Bar (Flagship Style) ──
          if (!_isCleanView)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: SafeArea(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Settings Button
                      _ProIconButton(
                        icon: Icons.settings, 
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ProSettingsScreen())),
                      ),

                      // AI Cameraman Toggle (Refined Pill)
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
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                          decoration: BoxDecoration(
                            color: _autoFramingEnabled ? AppColors.accentCyan.withOpacity(0.9) : Colors.black38,
                            borderRadius: BorderRadius.circular(25),
                            border: Border.all(
                              color: _autoFramingEnabled ? AppColors.accentCyan : Colors.white24,
                              width: 1.5,
                            ),
                            boxShadow: _autoFramingEnabled ? [BoxShadow(color: AppColors.accentCyan.withOpacity(0.4), blurRadius: 12)] : null,
                          ),
                          child: RawRow(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.face_retouching_natural, 
                                   color: _autoFramingEnabled ? Colors.black : Colors.white, size: 18),
                              const SizedBox(width: 8),
                              Text('AI CAMERAMAN', style: TextStyle(
                                color: _autoFramingEnabled ? Colors.black : Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 1.2,
                              )),
                            ],
                          ),
                        ),
                      ),

                      // Right Group: Flash & Flip
                      Row(
                        children: [
                          _ProIconButton(
                            icon: _getFlashIcon(),
                            onTap: _toggleFlash,
                            isActive: _flashMode != FlashMode.off,
                          ),
                          const SizedBox(width: 12),
                          _ProIconButton(
                            icon: Icons.cameraswitch,
                            onTap: _switchCamera,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),

          // ── Clean View Exit Button (Small corner hint) ──
          if (_isCleanView)
            Positioned(
              top: MediaQuery.of(context).padding.top + 8,
              right: 16,
              child: IconButton(
                onPressed: _toggleCleanView,
                icon: const Icon(Icons.visibility_off, color: Colors.white38, size: 20),
              ),
            ),

          // ── Pose Mode Specific Overlays ──
          if (isPoseMode && _selectedTemplate != null && !_isCleanView) ...[
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

            // Skeleton rendering removed per user request for cleaner UI
            // The AI logic for matching still runs in background.

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

          // ── Pro Zoom Controller (Premium Super Zoom Selection) ──
          if (!_isCleanView)
            Positioned(
              bottom: 200,
              left: 0,
              right: 0,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Horizontal Scrolling Zoom Buttons
                  SizedBox(
                    height: 40,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      children: [
                        _ZoomQuickBtn(label: '0.6x', value: 0.6, current: _currentZoomLevel, min: _minZoomLevel, max: _maxZoomLevel, onTap: _setZoom),
                        _ZoomQuickBtn(label: '1x', value: 1.0, current: _currentZoomLevel, min: _minZoomLevel, max: _maxZoomLevel, onTap: _setZoom),
                        _ZoomQuickBtn(label: '2x', value: 2.0, current: _currentZoomLevel, min: _minZoomLevel, max: _maxZoomLevel, onTap: _setZoom),
                        _ZoomQuickBtn(label: '4x', value: 4.0, current: _currentZoomLevel, min: _minZoomLevel, max: _maxZoomLevel, onTap: _setZoom),
                        _ZoomQuickBtn(label: '5x', value: 5.0, current: _currentZoomLevel, min: _minZoomLevel, max: _maxZoomLevel, onTap: _setZoom),
                        _ZoomQuickBtn(label: '8x', value: 8.0, current: _currentZoomLevel, min: _minZoomLevel, max: _maxZoomLevel, onTap: _setZoom),
                        _ZoomQuickBtn(label: '10x', value: 10.0, current: _currentZoomLevel, min: _minZoomLevel, max: _maxZoomLevel, onTap: _setZoom),
                        _ZoomQuickBtn(label: '15x', value: 15.0, current: _currentZoomLevel, min: _minZoomLevel, max: _maxZoomLevel, onTap: _setZoom),
                        _ZoomQuickBtn(label: '20x', value: 20.0, current: _currentZoomLevel, min: _minZoomLevel, max: _maxZoomLevel, onTap: _setZoom),
                        _ZoomQuickBtn(label: '30x', value: 30.0, current: _currentZoomLevel, min: _minZoomLevel, max: _maxZoomLevel, onTap: _setZoom),
                        _ZoomQuickBtn(label: '45x', value: 45.0, current: _currentZoomLevel, min: _minZoomLevel, max: _maxZoomLevel, onTap: _setZoom),
                        _ZoomQuickBtn(label: '75x', value: 75.0, current: _currentZoomLevel, min: _minZoomLevel, max: _maxZoomLevel, onTap: _setZoom),
                        _ZoomQuickBtn(label: '100x', value: 100.0, current: _currentZoomLevel, min: _minZoomLevel, max: 100.0, onTap: _setZoom),
                      ],
                    ),
                  ),
                  // Professional Zoom Ticks (Interactive)
                  GestureDetector(
                    onPanUpdate: (details) {
                      final box = context.findRenderObject() as RenderBox;
                      final localOffset = box.globalToLocal(details.globalPosition);
                      // Assuming the ticks container is roughly 250 width centered
                      // Need to calculate which part of the 250 width is being touched
                      final screenWidth = MediaQuery.of(context).size.width;
                      final startX = (screenWidth - 250) / 2;
                      final relativeX = (localOffset.dx - startX).clamp(0.0, 250.0);
                      final progress = relativeX / 250.0;
                      
                      // Map 0..1 progress to minZoom..100x
                      final targetZoom = _minZoomLevel + (progress * (100.0 - _minZoomLevel));
                      _setZoom(targetZoom);
                    },
                    onTapUp: (details) {
                      final box = context.findRenderObject() as RenderBox;
                      final localOffset = box.globalToLocal(details.globalPosition);
                      final screenWidth = MediaQuery.of(context).size.width;
                      final startX = (screenWidth - 250) / 2;
                      final relativeX = (localOffset.dx - startX).clamp(0.0, 250.0);
                      final progress = relativeX / 250.0;
                      
                      final targetZoom = _minZoomLevel + (progress * (100.0 - _minZoomLevel));
                      _setZoom(targetZoom);
                    },
                    child: Container(
                      height: 20, // Increased hit area
                      width: 250,
                      color: Colors.transparent, // Invisible hit area
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: List.generate(21, (i) => Container(
                          width: 1.5,
                          height: i % 5 == 0 ? 10 : 5,
                          color: Colors.white30,
                        )),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Responsive Dial
                  SizedBox(
                    width: 250,
                    height: 40,
                    child: SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        trackHeight: 2,
                        activeTrackColor: Colors.yellow,
                        inactiveTrackColor: Colors.white12,
                        thumbColor: Colors.yellow,
                        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
                        overlayColor: Colors.yellow.withOpacity(0.1),
                      ),
                      child: Slider(
                        value: _currentZoomLevel.clamp(_minZoomLevel, 100.0),
                        min: _minZoomLevel,
                        max: 100.0, // Support up to 100x in UI
                        onChanged: _setZoom,
                      ),
                    ),
                  ),
                ],
              ),
            ),

          // ── Pro Focus & Exposure UI ──
          if (_showFocusUI && _focusPoint != null && !_isCleanView)
            Positioned(
              left: _focusPoint!.dx - 40,
              top: _focusPoint!.dy - 60,
              child: Row(
                children: [
                  // Focal Box
                  Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.yellow, width: 2),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Exposure Slider
                  SizedBox(
                    height: 120,
                    child: RotatedBox(
                      quarterTurns: 3,
                      child: SliderTheme(
                        data: SliderTheme.of(context).copyWith(
                          trackHeight: 2,
                          thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                          activeTrackColor: Colors.yellow,
                          inactiveTrackColor: Colors.white24,
                          thumbColor: Colors.yellow,
                        ),
                        child: Slider(
                          value: _exposureValue,
                          min: _minExposure,
                          max: _maxExposure,
                          onChanged: _setExposure,
                        ),
                      ),
                    ),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                       const Icon(Icons.wb_sunny, color: Colors.yellow, size: 18),
                       const SizedBox(height: 4),
                       Text('${_exposureValue > 0 ? '+' : ''}${_exposureValue.toStringAsFixed(1)}', 
                           style: const TextStyle(color: Colors.yellow, fontSize: 10, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ],
              ),
            ),

          // ── AI Dynamic Stats ──
          if (!_isCleanView)
          Positioned(
            top: MediaQuery.of(context).padding.top + 50,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.black38,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.auto_awesome, color: Colors.white, size: 14),
                    const SizedBox(width: 8),
                    Text(
                      _isZoomDragging ? "CALIBRATING OPTICS..." : "AI ANALYZING POSE...",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // DELETED duplicate Top Bar

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

                  // Video Timer if Recording (Premium Pulsing View)
                  if (_isRecordingVideo)
                    TweenAnimationBuilder<double>(
                      tween: Tween(begin: 1.0, end: 0.5),
                      duration: const Duration(seconds: 1),
                      builder: (context, value, child) => Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(value),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.white, width: 1.5),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.radio_button_checked, color: Colors.white, size: 16),
                            const SizedBox(width: 8),
                            Text(
                              '${(_videoRecordSeconds ~/ 60).toString().padLeft(2, '0')}:${(_videoRecordSeconds % 60).toString().padLeft(2, '0')}',
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
                            ),
                          ],
                        ),
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

class _ZoomQuickBtn extends StatelessWidget {
  final String label;
  final double value;
  final double current;
  final double min;
  final double max;
  final Function(double) onTap;

  const _ZoomQuickBtn({
    required this.label,
    required this.value,
    required this.current,
    required this.min,
    required this.max,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // If this specific value isn't supported by hardware, don't show or disable
    if (value < min && value != 0.5 && value != 0.6) return const SizedBox.shrink(); 
    if (value > max && value > 8.0) return const SizedBox.shrink(); // Allow up to 100x but maybe hide others if too much

    final isSelected = (current - value).abs() < 0.1;

    return GestureDetector(
      onTap: () => onTap(value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.yellow : Colors.black45,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isSelected ? Colors.yellow : Colors.white12, width: 1),
          boxShadow: isSelected ? [BoxShadow(color: Colors.yellow.withOpacity(0.3), blurRadius: 8)] : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.black : Colors.white,
            fontSize: 10,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }
}

class _ProIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final bool isActive;

  const _ProIconButton({
    required this.icon,
    required this.onTap,
    this.isActive = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: isActive ? AppColors.accentCyan.withOpacity(0.2) : Colors.black38,
          shape: BoxShape.circle,
          border: Border.all(color: isActive ? AppColors.accentCyan : Colors.white12, width: 1),
        ),
        child: Icon(icon, color: isActive ? AppColors.accentCyan : Colors.white, size: 20),
      ),
    );
  }
}

/// A simpler helper for Row inside Container to avoid issues with constraints
class RawRow extends StatelessWidget {
  final List<Widget> children;
  final MainAxisSize mainAxisSize;
  
  const RawRow({super.key, required this.children, this.mainAxisSize = MainAxisSize.min});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: mainAxisSize,
      children: children,
    );
  }
}
