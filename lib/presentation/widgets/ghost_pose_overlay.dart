import 'package:flutter/material.dart';
import 'package:google_mlkit_commons/google_mlkit_commons.dart';
import '../../data/models/pose_template.dart';
import 'silhouette_painter.dart';

/// Draws a high-end glowing silhouette reference pose (ghost) on screen
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
    // Determine canvas size for point scaling
    final size = MediaQuery.of(context).size;
    final paddingX = size.width * 0.15;
    final paddingY = size.height * 0.1;
    final drawWidth = size.width - paddingX * 2;
    final drawHeight = size.height - paddingY * 2;

    List<Offset> scaledPoints = template.keypoints.map((kp) {
      double x = paddingX + kp['x']! * drawWidth;
      double y = paddingY + kp['y']! * drawHeight;
      if (isFrontCamera) x = size.width - x;
      return Offset(x, y);
    }).toList();

    return CustomPaint(
      painter: SilhouettePainter(
        points: scaledPoints,
      ),
    );
  }
}

