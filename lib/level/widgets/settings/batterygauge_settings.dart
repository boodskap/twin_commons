import 'package:animated_battery_gauge/battery_gauge.dart';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:flutter_spinbox/flutter_spinbox.dart';
import 'package:twin_commons/level/widgets/battery_gauge.dart';
import 'package:twin_commons/core/sensor_widget.dart';
import 'package:uuid/uuid.dart';

class BatteryGaugeSettings extends StatefulWidget {
  final String label;
  final Map<String, dynamic> settings;
  final OnSettingsSaved onSettingsSaved;

  const BatteryGaugeSettings(
      {super.key,
      required this.label,
      required this.settings,
      required this.onSettingsSaved});

  @override
  State<BatteryGaugeSettings> createState() => _BatteryGaugeSettingsState();
}

class _BatteryGaugeSettingsState extends State<BatteryGaugeSettings> {
  static const Map<BatteryGaugePaintMode, String> labels = {
    BatteryGaugePaintMode.none: 'None',
    BatteryGaugePaintMode.gauge: 'Guage',
    BatteryGaugePaintMode.grid: 'Grid',
  };
  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        SimpleBatteryGauge(
          key: Key(const Uuid().v4()),
          poorColor: Color(widget.settings['poorColor'] ?? Colors.red.value),
          lowColor: Color(widget.settings['lowColor'] ?? Colors.orange.value),
          mediumColor:
              Color(widget.settings['mediumColor'] ?? Colors.lightGreen.value),
          highColor: Color(widget.settings['highColor'] ?? Colors.green.value),
          borderColor:
              Color(widget.settings['borderColor'] ?? Colors.black.value),
          animated: widget.settings['shouldAnimate'] ?? false,
          fontSize: widget.settings['fontSize'] ?? 10,
          fontWeight: widget.settings['fontBold'] ?? true
              ? FontWeight.bold
              : FontWeight.normal,
          horizontal: widget.settings['horizontal'] ?? true,
          mode: BatteryGaugePaintMode.values.byName(
              widget.settings['mode'] ?? BatteryGaugePaintMode.none.name),
          tiny: false,
          value: 35,
          label: widget.label,
        ),
        Column(
          children: [
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
                const Text('Mode'),
                SizedBox(
                  width: 180,
                  child: DropdownMenu<BatteryGaugePaintMode>(
                    initialSelection: BatteryGaugePaintMode.values.byName(
                        widget.settings['mode'] ??
                            BatteryGaugePaintMode.gauge.name),
                    dropdownMenuEntries: BatteryGaugePaintMode.values.map((e) {
                      return DropdownMenuEntry<BatteryGaugePaintMode>(
                          value: e, label: labels[e]!);
                    }).toList(),
                    onSelected: (mode) {
                      setState(() {
                        widget.settings['mode'] =
                            mode?.name ?? BatteryGaugePaintMode.none.name;
                      });
                    },
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
                const Text('Poor Battery Color'),
                IconButton(
                    onPressed: () async {
                      await chooseColor(
                          selectedColor:
                              getColorOrDefault('poorColor', Colors.red),
                          field: 'poorColor');
                    },
                    icon: Icon(
                      Icons.palette,
                      color: getColorOrDefault('poorColor', Colors.red),
                    )),
              ],
            ),
            const SizedBox(
              height: 8,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Low Battery Color'),
                IconButton(
                    onPressed: () async {
                      await chooseColor(
                          selectedColor:
                              getColorOrDefault('lowColor', Colors.orange),
                          field: 'lowColor');
                    },
                    icon: Icon(
                      Icons.palette,
                      color: getColorOrDefault('lowColor', Colors.orange),
                    )),
              ],
            ),
            const SizedBox(
              height: 8,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Medium Battery Color'),
                IconButton(
                    onPressed: () async {
                      await chooseColor(
                          selectedColor: getColorOrDefault(
                              'mediumColor', Colors.lightGreen),
                          field: 'mediumColor');
                    },
                    icon: Icon(
                      Icons.palette,
                      color:
                          getColorOrDefault('mediumColor', Colors.lightGreen),
                    )),
              ],
            ),
            const SizedBox(
              height: 8,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('High Battery Color'),
                IconButton(
                    onPressed: () async {
                      await chooseColor(
                          selectedColor:
                              getColorOrDefault('highColor', Colors.green),
                          field: 'highColor');
                    },
                    icon: Icon(
                      Icons.palette,
                      color: getColorOrDefault('highColor', Colors.green),
                    )),
              ],
            ),
            const SizedBox(
              height: 8,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Border Color'),
                IconButton(
                    onPressed: () async {
                      await chooseColor(
                          selectedColor:
                              getColorOrDefault('borderColor', Colors.black),
                          field: 'borderColor');
                    },
                    icon: Icon(
                      Icons.palette,
                      color: getColorOrDefault('borderColor', Colors.black),
                    )),
              ],
            ),
            const SizedBox(
              height: 8,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Animate'),
                Checkbox(
                  value: widget.settings['shouldAnimate'] ?? true,
                  onChanged: (value) =>
                      setState(() => widget.settings['shouldAnimate'] = value),
                )
              ],
            ),
            const SizedBox(
              height: 8,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Horizontal'),
                Checkbox(
                  value: widget.settings['horizontal'] ?? true,
                  onChanged: (value) =>
                      setState(() => widget.settings['horizontal'] = value),
                )
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

  Color getColorOrDefault(String field, Color defColor) {
    return Color(widget.settings[field] ?? defColor.value);
  }

  Future chooseColor(
      {required Color selectedColor, required String field}) async {
    Color? color = await pickColor(selectedColor: selectedColor);
    if (null != color) {
      setState(() {
        widget.settings[field] = color.value;
      });
    }
  }

  Future<Color?> pickColor({required Color selectedColor}) async {
    Color? pickedColor;
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Pick a Color'),
          content: SizedBox(
            width: 450.0,
            height: 200.0,
            child: ColorPicker(
              pickerColor: selectedColor,
              onColorChanged: (color) {
                pickedColor = color;
              },
              colorPickerWidth: 100.0,
              pickerAreaHeightPercent: 0.7,
            ),
          ),
          actions: <Widget>[
            ElevatedButton(
              child: const Text('Done'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
    return pickedColor;
  }
}
