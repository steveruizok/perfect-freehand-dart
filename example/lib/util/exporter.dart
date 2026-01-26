import 'dart:convert';
import 'dart:math';

import 'package:file_saver/file_saver.dart';
import 'package:flutter/widgets.dart';
import 'package:perfect_freehand/perfect_freehand.dart';

import '../main.dart';

abstract class Exporter {
  /// Exports the canvas as an SVG and returns the resulting file path.
  static Future<String> export(
    CanvasController controller,
    StrokeOptions strokeOptions,
  ) async {
    final svg = controller.toSvg(strokeOptions);
    return await FileSaver.instance.saveFile(
      name: 'freehand',
      bytes: utf8.encode(svg),
      fileExtension: 'svg',
      mimeType: MimeType.svg,
    );
  }
}

extension on CanvasController {
  String toSvg(StrokeOptions strokeOptions) {
    final bounds = getBounds(strokeOptions);
    final buffer = StringBuffer();
    buffer.write(
      '<svg width="${bounds.width}" height="${bounds.height}" '
      'viewBox="${bounds.left} ${bounds.top} ${bounds.width} ${bounds.height}" '
      'xmlns="http://www.w3.org/2000/svg">\n',
    );
    for (var stroke in strokes) {
      buffer.write('<path d="');
      final outlinePoints = getStroke(stroke.points, options: strokeOptions);
      for (var i = 0; i < outlinePoints.length - 1; ++i) {
        if (i == 0) {
          buffer.writeAll([
            'M',
            outlinePoints[i].dx.toStringAsFixed(2),
            ' ',
            outlinePoints[i].dy.toStringAsFixed(2),
          ]);
        } else {
          final p0 = outlinePoints[i];
          final p1 = outlinePoints[i + 1];
          final midpoint = (p0 + p1) / 2;
          buffer.writeAll([
            'Q',
            p0.dx.toStringAsFixed(2),
            ' ',
            p0.dy.toStringAsFixed(2),
            ' ',
            midpoint.dx.toStringAsFixed(2),
            ' ',
            midpoint.dy.toStringAsFixed(2),
          ]);
        }
      }
      buffer.write('Z" fill="currentColor"/>\n');
    }
    buffer.write('</svg>');
    return buffer.toString();
  }

  Rect getBounds(StrokeOptions strokeOptions) {
    var minX = double.infinity;
    var minY = double.infinity;
    var maxX = double.negativeInfinity;
    var maxY = double.negativeInfinity;

    for (var stroke in strokes) {
      for (var point in stroke.points) {
        minX = min(minX, point.x);
        minY = min(minY, point.y);
        maxX = max(maxX, point.x);
        maxY = max(maxY, point.y);
      }
    }

    minX -= strokeOptions.size / 2;
    minY -= strokeOptions.size / 2;
    maxX += strokeOptions.size / 2;
    maxY += strokeOptions.size / 2;

    return Rect.fromLTRB(minX, minY, maxX, maxY);
  }
}
