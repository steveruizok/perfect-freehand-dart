/// Get the stroke's radius, given its size, thinning and pressure.
double getStrokeRadius(double size, double thinning, double pressure) {
  return size * (0.5 - thinning * (0.5 - pressure));
}
