import 'dart:ui';

import 'package:perfect_freehand/src/get_stroke_outline_points.dart';
import 'package:perfect_freehand/src/get_stroke_points.dart';
import 'package:perfect_freehand/src/types.dart';

/// Get an array of points describing a polygon that surrounds the
/// input points.
List<Offset> getStroke(
  List<PointVector> points, [
  StrokeOptions? options,
]) {
  return getStrokeOutlinePoints(
    getStrokePoints(points, options),
    options,
  );
}
