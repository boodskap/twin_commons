enum ChartType {
  none,
  area,
  spline,
  scatter,
}

class TimeSeriesData {
  TimeSeriesData(
      {required int millis, required this.value, required this.recordId})
      : dateTime = DateTime.fromMillisecondsSinceEpoch(millis);
  final DateTime dateTime;
  final dynamic value;
  final String recordId;
}
