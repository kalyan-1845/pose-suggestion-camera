import '../models/pose_template.dart';

/// 10 Family pose templates
class FamilyTemplates {
  FamilyTemplates._();

  static List<PoseTemplate> get all => [
    _classicPortrait, _groupHug, _parentsLiftChild, _sittingStaircase,
    _walkingTogether, _piggybackFamily, _handsStacked, _lookingUp,
    _triangleFormation, _candidLaughing,
  ];

  static const _classicPortrait = PoseTemplate(
    id: 'family_01', name: 'Classic Portrait', category: 'family', personCount: 4,
    difficulty: 'easy', placeTags: ['indoor', 'park', 'steps'], emoji: '👨‍👩‍👧‍👦',
    instruction: 'Stand in a line by height, tallest in back!',
    keypoints: [
      {'x': 0.50, 'y': 0.05}, {'x': 0.48, 'y': 0.03}, {'x': 0.47, 'y': 0.03}, {'x': 0.46, 'y': 0.03},
      {'x': 0.52, 'y': 0.03}, {'x': 0.53, 'y': 0.03}, {'x': 0.54, 'y': 0.03},
      {'x': 0.44, 'y': 0.05}, {'x': 0.56, 'y': 0.05}, {'x': 0.49, 'y': 0.07}, {'x': 0.51, 'y': 0.07},
      {'x': 0.37, 'y': 0.22}, {'x': 0.63, 'y': 0.22},
      {'x': 0.32, 'y': 0.38}, {'x': 0.68, 'y': 0.38},
      {'x': 0.35, 'y': 0.50}, {'x': 0.65, 'y': 0.50},
      {'x': 0.34, 'y': 0.52}, {'x': 0.66, 'y': 0.52}, {'x': 0.36, 'y': 0.51}, {'x': 0.64, 'y': 0.51},
      {'x': 0.37, 'y': 0.50}, {'x': 0.63, 'y': 0.50},
      {'x': 0.40, 'y': 0.52}, {'x': 0.60, 'y': 0.52},
      {'x': 0.40, 'y': 0.73}, {'x': 0.60, 'y': 0.73},
      {'x': 0.40, 'y': 0.95}, {'x': 0.60, 'y': 0.95},
      {'x': 0.38, 'y': 0.97}, {'x': 0.58, 'y': 0.97},
      {'x': 0.42, 'y': 1.00}, {'x': 0.62, 'y': 1.00},
    ],
    keyAngles: {'leftElbow': 155.0, 'rightElbow': 155.0, 'leftShoulder': 18.0, 'rightShoulder': 18.0, 'leftHip': 175.0, 'rightHip': 175.0, 'leftKnee': 178.0, 'rightKnee': 178.0},
  );

  static const _groupHug = PoseTemplate(
    id: 'family_02', name: 'Group Hug Circle', category: 'family', personCount: 4,
    difficulty: 'easy', placeTags: ['any'], emoji: '🫂',
    instruction: 'Everyone hug together in a tight group!',
    keypoints: [
      {'x': 0.50, 'y': 0.05}, {'x': 0.48, 'y': 0.03}, {'x': 0.47, 'y': 0.03}, {'x': 0.46, 'y': 0.03},
      {'x': 0.52, 'y': 0.03}, {'x': 0.53, 'y': 0.03}, {'x': 0.54, 'y': 0.03},
      {'x': 0.44, 'y': 0.05}, {'x': 0.56, 'y': 0.05}, {'x': 0.49, 'y': 0.07}, {'x': 0.51, 'y': 0.07},
      {'x': 0.38, 'y': 0.22}, {'x': 0.62, 'y': 0.22},
      {'x': 0.42, 'y': 0.32}, {'x': 0.58, 'y': 0.32},
      {'x': 0.55, 'y': 0.35}, {'x': 0.45, 'y': 0.35},
      {'x': 0.56, 'y': 0.36}, {'x': 0.44, 'y': 0.36}, {'x': 0.54, 'y': 0.34}, {'x': 0.46, 'y': 0.34},
      {'x': 0.53, 'y': 0.35}, {'x': 0.47, 'y': 0.35},
      {'x': 0.40, 'y': 0.52}, {'x': 0.60, 'y': 0.52},
      {'x': 0.40, 'y': 0.73}, {'x': 0.60, 'y': 0.73},
      {'x': 0.40, 'y': 0.95}, {'x': 0.60, 'y': 0.95},
      {'x': 0.38, 'y': 0.97}, {'x': 0.58, 'y': 0.97},
      {'x': 0.42, 'y': 1.00}, {'x': 0.62, 'y': 1.00},
    ],
    keyAngles: {'leftElbow': 75.0, 'rightElbow': 75.0, 'leftShoulder': 40.0, 'rightShoulder': 40.0, 'leftHip': 175.0, 'rightHip': 175.0, 'leftKnee': 178.0, 'rightKnee': 178.0},
  );

