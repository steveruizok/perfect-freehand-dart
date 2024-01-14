/// Compute a radius based on the pressure.
double getStrokeRadius(
  double size,
  double thinning,
  double pressure,
  double Function(double) easing,
) {
  return size * easing(0.5 - thinning * (0.5 - pressure));
}
