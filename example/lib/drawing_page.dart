import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:perfect_freehand/perfect_freehand.dart';

import 'drag_details.dart';
import 'sketcher.dart';
import 'stroke.dart';
import 'stroke_options.dart';

class DrawingPage extends StatefulWidget {
  const DrawingPage({Key? key, this.outCallback, required this.canvasSize})
      : super(key: key);

  final Function? outCallback;
  final Size canvasSize;

  @override
  State<DrawingPage> createState() => DrawingPageState();
}

class DrawingPageState extends State<DrawingPage> {
  List<Stroke> lines = <Stroke>[];

  Stroke? line;
  bool enabled = true;

  StrokeOptions options = StrokeOptions();
  ui.PointerDeviceKind? kind;

  StreamController<Stroke> currentLineStreamController =
      StreamController<Stroke>.broadcast();

  StreamController<List<Stroke>> linesStreamController =
      StreamController<List<Stroke>>.broadcast();

  Future<void> clear() async {
    setState(() {
      lines = [];
      line = null;
      enabled = true;
      kind = null;
    });
  }

  Future<void> image(BuildContext context) async {
    final image = await toImage();
    final futureBytes = await image.toByteData(format: ui.ImageByteFormat.png);
    final pngBytes = futureBytes!.buffer.asUint8List();

    showDialog(
      context: context,
      builder: (ctx) {
        return Dialog(
          elevation: 1,
          insetPadding: const EdgeInsets.all(32.0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0),
          ),
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: SizedBox(
              height: 500,
              width: 500,
              child: Image.memory(pngBytes),
            ),
          ),
        );
      },
    );
  }

  Future<void> updateSizeOption(double size) async {
    setState(() {
      options.size = size;
    });
  }

  void onTouchEventStart(DragDetails details) {
    final box = context.findRenderObject() as RenderBox;
    if (checkPoint(
        Point(details.localPosition.dx, details.localPosition.dy), box.size)) {
      final offset = details.localPosition;
      Point point = Point(offset.dx, offset.dy, details.pressure);
      final points = [point];
      line = Stroke(points);
      currentLineStreamController.add(line!);
    }
  }

  void onTouchEventUpdate(DragDetails details) {
    final box = context.findRenderObject() as RenderBox;
    if (checkPoint(
        Point(details.localPosition.dx, details.localPosition.dy), box.size)) {
      final offset = details.localPosition;
      final point = Point(offset.dx, offset.dy, details.pressure);
      final points = [...line!.points, point];
      line = Stroke(points);
      currentLineStreamController.add(line!);
    }
  }

  void onTouchEventEnd() {
    if (enabled) {
      lines = List.from(lines)..add(line!);
      linesStreamController.add(lines);
    }
  }

  Widget buildCurrentPath(BuildContext context) {
    final child = RepaintBoundary(
      child: Container(
        color: Colors.transparent,
        width: double.infinity,
        height: double.infinity,
        child: StreamBuilder<Stroke>(
          stream: currentLineStreamController.stream,
          builder: (context, snapshot) {
            return CustomPaint(
              painter: Sketcher(
                lines: line == null ? [] : [line!],
                options: options,
              ),
            );
          },
        ),
      ),
    );

    return Listener(
      onPointerDown: (event) {
        if (kind == ui.PointerDeviceKind.stylus &&
            event.kind == ui.PointerDeviceKind.touch) {
          return;
        }
        if (kind == ui.PointerDeviceKind.touch &&
            event.kind == ui.PointerDeviceKind.stylus) {
          clear();
        }
        kind = event.kind;
        onTouchEventStart(DragDetails.withPointer(event));
      },
      onPointerMove: (event) {
        if (kind == ui.PointerDeviceKind.stylus &&
            event.kind == ui.PointerDeviceKind.touch) {
          return;
        }
        kind = event.kind;
        onTouchEventUpdate(DragDetails.withPointer(event));
      },
      onPointerUp: (event) {
        if (kind == ui.PointerDeviceKind.stylus &&
            event.kind == ui.PointerDeviceKind.touch) {
          return;
        }
        onTouchEventEnd();
      },
      child: child,
    );
  }

  Widget buildAllPaths(BuildContext context) {
    return RepaintBoundary(
      child: Container(
        color: Colors.transparent,
        width: double.infinity,
        height: double.infinity,
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
                'Simulate pressure',
                textAlign: TextAlign.start,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
              ),
              Checkbox(
                  value: options.simulatePressure,
                  onChanged: (status) {
                    clear();
                    setState(() {
                      options = StrokeOptions(simulatePressure: status!);
                    });
                  }),
              buildButtons(context),
            ]));
  }

  Widget buildButtons(BuildContext context) {
    return Row(
      children: [
        Column(children: [
          const Text(
            'Picture',
            textAlign: TextAlign.start,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
          ),
          GestureDetector(
            onTap: () {
              image(context);
            },
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: const CircleAvatar(
                  child: Icon(
                Icons.image,
                size: 20.0,
                color: Colors.white,
              )),
            ),
          ),
        ]),
        VerticalDivider(width: 30),
        Column(
          children: [
            const Text(
              'Clear',
              textAlign: TextAlign.start,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
            ),
            GestureDetector(
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
            ),
          ],
        ),
      ],
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

  bool isValidPoint(Point p, Size s) {
    bool result = p.x > 0 && p.y > 0 && p.x < s.width && p.y < s.height;
    return result;
  }

  bool checkPoint(Point p, Size s) {
    bool isValid = isValidPoint(p, s);
    if (!isValid && enabled && widget.outCallback != null) {
      enabled = false;
      widget.outCallback!();
    }
    return enabled && isValid;
  }

  Future<ui.Image> toImage() async {
    final ui.PictureRecorder recorder = ui.PictureRecorder();

    final ui.Canvas canvas = Canvas(recorder);

    final sketcher = Sketcher(lines: lines, options: options);
    final size = widget.canvasSize;
    sketcher.paint(canvas, size);

    final ui.Picture picture = recorder.endRecording();
    return picture.toImage(size.width.toInt(), size.height.toInt());
  }
}