  static const _parentsLiftChild = PoseTemplate(
    id: 'family_03', name: 'Parents Lift Child', category: 'family', personCount: 3,
    difficulty: 'medium', placeTags: ['park', 'beach', 'indoor'], emoji: '👶',
    instruction: 'Parents hold child\'s hands and lift them up between!',
    keypoints: [
      {'x': 0.50, 'y': 0.00}, {'x': 0.48, 'y': 0.00}, {'x': 0.47, 'y': 0.00}, {'x': 0.46, 'y': 0.00},
      {'x': 0.52, 'y': 0.00}, {'x': 0.53, 'y': 0.00}, {'x': 0.54, 'y': 0.00},
      {'x': 0.44, 'y': 0.02}, {'x': 0.56, 'y': 0.02}, {'x': 0.49, 'y': 0.03}, {'x': 0.51, 'y': 0.03},
      {'x': 0.35, 'y': 0.15}, {'x': 0.65, 'y': 0.15},
      {'x': 0.25, 'y': 0.10}, {'x': 0.75, 'y': 0.10},
      {'x': 0.20, 'y': 0.08}, {'x': 0.80, 'y': 0.08},
      {'x': 0.19, 'y': 0.09}, {'x': 0.81, 'y': 0.09}, {'x': 0.21, 'y': 0.07}, {'x': 0.79, 'y': 0.07},
      {'x': 0.22, 'y': 0.08}, {'x': 0.78, 'y': 0.08},
      {'x': 0.42, 'y': 0.40}, {'x': 0.58, 'y': 0.40},
      {'x': 0.40, 'y': 0.62}, {'x': 0.60, 'y': 0.62},
      {'x': 0.42, 'y': 0.85}, {'x': 0.58, 'y': 0.85},
      {'x': 0.40, 'y': 0.88}, {'x': 0.56, 'y': 0.88},
      {'x': 0.44, 'y': 0.90}, {'x': 0.60, 'y': 0.90},
    ],
    keyAngles: {'leftElbow': 160.0, 'rightElbow': 160.0, 'leftShoulder': 140.0, 'rightShoulder': 140.0, 'leftHip': 170.0, 'rightHip': 170.0, 'leftKnee': 175.0, 'rightKnee': 175.0},
  );

  static const _sittingStaircase = PoseTemplate(
    id: 'family_04', name: 'Sitting Staircase', category: 'family', personCount: 4,
    difficulty: 'easy', placeTags: ['steps', 'indoor'], emoji: '🪜',
    instruction: 'Sit on stairs at different levels, cascading down!',
    keypoints: [
      {'x': 0.50, 'y': 0.10}, {'x': 0.48, 'y': 0.08}, {'x': 0.47, 'y': 0.08}, {'x': 0.46, 'y': 0.08},
      {'x': 0.52, 'y': 0.08}, {'x': 0.53, 'y': 0.08}, {'x': 0.54, 'y': 0.08},
      {'x': 0.44, 'y': 0.10}, {'x': 0.56, 'y': 0.10}, {'x': 0.49, 'y': 0.12}, {'x': 0.51, 'y': 0.12},
      {'x': 0.38, 'y': 0.28}, {'x': 0.62, 'y': 0.28},
      {'x': 0.32, 'y': 0.42}, {'x': 0.68, 'y': 0.42},
      {'x': 0.35, 'y': 0.55}, {'x': 0.65, 'y': 0.55},
      {'x': 0.34, 'y': 0.57}, {'x': 0.66, 'y': 0.57}, {'x': 0.36, 'y': 0.56}, {'x': 0.64, 'y': 0.56},
      {'x': 0.37, 'y': 0.55}, {'x': 0.63, 'y': 0.55},
      {'x': 0.42, 'y': 0.56}, {'x': 0.58, 'y': 0.56},
      {'x': 0.38, 'y': 0.72}, {'x': 0.62, 'y': 0.72},
      {'x': 0.42, 'y': 0.90}, {'x': 0.58, 'y': 0.90},
      {'x': 0.40, 'y': 0.93}, {'x': 0.56, 'y': 0.93},
      {'x': 0.44, 'y': 0.95}, {'x': 0.60, 'y': 0.95},
    ],
    keyAngles: {'leftElbow': 120.0, 'rightElbow': 120.0, 'leftShoulder': 25.0, 'rightShoulder': 25.0, 'leftHip': 90.0, 'rightHip': 90.0, 'leftKnee': 90.0, 'rightKnee': 90.0},
  );

