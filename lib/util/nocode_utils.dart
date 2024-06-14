import 'package:twin_commons/core/sensor_widget.dart';
import 'package:twinned_api/api/twinned.swagger.dart';

class TwinUtils {
  static dynamic getParameterValue(String name, DeviceData dd) {
    Map<String, dynamic> map = dd.data as Map<String, dynamic>;
    return map[name] ?? '-';
  }

  static String getParameterLabel(String name, DeviceModel deviceModel) {
    for (var p in deviceModel.parameters) {
      if (p.name == name) {
        String label = p.label ?? p.name;
        return getStrippedLabel(label);
      }
    }

    return '?';
  }

  static String getStrippedLabel(String label) {
    int index = label.indexOf(":");
    if (index >= 0) {
      return label.substring(index + 1);
    }
    return label;
  }

  static String getParameterUnit(String name, DeviceModel deviceModel) {
    for (var p in deviceModel.parameters) {
      if (p.name == name) {
        return p.unit ?? '';
      }
    }
    return '';
  }

  static String getParameterIcon(String name, DeviceModel deviceModel) {
    for (var p in deviceModel.parameters) {
      if (p.name == name) {
        return p.icon ?? '';
      }
    }
    return '';
  }

  static List<String> getSortedFields(DeviceModel deviceModel) {
    final Set<String> indexes = <String>{};
    final Map<String, Parameter> parameters = {};
    final List<String> names = [];

    for (var p in deviceModel.parameters) {
      var name = p.label ?? '';
      if (name.isEmpty || !name.contains(':')) continue;
      int index = name.indexOf(":");
      String idx = name.substring(0, index);
      parameters[idx] = p;
      indexes.add(idx);
    }

    var sorted = indexes.toList();
    sorted.sort();

    for (String idx in sorted) {
      Parameter p = parameters[idx]!;
      names.add(p.name);
    }

    return names;
  }

  static SensorWidgetType getSensorWidgetType(
      String name, DeviceModel deviceModel) {
    for (var p in deviceModel.parameters) {
      if (p.name == name) {
        String? widgetId = p.sensorWidget?.widgetId;
        if (null != widgetId && widgetId.trim().isNotEmpty) {
          return SensorWidgetType.values.byName(widgetId);
        }
      }
    }
    return SensorWidgetType.none;
  }

  static Parameter? getParameter(String name, DeviceModel deviceModel) {
    for (var p in deviceModel.parameters) {
      if (p.name == name) {
        return p;
      }
    }
    return null;
  }

  static bool hasTimeSeries(String name, DeviceModel deviceModel) {
    for (var p in deviceModel.parameters) {
      if (p.name == name) {
        return p.enableTimeSeries ?? false;
      }
    }
    return false;
  }

  static bool hasTrends(String name, DeviceModel deviceModel) {
    for (var p in deviceModel.parameters) {
      if (p.name == name) {
        return p.enableTrend ?? false;
      }
    }
    return false;
  }

  static List<String> getTimeSeriesFields(DeviceModel deviceModel) {
    List<String> fields = [];
    for (var p in deviceModel.parameters) {
      if (p.enableTimeSeries ?? false) {
        fields.add(p.name);
      }
    }
    return fields;
  }
}
