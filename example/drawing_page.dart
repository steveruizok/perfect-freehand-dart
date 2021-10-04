import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:perfect_freehand/perfect_freehand.dart';

import "./sketcher.dart";

class DrawingPage extends StatefulWidget {
  const DrawingPage({Key? key}) : super(key: key);

  @override
  _DrawingPageState createState() => _DrawingPageState();
}

class _DrawingPageState extends State<DrawingPage> {
  List<Stroke> lines = <Stroke>[];

  Stroke? line;

  StrokeOptions options = StrokeOptions();

  StreamController<Stroke> currentLineStreamController =
      StreamController<Stroke>.broadcast();

  StreamController<List<Stroke>> linesStreamController =
      StreamController<List<Stroke>>.broadcast();

  Future<void> clear() async {
    setState(() {
      lines = [];
      line = null;
    });
  }

  Future<void> updateSizeOption(double size) async {
    setState(() {
      options.size = size;
    });
  }

  void onPanStart(DragStartDetails details) {
    final box = context.findRenderObject() as RenderBox;
    final offset = box.globalToLocal(details.globalPosition);
    final point = Point(offset.dx, offset.dy);
    final path = [point];
    line = Stroke(path, false);
    currentLineStreamController.add(line!);
  }

  void onPanUpdate(DragUpdateDetails details) {
    final box = context.findRenderObject() as RenderBox;
    final offset = box.globalToLocal(details.globalPosition);
    final point = Point(offset.dx, offset.dy);
    final path = [...line!.path, point];
    line = Stroke(path, false);
    currentLineStreamController.add(line!);
  }

  void onPanEnd(DragEndDetails details) {
    lines = List.from(lines)..add(line!);
    linesStreamController.add(lines);
  }

  Widget buildCurrentPath(BuildContext context) {
    return GestureDetector(
      onPanStart: onPanStart,
      onPanUpdate: onPanUpdate,
      onPanEnd: onPanEnd,
      child: RepaintBoundary(
        child: Container(
            color: Colors.transparent,
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            child: StreamBuilder<Stroke>(
                stream: currentLineStreamController.stream,
                builder: (context, snapshot) {
                  return CustomPaint(
                    painter: Sketcher(
                      lines: line == null ? [] : [line!],
                      options: options,
                    ),
                  );
                })),
      ),
    );
  }

  Widget buildAllPaths(BuildContext context) {
    return RepaintBoundary(
      child: SizedBox(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: StreamBuilder<List<Stroke>>(
          stream: linesStreamController.stream,
          builder: (context, snapshot) {
            return CustomPaint(
              painter: Sketcher(
                lines: lines,
                options: options,
              ),
            );
          },
        ),
      ),
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
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
              ),
              Slider(
                  value: options.size,
                  min: 1,
                  max: 50,
                  divisions: 100,
                  label: options.size.round().toString(),
                  onChanged: (double value) => {
                        setState(() {
                          options.size = value;
                        })
                      }),
              const Text(
                'Thinning',
                textAlign: TextAlign.start,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
              ),
              Slider(
                  value: options.thinning,
                  min: -1,
                  max: 1,
                  divisions: 100,
                  label: options.thinning.toStringAsFixed(2),
                  onChanged: (double value) => {
                        setState(() {
                          options.thinning = value;
                        })
                      }),
              const Text(
                'Streamline',
                textAlign: TextAlign.start,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
              ),
              Slider(
                  value: options.streamline,
                  min: 0,
                  max: 1,
                  divisions: 100,
                  label: options.streamline.toStringAsFixed(2),
                  onChanged: (double value) => {
                        setState(() {
                          options.streamline = value;
                        })
                      }),
              const Text(
                'Smoothing',
                textAlign: TextAlign.start,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
              ),
              Slider(
                  value: options.smoothing,
                  min: 0,
                  max: 1,
                  divisions: 100,
                  label: options.smoothing.toStringAsFixed(2),
                  onChanged: (double value) => {
                        setState(() {
                          options.smoothing = value;
                        })
                      }),
              const Text(
                'Taper Start',
                textAlign: TextAlign.start,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
              ),
              Slider(
                  value: options.taperStart,
                  min: 0,
                  max: 100,
                  divisions: 100,
                  label: options.taperStart.toStringAsFixed(2),
                  onChanged: (double value) => {
                        setState(() {
                          options.taperStart = value;
                        })
                      }),
              const Text(
                'Taper End',
                textAlign: TextAlign.start,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
              ),
              Slider(
                  value: options.taperEnd,
                  min: 0,
                  max: 100,
                  divisions: 100,
                  label: options.taperEnd.toStringAsFixed(2),
                  onChanged: (double value) => {
                        setState(() {
                          options.taperEnd = value;
                        })
                      }),
              const Text(
                'Clear',
                textAlign: TextAlign.start,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
              ),
              buildClearButton(),
            ]));
  }

  Widget buildClearButton() {
    return GestureDetector(
      onTap: clear,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: const CircleAvatar(
            child: Icon(
          Icons.replay,
          size: 20.0,
          color: Colors.white,
        )),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          buildAllPaths(context),
          buildCurrentPath(context),
          buildToolbar()
        ],
      ),
    );
  }

  @override
  void dispose() {
    linesStreamController.close();
    currentLineStreamController.close();
    super.dispose();
  }
}
