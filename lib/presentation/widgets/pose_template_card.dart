import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../data/models/pose_template.dart';
import 'difficulty_badge.dart';

/// Card for displaying a pose template in the selection grid
class PoseTemplateCard extends StatelessWidget {
  final PoseTemplate template;
  final bool isSuggested;
  final VoidCallback onTap;

  const PoseTemplateCard({
    super.key,
    required this.template,
    required this.isSuggested,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: isSuggested
              ? AppColors.accentAmber.withOpacity(0.08)
              : AppColors.card,
          border: Border.all(
            color: isSuggested
                ? AppColors.accentAmber.withOpacity(0.3)
                : AppColors.glassBorder,
            width: 1,
          ),
        ),
        child: Row(
          children: [
            // Emoji avatar
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                color: AppColors.surfaceLight,
              ),
              child: Center(
                child: Text(
                  template.emoji,
                  style: const TextStyle(fontSize: 26),
                ),
              ),
            ),
            const SizedBox(width: 14),
            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          template.name,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                      DifficultyBadge(difficulty: template.difficulty),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    template.instruction,
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textMuted,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  // Place tags
                  Wrap(
                    spacing: 6,
                    children: template.placeTags.take(3).map((tag) {
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(6),
                          color: AppColors.surface,
                        ),
                        child: Text(
                          tag,
                          style: TextStyle(
                            fontSize: 10,
                            color: AppColors.textMuted,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: AppColors.textMuted,
            ),
          ],
        ),
      ),
    );
  }
}
