# ![Screenshot](https://github.com/steveruizok/perfect-freehand-dart/blob/main/doc/assets/perfect-freehand-logo.svg "Perfect Freehand")

Draw perfect pressure-sensitive freehand lines.

🔗 A port of the [perfect-freehand](https://github.com/steveruizok/perfect-freehand) JavaScript library.
[Try out the demo](https://steveruizok.github.io/perfect-freehand-dart/)!

💕 Love this library? Consider becoming a sponsor for
[steveruizok](https://github.com/sponsors/steveruizok)
(the author of the original JavaScript library) or
[adil192](https://github.com/sponsors/adil192)
(the maintainer of the Dart package).

## Table of Contents

- [Installation](#installation)
- [Usage](#usage)
- [Community](#community)

## Introduction

This package exports a function named `getStroke` that will generate the points for a polygon based on an array of points.

![Screenshot](doc/assets/process.gif "A GIF showing a stroke with input points, outline points, and a curved path connecting these points")

To do this work, `getStroke` first creates a set of spline points (red) based on the input points (grey) and then creates outline points (blue). You can render the result any way you like, using whichever technology you prefer.

## Installation

This package is available on [pub.dev](https://pub.dev/packages/perfect_freehand)
and requires Flutter.
If you're using Dart without Flutter, check out versions `1.x.x` of this package.

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

List<PointVector> myPoints = [
  PointVector(0, 0),
  PointVector(1, 2),
  // etc...
];

final stroke = getStroke(myPoints);
```

You may also provide options to `getStroke`.
You'll most likely store the `StrokeOptions` object in a variable,
but you can also pass it directly to `getStroke`.

```dart
final stroke = getStroke(
  myPoints,
  options: StrokeOptions(
    size: 16,
    thinning: 0.7,
    smoothing: 0.5,
    streamline: 0.5,
    simulatePressure: true,
    start: StrokeEndOptions(
      cap: true,
      taperEnabled: true,
    ),
    end: StrokeEndOptions(
      cap: true,
      taperEnabled: true,
    ),
    isComplete: false,
  ),
);
```

To use real pressure, provide each point's pressure as a third parameter.

```dart
List<PointVector> myPoints = [
  PointVector(0, 0, 0.2),
  PointVector(1, 2, 0.3),
  PointVector(2, 4, 0.4),
  // etc...
];

final stroke = getStroke(
  myPoints,
  options: StrokeOptions(
    simulatePressure: false,
  ),
);
```

### Options

You can customize the stroke by passing a `StrokeOptions` object as the second parameter to `getStroke`.
This object accepts the following properties:

| Property             | Type             | Default | Description                                                                                                      |
| -------------------- | ---------------- | ------- | ---------------------------------------------------------------------------------------------------------------- |
| `size`               | double           | 16      | The base size (diameter) of the stroke.                                                                          |
| `thinning`           | double           | .5      | The effect of pressure on the stroke's size.                                                                     |
| `smoothing`          | double           | .5      | How much to soften the stroke's edges.                                                                           |
| `streamline`         | double           | .5      | How much to remove variation from the input points.                                                              |
| `simulatePressure`   | bool             | true    | Whether to simulate pressure based on distance between points, or else use the provided PointVectors' pressures. |
| `isComplete`         | bool             | true    | Whether the stroke is complete.                                                                                  |
| `start`              | StrokeEndOptions |         | How far to taper the start of the line.                                                                          |
| `end     `           | StrokeEndOptions |         | How far to taper the end of the line.                                                                            |
| `start.cap`          | bool             | true    | Whether to cap the start of the line.                                                                            |
| `start.taperEnabled` | bool             | false   | Whether to taper the start of the line.                                                                          |
| `start.customTaper`  | double           |         | A custom taper value for the start of the line, defaults to the total running length.                            |

Notes:
- When the `isComplete` property is `true`, the line's end will be drawn at the last input point, rather than slightly behind it.
- The `StrokeEndOptions.cap` property has no effect when `StrokeEndOptions.taperEnabled` is `true`.
- To create a stroke with a constant width, set the `thinning` option to `0`.
- To create a stroke that gets thinner with pressure instead of thicker, use a negative number for the `thinning` option.

### Rendering

While `getStroke` returns an array of points representing the outline of a stroke, it's up to you to decide how you will render these points.

See the `StrokePainter` class in the
[example project](https://github.com/steveruizok/perfect-freehand-dart/blob/main/example/lib/main.dart)
to see how you might draw these points in Flutter with a `CustomPainter`.

### Advanced Usage

For advanced usage, the library also exports smaller functions that `getStroke` uses to generate its outline points.

#### `getStrokePoints`

A function that accepts an array of `PointVector`s and returns a set of `StrokePoints`. The path's total length will be the `runningLength` of the last point in the array. Like `getStroke`, this function also accepts any of the [optional named parameters](#options) listed above.

```dart
List<PointVector> myPoints = [
  PointVector(0, 0),
  PointVector(1, 2),
  // etc...
];
final options = StrokeOptions(
  size: 16,
);

final strokePoints = getStrokePoints(myPoints, options: options);
```

#### `getOutlinePoints`

A function that accepts an array of StrokePoints (i.e. the output of `getStrokePoint`) and returns an array of Points defining the outline of a stroke. Like `getStroke`, this function also accepts any of the [optional named parameters](#options) listed above.

```dart
List<PointVector> myPoints = [
  PointVector(0, 0),
  PointVector(1, 2),
  // etc...
];
final options = StrokeOptions(
  size: 16,
);

final myStrokePoints = getStrokePoints(myPoints, options: options);

final myOutlinePoints = getStrokeOutlinePoints(myStrokePoints, options: options);
```

**Note:** Internally, the `getStroke` function passes the result of `getStrokePoints` to `getStrokeOutlinePoints`, just as shown in this example. This means that, in this example, the result of `myOutlinePoints` will be the same as if the `myPoints` List had been passed to `getStroke`.

#### `rememberSimulatedPressure`

Pressure simulation relies on the distance between points to determine the pressure at each point.
But in some scenarios, it would be wasteful to store all of these points.

The `rememberSimulatedPressure` argument solves this problem by calculating the pressure once
and then storing it in the original array of points.

```dart
/// Input points without pressure values
List<PointVector> myPoints = [/* ... */];

getStroke(
  myPoints,
  options: StrokeOptions(
    // isComplete and simulatePressure must be true for rememberSimulatedPressure
    simulatePressure: true,
    isComplete: true,
  ),
  rememberSimulatedPressure: true,
);

// myPoints now have pressure values (except for duplicate points)
print(myPoints[0].pressure); // (some number, not null)

// We are now free to compress myPoints however we want, e.g.
// this function removes duplicate points and points that are too close together:
void optimisePoints({double thresholdMultiplier = 0.1}) {
  if (points.length <= 3) return;

  final minDistance = strokeOptions.size * thresholdMultiplier;

  // Duplicate points have null pressure values, so we can remove them
  myPoints.removeWhere((point) => point.pressure == null);

  for (int i = 1; i < points.length - 1; i++) {
    final point = points[i];
    final prev = points[i - 1];
    final next = points[i + 1];

    if (prev.distanceSquaredTo(point) < minDistance * minDistance &&
        next.distanceSquaredTo(point) < minDistance * minDistance) {
      points.removeAt(i);
      i--;
    }
  }
}
```

## Community

### Support

Need help? Please [open an issue](https://github.com/steveruizok/perfect-freehand-dart/issues/new) for support.

### Discussion

Have an idea or casual question? Visit the [discussion page](https://github.com/steveruizok/perfect-freehand-dart/discussions).

### License

- MIT
- ...but if you're using `perfect-freehand` in a commercial product,
    consider becoming a sponsor for
    [steveruizok](https://github.com/sponsors/steveruizok)
    (the author of the original JavaScript library) or
    [adil192](https://github.com/sponsors/adil192)
    (the maintainer of the Dart package).. 💰
