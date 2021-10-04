import 'dart:math';

import 'get_stroke_radius.dart';
import 'point.dart';
import 'stroke_options.dart';
import 'stroke_point.dart';
import 'vec.dart';

const double rateOfPressureChange = 0.275;

// Get stroke points from input points
List<Point> getStrokeOutlinePoints(
  List<StrokePoint> points,
  StrokeOptions options,
) {
  
  if (points.isEmpty || options.size < 0) return [];
  
  final totalLength = points.last.runningLength;
  
  final minDistance = pow(options.size * options.smoothing, 2);
  
  final leftPts = <Point>[];
  
  final rightPts = <Point>[];
  
  double prevPressure = points[0].point.p;
  
  double sp;
  
  double rp;
  
  for (var i = 0; i < min(10, points.length); i++) {
    var pressure = points[i].point.p;
    
    if (options.simulatePressure) {
      sp = min(1, points[i].distance / options.size);
      
      rp = min(1, 1 - sp);
      
      pressure = min(
        1,
        prevPressure + (rp - prevPressure) * (sp * rateOfPressureChange),
      );
    }
    
    prevPressure = (prevPressure + pressure) / 2;
  }
  
  double radius = getStrokeRadius(
    options.size,
    options.thinning,
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
    
    if (options.thinning != 0) {
      if (options.simulatePressure) {
        sp = min(1, curr.distance / options.size);
        rp = min(1, 1 - sp);
        pressure = min(
          1,
          prevPressure + (rp - prevPressure) * (sp * rateOfPressureChange),
        );
        radius = getStrokeRadius(
          options.size,
          options.thinning,
          pressure,
        );
      } else {
        radius = options.size / 2;
      }
    }

    firstRadius ??= radius;
   
    // Tapering
   
    if (curr.runningLength < options.taperStart) {
      ts = curr.runningLength / options.taperStart;
    } else {
      ts = 1;
    }
   
    if (totalLength - curr.runningLength < options.taperEnd) {
      te = (totalLength - curr.runningLength) / options.taperEnd;
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
    if (!(options.taperStart > 0 || options.taperEnd > 0) || options.isComplete) {
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
    
    if (options.taperStart > 0 || (options.taperEnd > 0 && isVeryShort)) {
      // noop
    } else if (options.capStart) {
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

    if (options.taperEnd > 0 || (options.taperStart > 0 && isVeryShort)) {
      endCap.add(lastPoint);
    } else if (options.capEnd) {
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
