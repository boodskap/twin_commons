import 'package:twin_commons/core/sensor_widget.dart';
import 'package:twin_commons/core/twin_image_helper.dart';
import 'package:twin_commons/core/twinned_session.dart';
import 'package:twinned_api/api/twinned.swagger.dart';
import 'package:flutter/material.dart';
import 'package:twinned_models/models.dart';
import 'package:twinned_api/twinned_api.dart' as twin;
import 'package:chopper/chopper.dart' as chopper;
import 'package:google_fonts/google_fonts.dart';

class TwinUtils {
  static Future execute(Future Function() sync, {bool debug = false}) async {
    try {
      await sync();
    } catch (e, s) {
      debugPrint('$e\n$s');
    }
  }

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

  static Future<twin.DeviceModel?> getDeviceModel(
      {required String modelId}) async {
    try {
      var res = await TwinnedSession.instance.twin.getDeviceModel(
          apikey: TwinnedSession.instance.authToken, modelId: modelId);

      if (TwinUtils.validateResponse(res)) {
        return res.body?.entity;
      }
    } catch (e, s) {
      debugPrint('$e\n$s');
    }
  }

  static String? getDeviceModelIcon(
      {required String field, required twin.DeviceModel deviceModel}) {
    for (var p in deviceModel.parameters) {
      if (p.name == field) {
        return p.icon;
      }
    }
  }

  static Widget? getDeviceModelIconImage(
      {required String field,
      required twin.DeviceModel deviceModel,
      double scale = 1.0,
      BoxFit fit = BoxFit.contain}) {
    String? iconId =
        TwinUtils.getDeviceModelIcon(field: field, deviceModel: deviceModel);
    if (null != iconId && iconId.trim().isNotEmpty) {
      return TwinImageHelper.getDomainImage(iconId, scale: scale, fit: fit);
    }
  }

  static Future<Widget?> getDeviceModelIdIconImage(
      {required String field,
      required String modelId,
      double scale = 1.0,
      BoxFit fit = BoxFit.contain}) async {
    twin.DeviceModel? deviceModel = await getDeviceModel(modelId: modelId);
    if (null != deviceModel) {
      return getDeviceModelIconImage(
          field: field, deviceModel: deviceModel, scale: scale, fit: fit);
    }
  }

  static Future<twin.Device?> getDevice({required String deviceId}) async {
    try {
      var res = await TwinnedSession.instance.twin.getDevice(
          apikey: TwinnedSession.instance.authToken, deviceId: deviceId);

      if (TwinUtils.validateResponse(res)) {
        return res.body?.entity;
      }
    } catch (e, s) {
      debugPrint('$e\n$s');
    }
  }

  static Future<Widget?> getDeviceIconImage(
      {required String field,
      required twin.Device device,
      double scale = 1.0,
      BoxFit fit = BoxFit.contain}) async {
    return TwinUtils.getDeviceModelIdIconImage(
        field: field, modelId: device.modelId, scale: scale, fit: fit);
  }

  static Future<Widget?> getDeviceIdIconImage(
      {required String field,
      required String deviceId,
      double scale = 1.0,
      BoxFit fit = BoxFit.contain}) async {
    twin.Device? device = await getDevice(deviceId: deviceId);
    if (null != device) {
      return getDeviceIconImage(
          field: field, device: device, scale: scale, fit: fit);
    }
  }

  static TextStyle getTextStyle(FontConfig fontConfig,
      {bool googleFonts = false}) {
    if (googleFonts) {
      return GoogleFonts.getFont(
        fontConfig.fontFamily,
        fontSize: fontConfig.fontSize,
        fontWeight: fontConfig.fontBold ? FontWeight.bold : FontWeight.normal,
        color: Color(fontConfig.fontColor),
      );
    }

    return TextStyle(
      fontFamily: fontConfig.fontFamily,
      fontSize: fontConfig.fontSize,
      fontWeight: fontConfig.fontBold ? FontWeight.bold : FontWeight.normal,
      color: Color(fontConfig.fontColor),
    );
  }

  static bool validateResponse(chopper.Response r) {
    if (null == r.body) {
      debugPrint('Error: ${r.bodyString}');
      return false;
    }
    if (!r.body.ok) {
      debugPrint('Error: ${r.bodyString}');
      return false;
    }
    return true;
  }

  static Color darken(Color color, [double amount = .1]) {
    assert(amount >= 0 && amount <= 1);

    final hsl = HSLColor.fromColor(color);
    final hslDark = hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0));

    return hslDark.toColor();
  }

  static Color lighten(Color color, [double amount = .1]) {
    assert(amount >= 0 && amount <= 1);

    final hsl = HSLColor.fromColor(color);
    final hslLight =
        hsl.withLightness((hsl.lightness + amount).clamp(0.0, 1.0));

    return hslLight.toColor();
  }
}
