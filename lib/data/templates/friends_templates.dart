import '../models/pose_template.dart';

/// 12 Friends pose templates
class FriendsTemplates {
  FriendsTemplates._();

  static List<PoseTemplate> get all => [
    _groupJump, _charliesAngels, _pyramid, _groupWave, _armsOverShoulders,
    _funnyFace, _walkingSquad, _backToBackCircle, _dabbingTogether,
    _pointingAtEachOther, _victoryLine, _groupSelfie,
  ];

  static const _groupJump = PoseTemplate(
    id: 'friends_01', name: 'Group Jump Shot', category: 'friends', personCount: 3,
    difficulty: 'hard', placeTags: ['beach', 'park', 'any'], emoji: '🤸',
    instruction: 'Everyone jump at the same time with arms up!',
    keypoints: [
      {'x': 0.50, 'y': 0.05}, {'x': 0.48, 'y': 0.03}, {'x': 0.47, 'y': 0.03}, {'x': 0.46, 'y': 0.03},
      {'x': 0.52, 'y': 0.03}, {'x': 0.53, 'y': 0.03}, {'x': 0.54, 'y': 0.03},
      {'x': 0.44, 'y': 0.05}, {'x': 0.56, 'y': 0.05}, {'x': 0.49, 'y': 0.07}, {'x': 0.51, 'y': 0.07},
      {'x': 0.35, 'y': 0.20}, {'x': 0.65, 'y': 0.20},
      {'x': 0.25, 'y': 0.08}, {'x': 0.75, 'y': 0.08},
      {'x': 0.20, 'y': 0.00}, {'x': 0.80, 'y': 0.00},
      {'x': 0.19, 'y': 0.01}, {'x': 0.81, 'y': 0.01}, {'x': 0.21, 'y': 0.00}, {'x': 0.79, 'y': 0.00},
      {'x': 0.22, 'y': 0.01}, {'x': 0.78, 'y': 0.01},
      {'x': 0.40, 'y': 0.50}, {'x': 0.60, 'y': 0.50},
      {'x': 0.38, 'y': 0.70}, {'x': 0.62, 'y': 0.70},
      {'x': 0.40, 'y': 0.88}, {'x': 0.60, 'y': 0.88},
      {'x': 0.38, 'y': 0.90}, {'x': 0.58, 'y': 0.90},
      {'x': 0.42, 'y': 0.93}, {'x': 0.62, 'y': 0.93},
    ],
    keyAngles: {'leftElbow': 165.0, 'rightElbow': 165.0, 'leftShoulder': 170.0, 'rightShoulder': 170.0, 'leftHip': 165.0, 'rightHip': 165.0, 'leftKnee': 150.0, 'rightKnee': 150.0},
  );

  static const _charliesAngels = PoseTemplate(
    id: 'friends_02', name: "Charlie's Angels", category: 'friends', personCount: 3,
    difficulty: 'medium', placeTags: ['urban', 'indoor'], emoji: '🔫',
    instruction: 'Strike the classic Charlie\'s Angels pose - back to back, finger guns!',
    keypoints: [
      {'x': 0.50, 'y': 0.05}, {'x': 0.48, 'y': 0.03}, {'x': 0.47, 'y': 0.03}, {'x': 0.46, 'y': 0.03},
      {'x': 0.52, 'y': 0.03}, {'x': 0.53, 'y': 0.03}, {'x': 0.54, 'y': 0.03},
      {'x': 0.44, 'y': 0.05}, {'x': 0.56, 'y': 0.05}, {'x': 0.49, 'y': 0.07}, {'x': 0.51, 'y': 0.07},
      {'x': 0.37, 'y': 0.22}, {'x': 0.63, 'y': 0.22},
      {'x': 0.25, 'y': 0.18}, {'x': 0.75, 'y': 0.18},
      {'x': 0.15, 'y': 0.18}, {'x': 0.85, 'y': 0.18},
      {'x': 0.14, 'y': 0.19}, {'x': 0.86, 'y': 0.19}, {'x': 0.16, 'y': 0.17}, {'x': 0.84, 'y': 0.17},
      {'x': 0.17, 'y': 0.18}, {'x': 0.83, 'y': 0.18},
      {'x': 0.40, 'y': 0.52}, {'x': 0.60, 'y': 0.52},
      {'x': 0.40, 'y': 0.73}, {'x': 0.60, 'y': 0.73},
      {'x': 0.40, 'y': 0.95}, {'x': 0.60, 'y': 0.95},
      {'x': 0.38, 'y': 0.97}, {'x': 0.58, 'y': 0.97},
      {'x': 0.42, 'y': 1.00}, {'x': 0.62, 'y': 1.00},
    ],
    keyAngles: {'leftElbow': 170.0, 'rightElbow': 170.0, 'leftShoulder': 85.0, 'rightShoulder': 85.0, 'leftHip': 175.0, 'rightHip': 175.0, 'leftKnee': 178.0, 'rightKnee': 178.0},
  );

