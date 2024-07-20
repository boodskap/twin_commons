import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ChartData {
  final Widget xAxis;
  final List<double> yAxis;

  ChartData({
    required this.xAxis,
    required this.yAxis,
  });
}

class BarChartWidget extends StatefulWidget {
  final List<int> xAxis;
  final List<List<double>> yAxis;
  final String dateFormat;
  final List<Color> colors;
  final EdgeInsets padding;
  final double width;
  final double height;
  final BorderSide leftBorder;
  final BorderSide rightBorder;
  final BorderSide bottomBorder;
  final BorderSide topBorder;
  final double leftReservedSize;
  final double bottomReservedSize;
  final Alignment chartAlignment;
  final bool isLeftTitle;
  final bool isRightTitle;
  final bool isTopTitle;
  final bool isBottomTitle;
  final bool gridEnable;

  const BarChartWidget({
    super.key,
    required this.xAxis,
    required this.yAxis,
    required this.dateFormat,
    required this.colors,
    this.height = -1,
    this.width = -1,
    this.padding = const EdgeInsets.only(top: 30),
    this.leftBorder = const BorderSide(color: Colors.black, width: 1),
    this.rightBorder = const BorderSide(color: Colors.transparent),
    this.bottomBorder = const BorderSide(color: Colors.black, width: 1),
    this.topBorder = const BorderSide(color: Colors.transparent),
    this.leftReservedSize = 44,
    this.bottomReservedSize = 32,
    this.chartAlignment = Alignment.center,
    this.isLeftTitle = true,
    this.isRightTitle = false,
    this.isTopTitle = false,
    this.isBottomTitle = true,
    this.gridEnable = true,
  });

  @override
  State<BarChartWidget> createState() => _BarChartWidgetState();
}

class _BarChartWidgetState extends State<BarChartWidget> {
  final DateFormat tipFormat = DateFormat('yyyy/MM/dd HH:mm:ss');
  final List<ChartData> data = [];

  _BarChartWidgetState();

  @override
  void initState() {
    DateFormat dayFormat = DateFormat(widget.dateFormat);

    for (int i = 0; i < widget.xAxis.length; i++) {
      String tip = tipFormat
          .format(DateTime.fromMillisecondsSinceEpoch(widget.xAxis[i]));
      String day = dayFormat
          .format(DateTime.fromMillisecondsSinceEpoch(widget.xAxis[i]));
      data.add(ChartData(
        xAxis: Tooltip(
          message: tip,
          child: Text(day,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
              maxLines: 2),
        ),
        yAxis: widget.yAxis[i],
      ));
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.center,
      child: Padding(
        padding: widget.padding,
        child: SizedBox(
          width: widget.width == -1
              ? MediaQuery.of(context).size.width
              : widget.width,
          height: widget.height == -1
              ? MediaQuery.of(context).size.height
              : widget.height,
          child: BarChart(
            BarChartData(
              barGroups: _chartGroups(),
              borderData: FlBorderData(
                  border: Border(
                      bottom: widget.bottomBorder, left: widget.leftBorder)),
              gridData: FlGridData(show: widget.gridEnable),
              titlesData: FlTitlesData(
                bottomTitles: AxisTitles(sideTitles: _bottomTitles),
                leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                        showTitles: widget.isLeftTitle,
                        reservedSize: widget.leftReservedSize)),
                topTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: widget.isTopTitle)),
                rightTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: widget.isRightTitle)),
              ),
            ),
          ),
        ),
      ),
    );
  }

  List<BarChartGroupData> _chartGroups() {
    final List<BarChartGroupData> groups = [];

    for (var cd in data) {
      final List<BarChartRodData> rods = [];
      int i = 0;
      for (var toY in cd.yAxis) {
        rods.add(BarChartRodData(toY: toY, color: widget.colors[i++]));
      }
      groups.add(BarChartGroupData(x: cd.yAxis[0].toInt(), barRods: rods));
    }

    return groups;
  }

  SideTitles get _bottomTitles => SideTitles(
        showTitles: widget.isBottomTitle,
        reservedSize: widget.bottomReservedSize,
        getTitlesWidget: _getBottomTitlesWidget,
      );

  Widget _getBottomTitlesWidget(double value, TitleMeta meta) {
    int index = data.indexWhere((element) => element.yAxis[0] == value);

    if (index >= 0 && index < data.length) {
      return data[index].xAxis;
    }
    return const Text('');
  }
}
