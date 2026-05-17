import 'dart:async';
import 'dart:math' as math;
import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:camera/camera.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image/image.dart' as img;
import '../../core/constants/app_colors.dart';
import '../../core/constants/place_constants.dart';
import '../../data/models/pose_template.dart';
import '../../data/models/pose_match_result.dart';
import '../../data/repositories/template_repository.dart';
import '../../domain/pose_detector_service.dart';
import '../../domain/pose_matching_engine.dart';
import '../../domain/auto_capture_controller.dart';
import '../../domain/voice_guidance_service.dart';
import '../../domain/gesture_controller.dart';
import '../../domain/magic_enhance_service.dart';
import '../widgets/skeleton_painter.dart';
import '../widgets/ghost_pose_overlay.dart';
import '../widgets/feedback_overlay.dart';
import '../widgets/match_score_indicator.dart';
import '../widgets/pose_effects_slider.dart';
import '../widgets/mode_card.dart';
import '../widgets/place_card.dart';
import '../widgets/pose_template_card.dart';
import '../animations/countdown_overlay.dart';
import '../animations/capture_flash.dart';
import 'preview_screen.dart';
import 'collage_preview_screen.dart';
import 'wifi_share_screen.dart';
import 'pro_settings_screen.dart';
import 'mini_gallery_screen.dart';
import 'package:gal/gal.dart';
import 'package:android_intent_plus/android_intent.dart';
import 'package:android_intent_plus/flag.dart';
import '../../core/utils/watermark_service.dart';
import 'package:image_picker/image_picker.dart';

/// Main camera screen mimicking standard OS camera with a "Poses" mode
class MainCameraScreen extends StatefulWidget {
  const MainCameraScreen({super.key});

  @override
  State<MainCameraScreen> createState() => _MainCameraScreenState();
}

class _MainCameraScreenState extends State<MainCameraScreen> with WidgetsBindingObserver, TickerProviderStateMixin {
  CameraController? _cameraController;
  List<CameraDescription> _cameras = [];
  int _currentCameraIndex = 0;

  final PoseDetectorService _poseDetectorService = PoseDetectorService();
  AutoCaptureController? _autoCaptureController;
  final VoiceGuidanceService _voiceService = VoiceGuidanceService();
  final GestureController _gestureController = GestureController();
  
  bool _voiceEnabled = true;
  bool _portraitModeActive = false;
  bool _isEnhancing = false;

  bool _isInitialized = false;
  bool _isProcessingFrame = false; // Flag to throttle camera stream frame processor to prevent CPU heating/lag

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

  // Settings State
  bool _gridEnabled = false;
  bool _mirrorFrontCamera = true;
  bool _autoBrightness = true;
  String _watermarkStyle = 'leica';
  String _auraStyle = 'cyan';
  String _filmRecipe = 'none';
  String? _latestPhotoPath;

  // Leo AI Voice Assistant State
  bool _leoActive = false;
  String _leoSpeechText = "";
  AnimationController? _leoAnimationController;

  // Filtering State
  String _selectedCategory = 'solo'; // 'solo', 'couple', 'friends', 'family'
  String _selectedPlaceId = 'any';   // 'any', 'beach', 'cafe', etc.

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
    _loadSettings();
    _applySmartContextSuggestions();
    _filterTemplates(initial: true);
    _initCamera();
    _poseDetectorService.initialize();
    
