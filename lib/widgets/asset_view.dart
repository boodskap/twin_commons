import 'package:flutter/material.dart';
import 'package:twin_commons/core/base_state.dart';
import 'package:twin_commons/core/busy_indicator.dart';
import 'package:twin_commons/core/twin_image_helper.dart';
import 'package:twin_commons/widgets/device_view.dart';
import 'package:twinned_api/api/twinned.swagger.dart' as twin;

typedef OnAssetDoubleTapped = Future<void> Function(twin.DeviceData dd);
typedef OnAssetAnalyticsTapped = Future<void> Function(twin.DeviceData dd);

class SimpleAssetView extends StatefulWidget {
  final twin.Twinned twinned;
  final String authToken;
  final String assetId;
  final double width;
  final double height;
  final OnAssetDoubleTapped onAssetDoubleTapped;
  final OnAssetAnalyticsTapped onAssetAnalyticsTapped;

  const SimpleAssetView(
      {super.key,
      required this.twinned,
      required this.authToken,
      required this.assetId,
      this.width = 350,
      this.height = 350,
      required this.onAssetDoubleTapped,
      required this.onAssetAnalyticsTapped});

  @override
  State<SimpleAssetView> createState() => _SimpleAssetViewState();
}

class _SimpleAssetViewState extends BaseState<SimpleAssetView> {
  final List<twin.DeviceData> _data = [];
  bool hasDevices = false;
  String premise = '-';
  String facility = '';
  String floor = '';
  String asset = '';
  Widget? assetImage;

  @override
  void setup() async {
    await _load();
  }

  Future _load() async {
    if (loading) return;
    loading = true;
    await execute(() async {
      _data.clear();
      var res = await widget.twinned
          .getAsset(apikey: widget.authToken, assetId: widget.assetId);

      if (validateResponse(res)) {
        hasDevices = res.body!.entity!.devices!.isNotEmpty;
        if (res.body!.entity!.images?.isNotEmpty ?? false) {
          int idx = res.body!.entity!.selectedImage ?? 0;
          if (res.body!.entity!.images!.length < idx) {
            idx = 0;
          }
          var image =
              TwinImageHelper.getDomainImage(res.body!.entity!.images![idx]);
          assetImage = SizedBox(
            width: 350,
            height: 350,
            child: Align(alignment: Alignment.center, child: image),
          );
        }
        for (var deviceId in res.body!.entity!.devices!) {
          var dd = await widget.twinned
              .getDeviceData(apikey: widget.authToken, deviceId: deviceId);
          if (validateResponse(dd, shouldAlert: false)) {
            setState(() {
              _data.add(dd.body!.data!);
            });
          }
        }
      }
    });
    loading = false;

    refresh();
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return SizedBox(
          width: widget.width,
          height: widget.height,
          child: Card(
            elevation: 10,
            child: Container(
              color: Colors.white,
              child: const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  BusyIndicator(),
                ],
              ),
            ),
          ));
    }

    List<Widget> deviceViews = [];

    if (null != assetImage) {
      deviceViews.add(assetImage!);
    }

    for (var dd in _data) {
      deviceViews.add(SimpleDeviceView(
          twinned: widget.twinned,
          authToken: widget.authToken,
          data: dd,
          showTitle: _data.length > 1,
          onDeviceDoubleTapped: () async {
            await widget.onAssetDoubleTapped(dd);
          },
          onDeviceAnalyticsTapped: () async {
            await widget.onAssetAnalyticsTapped(dd);
          }));
    }

    if (!hasDevices) {
      deviceViews.add(const Text('No device mapping found'));
    }

    if (_data.isEmpty) {
      deviceViews.add(const Text('No data found'));
    } else {
      twin.DeviceData dd = _data.first;
      premise = dd.premise ?? '-';
      facility = dd.facility ?? '-';
      floor = dd.floor ?? '-';
      asset = dd.asset ?? '-';
    }

    return SizedBox(
        width: widget.width,
        height: widget.height,
        child: Card(
          elevation: 10,
          child: Container(
            color: Colors.white,
            child: Column(
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: Wrap(
                    spacing: 8,
                    children: [
                      const Icon(
                        Icons.view_compact_sharp,
                        color: Colors.green,
                      ),
                      Text(
                        asset,
                        style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            overflow: TextOverflow.ellipsis),
                      )
                    ],
                  ),
                ),
                divider(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Wrap(
                      spacing: 8,
                      children: [
                        const Icon(
                          Icons.home,
                          color: Colors.green,
                        ),
                        Text(
                          premise,
                          style:
                              const TextStyle(overflow: TextOverflow.ellipsis),
                        )
                      ],
                    ),
                    Wrap(
                      spacing: 8,
                      children: [
                        const Icon(
                          Icons.business,
                          color: Colors.green,
                        ),
                        Text(
                          facility,
                          style:
                              const TextStyle(overflow: TextOverflow.ellipsis),
                        )
                      ],
                    ),
                    Wrap(
                      spacing: 8,
                      children: [
                        const Icon(
                          Icons.cabin,
                          color: Colors.green,
                        ),
                        Text(
                          floor,
                          style:
                              const TextStyle(overflow: TextOverflow.ellipsis),
                        )
                      ],
                    ),
                  ],
                ),
                divider(),
                Wrap(
                  spacing: 8,
                  children: deviceViews,
                ),
              ],
            ),
          ),
        ));
  }
}
