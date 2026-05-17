import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import '../../data/models/pose_match_result.dart';
import '../../data/models/pose_template.dart';

class SkeletonPainter extends CustomPainter {
  final Pose pose;
  final Size imageSize;
  final InputImageRotation rotation;
  final PoseMatchResult matchResult;
  final bool isFrontCamera;
  final PoseTemplate template;
  final Color accentColor;

  SkeletonPainter({
    required this.pose,
    required this.imageSize,
    required this.rotation,
    required this.matchResult,
    required this.isFrontCamera,
    required this.template,
    this.accentColor = const Color(0xFF00E5FF),
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (pose.landmarks.isEmpty) return;

    // Scale template points (mirroring GhostPoseOverlay coordinate layout)
    final paddingX = size.width * 0.15;
    final paddingY = size.height * 0.1;
    final drawWidth = size.width - paddingX * 2;
    final drawHeight = size.height - paddingY * 2;

    // Key joints we want to check and provide corrective compasses for
    final List<int> keyJointIndices = [15, 16, 13, 14, 25, 26]; // Wrists, Elbows, Knees
    final Map<int, String> jointNames = {
      15: "Left Hand",
      16: "Right Hand",
      13: "Left Elbow",
      14: "Right Elbow",
      25: "Left Knee",
      26: "Right Knee",
    };

    for (final index in keyJointIndices) {
      final targetJoint = template.keypoints.firstWhere((kp) => kp['index'] == index);
      final landmark = pose.landmarks[PoseLandmarkType.values[index]];
      if (landmark == null) continue;

      // Scale template target position
      double targetX = paddingX + targetJoint['x']! * drawWidth;
      double targetY = paddingY + targetJoint['y']! * drawHeight;
      if (isFrontCamera) targetX = size.width - targetX;
      final targetPos = Offset(targetX, targetY);

      // Live user joint position scaled from camera coordinate space
      final currentPos = _translatePoint(landmark.x, landmark.y, size);

      final distance = (currentPos - targetPos).distance;

      if (distance > 45.0) {
        // Mismatched Joint - Draw floating Neon Compass corrective arrow!
        final Color arrowColor = distance > 110 
            ? Colors.redAccent 
            : (distance > 70 ? Colors.orangeAccent : accentColor);

        final arrowPaint = Paint()
          ..color = arrowColor.withOpacity(0.8)
          ..strokeWidth = 3.0
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round;

        final glowPaint = Paint()
          ..color = arrowColor.withOpacity(0.25)
          ..strokeWidth = 10.0
          ..style = PaintingStyle.stroke
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);

        // Draw dotted/dashed line connecting current position to target position
        _drawDashedLine(canvas, currentPos, targetPos, arrowPaint, glowPaint);

        // Draw Target Pointer (Mini Arrowhead pointing to where they need to go)
        _drawArrowhead(canvas, currentPos, targetPos, arrowColor);

        // Draw a small floating text tag near the current position to tell them what joint needs adjustment
        _drawJointText(canvas, currentPos, jointNames[index]!, arrowColor);
      } else {
        // Perfectly Aligned Joint! Draw a pulsing glowing green circle
        final alignedPaint = Paint()
          ..color = Colors.greenAccent.withOpacity(0.8)
          ..strokeWidth = 2.5
          ..style = PaintingStyle.stroke;

        final alignedGlow = Paint()
          ..color = Colors.greenAccent.withOpacity(0.3)
          ..strokeWidth = 10.0
          ..style = PaintingStyle.stroke
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);

        canvas.drawCircle(currentPos, 14.0, alignedGlow);
        canvas.drawCircle(currentPos, 14.0, alignedPaint);
        
        // Draw inner lock dot
        canvas.drawCircle(currentPos, 4.0, Paint()..color = Colors.greenAccent);
      }
    }
  }

  void _drawDashedLine(Canvas canvas, Offset p1, Offset p2, Paint paint, Paint glow) {
    const dashWidth = 8.0;
    const dashSpace = 6.0;
    
    final distance = (p2 - p1).distance;
    final dx = (p2.dx - p1.dx) / distance;
    final dy = (p2.dy - p1.dy) / distance;
    
    double start = 0.0;
    while (start < distance) {
      final x1 = p1.dx + dx * start;
      final y1 = p1.dy + dy * start;
      
      final end = math.min(start + dashWidth, distance);
      final x2 = p1.dx + dx * end;
      final y2 = p1.dy + dy * end;
      
      canvas.drawLine(Offset(x1, y1), Offset(x2, y2), glow);
      canvas.drawLine(Offset(x1, y1), Offset(x2, y2), paint);
      
      start += dashWidth + dashSpace;
    }
  }

  void _drawArrowhead(Canvas canvas, Offset current, Offset target, Color color) {
    final direction = target - current;
    final angle = math.atan2(direction.dy, direction.dx);
    const arrowSize = 10.0;

    final path = Path();
    path.moveTo(target.dx, target.dy);
    path.lineTo(
      target.dx - arrowSize * math.cos(angle - math.pi / 6),
      target.dy - arrowSize * math.sin(angle - math.pi / 6),
    );
    path.lineTo(
      target.dx - arrowSize * math.cos(angle + math.pi / 6),
      target.dy - arrowSize * math.sin(angle + math.pi / 6),
    );
    path.close();

    final fillPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    canvas.drawPath(path, fillPaint);
  }

  void _drawJointText(Canvas canvas, Offset pos, String name, Color color) {
     final textPainter = TextPainter(
       text: TextSpan(
         text: name,
         style: TextStyle(
           color: color, 
           fontSize: 8.5, 
           fontWeight: FontWeight.bold,
           backgroundColor: Colors.black.withOpacity(0.55),
         ),
       ),
       textDirection: TextDirection.ltr,
     );
     textPainter.layout();
     textPainter.paint(canvas, Offset(pos.dx + 12, pos.dy - 12));
  }

  Offset _translatePoint(double x, double y, Size canvasSize) {
    double translatedX = x;
    double translatedY = y;

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

    if (isFrontCamera) {
      translatedX = canvasSize.width - translatedX;
    }

    return Offset(translatedX, translatedY);
  }

  @override
  bool shouldRepaint(SkeletonPainter oldDelegate) => true;
}
