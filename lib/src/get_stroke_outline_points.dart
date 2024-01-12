import 'dart:math';
import 'dart:ui';

import 'package:perfect_freehand/src/get_stroke_radius.dart';
import 'package:perfect_freehand/src/types.dart';

// This is the rate of change for simulated pressure. It could be an option.
const rateOfPressureChange = 0.275;

// Browser strokes seem to be off if PI is regular, a tiny offset seems to fix it
const fixedPi = pi + 0.0001;

/// Get an array of points representing the outline of a stroke.
///
/// Used internally by `getStroke` but possibly of separate interest.
/// Accepts the result of `getStrokePoints`.
///
/// The [rememberSimulatedPressure] argument sets whether to update the
/// input [points] with the simulated pressure values.
List<Offset> getStrokeOutlinePoints(
  List<StrokePoint> points, {
  StrokeOptions? options,
  bool rememberSimulatedPressure = false,
}) {
  final size = options?.size ?? 16;
  final smoothing = options?.smoothing ?? 0.5;
  final thinning = options?.thinning ?? 0.5;
  final simulatePressure = options?.simulatePressure ?? true;
  final easing = options?.easing ?? StrokeEasings.identity;
  final start = options?.start ?? StrokeEndOptions();
  final end = options?.end ?? StrokeEndOptions();
  final isComplete = options?.isComplete ?? false;

  final capStart = start.cap ?? true;
  final taperStartEase = start.easing ?? StrokeEasings.easeInOut;
  final capEnd = end.cap ?? true;
  final taperEndEase = end.easing ?? StrokeEasings.easeOutCubic;

  if (rememberSimulatedPressure) {
    assert(simulatePressure && isComplete,
        'rememberSimulatedPressure can only be used when simulatePressure and isComplete are true.');
  }

  // We can't do anything with an empty array or a stroke with negative size.
  if (points.isEmpty || size <= 0) return [];

  // The total length of the line.
  final totalLength = points.last.runningLength;

  final taperStart = (start.taperEnabled ?? false)
      ? start.customTaper ?? max(size, totalLength)
      : 0.0;
  final taperEnd = (end.taperEnabled ?? false)
      ? end.customTaper ?? max(size, totalLength)
      : 0.0;

  /// The minimum allowed distance between points (squared)
  final minDistance = pow(size * smoothing, 2);

  // Our collected left and right points
  final leftPoints = <PointVector>[];
  final rightPoints = <PointVector>[];

  // Previous pressure.
  // We start with average of first 10 pressures,
  // in order to prevent fat starts for every line.
  // Drawn lines almost always start slow!
  var prevPressure = () {
    double acc = points.first.pressure;
    for (final curr in points.sublist(0, min(10, points.length - 1))) {
      final double pressure;
      if (simulatePressure) {
        // Speed of change - how fast should the pressure be changing?
        final sp = min(1, curr.distance / size);
        // Rate of change - how much of a change is there?
        final rp = min(1, 1 - sp);
        // Accelerate the pressure
        pressure = min(1, acc + (rp - acc) * (sp * rateOfPressureChange));
      } else {
        pressure = curr.pressure;
      }

      acc = (acc + pressure) / 2;
    }
    return acc;
  }();

  // The current radius
  var radius = getStrokeRadius(
    size,
    thinning,
    points.last.pressure,
    easing,
  );

  // The radius of the first saved point
  double? firstRadius;

  // Previous vector
  var prevVector = points.first.vector;

  // Previous left and right points
  var pl = points.first.point;
  var pr = pl;

  // Temporary left and right points
  var tl = pl;
  var tr = pr;

  // Keep track of whether the previous point is a sharp corner
  // ... so that we don't detect the same corner twice
  var isPrevPointSharpCorner = false;

  // var short = true

  /**
   * Find the outline's left and right points
   * 
   * Iterating through the points and populate the rightPts and leftPts arrays,
   * skipping the first and last points, which will get caps later on.
   */

  for (int i = 0; i < points.length; ++i) {
    var pressure = points[i].pressure;
    final point = points[i].point;
    final vector = points[i].vector;
    final distance = points[i].distance;
    final runningLength = points[i].runningLength;

    // Removes noise from the end of the line
    if (i < points.length - 1 && totalLength - runningLength < size) {
      continue;
    }

    /**
     * Calculate the radius
     * 
     * If not thinning, the current point's radius will be half the size; or
     * otherwise, the size will be based on the current (real or simulated)
     * pressure.
     */

    if (thinning != 0) {
      if (simulatePressure) {
        // If we're simulating pressure, then do so based on the distance
        // between the current point and the previous point, and the size
        // of the stroke. Otherwise, use the input pressure.
        final sp = min(1, distance / size);
        final rp = min(1, 1 - sp);
        pressure = min(1,
            prevPressure + (rp - prevPressure) * (sp * rateOfPressureChange));

        // Update the point's pressure
        if (rememberSimulatedPressure) {
          points[i].updatePressure(pressure);
        }
      }

      radius = getStrokeRadius(
        size,
        thinning,
        pressure,
        easing,
      );
    } else {
      radius = size / 2;
    }

    firstRadius ??= radius;

    /**
     * Apply tapering
     * 
     * If the current length if within the taper distance at either the
     * start or the end, calculate the taper strengths. Apply the smaller
     * of the two taper strengths to the radius.
     */

    final ts = runningLength < taperStart
        ? taperStartEase(runningLength / taperStart)
        : 1;
    final te = totalLength - runningLength < taperEnd
        ? taperEndEase((totalLength - runningLength) / taperEnd)
        : 1;

    radius = max(0.01, radius * min(ts, te));

    // Add points to left and right

    /**
     * Handle sharp corners
     * 
     * Find the difference (dot product) between the current and next vector.
     * If the next vector is at more than a right angle to the current vector,
     * draw a cap at the current point.
     */

    final nextVector = i < points.length - 1 ? points[i + 1].vector : vector;
    final nextDpr = i < points.length - 1 ? vector.dpr(nextVector) : 1.0;
    final prevDpr = vector.dpr(prevVector);

    final isPointSharpCorner = prevDpr < 0 && !isPrevPointSharpCorner;
    final isNextPointSharpCorner = nextDpr < 0;

    if (isPointSharpCorner || isNextPointSharpCorner) {
      // It's a sharp corner. Draw a rounded cap and move on to the next point
      // Considering saving these and drawing them later? So that we can avoid
      // crossing future points.

      final offset = prevVector.perpendicular() * radius;

      const step = 1 / 13;
      for (double t = 0; t <= 1; t += step) {
        tl = (point - offset).rotAround(point, fixedPi * t);
        leftPoints.add(tl);

        tr = (point + offset).rotAround(point, fixedPi * -t);
        rightPoints.add(tr);
      }

      pl = tl;
      pr = tr;

      if (isNextPointSharpCorner) {
        isPrevPointSharpCorner = true;
      }
      continue;
    }

    isPrevPointSharpCorner = false;

    // Handle the last point
    if (i == points.length - 1) {
      final offset = vector.perpendicular() * radius;
      leftPoints.add(point - offset);
      rightPoints.add(point + offset);
      continue;
    }

    /**
     * Add regular points
     * 
     * Project points to either side of the current point, using the
     * calculated size as a distance. If a point's distance to the
     * previous point on that side is greater than the minimum distance
     * (or if the corner is kinda sharp), add the points to the side's
     * points array.
     */

    final offset = nextVector.lerp(nextDpr, vector).perpendicular() * radius;

    tl = point - offset;

    if (i <= 1 || pl.distanceSquaredTo(tl) > minDistance) {
      leftPoints.add(tl);
      pl = tl;
    }

    tr = point + offset;

    if (i <= 1 || pr.distanceSquaredTo(tr) > minDistance) {
      rightPoints.add(tr);
      pr = tr;
    }

    // Set variables for next iteration
    prevPressure = pressure;
    prevVector = vector;
  }

  /**
   * Drawing caps
   * 
   * Now that we have our points on either side of the line, we need to
   * draw caps at the start and end. Tapered lines don't have caps, but
   * may have dots for very short lines.
   */

  final firstPoint = points.first.point;
  final lastPoint =
      points.length > 1 ? points.last.point : firstPoint + points.first.vector;

  final startCap = <PointVector>[];
  final endCap = <PointVector>[];

  /**
   * Draw a dot for very short or completed strokes
   * 
   * If the line is too short to gather left or right points and if the line is
   * not tapered on either side, draw a dot. If the line is tapered, then only
   * draw a dot if the line is both very short and complete. If we draw a dot,
   * we can just return those points.
   */

  if (points.length == 1) {
    if (!(taperStart > 0 || taperEnd > 0) || isComplete) {
      final start = firstPoint.project(
        (firstPoint - lastPoint).perpendicular().unit(),
        -(firstRadius ?? radius),
      );
      final List<PointVector> dotPts = [];
      const step = 1 / 13;
      for (double t = step; t <= 1; t += step) {
        dotPts.add(start.rotAround(firstPoint, fixedPi * 2 * t));
      }
      return dotPts;
    }
  } else {
    /**
     * Draw a start cap
     * 
     * Unless the line has a tapered start, or unless the line has a tapered end
     * and the line is very short, draw a start cap around the first point. Use
     * the distance between the second left and right point for the cap's radius.
     * Finally remove the first left and right points. :psyduck:
     */

    if (taperStart > 0 || (taperEnd > 0 && points.length == 1)) {
      // The start point is tapered, noop
    } else if (capStart) {
      // Draw the round cap - add thirteen points rotating the right point
      // around the start point to the left point
      const step = 1 / 13;
      for (double t = step; t <= 1; t += step) {
        final pt = rightPoints.first.rotAround(firstPoint, fixedPi * t);
        startCap.add(pt);
      }
    } else {
      // Draw the flat cap
      // - add a point to the left and right of the start point
      final cornersVector = leftPoints.first - rightPoints.first;
      final offsetA = cornersVector * 0.5;
      final offsetB = cornersVector * 0.51;

      startCap.add(firstPoint - offsetA);
      startCap.add(firstPoint - offsetB);
      startCap.add(firstPoint + offsetB);
      startCap.add(firstPoint + offsetA);
    }
  }

  /**
   * Draw an end cap
   * 
   * If the line does not have a tapered end, and unless the line has a tapered
   * start and the line is very short, draw a cap around the last point. Finally,
   * remove the last left and right points. Otherwise, add the last point. Note
   * that This cap is a full-turn-and-a-half: this prevents incorrect caps on
   * sharp end turns.
   */

  final direction = (-points.last.vector).perpendicular();

  if (taperEnd > 0 || (taperStart > 0 && points.length == 1)) {
    // Tapered end - push the last point to the line
    endCap.add(lastPoint);
  } else if (capEnd) {
    // Draw the round end cap
    final start = lastPoint.project(direction, radius);
    const step = 1 / 29;
    for (double t = step; t <= 1; t += step) {
      endCap.add(start.rotAround(lastPoint, fixedPi * 3 * t));
    }
  } else {
    // Draw the flat end cap

    endCap.add(lastPoint + direction * radius);
    endCap.add(lastPoint + direction * (radius * 0.99));
    endCap.add(lastPoint - direction * (radius * 0.99));
    endCap.add(lastPoint - direction * radius);
  }

  /**
   * Return the points in the correct winding order: begin on the left side, then
   * continue around the end cap, then come back along the right side, and finally
   * complete the start cap.
   */

  return [
    ...leftPoints,
    ...endCap,
    ...rightPoints.reversed,
    ...startCap,
  ];
}
