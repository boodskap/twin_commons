import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:flutter_spinbox/flutter_spinbox.dart';
import 'package:twin_commons/level/widgets/hexagon_tank.dart';
import 'package:twin_commons/core/sensor_widget.dart';
import 'package:uuid/uuid.dart';

class HexagonTankSettings extends StatefulWidget {
  final String label;
  final Map<String, dynamic> settings;
  final OnSettingsSaved onSettingsSaved;

  const HexagonTankSettings(
      {super.key,
      required this.settings,
      required this.onSettingsSaved,
      required this.label});

  @override
  State<HexagonTankSettings> createState() => _HexagonTankSettingsState();
}

class _HexagonTankSettingsState extends State<HexagonTankSettings> {
  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        SizedBox(
          width: 120,
          height: 120,
          child: HexagonTank(
            key: Key(const Uuid().v4()),
            liquidColor:
                Color(widget.settings['liquidColor'] ?? Colors.blue.value),
            bottleColor:
                Color(widget.settings['bottleColor'] ?? Colors.black.value),
            shouldAnimate: widget.settings['shouldAnimate'] ?? false,
            fontSize: widget.settings['fontSize'] ?? 10,
            fontWeight: widget.settings['fontBold'] ?? true
                ? FontWeight.bold
                : FontWeight.normal,
            label: widget.label,
            liquidLevel: 35,
            tiny: false,
          ),
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
              ],
            ),
            const SizedBox(
              height: 8,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Liquid Color'),
                IconButton(
                    onPressed: () async {
                      Color? picked = await pickColor(
                          selectedColor: Color(widget.settings['liquidColor'] ??
                              Colors.blue.value));
                      setState(() {
                        widget.settings['liquidColor'] =
                            picked?.value ?? Colors.blue.value;
                      });
                    },
                    icon: Icon(
                      Icons.palette,
                      color: Color(
                          widget.settings['liquidColor'] ?? Colors.blue.value),
                    )),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Tank Color'),
                IconButton(
                    onPressed: () async {
                      Color? picked = await pickColor(
                          selectedColor: Color(widget.settings['bottleColor'] ??
                              Colors.black.value));
                      setState(() {
                        widget.settings['bottleColor'] =
                            picked?.value ?? Colors.black.value;
                      });
                    },
                    icon: Icon(
                      Icons.palette,
                      color: Color(
                          widget.settings['bottleColor'] ?? Colors.black.value),
                    )),
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
