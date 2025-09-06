import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:perfect_freehand/perfect_freehand.dart';

class StrokeDrawer extends StatelessWidget {
  const StrokeDrawer({
    super.key,
    required this.strokes,
  });

  final Map<List<PointVector>, List<Offset>> strokes;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _StrokePainter(strokes),
    );
  }
}

class _StrokePainter extends CustomPainter {
  _StrokePainter(this.strokes);

  final Map<List<PointVector>, List<Offset>> strokes;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()..color = Colors.white,
    );

    const strokeColors = [
      Color.fromARGB(255, 255, 0, 0),
      Color.fromARGB(255, 0, 255, 0),
      Color.fromARGB(255, 0, 0, 255),
    ];
    const fillColor = Color.fromARGB(128, 0, 0, 0);
    const inputColor = Color.fromARGB(128, 255, 255, 255);

    var i = -1;
    for (final inputPoints in strokes.keys) {
      final outlinePoints = strokes[inputPoints]!;

      // Draw fill
      canvas.drawPath(
        Path()..addPolygon(outlinePoints, true),
        Paint()..color = fillColor,
      );

      // Draw outline points as stroke
      final strokeColor =
          strokeColors[++i % strokeColors.length].withValues(alpha: 0.3);
      canvas.drawPoints(
        PointMode.lines,
        [
          for (int i = 1; i < outlinePoints.length; i++) ...[
            outlinePoints[i - 1],
            outlinePoints[i],
          ],
        ],
        Paint()
          ..color = strokeColor
          ..strokeWidth = 0.5,
      );

      // Draw input points
      canvas.drawPoints(
        PointMode.points,
        inputPoints,
        Paint()
          ..color = inputColor
          ..strokeWidth = 3,
      );
    }
  }

  @override
  bool shouldRepaint(_StrokePainter oldDelegate) => true;
}
