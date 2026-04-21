import '../data/models/pose_template.dart';
import '../data/repositories/template_repository.dart';

/// Engine that ranks and suggests poses based on selected place/scene
class PlaceSuggestionEngine {
  PlaceSuggestionEngine._();

  /// Get suggested poses for a category and place, ranked by relevance
  static List<PoseTemplate> suggest({
    required String category,
    required String placeId,
    int? limit,
  }) {
    final templates = TemplateRepository.byCategoryAndPlace(category, placeId);

    if (limit != null && templates.length > limit) {
      return templates.sublist(0, limit);
    }

    return templates;
  }

  /// Get the top N suggested poses across all categories for a place
  static List<PoseTemplate> suggestAll({
    required String placeId,
    int limit = 10,
  }) {
    final allTemplates = TemplateRepository.all;

    // Sort by place compatibility
    final sorted = List<PoseTemplate>.from(allTemplates)
      ..sort((a, b) {
        final scoreA = a.placeScore(placeId);
        final scoreB = b.placeScore(placeId);
        if (scoreA != scoreB) return scoreB.compareTo(scoreA);
        return a.difficultySortOrder.compareTo(b.difficultySortOrder);
      });

    return sorted.take(limit).toList();
  }

  /// Get count of suggested poses for each place in a category
  static Map<String, int> placeCountsForCategory(String category) {
    final templates = TemplateRepository.byCategory(category);
    final counts = <String, int>{};

    final placeIds = ['any', 'beach', 'park', 'urban', 'indoor', 'cafe', 'mountain', 'sunset', 'event', 'steps'];
    for (final placeId in placeIds) {
      if (placeId == 'any') {
        counts[placeId] = templates.length;
      } else {
        counts[placeId] = templates.where((t) => t.isCompatibleWith(placeId)).length;
      }
    }

    return counts;
  }
}
