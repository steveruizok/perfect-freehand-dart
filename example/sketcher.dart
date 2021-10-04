import 'package:flutter/material.dart';
import 'package:perfect_freehand/perfect_freehand.dart';

class Sketcher extends CustomPainter {
  final List<Stroke> lines;
  final StrokeOptions options;

  Sketcher({required this.lines, required this.options});

  // Paint a line on the canvas
  void paintLine(Stroke line, Canvas canvas, Paint paint) {
    final path = Path();

    if (line.path.isEmpty) {
      return;
    } else if (line.path.length < 2) {
      // If the path only has one line, draw a dot.
      path.addOval(Rect.fromCircle(
          center: Offset(line.path[0].x, line.path[0].y), radius: 1));
    } else {
      // Otherwise, draw a line that connects each point with a curve.
      path.moveTo(line.path[0].x, line.path[0].y);

      for (int i = 1; i < line.path.length - 1; ++i) {
        final p0 = line.path[i];
        final p1 = line.path[i + 1];
        path.quadraticBezierTo(
            p0.x, p0.y, (p0.x + p1.x) / 2, (p0.y + p1.y) / 2);
      }
    }

    canvas.drawPath(path, paint);
  }

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = Colors.black
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 5.0;

    for (int i = 0; i < lines.length; ++i) {
      var line = lines[i];

      // Get Stroke Points

      final strokePoints = getStrokePoints(line.path, options);

      final outlinePoints = getStrokeOutlinePoints(strokePoints, options);

      line = Stroke(outlinePoints, false);

      // Paint the line
      paintLine(line, canvas, paint);
    }
  }

  @override
  bool shouldRepaint(Sketcher oldDelegate) {
    return true;
  }
}
