/// Represents a predefined pose template with keypoints and metadata
class PoseTemplate {
  final String id;
  final String name;
  final String category;          // 'solo', 'couple', 'friends', 'family'
  final int personCount;
  final String difficulty;        // 'easy', 'medium', 'hard'
  final List<String> placeTags;   // ['beach', 'park', 'urban', 'any']
  final String instruction;       // User-facing instruction
  final String emoji;             // Visual emoji for the pose
  final List<Map<String, double>> keypoints; // 33 normalized keypoints {x, y}
  final Map<String, double> keyAngles;       // Key joint angles for matching

  const PoseTemplate({
    required this.id,
    required this.name,
    required this.category,
    required this.personCount,
    required this.difficulty,
    required this.placeTags,
    required this.instruction,
    required this.emoji,
    required this.keypoints,
    required this.keyAngles,
  });

  /// Check if this pose is compatible with a given place
  bool isCompatibleWith(String placeId) {
    if (placeId == 'any') return true;
    return placeTags.contains(placeId) || placeTags.contains('any');
  }

  /// Get compatibility score for a place (higher = better match)
  double placeScore(String placeId) {
    if (placeId == 'any') return 1.0;
    if (placeTags.contains(placeId)) return 1.0;
    if (placeTags.contains('any')) return 0.7;
    return 0.3;
  }

  /// Get difficulty sort order
  int get difficultySortOrder {
    switch (difficulty) {
      case 'easy':
        return 0;
      case 'medium':
        return 1;
      case 'hard':
        return 2;
      default:
        return 0;
    }
  }
}
