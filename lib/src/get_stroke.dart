import 'dart:ui';

import 'package:perfect_freehand/src/get_stroke_outline_points.dart';
import 'package:perfect_freehand/src/get_stroke_points.dart';
import 'package:perfect_freehand/src/types/point_vector.dart';
import 'package:perfect_freehand/src/types/stroke_options.dart';

/// Get an array of points describing a polygon that surrounds the
/// input points.
///
/// The [rememberSimulatedPressure] argument sets whether to update the
/// input [points] with the simulated pressure values.
List<Offset> getStroke(
  List<PointVector> points, {
  StrokeOptions? options,
  bool rememberSimulatedPressure = false,
}) {
  options ??= StrokeOptions();
  return getStrokeOutlinePoints(
    getStrokePoints(
      points,
      options: options,
    ),
    options: options,
    rememberSimulatedPressure: rememberSimulatedPressure,
  );
}
