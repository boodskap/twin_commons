import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:twin_commons/core/base_state.dart';
import 'package:community_charts_flutter/community_charts_flutter.dart'
    as charts;

class BarChartSection extends StatefulWidget {
  final String dataField;
  final List<String> deviceIds;
  final String title;
  final double width;
  final double height;
  final bool animationEnabled;
  final charts.BehaviorPosition legendPosition;
  final charts.BarGroupingType groupType;
  final charts.Color titleColor;
  final int titleFontSize;
  final Alignment chartAlignment;
  final EdgeInsets padding;
  final bool legendEnabled;
  final bool defaultDisplayEnabled;
  const BarChartSection({
    super.key,
    required this.dataField,
    required this.deviceIds,
    this.title = 'Chart Name',
    this.width = 400,
    this.height = 400,
    this.animationEnabled = true,
    this.legendPosition = charts.BehaviorPosition.bottom,
    this.groupType = charts.BarGroupingType.grouped,
    this.titleFontSize = 14,
    this.titleColor = charts.MaterialPalette.black,
    this.chartAlignment = Alignment.center,
    this.padding = const EdgeInsets.only(top: 30),
    this.legendEnabled = true,
    this.defaultDisplayEnabled = true,
  });

  @override
  State<BarChartSection> createState() => _BarChartSectionState();
}

class _BarChartSectionState extends BaseState<BarChartSection> {
  final List<charts.Series<IoTData, String>> _series = [];

  @override
  void initState() {
    List<IoTData> data = [
      IoTData(device: 'Device 1', data: 100),
      IoTData(device: 'Device 1', data: 125),
    ];
    _buildSeries(data, _series);
    super.initState();
  }

  @override
  void setup() async {}

  void _buildSeries(
      List<IoTData> data, List<charts.Series<IoTData, String>> series) {
    series.add(charts.Series<IoTData, String>(
      id: widget.title,
      colorFn: (_, __) => charts.MaterialPalette.blue.shadeDefault,
      domainFn: (IoTData series, _) => series.device,
      measureFn: (IoTData series, _) => series.data,
      data: data,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: widget.padding,
      child: Align(
        alignment: widget.chartAlignment,
        child: SizedBox(
          width: widget.width,
          height: widget.height,
          child: Center(
            child: charts.BarChart(
              _series,
              animate: widget.animationEnabled,
              barGroupingType: widget.groupType,
              behaviors: [
                if (widget.legendEnabled)
                  charts.SeriesLegend(
                    position: widget.legendPosition,
                  ),
                charts.ChartTitle(
                  widget.title,
                  titleStyleSpec: charts.TextStyleSpec(
                    fontSize: widget.titleFontSize,
                    color: widget.titleColor, // Use Colors class for the color
                  ),
                ),
              ],
              defaultRenderer: widget.defaultDisplayEnabled
                  ? charts.BarRendererConfig(
                      barRendererDecorator: charts.BarLabelDecorator<String>(),
                    )
                  : null,
            ),
          ),
        ),
      ),
    );
  }
}

class IoTData {
  final String device;
  final num data;
  IoTData({required this.device, required this.data});
}
