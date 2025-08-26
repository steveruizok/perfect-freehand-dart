abstract class StrokeEasings {
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
