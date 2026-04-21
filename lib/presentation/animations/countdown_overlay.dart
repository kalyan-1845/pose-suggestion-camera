import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

/// Large countdown overlay (3-2-1) shown before auto-capture
class CountdownOverlay extends StatelessWidget {
  final int value;

  const CountdownOverlay({super.key, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black.withOpacity(0.3),
      child: Center(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          transitionBuilder: (child, animation) {
            return ScaleTransition(
              scale: animation,
              child: FadeTransition(opacity: animation, child: child),
            );
          },
          child: value > 0
              ? Text(
                  '$value',
                  key: ValueKey(value),
                  style: TextStyle(
                    fontSize: 120,
                    fontWeight: FontWeight.w900,
                    color: AppColors.accentCyan,
                    shadows: [
                      Shadow(
                        color: AppColors.accentCyan.withOpacity(0.5),
                        blurRadius: 40,
                      ),
                    ],
                  ),
                )
              : Icon(
                  Icons.camera,
                  key: const ValueKey('camera'),
                  size: 80,
                  color: AppColors.accentGreen,
                ),
        ),
      ),
    );
  }
}
