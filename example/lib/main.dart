import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:perfect_freehand/perfect_freehand.dart';

import 'components/footer.dart';
import 'components/header.dart';
import 'components/menu.dart';
import 'util/hey.dart';
import 'util/theme.dart';
import 'util/transform_stroke.dart';

void main() {
  runApp(const DemoApp());
}

class DemoApp extends StatelessWidget {
  const DemoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'perfect_freehand',
      theme: createTheme(brightness: .light),
      darkTheme: createTheme(brightness: .dark),
      home: const DemoPage(),
    );
  }
}

class DemoPage extends HookWidget {
  const DemoPage({super.key});

  @override
  Widget build(BuildContext context) {
    final showMenu = useState(true);
    final strokeOptions = useState(StrokeOptions());
    final controller = useMemoized(
      () => CanvasController(screenSize: MediaQuery.sizeOf(context)),
    );

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: CanvasWidget(
              strokeOptions: strokeOptions,
              controller: controller,
            ),
          ),
          Column(
            crossAxisAlignment: .start,
            children: [
              Center(child: Header()),
              Expanded(
                child: Align(
                  alignment: AlignmentDirectional.bottomStart,
                  child: IgnorePointer(
                    ignoring: !showMenu.value,
                    child: AnimatedOpacity(
                      opacity: showMenu.value ? 1 : 0,
                      duration: const Duration(milliseconds: 200),
                      curve: Curves.easeOut,
                      child: Menu(strokeOptions: strokeOptions),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 64),
            ],
          ),
        ],
      ),
      floatingActionButton: Footer(showMenu: showMenu, controller: controller),
      floatingActionButtonLocation: .startFloat,
    );
  }
}

class CanvasWidget extends HookWidget {
  const CanvasWidget({
    super.key,
    required this.strokeOptions,
    required this.controller,
  });

  final ValueNotifier<StrokeOptions> strokeOptions;
  final CanvasController controller;

  void onPointerDown(PointerDownEvent details) {
    final pressureSensitive = details.pressureMin < 1;
    final point = PointVector(
      details.localPosition.dx,
      details.localPosition.dy,
      pressureSensitive ? details.pressure : null,
    );
    controller.currentStroke = DemoStroke([point]);
  }

  void onPointerMove(PointerMoveEvent details) {
    final pressureSensitive = details.pressureMin < 1;
    final point = PointVector(
      details.localPosition.dx,
      details.localPosition.dy,
      pressureSensitive ? details.pressure : null,
    );
    controller.currentStroke = DemoStroke([
      ...controller.currentStroke!.points,
      point,
    ]);
  }

  void onPointerUp(PointerUpEvent details) {
    controller.strokes = [...controller.strokes, controller.currentStroke!];
    controller.currentStroke = null;
  }

  @override
  Widget build(BuildContext context) {
    useListenable(controller);
    final strokeOptions = useValueListenable(this.strokeOptions);
    final strokeColor = ColorScheme.of(context).onSurface;
    return Listener(
      onPointerDown: (details) => onPointerDown(details),
      onPointerMove: (details) => onPointerMove(details),
      onPointerUp: (details) => onPointerUp(details),
      child: CustomPaint(
        painter: StrokePainter(
          strokeOptions: strokeOptions,
          color: strokeColor,
          strokes: controller.strokes,
        ),
        foregroundPainter: StrokePainter(
          strokeOptions: strokeOptions,
          color: strokeColor,
          strokes: [?controller.currentStroke],
        ),
      ),
    );
  }
}

class StrokePainter extends CustomPainter {
  const StrokePainter({
    required this.strokeOptions,
    required this.color,
    required this.strokes,
  });

  final StrokeOptions strokeOptions;
  final Color color;
  final List<DemoStroke> strokes;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    for (final stroke in strokes) {
      canvas.drawPath(stroke.createPath(strokeOptions), paint);
    }
  }

  @override
  bool shouldRepaint(StrokePainter oldDelegate) =>
      oldDelegate != this || strokes != oldDelegate.strokes;
}

class CanvasController extends ChangeNotifier {
  CanvasController({required Size screenSize}) {
    final heyStroke = transformExampleStroke(hey, screenSize);
    _strokes.add(heyStroke);
  }

  List<DemoStroke> get strokes => _strokes;
  List<DemoStroke> _strokes = <DemoStroke>[];
  set strokes(List<DemoStroke> value) {
    _strokes = value;
    notifyListeners();
  }

  DemoStroke? get currentStroke => _currentStroke;
  DemoStroke? _currentStroke;
  set currentStroke(DemoStroke? value) {
    _currentStroke = value;
    notifyListeners();
  }

  void undo() {
    strokes.removeLast();
    notifyListeners();
  }

  void clear() {
    strokes = [];
    currentStroke = null;
  }
}

class DemoStroke {
  DemoStroke(this.points);

  final List<PointVector> points;

  /// For demo purposes, we aren't caching the result so the user can adjust
  /// the stroke options for all strokes at once.
  /// In a real app, you should store the resulting Path and only recreate it
  /// if the input points changed.
  Path createPath(StrokeOptions strokeOptions) {
    final outlinePoints = getStroke(points, options: strokeOptions);

    final path = Path();
    if (outlinePoints.isEmpty) return path;
    path.moveTo(outlinePoints.first.dx, outlinePoints.first.dy);
    for (int i = 0; i < outlinePoints.length - 1; ++i) {
      final p0 = outlinePoints[i];
      final p1 = outlinePoints[i + 1];
      path.quadraticBezierTo(
        p0.dx,
        p0.dy,
        (p0.dx + p1.dx) / 2,
        (p0.dy + p1.dy) / 2,
      );
    }
    return path;
  }
}
