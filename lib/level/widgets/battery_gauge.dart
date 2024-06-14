import 'package:animated_battery_gauge/animated_battery_gauge.dart';
import 'package:animated_battery_gauge/battery_gauge.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class SimpleBatteryGauge extends StatelessWidget {
  final bool animated;
  final String label;
  final int animationDuation;
  final Color borderColor;
  final Color poorColor;
  final Color lowColor;
  final Color mediumColor;
  final Color highColor;
  final double fontSize;
  final FontWeight fontWeight;
  final bool horizontal;
  final BatteryGaugePaintMode mode;
  final bool tiny;
  final double value;

  const SimpleBatteryGauge(
      {super.key,
      required this.animated,
      required this.label,
      this.animationDuation = 2,
      this.borderColor = Colors.grey,
      this.poorColor = Colors.red,
      this.lowColor = Colors.orange,
      this.mediumColor = Colors.lightGreen,
      this.highColor = Colors.green,
      this.fontSize = 10,
      this.fontWeight = FontWeight.bold,
      this.horizontal = true,
      this.mode = BatteryGaugePaintMode.gauge,
      required this.tiny,
      required this.value});

  @override
  Widget build(BuildContext context) {
    late Color color;
    if (value > 75) {
      color = highColor;
    } else if (value > 50) {
      color = mediumColor;
    } else if (value > 25) {
      color = lowColor;
    } else {
      color = poorColor;
    }

    late Widget center;

    if (!animated) {
      center = Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          BatteryGauge(
            value: value.toInt(),
            size: horizontal
                ? Size(tiny ? 50 : 75, tiny ? 18 : 27)
                : Size(tiny ? 18 : 35, tiny ? 50 : 100),
            borderColor: borderColor,
            valueColor: color,
            mode: mode,
            hasText: false,
            //textStyle: TextStyle(fontSize: fontSize, fontWeight: fontWeight),
          ),
        ],
      );
    } else {
      center = Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: horizontal
                ? tiny
                    ? 50
                    : 75
                : tiny
                    ? 18
                    : 27,
            height: horizontal
                ? tiny
                    ? 75
                    : 50
                : tiny
                    ? 27
                    : 18,
            child: AnimatedBatteryGauge(
              duration: Duration(seconds: animationDuation),
              value: value,
              size: horizontal
                  ? Size(tiny ? 50 : 75, tiny ? 18 : 27)
                  : Size(tiny ? 18 : 27, tiny ? 50 : 75),
              borderColor: borderColor,
              valueColor: color,
              mode: mode,
              hasText: false,
              //textStyle: TextStyle(fontSize: fontSize, fontWeight: fontWeight),
            ),
          ),
        ],
      );
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Stack(
          alignment: AlignmentDirectional.center,
          children: [
            center,
            Column(
              children: [
                Text(
                  label,
                  style: TextStyle(
                      fontSize: tiny ? fontSize / 2 : fontSize,
                      fontWeight: fontWeight),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  '${value.toInt()} %',
                  style: TextStyle(
                      fontSize: tiny ? fontSize / 2 : fontSize,
                      fontWeight: fontWeight),
                  overflow: TextOverflow.ellipsis,
                )
              ],
            ),
          ],
        ),
      ],
    );
  }
}
