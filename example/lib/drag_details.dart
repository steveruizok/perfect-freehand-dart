import 'dart:ui';

import 'package:flutter/material.dart';

class DragDetails {
  /// The kind of pointer device.
  final PointerDeviceKind? kind;

  /// The local position at which the function was called.
  final Offset localPosition;

  /// The pressure of the pointer on the screen. 0 - 1
  final double pressure;

  const DragDetails(this.localPosition, [this.kind, this.pressure = 0.5]);

  DragDetails.withPointer(PointerEvent pointerEvent)
      : localPosition = pointerEvent.localPosition,
        kind = pointerEvent.kind,
        pressure = pointerEvent.pressureMax != 0
            ? pointerEvent.pressure / pointerEvent.pressureMax
            : 0.5;
}
