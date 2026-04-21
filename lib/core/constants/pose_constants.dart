import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';

/// Constants for pose detection keypoint indices and skeleton connections
class PoseConstants {
  PoseConstants._();

  // ── Match thresholds ──
  static const double matchThreshold = 75.0;       // Lowered for easier matching
  static const double goodMatchThreshold = 60.0;
  static const int stabilityDurationMs = 1500;     // 1.5 seconds hold
  static const int countdownSeconds = 3;
  static const double minConfidence = 0.5;

  // ── Keypoint weights for matching ──
  // Higher weight = more important for pose matching
  static const Map<PoseLandmarkType, double> keypointWeights = {
    PoseLandmarkType.nose: 0.8,
    PoseLandmarkType.leftShoulder: 1.0,
    PoseLandmarkType.rightShoulder: 1.0,
    PoseLandmarkType.leftElbow: 1.2,
    PoseLandmarkType.rightElbow: 1.2,
    PoseLandmarkType.leftWrist: 1.5,
    PoseLandmarkType.rightWrist: 1.5,
    PoseLandmarkType.leftHip: 0.9,
    PoseLandmarkType.rightHip: 0.9,
    PoseLandmarkType.leftKnee: 1.0,
    PoseLandmarkType.rightKnee: 1.0,
    PoseLandmarkType.leftAnkle: 0.8,
    PoseLandmarkType.rightAnkle: 0.8,
    PoseLandmarkType.leftPinky: 0.3,
    PoseLandmarkType.rightPinky: 0.3,
    PoseLandmarkType.leftIndex: 0.3,
    PoseLandmarkType.rightIndex: 0.3,
    PoseLandmarkType.leftThumb: 0.3,
    PoseLandmarkType.rightThumb: 0.3,
    PoseLandmarkType.leftEar: 0.4,
    PoseLandmarkType.rightEar: 0.4,
    PoseLandmarkType.leftEye: 0.3,
    PoseLandmarkType.rightEye: 0.3,
    PoseLandmarkType.leftEyeInner: 0.2,
    PoseLandmarkType.rightEyeInner: 0.2,
    PoseLandmarkType.leftEyeOuter: 0.2,
    PoseLandmarkType.rightEyeOuter: 0.2,
    PoseLandmarkType.leftMouth: 0.3,
    PoseLandmarkType.rightMouth: 0.3,
    PoseLandmarkType.leftHeel: 0.5,
    PoseLandmarkType.rightHeel: 0.5,
    PoseLandmarkType.leftFootIndex: 0.4,
    PoseLandmarkType.rightFootIndex: 0.4,
  };

  // ── Skeleton connection pairs for drawing ──
  static const List<List<PoseLandmarkType>> skeletonConnections = [
    // Face
    [PoseLandmarkType.leftEar, PoseLandmarkType.leftEye],
    [PoseLandmarkType.rightEar, PoseLandmarkType.rightEye],
    [PoseLandmarkType.leftEye, PoseLandmarkType.nose],
    [PoseLandmarkType.rightEye, PoseLandmarkType.nose],
    [PoseLandmarkType.leftMouth, PoseLandmarkType.rightMouth],
    // Upper body
    [PoseLandmarkType.leftShoulder, PoseLandmarkType.rightShoulder],
    [PoseLandmarkType.leftShoulder, PoseLandmarkType.leftElbow],
    [PoseLandmarkType.rightShoulder, PoseLandmarkType.rightElbow],
    [PoseLandmarkType.leftElbow, PoseLandmarkType.leftWrist],
    [PoseLandmarkType.rightElbow, PoseLandmarkType.rightWrist],
    // Hands
    [PoseLandmarkType.leftWrist, PoseLandmarkType.leftPinky],
    [PoseLandmarkType.leftWrist, PoseLandmarkType.leftIndex],
    [PoseLandmarkType.leftWrist, PoseLandmarkType.leftThumb],
    [PoseLandmarkType.rightWrist, PoseLandmarkType.rightPinky],
    [PoseLandmarkType.rightWrist, PoseLandmarkType.rightIndex],
    [PoseLandmarkType.rightWrist, PoseLandmarkType.rightThumb],
    // Torso
    [PoseLandmarkType.leftShoulder, PoseLandmarkType.leftHip],
    [PoseLandmarkType.rightShoulder, PoseLandmarkType.rightHip],
    [PoseLandmarkType.leftHip, PoseLandmarkType.rightHip],
    // Lower body
    [PoseLandmarkType.leftHip, PoseLandmarkType.leftKnee],
    [PoseLandmarkType.rightHip, PoseLandmarkType.rightKnee],
    [PoseLandmarkType.leftKnee, PoseLandmarkType.leftAnkle],
    [PoseLandmarkType.rightKnee, PoseLandmarkType.rightAnkle],
    // Feet
    [PoseLandmarkType.leftAnkle, PoseLandmarkType.leftHeel],
    [PoseLandmarkType.rightAnkle, PoseLandmarkType.rightHeel],
    [PoseLandmarkType.leftAnkle, PoseLandmarkType.leftFootIndex],
    [PoseLandmarkType.rightAnkle, PoseLandmarkType.rightFootIndex],
  ];

  // ── Key angle definitions for matching ──
  // Each angle is defined by 3 keypoint indices: [start, vertex, end]
  static const Map<String, List<PoseLandmarkType>> keyAngles = {
    'leftElbow': [
      PoseLandmarkType.leftShoulder,
      PoseLandmarkType.leftElbow,
      PoseLandmarkType.leftWrist,
    ],
    'rightElbow': [
      PoseLandmarkType.rightShoulder,
      PoseLandmarkType.rightElbow,
      PoseLandmarkType.rightWrist,
    ],
    'leftShoulder': [
      PoseLandmarkType.leftElbow,
      PoseLandmarkType.leftShoulder,
      PoseLandmarkType.leftHip,
    ],
    'rightShoulder': [
      PoseLandmarkType.rightElbow,
      PoseLandmarkType.rightShoulder,
      PoseLandmarkType.rightHip,
    ],
    'leftHip': [
      PoseLandmarkType.leftShoulder,
      PoseLandmarkType.leftHip,
      PoseLandmarkType.leftKnee,
    ],
    'rightHip': [
      PoseLandmarkType.rightShoulder,
      PoseLandmarkType.rightHip,
      PoseLandmarkType.rightKnee,
    ],
    'leftKnee': [
      PoseLandmarkType.leftHip,
      PoseLandmarkType.leftKnee,
      PoseLandmarkType.leftAnkle,
    ],
    'rightKnee': [
      PoseLandmarkType.rightHip,
      PoseLandmarkType.rightKnee,
      PoseLandmarkType.rightAnkle,
    ],
  };
}
