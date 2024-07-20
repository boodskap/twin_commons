import 'package:flutter/material.dart';
import 'package:twin_commons/core/base_state.dart';
import 'package:twin_commons/core/twin_image_helper.dart';
import 'package:twin_commons/widgets/fillable_circle.dart';
import 'package:twin_commons/widgets/fillable_rectangle.dart';
import 'package:twinned_api/api/twinned.swagger.dart' as twin;
import 'package:eventify/eventify.dart' as event;
import 'package:uuid/uuid.dart';
import 'package:twin_commons/widgets/alarm_snippet.dart';
import 'package:twin_commons/widgets/display_snippet.dart';

typedef OnDeviceDoubleTapped = Future<void> Function();
typedef OnDeviceAnalyticsTapped = Future<void> Function();

class SimpleDeviceView extends StatefulWidget {
  final twin.Twinned twinned;
  final String authToken;
  final event.EventEmitter? events;
  final bool? liveData;
  final bool? showTitle;
  final double? topMenuHeight;
  final double? leftMenuWidth;
  final double? rightMenuWidth;
  final double? bottomMenuHeight;
  final double? width;
  final double? height;
  final twin.DeviceData data;
  final OnDeviceDoubleTapped? onDeviceDoubleTapped;
  final OnDeviceAnalyticsTapped onDeviceAnalyticsTapped;

  const SimpleDeviceView({
    super.key,
    required this.twinned,
    required this.authToken,
    this.events,
    this.liveData = false,
    this.showTitle = false,
    this.topMenuHeight = 45,
    this.bottomMenuHeight = 45,
    this.leftMenuWidth = 45,
    this.rightMenuWidth = 45,
    this.width = 350,
    this.height = 350,
    required this.data,
    required this.onDeviceDoubleTapped,
    required this.onDeviceAnalyticsTapped,
  });

  @override
  State<SimpleDeviceView> createState() => _SimpleDeviceViewState();
}

class _SimpleDeviceViewState extends BaseState<SimpleDeviceView> {
  static Map<String, Widget> images = {};

  event.Listener? listener;
  Widget? deviceImage = const Icon(Icons.hourglass_empty);
  String _title = '';
  twin.Device? _device;
  twin.DeviceModel? _deviceModel;
  twin.DeviceData? _data;
  twin.CustomWidget? _customWidget;

  @override
  void initState() {
    _data = widget.data;
    _title = _data!.deviceName!;

    if (null != widget.events && widget.liveData!) {
      listener = widget.events!.on('twinMessageReceived', this, (e, o) {
        if (_data!.hardwareDeviceId == e.eventData) {
          debugPrint('*** REFRESHING ${e.eventData} ***');
          _load();
        }
      });
    }

    super.initState();
  }

  @override
  void dispose() {
    if (null != listener) {
      widget.events!.off(listener!);
    }
    super.dispose();
  }

  void _load() async {
    execute(() async {
      var res = await widget.twinned
          .getDeviceData(apikey: widget.authToken, deviceId: _data!.deviceId);

      if (validateResponse(res, shouldAlert: false)) {
        _data = res.body!.data!;
        refresh();
      }
    });
  }

  @override
  void setup() async {
    deviceImage = images[_data!.deviceId];

    if (null == deviceImage) {
      String? imageId;

      try {
        var dRes = await widget.twinned
            .getDevice(apikey: widget.authToken, deviceId: _data!.deviceId);
        if (validateResponse(dRes, shouldAlert: false)) {
          _device = dRes.body!.entity;
          int idx = _device!.selectedImage ?? 0;
          if (idx < 0) idx = 0;
          imageId = dRes.body!.entity!.images!.length > idx
              ? dRes.body!.entity!.images![idx]
              : null;
        }
      } catch (e, s) {
        debugPrint('$e\n$s');
      }

      try {
        if (null == imageId || imageId.isEmpty) {
          var mRes = await widget.twinned.getDeviceModel(
              apikey: widget.authToken, modelId: _data!.modelId);

          if (validateResponse(mRes, shouldAlert: false)) {
            _deviceModel = mRes.body!.entity;
            int idx = _deviceModel!.selectedImage ?? 0;
            if (idx < 0) idx = 0;
            imageId = mRes.body!.entity!.images![idx];
          }
          debugPrint("*** Model ImageID: ${imageId ?? 'Null'}");
        }
      } catch (e, s) {
        debugPrint('$e\n$s');
      }

      if (null != _device) {
        _customWidget = _device!.customWidget;
      }

      if (null == _customWidget && null != _deviceModel) {
        _customWidget = _deviceModel!.customWidget;
      }

      if (null != _customWidget) {
        ScreenWidgetType widgetType =
            ScreenWidgetType.values.byName(_customWidget!.id);

        Map<String, dynamic> attributes =
            _customWidget!.attributes as Map<String, dynamic>;
        Map<String, dynamic> data = {};

        if (null != _data) {
          data = _data!.data as Map<String, dynamic>;
        }

        switch (widgetType) {
          case ScreenWidgetType.fillableRectangle:
            deviceImage = FillableRectangle(attributes: attributes, data: data);
            break;
          case ScreenWidgetType.fillableCircle:
            deviceImage = FillableCircle(attributes: attributes, data: data);
            break;
        }
      } else {
        deviceImage ??= TwinImageHelper.getDomainImage(imageId!);
      }
    }

    refresh();
  }

