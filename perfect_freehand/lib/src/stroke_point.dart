import 'point.dart';

class StrokePoint {
  final Point point;
  
  Point vector;
  
  final double distance;
  
  final double runningLength;

  StrokePoint(
    this.point,
    this.vector,
    this.distance,
    this.runningLength,
  );
}
