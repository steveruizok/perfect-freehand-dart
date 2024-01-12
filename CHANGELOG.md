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
