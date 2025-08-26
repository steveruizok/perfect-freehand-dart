import 'package:flutter/material.dart';

class StrokeDrawer extends StatelessWidget {
  const StrokeDrawer({
    super.key,
    required this.stroke,
  });

  final List<Offset> stroke;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _StrokePainter(stroke),
    );
  }
}

class _StrokePainter extends CustomPainter {
  _StrokePainter(this.stroke);

  final List<Offset> stroke;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black
      ..strokeWidth = 1;

    canvas.drawPath(
      Path()
        ..addPolygon(
          stroke,
          true,
        ),
      paint,
    );
  }

  @override
  bool shouldRepaint(_StrokePainter oldDelegate) {
    return oldDelegate.stroke != stroke;
  }
}