  static const _walkingTogether = PoseTemplate(
    id: 'family_05', name: 'Walking Together', category: 'family', personCount: 4,
    difficulty: 'easy', placeTags: ['park', 'beach', 'urban'], emoji: '🚶‍♂️',
    instruction: 'Walk together as a family, holding hands!',
    keypoints: [
      {'x': 0.50, 'y': 0.05}, {'x': 0.48, 'y': 0.03}, {'x': 0.47, 'y': 0.03}, {'x': 0.46, 'y': 0.03},
      {'x': 0.52, 'y': 0.03}, {'x': 0.53, 'y': 0.03}, {'x': 0.54, 'y': 0.03},
      {'x': 0.44, 'y': 0.05}, {'x': 0.56, 'y': 0.05}, {'x': 0.49, 'y': 0.07}, {'x': 0.51, 'y': 0.07},
      {'x': 0.37, 'y': 0.22}, {'x': 0.63, 'y': 0.22},
      {'x': 0.25, 'y': 0.35}, {'x': 0.75, 'y': 0.35},
      {'x': 0.20, 'y': 0.45}, {'x': 0.80, 'y': 0.45},
      {'x': 0.19, 'y': 0.47}, {'x': 0.81, 'y': 0.47}, {'x': 0.21, 'y': 0.44}, {'x': 0.79, 'y': 0.44},
      {'x': 0.22, 'y': 0.45}, {'x': 0.78, 'y': 0.45},
      {'x': 0.40, 'y': 0.52}, {'x': 0.60, 'y': 0.52},
      {'x': 0.35, 'y': 0.72}, {'x': 0.62, 'y': 0.72},
      {'x': 0.42, 'y': 0.92}, {'x': 0.55, 'y': 0.92},
      {'x': 0.40, 'y': 0.95}, {'x': 0.53, 'y': 0.95},
      {'x': 0.44, 'y': 0.97}, {'x': 0.57, 'y': 0.97},
    ],
    keyAngles: {'leftElbow': 150.0, 'rightElbow': 150.0, 'leftShoulder': 30.0, 'rightShoulder': 30.0, 'leftHip': 160.0, 'rightHip': 165.0, 'leftKnee': 168.0, 'rightKnee': 172.0},
  );

  static const _piggybackFamily = PoseTemplate(
    id: 'family_06', name: 'Piggyback Family', category: 'family', personCount: 3,
    difficulty: 'medium', placeTags: ['park', 'beach', 'any'], emoji: '🐻',
    instruction: 'Kids on parents\' backs for a fun piggyback shot!',
    keypoints: [
      {'x': 0.50, 'y': 0.00}, {'x': 0.48, 'y': 0.00}, {'x': 0.47, 'y': 0.00}, {'x': 0.46, 'y': 0.00},
      {'x': 0.52, 'y': 0.00}, {'x': 0.53, 'y': 0.00}, {'x': 0.54, 'y': 0.00},
      {'x': 0.44, 'y': 0.02}, {'x': 0.56, 'y': 0.02}, {'x': 0.49, 'y': 0.03}, {'x': 0.51, 'y': 0.03},
      {'x': 0.38, 'y': 0.15}, {'x': 0.62, 'y': 0.15},
      {'x': 0.30, 'y': 0.25}, {'x': 0.70, 'y': 0.25},
      {'x': 0.35, 'y': 0.32}, {'x': 0.65, 'y': 0.32},
      {'x': 0.34, 'y': 0.33}, {'x': 0.66, 'y': 0.33}, {'x': 0.36, 'y': 0.31}, {'x': 0.64, 'y': 0.31},
      {'x': 0.37, 'y': 0.32}, {'x': 0.63, 'y': 0.32},
      {'x': 0.42, 'y': 0.45}, {'x': 0.58, 'y': 0.45},
      {'x': 0.40, 'y': 0.68}, {'x': 0.60, 'y': 0.68},
      {'x': 0.42, 'y': 0.90}, {'x': 0.58, 'y': 0.90},
      {'x': 0.40, 'y': 0.93}, {'x': 0.56, 'y': 0.93},
      {'x': 0.44, 'y': 0.95}, {'x': 0.60, 'y': 0.95},
    ],
    keyAngles: {'leftElbow': 100.0, 'rightElbow': 100.0, 'leftShoulder': 45.0, 'rightShoulder': 45.0, 'leftHip': 162.0, 'rightHip': 162.0, 'leftKnee': 170.0, 'rightKnee': 170.0},
  );

