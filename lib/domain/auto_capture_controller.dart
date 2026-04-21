import 'dart:async';
import 'package:camera/camera.dart';
import '../core/constants/pose_constants.dart';

/// Controls auto-capture logic:
/// - Monitors match score stability
/// - Triggers countdown when score > threshold for N seconds
/// - Captures photo via camera controller
class AutoCaptureController {
  final CameraController cameraController;
  final Function(String path) onCaptured;
  final Function(int secondsLeft) onCountdownTick;
  final Function() onCountdownStart;
  final Function() onCountdownCancel;

  Timer? _stabilityTimer;
  Timer? _countdownTimer;
  bool _isCountingDown = false;
  bool _hasCaptured = false;
  int _countdownSecondsLeft = PoseConstants.countdownSeconds;
  DateTime? _matchStartTime;

  AutoCaptureController({
    required this.cameraController,
    required this.onCaptured,
    required this.onCountdownTick,
    required this.onCountdownStart,
    required this.onCountdownCancel,
  });

  /// Update with latest match score
  void updateScore(double score) {
    if (_hasCaptured) return;

    if (score >= PoseConstants.matchThreshold) {
      // Score is above threshold
      _matchStartTime ??= DateTime.now();

      final elapsed = DateTime.now().difference(_matchStartTime!).inMilliseconds;

      if (elapsed >= PoseConstants.stabilityDurationMs && !_isCountingDown) {
        // Stable for long enough — start countdown!
        _startCountdown();
      }
    } else {
      // Score dropped below threshold
      _matchStartTime = null;

      if (_isCountingDown) {
        _cancelCountdown();
      }
    }
  }

  /// Start the capture countdown
  void _startCountdown() {
    _isCountingDown = true;
    _countdownSecondsLeft = PoseConstants.countdownSeconds;
    onCountdownStart();
    onCountdownTick(_countdownSecondsLeft);

    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _countdownSecondsLeft--;
      onCountdownTick(_countdownSecondsLeft);

      if (_countdownSecondsLeft <= 0) {
        timer.cancel();
        _capture();
      }
    });
  }

  /// Cancel the countdown
  void _cancelCountdown() {
    _countdownTimer?.cancel();
    _isCountingDown = false;
    _countdownSecondsLeft = PoseConstants.countdownSeconds;
    onCountdownCancel();
  }

  /// Capture the photo
  Future<void> _capture() async {
    if (_hasCaptured) return;
    _hasCaptured = true;
    _isCountingDown = false;

    try {
      final XFile photo = await cameraController.takePicture();
      onCaptured(photo.path);
    } catch (e) {
      _hasCaptured = false; // Allow retry on failure
    }
  }

  /// Manual capture trigger
  Future<void> manualCapture() async {
    if (_hasCaptured) return;
    _hasCaptured = true;
    _cancelCountdown();

    try {
      final XFile photo = await cameraController.takePicture();
      onCaptured(photo.path);
    } catch (e) {
      _hasCaptured = false;
    }
  }

  /// Reset state for new pose attempt
  void reset() {
    _cancelCountdown();
    _hasCaptured = false;
    _matchStartTime = null;
  }

  /// Whether auto-capture has fired
  bool get hasCaptured => _hasCaptured;

  /// Whether countdown is active
  bool get isCountingDown => _isCountingDown;

  /// Current countdown value
  int get countdownValue => _countdownSecondsLeft;

  /// Dispose timers
  void dispose() {
    _stabilityTimer?.cancel();
    _countdownTimer?.cancel();
  }
}
