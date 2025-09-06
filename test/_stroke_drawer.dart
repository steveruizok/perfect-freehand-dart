import 'dart:ui';

import 'package:flutter/material.dart';

class StrokeDrawer extends StatelessWidget {
  const StrokeDrawer({
    super.key,
    required this.strokes,
  });

  final List<List<Offset>> strokes;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _StrokePainter(strokes),
    );
  }
}

class _StrokePainter extends CustomPainter {
  _StrokePainter(this.strokes);

  final List<List<Offset>> strokes;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()..color = Colors.white,
    );

    for (final stroke in strokes) {
      canvas.drawPath(
        Path()..addPolygon(stroke, true),
        Paint()..color = Colors.black.withValues(alpha: 0.5),
      );
    }

    final strokeColors = [
      Color.fromARGB(255, 255, 0, 0),
      Color.fromARGB(255, 0, 255, 0),
      Color.fromARGB(255, 0, 0, 255),
    ];
    for (var i = 0; i < strokes.length; i++) {
      final stroke = strokes[i];
      final strokeColor = strokeColors[i % strokeColors.length];
      canvas.drawPoints(
        PointMode.lines,
        [
          for (int i = 1; i < stroke.length; i++) ...[
            stroke[i - 1],
            stroke[i],
          ],
        ],
        Paint()
          ..color = strokeColor.withValues(alpha: 0.3)
          ..strokeWidth = 0.5,
      );
    }
  }

  @override
  bool shouldRepaint(_StrokePainter oldDelegate) => true;
}
