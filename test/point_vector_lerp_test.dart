import 'package:flutter_test/flutter_test.dart';
import 'package:perfect_freehand/perfect_freehand.dart';

void main() {
  group('PointVector.lerp', () {
    test('between two normal points', () {
      final p1 = PointVector(10, 100, 0.1);
      final p2 = PointVector(20, 200, 0.2);
      final result = p1.lerp(0.4, p2);
      expect(result.x, 14);
      expect(result.y, 140);
      expect(result.pressure, 0.14);
    });

    test('with NaN p1', () {
      final p1 = PointVector(double.nan, 100, 0.1);
      final p2 = PointVector(20, 200, 0.2);
      final result = p1.lerp(0.4, p2);
      expect(result, p2);
    });

    test('with NaN p2', () {
      final p1 = PointVector(10, 100, 0.1);
      final p2 = PointVector(double.nan, 200, 0.2);
      final result = p1.lerp(0.4, p2);
      expect(result, p1);
    });

    test('with both NaN points', () {
      final p1 = PointVector(double.nan, 100, 0.1);
      final p2 = PointVector(double.nan, 200, 0.2);
      final result = p1.lerp(0.4, p2);
      expect(result.x, isNaN);
      expect(result.y, anyOf(p1.y, p2.y),
          reason: 'Does not matter since both points are invalid');
      expect(result.pressure, anyOf(p1.pressure, p2.pressure),
          reason: 'Does not matter since both points are invalid');
    });

    test('with null p1 pressure', () {
      final p1 = PointVector(10, 100, null);
      final p2 = PointVector(20, 200, 0.3);
      final result = p1.lerp(0.4, p2);
      expect(result.pressure, 0.3, reason: 'Should use the non-null pressure');
    });

    test('with null p2 pressure', () {
      final p1 = PointVector(10, 100, 0.5);
      final p2 = PointVector(20, 200, null);
      final result = p1.lerp(0.4, p2);
      expect(result.pressure, 0.5, reason: 'Should use the non-null pressure');
    });

    test('with both null pressure', () {
      final p1 = PointVector(10, 100, null);
      final p2 = PointVector(20, 200, null);
      final result = p1.lerp(0.4, p2);
      expect(result.pressure, null);
    });
  });
}
