import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

/// Small badge showing difficulty level: Easy (green), Medium (amber), Hard (red)
class DifficultyBadge extends StatelessWidget {
  final String difficulty;

  const DifficultyBadge({super.key, required this.difficulty});

  Color get _color {
    switch (difficulty) {
      case 'easy':
        return AppColors.accentGreen;
      case 'medium':
        return AppColors.accentAmber;
      case 'hard':
        return AppColors.accentRed;
      default:
        return AppColors.textMuted;
    }
  }

  String get _label {
    switch (difficulty) {
      case 'easy':
        return 'Easy';
      case 'medium':
        return 'Medium';
      case 'hard':
        return 'Hard';
      default:
        return difficulty;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: _color.withOpacity(0.15),
        border: Border.all(color: _color.withOpacity(0.4), width: 1),
      ),
      child: Text(
        _label,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: _color,
        ),
      ),
    );
  }
}
