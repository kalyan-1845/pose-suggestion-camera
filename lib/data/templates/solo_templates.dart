import '../models/pose_template.dart';

/// 15 Solo pose templates with normalized keypoints and key angles
/// Keypoints are normalized 0-1 relative to body bounding box
/// Based on standard MediaPipe 33-keypoint model
class SoloTemplates {
  SoloTemplates._();

  static List<PoseTemplate> get all => [
    _victoryPose,
    _armsWideOpen,
    _thinker,
    _leanBackCool,
    _jumpShot,
    _walkingTowards,
    _overShoulder,
    _sittingCrossLegged,
    _handsInPockets,
    _armsCrossed,
    _yogaTree,
    _danceSpin,
    _leanOnWall,
    _pointAtCamera,
    _silhouette,
    _runwayStrut,
    _actionHero,
    _powerStance,
    _casualLean,
    _theAura,
  ];

  // ── 1. Victory / Peace Sign ──
  static const _victoryPose = PoseTemplate(
    id: 'solo_01',
    name: 'Victory Pose',
    category: 'solo',
    personCount: 1,
    difficulty: 'easy',
    placeTags: ['any'],
    instruction: 'Stand straight, raise one hand making a V sign!',
    emoji: '✌️',
    keypoints: [
      {'x': 0.50, 'y': 0.05}, // nose
      {'x': 0.47, 'y': 0.03}, // left eye inner
      {'x': 0.46, 'y': 0.03}, // left eye
      {'x': 0.45, 'y': 0.03}, // left eye outer
      {'x': 0.53, 'y': 0.03}, // right eye inner
      {'x': 0.54, 'y': 0.03}, // right eye
      {'x': 0.55, 'y': 0.03}, // right eye outer
      {'x': 0.43, 'y': 0.05}, // left ear
      {'x': 0.57, 'y': 0.05}, // right ear
      {'x': 0.48, 'y': 0.07}, // left mouth
      {'x': 0.52, 'y': 0.07}, // right mouth
      {'x': 0.35, 'y': 0.20}, // left shoulder
      {'x': 0.65, 'y': 0.20}, // right shoulder
      {'x': 0.28, 'y': 0.35}, // left elbow
      {'x': 0.72, 'y': 0.12}, // right elbow (raised)
      {'x': 0.25, 'y': 0.50}, // left wrist
      {'x': 0.75, 'y': 0.00}, // right wrist (raised high)
      {'x': 0.24, 'y': 0.52}, // left pinky
      {'x': 0.76, 'y': 0.00}, // right pinky
      {'x': 0.25, 'y': 0.51}, // left index
      {'x': 0.74, 'y': 0.00}, // right index
      {'x': 0.26, 'y': 0.50}, // left thumb
      {'x': 0.73, 'y': 0.02}, // right thumb
      {'x': 0.40, 'y': 0.52}, // left hip
      {'x': 0.60, 'y': 0.52}, // right hip
      {'x': 0.40, 'y': 0.73}, // left knee
      {'x': 0.60, 'y': 0.73}, // right knee
      {'x': 0.40, 'y': 0.95}, // left ankle
      {'x': 0.60, 'y': 0.95}, // right ankle
      {'x': 0.38, 'y': 0.97}, // left heel
      {'x': 0.58, 'y': 0.97}, // right heel
      {'x': 0.42, 'y': 1.00}, // left foot index
      {'x': 0.62, 'y': 1.00}, // right foot index
    ],
    keyAngles: {
      'leftElbow': 160.0,
      'rightElbow': 150.0,
      'leftShoulder': 15.0,
      'rightShoulder': 170.0,
      'leftHip': 175.0,
      'rightHip': 175.0,
      'leftKnee': 178.0,
      'rightKnee': 178.0,
    },
  );

  // ── 2. Arms Wide Open ──
  static const _armsWideOpen = PoseTemplate(
    id: 'solo_02',
    name: 'Arms Wide Open',
    category: 'solo',
    personCount: 1,
    difficulty: 'easy',
    placeTags: ['beach', 'mountain', 'park', 'sunset'],
    instruction: 'Spread both arms wide like you\'re embracing the world!',
    emoji: '🤗',
    keypoints: [
      {'x': 0.50, 'y': 0.05},
      {'x': 0.47, 'y': 0.03}, {'x': 0.46, 'y': 0.03}, {'x': 0.45, 'y': 0.03},
      {'x': 0.53, 'y': 0.03}, {'x': 0.54, 'y': 0.03}, {'x': 0.55, 'y': 0.03},
      {'x': 0.43, 'y': 0.05}, {'x': 0.57, 'y': 0.05},
      {'x': 0.48, 'y': 0.07}, {'x': 0.52, 'y': 0.07},
      {'x': 0.35, 'y': 0.22}, {'x': 0.65, 'y': 0.22},
      {'x': 0.15, 'y': 0.22}, {'x': 0.85, 'y': 0.22}, // elbows wide
      {'x': 0.00, 'y': 0.22}, {'x': 1.00, 'y': 0.22}, // wrists wide
      {'x': 0.00, 'y': 0.23}, {'x': 1.00, 'y': 0.23},
      {'x': 0.00, 'y': 0.21}, {'x': 1.00, 'y': 0.21},
      {'x': 0.02, 'y': 0.22}, {'x': 0.98, 'y': 0.22},
      {'x': 0.40, 'y': 0.52}, {'x': 0.60, 'y': 0.52},
      {'x': 0.40, 'y': 0.73}, {'x': 0.60, 'y': 0.73},
      {'x': 0.40, 'y': 0.95}, {'x': 0.60, 'y': 0.95},
      {'x': 0.38, 'y': 0.97}, {'x': 0.58, 'y': 0.97},
      {'x': 0.42, 'y': 1.00}, {'x': 0.62, 'y': 1.00},
    ],
    keyAngles: {
      'leftElbow': 175.0, 'rightElbow': 175.0,
      'leftShoulder': 90.0, 'rightShoulder': 90.0,
      'leftHip': 175.0, 'rightHip': 175.0,
      'leftKnee': 178.0, 'rightKnee': 178.0,
    },
  );

