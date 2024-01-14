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

  StrokeOptions.fromJson(
    Map<String, dynamic> json, {
    double Function(double)? easing,
    double Function(double)? startEasing,
    double Function(double)? endEasing,
  })  : size = json['s'] ?? StrokeOptions.defaultSize,
        thinning = json['t'] ?? StrokeOptions.defaultThinning,
        smoothing = json['sm'] ?? StrokeOptions.defaultSmoothing,
        streamline = json['sl'] ?? StrokeOptions.defaultStreamline,
        easing = easing ?? defaultEasing,
        simulatePressure = json['sp'] ?? StrokeOptions.defaultSimulatePressure,
        start = StrokeEndOptions.start(
          customTaper: json['ts'],
          cap: json['cs'] ?? StrokeEndOptions.defaultCap,
          easing: startEasing,
        ),
        end = StrokeEndOptions.end(
          customTaper: json['te'],
          cap: json['ce'] ?? StrokeEndOptions.defaultCap,
          easing: endEasing,
        ),
        isComplete = json['f'] ?? true;

  /// Note that the easing functions aren't serialized.
  /// If you need this functionality, please open an issue or PR.
  Map<String, dynamic> toJson() => {
        if (size != StrokeOptions.defaultSize) 's': size,
        if (thinning != StrokeOptions.defaultThinning) 't': thinning,
        if (smoothing != StrokeOptions.defaultSmoothing) 'sm': smoothing,
        if (streamline != StrokeOptions.defaultStreamline) 'sl': streamline,

        // -1 means taper is enabled, but no custom taper is set.
        if (start.taperEnabled) 'ts': start.customTaper ?? -1,
        if (end.taperEnabled) 'te': end.customTaper ?? -1,
        if (start.cap != StrokeEndOptions.defaultCap) 'cs': start.cap,
        if (end.cap != StrokeEndOptions.defaultCap) 'ce': end.cap,

        if (simulatePressure != StrokeOptions.defaultSimulatePressure)
          'sp': simulatePressure,
        if (isComplete != true) 'f': isComplete,
      };

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

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is StrokeOptions &&
        other.size == size &&
        other.thinning == thinning &&
        other.smoothing == smoothing &&
        other.streamline == streamline &&
        other.easing == easing &&
        other.simulatePressure == simulatePressure &&
        other.start == start &&
        other.end == end &&
        other.isComplete == isComplete;
  }

  @override
  int get hashCode => Object.hashAll([
        size,
        thinning,
        smoothing,
        streamline,
        easing,
        simulatePressure,
        start,
        end,
        isComplete,
      ]);
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
  ///
  /// For convenience, if [customTaper] is set to `0` in the constructor,
  /// [taperEnabled] will be set to `false`.
  ///
  /// For convenience, if [customTaper] is set to `-1` in the constructor,
  /// [taperEnabled] will be set to `true` and [customTaper] will be set to
  /// `null`.
  double? customTaper;

  double Function(double) easing;

  StrokeEndOptions._({
    required this.cap,
    required this.taperEnabled,
    this.customTaper,
    required this.easing,
  }) {
    if (customTaper != null) {
      taperEnabled = customTaper != 0;
      if (customTaper == -1) customTaper = null;
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

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is StrokeEndOptions &&
        other.cap == cap &&
        other.taperEnabled == taperEnabled &&
        other.customTaper == customTaper &&
        other.easing == easing;
  }

  @override
  int get hashCode => Object.hashAll([
        cap,
        taperEnabled,
        customTaper,
        easing,
      ]);
}