    _leoAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _leoAnimationController?.dispose();
    super.dispose();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        _gridEnabled = prefs.getBool('pro_grid') ?? false;
        _mirrorFrontCamera = prefs.getBool('pro_mirror') ?? true;
        _autoBrightness = prefs.getBool('pro_auto_bright') ?? true;
        _watermarkStyle = prefs.getString('pro_watermark_style') ?? 'leica';
        _auraStyle = prefs.getString('pro_aura_style') ?? 'cyan';
        _filmRecipe = prefs.getString('pro_film_recipe') ?? 'none';
      });
    }
  }

  Color _getAuraColor() {
    switch (_auraStyle) {
      case 'pink':
        return const Color(0xFFFF007F); // Cyberpunk Pink
      case 'green':
        return const Color(0xFF39FF14); // Toxic Acid Green
      case 'amber':
        return const Color(0xFFFFAA00); // Sunset Amber
      case 'cyan':
      default:
        return const Color(0xFF00E5FF); // Electric Arctic Cyan
    }
  }

  void _applySmartContextSuggestions() {
    final now = DateTime.now();
    if (now.hour >= 17 && now.hour <= 19) {
      _selectedPlaceId = 'sunset';
    } else if (now.hour >= 7 && now.hour <= 9) {
      _selectedPlaceId = 'garden';
    } else if (now.hour >= 12 && now.hour <= 14) {
      _selectedPlaceId = 'cafe';
    } else {
      _selectedPlaceId = 'any';
    }
  }

  double _lastHapticScore = 0.0;

  void _triggerParkingSensorHaptics(double score, bool wasMatched, bool isMatched) {
    // 1. Lock Transition (Unmatched -> Matched)
    if (isMatched && !wasMatched) {
      HapticFeedback.heavyImpact();
      Future.delayed(const Duration(milliseconds: 100), () => HapticFeedback.mediumImpact());
      return;
    }

    // 2. Parking sensor threshold crossings
    if (score >= 70 && _lastHapticScore < 70 && !isMatched) {
      HapticFeedback.mediumImpact();
    } else if (score >= 50 && _lastHapticScore < 50 && score < 70) {
      HapticFeedback.lightImpact();
    }
    
    _lastHapticScore = score;
  }

  void _triggerLeoAIScan() async {
    if (_leoActive) return;
    
    setState(() {
      _leoActive = true;
      _leoSpeechText = "Hey! Leo here.\nListening to environment context...";
    });

    _leoAnimationController?.repeat();

    // Siri-style haptic tap trigger
    HapticFeedback.heavyImpact();
    await Future.delayed(const Duration(milliseconds: 150));
    HapticFeedback.lightImpact();

    // Dynamic environment scan
    final now = DateTime.now();
    String detectedEnvironment = "daylight";
    String recommendedTemplate = "Standing Outdoor";
    String recomPlace = "garden";

    if (now.hour >= 17 && now.hour <= 19) {
      detectedEnvironment = "Sunset Golden Hour";
      recommendedTemplate = "Sunset Silhouette";
      recomPlace = "sunset";
    } else if (now.hour >= 12 && now.hour <= 14) {
      detectedEnvironment = "Midday Cafe Vibe";
      recommendedTemplate = "Cozy Cafe Seated";
      recomPlace = "cafe";
    } else {
      detectedEnvironment = "Bright Morning Park";
      recommendedTemplate = "Standing Outdoor";
      recomPlace = "garden";
    }

    setState(() {
      _selectedPlaceId = recomPlace;
      _watermarkStyle = 'leica'; // Force premium Leica specs for master level capture
    });
    
    _filterTemplates();

    final speechText = "Hey there! Leo here. Scanning your scene... "
        "I've detected beautiful $detectedEnvironment lighting. "
        "Applying our premium Leica M11 profile and loading a master-class $recommendedTemplate guide. "
        "Get in frame and prepare to strike a pose! I will capture your shot in 3 seconds!";

    setState(() {
      _leoSpeechText = "Scanning scene...\n\n[SUCCESS] Detected $detectedEnvironment\n[APPLIED] Leica M11 Color Style\n[LOADED] $recommendedTemplate Pose";
    });

    await _voiceService.speak(speechText);

    // Give voice assistant 6 seconds to comfortably complete speaking before capturing
    await Future.delayed(const Duration(seconds: 6));

    if (!mounted) return;
    _startLeoCountdown();
  }

  void _startLeoCountdown() async {
    setState(() {
      _leoActive = false;
      _leoSpeechText = "";
      _showCountdown = true;
      _countdownValue = 3;
    });

    _leoAnimationController?.stop();

    for (int i = 3; i > 0; i--) {
      if (!mounted) return;
      setState(() {
        _countdownValue = i;
      });
      HapticFeedback.mediumImpact();
      await _voiceService.speak("$i");
      await Future.delayed(const Duration(seconds: 1));
    }

    if (!mounted) return;
    setState(() {
      _showCountdown = false;
    });

    // Capture the premium master photo!
    _takePhoto();
  }

  void _filterTemplates({bool initial = false}) {
    final filtered = TemplateRepository.byCategoryAndPlace(_selectedCategory, _selectedPlaceId);
    if (mounted) {
      setState(() {
        _allTemplates = filtered;
        if (filtered.isNotEmpty) {
          _selectedTemplate = filtered.first;
        } else {
          _selectedTemplate = null;
        }
      });
    } else if (initial) {
      _allTemplates = filtered;
      if (filtered.isNotEmpty) {
        _selectedTemplate = filtered.first;
      } else {
        _selectedTemplate = null;
      }
    }
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
      ResolutionPreset.high, // Optimized: 1080p for performance & clarity
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
    if (_isProcessingFrame) return; // Drop redundant/overlapping camera frames to cool down device and stop UI lag!
    
    final mode = _cameraModes[_selectedModeIndex];
    final isPoseMode = mode == 'Poses' || mode == 'Photo Booth';

    if (!isPoseMode || _selectedTemplate == null) {
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

    _isProcessingFrame = true; // Lock process
    _poseDetectorService.processFrame(image, camera, sensorOrientation).then((poses) {
      _isProcessingFrame = false; // Unlock process
      if (!mounted) return;

      if (poses.isNotEmpty && _selectedTemplate != null) {
        final pose = poses.first;
        final wasMatched = _matchResult.isMatched;
        final result = PoseMatchingEngine.compare(pose, _selectedTemplate!);

        setState(() {
          _currentPose = pose;
          _matchResult = result;
          _updateAutoFraming(pose);
        });

        // Smart Parking Sensor Haptics (Feedback guidance)
        _triggerParkingSensorHaptics(result.score, wasMatched, result.isMatched);

        // 1. Hands-Free Gesture detection
        if (_gestureController.checkRightHandWave(pose)) {
          _autoCaptureController?.manualCapture();
          _voiceService.speak('Awesome gesture! Capture.');
        } else if (_gestureController.checkLeftHandVictory(pose)) {
          // Instantly switch to Photo Booth mode if not active
          if (_cameraModes[_selectedModeIndex] != 'Photo Booth') {
            setState(() {
              _selectedModeIndex = _cameraModes.indexOf('Photo Booth');
              _photoBoothImages.clear();
            });
          }
          _autoCaptureController?.manualCapture();
          _voiceService.speak('Left hand victory detected! High-Speed Photo Booth collage initiated!');
        }

        // 2. Voice feedback for posture
        if (result.feedback.isNotEmpty && !result.isMatched) {
          _voiceService.speak(result.feedback.first);
        }

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
    }).catchError((e) {
      _isProcessingFrame = false; // Safe unlock on error
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

    // Process photo with Pro features (Watermark, Blur)
    _processPhotoWithProFeatures(path, mode).then((processedPath) {
      if (!mounted) return;

      if (mode == 'Photo Booth') {
        _photoBoothImages.add(processedPath);
        
        if (_photoBoothImages.length < 4) {
           // Cycle to next template for variety
           int nextIndex = (_allTemplates.indexOf(_selectedTemplate!) + 1) % _allTemplates.length;
           setState(() {
             _selectedTemplate = _allTemplates[nextIndex];
             _autoCaptureController?.reset(); // Allow next capture
           });
           _voiceService.speak('Next pose in 3 seconds!');
        } else {
           // All 4 captured! Show collage
           Navigator.push(context, MaterialPageRoute(builder: (_) => CollagePreviewScreen(imagePaths: _photoBoothImages)));
           _photoBoothImages.clear();
        }
      } else {
        // Standard single photo auto-saves in the background like native camera apps!
        if (mounted) {
          setState(() {
            _latestPhotoPath = processedPath;
          });
        }

        // Allow immediate next capture
        _autoCaptureController?.reset();

        Gal.putImage(processedPath).then((_) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('AuraPose AI photo saved to Gallery!'),
                duration: Duration(milliseconds: 1500),
                backgroundColor: Colors.black87,
              ),
            );
          }
        });
      }
    });
  }

  Future<String> _processPhotoWithProFeatures(String path, String mode) async {
    try {
      if (mounted) setState(() => _isEnhancing = true);

      final file = File(path);
      Uint8List bytes = await file.readAsBytes();

      // 0. Permanent EXIF Orientation Baking & Front Camera Mirroring
      img.Image? decoded = img.decodeImage(bytes);
      if (decoded != null) {
        // Bake EXIF orientation directly into the pixels so it never displays rotated in editors
        decoded = img.bakeOrientation(decoded);
        
        // Mirror horizontally if front camera selfie and mirroring is enabled
        if (_currentCameraIndex == 1 && _mirrorFrontCamera) {
          decoded = img.flipHorizontal(decoded);
        }

        // Apply Selected Analog Film Recipe (Flagship Color Simulation)
        if (_filmRecipe != 'none') {
          final math.Random random = math.Random();
          for (int y = 0; y < decoded.height; y++) {
            for (int x = 0; x < decoded.width; x++) {
              final pixel = decoded.getPixel(x, y);
              int r = pixel.r.toInt();
              int g = pixel.g.toInt();
              int b = pixel.b.toInt();
              
              if (_filmRecipe == 'classic_chrome') {
                // Fujifilm Classic Chrome: Cool teal cast, desaturated warm tones
                r = (r * 0.92).toInt().clamp(0, 255);
                g = (g * 1.04).toInt().clamp(0, 255);
                b = (b * 1.08).toInt().clamp(0, 255);
              } else if (_filmRecipe == 'portra_400') {
                // Kodak Portra 400: Warm golds, rich orange, pulled down blue shadows
                r = (r * 1.12).toInt().clamp(0, 255);
                g = (g * 1.05).toInt().clamp(0, 255);
                b = (b * 0.88).toInt().clamp(0, 255);
              } else if (_filmRecipe == 'noir_grain') {
                // Aura Noir: High-contrast silver monochrome with organic film grain
                int gray = (0.299 * r + 0.587 * g + 0.114 * b).toInt();
                gray = (((gray - 128) * 1.25) + 128).toInt().clamp(0, 255);
                final grain = random.nextInt(26) - 13;
                gray = (gray + grain).clamp(0, 255);
                r = gray;
                g = gray;
                b = gray;
              }
              
              pixel.r = r;
              pixel.g = g;
              pixel.b = b;
            }
          }
        }
        
        bytes = Uint8List.fromList(img.encodeJpg(decoded, quality: 95));
      }

      // 1. Mandatory Cinematic Watermark
      bytes = await WatermarkService.applyCinematicWatermark(
        bytes, 
        "iQOO Z6 Lite 5G",
        watermarkStyle: _watermarkStyle,
      );

      // 2. AI Magic Enhance (Flagship Pass)
      // This sharpens, fixes colors and reduces noise
      bytes = await MagicEnhanceService.enhance(bytes);

      await file.writeAsBytes(bytes);
      
      if (mounted) setState(() => _isEnhancing = false);
    } catch (e) {
      debugPrint('Error processing pro features: $e');
      if (mounted) setState(() => _isEnhancing = false);
    }
    return path;
  }

  void _switchCamera() async {
    if (_cameras.length < 2) return;

    await _cameraController?.stopImageStream();
    _currentCameraIndex = (_currentCameraIndex + 1) % _cameras.length;
    await _setupCamera(_cameras[_currentCameraIndex]);
  }

  void _openReceiveScreen() {
    _cameraController?.stopImageStream().then((_) {
      _cameraController?.dispose().then((_) {
        if (mounted) {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => WifiShareScreen()),
          ).then((_) {
            _setupCamera(_cameras[_currentCameraIndex]);
          });
        }
      });
    });
  }

  void _toggleCleanView() {
    setState(() => _isCleanView = !_isCleanView);
  }

  void _toggleGhostPose() {
    setState(() => _showGhostPose = !_showGhostPose);
  }

  void _showPoseCatalogSheet() {
    final TextEditingController searchController = TextEditingController();
    String query = '';
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black54,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            // Get all matching templates based on current selections and search query
            final categoryCounts = TemplateRepository.categoryCounts;
            
            // Search & filter matching templates
            List<PoseTemplate> filteredTemplates = TemplateRepository.byCategoryAndPlace(_selectedCategory, _selectedPlaceId);
            if (query.isNotEmpty) {
              filteredTemplates = filteredTemplates.where((t) => t.name.toLowerCase().contains(query.toLowerCase())).toList();
            }
            
            return BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
              child: Container(
                height: MediaQuery.of(context).size.height * 0.85,
                padding: const EdgeInsets.only(top: 10),
                decoration: BoxDecoration(
                  color: AppColors.background.withOpacity(0.92),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                  border: Border.all(color: AppColors.glassBorder, width: 1.5),
                ),
                child: Column(
                  children: [
                    // Slide Handle
                    Container(
                      width: 40,
                      height: 5,
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white30,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    const SizedBox(height: 8),
                    
                    // Sheet Header
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Pose & Location Hub",
                                style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                "Select location and matches will be ranked automatically",
                                style: TextStyle(color: AppColors.textSecondary.withOpacity(0.8), fontSize: 11),
                              ),
                            ],
                          ),
                          IconButton(
                            onPressed: () => Navigator.pop(context),
                            icon: const Icon(Icons.close, color: Colors.white54),
                          )
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Search Bar
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(color: AppColors.glassBorder),
                        ),
                        child: TextField(
                          controller: searchController,
                          style: const TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            hintText: "Search 50+ aesthetic poses...",
                            hintStyle: const TextStyle(color: AppColors.textMuted),
                            prefixIcon: const Icon(Icons.search, color: AppColors.accentCyan),
                            suffixIcon: query.isNotEmpty
                                ? IconButton(
                                    icon: const Icon(Icons.clear, color: Colors.white54),
                                    onPressed: () {
                                      searchController.clear();
                                      setSheetState(() => query = '');
                                    },
                                  )
                                : null,
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          onChanged: (val) {
                            setSheetState(() => query = val);
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Bottom Sheet Content List
                    Expanded(
                      child: ListView(
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        children: [
                          // 1. Choose Category Section
                          const Text(
                            "POSE CATEGORY",
                            style: TextStyle(color: AppColors.textSecondary, fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 1.2),
                          ),
                          const SizedBox(height: 12),
                          SizedBox(
                            height: 110,
                            child: ListView(
                              scrollDirection: Axis.horizontal,
                              physics: const BouncingScrollPhysics(),
                              children: [
                                ModeCard(
                                  title: 'Solo',
                                  subtitle: 'Self portraits',
                                  icon: Icons.person,
                                  emoji: '🧍',
                                  poseCount: categoryCounts['solo'] ?? 0,
                                  gradient: AppColors.modeGradients[0],
                                  onTap: () {
                                    setSheetState(() {
                                      _selectedCategory = 'solo';
                                    });
                                    _filterTemplates();
                                    HapticFeedback.mediumImpact();
                                  },
                                ),
                                const SizedBox(width: 12),
                                ModeCard(
                                  title: 'Couple',
                                  subtitle: 'Romantic & fun',
                                  icon: Icons.favorite,
                                  emoji: '👩‍❤️‍👨',
                                  poseCount: categoryCounts['couple'] ?? 0,
                                  gradient: AppColors.modeGradients[1],
                                  onTap: () {
                                    setSheetState(() {
                                      _selectedCategory = 'couple';
                                    });
                                    _filterTemplates();
                                    HapticFeedback.mediumImpact();
                                  },
                                ),
                                const SizedBox(width: 12),
                                ModeCard(
                                  title: 'Friends',
                                  subtitle: 'Group photos',
                                  icon: Icons.people,
                                  emoji: '👯',
                                  poseCount: categoryCounts['friends'] ?? 0,
                                  gradient: AppColors.modeGradients[2],
                                  onTap: () {
                                    setSheetState(() {
                                      _selectedCategory = 'friends';
                                    });
                                    _filterTemplates();
                                    HapticFeedback.mediumImpact();
                                  },
                                ),
                                const SizedBox(width: 12),
                                ModeCard(
                                  title: 'Family',
                                  subtitle: 'Warm bonding',
                                  icon: Icons.home,
                                  emoji: '👨‍👩‍👧‍👦',
                                  poseCount: categoryCounts['family'] ?? 0,
                                  gradient: AppColors.modeGradients[3],
                                  onTap: () {
                                    setSheetState(() {
                                      _selectedCategory = 'family';
                                    });
                                    _filterTemplates();
                                    HapticFeedback.mediumImpact();
                                  },
                                ),
                              ],
                            ),
                          ),
                          
                          // 1.5 Scene selection using PlaceCards
                          const SizedBox(height: 24),
                          const Text(
                            "SCENE / LOCATION",
                            style: TextStyle(color: AppColors.textSecondary, fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 1.2),
                          ),
                          const SizedBox(height: 12),
                          SizedBox(
                            height: 120,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              physics: const BouncingScrollPhysics(),
                              itemCount: PlaceConstants.places.length,
                              itemBuilder: (context, index) {
                                final place = PlaceConstants.places[index];
                                // Count how many poses in this category match the place
                                final poseCount = TemplateRepository.countByPlace(_selectedCategory, place.id);
                                return Padding(
                                  padding: const EdgeInsets.only(right: 12),
                                  child: SizedBox(
                                    width: 140,
                                    child: PlaceCard(
                                      place: place,
                                      poseCount: poseCount,
                                      onTap: () {
                                        setSheetState(() {
                                          _selectedPlaceId = place.id;
                                        });
                                        _filterTemplates();
                                        HapticFeedback.mediumImpact();
                                      },
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                          const SizedBox(height: 24),
                          
                          // Active filters pill row (Category filter indication)
                          Row(
                            children: [
                              Text(
                                "POSE IDEAS FOR ${_selectedCategory.toUpperCase()} - ${_selectedPlaceId.toUpperCase()}",
                                style: const TextStyle(color: AppColors.textSecondary, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1.2),
                              ),
                              const Spacer(),
                              Text(
                                "${filteredTemplates.length} matches",
                                style: const TextStyle(color: AppColors.accentCyan, fontSize: 11, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          
                          // 2. Main Poses Grid
                          filteredTemplates.isEmpty
                              ? Container(
                                  padding: const EdgeInsets.symmetric(vertical: 40),
                                  child: const Center(
                                    child: Column(
                                      children: [
                                        Icon(Icons.search_off, color: Colors.white24, size: 48),
                                        SizedBox(height: 12),
                                        Text(
                                          "No poses found for this query",
                                          style: TextStyle(color: AppColors.textMuted, fontSize: 13),
                                        ),
                                      ],
                                    ),
                                  ),
                                )
                              : ListView.builder(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: filteredTemplates.length,
                                  itemBuilder: (context, index) {
                                    final template = filteredTemplates[index];
                                    final isSelected = template.id == _selectedTemplate?.id;
                                    return Padding(
                                      padding: const EdgeInsets.only(bottom: 12),
                                      child: PoseTemplateCard(
                                        template: template,
                                        isSuggested: isSelected,
                                        onTap: () {
                                          setState(() {
                                            _selectedTemplate = template;
                                            _matchResult = PoseMatchResult.empty;
                                          });
                                          _autoCaptureController?.reset();
                                          HapticFeedback.mediumImpact();
                                          Navigator.pop(context); // Close catalog sheet
                                        },
                                      ),
                                    );
                                  },
                                ),
                          const SizedBox(height: 40),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
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
      HapticFeedback.selectionClick();
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

  void _openGallery() {
    if (Theme.of(context).platform == TargetPlatform.android) {
       const intent = AndroidIntent(
         action: 'android.intent.action.VIEW',
         type: 'image/*',
         flags: [Flag.FLAG_ACTIVITY_NEW_TASK],
       );
       intent.launch();
    }
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
    if (_cameraController == null || !_cameraController!.value.isInitialized) return;
    
    if (state == AppLifecycleState.inactive) {
      _cameraController?.dispose();
    } else if (state == AppLifecycleState.resumed) {
      _setupCamera(_cameras[_currentCameraIndex]);
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
    HapticFeedback.selectionClick();

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
    _voiceService.stop();
    super.dispose();
  }

  FlashMode _flashMode = FlashMode.off;

  Future<void> _toggleFlash() async {
    if (_cameraController == null) return;
    
    FlashMode nextMode;
    switch (_flashMode) {
      case FlashMode.off:
        nextMode = FlashMode.auto; // Start with Auto
        break;
      case FlashMode.auto:
        nextMode = FlashMode.always; // Then On
        break;
      case FlashMode.always:
        nextMode = FlashMode.torch; // Then Torch
        break;
      case FlashMode.torch:
        nextMode = FlashMode.off; // Back to Off
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
              setState(() => _isZoomDragging = true);
            },
            onScaleEnd: (details) {
              setState(() => _isZoomDragging = false);
            },
            onScaleUpdate: (details) async {
              if (_cameraController == null) return;
              double zoomLevel = _baseZoomLevel * details.scale;
              if (zoomLevel < _minZoomLevel) zoomLevel = _minZoomLevel;
              if (zoomLevel > 100.0) zoomLevel = 100.0;
              
              if ((zoomLevel - _currentZoomLevel).abs() > 0.05) {
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
                duration: _isZoomDragging ? Duration.zero : const Duration(milliseconds: 300),
                curve: Curves.easeOut,
                transform: Matrix4.identity()
                  ..translate(_framingOffset.dx, _framingOffset.dy)
                  ..scale(_framingScale * _digitalZoomScale),
                alignment: Alignment.center,
                child: Center(
                  child: RepaintBoundary(
                    child: AspectRatio(
                      aspectRatio: 1 / _cameraController!.value.aspectRatio,
                      child: CameraPreview(_cameraController!),
                    ),
                  ),
                ),
              ),
            ),
          ),

          // ── Rule of Thirds Grid Overlay ──
          if (_gridEnabled && !_isCleanView)
            Positioned.fill(
              child: IgnorePointer(
                child: CustomPaint(
                  painter: GridPainter(),
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
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Left Side: Settings
                          _ProIconButton(
                            icon: Icons.settings, 
                            onTap: () => Navigator.push(
                              context, 
                              MaterialPageRoute(builder: (_) => const ProSettingsScreen())
                            ).then((_) => _loadSettings()),
                          ),

                          // Right Group: Voice, Flash & Flip
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              _ProIconButton(
                                icon: _voiceEnabled ? Icons.volume_up : Icons.volume_off,
                                onTap: () {
                                  setState(() {
                                    _voiceEnabled = !_voiceEnabled;
                                    _voiceService.toggle(_voiceEnabled);
                                  });
                                },
                                isActive: _voiceEnabled,
                              ),
                              const SizedBox(width: 10),
                              _ProIconButton(
                                icon: _getFlashIcon(),
                                onTap: _toggleFlash,
                                isActive: _flashMode != FlashMode.off,
                              ),
                              const SizedBox(width: 10),
                              _ProIconButton(
                                icon: Icons.cameraswitch,
                                onTap: _switchCamera,
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      // Zoom Quick Select Chips (Simplified)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _ZoomQuickBtn(label: '0.6x', value: 0.6, current: _currentZoomLevel, min: _minZoomLevel, max: _maxZoomLevel, onTap: _setZoom),
                          _ZoomQuickBtn(label: '1x', value: 1.0, current: _currentZoomLevel, min: _minZoomLevel, max: _maxZoomLevel, onTap: _setZoom),
                          _ZoomQuickBtn(label: '2x', value: 2.0, current: _currentZoomLevel, min: _minZoomLevel, max: _maxZoomLevel, onTap: _setZoom),
                          _ZoomQuickBtn(label: '5x', value: 5.0, current: _currentZoomLevel, min: _minZoomLevel, max: _maxZoomLevel, onTap: _setZoom),
                        ],
                      ),
                      const SizedBox(height: 12),
                      // AI Status & Cameraman Centralized Row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (isPoseMode) ...[
                            _TopCapsule(
                              onTap: _openReceiveScreen,
                              icon: Icons.qr_code_scanner,
                              label: 'QR',
                              color: Colors.black45,
                            ),
                            const SizedBox(width: 8),
                          ],
                          _TopCapsule(
                            onTap: () {
                              setState(() {
                                _autoFramingEnabled = !_autoFramingEnabled;
                                if (!_autoFramingEnabled) {
                                  _framingScale = 1.0;
                                  _framingOffset = Offset.zero;
                                }
                              });
                            },
                            icon: Icons.face_retouching_natural,
                            label: 'AI CAMERAMAN',
                            color: _autoFramingEnabled ? AppColors.accentCyan : Colors.black45,
                            isActive: _autoFramingEnabled,
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
                  isMatched: _matchResult.score >= 80.0,
                  auraColor: _getAuraColor(),
                ),
              ),

            // Advanced AI Joint Correction Compass Overlay
            if (_showGhostPose && _currentPose != null && !_isCleanView)
              Positioned.fill(
                child: CustomPaint(
                  painter: SkeletonPainter(
                    pose: _currentPose!,
                    imageSize: _imageSize,
                    rotation: _imageRotation,
                    matchResult: _matchResult,
                    isFrontCamera: _currentCameraIndex == 1,
                    template: _selectedTemplate!,
                    accentColor: _getAuraColor(),
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
                  child: RepaintBoundary(
                    child: Icon(
                      Icons.visibility,
                      color: _showGhostPose ? AppColors.accentCyan : Colors.white54,
                      size: 22,
                    ),
                  ),
                ),
              ),
            ),

            // Feedback Overlay (Moved Higher)
            Positioned(
              bottom: 340, // Much higher to clear zoom controls and emojis
              left: 30,
              right: 30,
              child: FeedbackOverlay(
                feedback: _matchResult.feedback,
                scoreLabel: _matchResult.scoreLabel,
              ),
            ),
          ],

          // ── Pro Zoom Controller (Elevated Layer) ──
          if (!_isCleanView)
            Positioned(
              bottom: 240, // Elevated above pose selector
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
                    onPanStart: (details) => setState(() => _isZoomDragging = true),
                    onPanEnd: (details) => setState(() => _isZoomDragging = false),
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
                        onChangeStart: (v) => setState(() => _isZoomDragging = true),
                        onChangeEnd: (v) => setState(() => _isZoomDragging = false),
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

          // ── AI Dynamic Stats (Integrated Status) ──
          if (!_isCleanView)
          Positioned(
            top: MediaQuery.of(context).padding.top + 70,
            left: 0,
            right: 0,
            child: Center(
              child: AnimatedOpacity(
                opacity: (isPoseMode && _selectedTemplate != null) ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 300),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.black45,
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: Colors.white12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.auto_awesome, color: AppColors.accentCyan, size: 12),
                      const SizedBox(width: 6),
                      Text(
                        _isZoomDragging ? "AURA CALIBRATING OPTICS" : "AURAPOSE AI ANALYZING",
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 9,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.0,
                        ),
                      ),
                    ],
                  ),
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
                  if (isPoseMode) ...[
                    // Horizontal scrolling Location scene chips
                    SizedBox(
                      height: 38,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        itemCount: PlaceConstants.places.length,
                        itemBuilder: (context, index) {
                          final place = PlaceConstants.places[index];
                          final isSelected = place.id == _selectedPlaceId;
                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedPlaceId = place.id;
                                _filterTemplates();
                              });
                              HapticFeedback.selectionClick();
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              margin: const EdgeInsets.only(right: 10),
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                              decoration: BoxDecoration(
                                color: isSelected ? AppColors.accentCyan.withOpacity(0.18) : Colors.black45,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: isSelected ? AppColors.accentCyan : Colors.white12,
                                  width: 1,
                                ),
                                boxShadow: isSelected
                                    ? [BoxShadow(color: AppColors.accentCyan.withOpacity(0.2), blurRadius: 8)]
                                    : [],
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(place.icon, color: isSelected ? AppColors.accentCyan : Colors.white60, size: 14),
                                  const SizedBox(width: 6),
                                  Text(
                                    place.name,
                                    style: TextStyle(
                                      color: isSelected ? AppColors.accentCyan : Colors.white70,
                                      fontSize: 11,
                                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 14),
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
                    ),
                  ] else
                     const SizedBox(height: 162), // Placeholder to keep layout stable

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
                      // Gallery / Latest Snap Live Preview Thumbnail Bubble
                      GestureDetector(
                        onTap: () {
                          if (_latestPhotoPath != null) {
                            // Instant high-fidelity pose evaluation editor view!
                            _cameraController?.stopImageStream().then((_) {
                              if (mounted) {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => PreviewScreen(
                                      imagePath: _latestPhotoPath!,
                                      templateId: _selectedTemplate?.id ?? 'custom',
                                      templateName: _selectedTemplate?.name ?? 'Standard Photo',
                                      matchScore: mode == 'Poses' ? _matchResult.score : 100.0,
                                      isFrontCamera: _currentCameraIndex == 1,
                                    ),
                                  ),
                                ).then((_) {
                                   // Resume camera stream when returning
                                   _showGhostPose = true; 
                                   _autoCaptureController?.reset();
                                   if (_cameraController != null && _cameraController!.value.isInitialized) {
                                       _cameraController!.startImageStream(_processFrame).catchError((e){});
                                   }
                                });
                              }
                            });
                          } else {
                            // Fallback to native system photo library intent
                            _openGallery();
                          }
                        },
                        child: Container(
                          width: 46,
                          height: 46,
                          decoration: BoxDecoration(
                            shape: BoxShape.rectangle,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.white, width: 2),
                            color: Colors.black38,
                            boxShadow: _latestPhotoPath != null
                                ? [
                                    BoxShadow(
                                      color: _getAuraColor().withOpacity(0.5),
                                      blurRadius: 6,
                                      spreadRadius: 1,
                                    )
                                  ]
                                : null,
                            image: _latestPhotoPath != null
                                ? DecorationImage(
                                    image: FileImage(File(_latestPhotoPath!)),
                                    fit: BoxFit.cover,
                                  )
                                : null,
                          ),
                          child: _latestPhotoPath == null
                              ? const Icon(Icons.photo_library, color: Colors.white70, size: 20)
                              : null,
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
                      
                      // Pose Catalog Bottom Sheet Button
                      GestureDetector(
                        onTap: _showPoseCatalogSheet,
                        child: Container(
                          width: 46,
                          height: 46,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white24, width: 1.5),
                            color: Colors.black45,
                          ),
                          child: const Icon(Icons.grid_view, color: AppColors.accentCyan, size: 20),
                        ),
                      ),
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

          // ── AI Enhancement Overlay (Flagship Style) ──
          if (_isEnhancing)
            Positioned.fill(
              child: Container(
                color: Colors.black54,
                child: Center(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 30),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.white24),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const CircularProgressIndicator(color: AppColors.accentCyan, strokeWidth: 2),
                            const SizedBox(height: 24),
                            Text(
                              "AURA AI ENHANCING...",
                              style: TextStyle(
                                color: AppColors.accentCyan.withOpacity(0.9),
                                fontSize: 13,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 2,
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              "Optimizing details and colors",
                              style: TextStyle(color: Colors.white70, fontSize: 10),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            // ── Leo AI floating trigger button ──
          if (!_isCleanView && isPoseMode)
            Positioned(
              top: MediaQuery.of(context).padding.top + 130,
              right: 16,
              child: GestureDetector(
                onTap: _triggerLeoAIScan,
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      colors: [Color(0xFFff2d55), Color(0xFF5856d6), Color(0xFF007aff)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF5856d6).withOpacity(0.6),
                        blurRadius: 16,
                        spreadRadius: 2,
                      )
                    ],
                  ),
                  child: const Icon(
                    Icons.blur_on,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
              ),
            ),

          // ── Fullscreen Siri Mesh Orb Overlay ──
          if (_leoActive) ...[
            // Blur Background
            Positioned.fill(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                child: Container(
                  color: Colors.black.withOpacity(0.4),
                ),
              ),
            ),
            // Glowing Animated Mesh Orb at the bottom center
            Positioned(
              bottom: 80,
              left: 0,
              right: 0,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Text Bubble from Assistant Leo
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 30),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.7),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white12),
                    ),
                    child: Text(
                      _leoSpeechText,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        height: 1.4,
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                  // Pulse Mesh Orb
                  AnimatedBuilder(
                    animation: _leoAnimationController!,
                    builder: (context, child) {
                      return SizedBox(
                        width: 150,
                        height: 150,
                        child: CustomPaint(
                          painter: SiriOrbPainter(_leoAnimationController!.value),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
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
class _TopCapsule extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final bool isActive;
  final VoidCallback onTap;

  const _TopCapsule({
    required this.icon,
    required this.label,
    required this.color,
    this.isActive = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? AppColors.accentCyan : color,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white12, width: 1),
          boxShadow: isActive ? [BoxShadow(color: AppColors.accentCyan.withOpacity(0.3), blurRadius: 10)] : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: isActive ? Colors.black : Colors.white, size: 16),
            const SizedBox(width: 8),
            Text(label, style: TextStyle(
              color: isActive ? Colors.black : Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.1,
            )),
          ],
        ),
      ),
    );
  }
}

/// Custom painter to draw Rule of Thirds 3x3 grid lines
class GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.25)
      ..strokeWidth = 1.0;

    // Draw vertical lines
    canvas.drawLine(Offset(size.width / 3, 0), Offset(size.width / 3, size.height), paint);
    canvas.drawLine(Offset(size.width * 2 / 3, 0), Offset(size.width * 2 / 3, size.height), paint);

    // Draw horizontal lines
    canvas.drawLine(Offset(0, size.height / 3), Offset(size.width, size.height / 3), paint);
    canvas.drawLine(Offset(0, size.height * 2 / 3), Offset(size.width, size.height * 2 / 3), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class SiriOrbPainter extends CustomPainter {
  final double animationValue;

  SiriOrbPainter(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    
    // Create animated multi-color gradient
    final gradient = RadialGradient(
      center: Alignment(
        0.3 * math.sin(animationValue * 2 * math.pi),
        0.3 * math.cos(animationValue * 2 * math.pi),
      ),
      radius: 0.8 + 0.15 * math.sin(animationValue * 4 * math.pi),
      colors: const [
        Color(0xFFFF2D55), // Neon pink
        Color(0xFF5856D6), // Purple
        Color(0xFF007AFF), // Blue
        Color(0x00007AFF), // Transparent
      ],
      stops: const [0.0, 0.3, 0.6, 1.0],
    );

    final paint = Paint()
      ..shader = gradient.createShader(rect)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 20);

    canvas.drawCircle(
      Offset(size.width / 2, size.height / 2),
      (size.width / 2) * (0.95 + 0.05 * math.sin(animationValue * 2 * math.pi)),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant SiriOrbPainter oldDelegate) =>
      oldDelegate.animationValue != animationValue;
}
