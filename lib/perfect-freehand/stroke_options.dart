class StrokeOptions {
  double size;
  double thinning;
  double smoothing;
  double streamline;
  bool simulatePressure;
  double taperStart;
  double taperEnd;
  bool capStart;
  bool capEnd;
  bool last;

  StrokeOptions(
      {this.size = 16,
      this.thinning = 0.7,
      this.smoothing = 0.5,
      this.streamline = 0.5,
      this.taperStart = 0.0,
      this.capStart = true,
      this.taperEnd = 0.0,
      this.capEnd = true,
      this.simulatePressure = true,
      this.last = false});
}
