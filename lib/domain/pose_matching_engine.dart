import 'dart:math';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import '../core/constants/pose_constants.dart';
import '../core/utils/pose_utils.dart';
import '../data/models/pose_template.dart';
import '../data/models/pose_match_result.dart';

/// Engine that compares live detected pose against template pose
/// Uses weighted Euclidean distance + joint angle comparison
class PoseMatchingEngine {
  PoseMatchingEngine._();

  /// Compare a live pose against a template and return match result
  static PoseMatchResult compare(Pose livePose, PoseTemplate template) {
    final liveLandmarks = livePose.landmarks;

    // Check if we have enough visible landmarks
    if (!PoseUtils.isPoseVisible(livePose)) {
      return PoseMatchResult.empty;
    }

    // ── Step 1: Normalize live pose keypoints ──
    final liveList = <PoseLandmark>[];
    for (final type in PoseLandmarkType.values) {
      final lm = liveLandmarks[type];
      if (lm != null) {
        liveList.add(lm);
      }
    }

    if (liveList.length < 20) {
      return PoseMatchResult.empty;
    }

    final normalizedLive = PoseUtils.normalizeLandmarks(liveList);
    final normalizedTemplate = PoseUtils.normalizeRawKeypoints(template.keypoints);

    // ── Step 2: Calculate weighted keypoint distance ──
    double totalWeightedError = 0;
    double totalWeight = 0;
    final keypointErrors = <int, double>{};

    final numPoints = min(normalizedLive.length, normalizedTemplate.length);

    for (int i = 0; i < numPoints; i++) {
      final livePoint = normalizedLive[i];
      final templatePoint = normalizedTemplate[i];

      final dx = livePoint['x']! - templatePoint['x']!;
      final dy = livePoint['y']! - templatePoint['y']!;
      final distance = sqrt(dx * dx + dy * dy);

      // Get weight for this keypoint
      double weight = 1.0;
      if (i < PoseLandmarkType.values.length) {
        weight = PoseConstants.keypointWeights[PoseLandmarkType.values[i]] ?? 1.0;
      }

      final confidence = livePoint['confidence'] ?? 0.5;
      final adjustedWeight = weight * confidence;

      totalWeightedError += distance * adjustedWeight;
      totalWeight += adjustedWeight;
      keypointErrors[i] = distance;
    }

    final avgKeypointError = totalWeight > 0 ? totalWeightedError / totalWeight : 1.0;

    // ── Step 3: Calculate joint angle comparison ──
    double angleScore = 0;
    int angleCount = 0;
    final angleErrors = <String, double>{};

    for (final entry in PoseConstants.keyAngles.entries) {
      final angleName = entry.key;
      final points = entry.value;

      if (template.keyAngles.containsKey(angleName)) {
        final lm1 = liveLandmarks[points[0]];
        final lm2 = liveLandmarks[points[1]]; // vertex
        final lm3 = liveLandmarks[points[2]];

        if (lm1 != null && lm2 != null && lm3 != null) {
          final liveAngle = PoseUtils.calculateAngle(lm1, lm2, lm3);
          final templateAngle = template.keyAngles[angleName]!;
          final angleDiff = (liveAngle - templateAngle).abs();

          // Normalize angle error: 0 at perfect match, 1 at 90+ degrees off
          final normalizedAngleError = min(angleDiff / 90.0, 1.0);
          angleScore += (1.0 - normalizedAngleError);
          angleCount++;
          angleErrors[angleName] = angleDiff;
        }
      }
    }

    final avgAngleScore = angleCount > 0 ? angleScore / angleCount : 0.5;

    // ── Step 4: Combine scores ──
    // Keypoint distance: convert to 0-1 score (lower error = higher score)
    final keypointScore = max(0.0, 1.0 - (avgKeypointError * 2.5));

    // Final score: 60% keypoint position + 40% joint angles
    final finalScore = ((keypointScore * 0.6) + (avgAngleScore * 0.4)) * 100;
    final clampedScore = finalScore.clamp(0.0, 100.0);

    // ── Step 5: Generate feedback ──
    final feedback = _generateFeedback(
      normalizedLive,
      normalizedTemplate,
      angleErrors,
      liveLandmarks,
    );

    return PoseMatchResult(
      score: clampedScore,
      isMatched: clampedScore >= PoseConstants.matchThreshold,
      feedback: feedback,
      keypointErrors: keypointErrors,
      angleErrors: angleErrors,
    );
  }

  /// Generate human-readable feedback based on pose differences
  static List<String> _generateFeedback(
    List<Map<String, double>> live,
    List<Map<String, double>> template,
    Map<String, double> angleErrors,
    Map<PoseLandmarkType, PoseLandmark> liveLandmarks,
  ) {
    final feedback = <String>[];
    const threshold = 0.12;

    // Check overall body position (using shoulder midpoint)
    if (live.length >= 13 && template.length >= 13) {
      // Shoulders are at indices 11 (left) and 12 (right)
      final liveMidX = (live[11]['x']! + live[12]['x']!) / 2;
      final liveMidY = (live[11]['y']! + live[12]['y']!) / 2;
      final tempMidX = (template[11]['x']! + template[12]['x']!) / 2;
      final tempMidY = (template[11]['y']! + template[12]['y']!) / 2;

      final dx = liveMidX - tempMidX;
      final dy = liveMidY - tempMidY;

      if (dx.abs() > threshold) {
        feedback.add(dx > 0 ? '← Move left' : '→ Move right');
      }
      if (dy.abs() > threshold) {
        feedback.add(dy > 0 ? '↑ Move up / Step back' : '↓ Move down / Step closer');
      }
    }

    // Check arms
    for (final entry in angleErrors.entries) {
      if (entry.value > 25) { // More than 25 degrees off
        switch (entry.key) {
          case 'leftElbow':
            feedback.add('Adjust your left arm');
            break;
          case 'rightElbow':
            feedback.add('Adjust your right arm');
            break;
          case 'leftShoulder':
            feedback.add('Raise/lower your left arm');
            break;
          case 'rightShoulder':
            feedback.add('Raise/lower your right arm');
            break;
          case 'leftKnee':
            feedback.add('Adjust your left leg');
            break;
          case 'rightKnee':
            feedback.add('Adjust your right leg');
            break;
          case 'leftHip':
            feedback.add('Adjust your left hip angle');
            break;
          case 'rightHip':
            feedback.add('Adjust your right hip angle');
            break;
        }
      }
    }

    if (feedback.isEmpty) {
      feedback.add('Hold steady! 📸');
    }

    // Limit to top 3 most important feedback items
    return feedback.take(3).toList();
  }
}
