import 'point.dart';
import 'stroke_point.dart';
import 'vec.dart';

/// Get an array of points as objects with an adjusted point, pressure, vector, distance, and runningLength for the provided [points]. Used internally by `getStroke` but possibly of separate interest. Can be passed to `getStrokeOutlinePoints`.
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
List<StrokePoint> getStrokePoints(
  List<Point> points, {
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
  if (points.isEmpty) return [];

  final t = 0.15 + (1 - streamline) * 0.85;

  List<Point> pts = points;

  if (pts.length == 1) {
    pts = pts.toList();
    pts.add(Point(pts[0].x + 1, pts[0].y + 1, pts[0].p));
  }

  final strokePoints = <StrokePoint>[];

  var prev = StrokePoint(
    pts[0],
    Point(1, 1),
    0,
    0,
  );

  strokePoints.add(prev);

  Point point;

  double distance;

  double runningLength = 0;

  bool hasReachedMinimumLength = false;

  for (var i = 1; i < pts.length; i++) {
    if (isComplete && i == pts.length - 1) {
      point = pts[i];
    } else {
      final tempPoint = lrp(prev.point, pts[i], t);
      point = Point(tempPoint.x, tempPoint.y, pts[i].p);
    }

    if (isEqual(point, prev.point)) {
      continue;
    }

    distance = dist(point, prev.point);

    runningLength += distance;

    if (i < pts.length - 1 && !hasReachedMinimumLength) {
      if (runningLength < size) {
        continue;
      }
      hasReachedMinimumLength = true;
    }

    prev = StrokePoint(
      point,
      uni(sub(prev.point, point)),
      distance,
      runningLength,
    );

    strokePoints.add(prev);
  }

  if (strokePoints.length > 1) {
    strokePoints[0].vector = strokePoints[1].vector;
  }

  return strokePoints;
}
