double getStrokeRadius(double size, double thinning, double pressure) {
  return size * (0.5 - thinning * (0.5 - pressure));
}