import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import "package:perfect_freehand/perfect_freehand.dart";

import "sketcher.dart";

class DrawingPage extends StatefulWidget {
  const DrawingPage({
    Key? key,
  }) : super(
          key: key,
        );

  @override
  _DrawingPageState createState() => _DrawingPageState();
}

class _DrawingPageState extends State<DrawingPage> {
  Stroke? line;
  List<Stroke> lines = <Stroke>[];
  StrokeOptions options = StrokeOptions();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        fit: StackFit.expand,
        children: [
          buildAllPaths(context),
          buildCurrentPath(context),
          buildToolbar(),
        ],
      ),
    );
  }

  Widget buildAllPaths(BuildContext context) {
    return RepaintBoundary(
      child: CustomPaint(
        painter: Sketcher(
          lines: lines,
          options: options,
        ),
      ),
    );
  }

  Widget buildCurrentPath(BuildContext context) {
    return GestureDetector(
      onPanStart: onPanStart,
      onPanUpdate: onPanUpdate,
      onPanEnd: onPanEnd,
      child: RepaintBoundary(
        child: Container(
          color: Colors.transparent,
          child: CustomPaint(
            painter: Sketcher(
              lines: () {
                if (line == null) {
                  return <Stroke>[];
                } else {
                  return [line!];
                }
              }(),
              options: options,
            ),
          ),
        ),
      ),
    );
  }

  void onPanStart(DragStartDetails details) {
    final offset = details.localPosition;
    final point = Point(offset.dx, offset.dy);
    final path = [point];
    setState(
      () => line = Stroke(path, false),
    );
  }

  void onPanEnd(DragEndDetails details) {
    setState(
      () => lines = List.from(lines)..add(line!),
    );
  }

  void onPanUpdate(DragUpdateDetails details) {
    final offset = details.localPosition;
    final point = Point(offset.dx, offset.dy);
    final path = [...line!.path, point];
    setState(
      () => line = Stroke(path, false),
    );
  }

  Widget buildToolbar() {
    return Positioned(
      top: 40.0,
      right: 10.0,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          const Text(
            'Size',
            textAlign: TextAlign.start,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
          Slider(
            value: options.size,
            min: 1,
            max: 50,
            divisions: 100,
            label: options.size.round().toString(),
            onChanged: (value) => setState(
              () => options.size = value,
            ),
          ),
          const Text(
            'Thinning',
            textAlign: TextAlign.start,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
          Slider(
            value: options.thinning,
            min: -1,
            max: 1,
            divisions: 100,
            label: options.thinning.toStringAsFixed(2),
            onChanged: (value) => setState(
              () => options.thinning = value,
            ),
          ),
          const Text(
            'Streamline',
            textAlign: TextAlign.start,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
          Slider(
            value: options.streamline,
            min: 0,
            max: 1,
            divisions: 100,
            label: options.streamline.toStringAsFixed(2),
            onChanged: (value) => setState(
              () => options.streamline = value,
            ),
          ),
          const Text(
            'Smoothing',
            textAlign: TextAlign.start,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
          Slider(
            value: options.smoothing,
            min: 0,
            max: 1,
            divisions: 100,
            label: options.smoothing.toStringAsFixed(2),
            onChanged: (value) => setState(
              () => options.smoothing = value,
            ),
          ),
          const Text(
            'Taper Start',
            textAlign: TextAlign.start,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
          Slider(
            value: options.taperStart,
            min: 0,
            max: 100,
            divisions: 100,
            label: options.taperStart.toStringAsFixed(2),
            onChanged: (value) => setState(
              () => options.taperStart = value,
            ),
          ),
          const Text(
            'Taper End',
            textAlign: TextAlign.start,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
          Slider(
            value: options.taperEnd,
            min: 0,
            max: 100,
            divisions: 100,
            label: options.taperEnd.toStringAsFixed(2),
            onChanged: (double value) => setState(
              () => options.taperEnd = value,
            ),
          ),
          const Text(
            'Clear',
            textAlign: TextAlign.start,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
          buildClearButton(),
        ],
      ),
    );
  }

  Widget buildClearButton() {
    return GestureDetector(
      onTap: clear,
      child: Container(
        padding: const EdgeInsets.symmetric(
          vertical: 8.0,
        ),
        child: const CircleAvatar(
          child: Icon(
            Icons.replay,
            size: 20.0,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Future<void> clear() async {
    setState(() {
      lines = [];
      line = null;
    });
  }
}
