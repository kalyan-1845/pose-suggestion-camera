import 'dart:async';
import 'package:camera/camera.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import '../core/utils/image_utils.dart';

/// Service that wraps Google ML Kit Pose Detection
/// Handles initialization, frame processing, and lifecycle management
class PoseDetectorService {
  PoseDetector? _poseDetector;
  bool _isProcessing = false;
  bool _isInitialized = false;
  int _frameSkipCount = 0;
  static const int _frameSkipInterval = 2; // Process every 2nd frame

  /// Initialize the pose detector
  void initialize() {
    final options = PoseDetectorOptions(
      model: PoseDetectionModel.base, // Use base for speed on mid-range devices
      mode: PoseDetectionMode.stream,
    );
    _poseDetector = PoseDetector(options: options);
    _isInitialized = true;
  }

  /// Process a camera frame and return detected poses
  Future<List<Pose>> processFrame(
    CameraImage image,
    CameraDescription camera,
    int sensorOrientation,
  ) async {
    if (!_isInitialized || _poseDetector == null) return [];
    if (_isProcessing) return []; // Skip if still processing previous frame

    // Frame skipping for performance
    _frameSkipCount++;
    if (_frameSkipCount % _frameSkipInterval != 0) return [];

    _isProcessing = true;

    try {
      final inputImage = ImageUtils.cameraImageToInputImage(
        image,
        camera,
        sensorOrientation,
      );

      if (inputImage == null) {
        _isProcessing = false;
        return [];
      }

      final poses = await _poseDetector!.processImage(inputImage);
      _isProcessing = false;
      return poses;
    } catch (e) {
      _isProcessing = false;
      return [];
    }
  }

  /// Check if service is ready
  bool get isInitialized => _isInitialized;

  /// Check if currently processing
  bool get isProcessing => _isProcessing;

  /// Dispose the detector and release resources
  Future<void> dispose() async {
    _isInitialized = false;
    await _poseDetector?.close();
    _poseDetector = null;
  }
}
