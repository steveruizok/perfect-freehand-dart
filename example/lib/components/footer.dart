import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:perfect_freehand/perfect_freehand.dart';

import '../main.dart';
import '../util/exporter.dart';

class Footer extends HookWidget {
  const Footer({
    super.key,
    required this.showMenu,
    required this.strokeOptions,
    required this.controller,
  });

  final ValueNotifier<bool> showMenu;
  final ValueNotifier<StrokeOptions> strokeOptions;
  final CanvasController controller;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final borderRadius = BorderRadius.circular(64);
    final tonalButtonStyle = IconButton.styleFrom(
      backgroundColor: Colors.transparent,
      disabledBackgroundColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: borderRadius),
    );
    return Row(
      children: [
        IconButton.filled(
          style: IconButton.styleFrom(
            shape: RoundedSuperellipseBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            iconSize: 36,
          ),
          onPressed: () => showMenu.value = !showMenu.value,
          tooltip: 'Stroke options',
          icon: Icon(Icons.tune),
        ),
        SizedBox(width: 8),
        Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.secondaryContainer,
            borderRadius: borderRadius,
          ),
          child: Row(
            children: [
              IconButton.filledTonal(
                style: tonalButtonStyle,
                onPressed: controller.undo,
                tooltip: 'Undo',
                icon: Icon(Icons.backspace),
              ),
              IconButton.filledTonal(
                style: tonalButtonStyle,
                onPressed: controller.clear,
                tooltip: 'Clear',
                icon: Icon(Icons.delete),
              ),
              IconButton.filledTonal(
                style: tonalButtonStyle,
                onPressed: () async {
                  final result = await Exporter.export(
                    controller,
                    strokeOptions.value,
                    theme.colorScheme,
                  );
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Exported to $result')),
                    );
                  }
                },
                tooltip: 'Export',
                icon: Icon(Icons.file_download),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
