import 'package:flutter_test/flutter_test.dart';
import 'package:perfect_freehand/src/get_stroke_radius.dart';

void main() {
  group('getStrokeRadius', () {
    group('when thinning is zero', () {
      test('uses half the size', () {
        expect(getStrokeRadius(100, 0, 0), 50);
        expect(getStrokeRadius(100, 0, 0.25), 50);
        expect(getStrokeRadius(100, 0, 0.5), 50);
        expect(getStrokeRadius(100, 0, 0.75), 50);
        expect(getStrokeRadius(100, 0, 1), 50);
      });
    });

    group('when thinning is positive', () {
      test('scales between 25% and 75% at .5 thinning', () {
        expect(getStrokeRadius(100, 0.5, 0), 25);
        expect(getStrokeRadius(100, 0.5, 0.25), 37.5);
        expect(getStrokeRadius(100, 0.5, 0.5), 50);
        expect(getStrokeRadius(100, 0.5, 0.75), 62.5);
        expect(getStrokeRadius(100, 0.5, 1), 75);
      });

      test('scales between 0% and 100% at 1 thinning', () {
        expect(getStrokeRadius(100, 1, 0), 0);
        expect(getStrokeRadius(100, 1, 0.25), 25);
        expect(getStrokeRadius(100, 1, 0.5), 50);
        expect(getStrokeRadius(100, 1, 0.75), 75);
        expect(getStrokeRadius(100, 1, 1), 100);
      });
    });

    group('when thinning is negative', () {
      test('scales between 75% and 25% at -0.5 thinning', () {
        expect(getStrokeRadius(100, -0.5, 0), 75);
        expect(getStrokeRadius(100, -0.5, 0.25), 62.5);
        expect(getStrokeRadius(100, -0.5, 0.5), 50);
        expect(getStrokeRadius(100, -0.5, 0.75), 37.5);
        expect(getStrokeRadius(100, -0.5, 1), 25);
      });

      test('scales between 100% and 0% at -1 thinning', () {
        expect(getStrokeRadius(100, -1, 0), 100);
        expect(getStrokeRadius(100, -1, 0.25), 75);
        expect(getStrokeRadius(100, -1, 0.5), 50);
        expect(getStrokeRadius(100, -1, 0.75), 25);
        expect(getStrokeRadius(100, -1, 1), 0);
      });
    });

    group('when easing is exponential', () {
      double expEasing(t) => t * t;

      test('scales between 0% and 100% at 1 thinning', () {
        expect(getStrokeRadius(100, 1, 0, expEasing), 0);
        expect(getStrokeRadius(100, 1, 0.25, expEasing), 6.25);
        expect(getStrokeRadius(100, 1, 0.5, expEasing), 25);
        expect(getStrokeRadius(100, 1, 0.75, expEasing), 56.25);
        expect(getStrokeRadius(100, 1, 1, expEasing), 100);
      });

      test('scales between 100% and 0% at -1 thinning', () {
        expect(getStrokeRadius(100, -1, 0, expEasing), 100);
        expect(getStrokeRadius(100, -1, 0.25, expEasing), 56.25);
        expect(getStrokeRadius(100, -1, 0.5, expEasing), 25);
        expect(getStrokeRadius(100, -1, 0.75, expEasing), 6.25);
        expect(getStrokeRadius(100, -1, 1, expEasing), 0);
      });
    });
  });
}
