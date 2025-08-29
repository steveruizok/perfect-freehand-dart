import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:perfect_freehand/perfect_freehand.dart';

import '_stroke_drawer.dart';
import 'example_inputs/hey.dart';
import 'example_inputs/many_points.dart';
import 'example_inputs/number_pairs.dart';
import 'example_inputs/one_point.dart';
import 'example_inputs/two_equal_points.dart';
import 'example_inputs/two_points.dart';
import 'example_inputs/with_duplicates.dart';

const _exampleInputs = {
  "one_point": onePoint,
  "two_points": twoPoints,
  "two_equal_points": twoEqualPoints,
  "with_duplicates": withDuplicates,
  "number_pairs": numberPairs,
  "many_points": manyPoints,
  "hey": hey,
};

void main() {
  group('getStroke', () {
    for (final entry in _exampleInputs.entries) {
      testWidgets('gets stroke from ${entry.key}', (tester) async {
        tester.view.physicalSize = const Size(4000, 2000);
        addTearDown(tester.view.resetPhysicalSize);

        final stroke = getStroke(entry.value);

        expect(stroke.any((offset) {
          return offset.dx.isNaN || offset.dy.isNaN;
        }), false, reason: 'stroke contains NaNs');

        await tester.pumpWidget(Padding(
          padding: const EdgeInsets.all(8),
          child: StrokeDrawer(strokes: [stroke]),
        ));

        await expectLater(
          find.byType(StrokeDrawer),
          matchesGoldenFile('example_inputs/${entry.key}.png'),
        );
      });
    }

    testWidgets('short strokes', (tester) async {
      const numStrokes = 8;
      final options = StrokeOptions(
        size: 100 / numStrokes * 0.8,
        smoothing: 0,
        streamline: 0,
        simulatePressure: false,
      );
      tester.view.physicalSize =
          const Size(100, 100) * tester.view.devicePixelRatio;
      addTearDown(tester.view.resetPhysicalSize);

      final strokes = [
        for (var i = 0.0; i <= 1.0; i += 1 / numStrokes)
          [
            PointVector(lerpDouble(5, 95, i)!, 5),
            PointVector(lerpDouble(5, 95, i)!, lerpDouble(95, 5, i)!),
          ],
      ].map((points) => getStroke(points, options: options)).toList();

      await tester.pumpWidget(StrokeDrawer(strokes: strokes));

      await expectLater(
        find.byType(StrokeDrawer),
        matchesGoldenFile('example_inputs/short_strokes.png'),
      );
    });

    testWidgets('L shapes', (tester) async {
      const numStrokes = 8;
      final options = StrokeOptions(
        size: 100 / numStrokes * 0.8,
        smoothing: 0,
        streamline: 0,
        simulatePressure: false,
      );
      tester.view.physicalSize =
          const Size(100, 100) * tester.view.devicePixelRatio;
      addTearDown(tester.view.resetPhysicalSize);

      final strokes = [
        for (var i = 0.0; i <= 1.0; i += 1 / numStrokes)
          _interpolatePoints([
            PointVector(lerpDouble(5, 95, i)!, 5),
            PointVector(lerpDouble(5, 95, i)!, lerpDouble(95, 5, i)!),
            PointVector(95, lerpDouble(95, 5, i)!),
          ]),
      ].map((points) => getStroke(points, options: options)).toList();

      await tester.pumpWidget(StrokeDrawer(strokes: strokes));

      await expectLater(
        find.byType(StrokeDrawer),
        matchesGoldenFile('example_inputs/L_shapes.png'),
      );
    });
  });
}

List<PointVector> _interpolatePoints(List<PointVector> points) {
  final newPoints = <PointVector>[];
  for (int i = 0; i < points.length - 1; ++i) {
    final firstPoint = points[i];
    final secondPoint = points[i + 1];
    for (double t = 0; t <= 1; t += 1 / 32) {
      newPoints.add(PointVector(
        lerpDouble(firstPoint.x, secondPoint.x, t)!,
        lerpDouble(firstPoint.y, secondPoint.y, t)!,
      ));
    }
  }
  return newPoints;
}