  static const _pyramid = PoseTemplate(
    id: 'friends_03', name: 'Pyramid Levels', category: 'friends', personCount: 3,
    difficulty: 'hard', placeTags: ['park', 'beach', 'steps'], emoji: '🔺',
    instruction: 'Create different height levels - one squat, one stand, one jump!',
    keypoints: [
      {'x': 0.50, 'y': 0.05}, {'x': 0.48, 'y': 0.03}, {'x': 0.47, 'y': 0.03}, {'x': 0.46, 'y': 0.03},
      {'x': 0.52, 'y': 0.03}, {'x': 0.53, 'y': 0.03}, {'x': 0.54, 'y': 0.03},
      {'x': 0.44, 'y': 0.05}, {'x': 0.56, 'y': 0.05}, {'x': 0.49, 'y': 0.07}, {'x': 0.51, 'y': 0.07},
      {'x': 0.35, 'y': 0.18}, {'x': 0.65, 'y': 0.18},
      {'x': 0.25, 'y': 0.05}, {'x': 0.75, 'y': 0.05},
      {'x': 0.20, 'y': 0.00}, {'x': 0.80, 'y': 0.00},
      {'x': 0.19, 'y': 0.01}, {'x': 0.81, 'y': 0.01}, {'x': 0.21, 'y': 0.00}, {'x': 0.79, 'y': 0.00},
      {'x': 0.22, 'y': 0.01}, {'x': 0.78, 'y': 0.01},
      {'x': 0.40, 'y': 0.45}, {'x': 0.60, 'y': 0.45},
      {'x': 0.40, 'y': 0.68}, {'x': 0.60, 'y': 0.68},
      {'x': 0.40, 'y': 0.90}, {'x': 0.60, 'y': 0.90},
      {'x': 0.38, 'y': 0.92}, {'x': 0.58, 'y': 0.92},
      {'x': 0.42, 'y': 0.95}, {'x': 0.62, 'y': 0.95},
    ],
    keyAngles: {'leftElbow': 160.0, 'rightElbow': 160.0, 'leftShoulder': 160.0, 'rightShoulder': 160.0, 'leftHip': 170.0, 'rightHip': 170.0, 'leftKnee': 165.0, 'rightKnee': 165.0},
  );

