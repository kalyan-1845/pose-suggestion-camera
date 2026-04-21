import '../models/pose_template.dart';
import '../templates/solo_templates.dart';
import '../templates/couple_templates.dart';
import '../templates/friends_templates.dart';
import '../templates/family_templates.dart';

/// Repository that manages all 50 pose templates with filtering and ranking
class TemplateRepository {
  TemplateRepository._();

  static final List<PoseTemplate> _allTemplates = [
    ...SoloTemplates.all,
    ...CoupleTemplates.all,
    ...FriendsTemplates.all,
    ...FamilyTemplates.all,
  ];

  /// Get all 50 templates
  static List<PoseTemplate> get all => _allTemplates;

  /// Get templates by category
  static List<PoseTemplate> byCategory(String category) {
    return _allTemplates.where((t) => t.category == category).toList();
  }

  /// Get templates by category and place, sorted by relevance
  static List<PoseTemplate> byCategoryAndPlace(String category, String placeId) {
    final templates = byCategory(category);

    if (placeId == 'any') {
      // Sort by difficulty (easy first)
      templates.sort((a, b) => a.difficultySortOrder.compareTo(b.difficultySortOrder));
      return templates;
    }

    // Sort by place compatibility (best match first), then by difficulty
    templates.sort((a, b) {
      final scoreA = a.placeScore(placeId);
      final scoreB = b.placeScore(placeId);
      if (scoreA != scoreB) return scoreB.compareTo(scoreA); // Higher score first
      return a.difficultySortOrder.compareTo(b.difficultySortOrder);
    });

    return templates;
  }

  /// Get a template by ID
  static PoseTemplate? getById(String id) {
    try {
      return _allTemplates.firstWhere((t) => t.id == id);
    } catch (_) {
      return null;
    }
  }

  /// Get category counts
  static Map<String, int> get categoryCounts => {
    'solo': SoloTemplates.all.length,
    'couple': CoupleTemplates.all.length,
    'friends': FriendsTemplates.all.length,
    'family': FamilyTemplates.all.length,
  };

  /// Get count of poses compatible with a place in a category
  static int countByPlace(String category, String placeId) {
    if (placeId == 'any') return byCategory(category).length;
    return byCategory(category)
        .where((t) => t.isCompatibleWith(placeId))
        .length;
  }

  /// Search templates by name
  static List<PoseTemplate> search(String query) {
    final lowerQuery = query.toLowerCase();
    return _allTemplates
        .where((t) => t.name.toLowerCase().contains(lowerQuery))
        .toList();
  }
}
