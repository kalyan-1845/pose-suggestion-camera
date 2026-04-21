import 'package:flutter/material.dart';
import 'package:google_mlkit_commons/google_mlkit_commons.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/pose_constants.dart';
import '../../data/models/pose_template.dart';

/// Draws a semi-transparent reference pose (ghost) on screen
/// Shows the target pose the user should match
class GhostPoseOverlay extends StatelessWidget {
  final PoseTemplate template;
  final Size imageSize;
  final InputImageRotation rotation;
  final bool isFrontCamera;

  const GhostPoseOverlay({
    super.key,
    required this.template,
    required this.imageSize,
    required this.rotation,
    required this.isFrontCamera,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _GhostPainter(
        keypoints: template.keypoints,
        isFrontCamera: isFrontCamera,
      ),
    );
  }
}

class _GhostPainter extends CustomPainter {
  final List<Map<String, double>> keypoints;
  final bool isFrontCamera;

  _GhostPainter({
    required this.keypoints,
    required this.isFrontCamera,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (keypoints.length < 33) return;

    // Scale keypoints to canvas size with padding
    final paddingX = size.width * 0.15;
    final paddingY = size.height * 0.1;
    final drawWidth = size.width - paddingX * 2;
    final drawHeight = size.height - paddingY * 2;

    List<Offset> points = keypoints.map((kp) {
      double x = paddingX + kp['x']! * drawWidth;
      double y = paddingY + kp['y']! * drawHeight;

      if (isFrontCamera) {
        x = size.width - x;
      }

      return Offset(x, y);
    }).toList();

    // Paint Shape stroke style
    final linePaint = Paint()
      ..color = Colors.white.withOpacity(0.4)
      ..strokeWidth = 15.0
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    // Inner glow
    final glowPaint = Paint()
      ..color = Colors.blueAccent.withOpacity(0.15)
      ..strokeWidth = 22.0
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    // Draw skeleton connections using indices matching PoseConstants
    // Simplified connection pairs using keypoint array indices
    final connections = [
      [11, 12], // shoulders
      [11, 13], [13, 15], // left arm
      [12, 14], [14, 16], // right arm
      [11, 23], [12, 24], // torso sides
      [23, 24], // hips
      [23, 25], [25, 27], // left leg
      [24, 26], [26, 28], // right leg
    ];

    for (final conn in connections) {
      if (conn[0] < points.length && conn[1] < points.length) {
        canvas.drawLine(points[conn[0]], points[conn[1]], glowPaint);
        canvas.drawLine(points[conn[0]], points[conn[1]], linePaint);
      }
    }
  }

  @override
  bool shouldRepaint(_GhostPainter oldDelegate) => false;
}