  static const _groupWave = PoseTemplate(
    id: 'friends_04', name: 'Group Wave', category: 'friends', personCount: 3,
    difficulty: 'easy', placeTags: ['any'], emoji: '👋',
    instruction: 'Everyone wave at the camera together!',
    keypoints: [
      {'x': 0.50, 'y': 0.05}, {'x': 0.48, 'y': 0.03}, {'x': 0.47, 'y': 0.03}, {'x': 0.46, 'y': 0.03},
      {'x': 0.52, 'y': 0.03}, {'x': 0.53, 'y': 0.03}, {'x': 0.54, 'y': 0.03},
      {'x': 0.44, 'y': 0.05}, {'x': 0.56, 'y': 0.05}, {'x': 0.49, 'y': 0.07}, {'x': 0.51, 'y': 0.07},
      {'x': 0.37, 'y': 0.22}, {'x': 0.63, 'y': 0.22},
      {'x': 0.30, 'y': 0.12}, {'x': 0.70, 'y': 0.12},
      {'x': 0.25, 'y': 0.02}, {'x': 0.75, 'y': 0.02},
      {'x': 0.24, 'y': 0.03}, {'x': 0.76, 'y': 0.03}, {'x': 0.26, 'y': 0.01}, {'x': 0.74, 'y': 0.01},
      {'x': 0.27, 'y': 0.02}, {'x': 0.73, 'y': 0.02},
      {'x': 0.40, 'y': 0.52}, {'x': 0.60, 'y': 0.52},
      {'x': 0.40, 'y': 0.73}, {'x': 0.60, 'y': 0.73},
      {'x': 0.40, 'y': 0.95}, {'x': 0.60, 'y': 0.95},
      {'x': 0.38, 'y': 0.97}, {'x': 0.58, 'y': 0.97},
      {'x': 0.42, 'y': 1.00}, {'x': 0.62, 'y': 1.00},
    ],
    keyAngles: {'leftElbow': 130.0, 'rightElbow': 130.0, 'leftShoulder': 150.0, 'rightShoulder': 150.0, 'leftHip': 175.0, 'rightHip': 175.0, 'leftKnee': 178.0, 'rightKnee': 178.0},
  );

  static const _armsOverShoulders = PoseTemplate(
    id: 'friends_05', name: 'Arms Over Shoulders', category: 'friends', personCount: 3,
    difficulty: 'easy', placeTags: ['any'], emoji: '🤙',
    instruction: 'Put arms over each other\'s shoulders, squad style!',
    keypoints: [
      {'x': 0.50, 'y': 0.05}, {'x': 0.48, 'y': 0.03}, {'x': 0.47, 'y': 0.03}, {'x': 0.46, 'y': 0.03},
      {'x': 0.52, 'y': 0.03}, {'x': 0.53, 'y': 0.03}, {'x': 0.54, 'y': 0.03},
      {'x': 0.44, 'y': 0.05}, {'x': 0.56, 'y': 0.05}, {'x': 0.49, 'y': 0.07}, {'x': 0.51, 'y': 0.07},
      {'x': 0.37, 'y': 0.20}, {'x': 0.63, 'y': 0.20},
      {'x': 0.25, 'y': 0.22}, {'x': 0.75, 'y': 0.22},
      {'x': 0.18, 'y': 0.25}, {'x': 0.82, 'y': 0.25},
      {'x': 0.17, 'y': 0.26}, {'x': 0.83, 'y': 0.26}, {'x': 0.19, 'y': 0.24}, {'x': 0.81, 'y': 0.24},
      {'x': 0.20, 'y': 0.25}, {'x': 0.80, 'y': 0.25},
      {'x': 0.40, 'y': 0.52}, {'x': 0.60, 'y': 0.52},
      {'x': 0.40, 'y': 0.73}, {'x': 0.60, 'y': 0.73},
      {'x': 0.40, 'y': 0.95}, {'x': 0.60, 'y': 0.95},
      {'x': 0.38, 'y': 0.97}, {'x': 0.58, 'y': 0.97},
      {'x': 0.42, 'y': 1.00}, {'x': 0.62, 'y': 1.00},
    ],
    keyAngles: {'leftElbow': 120.0, 'rightElbow': 120.0, 'leftShoulder': 85.0, 'rightShoulder': 85.0, 'leftHip': 175.0, 'rightHip': 175.0, 'leftKnee': 178.0, 'rightKnee': 178.0},
  );

