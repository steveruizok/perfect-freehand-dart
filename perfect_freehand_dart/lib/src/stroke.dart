import 'point.dart';

class Stroke {
  final List<Point> path;
  final bool complete;

  const Stroke(
    this.path,
    this.complete,
  );
}
