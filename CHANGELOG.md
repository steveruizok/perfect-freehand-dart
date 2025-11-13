## 2.5.1

- Fix: Fixed NaN values appearing with some inputs, especially those with non-null pressure values.

## 2.5.0

- Fix: Path segments (separated by sharp angles) are now properly connected, preventing unexpected thinness at elbows.
- Fix: Right angles are now properly treated as sharp angles (so the corner can be rounded out).
- Fix: Less detail is lost near the end of a stroke. This results in less flickering while drawing.
- Fix: `PointVector.lerp` better handles the case when one point has a non-null pressure and the other has a null pressure.

Before and after with sharp corners:

<img width="300" height="180" alt="v2.4.0" src="https://github.com/user-attachments/assets/46951a57-3f29-4792-97fd-3383627aa5f0" /> <img width="300" height="180" alt="v2.5.0" src="https://github.com/user-attachments/assets/110267f5-3dfd-4223-bb06-30accbaf4146" />

You can see more before/after comparison images in the [Fix elbows and sharp corners, #24](https://github.com/steveruizok/perfect-freehand-dart/pull/24) pull request.

As always, you can demo the new version in the [online demo](https://steveruizok.github.io/perfect-freehand-dart/).

## 2.4.1

- Round stroke end caps are now full circles again (i.e. the change from 2.4.0 was reverted). This fixes sharp corners caused by small turns at the end of a stroke: see [#23](https://github.com/steveruizok/perfect-freehand-dart/issues/23) for more details.

## 2.4.0+1

- Fixed image not loading on pub.dev README

## 2.4.0

- Round stroke end caps are now half circles instead of full circles, reducing unnecessary polygon points, thanks to @dodgog in [#14](https://github.com/steveruizok/perfect-freehand-dart/pull/14).
- Fixed a bug when using the `rememberSimulatedPressure` flag with a list of exactly 2 points, thanks to @ZebraVogel94349 in [#21](https://github.com/steveruizok/perfect-freehand-dart/pull/21).
- Implemented `PointVector.toString()`.

## 2.3.2

- Fixed an error in `toJson()` when `taperEnabled` is true but `customTaper` is null.

## 2.3.1

- Fixed an error that occured when trying to lerp a NaN point.

## 2.3.0

- Added `toJson()` and `fromJson()` methods to `StrokeOptions`.

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