  // ── 3. The Thinker ──
  static const _thinker = PoseTemplate(
    id: 'solo_03',
    name: 'The Thinker',
    category: 'solo',
    personCount: 1,
    difficulty: 'easy',
    placeTags: ['indoor', 'urban', 'cafe'],
    instruction: 'Rest your chin on your hand, look thoughtful!',
    emoji: '🤔',
    keypoints: [
      {'x': 0.50, 'y': 0.05},
      {'x': 0.47, 'y': 0.03}, {'x': 0.46, 'y': 0.03}, {'x': 0.45, 'y': 0.03},
      {'x': 0.53, 'y': 0.03}, {'x': 0.54, 'y': 0.03}, {'x': 0.55, 'y': 0.03},
      {'x': 0.43, 'y': 0.05}, {'x': 0.57, 'y': 0.05},
      {'x': 0.48, 'y': 0.07}, {'x': 0.52, 'y': 0.07},
      {'x': 0.35, 'y': 0.22}, {'x': 0.65, 'y': 0.22},
      {'x': 0.40, 'y': 0.35}, {'x': 0.58, 'y': 0.12}, // right elbow up
      {'x': 0.35, 'y': 0.50}, {'x': 0.52, 'y': 0.06}, // right wrist at chin
      {'x': 0.34, 'y': 0.52}, {'x': 0.53, 'y': 0.05},
      {'x': 0.36, 'y': 0.51}, {'x': 0.51, 'y': 0.06},
      {'x': 0.37, 'y': 0.50}, {'x': 0.52, 'y': 0.07},
      {'x': 0.40, 'y': 0.52}, {'x': 0.60, 'y': 0.52},
      {'x': 0.40, 'y': 0.73}, {'x': 0.60, 'y': 0.73},
      {'x': 0.40, 'y': 0.95}, {'x': 0.60, 'y': 0.95},
      {'x': 0.38, 'y': 0.97}, {'x': 0.58, 'y': 0.97},
      {'x': 0.42, 'y': 1.00}, {'x': 0.62, 'y': 1.00},
    ],
    keyAngles: {
      'leftElbow': 140.0, 'rightElbow': 45.0,
      'leftShoulder': 20.0, 'rightShoulder': 130.0,
      'leftHip': 175.0, 'rightHip': 175.0,
      'leftKnee': 178.0, 'rightKnee': 178.0,
    },
  );

  // ── 4. Lean Back Cool ──
  static const _leanBackCool = PoseTemplate(
    id: 'solo_04',
    name: 'Lean Back Cool',
    category: 'solo',
    personCount: 1,
    difficulty: 'easy',
    placeTags: ['urban', 'indoor'],
    instruction: 'Lean back slightly with a confident stance!',
    emoji: '😎',
    keypoints: [
      {'x': 0.52, 'y': 0.06},
      {'x': 0.49, 'y': 0.04}, {'x': 0.48, 'y': 0.04}, {'x': 0.47, 'y': 0.04},
      {'x': 0.55, 'y': 0.04}, {'x': 0.56, 'y': 0.04}, {'x': 0.57, 'y': 0.04},
      {'x': 0.45, 'y': 0.06}, {'x': 0.59, 'y': 0.06},
      {'x': 0.50, 'y': 0.08}, {'x': 0.54, 'y': 0.08},
      {'x': 0.38, 'y': 0.23}, {'x': 0.68, 'y': 0.23},
      {'x': 0.32, 'y': 0.38}, {'x': 0.62, 'y': 0.38},
      {'x': 0.35, 'y': 0.50}, {'x': 0.58, 'y': 0.50},
      {'x': 0.34, 'y': 0.52}, {'x': 0.57, 'y': 0.52},
      {'x': 0.36, 'y': 0.51}, {'x': 0.59, 'y': 0.51},
      {'x': 0.37, 'y': 0.50}, {'x': 0.56, 'y': 0.50},
      {'x': 0.42, 'y': 0.52}, {'x': 0.62, 'y': 0.52},
      {'x': 0.38, 'y': 0.73}, {'x': 0.58, 'y': 0.73},
      {'x': 0.36, 'y': 0.95}, {'x': 0.56, 'y': 0.95},
      {'x': 0.34, 'y': 0.97}, {'x': 0.54, 'y': 0.97},
      {'x': 0.38, 'y': 1.00}, {'x': 0.58, 'y': 1.00},
    ],
    keyAngles: {
      'leftElbow': 150.0, 'rightElbow': 150.0,
      'leftShoulder': 25.0, 'rightShoulder': 25.0,
      'leftHip': 165.0, 'rightHip': 165.0,
      'leftKnee': 175.0, 'rightKnee': 175.0,
    },
  );

  // ── 5. Jump Shot ──
  static const _jumpShot = PoseTemplate(
    id: 'solo_05',
    name: 'Jump Shot',
    category: 'solo',
    personCount: 1,
    difficulty: 'medium',
    placeTags: ['beach', 'park', 'any'],
    instruction: 'Jump up with arms raised high! Time the shot!',
    emoji: '🦘',
    keypoints: [
      {'x': 0.50, 'y': 0.05},
      {'x': 0.47, 'y': 0.03}, {'x': 0.46, 'y': 0.03}, {'x': 0.45, 'y': 0.03},
      {'x': 0.53, 'y': 0.03}, {'x': 0.54, 'y': 0.03}, {'x': 0.55, 'y': 0.03},
      {'x': 0.43, 'y': 0.05}, {'x': 0.57, 'y': 0.05},
      {'x': 0.48, 'y': 0.07}, {'x': 0.52, 'y': 0.07},
      {'x': 0.35, 'y': 0.20}, {'x': 0.65, 'y': 0.20},
      {'x': 0.25, 'y': 0.08}, {'x': 0.75, 'y': 0.08},
      {'x': 0.20, 'y': 0.00}, {'x': 0.80, 'y': 0.00},
      {'x': 0.19, 'y': 0.00}, {'x': 0.81, 'y': 0.00},
      {'x': 0.21, 'y': 0.00}, {'x': 0.79, 'y': 0.00},
      {'x': 0.22, 'y': 0.01}, {'x': 0.78, 'y': 0.01},
      {'x': 0.40, 'y': 0.50}, {'x': 0.60, 'y': 0.50},
      {'x': 0.35, 'y': 0.68}, {'x': 0.65, 'y': 0.68},
      {'x': 0.38, 'y': 0.85}, {'x': 0.62, 'y': 0.85},
      {'x': 0.36, 'y': 0.87}, {'x': 0.60, 'y': 0.87},
      {'x': 0.40, 'y': 0.90}, {'x': 0.64, 'y': 0.90},
    ],
    keyAngles: {
      'leftElbow': 160.0, 'rightElbow': 160.0,
      'leftShoulder': 170.0, 'rightShoulder': 170.0,
      'leftHip': 165.0, 'rightHip': 165.0,
      'leftKnee': 155.0, 'rightKnee': 155.0,
    },
  );

