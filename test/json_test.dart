import 'package:flutter_test/flutter_test.dart';
import 'package:perfect_freehand/perfect_freehand.dart';

final _options = StrokeOptions(
  size: 50,
  thinning: 0.8,
  smoothing: 0.7,
  streamline: 0.6,
  start: StrokeEndOptions.start(
    cap: false,
    taperEnabled: true,
  ),
  end: StrokeEndOptions.end(
    cap: true,
    taperEnabled: true,
    customTaper: 10,
  ),
  simulatePressure: false,
  isComplete: true,
);
final _optionsJson = <String, dynamic>{
  's': 50.0,
  't': 0.8,
  'sm': 0.7,
  'sl': 0.6,
  'ts': -1.0,
  'te': 10.0,
  'cs': false,
  'sp': false,
};

void main() {
  group('JSON methods', () {
    test('toJson', () {
      expect(_options.toJson(), _optionsJson);
    });
    test('fromJson', () {
      expect(StrokeOptions.fromJson(_optionsJson), _options);
    });
  });
}