  static const _funnyFace = PoseTemplate(
    id: 'friends_06', name: 'Funny Face Lineup', category: 'friends', personCount: 3,
    difficulty: 'easy', placeTags: ['any'], emoji: '🤪',
    instruction: 'Line up and make your funniest faces!',
    keypoints: [
      {'x': 0.50, 'y': 0.05}, {'x': 0.48, 'y': 0.03}, {'x': 0.47, 'y': 0.03}, {'x': 0.46, 'y': 0.03},
      {'x': 0.52, 'y': 0.03}, {'x': 0.53, 'y': 0.03}, {'x': 0.54, 'y': 0.03},
      {'x': 0.44, 'y': 0.05}, {'x': 0.56, 'y': 0.05}, {'x': 0.49, 'y': 0.07}, {'x': 0.51, 'y': 0.07},
      {'x': 0.37, 'y': 0.22}, {'x': 0.63, 'y': 0.22},
      {'x': 0.32, 'y': 0.12}, {'x': 0.68, 'y': 0.12},
      {'x': 0.30, 'y': 0.05}, {'x': 0.70, 'y': 0.05},
      {'x': 0.29, 'y': 0.06}, {'x': 0.71, 'y': 0.06}, {'x': 0.31, 'y': 0.04}, {'x': 0.69, 'y': 0.04},
      {'x': 0.32, 'y': 0.05}, {'x': 0.68, 'y': 0.05},
      {'x': 0.40, 'y': 0.52}, {'x': 0.60, 'y': 0.52},
      {'x': 0.40, 'y': 0.73}, {'x': 0.60, 'y': 0.73},
      {'x': 0.40, 'y': 0.95}, {'x': 0.60, 'y': 0.95},
      {'x': 0.38, 'y': 0.97}, {'x': 0.58, 'y': 0.97},
      {'x': 0.42, 'y': 1.00}, {'x': 0.62, 'y': 1.00},
    ],
    keyAngles: {'leftElbow': 120.0, 'rightElbow': 120.0, 'leftShoulder': 140.0, 'rightShoulder': 140.0, 'leftHip': 175.0, 'rightHip': 175.0, 'leftKnee': 178.0, 'rightKnee': 178.0},
  );

  static const _walkingSquad = PoseTemplate(
    id: 'friends_07', name: 'Walking Squad', category: 'friends', personCount: 3,
    difficulty: 'medium', placeTags: ['urban', 'beach', 'park'], emoji: '🚶‍♂️',
    instruction: 'Walk side-by-side like a squad, mid-stride!',
    keypoints: [
      {'x': 0.50, 'y': 0.05}, {'x': 0.48, 'y': 0.03}, {'x': 0.47, 'y': 0.03}, {'x': 0.46, 'y': 0.03},
      {'x': 0.52, 'y': 0.03}, {'x': 0.53, 'y': 0.03}, {'x': 0.54, 'y': 0.03},
      {'x': 0.44, 'y': 0.05}, {'x': 0.56, 'y': 0.05}, {'x': 0.49, 'y': 0.07}, {'x': 0.51, 'y': 0.07},
      {'x': 0.37, 'y': 0.22}, {'x': 0.63, 'y': 0.22},
      {'x': 0.42, 'y': 0.36}, {'x': 0.55, 'y': 0.36},
      {'x': 0.45, 'y': 0.48}, {'x': 0.52, 'y': 0.48},
      {'x': 0.44, 'y': 0.50}, {'x': 0.51, 'y': 0.50}, {'x': 0.46, 'y': 0.49}, {'x': 0.53, 'y': 0.49},
      {'x': 0.47, 'y': 0.48}, {'x': 0.50, 'y': 0.48},
      {'x': 0.42, 'y': 0.52}, {'x': 0.58, 'y': 0.52},
      {'x': 0.35, 'y': 0.72}, {'x': 0.62, 'y': 0.72},
      {'x': 0.42, 'y': 0.92}, {'x': 0.55, 'y': 0.92},
      {'x': 0.40, 'y': 0.95}, {'x': 0.53, 'y': 0.95},
      {'x': 0.44, 'y': 0.97}, {'x': 0.57, 'y': 0.97},
    ],
    keyAngles: {'leftElbow': 140.0, 'rightElbow': 140.0, 'leftShoulder': 20.0, 'rightShoulder': 20.0, 'leftHip': 155.0, 'rightHip': 165.0, 'leftKnee': 165.0, 'rightKnee': 170.0},
  );

