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
    final paint = Paint()
      ..color = Colors.black
      ..strokeWidth = 1;

    for (final stroke in strokes) {
      canvas.drawPath(
        Path()..addPolygon(stroke, true),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_StrokePainter oldDelegate) => true;
}