  // ── 6. Walking Towards Camera ──
  static const _walkingTowards = PoseTemplate(
    id: 'solo_06',
    name: 'Walking Towards',
    category: 'solo',
    personCount: 1,
    difficulty: 'medium',
    placeTags: ['urban', 'park', 'beach'],
    instruction: 'Walk confidently towards the camera, mid-stride!',
    emoji: '🚶',
    keypoints: [
      {'x': 0.50, 'y': 0.05},
      {'x': 0.47, 'y': 0.03}, {'x': 0.46, 'y': 0.03}, {'x': 0.45, 'y': 0.03},
      {'x': 0.53, 'y': 0.03}, {'x': 0.54, 'y': 0.03}, {'x': 0.55, 'y': 0.03},
      {'x': 0.43, 'y': 0.05}, {'x': 0.57, 'y': 0.05},
      {'x': 0.48, 'y': 0.07}, {'x': 0.52, 'y': 0.07},
      {'x': 0.37, 'y': 0.22}, {'x': 0.63, 'y': 0.22},
      {'x': 0.42, 'y': 0.36}, {'x': 0.55, 'y': 0.36},
      {'x': 0.45, 'y': 0.48}, {'x': 0.52, 'y': 0.48},
      {'x': 0.44, 'y': 0.50}, {'x': 0.51, 'y': 0.50},
      {'x': 0.46, 'y': 0.49}, {'x': 0.53, 'y': 0.49},
      {'x': 0.47, 'y': 0.48}, {'x': 0.50, 'y': 0.48},
      {'x': 0.42, 'y': 0.52}, {'x': 0.58, 'y': 0.52},
      {'x': 0.35, 'y': 0.72}, {'x': 0.62, 'y': 0.72},
      {'x': 0.42, 'y': 0.92}, {'x': 0.55, 'y': 0.92},
      {'x': 0.40, 'y': 0.95}, {'x': 0.53, 'y': 0.95},
      {'x': 0.44, 'y': 0.97}, {'x': 0.57, 'y': 0.97},
    ],
    keyAngles: {
      'leftElbow': 140.0, 'rightElbow': 140.0,
      'leftShoulder': 20.0, 'rightShoulder': 20.0,
      'leftHip': 155.0, 'rightHip': 165.0,
      'leftKnee': 165.0, 'rightKnee': 170.0,
    },
  );

  // ── 7. Over-the-Shoulder Look ──
  static const _overShoulder = PoseTemplate(
    id: 'solo_07',
    name: 'Over Shoulder Look',
    category: 'solo',
    personCount: 1,
    difficulty: 'easy',
    placeTags: ['urban', 'indoor', 'mountain'],
    instruction: 'Turn your back slightly and look over your shoulder!',
    emoji: '💫',
    keypoints: [
      {'x': 0.55, 'y': 0.06},
      {'x': 0.52, 'y': 0.04}, {'x': 0.53, 'y': 0.04}, {'x': 0.54, 'y': 0.04},
      {'x': 0.57, 'y': 0.04}, {'x': 0.58, 'y': 0.04}, {'x': 0.59, 'y': 0.04},
      {'x': 0.50, 'y': 0.06}, {'x': 0.62, 'y': 0.06},
      {'x': 0.54, 'y': 0.08}, {'x': 0.57, 'y': 0.08},
      {'x': 0.40, 'y': 0.22}, {'x': 0.65, 'y': 0.22},
      {'x': 0.35, 'y': 0.38}, {'x': 0.60, 'y': 0.38},
      {'x': 0.33, 'y': 0.50}, {'x': 0.55, 'y': 0.50},
      {'x': 0.32, 'y': 0.52}, {'x': 0.54, 'y': 0.52},
      {'x': 0.34, 'y': 0.51}, {'x': 0.56, 'y': 0.51},
      {'x': 0.35, 'y': 0.50}, {'x': 0.53, 'y': 0.50},
      {'x': 0.43, 'y': 0.52}, {'x': 0.60, 'y': 0.52},
      {'x': 0.42, 'y': 0.73}, {'x': 0.58, 'y': 0.73},
      {'x': 0.42, 'y': 0.95}, {'x': 0.58, 'y': 0.95},
      {'x': 0.40, 'y': 0.97}, {'x': 0.56, 'y': 0.97},
      {'x': 0.44, 'y': 1.00}, {'x': 0.60, 'y': 1.00},
    ],
    keyAngles: {
      'leftElbow': 155.0, 'rightElbow': 155.0,
      'leftShoulder': 20.0, 'rightShoulder': 20.0,
      'leftHip': 175.0, 'rightHip': 175.0,
      'leftKnee': 178.0, 'rightKnee': 178.0,
    },
  );

