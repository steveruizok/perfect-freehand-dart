import 'point.dart';
import 'stroke_options.dart';
import 'stroke_point.dart';
import 'vec.dart';

// Get stroke points from input points
List<StrokePoint> getStrokePoints(List<Point> points, StrokeOptions options) {
  if (points.isEmpty) return [];
  
  final t = 0.15 + (1 - options.streamline) * 0.85;
  
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
    if (options.isComplete && i == pts.length - 1) {
      point = pts[i];
    } else {
      point = lrp(prev.point, pts[i], t);
    }
    
    if (isEqual(point, prev.point)) {
      continue;
    }
    
    distance = dist(point, prev.point);
    
    runningLength += distance;
    
    if (i < pts.length - 1 && !hasReachedMinimumLength) {
      if (runningLength < options.size) {
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
