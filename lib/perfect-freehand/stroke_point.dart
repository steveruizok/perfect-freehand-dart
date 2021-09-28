import './point.dart';

class StrokePoint {
  Point point;
  Point vector;
  double distance;
  double runningLength;

  StrokePoint(this.point, this.vector, this.distance, this.runningLength);
}
