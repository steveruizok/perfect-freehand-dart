import 'dart:math';

import 'package:flutter/material.dart';
import 'package:perfect_freehand/perfect_freehand.dart';

import '../main.dart';

/// Transforms the input points to be centered in the available screen size.
DemoStroke transformExampleStroke(
  List<PointVector> inputPoints,
  Size screenSize,
) {
  final bounds = Rect.fromLTRB(
    inputPoints.map((p) => p.x).reduce(min),
    inputPoints.map((p) => p.y).reduce(min),
    inputPoints.map((p) => p.x).reduce(max),
    inputPoints.map((p) => p.y).reduce(max),
  );
  inputPoints = [
    for (final point in inputPoints)
      PointVector(
        point.x - bounds.left - bounds.width / 2 + screenSize.width / 2,
        point.y - bounds.top - bounds.height / 2 + screenSize.height / 2,
      ),
  ];
  return DemoStroke(inputPoints);
}
