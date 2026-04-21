/// Result of comparing a live pose against a template
class PoseMatchResult {
  final double score;                       // 0.0 - 100.0
  final bool isMatched;                     // score >= threshold
  final List<String> feedback;              // Directional hints
  final Map<int, double> keypointErrors;    // Per-keypoint error values
  final Map<String, double> angleErrors;    // Per-angle error values

  const PoseMatchResult({
    required this.score,
    required this.isMatched,
    required this.feedback,
    required this.keypointErrors,
    required this.angleErrors,
  });

  /// Empty result (no pose detected)
  static const PoseMatchResult empty = PoseMatchResult(
    score: 0.0,
    isMatched: false,
    feedback: ['Stand in frame to begin'],
    keypointErrors: {},
    angleErrors: {},
  );

  /// Get the most important feedback message
  String get primaryFeedback {
    if (feedback.isEmpty) return 'Hold steady!';
    return feedback.first;
  }

  /// Get score label
  String get scoreLabel {
    if (score >= 85) return 'Perfect! 🎯';
    if (score >= 70) return 'Almost there! 🔥';
    if (score >= 50) return 'Getting close 👍';
    if (score >= 25) return 'Keep adjusting 💪';
    return 'Follow the guide 👻';
  }
}
