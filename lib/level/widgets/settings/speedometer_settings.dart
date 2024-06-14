import 'package:flutter/material.dart';
import 'package:flutter_spinbox/flutter_spinbox.dart';
import 'package:twin_commons/level/widgets/gauge.dart';
import 'package:twin_commons/core/sensor_widget.dart';

class SpeedometerSettings extends StatefulWidget {
  final String label;
  final String unit;
  final Map<String, dynamic> settings;
  final OnSettingsSaved onSettingsSaved;

  const SpeedometerSettings(
      {super.key,
      required this.settings,
      required this.onSettingsSaved,
      required this.label,
      required this.unit});

  @override
  State<SpeedometerSettings> createState() => _SpeedometerSettingsState();
}

class _SpeedometerSettingsState extends State<SpeedometerSettings> {
  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        SizedBox(
          width: 120,
          height: 120,
          child: Gauge(
            tiny: false,
            min: widget.settings['minValue'] ?? 0,
            max: widget.settings['maxValue'] ?? 250,
            interval: widget.settings['interval'] ?? 5,
            startAngle: widget.settings['startAngle'] ?? 45,
            endAngle: widget.settings['endAngle'] ?? 15,
            fontSize: widget.settings['fontSize'] ?? 12,
            fontWeight: widget.settings['fontBold'] ?? true
                ? FontWeight.bold
                : FontWeight.normal,
            label: widget.label,
            unit: widget.unit,
            value: 0,
          ),
        ),
        Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Min Value'),
                SizedBox(
                  width: 180,
                  child: SpinBox(
                    value: widget.settings['minValue'] ?? 0,
                    min: 0,
                    max: 3000,
                    onChanged: (value) =>
                        setState(() => widget.settings['minValue'] = value),
                  ),
                ),
              ],
            ),
            const SizedBox(
              height: 8,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Max Value'),
                SizedBox(
                  width: 180,
                  child: SpinBox(
                    value: widget.settings['maxValue'] ?? 250,
                    min: 0,
                    max: 3000,
                    onChanged: (value) =>
                        setState(() => widget.settings['maxValue'] = value),
                  ),
                ),
              ],
            ),
            const SizedBox(
              height: 8,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Dial Interval'),
                SizedBox(
                  width: 180,
                  child: SpinBox(
                    value: widget.settings['interval'] ?? 5,
                    min: 0,
                    max: 10,
                    onChanged: (value) =>
                        setState(() => widget.settings['interval'] = value),
                  ),
                ),
              ],
            ),
            const SizedBox(
              height: 8,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Start Angle'),
                SizedBox(
                  width: 180,
                  child: SpinBox(
                    value: widget.settings['startAngle'] ?? 45,
                    min: 0,
                    max: 360,
                    onChanged: (value) =>
                        setState(() => widget.settings['startAngle'] = value),
                  ),
                ),
              ],
            ),
            const SizedBox(
              height: 8,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('End Angle'),
                SizedBox(
                  width: 180,
                  child: SpinBox(
                    value: widget.settings['endAngle'] ?? 15,
                    min: 0,
                    max: 360,
                    onChanged: (value) =>
                        setState(() => widget.settings['endAngle'] = value),
                  ),
                ),
              ],
            ),
            const SizedBox(
              height: 8,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Font Size'),
                SizedBox(
                  width: 180,
                  child: SpinBox(
                    value: widget.settings['fontSize'] ?? 10,
                    min: 0,
                    max: 30,
                    onChanged: (value) =>
                        setState(() => widget.settings['fontSize'] = value),
                  ),
                ),
              ],
            ),
            const SizedBox(
              height: 8,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Bold Font'),
                Checkbox(
                  value: widget.settings['fontBold'] ?? true,
                  onChanged: (value) =>
                      setState(() => widget.settings['fontBold'] = value),
                )
              ],
            ),
            const SizedBox(
              height: 8,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text('Cancel')),
                const SizedBox(
                  width: 8,
                ),
                ElevatedButton(
                    onPressed: () {
                      widget.onSettingsSaved(widget.settings);
                      Navigator.pop(context);
                    },
                    child: const Text('Save')),
                const SizedBox(
                  width: 8,
                ),
              ],
            )
          ],
        )
      ],
    );
  }
}
