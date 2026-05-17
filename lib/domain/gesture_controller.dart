import 'dart:math';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';

class GestureController {
  bool _rightActive = false;
  DateTime? _rightStartTime;

  bool _leftActive = false;
  DateTime? _leftStartTime;
  
  static const int _holdDuration = 1000; // in milliseconds

  /// Checks for Right Hand Wave -> triggers Single Capture
  bool checkRightHandWave(Pose pose) {
    final landmarks = pose.landmarks;
    final wrist = landmarks[PoseLandmarkType.rightWrist];
    final indexTip = landmarks[PoseLandmarkType.rightIndex];
    final shoulder = landmarks[PoseLandmarkType.rightShoulder];
    
    if (wrist != null && indexTip != null && shoulder != null) {
      final isHandRaised = wrist.y < shoulder.y;
      final armDist = sqrt(pow(wrist.x - indexTip.x, 2) + pow(wrist.y - indexTip.y, 2));
      final isPalmRaised = isHandRaised && armDist > 20;

      if (isPalmRaised) {
        if (!_rightActive) {
          _rightActive = true;
          _rightStartTime = DateTime.now();
        } else if (_rightStartTime != null && 
                   DateTime.now().difference(_rightStartTime!).inMilliseconds > _holdDuration) {
          _rightActive = false;
          _rightStartTime = null;
          return true;
        }
      } else {
        _rightActive = false;
        _rightStartTime = null;
      }
    }
    return false;
  }

  /// Checks for Left Hand Victory salute -> triggers Photo Booth Collage Capture
  bool checkLeftHandVictory(Pose pose) {
    final landmarks = pose.landmarks;
    final wrist = landmarks[PoseLandmarkType.leftWrist];
    final indexTip = landmarks[PoseLandmarkType.leftIndex];
    final shoulder = landmarks[PoseLandmarkType.leftShoulder];
    
    if (wrist != null && indexTip != null && shoulder != null) {
      final isHandRaised = wrist.y < shoulder.y;
      final armDist = sqrt(pow(wrist.x - indexTip.x, 2) + pow(wrist.y - indexTip.y, 2));
      final isPalmRaised = isHandRaised && armDist > 20;

      if (isPalmRaised) {
        if (!_leftActive) {
          _leftActive = true;
          _leftStartTime = DateTime.now();
        } else if (_leftStartTime != null && 
                   DateTime.now().difference(_leftStartTime!).inMilliseconds > _holdDuration) {
          _leftActive = false;
          _leftStartTime = null;
          return true;
        }
      } else {
        _leftActive = false;
        _leftStartTime = null;
      }
    }
    return false;
  }

  // Backwards compatibility for single gesture check
  bool checkGesture(Pose pose) {
    return checkRightHandWave(pose);
  }
}