  static const _backToBackCircle = PoseTemplate(
    id: 'friends_08', name: 'Back to Back Circle', category: 'friends', personCount: 3,
    difficulty: 'medium', placeTags: ['park', 'indoor', 'any'], emoji: '🔄',
    instruction: 'Stand in a circle facing outward, arms crossed!',
    keypoints: [
      {'x': 0.50, 'y': 0.05}, {'x': 0.48, 'y': 0.03}, {'x': 0.47, 'y': 0.03}, {'x': 0.46, 'y': 0.03},
      {'x': 0.52, 'y': 0.03}, {'x': 0.53, 'y': 0.03}, {'x': 0.54, 'y': 0.03},
      {'x': 0.44, 'y': 0.05}, {'x': 0.56, 'y': 0.05}, {'x': 0.49, 'y': 0.07}, {'x': 0.51, 'y': 0.07},
      {'x': 0.37, 'y': 0.22}, {'x': 0.63, 'y': 0.22},
      {'x': 0.42, 'y': 0.32}, {'x': 0.58, 'y': 0.32},
      {'x': 0.55, 'y': 0.30}, {'x': 0.45, 'y': 0.30},
      {'x': 0.56, 'y': 0.31}, {'x': 0.44, 'y': 0.31}, {'x': 0.54, 'y': 0.29}, {'x': 0.46, 'y': 0.29},
      {'x': 0.53, 'y': 0.30}, {'x': 0.47, 'y': 0.30},
      {'x': 0.40, 'y': 0.52}, {'x': 0.60, 'y': 0.52},
      {'x': 0.40, 'y': 0.73}, {'x': 0.60, 'y': 0.73},
      {'x': 0.40, 'y': 0.95}, {'x': 0.60, 'y': 0.95},
      {'x': 0.38, 'y': 0.97}, {'x': 0.58, 'y': 0.97},
      {'x': 0.42, 'y': 1.00}, {'x': 0.62, 'y': 1.00},
    ],
    keyAngles: {'leftElbow': 55.0, 'rightElbow': 55.0, 'leftShoulder': 40.0, 'rightShoulder': 40.0, 'leftHip': 175.0, 'rightHip': 175.0, 'leftKnee': 178.0, 'rightKnee': 178.0},
  );

