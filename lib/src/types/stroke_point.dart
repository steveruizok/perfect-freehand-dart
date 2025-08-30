import 'dart:math';

import 'package:perfect_freehand/src/types/point_vector.dart';

// This is the rate of change for simulated pressure. It could be an option.
const rateOfPressureChange = 0.275;

/// The points returned by [getStrokePoints]
/// and the input for [getStrokeOutlinePoints].
class StrokePoint {
  StrokePoint({
    required this.point,
    required void Function(double)? updatePressure,
    required this.distance,
    required this.vector,
    required this.runningLength,
  }) : _updatePressure = updatePressure;

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

  /// Simulates pressure based on the [distance] from the previous point,
  /// the previous point's pressure, and the [size] from `StrokeOptions`.
  ///
  /// This function does not mutate the [point] or its [pressure].
  /// Use [updatePressure] to update the point's pressure if needed.
  double simulatePressure(double prevPressure, double size) {
    // Speed of change - how fast should the pressure be changing?
    final sp = min(1.0, distance / size);
    // Rate of change - how much of a change is there?
    final rp = min(1.0, 1.0 - sp);
    // Accelerate the pressure
    final pressure = min(
        1.0, prevPressure + (rp - prevPressure) * (sp * rateOfPressureChange));
    return pressure;
  }
}
