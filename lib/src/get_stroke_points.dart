import 'dart:math';

import 'package:perfect_freehand/src/types/point_vector.dart';
import 'package:perfect_freehand/src/types/stroke_options.dart';
import 'package:perfect_freehand/src/types/stroke_point.dart';

/// Get an array of points as objects with
/// an adjusted point, pressure, vector, distance,
/// and runningLength.
List<StrokePoint> getStrokePoints(
  List<PointVector> points, {
  required StrokeOptions options,
}) {
  // If we don't have any points, return an empty array.
  if (points.isEmpty) return [];

  // Find the interpolation level between points.
  final t = 0.15 + (1 - options.streamline) * 0.85;

  // Clone array of points and fill in missing pressure values.
  final pts =
      points.map((p) => p.copyWith(pressure: p.pressure ?? 0.5)).toList();

  // If all points stay within the stroke's size of the first one (e.g. a tap,
  // which often drifts by a fraction of a pixel), treat them as a single
  // point with the highest pressure applied, so the dot's size reflects how
  // hard it was pressed.
  if (pts.length > 1 &&
      pts.every((p) => p.distanceTo(pts.first) <= options.size)) {
    final maxPressure =
        pts.map((p) => p.pressure!).reduce((a, b) => a > b ? a : b);
    pts
      ..removeRange(1, pts.length)
      ..[0] = pts.first.copyWith(pressure: maxPressure);
  }

  // Add extra points between the two, to help avoid "dash" lines
  // for strokes with tapered start and ends. Don't mutate the
  // input array!
  if (pts.length == 2) {
    final first = pts.first;
    final last = pts.removeLast();
    for (int i = 1; i < 5; ++i) {
      pts.add(first.lerp(i / 4, last));
    }
  }

  // A single point is left alone: [getStrokeOutlinePoints] draws it as a
  // round dot. (Adding a second point at a 1pt offset, as before, stretched
  // the dot diagonally.)

  /// Updates the pressure of the point at index [i].
  /// This is used in [getStrokeOutlinePoints] if [rememberSimulatedPressure]
  /// is true and once the pressure has been calculated.
  void updatePressure(int i, double pressure) {
    points[i] = points[i].copyWith(pressure: pressure);
  }

  // The [strokePoints] array will hold the points for the stroke.
  // Start it out with the first point, which needs no adjustment.
  final strokePoints = <StrokePoint>[
    StrokePoint(
      point: pts.first,
      updatePressure: (pressure) => updatePressure(0, pressure),
      vector: PointVector.one,
      distance: 0,
      runningLength: 0,
    ),
  ];

  // A flag to see whether we've already reached our minimum length
  var hasReachedMinimumLength = false;

  // We use the runningLength to keep track of the total distance
  var runningLength = 0.0;

  // We're set this to the latest point, so we can use it to calculate
  // the distance and vector of the next point.
  var prev = strokePoints.first;

  final max = pts.length - 1;

  // Iterate through all of the points, creating StrokePoints.
  for (int i = 0; i < pts.length; ++i) {
    final point = (options.isComplete && i == max)
        // If we're at the last point, and [options.last] is true,
        // then add the actual input point.
        ? pts[i]
        // Otherwise,
        // using the [t] calculated from the [streamline] option,
        // interpolate a new point between the previous point
        // and the current point.
        : prev.point.lerp(t, pts[i]);

    // If the new point is at the same position as the previous point,
    // skip ahead (even if its pressure differs).
    if (point.isAtSamePositionAs(prev.point)) continue;

    // How far is the new point from the previous point?
    final distance = point.distanceTo(prev.point);

    // Add this distance to the total "running length" of the line.
    runningLength += distance;

    // At the start of the line, we wait until the new point is a
    // certain distance away from the original point, to avoid noise.
    if (i < max && !hasReachedMinimumLength) {
      if (runningLength < options.size) continue;
      hasReachedMinimumLength = true;
      // TODO(steveruizok): Backfill the missing points so that tapering works correctly.
    }

    // Create a new [StrokePoint] (it will be the new [prev])
    prev = StrokePoint(
      // The adjusted point
      point: point,
      // A function to update the pressure of the point
      updatePressure: (pressure) => updatePressure(
        min(i, points.length - 1),
        pressure,
      ),
      // The vector from the current point to the previous point
      vector: point.unitVectorTo(prev.point),
      // The distance between the current point and the previous point
      distance: distance,
      // The total distance so far
      runningLength: runningLength,
    );

    // Add it to the [strokePoints] array
    strokePoints.add(prev);
  }

  // Set the vector of the first point to be the same as the second point.
  if (strokePoints.length > 1) {
    strokePoints.first.vector = strokePoints[1].vector;
  } else {
    // If there's only one point, set the vector to zero.
    strokePoints.first.vector = PointVector.zero;
  }

  return strokePoints;
}