  // ── 8. Sitting Cross-Legged ──
  static const _sittingCrossLegged = PoseTemplate(
    id: 'solo_08',
    name: 'Sitting Cross-Legged',
    category: 'solo',
    personCount: 1,
    difficulty: 'easy',
    placeTags: ['park', 'indoor', 'cafe'],
    instruction: 'Sit down cross-legged, hands on knees, look relaxed!',
    emoji: '🧘',
    keypoints: [
      {'x': 0.50, 'y': 0.10},
      {'x': 0.47, 'y': 0.08}, {'x': 0.46, 'y': 0.08}, {'x': 0.45, 'y': 0.08},
      {'x': 0.53, 'y': 0.08}, {'x': 0.54, 'y': 0.08}, {'x': 0.55, 'y': 0.08},
      {'x': 0.43, 'y': 0.10}, {'x': 0.57, 'y': 0.10},
      {'x': 0.48, 'y': 0.12}, {'x': 0.52, 'y': 0.12},
      {'x': 0.35, 'y': 0.28}, {'x': 0.65, 'y': 0.28},
      {'x': 0.30, 'y': 0.42}, {'x': 0.70, 'y': 0.42},
      {'x': 0.35, 'y': 0.55}, {'x': 0.65, 'y': 0.55},
      {'x': 0.34, 'y': 0.57}, {'x': 0.66, 'y': 0.57},
      {'x': 0.36, 'y': 0.56}, {'x': 0.64, 'y': 0.56},
      {'x': 0.37, 'y': 0.55}, {'x': 0.63, 'y': 0.55},
      {'x': 0.42, 'y': 0.58}, {'x': 0.58, 'y': 0.58},
      {'x': 0.55, 'y': 0.72}, {'x': 0.45, 'y': 0.72},
      {'x': 0.35, 'y': 0.80}, {'x': 0.65, 'y': 0.80},
      {'x': 0.33, 'y': 0.82}, {'x': 0.67, 'y': 0.82},
      {'x': 0.37, 'y': 0.85}, {'x': 0.63, 'y': 0.85},
    ],
    keyAngles: {
      'leftElbow': 130.0, 'rightElbow': 130.0,
      'leftShoulder': 30.0, 'rightShoulder': 30.0,
      'leftHip': 90.0, 'rightHip': 90.0,
      'leftKnee': 45.0, 'rightKnee': 45.0,
    },
  );

  // ── 9. Hands in Pockets ──
  static const _handsInPockets = PoseTemplate(
    id: 'solo_09',
    name: 'Hands in Pockets',
    category: 'solo',
    personCount: 1,
    difficulty: 'easy',
    placeTags: ['urban', 'indoor', 'any'],
    instruction: 'Stand straight with hands in pockets, casual & cool!',
    emoji: '🧍',
    keypoints: [
      {'x': 0.50, 'y': 0.05},
      {'x': 0.47, 'y': 0.03}, {'x': 0.46, 'y': 0.03}, {'x': 0.45, 'y': 0.03},
      {'x': 0.53, 'y': 0.03}, {'x': 0.54, 'y': 0.03}, {'x': 0.55, 'y': 0.03},
      {'x': 0.43, 'y': 0.05}, {'x': 0.57, 'y': 0.05},
      {'x': 0.48, 'y': 0.07}, {'x': 0.52, 'y': 0.07},
      {'x': 0.37, 'y': 0.22}, {'x': 0.63, 'y': 0.22},
      {'x': 0.35, 'y': 0.38}, {'x': 0.65, 'y': 0.38},
      {'x': 0.38, 'y': 0.50}, {'x': 0.62, 'y': 0.50}, // wrists at hip level
      {'x': 0.37, 'y': 0.52}, {'x': 0.63, 'y': 0.52},
      {'x': 0.39, 'y': 0.51}, {'x': 0.61, 'y': 0.51},
      {'x': 0.40, 'y': 0.50}, {'x': 0.60, 'y': 0.50},
      {'x': 0.40, 'y': 0.52}, {'x': 0.60, 'y': 0.52},
      {'x': 0.40, 'y': 0.73}, {'x': 0.60, 'y': 0.73},
      {'x': 0.40, 'y': 0.95}, {'x': 0.60, 'y': 0.95},
      {'x': 0.38, 'y': 0.97}, {'x': 0.58, 'y': 0.97},
      {'x': 0.42, 'y': 1.00}, {'x': 0.62, 'y': 1.00},
    ],
    keyAngles: {
      'leftElbow': 90.0, 'rightElbow': 90.0,
      'leftShoulder': 15.0, 'rightShoulder': 15.0,
      'leftHip': 175.0, 'rightHip': 175.0,
      'leftKnee': 178.0, 'rightKnee': 178.0,
    },
  );

  // ── 10. Arms Crossed Confident ──
  static const _armsCrossed = PoseTemplate(
    id: 'solo_10',
    name: 'Arms Crossed',
    category: 'solo',
    personCount: 1,
    difficulty: 'easy',
    placeTags: ['indoor', 'urban', 'any'],
    instruction: 'Cross your arms over your chest, stand confidently!',
    emoji: '💪',
    keypoints: [
      {'x': 0.50, 'y': 0.05},
      {'x': 0.47, 'y': 0.03}, {'x': 0.46, 'y': 0.03}, {'x': 0.45, 'y': 0.03},
      {'x': 0.53, 'y': 0.03}, {'x': 0.54, 'y': 0.03}, {'x': 0.55, 'y': 0.03},
      {'x': 0.43, 'y': 0.05}, {'x': 0.57, 'y': 0.05},
      {'x': 0.48, 'y': 0.07}, {'x': 0.52, 'y': 0.07},
      {'x': 0.37, 'y': 0.22}, {'x': 0.63, 'y': 0.22},
      {'x': 0.55, 'y': 0.32}, {'x': 0.45, 'y': 0.32}, // elbows crossed
      {'x': 0.62, 'y': 0.30}, {'x': 0.38, 'y': 0.30}, // wrists crossed
      {'x': 0.63, 'y': 0.31}, {'x': 0.37, 'y': 0.31},
      {'x': 0.61, 'y': 0.29}, {'x': 0.39, 'y': 0.29},
      {'x': 0.60, 'y': 0.30}, {'x': 0.40, 'y': 0.30},
      {'x': 0.40, 'y': 0.52}, {'x': 0.60, 'y': 0.52},
      {'x': 0.40, 'y': 0.73}, {'x': 0.60, 'y': 0.73},
      {'x': 0.40, 'y': 0.95}, {'x': 0.60, 'y': 0.95},
      {'x': 0.38, 'y': 0.97}, {'x': 0.58, 'y': 0.97},
      {'x': 0.42, 'y': 1.00}, {'x': 0.62, 'y': 1.00},
    ],
    keyAngles: {
      'leftElbow': 50.0, 'rightElbow': 50.0,
      'leftShoulder': 45.0, 'rightShoulder': 45.0,
      'leftHip': 175.0, 'rightHip': 175.0,
      'leftKnee': 178.0, 'rightKnee': 178.0,
    },
  );

