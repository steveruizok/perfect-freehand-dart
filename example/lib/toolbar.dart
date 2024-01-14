import 'package:flutter/material.dart';
import 'package:perfect_freehand/perfect_freehand.dart';

class Toolbar extends StatelessWidget {
  const Toolbar({
    super.key,
    required this.options,
    required this.updateOptions,
    required this.clear,
  });

  final StrokeOptions options;
  final void Function(void Function(StrokeOptions)) updateOptions;
  final void Function() clear;

  static double identity(double t) => t;

  @override
  Widget build(BuildContext context) {
    print('Building toolbar, size: ${options.size}');
    return Positioned(
      top: 0,
      right: 0,
      width: 200,
      child: Card(
        margin: const EdgeInsets.all(10),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
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
                onChanged: (double value) => updateOptions((options) {
                  options.size = value;
                }),
              ),
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
                onChanged: (double value) => updateOptions((options) {
                  options.thinning = value;
                }),
              ),
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
                onChanged: (double value) => updateOptions((options) {
                  options.streamline = value;
                }),
              ),
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
                onChanged: (double value) => updateOptions((options) {
                  options.smoothing = value;
                }),
              ),
              const Text(
                'Taper Start',
                textAlign: TextAlign.start,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
              ),
              Switch(
                value: options.start.taperEnabled,
                onChanged: (bool value) => updateOptions((options) {
                  options.start.taperEnabled = value;
                }),
              ),
              const Text(
                'Taper End',
                textAlign: TextAlign.start,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
              ),
              Switch(
                value: options.end.taperEnabled,
                onChanged: (bool value) => updateOptions((options) {
                  options.end.taperEnabled = value;
                }),
              ),
              const Text(
                'Eased pressure',
                textAlign: TextAlign.start,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
              ),
              Switch(
                value: options.easing != identity,
                onChanged: (bool value) => updateOptions((options) {
                  final easing = value ? StrokeEasings.easeMiddle : identity;
                  StrokeOptions.defaultEasing = easing;
                  options.easing = easing;
                  options.start.easing = easing;
                  options.end.easing = easing;
                }),
              ),
              const Text(
                'Clear',
                textAlign: TextAlign.start,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
              ),
              IconButton(
                icon: const Icon(Icons.replay),
                onPressed: clear,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
