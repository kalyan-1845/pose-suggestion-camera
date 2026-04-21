import 'dart:math';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';

/// Utility functions for pose processing: normalization, angles, distances
class PoseUtils {
  PoseUtils._();

  /// Calculate angle at vertex point (in degrees)
  /// Three points: start → vertex → end
  static double calculateAngle(
    PoseLandmark start,
    PoseLandmark vertex,
    PoseLandmark end,
  ) {
    final double radians = atan2(
          end.y - vertex.y,
          end.x - vertex.x,
        ) -
        atan2(
          start.y - vertex.y,
          start.x - vertex.x,
        );
    double angle = (radians * 180 / pi).abs();
    if (angle > 180) angle = 360 - angle;
    return angle;
  }

  /// Calculate angle from raw coordinates
  static double calculateAngleFromPoints(
    double x1, double y1,
    double x2, double y2,
    double x3, double y3,
  ) {
    final double radians = atan2(y3 - y2, x3 - x2) - atan2(y1 - y2, x1 - x2);
    double angle = (radians * 180 / pi).abs();
    if (angle > 180) angle = 360 - angle;
    return angle;
  }

  /// Euclidean distance between two points
  static double distance(double x1, double y1, double x2, double y2) {
    return sqrt(pow(x2 - x1, 2) + pow(y2 - y1, 2));
  }

  /// Get bounding box of all pose landmarks
  static Map<String, double> getBoundingBox(List<PoseLandmark> landmarks) {
    double minX = double.infinity, minY = double.infinity;
    double maxX = double.negativeInfinity, maxY = double.negativeInfinity;

    for (final lm in landmarks) {
      if (lm.x < minX) minX = lm.x;
      if (lm.y < minY) minY = lm.y;
      if (lm.x > maxX) maxX = lm.x;
      if (lm.y > maxY) maxY = lm.y;
    }

    return {
      'minX': minX,
      'minY': minY,
      'maxX': maxX,
      'maxY': maxY,
      'width': maxX - minX,
      'height': maxY - minY,
    };
  }

  /// Normalize landmarks to 0-1 range relative to body bounding box
  static List<Map<String, double>> normalizeLandmarks(
    List<PoseLandmark> landmarks,
  ) {
    final bbox = getBoundingBox(landmarks);
    final width = bbox['width']!;
    final height = bbox['height']!;

    if (width == 0 || height == 0) {
      return landmarks
          .map((lm) => {'x': 0.0, 'y': 0.0, 'confidence': lm.likelihood})
          .toList();
    }

    return landmarks.map((lm) {
      return {
        'x': (lm.x - bbox['minX']!) / width,
        'y': (lm.y - bbox['minY']!) / height,
        'confidence': lm.likelihood,
      };
    }).toList();
  }

  /// Normalize raw keypoints (List<Map>) to 0-1 range
  static List<Map<String, double>> normalizeRawKeypoints(
    List<Map<String, double>> keypoints,
  ) {
    double minX = double.infinity, minY = double.infinity;
    double maxX = double.negativeInfinity, maxY = double.negativeInfinity;

    for (final kp in keypoints) {
      final x = kp['x']!;
      final y = kp['y']!;
      if (x < minX) minX = x;
      if (y < minY) minY = y;
      if (x > maxX) maxX = x;
      if (y > maxY) maxY = y;
    }

    final width = maxX - minX;
    final height = maxY - minY;

    if (width == 0 || height == 0) {
      return keypoints
          .map((kp) => {'x': 0.0, 'y': 0.0, 'confidence': 1.0})
          .toList();
    }

    return keypoints.map((kp) {
      return {
        'x': (kp['x']! - minX) / width,
        'y': (kp['y']! - minY) / height,
        'confidence': kp['confidence'] ?? 1.0,
      };
    }).toList();
  }

  /// Get center of body (midpoint of shoulders + hips)
  static Map<String, double> getBodyCenter(Pose pose) {
    final leftShoulder = pose.landmarks[PoseLandmarkType.leftShoulder];
    final rightShoulder = pose.landmarks[PoseLandmarkType.rightShoulder];
    final leftHip = pose.landmarks[PoseLandmarkType.leftHip];
    final rightHip = pose.landmarks[PoseLandmarkType.rightHip];

    if (leftShoulder == null ||
        rightShoulder == null ||
        leftHip == null ||
        rightHip == null) {
      return {'x': 0.0, 'y': 0.0};
    }

    return {
      'x': (leftShoulder.x + rightShoulder.x + leftHip.x + rightHip.x) / 4,
      'y': (leftShoulder.y + rightShoulder.y + leftHip.y + rightHip.y) / 4,
    };
  }

  /// Check if a pose has sufficient visibility
  static bool isPoseVisible(Pose pose, {double minConfidence = 0.5}) {
    final keyLandmarks = [
      PoseLandmarkType.leftShoulder,
      PoseLandmarkType.rightShoulder,
      PoseLandmarkType.leftHip,
      PoseLandmarkType.rightHip,
    ];

    for (final type in keyLandmarks) {
      final landmark = pose.landmarks[type];
      if (landmark == null || landmark.likelihood < minConfidence) {
        return false;
      }
    }
    return true;
  }

  /// Get direction instruction based on offset
  static String getDirectionHint(double dx, double dy, double threshold) {
    final hints = <String>[];
    if (dx.abs() > threshold) {
      hints.add(dx > 0 ? 'Move left ←' : 'Move right →');
    }
    if (dy.abs() > threshold) {
      hints.add(dy > 0 ? 'Move up ↑' : 'Move down ↓');
    }
    return hints.isEmpty ? '' : hints.join(' • ');
  }
}
