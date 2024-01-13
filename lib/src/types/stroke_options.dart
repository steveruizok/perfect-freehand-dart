import 'package:perfect_freehand/src/types/easings.dart';

/// The options object for [getStroke] or [getStrokePoints].
class StrokeOptions {
  // Note: these defaults are not final, so devs can change them if they want.
  static double defaultSize = 16;
  static double defaultThinning = 0.5;
  static double defaultSmoothing = 0.5;
  static double defaultStreamline = 0.5;
  static double Function(double) defaultEasing = StrokeEasings.identity;
  static bool defaultSimulatePressure = true;
  static bool defaultIsComplete = false;

  /// The base size (diameter) of the stroke.
  double size;

  /// The effect of pressure on the stroke's size.
  double thinning;

  /// How much to soften the stroke's edges.
  double smoothing;

  double streamline;

  /// An easing function to apply to each point's pressure.
  double Function(double) easing;

  /// Whether to simulate pressure based on velocity.
  bool simulatePressure;

  /// Cap, taper, and easing for the start of the line.
  StrokeEndOptions start;

  /// Cap, taper, and easing for the end of the line.
  StrokeEndOptions end;

  /// Whether to handle the points as a completed stroke.
  bool isComplete;

  StrokeOptions({
    double? size,
    double? thinning,
    double? smoothing,
    double? streamline,
    double Function(double)? easing,
    bool? simulatePressure,
    StrokeEndOptions? start,
    StrokeEndOptions? end,
    bool? isComplete,
  })  : size = size ?? defaultSize,
        thinning = thinning ?? defaultThinning,
        smoothing = smoothing ?? defaultSmoothing,
        streamline = streamline ?? defaultStreamline,
        easing = easing ?? defaultEasing,
        simulatePressure = simulatePressure ?? defaultSimulatePressure,
        start = start ?? StrokeEndOptions.start(),
        end = end ?? StrokeEndOptions.end(),
        isComplete = isComplete ?? defaultIsComplete;

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
  // Note: these defaults are not final, so devs can change them if they want.
  static bool defaultCap = true;
  static bool defaultTaperEnabled = false;

  /// Whether to cap the line.
  bool cap;

  /// Whether to taper the start of the line.
  bool taperEnabled;

  /// A custom taper value for the start of the line, defaults to the total running length.
  double? customTaper;

  double Function(double) easing;

  StrokeEndOptions._({
    required this.cap,
    required this.taperEnabled,
    this.customTaper,
    required this.easing,
  }) {
    if (customTaper != null) {
      taperEnabled = true;
    }
  }

  /// The default options for the start of the line.
  StrokeEndOptions.start({
    bool? cap,
    bool? taperEnabled,
    double? customTaper,
    double Function(double)? easing,
  }) : this._(
          cap: cap ?? defaultCap,
          taperEnabled: taperEnabled ?? defaultTaperEnabled,
          customTaper: customTaper,
          easing: easing ?? StrokeEasings.easeInOut,
        );

  /// The default options for the end of the line.
  StrokeEndOptions.end({
    bool? cap,
    bool? taperEnabled,
    double? customTaper,
    double Function(double)? easing,
  }) : this._(
          cap: cap ?? defaultCap,
          taperEnabled: taperEnabled ?? defaultTaperEnabled,
          customTaper: customTaper,
          easing: easing ?? StrokeEasings.easeOutCubic,
        );
}