  // ── 11. Yoga Tree Pose ──
  static const _yogaTree = PoseTemplate(
    id: 'solo_11',
    name: 'Yoga Tree Pose',
    category: 'solo',
    personCount: 1,
    difficulty: 'medium',
    placeTags: ['park', 'beach', 'mountain'],
    instruction: 'Stand on one leg, other foot on inner thigh, palms together above!',
    emoji: '🌳',
    keypoints: [
      {'x': 0.50, 'y': 0.05},
      {'x': 0.47, 'y': 0.03}, {'x': 0.46, 'y': 0.03}, {'x': 0.45, 'y': 0.03},
      {'x': 0.53, 'y': 0.03}, {'x': 0.54, 'y': 0.03}, {'x': 0.55, 'y': 0.03},
      {'x': 0.43, 'y': 0.05}, {'x': 0.57, 'y': 0.05},
      {'x': 0.48, 'y': 0.07}, {'x': 0.52, 'y': 0.07},
      {'x': 0.38, 'y': 0.22}, {'x': 0.62, 'y': 0.22},
      {'x': 0.43, 'y': 0.08}, {'x': 0.57, 'y': 0.08}, // elbows up
      {'x': 0.48, 'y': 0.00}, {'x': 0.52, 'y': 0.00}, // wrists above head together
      {'x': 0.47, 'y': 0.00}, {'x': 0.53, 'y': 0.00},
      {'x': 0.49, 'y': 0.00}, {'x': 0.51, 'y': 0.00},
      {'x': 0.50, 'y': 0.01}, {'x': 0.50, 'y': 0.01},
      {'x': 0.42, 'y': 0.52}, {'x': 0.58, 'y': 0.52},
      {'x': 0.42, 'y': 0.73}, {'x': 0.50, 'y': 0.62}, // right knee bent
      {'x': 0.42, 'y': 0.95}, {'x': 0.48, 'y': 0.70}, // right foot on thigh
      {'x': 0.40, 'y': 0.97}, {'x': 0.47, 'y': 0.72},
      {'x': 0.44, 'y': 1.00}, {'x': 0.49, 'y': 0.68},
    ],
    keyAngles: {
      'leftElbow': 160.0, 'rightElbow': 160.0,
      'leftShoulder': 170.0, 'rightShoulder': 170.0,
      'leftHip': 175.0, 'rightHip': 100.0,
      'leftKnee': 178.0, 'rightKnee': 35.0,
    },
  );

  // ── 12. Dance Spin ──
  static const _danceSpin = PoseTemplate(
    id: 'solo_12',
    name: 'Dance Spin',
    category: 'solo',
    personCount: 1,
    difficulty: 'hard',
    placeTags: ['beach', 'park', 'indoor'],
    instruction: 'One arm up, one to the side, slight spin pose!',
    emoji: '💃',
    keypoints: [
      {'x': 0.48, 'y': 0.06},
      {'x': 0.45, 'y': 0.04}, {'x': 0.44, 'y': 0.04}, {'x': 0.43, 'y': 0.04},
      {'x': 0.51, 'y': 0.04}, {'x': 0.52, 'y': 0.04}, {'x': 0.53, 'y': 0.04},
      {'x': 0.41, 'y': 0.06}, {'x': 0.55, 'y': 0.06},
      {'x': 0.46, 'y': 0.08}, {'x': 0.50, 'y': 0.08},
      {'x': 0.35, 'y': 0.22}, {'x': 0.62, 'y': 0.22},
      {'x': 0.18, 'y': 0.22}, {'x': 0.65, 'y': 0.08}, // one wide, one up
      {'x': 0.05, 'y': 0.22}, {'x': 0.60, 'y': 0.00},
      {'x': 0.04, 'y': 0.23}, {'x': 0.59, 'y': 0.00},
      {'x': 0.06, 'y': 0.21}, {'x': 0.61, 'y': 0.00},
      {'x': 0.07, 'y': 0.22}, {'x': 0.58, 'y': 0.02},
      {'x': 0.40, 'y': 0.52}, {'x': 0.58, 'y': 0.52},
      {'x': 0.38, 'y': 0.72}, {'x': 0.60, 'y': 0.68},
      {'x': 0.40, 'y': 0.90}, {'x': 0.55, 'y': 0.88},
      {'x': 0.38, 'y': 0.92}, {'x': 0.53, 'y': 0.90},
      {'x': 0.42, 'y': 0.95}, {'x': 0.57, 'y': 0.93},
    ],
    keyAngles: {
      'leftElbow': 170.0, 'rightElbow': 155.0,
      'leftShoulder': 90.0, 'rightShoulder': 160.0,
      'leftHip': 170.0, 'rightHip': 160.0,
      'leftKnee': 175.0, 'rightKnee': 165.0,
    },
  );

