import 'package:flutter_test/flutter_test.dart';
import 'package:perfect_freehand/src/get_stroke_radius.dart';

void main() {
  i(double t) => t;

  group('getStrokeRadius', () {
    group('when thinning is zero', () {
      test('uses half the size', () {
        expect(getStrokeRadius(100, 0, 0, i), 50);
        expect(getStrokeRadius(100, 0, 0.25, i), 50);
        expect(getStrokeRadius(100, 0, 0.5, i), 50);
        expect(getStrokeRadius(100, 0, 0.75, i), 50);
        expect(getStrokeRadius(100, 0, 1, i), 50);
      });
    });

    group('when thinning is positive', () {
      test('scales between 25% and 75% at .5 thinning', () {
        expect(getStrokeRadius(100, 0.5, 0, i), 25);
        expect(getStrokeRadius(100, 0.5, 0.25, i), 37.5);
        expect(getStrokeRadius(100, 0.5, 0.5, i), 50);
        expect(getStrokeRadius(100, 0.5, 0.75, i), 62.5);
        expect(getStrokeRadius(100, 0.5, 1, i), 75);
      });

      test('scales between 0% and 100% at 1 thinning', () {
        expect(getStrokeRadius(100, 1, 0, i), 0);
        expect(getStrokeRadius(100, 1, 0.25, i), 25);
        expect(getStrokeRadius(100, 1, 0.5, i), 50);
        expect(getStrokeRadius(100, 1, 0.75, i), 75);
        expect(getStrokeRadius(100, 1, 1, i), 100);
      });
    });

    group('when thinning is negative', () {
      test('scales between 75% and 25% at -0.5 thinning', () {
        expect(getStrokeRadius(100, -0.5, 0, i), 75);
        expect(getStrokeRadius(100, -0.5, 0.25, i), 62.5);
        expect(getStrokeRadius(100, -0.5, 0.5, i), 50);
        expect(getStrokeRadius(100, -0.5, 0.75, i), 37.5);
        expect(getStrokeRadius(100, -0.5, 1, i), 25);
      });

      test('scales between 100% and 0% at -1 thinning', () {
        expect(getStrokeRadius(100, -1, 0, i), 100);
        expect(getStrokeRadius(100, -1, 0.25, i), 75);
        expect(getStrokeRadius(100, -1, 0.5, i), 50);
        expect(getStrokeRadius(100, -1, 0.75, i), 25);
        expect(getStrokeRadius(100, -1, 1, i), 0);
      });
    });
  });
}
