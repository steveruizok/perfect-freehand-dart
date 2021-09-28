import 'dart:async';

import './perfect-freehand/stroke.dart';
import "./perfect-freehand/point.dart";
import "./sketcher.dart";
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class DrawingPage extends StatefulWidget {
  const DrawingPage({Key? key}) : super(key: key);

  @override
  _DrawingPageState createState() => _DrawingPageState();
}

class _DrawingPageState extends State<DrawingPage> {
  List<Stroke> lines = <Stroke>[];

  Stroke? line;

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
            children: [buildClearButton()]));
  }

  Widget buildClearButton() {
    return GestureDetector(
      onTap: clear,
      child: const CircleAvatar(
        child: Icon(
          Icons.replay,
          size: 20.0,
          color: Colors.white,
        ),
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