  // ── 13. Lean on Wall ──
  static const _leanOnWall = PoseTemplate(
    id: 'solo_13',
    name: 'Lean on Wall',
    category: 'solo',
    personCount: 1,
    difficulty: 'easy',
    placeTags: ['urban', 'indoor'],
    instruction: 'Lean your shoulder against a wall, cross one leg!',
    emoji: '🧱',
    keypoints: [
      {'x': 0.45, 'y': 0.06},
      {'x': 0.42, 'y': 0.04}, {'x': 0.41, 'y': 0.04}, {'x': 0.40, 'y': 0.04},
      {'x': 0.48, 'y': 0.04}, {'x': 0.49, 'y': 0.04}, {'x': 0.50, 'y': 0.04},
      {'x': 0.38, 'y': 0.06}, {'x': 0.52, 'y': 0.06},
      {'x': 0.43, 'y': 0.08}, {'x': 0.47, 'y': 0.08},
      {'x': 0.32, 'y': 0.23}, {'x': 0.60, 'y': 0.23},
      {'x': 0.30, 'y': 0.38}, {'x': 0.55, 'y': 0.38},
      {'x': 0.33, 'y': 0.50}, {'x': 0.52, 'y': 0.50},
      {'x': 0.32, 'y': 0.52}, {'x': 0.51, 'y': 0.52},
      {'x': 0.34, 'y': 0.51}, {'x': 0.53, 'y': 0.51},
      {'x': 0.35, 'y': 0.50}, {'x': 0.50, 'y': 0.50},
      {'x': 0.38, 'y': 0.53}, {'x': 0.55, 'y': 0.53},
      {'x': 0.38, 'y': 0.73}, {'x': 0.52, 'y': 0.70},
      {'x': 0.38, 'y': 0.95}, {'x': 0.45, 'y': 0.90},
      {'x': 0.36, 'y': 0.97}, {'x': 0.43, 'y': 0.92},
      {'x': 0.40, 'y': 1.00}, {'x': 0.47, 'y': 0.95},
    ],
    keyAngles: {
      'leftElbow': 150.0, 'rightElbow': 150.0,
      'leftShoulder': 20.0, 'rightShoulder': 20.0,
      'leftHip': 170.0, 'rightHip': 155.0,
      'leftKnee': 178.0, 'rightKnee': 150.0,
    },
  );

  // ── 14. Point at Camera ──
  static const _pointAtCamera = PoseTemplate(
    id: 'solo_14',
    name: 'Point at Camera',
    category: 'solo',
    personCount: 1,
    difficulty: 'easy',
    placeTags: ['any'],
    instruction: 'Point directly at the camera with confidence!',
    emoji: '👉',
    keypoints: [
      {'x': 0.50, 'y': 0.05},
      {'x': 0.47, 'y': 0.03}, {'x': 0.46, 'y': 0.03}, {'x': 0.45, 'y': 0.03},
      {'x': 0.53, 'y': 0.03}, {'x': 0.54, 'y': 0.03}, {'x': 0.55, 'y': 0.03},
      {'x': 0.43, 'y': 0.05}, {'x': 0.57, 'y': 0.05},
      {'x': 0.48, 'y': 0.07}, {'x': 0.52, 'y': 0.07},
      {'x': 0.37, 'y': 0.22}, {'x': 0.63, 'y': 0.22},
      {'x': 0.35, 'y': 0.38}, {'x': 0.70, 'y': 0.22}, // right arm forward
      {'x': 0.33, 'y': 0.50}, {'x': 0.80, 'y': 0.22}, // right wrist forward
      {'x': 0.32, 'y': 0.52}, {'x': 0.82, 'y': 0.22},
      {'x': 0.34, 'y': 0.51}, {'x': 0.83, 'y': 0.22},
      {'x': 0.35, 'y': 0.50}, {'x': 0.78, 'y': 0.23},
      {'x': 0.40, 'y': 0.52}, {'x': 0.60, 'y': 0.52},
      {'x': 0.40, 'y': 0.73}, {'x': 0.60, 'y': 0.73},
      {'x': 0.40, 'y': 0.95}, {'x': 0.60, 'y': 0.95},
      {'x': 0.38, 'y': 0.97}, {'x': 0.58, 'y': 0.97},
      {'x': 0.42, 'y': 1.00}, {'x': 0.62, 'y': 1.00},
    ],
    keyAngles: {
      'leftElbow': 155.0, 'rightElbow': 170.0,
      'leftShoulder': 20.0, 'rightShoulder': 85.0,
      'leftHip': 175.0, 'rightHip': 175.0,
      'leftKnee': 178.0, 'rightKnee': 178.0,
    },
  );

  // ── 15. Silhouette Pose ──
  static const _silhouette = PoseTemplate(
    id: 'solo_15',
    name: 'Silhouette Pose',
    category: 'solo',
    personCount: 1,
    difficulty: 'medium',
    placeTags: ['sunset', 'beach', 'mountain'],
    instruction: 'Side profile with one arm reaching up to the sky!',
    emoji: '🌅',
    keypoints: [
      {'x': 0.50, 'y': 0.06},
      {'x': 0.47, 'y': 0.04}, {'x': 0.46, 'y': 0.04}, {'x': 0.45, 'y': 0.04},
      {'x': 0.53, 'y': 0.04}, {'x': 0.54, 'y': 0.04}, {'x': 0.55, 'y': 0.04},
      {'x': 0.43, 'y': 0.06}, {'x': 0.57, 'y': 0.06},
      {'x': 0.48, 'y': 0.08}, {'x': 0.52, 'y': 0.08},
      {'x': 0.40, 'y': 0.22}, {'x': 0.60, 'y': 0.22},
      {'x': 0.35, 'y': 0.38}, {'x': 0.55, 'y': 0.05}, // right arm up
      {'x': 0.33, 'y': 0.50}, {'x': 0.52, 'y': 0.00}, // right wrist skyward
      {'x': 0.32, 'y': 0.52}, {'x': 0.51, 'y': 0.00},
      {'x': 0.34, 'y': 0.51}, {'x': 0.53, 'y': 0.00},
      {'x': 0.35, 'y': 0.50}, {'x': 0.50, 'y': 0.02},
      {'x': 0.42, 'y': 0.52}, {'x': 0.58, 'y': 0.52},
      {'x': 0.42, 'y': 0.73}, {'x': 0.58, 'y': 0.73},
      {'x': 0.42, 'y': 0.95}, {'x': 0.58, 'y': 0.95},
      {'x': 0.40, 'y': 0.97}, {'x': 0.56, 'y': 0.97},
      {'x': 0.44, 'y': 1.00}, {'x': 0.60, 'y': 1.00},
    ],
    keyAngles: {
      'leftElbow': 155.0, 'rightElbow': 165.0,
      'leftShoulder': 20.0, 'rightShoulder': 175.0,
      'leftHip': 175.0, 'rightHip': 175.0,
      'leftKnee': 178.0, 'rightKnee': 178.0,
    },
  );

