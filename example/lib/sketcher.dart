import 'package:flutter/material.dart';
import 'package:perfect_freehand/perfect_freehand.dart';
import 'stroke.dart';
import 'stroke_options.dart';

class Sketcher extends CustomPainter {
  final List<Stroke> lines;
  final StrokeOptions options;

  Sketcher({required this.lines, required this.options});

  // Paint a line on the canvas
  void paintLine(Stroke line, Canvas canvas, Paint paint) {
    final path = Path();

    if (line.points.isEmpty) {
      return;
    } else if (line.points.length < 2) {
      // If the path only has one line, draw a dot.
      path.addOval(Rect.fromCircle(
          center: Offset(line.points[0].x, line.points[0].y), radius: 1));
    } else {
      // Otherwise, draw a line that connects each point with a curve.
      path.moveTo(line.points[0].x, line.points[0].y);

      for (int i = 1; i < line.points.length - 1; ++i) {
        final p0 = line.points[i];
        final p1 = line.points[i + 1];
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
      line = Stroke(getStroke(
        line.points,
        size: options.size,
        thinning: options.thinning,
        smoothing: options.smoothing,
        streamline: options.streamline,
        taperStart: options.taperStart,
        capStart: options.capStart,
        taperEnd: options.taperEnd,
        capEnd: options.capEnd,
        simulatePressure: options.simulatePressure,
        isComplete: options.isComplete,
      ));

      // Paint the line
      paintLine(line, canvas, paint);
    }
  }

  @override
  bool shouldRepaint(Sketcher oldDelegate) {
    return true;
  }
}
