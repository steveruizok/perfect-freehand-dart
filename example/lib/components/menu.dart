import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:perfect_freehand/perfect_freehand.dart';

class Menu extends HookWidget {
  const Menu({super.key, required this.strokeOptions});

  final ValueNotifier<StrokeOptions> strokeOptions;

  @override
  Widget build(BuildContext context) {
    final colorScheme = ColorScheme.of(context);
    useListenable(strokeOptions);
    return Container(
      width: 400,
      padding: .all(16),
      margin: .all(16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainer.withValues(alpha: 0.96),
        borderRadius: .circular(16),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: .min,
          children: [
            _SliderRow(
              title: 'Size',
              value: strokeOptions.value.size,
              formatValue: (value) => value.round().toString(),
              min: 1,
              max: 51,
              onChanged: (double value) {
                strokeOptions.value = strokeOptions.value.copyWith(size: value);
              },
            ),
            _SliderRow(
              title: 'Thinning',
              value: strokeOptions.value.thinning,
              min: 0,
              max: 1,
              onChanged: (double value) {
                strokeOptions.value = strokeOptions.value.copyWith(
                  thinning: value,
                );
              },
            ),
            _SliderRow(
              title: 'Streamline',
              value: strokeOptions.value.streamline,
              min: 0,
              max: 1,
              onChanged: (double value) {
                strokeOptions.value = strokeOptions.value.copyWith(
                  streamline: value,
                );
              },
            ),
            _SliderRow(
              title: 'Smoothing',
              value: strokeOptions.value.smoothing,
              min: 0,
              max: 1,
              onChanged: (double value) {
                strokeOptions.value = strokeOptions.value.copyWith(
                  smoothing: value,
                );
              },
            ),
            _EasingDropdownRow(
              title: 'Easing',
              value: strokeOptions.value.easing,
              onChanged: (easing) {
                strokeOptions.value = strokeOptions.value.copyWith(
                  easing: easing,
                );
              },
            ),

            Divider(),

            _SliderRow(
              title: 'Start taper',
              value: strokeOptions.value.start.taperEnabled
                  ? strokeOptions.value.start.customTaper ?? 100
                  : 0,
              formatValue: (taper) => switch (taper) {
                <= 0 => 'off',
                < 100 => taper.round().toString(),
                _ => 'on',
              },
              min: 0,
              max: 100,
              onChanged: (taper) {
                strokeOptions.value = strokeOptions.value.copyWith(
                  start: strokeOptions.value.start.copyWith(
                    taperEnabled: taper > 0,
                    customTaper: switch (taper) {
                      <= 0 => null,
                      < 100 => taper,
                      _ => null,
                    },
                  ),
                );
              },
            ),
            if (strokeOptions.value.start.taperEnabled)
              _EasingDropdownRow(
                title: 'Start easing',
                value: strokeOptions.value.start.easing,
                onChanged: (easing) =>
                    strokeOptions.value = strokeOptions.value.copyWith(
                      start: strokeOptions.value.start.copyWith(
                        easing: easing,
                        customTaper: strokeOptions.value.start.customTaper,
                      ),
                    ),
              )
            else
              _CheckboxRow(
                title: 'Start cap',
                value: strokeOptions.value.start.cap,
                onChanged: (cap) {
                  strokeOptions.value = strokeOptions.value.copyWith(
                    start: strokeOptions.value.start.copyWith(
                      cap: cap,
                      customTaper: null,
                    ),
                  );
                },
              ),

            Divider(),

            _SliderRow(
              title: 'End taper',
              value: strokeOptions.value.end.taperEnabled
                  ? strokeOptions.value.end.customTaper ?? 100
                  : 0,
              formatValue: (taper) => switch (taper) {
                <= 0 => 'off',
                < 100 => taper.round().toString(),
                _ => 'on',
              },
              min: 0,
              max: 100,
              onChanged: (taper) {
                strokeOptions.value = strokeOptions.value.copyWith(
                  end: strokeOptions.value.end.copyWith(
                    taperEnabled: taper > 0,
                    customTaper: switch (taper) {
                      <= 0 => null,
                      < 100 => taper,
                      _ => null,
                    },
                  ),
                );
              },
            ),
            if (strokeOptions.value.end.taperEnabled)
              _EasingDropdownRow(
                title: 'End easing',
                value: strokeOptions.value.end.easing,
                onChanged: (easing) =>
                    strokeOptions.value = strokeOptions.value.copyWith(
                      end: strokeOptions.value.end.copyWith(
                        easing: easing,
                        customTaper: strokeOptions.value.end.customTaper,
                      ),
                    ),
              )
            else
              _CheckboxRow(
                title: 'End cap',
                value: strokeOptions.value.end.cap,
                onChanged: (cap) {
                  strokeOptions.value = strokeOptions.value.copyWith(
                    end: strokeOptions.value.end.copyWith(
                      cap: cap,
                      customTaper: null,
                    ),
                  );
                },
              ),

            Divider(),

            _CheckboxRow(
              title: 'Simulate pressure',
              value: strokeOptions.value.simulatePressure,
              onChanged: (value) {
                strokeOptions.value = strokeOptions.value.copyWith(
                  simulatePressure: value,
                );
              },
            ),
            _CheckboxRow(
              title: 'Complete',
              value: strokeOptions.value.isComplete,
              onChanged: (value) {
                strokeOptions.value = strokeOptions.value.copyWith(
                  isComplete: value,
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _SliderRow extends StatelessWidget {
  const _SliderRow({
    required this.title,
    required this.value,
    this.formatValue,
    required this.min,
    required this.max,
    required this.onChanged,
  });

  final String title;
  final double value;
  final String Function(double value)? formatValue;
  final double min;
  final double max;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    final label = formatValue?.call(value) ?? value.toStringAsFixed(2);
    return _MenuRow(
      title: title,
      children: [
        Expanded(
          child: SizedBox(
            height: 32,
            child: SliderTheme(
              data: SliderThemeData(
                showValueIndicator: .never,
                // ignore: deprecated_member_use
                year2023: false,
                trackHeight: 8,
                thumbSize: thumbSize,
                padding: .symmetric(horizontal: 8),
              ),
              child: Slider(
                value: value,
                min: min,
                max: max,
                divisions: 20,
                label: label,
                onChanged: onChanged,
              ),
            ),
          ),
        ),
        SizedBox(width: 40, child: Text(label, textAlign: .end)),
      ],
    );
  }

  WidgetStateProperty<Size> get thumbSize {
    return WidgetStateProperty.resolveWith((Set<WidgetState> states) {
      if (states.contains(WidgetState.disabled)) return const Size(4, 28);
      if (states.contains(WidgetState.hovered)) return const Size(4, 28);
      if (states.contains(WidgetState.focused)) return const Size(2, 28);
      if (states.contains(WidgetState.pressed)) return const Size(2, 28);
      return const Size(4, 28);
    });
  }
}

class _CheckboxRow extends StatelessWidget {
  const _CheckboxRow({
    required this.title,
    required this.value,
    required this.onChanged,
  });

  final String title;
  final bool value;
  final ValueChanged<bool?> onChanged;

  @override
  Widget build(BuildContext context) {
    return _MenuRow(
      title: title,
      children: [
        SizedBox.square(
          dimension: 32,
          child: Checkbox.adaptive(value: value, onChanged: onChanged),
        ),
      ],
    );
  }
}

class _EasingDropdownRow extends StatelessWidget {
  const _EasingDropdownRow({
    required this.title,
    required this.value,
    required this.onChanged,
  });

  final String title;
  final double Function(double)? value;
  final ValueChanged<double Function(double)?> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return _MenuRow(
      title: title,
      children: [
        Expanded(
          child: Padding(
            padding: .symmetric(horizontal: 4),
            child: DropdownButtonHideUnderline(
              child: DropdownButton(
                value: value,
                onChanged: onChanged,
                isDense: true,
                padding: .symmetric(vertical: 4),
                style: theme.textTheme.bodyMedium,
                items: [
                  DropdownMenuItem(
                    value: StrokeEasings.identity,
                    child: Text('identity'),
                  ),
                  DropdownMenuItem(
                    value: StrokeEasings.easeInOut,
                    child: Text('easeInOut'),
                  ),
                  DropdownMenuItem(
                    value: StrokeEasings.easeOutCubic,
                    child: Text('easeOutCubic'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _MenuRow extends StatelessWidget {
  const _MenuRow({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Row(
      spacing: 8,
      children: [
        SizedBox(
          width: 132,
          child: Text(title, maxLines: 1, overflow: .ellipsis),
        ),
        ...children,
      ],
    );
  }
}
