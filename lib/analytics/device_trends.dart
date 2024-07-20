import 'package:flutter/material.dart';
import 'package:twin_commons/core/base_state.dart';
import 'package:twin_commons/widgets/bar_flchart.dart';
import 'package:twinned_api/api/twinned.swagger.dart';
import 'package:uuid/uuid.dart';

class DeviceTrendsWidget extends StatefulWidget {
  final Twinned twinned;
  final String apiKey;
  final DeviceModel model;
  final String deviceId;
  final String field;
  final String filter;
  final int? beginStamp;
  final int? endStamp;
  final List<Color> colors;
  final double height;
  const DeviceTrendsWidget(
      {super.key,
      required this.twinned,
      required this.apiKey,
      required this.model,
      required this.deviceId,
      required this.field,
      required this.filter,
      this.beginStamp = 0,
      this.endStamp = 0,
      this.height = 150,
      this.colors = const []});

  @override
  State<DeviceTrendsWidget> createState() => _DeviceTrendsWidgetState();
}

class _DeviceTrendsWidgetState extends BaseState<DeviceTrendsWidget> {
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
      final List<List<double>> yAxis = [];

      var res = await widget.twinned.getDeviceTrends(
          tz: DateTime.now().timeZoneName,
          filter: DeviceDataTrendsDeviceIdFieldGetFilter.values
              .byName(widget.filter),
          apikey: widget.apiKey,
          deviceId: widget.deviceId,
          field: widget.field,
          beginStamp: widget.beginStamp,
          endStamp: widget.endStamp);

      if (validateResponse(res, shouldAlert: false)) {
        for (var value in res.body!.values!) {
          debugPrint('Trend: ${value.toString()}');
          xAxis.add(value.stamp);
          yAxis.add([value.min ?? 0, value.avg ?? 0, value.max ?? 0]);
        }
      }

      refresh(sync: () {
        _xAxis.clear();
        _yAxis.clear();

        _xAxis.addAll(xAxis);
        _yAxis.addAll(yAxis);
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

    debugPrint('x:$_xAxis y:$_yAxis');
    return BarChartWidget(
      key: Key(const Uuid().v4().toString()),
      width: MediaQuery.of(context).size.width,
      height: widget.height,
      xAxis: _xAxis,
      yAxis: _yAxis,
      colors: _colors,
      dateFormat: dateFormat,
    );
  }
}