  static const _handsStacked = PoseTemplate(
    id: 'family_07', name: 'Hands Stacked', category: 'family', personCount: 4,
    difficulty: 'easy', placeTags: ['any'], emoji: '🤲',
    instruction: 'Stack all hands together in the center, teamwork!',
    keypoints: [
      {'x': 0.50, 'y': 0.05}, {'x': 0.48, 'y': 0.03}, {'x': 0.47, 'y': 0.03}, {'x': 0.46, 'y': 0.03},
      {'x': 0.52, 'y': 0.03}, {'x': 0.53, 'y': 0.03}, {'x': 0.54, 'y': 0.03},
      {'x': 0.44, 'y': 0.05}, {'x': 0.56, 'y': 0.05}, {'x': 0.49, 'y': 0.07}, {'x': 0.51, 'y': 0.07},
      {'x': 0.37, 'y': 0.22}, {'x': 0.63, 'y': 0.22},
      {'x': 0.42, 'y': 0.32}, {'x': 0.58, 'y': 0.32},
      {'x': 0.48, 'y': 0.38}, {'x': 0.52, 'y': 0.38},
      {'x': 0.47, 'y': 0.39}, {'x': 0.53, 'y': 0.39}, {'x': 0.49, 'y': 0.37}, {'x': 0.51, 'y': 0.37},
      {'x': 0.50, 'y': 0.38}, {'x': 0.50, 'y': 0.38},
      {'x': 0.40, 'y': 0.52}, {'x': 0.60, 'y': 0.52},
      {'x': 0.40, 'y': 0.73}, {'x': 0.60, 'y': 0.73},
      {'x': 0.40, 'y': 0.95}, {'x': 0.60, 'y': 0.95},
      {'x': 0.38, 'y': 0.97}, {'x': 0.58, 'y': 0.97},
      {'x': 0.42, 'y': 1.00}, {'x': 0.62, 'y': 1.00},
    ],
    keyAngles: {'leftElbow': 95.0, 'rightElbow': 95.0, 'leftShoulder': 35.0, 'rightShoulder': 35.0, 'leftHip': 175.0, 'rightHip': 175.0, 'leftKnee': 178.0, 'rightKnee': 178.0},
  );

  static const _lookingUp = PoseTemplate(
    id: 'family_08', name: 'Looking Up Together', category: 'family', personCount: 4,
    difficulty: 'easy', placeTags: ['park', 'any', 'mountain'], emoji: '🌤️',
    instruction: 'Everyone look up at the sky together!',
    keypoints: [
      {'x': 0.50, 'y': 0.08}, {'x': 0.48, 'y': 0.06}, {'x': 0.47, 'y': 0.06}, {'x': 0.46, 'y': 0.06},
      {'x': 0.52, 'y': 0.06}, {'x': 0.53, 'y': 0.06}, {'x': 0.54, 'y': 0.06},
      {'x': 0.44, 'y': 0.08}, {'x': 0.56, 'y': 0.08}, {'x': 0.49, 'y': 0.09}, {'x': 0.51, 'y': 0.09},
      {'x': 0.37, 'y': 0.22}, {'x': 0.63, 'y': 0.22},
      {'x': 0.32, 'y': 0.38}, {'x': 0.68, 'y': 0.38},
      {'x': 0.35, 'y': 0.50}, {'x': 0.65, 'y': 0.50},
      {'x': 0.34, 'y': 0.52}, {'x': 0.66, 'y': 0.52}, {'x': 0.36, 'y': 0.51}, {'x': 0.64, 'y': 0.51},
      {'x': 0.37, 'y': 0.50}, {'x': 0.63, 'y': 0.50},
      {'x': 0.40, 'y': 0.52}, {'x': 0.60, 'y': 0.52},
      {'x': 0.40, 'y': 0.73}, {'x': 0.60, 'y': 0.73},
      {'x': 0.40, 'y': 0.95}, {'x': 0.60, 'y': 0.95},
      {'x': 0.38, 'y': 0.97}, {'x': 0.58, 'y': 0.97},
      {'x': 0.42, 'y': 1.00}, {'x': 0.62, 'y': 1.00},
    ],
    keyAngles: {'leftElbow': 155.0, 'rightElbow': 155.0, 'leftShoulder': 18.0, 'rightShoulder': 18.0, 'leftHip': 175.0, 'rightHip': 175.0, 'leftKnee': 178.0, 'rightKnee': 178.0},
  );

