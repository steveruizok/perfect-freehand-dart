import 'dart:math';
import 'dart:ui';

/// The options object for [getStroke] or [getStrokePoints].
class StrokeOptions {
  /// The base size (diameter) of the stroke.
  double? size;

  /// The effect of pressure on the stroke's size.
  double? thinning;

  /// How much to soften the stroke's edges.
  double? smoothing;

  double? streamline;

  /// An easing function to apply to each point's pressure.
  double Function(double)? easing;

  /// Whether to simulate pressure based on velocity.
  bool? simulatePressure;

  /// Cap, taper, and easing for the start of the line.
  StrokeEndOptions? start;

  /// Cap, taper, and easing for the end of the line.
  StrokeEndOptions? end;

  /// Whether to handle the points as a completed stroke.
  bool? isComplete;

  StrokeOptions({
    this.size,
    this.thinning,
    this.smoothing,
    this.streamline,
    this.easing,
    this.simulatePressure,
    this.start,
    this.end,
    this.isComplete,
  });

  StrokeOptions copyWith({
    double? size,
    double? thinning,
    double? smoothing,
    double? streamline,
    double Function(double)? easing,
    bool? simulatePressure,
    StrokeEndOptions? start,
    StrokeEndOptions? end,
    bool? isComplete,
  }) =>
      StrokeOptions(
        size: size ?? this.size,
        thinning: thinning ?? this.thinning,
        smoothing: smoothing ?? this.smoothing,
        streamline: streamline ?? this.streamline,
        easing: easing ?? this.easing,
        simulatePressure: simulatePressure ?? this.simulatePressure,
        start: start ?? this.start,
        end: end ?? this.end,
        isComplete: isComplete ?? this.isComplete,
      );
}

class StrokeEasings {
  /// Identity function.
  /// Returns the input value.
  static double identity(double t) => t;

  /// Ease-in-out function.
  /// Used for the taper start.
  static double easeInOut(double t) => t * (2 - t);

  /// Ease-out-cubic function.
  /// Used for the taper end.
  static double easeOutCubic(double t) => --t * t * t + 1;
}

/// Stroke options for the start/end of the line.
class StrokeEndOptions {
  /// Whether to cap the line.
  bool? cap;

  /// Whether to taper the start of the line.
  bool? taperEnabled;

  /// A custom taper value for the start of the line, defaults to the total running length.
  double? customTaper;

  double Function(double)? easing;

  StrokeEndOptions({
    this.cap,
    this.taperEnabled,
    this.customTaper,
    this.easing,
  }) {
    if (customTaper != null) {
      taperEnabled = true;
    }
  }
}

/// The points returned by [getStrokePoints]
/// and the input for [getStrokeOutlinePoints].
class StrokePoint {
  /// The adjusted point.
  PointVector point;

  /// The input pressure.
  double pressure;

  /// The distance between the current point and the previous point.
  double distance;

  /// The vector from the current point to the previous point.
  PointVector vector;

  /// The total distance so far.
  double runningLength;

  StrokePoint({
    required this.point,
    required this.pressure,
    required this.distance,
    required this.vector,
    required this.runningLength,
  });
}

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
}
