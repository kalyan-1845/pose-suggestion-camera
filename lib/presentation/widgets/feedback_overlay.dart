import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

/// Animated overlay showing directional feedback instructions
class FeedbackOverlay extends StatelessWidget {
  final List<String> feedback;
  final String scoreLabel;

  const FeedbackOverlay({
    super.key,
    required this.feedback,
    required this.scoreLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Score label
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: Text(
            scoreLabel,
            key: ValueKey(scoreLabel),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: 8),
        // Feedback messages
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.6),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppColors.accentCyan.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 400),
            child: Column(
              key: ValueKey(feedback.join()),
              mainAxisSize: MainAxisSize.min,
              children: feedback.map((msg) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Text(
                  msg,
                  style: const TextStyle(
                    color: AppColors.accentCyan,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
              )).toList(),
            ),
          ),
        ),
      ],
    );
  }
}
