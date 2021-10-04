import 'point.dart';

/// A processed point returned by `getStrokePoints`. Used as an input to `getStrokeOutlinePoints`.
class StrokePoint {
  /// The point's x and y coordinates and pressure.
  final Point point;

  // The vector between this point and the previous point.
  Point vector;

  // The distance from this point and the previous point.
  final double distance;

  // The running length of the line at this point.
  final double runningLength;

  StrokePoint(
    this.point,
    this.vector,
    this.distance,
    this.runningLength,
  );
}
