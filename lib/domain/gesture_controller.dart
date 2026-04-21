import 'dart:math';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';

class GestureController {
  bool _gestureActive = false;
  DateTime? _gestureStartTime;
  
  /// Minimum time (in ms) to hold a gesture to trigger it
  static const int _holdDuration = 1000; 

  bool checkGesture(Pose pose) {
    final landmarks = pose.landmarks;
    
    // Check for "Hand Raise" or "Palm" gesture
    // Using Right Hand as standard
    final rightWrist = landmarks[PoseLandmarkType.rightWrist];
    final rightIndex = landmarks[PoseLandmarkType.rightIndex];
    final rightShoulder = landmarks[PoseLandmarkType.rightShoulder];
    
    if (rightWrist != null && rightIndex != null && rightShoulder != null) {
      // 1. Hand is raised above shoulder
      final isHandRaised = rightWrist.y < rightShoulder.y;
      
      // 2. Arm is somewhat extended (using distance from wrist to index tip as proxy)
      final armDist = sqrt(pow(rightWrist.x - rightIndex.x, 2) + pow(rightWrist.y - rightIndex.y, 2));
      final isPalmRaised = isHandRaised && armDist > 20; // Arbitrary threshold for index extension

      if (isPalmRaised) {
        if (!_gestureActive) {
          _gestureActive = true;
          _gestureStartTime = DateTime.now();
        } else if (_gestureStartTime != null && 
                   DateTime.now().difference(_gestureStartTime!).inMilliseconds > _holdDuration) {
          // Trigger!
          _gestureActive = false;
          _gestureStartTime = null;
          return true;
        }
      } else {
        _gestureActive = false;
        _gestureStartTime = null;
      }
    }
    
    return false;
  }
}