  // ── 16. Runway Strut ──
  static const _runwayStrut = PoseTemplate(
    id: 'solo_16',
    name: 'Runway Strut',
    category: 'solo',
    personCount: 1,
    difficulty: 'medium',
    placeTags: ['urban', 'indoor', 'any'],
    instruction: 'Walk powerfully. One hand strictly on hip, high fashion style!',
    emoji: '💋',
    keypoints: [
      {'x': 0.50, 'y': 0.05},
      {'x': 0.47, 'y': 0.03}, {'x': 0.46, 'y': 0.03}, {'x': 0.45, 'y': 0.03},
      {'x': 0.53, 'y': 0.03}, {'x': 0.54, 'y': 0.03}, {'x': 0.55, 'y': 0.03},
      {'x': 0.43, 'y': 0.05}, {'x': 0.57, 'y': 0.05},
      {'x': 0.48, 'y': 0.07}, {'x': 0.52, 'y': 0.07},
      {'x': 0.37, 'y': 0.22}, {'x': 0.63, 'y': 0.22},
      {'x': 0.42, 'y': 0.36}, {'x': 0.75, 'y': 0.36}, // Right elbow way out
      {'x': 0.45, 'y': 0.48}, {'x': 0.65, 'y': 0.52}, // Right wrist on hip
      {'x': 0.44, 'y': 0.50}, {'x': 0.64, 'y': 0.54},
      {'x': 0.46, 'y': 0.49}, {'x': 0.66, 'y': 0.53},
      {'x': 0.47, 'y': 0.48}, {'x': 0.67, 'y': 0.52},
      {'x': 0.42, 'y': 0.52}, {'x': 0.58, 'y': 0.52},
      {'x': 0.35, 'y': 0.72}, {'x': 0.62, 'y': 0.72},
      {'x': 0.42, 'y': 0.92}, {'x': 0.55, 'y': 0.92},
      {'x': 0.40, 'y': 0.95}, {'x': 0.53, 'y': 0.95},
      {'x': 0.44, 'y': 0.97}, {'x': 0.57, 'y': 0.97},
    ],
    keyAngles: {
      'leftElbow': 140.0, 'rightElbow': 70.0,
      'leftShoulder': 20.0, 'rightShoulder': 40.0,
      'leftHip': 155.0, 'rightHip': 165.0,
    },
  );

  // ── 17. Action Hero Landing ──
  static const _actionHero = PoseTemplate(
    id: 'solo_17',
    name: 'Action Hero',
    category: 'solo',
    personCount: 1,
    difficulty: 'hard',
    placeTags: ['urban', 'mountain', 'any'],
    instruction: 'Crouch down low, one hand touching the ground. Superhero pose!',
    emoji: '🦸',
    keypoints: [
      {'x': 0.50, 'y': 0.40}, // Head much lower
      {'x': 0.47, 'y': 0.38}, {'x': 0.46, 'y': 0.38}, {'x': 0.45, 'y': 0.38},
      {'x': 0.53, 'y': 0.38}, {'x': 0.54, 'y': 0.38}, {'x': 0.55, 'y': 0.38},
      {'x': 0.43, 'y': 0.40}, {'x': 0.57, 'y': 0.40},
      {'x': 0.48, 'y': 0.42}, {'x': 0.52, 'y': 0.42},
      {'x': 0.35, 'y': 0.50}, {'x': 0.65, 'y': 0.50},
      {'x': 0.20, 'y': 0.60}, {'x': 0.60, 'y': 0.65}, // Left arm out, Right arm down
      {'x': 0.15, 'y': 0.70}, {'x': 0.50, 'y': 0.85}, // Right hand near ground
      {'x': 0.14, 'y': 0.72}, {'x': 0.49, 'y': 0.87},
      {'x': 0.16, 'y': 0.71}, {'x': 0.51, 'y': 0.86},
      {'x': 0.17, 'y': 0.70}, {'x': 0.52, 'y': 0.85},
      {'x': 0.40, 'y': 0.70}, {'x': 0.60, 'y': 0.70},
      {'x': 0.30, 'y': 0.85}, {'x': 0.80, 'y': 0.85}, // Knees out wide/low
      {'x': 0.35, 'y': 0.95}, {'x': 0.75, 'y': 0.95},
      {'x': 0.33, 'y': 0.97}, {'x': 0.73, 'y': 0.97},
      {'x': 0.37, 'y': 1.00}, {'x': 0.77, 'y': 1.00},
    ],
    keyAngles: {
      'leftElbow': 160.0, 'rightElbow': 160.0,
      'leftHip': 60.0, 'rightHip': 60.0,
      'leftKnee': 40.0, 'rightKnee': 40.0,
    },
  );