  static const _dabbingTogether = PoseTemplate(
    id: 'friends_09', name: 'Dabbing Together', category: 'friends', personCount: 3,
    difficulty: 'easy', placeTags: ['any'], emoji: '🙆',
    instruction: 'Everyone dab in the same direction, stay in sync!',
    keypoints: [
      {'x': 0.45, 'y': 0.08}, {'x': 0.43, 'y': 0.06}, {'x': 0.42, 'y': 0.06}, {'x': 0.41, 'y': 0.06},
      {'x': 0.47, 'y': 0.06}, {'x': 0.48, 'y': 0.06}, {'x': 0.49, 'y': 0.06},
      {'x': 0.39, 'y': 0.08}, {'x': 0.51, 'y': 0.08}, {'x': 0.44, 'y': 0.10}, {'x': 0.46, 'y': 0.10},
      {'x': 0.35, 'y': 0.22}, {'x': 0.60, 'y': 0.22},
      {'x': 0.40, 'y': 0.10}, {'x': 0.75, 'y': 0.15},
      {'x': 0.42, 'y': 0.05}, {'x': 0.88, 'y': 0.10},
      {'x': 0.41, 'y': 0.06}, {'x': 0.89, 'y': 0.11}, {'x': 0.43, 'y': 0.04}, {'x': 0.87, 'y': 0.09},
      {'x': 0.44, 'y': 0.05}, {'x': 0.86, 'y': 0.10},
      {'x': 0.40, 'y': 0.52}, {'x': 0.58, 'y': 0.52},
      {'x': 0.40, 'y': 0.73}, {'x': 0.58, 'y': 0.73},
      {'x': 0.40, 'y': 0.95}, {'x': 0.58, 'y': 0.95},
      {'x': 0.38, 'y': 0.97}, {'x': 0.56, 'y': 0.97},
      {'x': 0.42, 'y': 1.00}, {'x': 0.60, 'y': 1.00},
    ],
    keyAngles: {'leftElbow': 30.0, 'rightElbow': 160.0, 'leftShoulder': 140.0, 'rightShoulder': 85.0, 'leftHip': 175.0, 'rightHip': 175.0, 'leftKnee': 178.0, 'rightKnee': 178.0},
  );

  static const _pointingAtEachOther = PoseTemplate(
    id: 'friends_10', name: 'Pointing at Each Other', category: 'friends', personCount: 3,
    difficulty: 'easy', placeTags: ['any'], emoji: '👈',
    instruction: 'Point at each other and make funny expressions!',
    keypoints: [
      {'x': 0.50, 'y': 0.05}, {'x': 0.48, 'y': 0.03}, {'x': 0.47, 'y': 0.03}, {'x': 0.46, 'y': 0.03},
      {'x': 0.52, 'y': 0.03}, {'x': 0.53, 'y': 0.03}, {'x': 0.54, 'y': 0.03},
      {'x': 0.44, 'y': 0.05}, {'x': 0.56, 'y': 0.05}, {'x': 0.49, 'y': 0.07}, {'x': 0.51, 'y': 0.07},
      {'x': 0.37, 'y': 0.22}, {'x': 0.63, 'y': 0.22},
      {'x': 0.25, 'y': 0.22}, {'x': 0.75, 'y': 0.22},
      {'x': 0.12, 'y': 0.22}, {'x': 0.88, 'y': 0.22},
      {'x': 0.11, 'y': 0.23}, {'x': 0.89, 'y': 0.23}, {'x': 0.13, 'y': 0.21}, {'x': 0.87, 'y': 0.21},
      {'x': 0.14, 'y': 0.22}, {'x': 0.86, 'y': 0.22},
      {'x': 0.40, 'y': 0.52}, {'x': 0.60, 'y': 0.52},
      {'x': 0.40, 'y': 0.73}, {'x': 0.60, 'y': 0.73},
      {'x': 0.40, 'y': 0.95}, {'x': 0.60, 'y': 0.95},
      {'x': 0.38, 'y': 0.97}, {'x': 0.58, 'y': 0.97},
      {'x': 0.42, 'y': 1.00}, {'x': 0.62, 'y': 1.00},
    ],
    keyAngles: {'leftElbow': 170.0, 'rightElbow': 170.0, 'leftShoulder': 85.0, 'rightShoulder': 85.0, 'leftHip': 175.0, 'rightHip': 175.0, 'leftKnee': 178.0, 'rightKnee': 178.0},
  );

