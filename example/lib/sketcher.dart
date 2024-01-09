import 'package:flutter/material.dart';
import 'package:perfect_freehand/perfect_freehand.dart';
import 'stroke.dart';

class Sketcher extends CustomPainter {
  final List<Stroke> lines;
  final StrokeOptions options;

  Sketcher({required this.lines, required this.options});

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()..color = Colors.black;

    for (int i = 0; i < lines.length; ++i) {
      final outlinePoints = getStroke(
        lines[i].points,
        options,
      );

      final path = Path();

      if (outlinePoints.isEmpty) {
        return;
      } else if (outlinePoints.length < 2) {
        // If the path only has one line, draw a dot.
        path.addOval(Rect.fromCircle(
            center: outlinePoints[0], radius: 1));
      } else {
        // Otherwise, draw a line that connects each point with a curve.
        path.moveTo(outlinePoints[0].dx, outlinePoints[0].dy);

        for (int i = 1; i < outlinePoints.length - 1; ++i) {
          final p0 = outlinePoints[i];
          final p1 = outlinePoints[i + 1];
          path.quadraticBezierTo(
              p0.dx, p0.dy, (p0.dx + p1.dx) / 2, (p0.dy + p1.dy) / 2);
        }
      }

      canvas.drawPath(path, paint);
    }
    
  }

  @override
  bool shouldRepaint(Sketcher oldDelegate) {
    return true;
  }
}
