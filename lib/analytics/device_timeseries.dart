import 'package:flutter/material.dart';
import 'package:twin_commons/core/base_state.dart';
import 'package:twin_commons/widgets/line_area_chart.dart';
import 'package:twinned_api/api/twinned.swagger.dart';

class DeviceTimeSeriesWidget extends StatefulWidget {
  final Twinned twinned;
  final String apiKey;
  final DeviceModel model;
  final String deviceId;
  final String field;
  final DeviceDataSeriesDeviceIdFieldPageSizeGetFilter filter;
  final int? beignStamp;
  final int? endStamp;
  final List<Color> colors;
  final double height;
  const DeviceTimeSeriesWidget(
      {super.key,
      required this.twinned,
      required this.apiKey,
      required this.model,
      required this.deviceId,
      required this.field,
      required this.filter,
      this.beignStamp = 0,
      this.endStamp = 0,
      this.height = 150,
      this.colors = const []});

  @override
  State<DeviceTimeSeriesWidget> createState() => _DeviceTimeSeriesWidgetState();
}

class _DeviceTimeSeriesWidgetState extends BaseState<DeviceTimeSeriesWidget> {
  final List<Color> _colors = [
    const Color(0xFFD33A02),
    const Color(0xFF005DC6),
    const Color(0xFF00B2D7),
    const Color(0xFFC45762),
    const Color(0xFF7CA001),
    const Color(0xFF009B7C),
    const Color(0xFFE8909E),
    const Color(0xFFBACC47),
    const Color(0xFF5E89CA),
    const Color(0xFF027D59),
    const Color(0xFFFB9361),
    const Color(0xFF938E7E),
    const Color(0xFF6E582F),
    const Color(0xFFFE9E88),
    const Color(0xFFCDDAF0),
  ];

  final List<String> _fields = [];
  final List<int> _xAxis = [];
  final List<List<double>> _yAxis = [];

  @override
  void initState() {
    _colors.insertAll(0, widget.colors);
    _colors.shuffle();

    for (var param in widget.model.parameters) {
      if (param.enableTimeSeries ?? false) {
        String label = param.label ?? '';
        if (label.trim().isEmpty) {
          label = param.name;
        }
        _fields.add(label);
      }
    }
    super.initState();
  }

  @override
  void setup() async {
    await _loadData();
  }

  Future _loadData() async {
    await execute(() async {
      final List<int> xAxis = [];
      final List<double> yAxis = [];

      var res = await widget.twinned.getDeviceTimeSeries(
          tz: DateTime.now().timeZoneName,
          filter: widget.filter,
          apikey: widget.apiKey,
          deviceId: widget.deviceId,
          field: widget.field,
          beginStamp: widget.beignStamp,
          endStamp: widget.endStamp,
          page: 0,
          size: 96);

      if (validateResponse(res, shouldAlert: false)) {
        for (var value in res.body!.values!) {
          if (null == value.data) continue;
          xAxis.add(value.updatedStamp);
          Map<String, dynamic> fValues = value.data as Map<String, dynamic>;
          yAxis.add(fValues[widget.field] ?? 0);
        }
      }

      refresh(sync: () {
        _xAxis.clear();
        _yAxis.clear();

        _xAxis.addAll(xAxis);
        _yAxis.addAll([yAxis]);

        debugPrint('X:$_xAxis, Y:$_yAxis');
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final String dateFormat;

    switch (widget.filter) {
      case DeviceDataSeriesDeviceIdFieldPageSizeGetFilter.today:
      case DeviceDataSeriesDeviceIdFieldPageSizeGetFilter.yesterday:
        dateFormat = 'HH:mm';
        break;
      default:
        dateFormat = 'MM/dd';
        break;
    }

    return LineAreaChartWidget(
      width: MediaQuery.of(context).size.width,
      height: widget.height,
      xAxis: _xAxis,
      yAxis: _yAxis,
      colors: _colors,
      dateFormat: dateFormat,
      isAreaChart: true,
    );
  }
}