  static const _triangleFormation = PoseTemplate(
    id: 'family_09', name: 'Triangle Formation', category: 'family', personCount: 3,
    difficulty: 'easy', placeTags: ['park', 'indoor', 'any'], emoji: '🔻',
    instruction: 'Form a triangle - one in front, two in back!',
    keypoints: [
      {'x': 0.50, 'y': 0.05}, {'x': 0.48, 'y': 0.03}, {'x': 0.47, 'y': 0.03}, {'x': 0.46, 'y': 0.03},
      {'x': 0.52, 'y': 0.03}, {'x': 0.53, 'y': 0.03}, {'x': 0.54, 'y': 0.03},
      {'x': 0.44, 'y': 0.05}, {'x': 0.56, 'y': 0.05}, {'x': 0.49, 'y': 0.07}, {'x': 0.51, 'y': 0.07},
      {'x': 0.37, 'y': 0.22}, {'x': 0.63, 'y': 0.22},
      {'x': 0.32, 'y': 0.38}, {'x': 0.68, 'y': 0.38},
      {'x': 0.35, 'y': 0.50}, {'x': 0.65, 'y': 0.50},
      {'x': 0.34, 'y': 0.52}, {'x': 0.66, 'y': 0.52}, {'x': 0.36, 'y': 0.51}, {'x': 0.64, 'y': 0.51},
      {'x': 0.37, 'y': 0.50}, {'x': 0.63, 'y': 0.50},
      {'x': 0.40, 'y': 0.52}, {'x': 0.60, 'y': 0.52},
      {'x': 0.40, 'y': 0.73}, {'x': 0.60, 'y': 0.73},
      {'x': 0.40, 'y': 0.95}, {'x': 0.60, 'y': 0.95},
      {'x': 0.38, 'y': 0.97}, {'x': 0.58, 'y': 0.97},
      {'x': 0.42, 'y': 1.00}, {'x': 0.62, 'y': 1.00},
    ],
    keyAngles: {'leftElbow': 155.0, 'rightElbow': 155.0, 'leftShoulder': 18.0, 'rightShoulder': 18.0, 'leftHip': 175.0, 'rightHip': 175.0, 'leftKnee': 178.0, 'rightKnee': 178.0},
  );

  static const _candidLaughing = PoseTemplate(
    id: 'family_10', name: 'Candid Laughing', category: 'family', personCount: 4,
    difficulty: 'easy', placeTags: ['any'], emoji: '😂',
    instruction: 'Everyone laugh together naturally, be candid!',
    keypoints: [
      {'x': 0.50, 'y': 0.05}, {'x': 0.48, 'y': 0.03}, {'x': 0.47, 'y': 0.03}, {'x': 0.46, 'y': 0.03},
      {'x': 0.52, 'y': 0.03}, {'x': 0.53, 'y': 0.03}, {'x': 0.54, 'y': 0.03},
      {'x': 0.44, 'y': 0.05}, {'x': 0.56, 'y': 0.05}, {'x': 0.49, 'y': 0.07}, {'x': 0.51, 'y': 0.07},
      {'x': 0.37, 'y': 0.22}, {'x': 0.63, 'y': 0.22},
      {'x': 0.33, 'y': 0.35}, {'x': 0.67, 'y': 0.35},
      {'x': 0.35, 'y': 0.45}, {'x': 0.65, 'y': 0.45},
      {'x': 0.34, 'y': 0.47}, {'x': 0.66, 'y': 0.47}, {'x': 0.36, 'y': 0.44}, {'x': 0.64, 'y': 0.44},
      {'x': 0.37, 'y': 0.45}, {'x': 0.63, 'y': 0.45},
      {'x': 0.40, 'y': 0.52}, {'x': 0.60, 'y': 0.52},
      {'x': 0.40, 'y': 0.73}, {'x': 0.60, 'y': 0.73},
      {'x': 0.40, 'y': 0.95}, {'x': 0.60, 'y': 0.95},
      {'x': 0.38, 'y': 0.97}, {'x': 0.58, 'y': 0.97},
      {'x': 0.42, 'y': 1.00}, {'x': 0.62, 'y': 1.00},
    ],
    keyAngles: {'leftElbow': 130.0, 'rightElbow': 130.0, 'leftShoulder': 22.0, 'rightShoulder': 22.0, 'leftHip': 175.0, 'rightHip': 175.0, 'leftKnee': 178.0, 'rightKnee': 178.0},
  );
}
