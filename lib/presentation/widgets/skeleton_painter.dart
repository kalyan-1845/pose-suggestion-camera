import 'package:flutter/material.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/pose_constants.dart';
import '../../data/models/pose_match_result.dart';

/// CustomPainter that draws the detected skeleton on camera preview
/// Colors keypoints green (matched) or red (mismatched) based on match result
class SkeletonPainter extends CustomPainter {
  final Pose pose;
  final Size imageSize;
  final InputImageRotation rotation;
  final PoseMatchResult matchResult;
  final bool isFrontCamera;

  SkeletonPainter({
    required this.pose,
    required this.imageSize,
    required this.rotation,
    required this.matchResult,
    required this.isFrontCamera,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // ── Draw connections (White Paint Style) ──
    final paintShapeColor = Colors.white.withOpacity(0.8);
    final glowColor = AppColors.accentCyan.withOpacity(0.4);

    for (final connection in PoseConstants.skeletonConnections) {
      final start = pose.landmarks[connection[0]];
      final end = pose.landmarks[connection[1]];

      if (start != null && end != null && start.likelihood > 0.5 && end.likelihood > 0.5) {
        final startPoint = _translatePoint(start.x, start.y, size);
        final endPoint = _translatePoint(end.x, end.y, size);

        // Draw glow effect underneath
        final glowPaint = Paint()
          ..strokeWidth = 18.0
          ..color = glowColor
          ..strokeCap = StrokeCap.round
          ..style = PaintingStyle.stroke;
        
        canvas.drawLine(startPoint, endPoint, glowPaint);

        // Draw thick white paint stroke
        final linePaint = Paint()
          ..strokeWidth = 10.0
          ..color = paintShapeColor
          ..strokeCap = StrokeCap.round
          ..style = PaintingStyle.stroke;

        canvas.drawLine(startPoint, endPoint, linePaint);
      }
    }
  }

  Offset _translatePoint(double x, double y, Size canvasSize) {
    double translatedX = x;
    double translatedY = y;

    // Scale from image coordinates to canvas coordinates
    switch (rotation) {
      case InputImageRotation.rotation90deg:
        translatedX = y * canvasSize.width / imageSize.height;
        translatedY = x * canvasSize.height / imageSize.width;
        break;
      case InputImageRotation.rotation270deg:
        translatedX = (imageSize.height - y) * canvasSize.width / imageSize.height;
        translatedY = (imageSize.width - x) * canvasSize.height / imageSize.width;
        break;
      default:
        translatedX = x * canvasSize.width / imageSize.width;
        translatedY = y * canvasSize.height / imageSize.height;
    }

    // Mirror for front camera
    if (isFrontCamera) {
      translatedX = canvasSize.width - translatedX;
    }

    return Offset(translatedX, translatedY);
  }

  @override
  bool shouldRepaint(SkeletonPainter oldDelegate) => true;
}
