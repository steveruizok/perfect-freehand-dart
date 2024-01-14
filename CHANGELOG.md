## 2.2.1

- The default easing function is now `StrokeEasings.easeMiddle` instead of a linear function. This makes strokes' pressure easier to control as the pressure stays around the middle for longer. You can still use the linear easing function by setting `StrokeOptions.easing` and `StrokeEndOptions.easing`.

![Graph of easeMiddle which starts fast, slows down around the middle, then ends fast](https://github.com/steveruizok/perfect-freehand-dart/assets/21128619/23aa63bb-e00c-4d56-bcd3-74275ebea141)

## 2.2.0

- Breaking change: The properties of `StrokeOptions` are now non-nullable. This means that e.g. `StrokeOptions.smoothing` now defaults to `StrokeOptions.defaultSmoothing` instead of `null`. Note that you can change the defaults.

## 2.1.0

- Breaking change: `getStroke(points, options)` is now `getStroke(points, options: options)`.
- You can now run `getStroke(points, rememberSimulatedPressure: true)` to store the simulated pressure values in the `points` list. ([#12](https://github.com/steveruizok/perfect-freehand-dart/issues/12))

## 2.0.1

- Fixed an edge case where we have an input of two equal points.

## 2.0.0

- 2.0.0 is a complete re-port of the original JavaScript library to Dart. There are some breaking changes, but the API is mostly the same and some automatic migration is possible by running `dart fix --apply`.

## 1.0.4

- One more fix to README.

## 1.0.3

- Pub score optimizations.
- Improve README.
- Add FUNDING.

## 1.0.2

- Fix README.

## 1.0.1

- Fix README.

## 1.0.0

- Initial version