  static const _victoryLine = PoseTemplate(
    id: 'friends_11', name: 'Victory Line', category: 'friends', personCount: 3,
    difficulty: 'easy', placeTags: ['steps', 'park', 'any'], emoji: '🏆',
    instruction: 'Line up and all do the victory sign together!',
    keypoints: [
      {'x': 0.50, 'y': 0.05}, {'x': 0.48, 'y': 0.03}, {'x': 0.47, 'y': 0.03}, {'x': 0.46, 'y': 0.03},
      {'x': 0.52, 'y': 0.03}, {'x': 0.53, 'y': 0.03}, {'x': 0.54, 'y': 0.03},
      {'x': 0.44, 'y': 0.05}, {'x': 0.56, 'y': 0.05}, {'x': 0.49, 'y': 0.07}, {'x': 0.51, 'y': 0.07},
      {'x': 0.37, 'y': 0.22}, {'x': 0.63, 'y': 0.22},
      {'x': 0.30, 'y': 0.12}, {'x': 0.70, 'y': 0.12},
      {'x': 0.27, 'y': 0.02}, {'x': 0.73, 'y': 0.02},
      {'x': 0.26, 'y': 0.03}, {'x': 0.74, 'y': 0.03}, {'x': 0.28, 'y': 0.01}, {'x': 0.72, 'y': 0.01},
      {'x': 0.29, 'y': 0.02}, {'x': 0.71, 'y': 0.02},
      {'x': 0.40, 'y': 0.52}, {'x': 0.60, 'y': 0.52},
      {'x': 0.40, 'y': 0.73}, {'x': 0.60, 'y': 0.73},
      {'x': 0.40, 'y': 0.95}, {'x': 0.60, 'y': 0.95},
      {'x': 0.38, 'y': 0.97}, {'x': 0.58, 'y': 0.97},
      {'x': 0.42, 'y': 1.00}, {'x': 0.62, 'y': 1.00},
    ],
    keyAngles: {'leftElbow': 145.0, 'rightElbow': 145.0, 'leftShoulder': 155.0, 'rightShoulder': 155.0, 'leftHip': 175.0, 'rightHip': 175.0, 'leftKnee': 178.0, 'rightKnee': 178.0},
  );

  static const _groupSelfie = PoseTemplate(
    id: 'friends_12', name: 'Group Selfie Pose', category: 'friends', personCount: 3,
    difficulty: 'easy', placeTags: ['any'], emoji: '🤳',
    instruction: 'Huddle close together like taking a group selfie!',
    keypoints: [
      {'x': 0.50, 'y': 0.05}, {'x': 0.48, 'y': 0.03}, {'x': 0.47, 'y': 0.03}, {'x': 0.46, 'y': 0.03},
      {'x': 0.52, 'y': 0.03}, {'x': 0.53, 'y': 0.03}, {'x': 0.54, 'y': 0.03},
      {'x': 0.44, 'y': 0.05}, {'x': 0.56, 'y': 0.05}, {'x': 0.49, 'y': 0.07}, {'x': 0.51, 'y': 0.07},
      {'x': 0.38, 'y': 0.22}, {'x': 0.62, 'y': 0.22},
      {'x': 0.33, 'y': 0.35}, {'x': 0.67, 'y': 0.35},
      {'x': 0.35, 'y': 0.48}, {'x': 0.65, 'y': 0.48},
      {'x': 0.34, 'y': 0.50}, {'x': 0.66, 'y': 0.50}, {'x': 0.36, 'y': 0.49}, {'x': 0.64, 'y': 0.49},
      {'x': 0.37, 'y': 0.48}, {'x': 0.63, 'y': 0.48},
      {'x': 0.40, 'y': 0.52}, {'x': 0.60, 'y': 0.52},
      {'x': 0.40, 'y': 0.73}, {'x': 0.60, 'y': 0.73},
      {'x': 0.40, 'y': 0.95}, {'x': 0.60, 'y': 0.95},
      {'x': 0.38, 'y': 0.97}, {'x': 0.58, 'y': 0.97},
      {'x': 0.42, 'y': 1.00}, {'x': 0.62, 'y': 1.00},
    ],
    keyAngles: {'leftElbow': 120.0, 'rightElbow': 120.0, 'leftShoulder': 20.0, 'rightShoulder': 20.0, 'leftHip': 175.0, 'rightHip': 175.0, 'leftKnee': 178.0, 'rightKnee': 178.0},
  );
}
