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
