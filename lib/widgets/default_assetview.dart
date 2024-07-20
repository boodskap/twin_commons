import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:twin_commons/core/base_state.dart';
import 'package:twin_commons/core/twin_image_helper.dart';
import 'package:twin_commons/util/nocode_utils.dart';
import 'package:twin_commons/widgets/device_component.dart';
import 'package:twinned_api/api/twinned.swagger.dart' as twin;
import 'package:timeago/timeago.dart' as timeago;
import 'package:twin_commons/core/sensor_widget.dart';

typedef OnAssetDoubleTapped = Future<void> Function(twin.DeviceData dd);
typedef OnAssetAnalyticsTapped = Future<void> Function(
    String field, twin.DeviceModel model, twin.DeviceData dd);

class DefaultAssetView extends StatefulWidget {
  final twin.Twinned twinned;
  final String authToken;
  final String assetId;
  final OnAssetDoubleTapped onAssetDoubleTapped;
  final OnAssetAnalyticsTapped onAssetAnalyticsTapped;
  final TextStyle titleTextStyle;
  final TextStyle infoTextStyle;
  final TextStyle widgetTextStyle;
  const DefaultAssetView({
    super.key,
    required this.twinned,
    required this.authToken,
    required this.assetId,
    required this.onAssetDoubleTapped,
    required this.onAssetAnalyticsTapped,
    this.titleTextStyle =
        const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
    this.infoTextStyle =
        const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
    this.widgetTextStyle =
        const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
  });

  @override
  State<DefaultAssetView> createState() => _DefaultAssetViewState();
}

class _DefaultAssetViewState extends BaseState<DefaultAssetView> {
  final List<Widget> _fields = [];
  final List<twin.DeviceData> _data = [];
  final List<Widget> _components = [];

  //Widget image = const Icon(Icons.image);
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
    _data.clear();
    _components.clear();

    refresh();

    await execute(() async {
      var res = await widget.twinned
          .getAsset(apikey: widget.authToken, assetId: widget.assetId);
      if (validateResponse(res)) {
        twin.Asset asset = res.body!.entity!;
        title = asset.name;
        //String imageId = UserSession().getSelectImageId(asset.selectedImage, asset.images);
        //image = UserSession().getImage(asset.domainKey, imageId);

        var dRes = await widget.twinned.searchRecentDeviceData(
            apikey: widget.authToken,
            assetId: widget.assetId,
            body:
                const twin.FilterSearchReq(search: '*', page: 0, size: 10000));

        if (validateResponse(dRes)) {
          _data.addAll(dRes.body!.values!);
        }
      } else {
        debugPrint('ASSET NOT FOUND: ${widget.assetId}');
      }
      int lastReported = 0;
      Map<String, twin.DeviceModel> models = {};

      for (twin.DeviceData dd in _data) {
        if (models.containsKey(dd.modelId)) continue;
        var res = await widget.twinned
            .getDeviceModel(apikey: widget.authToken, modelId: dd.modelId);
        if (validateResponse(res)) {
          models[dd.modelId] = res.body!.entity!;
        }
        _components.add(DeviceComponentView(
            twinned: widget.twinned,
            authToken: widget.authToken,
            deviceData: dd));
      }

      double cardWidth = 130;
      double cardHeight = 130;

      for (twin.DeviceData dd in _data) {
        if (lastReported < dd.updatedStamp) {
          lastReported = dd.updatedStamp;
        }
        twin.DeviceModel deviceModel = models[dd.modelId]!;
        var fields = TwinUtils.getSortedFields(deviceModel);

        for (String field in fields) {
          String icon = TwinUtils.getParameterIcon(field, deviceModel);
          String unit = TwinUtils.getParameterUnit(field, deviceModel);
          String label = TwinUtils.getParameterLabel(field, deviceModel);
          SensorWidgetType type =
              TwinUtils.getSensorWidgetType(field, deviceModel);
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
                child: InkWell(
                  onTap: !hasAnalytics
                      ? null
                      : () {
                          widget.onAssetAnalyticsTapped(field, deviceModel, dd);
                        },
                  child: Card(
                    elevation: 5,
                    child: Container(
                        color: Colors.white,
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
                        )),
                  ),
                ),
              ));
            });
          } else {
            var parameter = TwinUtils.getParameter(field, deviceModel);
            sensorWidget = SensorWidget(
              parameter: parameter!,
              deviceData: dd,
              tiny: false,
              deviceModel: deviceModel,
            );

            refresh(sync: () {
              _fields.add(SizedBox(
                  width: cardWidth,
                  height: cardHeight,
                  child: InkWell(
                    onTap: !hasAnalytics
                        ? null
                        : () {
                            widget.onAssetAnalyticsTapped(
                                field, deviceModel, dd);
                          },
                    child: Card(
                        elevation: 5,
                        child: Container(
                            color: Colors.white,
                            child: Padding(
                              padding: const EdgeInsets.all(4.0),
                              child: sensorWidget,
                            ))),
                  )));
            });
          }
        }
      }

      if (_data.isNotEmpty) {
        twin.DeviceData dd = _data.first;
        info = '${dd.premise} -> ${dd.facility} -> ${dd.floor}';
      }

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
