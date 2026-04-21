import 'package:flutter/material.dart';

/// Painter that draws a smooth, neon-white silhouette outline of a person
/// This replaces the standard dotted skeleton for a professional "AI Guide" look.
class SilhouettePainter extends CustomPainter {
  final List<Offset> points;
  final bool isMatched;

  SilhouettePainter({
    required this.points,
    this.isMatched = false,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (points.length < 33) return;

    final Color primaryColor = isMatched ? Colors.greenAccent : Colors.white;
    
    // Paint styles
    final glowPaint = Paint()
      ..color = primaryColor.withOpacity(0.3)
      ..strokeWidth = 24.0
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);

    final outlinePaint = Paint()
      ..color = primaryColor.withOpacity(0.8)
      ..strokeWidth = 8.0
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;

    // 1. Draw Head (Blob around nose/ears)
    final nose = points[0];
    final leftEar = points[7];
    final rightEar = points[8];
    canvas.drawCircle(nose, 30, glowPaint);
    canvas.drawCircle(nose, 30, outlinePaint);

    // 2. Draw Body Path
    final path = Path();
    
    // Left Arm
    path.moveTo(points[11].dx, points[11].dy); // Shoulder
    path.lineTo(points[13].dx, points[13].dy); // Elbow
    path.lineTo(points[15].dx, points[15].dy); // Wrist

    // Torso Side Left
    path.moveTo(points[11].dx, points[11].dy);
    path.lineTo(points[23].dx, points[23].dy); // Hip

    // Right Arm
    path.moveTo(points[12].dx, points[12].dy); 
    path.lineTo(points[14].dx, points[14].dy); 
    path.lineTo(points[16].dx, points[16].dy);

    // Torso Side Right
    path.moveTo(points[12].dx, points[12].dy);
    path.lineTo(points[24].dx, points[24].dy);

    // Shoulders
    path.moveTo(points[11].dx, points[11].dy);
    path.lineTo(points[12].dx, points[12].dy);
    
    // Hips
    path.moveTo(points[23].dx, points[23].dy);
    path.lineTo(points[24].dx, points[24].dy);

    // Left Leg
    path.moveTo(points[23].dx, points[23].dy);
    path.lineTo(points[25].dx, points[25].dy); // Knee
    path.lineTo(points[27].dx, points[27].dy); // Ankle

    // Right Leg
    path.moveTo(points[24].dx, points[24].dy);
    path.lineTo(points[26].dx, points[26].dy);
    path.lineTo(points[28].dx, points[28].dy);

    canvas.drawPath(path, glowPaint);
    canvas.drawPath(path, outlinePaint);

    // 3. Draw Floating "AI Tips" (Simulated markers)
    _drawMarker(canvas, points[15], "Wrist Target");
    _drawMarker(canvas, points[27], "Step Here");
  }

  void _drawMarker(Canvas canvas, Offset p, String text) {
     final textPainter = TextPainter(
       text: TextSpan(
         text: text,
         style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold, backgroundColor: Colors.black26),
       ),
       textDirection: TextDirection.ltr,
     );
     textPainter.layout();
     textPainter.paint(canvas, Offset(p.dx + 10, p.dy - 10));
  }

  @override
  bool shouldRepaint(SilhouettePainter oldDelegate) => true;
}