  @override
  Widget build(BuildContext context) {
    final bool showSeries =
        null != widget.data.series && widget.data.series!.isNotEmpty;
    final bool showTrends =
        null != widget.data.trends && widget.data.trends!.isNotEmpty;

    double centerWidth =
        widget.width! - (widget.leftMenuWidth! + widget.rightMenuWidth!);
    double centerHeight =
        widget.height! - (widget.topMenuHeight! + widget.bottomMenuHeight!);
    double width = widget.width!;
    double height = widget.height!;
    if (showSeries || showTrends || widget.showTitle!) {
      height += 28;
    }

    debugPrint('series: ${widget.data.series}, trends: ${widget.data.trends}');

    return MouseRegion(
      key: Key(const Uuid().v4()),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onDoubleTap: () async {
          if (null != widget.onDeviceDoubleTapped) {
            await widget.onDeviceDoubleTapped!();
            _load();
          }
        },
        child: Card(
          elevation: 10,
          child: Container(
            color: Colors.white,
            width: width,
            height: height,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                if (showSeries || showTrends || widget.showTitle!)
                  Padding(
                    padding: const EdgeInsets.only(top: 4.0),
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: Wrap(
                        children: [
                          if (widget.showTitle!)
                            Text(
                              _title,
                              style: const TextStyle(
                                  overflow: TextOverflow.ellipsis,
                                  fontWeight: FontWeight.bold),
                            ),
                          divider(horizontal: true),
                          if (showSeries || showTrends)
                            SizedBox(
                              width: 18,
                              height: 18,
                              child: GestureDetector(
                                onTap: () {
                                  widget.onDeviceAnalyticsTapped();
                                },
                                child: const Tooltip(
                                  message: 'Time series and trend analytics',
                                  child: Icon(Icons.bar_chart),
                                ),
                              ),
                            ),
                          if (showSeries || showTrends)
                            divider(horizontal: true),
                        ],
                      ),
                    ),
                  ),
                if (widget.showTitle!)
                  const SizedBox(
                    height: 4,
                  ),
                SizedBox(
                    height: widget.topMenuHeight,
                    child: SingleChildScrollView(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          EvaluatedAlarmsSnippet(
                            deviceData: _data!,
                            twinned: widget.twinned,
                            authToken: widget.authToken,
                          )
                        ],
                      ),
                    )),
                SizedBox(
                    width: widget.width,
                    height: centerHeight,
                    child: Row(
                      children: [
                        //Left Menu Bar
                        SizedBox(
                            width: widget.leftMenuWidth,
                            height: centerHeight,
                            child: const Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [],
                            )),
                        //Center Device Image
                        SizedBox(
                            width: centerWidth,
                            height: centerHeight,
                            child: deviceImage),
                        //Right Menu Bar
                        SizedBox(
                            width: widget.rightMenuWidth,
                            height: centerHeight,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                SingleChildScrollView(
                                  scrollDirection: Axis.vertical,
                                  child: EvaluatedDisplaysSnippet(
                                    twin: widget.twinned,
                                    authToken: widget.authToken,
                                    deviceData: _data!,
                                    orientation: Axis.vertical,
                                  ),
                                )
                              ],
                            )),
                      ],
                    )),
                //Bottom Menu Bar
                SizedBox(
                    height: widget.topMenuHeight,
                    child: SingleChildScrollView(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(DateTime.fromMillisecondsSinceEpoch(
                                  _data!.updatedStamp)
                              .toString()),
                          if (null != _data!.geolocation)
                            const Tooltip(
                                message: 'Live map view coming soon',
                                child: Icon(Icons.pin_drop)),
                        ],
                      ),
                    )),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
