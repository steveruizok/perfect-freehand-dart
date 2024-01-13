import 'package:perfect_freehand/src/types/point_vector.dart';

/// The points returned by [getStrokePoints]
/// and the input for [getStrokeOutlinePoints].
class StrokePoint {
  /// The adjusted point.
  PointVector point;

  /// The [point]'s pressure, or 0.5 if null.
  double get pressure => point.pressure ?? 0.5;

  /// A function to update the pressure of the point.
  /// Used in [updatePressure].
  final void Function(double)? _updatePressure;

  /// Update the pressure of the point.
  void updatePressure(double pressure) {
    point = point.copyWith(pressure: pressure);
    _updatePressure?.call(pressure);
  }

  /// The distance between the current point and the previous point.
  final double distance;

  /// The vector from the current point to the previous point.
  PointVector vector;

  /// The total distance so far.
  final double runningLength;

  StrokePoint({
    required this.point,
    required void Function(double)? updatePressure,
    required this.distance,
    required this.vector,
    required this.runningLength,
  }) : _updatePressure = updatePressure;
}
