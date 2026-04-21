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
    // Intentionally empty. Skeleton line/dot rendering has been removed per pro user request.
    // The ML tracking continues silently in the background!
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
