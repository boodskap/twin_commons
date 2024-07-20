import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

class LineAreaChartWidget extends StatefulWidget {
  final List<int> xAxis;
  final List<List<double>> yAxis;
  final List<Color> colors;
  final String dateFormat;
  final bool isLeftTitle;
  final bool isRightTitle;
  final bool isTopTitle;
  final bool isBottomTitle;
  final Color tooltipBgColor;
  final bool gridEnable;
  final double chartInterval;
  final bool borderEnable;
  final double width;
  final double height;
  final double barWidth;
  final bool isCurved;
  final EdgeInsets padding;
  final Alignment chartAlignment;
  final BorderSide leftBorder;
  final BorderSide rightBorder;
  final BorderSide bottomBorder;
  final BorderSide topBorder;
  final double leftReservedSize;
  final double bottomReservedSize;
  final TextStyle bottomTextStyle;
  final double spacing;
  final bool isAreaChart;

  const LineAreaChartWidget({
    super.key,
    required this.xAxis,
    required this.yAxis,
    required this.colors,
    required this.dateFormat,
    this.isLeftTitle = true,
    this.isRightTitle = false,
    this.isTopTitle = false,
    this.isBottomTitle = true,
    this.tooltipBgColor = Colors.black,
    this.gridEnable = false,
    this.chartInterval = 1,
    this.borderEnable = true,
    this.width = 450,
    this.height = 450,
    this.barWidth = 5,
    this.isCurved = true,
    this.chartAlignment = Alignment.center,
    this.padding = const EdgeInsets.only(top: 30),
    this.leftBorder = const BorderSide(color: Colors.black, width: 2),
    this.rightBorder = const BorderSide(color: Colors.transparent),
    this.bottomBorder = const BorderSide(color: Colors.black, width: 2),
    this.topBorder = const BorderSide(color: Colors.transparent),
    this.leftReservedSize = 44,
    this.bottomReservedSize = 32,
    this.bottomTextStyle = const TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 12,
    ),
    this.spacing = 10,
    required this.isAreaChart,
  });

  @override
  State<LineAreaChartWidget> createState() => _LineAreaChartWidgetState();
}

class _LineAreaChartWidgetState extends State<LineAreaChartWidget> {
  SideTitles get bottomTitles => SideTitles(
        showTitles: widget.isBottomTitle,
        reservedSize: widget.bottomReservedSize,
        interval: widget.chartInterval,
        getTitlesWidget: bottomTitleWidgets,
      );

  DateFormat tipFormat = DateFormat('yyyy/MM/dd HH:mm:ss');

  FlBorderData get borderData => FlBorderData(
        show: widget.borderEnable,
        border: Border(
          bottom: widget.bottomBorder,
          left: widget.leftBorder,
          right: widget.rightBorder,
          top: widget.topBorder,
        ),
      );

  Widget bottomTitleWidgets(double value, TitleMeta meta) {
    DateFormat dayFormat = DateFormat(widget.dateFormat);
    int index = value.toInt();
    if (index >= 0 && index < widget.xAxis.length) {
      String tip = tipFormat
          .format(DateTime.fromMillisecondsSinceEpoch(widget.xAxis[index]));
      String day = dayFormat
          .format(DateTime.fromMillisecondsSinceEpoch(widget.xAxis[index]));
      return SideTitleWidget(
        axisSide: meta.axisSide,
        space: widget.spacing,
        child: Tooltip(
            message: tip,
            child: Text(day, maxLines: 2, style: widget.bottomTextStyle)),
      );
    }
    return const Text("");
  }

  @override
  Widget build(BuildContext context) {
    final List<List<FlSpot>> flSpots = [];

    for (int i = 0; i < widget.yAxis.length; i++) {
      final List<FlSpot> spots = [];
      for (int j = 0; j < widget.yAxis[i].length; j++) {
        spots.add(FlSpot(j.toDouble(), widget.yAxis[i][j].toDouble()));
      }
      flSpots.add(spots);
    }

    List<LineChartBarData> lineBarsData =
        List.generate(widget.yAxis.length, (index) {
      List<FlSpot> flSpotData = flSpots[index];

      return LineChartBarData(
        spots: flSpotData,
        isCurved: widget.isCurved,
        barWidth: widget.barWidth,
        color: widget.colors[index],
        belowBarData: widget.isAreaChart
            ? BarAreaData(
                show: true, color: widget.colors[index].withOpacity(0.3))
            : null,
      );
    });

    return Align(
      alignment: widget.chartAlignment,
      child: Container(
        width: MediaQuery.of(context).size.width,
        height: widget.height,
        padding: widget.padding,
        child: LineChart(
          LineChartData(
            lineTouchData: const LineTouchData(
              touchTooltipData: LineTouchTooltipData(
                  //tooltipBgColor: widget.tooltipBgColor,
                  ),
            ),
            titlesData: FlTitlesData(
              bottomTitles: AxisTitles(
                sideTitles: bottomTitles,
              ),
              rightTitles: AxisTitles(
                sideTitles: SideTitles(showTitles: widget.isRightTitle),
              ),
              topTitles: AxisTitles(
                sideTitles: SideTitles(showTitles: widget.isTopTitle),
              ),
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                    showTitles: widget.isLeftTitle,
                    reservedSize: widget.leftReservedSize),
              ),
            ),
            gridData: FlGridData(show: widget.gridEnable),
            borderData: borderData,
            lineBarsData: lineBarsData,
          ),
        ),
      ),
    );
  }
}
