import 'package:flutter_test/flutter_test.dart';
import 'package:perfect_freehand/perfect_freehand.dart';

void main() {
  group('rememberSimulatedPressure', () {
    test('true', () {
      final points = <PointVector>[
        for (int i = 0; i < 6; ++i) const PointVector(0, 0),
        for (double i = 10; i <= 90; i += 10) PointVector(i, i),
        for (int i = 0; i < 7; ++i) const PointVector(100, 100),
      ];
      final originalStroke = getStroke(
        points,
        options: StrokeOptions(
          simulatePressure: true,
          isComplete: true,
        ),
        rememberSimulatedPressure: true,
      );
      const expectedPressures = [
        // The points at (0, 0)
        0.2206360875710297, null, null, null, null, null,

        // The points at (10, 10) - (90, 90)
        null, 0.15996116348899653, 0.13405511075513582,
        0.123598044778381, 0.11925620805156727, 0.11743276704536398,
        0.11666438883169417, 0.1163410248643386, 0.11620569325911113,

        // The points at (100, 100)
        null, null, null, null, null, null, 0.11838510316112387,
      ];
      for (var i = 0; i < points.length; i++) {
        expect(points[i].pressure, expectedPressures[i]);
      }

      // Now see if we can get roughly the same stroke back
      // using the remembered pressure.
      final rememberedStroke = getStroke(
        points.where((p) => p.pressure != null).toList(),
        options: StrokeOptions(
          simulatePressure: false,
          isComplete: true,
        ),
      );
      expect(originalStroke.length, rememberedStroke.length);
      for (var i = 0; i < originalStroke.length; i++) {
        // See if we can get roughly the same stroke back
        final originalPoint = originalStroke[i];
        final rememberedPoint = rememberedStroke[i];

        expect(
          rememberedPoint.dx,
          moreOrLessEquals(originalPoint.dx, epsilon: 0.2),
        );
      }
    });

    test('false', () {
      final points = <PointVector>[
        for (int i = 0; i < 6; ++i) const PointVector(0, 0),
        for (double i = 10; i <= 90; i += 10) PointVector(i, i),
        for (int i = 0; i < 7; ++i) const PointVector(100, 100),
      ];

      getStroke(
        points,
        options: StrokeOptions(
          simulatePressure: true,
          isComplete: true,
        ),
        rememberSimulatedPressure: false,
      );

      for (var i = 0; i < points.length; i++) {
        expect(points[i].pressure, null,
            reason: 'The pressure should not have been updated.');
      }
    });

    test('with 2 points', () {
      final points = <PointVector>[
        const PointVector(0, 0),
        const PointVector(100, 100),
      ];

      expect(
        () => getStroke(
          points,
          options: StrokeOptions(
            simulatePressure: true,
            isComplete: true,
          ),
          rememberSimulatedPressure: true,
        ),
        isNot(throwsRangeError),
        reason:
            'rememberSimulatedPressure should handle 2 points without error: '
            'see https://github.com/steveruizok/perfect-freehand-dart/pull/21',
      );

      expect(points, [
        const PointVector(0, 0, 0.3208095703125),
        const PointVector(100, 100, 0.0886337944141388),
      ]);
    });
  });
}
