import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:twin_commons/util/nocode_utils.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';

class Gauge extends StatelessWidget {
  final double min;
  final double max;
  final double fontSize;
  final FontWeight fontWeight;
  final double value;
  final bool tiny;
  final String unit;
  final int interval;
  final String label;
  final double startAngle;
  final double endAngle;

  Gauge({
    super.key,
    this.min = 0,
    this.max = 250,
    required this.value,
    required String label,
    required this.tiny,
    this.unit = 'psi',
    this.interval = 5,
    this.fontSize = 12,
    this.fontWeight = FontWeight.bold,
    required this.startAngle,
    required this.endAngle,
  }) : label = TwinUtils.getStrippedLabel(label);

  @override
  Widget build(BuildContext context) {
    SfRadialGauge gaugeWidget = SfRadialGauge(axes: <RadialAxis>[
      RadialAxis(
        startAngle: startAngle,
        endAngle: endAngle,
        radiusFactor: 1,
        minimum: min,
        maximum: max,
        labelOffset: 4,
        interval: max / interval,
        showFirstLabel: true,
        showLastLabel: true,
        showTicks: true,
        canScaleToFit: true,
        axisLabelStyle: const GaugeTextStyle(fontSize: 8),
        pointers: <GaugePointer>[
          NeedlePointer(
            value: value,
            needleEndWidth: 3,
          )
        ],
      )
    ]);

    return Stack(
      alignment: AlignmentDirectional.center,
      children: [
        if (tiny)
          Padding(
            padding: const EdgeInsets.fromLTRB(1.0, 8.0, 1.0, 1.0),
            child: gaugeWidget,
          ),
        if (!tiny) gaugeWidget,
        Align(
          alignment: Alignment.topCenter,
          child: Text(
            '$label: $value $unit',
            style: TextStyle(
                fontSize: fontSize,
                fontWeight: fontWeight,
                overflow: TextOverflow.ellipsis),
          ),
        ),
      ],
    );
  }
}
