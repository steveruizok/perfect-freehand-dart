import 'dart:math';

import 'get_stroke_radius.dart';
import 'point.dart';
import 'stroke_point.dart';
import 'vec.dart';

const double rateOfPressureChange = 0.275;

/// Get an array of points representing the outline of a stroke, based on the provided [points]. Used internally by `getStroke` but possibly of separate interest. Accepts the result of `getStrokeOutlinePoints`.
///
/// The [size] argument sets the base diameter for the shape.
///
/// The [thinning] argument sets the effect of pressure on the stroke's size.
///
/// The [smoothing] argument sets the density of points along the stroke's edges.
///
/// The [streamline] argument sets the level of variation allowed in the input points.
///
/// The [taperStart] argument sets the distance to taper the front of the stroke.
///
/// The [capStart] argument sets whether to add a cap to the start of the stroke.
///
/// The [taperEnd] argument sets the distance to taper the end of the stroke.
///
/// The [capEnd] argument sets whether to add a cap to the end of the stroke.
///
/// The [simulatePressure] argument sets whether to simulate pressure or use the point's provided pressures.
///
/// The [isComplete] argument sets whether the line is complete.
List<Point> getStrokeOutlinePoints(
  List<StrokePoint> points, {
  double size = 16,
  double thinning = 0.7,
  double smoothing = 0.5,
  double streamline = 0.5,
  double taperStart = 0.0,
  double taperEnd = 0.0,
  bool capStart = true,
  bool capEnd = true,
  bool simulatePressure = true,
  bool isComplete = false,
}) {
  if (points.isEmpty || size < 0) return [];

  final totalLength = points.last.runningLength;

  final minDistance = pow(size * smoothing, 2);

  final leftPts = <Point>[];

  final rightPts = <Point>[];

  double prevPressure = points[0].point.p;

  double sp;

  double rp;

  for (var i = 0; i < min(10, points.length); i++) {
    var pressure = points[i].point.p;

    if (simulatePressure) {
      sp = min(1, points[i].distance / size);

      rp = min(1, 1 - sp);

      pressure = min(
        1,
        prevPressure + (rp - prevPressure) * (sp * rateOfPressureChange),
      );
    }

    prevPressure = (prevPressure + pressure) / 2;
  }

  double radius = getStrokeRadius(
    size,
    thinning,
    points.last.point.p,
  );

  double? firstRadius;

  var prevVector = points[0].vector;

  var pl = points[0].point;

  var pr = pl;

  var tl = pl;

  var tr = pr;

  Point nextVector;

  Point offset;

  double nextDpr;

  double ts;

  double te;

  for (var i = 0; i < points.length - 1; i++) {
    final curr = points[i];

    if (totalLength - curr.runningLength < 3) continue;
    // Pressure

    var pressure = curr.point.p;

    if (thinning != 0) {
      if (simulatePressure) {
        sp = min(1, curr.distance / size);
        rp = min(1, 1 - sp);
        pressure = min(
          1,
          prevPressure + (rp - prevPressure) * (sp * rateOfPressureChange),
        );
      }
      radius = getStrokeRadius(
        size,
        thinning,
        pressure,
      );
    }

    firstRadius ??= radius;

    // Tapering

    if (curr.runningLength < taperStart) {
      ts = curr.runningLength / taperStart;
    } else {
      ts = 1;
    }

    if (totalLength - curr.runningLength < taperEnd) {
      te = (totalLength - curr.runningLength) / taperEnd;
    } else {
      te = 1;
    }

    radius = max(0.01, radius * min(ts, te));

    // Left and Right Points

    nextVector = points[i + 1].vector;

    nextDpr = dpr(curr.vector, nextVector);

    if (nextDpr < 0) {
      // Sharp Corner

      final offset = mul(per(prevVector), radius);

      const step = 1 / 13;

      for (double t = 0; t <= 1; t += step) {
        tl = rotAround(sub(curr.point, offset), curr.point, pi * t);
        leftPts.add(tl);
        tr = rotAround(add(curr.point, offset), curr.point, pi * -t);
        rightPts.add(tr);
      }

      pl = tl;

      pr = tr;

      continue;
    }

    // Regular points

    offset = mul(per(lrp(nextVector, curr.vector, nextDpr)), radius);

    tl = sub(curr.point, offset);

    if (i == 0 || dist2(pl, tl) > minDistance) {
      leftPts.add(tl);
      pl = tl;
    }

    tr = add(curr.point, offset);

    if (i == 0 || dist2(pr, tr) > minDistance) {
      rightPts.add(tr);
      pr = tr;
    }

    prevPressure = pressure;

    prevVector = curr.vector;
  }

  final firstPoint = points.first.point;

  final lastPoint = () {
    if (points.length > 1) {
      return points.last.point;
    } else {
      return add(
        firstPoint,
        Point(1, 1),
      );
    }
  }();

  final isVeryShort = leftPts.length <= 1 || rightPts.length <= 1;

  final startCap = <Point>[];

  final endCap = <Point>[];

  if (isVeryShort) {
    if (!(taperStart > 0 || taperEnd > 0) || isComplete) {
      final start = prj(
        firstPoint,
        uni(per(sub(firstPoint, lastPoint))),
        -(firstRadius ??= radius),
      );

      final dotPts = <Point>[];

      const step = 1 / 13;

      for (double t = step; t <= 1; t += step) {
        dotPts.add(rotAround(start, firstPoint, pi * 2 * t));
      }

      return dotPts;
    }
  } else {
    // Start Cap

    if (taperStart > 0 || (taperEnd > 0 && isVeryShort)) {
      // noop
    } else if (capStart) {
      const step = 1 / 13;

      for (double t = step; t <= 1; t += step) {
        startCap.add(rotAround(rightPts.first, firstPoint, pi * t));
      }
    } else {
      final cornersVector = sub(leftPts.first, rightPts.first);

      final offsetA = mul(cornersVector, 0.5);

      final offsetB = mul(cornersVector, 0.51);

      startCap.addAll(
        [
          sub(firstPoint, offsetA),
          sub(firstPoint, offsetB),
          add(firstPoint, offsetB),
          add(firstPoint, offsetA),
        ],
      );
    }

    // End Cap

    final mid = med(leftPts.last, rightPts.last);

    final direction = per(uni(sub(lastPoint, mid)));

    if (taperEnd > 0 || (taperStart > 0 && isVeryShort)) {
      endCap.add(lastPoint);
    } else if (capEnd) {
      final start = prj(lastPoint, direction, radius);

      const step = 1 / 29;

      for (double t = 0; t <= 1; t += step) {
        endCap.add(rotAround(start, lastPoint, pi * 3 * t));
      }
    } else {
      endCap.addAll([
        sub(lastPoint, mul(direction, radius)),
        sub(lastPoint, mul(direction, radius * .99)),
        add(lastPoint, mul(direction, radius * .99)),
        add(lastPoint, mul(direction, radius))
      ]);
    }
  }

  return [
    ...leftPts,
    ...endCap,
    ...rightPts.reversed,
    ...startCap,
  ];
}
