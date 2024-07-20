import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:twin_commons/core/base_state.dart';
import 'package:twin_commons/core/twin_image_helper.dart';
import 'package:twin_commons/util/nocode_utils.dart';
import 'package:twin_commons/widgets/device_component.dart';
import 'package:twinned_api/api/twinned.swagger.dart' as twin;
import 'package:timeago/timeago.dart' as timeago;
import 'package:twin_commons/core/sensor_widget.dart';

typedef OnDeviceDoubleTapped = Future<void> Function(twin.DeviceData dd);
typedef OnDeviceAnalyticsTapped = Future<void> Function(
    String field, twin.DeviceModel mode, twin.DeviceData dd);

class DefaultDeviceView extends StatefulWidget {
  final twin.DeviceData? deviceData;
  final String deviceId;
  final twin.Twinned twinned;
  final String authToken;
  final OnDeviceDoubleTapped onDeviceDoubleTapped;
  final OnDeviceAnalyticsTapped onDeviceAnalyticsTapped;
  final TextStyle titleTextStyle;
  final TextStyle infoTextStyle;
  final TextStyle widgetTextStyle;
  const DefaultDeviceView({
    super.key,
    this.deviceData,
    required this.deviceId,
    required this.twinned,
    required this.authToken,
    required this.onDeviceDoubleTapped,
    required this.onDeviceAnalyticsTapped,
    this.titleTextStyle =
        const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
    this.infoTextStyle =
        const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
    this.widgetTextStyle =
        const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
  });

  @override
  State<DefaultDeviceView> createState() => _DefaultDeviceViewState();
}

class _DefaultDeviceViewState extends BaseState<DefaultDeviceView> {
  final List<Widget> _fields = [];
  final List<Widget> _components = [];
  twin.DeviceData? _data;
  String title = '?';
  String info = '?';
  String reported = '';

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Column(
              children: [
                Text(
                  title,
                  style: widget.titleTextStyle,
                ),
                divider(),
                Text(
                  info,
                  style: widget.infoTextStyle,
                ),
                divider(),
                Wrap(
                  spacing: 4,
                  children: _components,
                ),
              ],
            ),
            Expanded(
              child: Row(
                children: [
                  if (_fields.isNotEmpty)
                    Expanded(
                        flex: 3,
                        child: SingleChildScrollView(
                          child: Center(
                            child: Wrap(
                              spacing: 5,
                              children: _fields,
                            ),
                          ),
                        )),
                  divider(horizontal: true)
                ],
              ),
            ),
            divider(),
            if (reported.isNotEmpty)
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    reported,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  )
                ],
              ),
          ],
        ),
      ),
    );
  }

  Future load() async {
    if (loading) return;
    loading = true;

    _fields.clear();
    _data = null;

    refresh();

    await execute(() async {
      if (null != widget.deviceData) {
        _data = widget.deviceData;
        title = _data!.deviceName ?? '-';
      } else {
        var res = await widget.twinned.getDevice(
            apikey: widget.authToken,
            deviceId: widget.deviceId,
            isHardwareDevice: false);
        if (validateResponse(res)) {
          twin.Device device = res.body!.entity!;
          title = device.name;
          var dRes = await widget.twinned.getDeviceData(
            apikey: widget.authToken,
            deviceId: widget.deviceId,
            isHardwareDevice: false,
          );

          if (validateResponse(dRes)) {
            _data = dRes.body?.data;
          }
        }
      }

      if (null == _data) return;

      twin.DeviceData dd = _data!;
      int lastReported = 0;
      twin.DeviceModel? model;

      if (dd.alarms.length + dd.displays.length > 0) {
        debugPrint('*** ADDING ALARMS ***');
        debugPrint(jsonEncode(dd));
        _components.add(DeviceComponentView(
            twinned: widget.twinned,
            authToken: widget.authToken,
            deviceData: dd));
      }

      var mRes = await widget.twinned
          .getDeviceModel(apikey: widget.authToken, modelId: _data!.modelId);

      if (validateResponse(mRes)) {
        model = mRes.body!.entity!;
      }

      if (null == model) return;

      double cardWidth = 130;
      double cardHeight = 130;

      if (lastReported < dd.updatedStamp) {
        lastReported = dd.updatedStamp;
      }

      var fields = TwinUtils.getSortedFields(model);

      for (String field in fields) {
        String icon = TwinUtils.getParameterIcon(field, model);
        String unit = TwinUtils.getParameterUnit(field, model);
        String label = TwinUtils.getParameterLabel(field, model);
        SensorWidgetType type = TwinUtils.getSensorWidgetType(field, model);
        dynamic value = TwinUtils.getParameterValue(field, dd);
        late Widget sensorWidget;
        bool hasAnalytics =
            dd.series!.contains(field) | dd.trends!.contains(field);

        if (type == SensorWidgetType.none) {
          if (icon.isEmpty) {
            sensorWidget = const Icon(Icons.device_unknown_sharp);
          } else {
            sensorWidget = SizedBox(
                width: 45, child: TwinImageHelper.getDomainImage(icon));
          }

          refresh(sync: () {
            _fields.add(SizedBox(
              width: cardWidth,
              height: cardHeight,
              child: Card(
                elevation: 5,
                child: Container(
                    color: Colors.white,
                    child: InkWell(
                      onTap: !hasAnalytics
                          ? null
                          : () {
                              widget.onDeviceAnalyticsTapped(field, model!, dd);
                            },
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '$label : $value $unit',
                            style: widget.widgetTextStyle,
                          ),
                          const SizedBox(
                            height: 8,
                          ),
                          sensorWidget,
                        ],
                      ),
                    )),
              ),
            ));
          });
        } else {
          var parameter = TwinUtils.getParameter(field, model);
          sensorWidget = SensorWidget(
            parameter: parameter!,
            deviceData: dd,
            tiny: false,
            deviceModel: model,
          );

          refresh(sync: () {
            _fields.add(SizedBox(
                width: cardWidth,
                height: cardHeight,
                child: Card(
                    elevation: 5,
                    child: InkWell(
                      onTap: !hasAnalytics
                          ? null
                          : () {
                              widget.onDeviceAnalyticsTapped(field, model!, dd);
                            },
                      child: Container(
                          color: Colors.white,
                          child: Padding(
                            padding: const EdgeInsets.all(4.0),
                            child: sensorWidget,
                          )),
                    ))));
          });
        }
      }

      info = '${dd.premise} -> ${dd.facility} -> ${dd.floor}';

      if (lastReported > 0) {
        var dt = DateTime.fromMillisecondsSinceEpoch(lastReported);
        reported = 'reported ${timeago.format(dt, locale: 'en')}';
      } else {
        reported = '';
      }

      refresh();
    });
    loading = false;
  }

  @override
  void setup() {
    load();
  }
}
