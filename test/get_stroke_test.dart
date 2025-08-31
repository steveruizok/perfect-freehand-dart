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
      // Abrupt changes in direction at the end of the line need special
      // attention. We use a full circle for the end cap to hide the corners.

      final options = StrokeOptions(
        size: 10,
        smoothing: 0,
        streamline: 0,
        simulatePressure: false,
      );
      tester.view.physicalSize =
          const Size(100, 100) * tester.view.devicePixelRatio;
      addTearDown(tester.view.resetPhysicalSize);

      final strokes = [
        [PointVector(5, 5), PointVector(5, 95), PointVector(6, 95)],
        [PointVector(95, 5), PointVector(95, 95), PointVector(94, 95)],
      ].map((points) => getStroke(points, options: options)).toList();

      await tester.pumpWidget(StrokeDrawer(strokes: strokes));

      await expectLater(
        find.byType(StrokeDrawer),
        matchesGoldenFile('example_inputs/L_shapes.png'),
      );
    });

    testWidgets('Sharp corners', (tester) async {
      final options = StrokeOptions(
        size: 10,
        smoothing: 0,
        streamline: 0,
        simulatePressure: false,
      );
      tester.view.physicalSize =
          const Size(100, 100) * tester.view.devicePixelRatio;
      addTearDown(tester.view.resetPhysicalSize);

      final rawStrokes = [
        // very accute
        [PointVector(5, 5), PointVector(5, 45), PointVector(10, 40)],
        // slightly accute
        [PointVector(25, 5), PointVector(25, 45), PointVector(35, 40)],
        // right angle
        [PointVector(45, 5), PointVector(45, 45), PointVector(55, 45)],
        // slightly obtuse
        [PointVector(65, 5), PointVector(65, 45), PointVector(75, 55)],
        // very obtuse
        [PointVector(90, 5), PointVector(90, 45), PointVector(95, 55)],
      ];

      // Mirror strokes so left turns and right turns are both tested.
      final unmirroredLength = rawStrokes.length;
      for (var i = 0; i < unmirroredLength; i++) {
        rawStrokes.add(
          rawStrokes[i].map((p) => PointVector(p.dx, 120 - p.dy)).toList(),
        );
      }

      final strokes = rawStrokes
          .map((points) => getStroke(points, options: options))
          .toList();

      await tester.pumpWidget(StrokeDrawer(strokes: strokes));

      await expectLater(
        find.byType(StrokeDrawer),
        matchesGoldenFile('example_inputs/sharp_corners.png'),
      );
    });
  });
}
