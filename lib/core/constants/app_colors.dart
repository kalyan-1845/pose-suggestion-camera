import 'package:flutter/material.dart';

/// Premium dark-mode color palette for the Pose AI Camera app
class AppColors {
  AppColors._();

  // ── Primary palette ──
  static const Color background = Color(0xFF0A0E21);
  static const Color surface = Color(0xFF1A1F36);
  static const Color surfaceLight = Color(0xFF252A42);
  static const Color card = Color(0xFF1E2340);

  // ── Accent colors ──
  static const Color accentCyan = Color(0xFF00E5FF);
  static const Color accentPurple = Color(0xFFBB86FC);
  static const Color accentPink = Color(0xFFFF6090);
  static const Color accentGreen = Color(0xFF00E676);
  static const Color accentAmber = Color(0xFFFFD740);
  static const Color accentRed = Color(0xFFFF5252);

  // ── Text colors ──
  static const Color textPrimary = Color(0xFFF5F5F5);
  static const Color textSecondary = Color(0xFFB0B3C5);
  static const Color textMuted = Color(0xFF6C7293);

  // ── Gradients ──
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF00E5FF), Color(0xFFBB86FC)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient pinkPurpleGradient = LinearGradient(
    colors: [Color(0xFFFF6090), Color(0xFFBB86FC)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient greenCyanGradient = LinearGradient(
    colors: [Color(0xFF00E676), Color(0xFF00E5FF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient sunsetGradient = LinearGradient(
    colors: [Color(0xFFFF6090), Color(0xFFFFD740)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // ── Glassmorphism ──
  static Color glassWhite = Colors.white.withOpacity(0.08);
  static Color glassBorder = Colors.white.withOpacity(0.15);

  // ── Score colors ──
  static Color scoreColor(double score) {
    if (score >= 85) return accentGreen;
    if (score >= 50) return accentAmber;
    return accentRed;
  }

  // ── Mode gradients ──
  static const List<LinearGradient> modeGradients = [
    LinearGradient(colors: [Color(0xFF00E5FF), Color(0xFF0077FF)]),  // Solo
    LinearGradient(colors: [Color(0xFFFF6090), Color(0xFFBB86FC)]),  // Couple
    LinearGradient(colors: [Color(0xFF00E676), Color(0xFF00E5FF)]),  // Friends
    LinearGradient(colors: [Color(0xFFFFD740), Color(0xFFFF6090)]),  // Family
  ];
}
