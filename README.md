# ![Screenshot](https://github.com/steveruizok/perfect-freehand-dart/blob/main/doc/assets/perfect-freehand-logo.svg "Perfect Freehand")

Draw perfect pressure-sensitive freehand lines.

🔗 A port of the [perfect-freehand](https://github.com/steveruizok/perfect-freehand) JavaScript library. [Try out that demo](https://perfect-freehand-example.vercel.app/).

💕 Love this library? Consider becoming a sponsor for
[steveruizok](https://github.com/sponsors/steveruizok)
(the author of the original JavaScript library) or
[adil192](https://github.com/sponsors/adil192)
(the maintainer of the Dart package).

## Table of Contents

- [Installation](#installation)
- [Usage](#usage)
- [Community](#community)
- [Author](#author)

## Introduction

This package exports a function named `getStroke` that will generate the points for a polygon based on an array of points.

![Screenshot](doc/assets/process.gif "A GIF showing a stroke with input points, outline points, and a curved path connecting these points")

To do this work, `getStroke` first creates a set of spline points (red) based on the input points (grey) and then creates outline points (blue). You can render the result any way you like, using whichever technology you prefer.

## Installation

This package is available on [pub.dev](https://pub.dev/packages/perfect_freehand). It can be used with or without Flutter.

With Dart:

```bash
dart pub add perfect_freehand
```

With Flutter:

```bash
flutter pub add perfect_freehand
```

See [here](https://pub.dev/packages/perfect_freehand/install) for more.

## Usage

This package exports a function named `getStroke` that:

- accepts an array of points and several options
- returns a stroke outline as an array of points

```dart
import 'package:perfect_freehand/perfect_freehand.dart';

List<Point> myPoints = [
  Point(0, 0),
  Point(1, 2),
  // etc...
];

final stroke = getStroke(myPoints);
```

You may also provide options as named parameters:

```dart
final stroke = getStroke(
  myPoints,
  size: 16,
  thinning: 0.7,
  smoothing: 0.5,
  streamline: 0.5,
  taperStart: 0.0,
  taperEnd: 0.0,
  capStart: true,
  capEnd: true,
  simulatePressure: true,
  isComplete: false,
);
```

To use real pressure, provide each point's pressure as a third parameter.

```dart
List<Point> myPoints = [
  Point(0, 0, 0.2),
  Point(1, 2, 0.3),
  Point(2, 4, 0.4),
  // etc...
];

final stroke = getStroke(myPoints, simulatePressure: false);
```

### Options

The optional parameters are:

| Property           | Type    | Default | Description                                                                                                |
| ------------------ | ------- | ------- | ---------------------------------------------------------------------------------------------------------- |
| `size`             | double  | 16      | The base size (diameter) of the stroke.                                                                    |
| `thinning`         | double  | .5      | The effect of pressure on the stroke's size.                                                               |
| `smoothing`        | double  | .5      | How much to soften the stroke's edges.                                                                     |
| `streamline`       | double  | .5      | How much to remove variation from the input points.                                                        |
| `startTaper`       | double  | 0       | How far to taper the start of the line.                                                                    |
| `endTaper`         | double  | 0       | How far to taper the end of the line.                                                                      |
| `isComplete`       | boolean | true    | Whether the stroke is complete.                                                                            |
| `simulatePressure` | boolean | true    | Whether to simulate pressure based on distance between points, or else use the provided Points' pressures. |

**Note:** When the `last` property is `true`, the line's end will be drawn at the last input point, rather than slightly behind it.

**Note:** The `cap` property has no effect when `taper` is more than zero.

**Tip:** To create a stroke with a steady line, set the `thinning` option to `0`.

**Tip:** To create a stroke that gets thinner with pressure instead of thicker, use a negative number for the `thinning` option.

### Rendering

While `getStroke` returns an array of points representing the outline of a stroke, it's up to you to decide how you will render these points. Check the **example project** to see how you might draw these points in Flutter using a `CustomPainter`.

```dart
import 'package:flutter/material.dart';
import 'package:perfect_freehand/perfect_freehand.dart';

class StrokePainter extends CustomPainter {
  final List<Point> points;

  StrokePainter({ required this.points });

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint() ..color = Colors.black;

    // 1. Get the outline points from the input points
    final outlinePoints = getStroke(points);

    // 2. Render the points as a path
    final path = Path();

    if (outlinePoints.isEmpty) {
      // If the list is empty, don't do anything.
      return;
    } else if (outlinePoints.length < 2) {
      // If the list only has one point, draw a dot.
      path.addOval(Rect.fromCircle(
          center: Offset(outlinePoints[0].x, outlinePoints[0].y), radius: 1));
    } else {
      // Otherwise, draw a line that connects each point with a bezier curve segment.
      path.moveTo(outlinePoints[0].x, outlinePoints[0].y);

      for (int i = 1; i < outlinePoints.length - 1; ++i) {
        final p0 = outlinePoints[i];
        final p1 = outlinePoints[i + 1];
        path.quadraticBezierTo(
            p0.x, p0.y, (p0.x + p1.x) / 2, (p0.y + p1.y) / 2);
      }
    }

    // 3. Draw the path to the canvas
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(StrokePainter oldDelegate) {
    return true;
  }
}
```

### Advanced Usage

For advanced usage, the library also exports smaller functions that `getStroke` uses to generate its outline points.

#### `getStrokePoints`

A function that accepts an array of Points and returns a set of `StrokePoints`. The path's total length will be the `runningLength` of the last point in the array. Like `getStroke`, this function also accepts any of the [optional named parameters](#options) listed above.

```dart
List<Point> myPoints = [
  Point(0, 0),
  Point(1, 2),
  // etc...
];

final strokePoints = getStrokePoints(myPoints, size: 16);
```

#### `getOutlinePoints`

A function that accepts an array of StrokePoints (i.e. the output of `getStrokePoint`) and returns an array of Points defining the outline of a stroke. Like `getStroke`, this function also accepts any of the [optional named parameters](#options) listed above.

```dart
List<Point> myPoints = [
  Point(0, 0),
  Point(1, 2),
  // etc...
];

final myStrokePoints = getStrokePoints(myPoints, size: 16);

final myOutlinePoints = getStrokeOutlinePoints(myStrokePoints, size: 16)
```

**Note:** Internally, the `getStroke` function passes the result of `getStrokePoints` to `getStrokeOutlinePoints`, just as shown in this example. This means that, in this example, the result of `myOutlinePoints` will be the same as if the `myPoints` List had been passed to `getStroke`.

## Community

### Support

Need help? Please [open an issue](https://github.com/steveruizok/perfect-freehand-dart/issues/new) for support.

### Discussion

Have an idea or casual question? Visit the [discussion page](https://github.com/steveruizok/perfect-freehand-dart/discussions).

### License

- MIT
- ...but if you're using `perfect-freehand` in a commercial product, consider [becoming a sponsor](https://github.com/sponsors/steveruizok?frequency=recurring&sponsor=steveruizok). 💰

## Author

- [@steveruizok](https://twitter.com/steveruizok)
