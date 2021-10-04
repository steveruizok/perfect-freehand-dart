/// A point with an x and y coordinate and a pressure.
class Point {
  /// The horizontal coordinate.
  final double x;

  /// The vertical coordinate.
  final double y;

  /// The pressure for this point.
  final double p;

  const Point(
    this.x,
    this.y, [
    this.p = 0.5,
  ]);
}
