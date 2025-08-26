import 'dart:math';
import 'dart:ui' show Offset, lerpDouble;

class PointVector extends Offset {
  const PointVector(
    this.x,
    this.y, [
    this.pressure,
  ]) : super(x, y);

  /// Identical to [dx]
  final double x;

  /// Identical to [dy]
  final double y;

  /// The pressure of the point, between 0 and 1,
  /// or null if the pressure is unknown.
  final double? pressure;

  /// Deprecated non-nullable pressure value.
  ///
  /// If [pressure] is null, this will return 0.5
  /// to match the previous behavior.
  @Deprecated('Use pressure instead')
  double get p => pressure ?? 0.5;

  static const zero = PointVector(0, 0);
  static const one = PointVector(1, 1);

  PointVector.fromOffset({
    required Offset offset,
    double? pressure,
  }) : this(offset.dx, offset.dy, pressure);

  PointVector copyWith({
    double? x,
    double? y,
    double? pressure,
  }) =>
      PointVector(
        x ?? this.x,
        y ?? this.y,
        pressure ?? this.pressure,
      );

  PointVector lerp(
    double t,
    PointVector other,
  ) {
    // avoid null values
    if (!isFinite) return other;
    if (!other.isFinite) return this;

    return PointVector(
      lerpDouble(x, other.x, t)!,
      lerpDouble(y, other.y, t)!,
      lerpDouble(pressure, other.pressure, t) ?? pressure ?? 0.5,
    );
  }

  /// Rotate a vector around another vector by [r] radians
  PointVector rotAround(PointVector center, double r) {
    final s = sin(r);
    final c = cos(r);

    final px = x - center.x;
    final py = y - center.y;

    final nx = px * c - py * s;
    final ny = px * s + py * c;

    return PointVector(
      nx + center.x,
      ny + center.y,
      pressure,
    );
  }

  double distanceSquaredTo(PointVector point) {
    final dx = x - point.x;
    final dy = y - point.y;
    return dx * dx + dy * dy;
  }

  double distanceTo(PointVector point) {
    return sqrt(distanceSquaredTo(point));
  }

  PointVector unitVectorTo(PointVector other) {
    final dx = other.x - x;
    final dy = other.y - y;
    final distance = sqrt(dx * dx + dy * dy);
    return PointVector(
      dx / distance,
      dy / distance,
    );
  }

  /// Dot product
  double dpr(PointVector other) {
    return x * other.x + y * other.y;
  }

  /// Perpendicular rotation of the vector
  PointVector perpendicular() {
    return PointVector(
      y,
      -x,
    );
  }

  /// Get the normalized / unit vector.
  PointVector unit() {
    final length = sqrt(x * x + y * y);
    if (length == 0) return PointVector.zero;
    return PointVector(
      x / length,
      y / length,
    );
  }

  /// Project this point in the direction of [direction] by a scalar [distance].
  PointVector project(PointVector direction, double distance) {
    return PointVector(
      x + direction.x * distance,
      y + direction.y * distance,
    );
  }

  @override
  PointVector operator *(double operand) {
    return PointVector(
      x * operand,
      y * operand,
      pressure,
    );
  }

  @override
  PointVector operator +(Offset other) {
    return PointVector(
      x + other.dx,
      y + other.dy,
      switch (other) {
        _ when other is PointVector => pressure ?? other.pressure,
        _ => pressure,
      },
    );
  }

  @override
  PointVector operator -(Offset other) {
    return PointVector(
      x - other.dx,
      y - other.dy,
      switch (other) {
        _ when other is PointVector => other.pressure ?? pressure,
        _ => pressure,
      },
    );
  }

  /// Negates the vector.
  @override
  PointVector operator -() {
    return PointVector(
      -x,
      -y,
      pressure,
    );
  }

  /// Compares this [PointVector] to an [Offset] or [PointVector] [other]
  /// for equality.
  ///
  /// If [other] is another [PointVector],
  /// it must have the same [x], [y], and [pressure] values.
  ///
  /// If [other] is an [Offset],
  /// it must have the same [dx] and [dy] values.
  @override
  bool operator ==(Object other) =>
      other is Offset &&
      x == other.dx &&
      y == other.dy &&
      (other is! PointVector || pressure == other.pressure);

  /// Returns a hash of the [x] and [y] values.
  /// This matches the hashcode of an Offset with those same values.
  @override
  int get hashCode => super.hashCode;

  @override
  String toString() => 'PointVector($x, $y, $pressure)';
}