  // ── 18. Power Stance ──
  static const _powerStance = PoseTemplate(
    id: 'solo_18',
    name: 'Power Stance',
    category: 'solo',
    personCount: 1,
    difficulty: 'easy',
    placeTags: ['urban', 'business'],
    instruction: 'Stand tall, feet wide apart, hands firmly on your hips!',
    emoji: '🦸‍♂️',
    keypoints: [
      {'x': 0.50, 'y': 0.05},
      {'x': 0.47, 'y': 0.03}, {'x': 0.46, 'y': 0.03}, {'x': 0.45, 'y': 0.03},
      {'x': 0.53, 'y': 0.03}, {'x': 0.54, 'y': 0.03}, {'x': 0.55, 'y': 0.03},
      {'x': 0.43, 'y': 0.05}, {'x': 0.57, 'y': 0.05},
      {'x': 0.48, 'y': 0.07}, {'x': 0.52, 'y': 0.07},
      {'x': 0.35, 'y': 0.22}, {'x': 0.65, 'y': 0.22},
      {'x': 0.20, 'y': 0.35}, {'x': 0.80, 'y': 0.35}, // Elbows wide
      {'x': 0.38, 'y': 0.52}, {'x': 0.62, 'y': 0.52}, // Hands on hips
      {'x': 0.36, 'y': 0.54}, {'x': 0.64, 'y': 0.54},
      {'x': 0.38, 'y': 0.53}, {'x': 0.62, 'y': 0.53},
      {'x': 0.39, 'y': 0.52}, {'x': 0.61, 'y': 0.52},
      {'x': 0.40, 'y': 0.52}, {'x': 0.60, 'y': 0.52},
      {'x': 0.35, 'y': 0.75}, {'x': 0.65, 'y': 0.75}, // Legs wide
      {'x': 0.30, 'y': 0.95}, {'x': 0.70, 'y': 0.95},
      {'x': 0.28, 'y': 0.97}, {'x': 0.72, 'y': 0.97},
      {'x': 0.32, 'y': 1.00}, {'x': 0.68, 'y': 1.00},
    ],
    keyAngles: {
      'leftElbow': 70.0, 'rightElbow': 70.0,
      'leftHip': 160.0, 'rightHip': 160.0,
      'leftKnee': 175.0, 'rightKnee': 175.0,
    },
  );

  // ── 19. Casual Lean ──
  static const _casualLean = PoseTemplate(
    id: 'solo_19',
    name: 'Casual Lean',
    category: 'solo',
    personCount: 1,
    difficulty: 'easy',
    placeTags: ['indoor', 'cafe'],
    instruction: 'Lean casually to one side, one hand in pocket.',
    emoji: '☕',
    keypoints: [
      {'x': 0.55, 'y': 0.05}, // Head skewed right
      {'x': 0.52, 'y': 0.03}, {'x': 0.51, 'y': 0.03}, {'x': 0.50, 'y': 0.03},
      {'x': 0.58, 'y': 0.03}, {'x': 0.59, 'y': 0.03}, {'x': 0.60, 'y': 0.03},
      {'x': 0.48, 'y': 0.05}, {'x': 0.62, 'y': 0.05},
      {'x': 0.53, 'y': 0.07}, {'x': 0.57, 'y': 0.07},
      {'x': 0.40, 'y': 0.22}, {'x': 0.70, 'y': 0.22},
      {'x': 0.30, 'y': 0.40}, {'x': 0.75, 'y': 0.40},
      {'x': 0.35, 'y': 0.52}, {'x': 0.65, 'y': 0.52},
      {'x': 0.33, 'y': 0.54}, {'x': 0.67, 'y': 0.54},
      {'x': 0.35, 'y': 0.53}, {'x': 0.65, 'y': 0.53},
      {'x': 0.36, 'y': 0.52}, {'x': 0.64, 'y': 0.52},
      {'x': 0.45, 'y': 0.52}, {'x': 0.65, 'y': 0.52}, // Hips right
      {'x': 0.45, 'y': 0.73}, {'x': 0.55, 'y': 0.73},
      {'x': 0.45, 'y': 0.95}, {'x': 0.55, 'y': 0.95},
      {'x': 0.43, 'y': 0.97}, {'x': 0.53, 'y': 0.97},
      {'x': 0.47, 'y': 1.00}, {'x': 0.57, 'y': 1.00},
    ],
    keyAngles: {
      'leftElbow': 90.0, 'rightElbow': 170.0,
      'leftHip': 175.0, 'rightHip': 175.0,
    },
  );

  // ── 20. The Aura ──
  static const _theAura = PoseTemplate(
    id: 'solo_20',
    name: 'The Aura',
    category: 'solo',
    personCount: 1,
    difficulty: 'medium',
    placeTags: ['sunset', 'mountain'],
    instruction: 'Raise your arms gently outwards like you are floating!',
    emoji: '✨',
    keypoints: [
      {'x': 0.50, 'y': 0.05},
      {'x': 0.47, 'y': 0.03}, {'x': 0.46, 'y': 0.03}, {'x': 0.45, 'y': 0.03},
      {'x': 0.53, 'y': 0.03}, {'x': 0.54, 'y': 0.03}, {'x': 0.55, 'y': 0.03},
      {'x': 0.43, 'y': 0.05}, {'x': 0.57, 'y': 0.05},
      {'x': 0.48, 'y': 0.07}, {'x': 0.52, 'y': 0.07},
      {'x': 0.35, 'y': 0.20}, {'x': 0.65, 'y': 0.20},
      {'x': 0.20, 'y': 0.15}, {'x': 0.80, 'y': 0.15}, // Elbows up slightly
      {'x': 0.10, 'y': 0.10}, {'x': 0.90, 'y': 0.10}, // Wrists very high/wide
      {'x': 0.08, 'y': 0.10}, {'x': 0.92, 'y': 0.10},
      {'x': 0.09, 'y': 0.09}, {'x': 0.91, 'y': 0.09},
      {'x': 0.11, 'y': 0.11}, {'x': 0.89, 'y': 0.11},
      {'x': 0.40, 'y': 0.52}, {'x': 0.60, 'y': 0.52},
      {'x': 0.40, 'y': 0.73}, {'x': 0.60, 'y': 0.73},
      {'x': 0.40, 'y': 0.95}, {'x': 0.60, 'y': 0.95},
      {'x': 0.38, 'y': 0.97}, {'x': 0.58, 'y': 0.97},
      {'x': 0.42, 'y': 1.00}, {'x': 0.62, 'y': 1.00},
    ],
    keyAngles: {
      'leftElbow': 160.0, 'rightElbow': 160.0,
      'leftShoulder': 120.0, 'rightShoulder': 120.0,
      'leftHip': 175.0, 'rightHip': 175.0,
      'leftKnee': 178.0, 'rightKnee': 178.0,
    },
  );
}
