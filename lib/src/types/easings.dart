import 'dart:math';

class StrokeEasings {
  /// Identity function.
  /// Previously used as the default ease in [getStrokeRadius].
  @Deprecated('Use easeMiddle or define your own easing function')
  static double identity(double t) => t;

  /// This function is actually an ease-out function.
  /// Previously used for the taper start.
  @Deprecated('Use easeMiddle or define your own easing function')
  static double easeInOut(double t) => t * (2 - t);

  /// This function does not output a value between 0 and 1.
  /// Previously used for the taper end.
  @Deprecated('Use easeMiddle or define your own easing function')
  static double easeOutCubic(double t) => --t * t * t + 1;

  /// Easing function that slows down around the middle.
  static double easeMiddle(double t) {
    // Take average of t and cubic ease of t to smooth out the curve.
    return (t + _easeMiddleCubic(t)) / 2;
  }

  static double _easeMiddleCubic(double t) {
    return 4 * pow(t - 0.5, 3) + 0.5;
  }
}
