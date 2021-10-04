class StrokeOptions {
  /// The base size (diameter) of the stroke.
  double size;
  
  /// The effect of pressure on the stroke's size.
  double thinning;
  
  /// Controls the density of points along the stroke's edges.
  double smoothing;
  
  /// Controls the level of variation allowed in the input points.
  double streamline;
  
  // Whether to simulate pressure or use the point's provided pressures. 
  final bool simulatePressure;
  
  // The distance to taper the front of the stroke.
  double taperStart;
  
  // The distance to taper the end of the stroke.
  double taperEnd;
  
  // Whether to add a cap to the start of the stroke.
  final bool capStart;
  
  // Whether to add a cap to the end of the stroke.
  final bool capEnd;
  
  // Whether the line is complete.
  final bool isComplete;

  StrokeOptions({
    this.size = 16,
    this.thinning = 0.7,
    this.smoothing = 0.5,
    this.streamline = 0.5,
    this.taperStart = 0.0,
    this.capStart = true,
    this.taperEnd = 0.0,
    this.capEnd = true,
    this.simulatePressure = true,
    this.isComplete = false,
  });
}
