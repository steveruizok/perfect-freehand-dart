import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:perfect_freehand/src/get_stroke.dart';

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
          child: StrokeDrawer(stroke: stroke),
        ));

        await expectLater(
          find.byType(StrokeDrawer),
          matchesGoldenFile('example_inputs/${entry.key}.png'),
        );
      });
    }
  });
}
