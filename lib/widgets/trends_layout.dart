import 'package:flutter/material.dart';
import 'package:twin_commons/analytics/device_trends.dart';
import 'package:twin_commons/core/base_state.dart';
import 'package:twin_commons/core/busy_indicator.dart';
import 'package:twinned_api/api/twinned.swagger.dart';
import 'package:uuid/uuid.dart';

import 'date_filter_dropdown.dart';

class TrendsLayoutWidget extends StatefulWidget {
  final Twinned twinned;
  final String apiKey;
  final DeviceModel model;
  final String deviceId;
  final String field;
  final String title;
  final Color backgroundColor;
  final TextStyle titleTextStyle;
  final double opacity;
  final EdgeInsets outerPadding;
  final EdgeInsets innerPadding;
  final double borderRadius;
  final List<BoxShadow> boxShadow;
  final EdgeInsets padding;
  final Alignment chartAlignment;
  final double height;
  final double smFontSize;
  final double responsiveWidth;

  const TrendsLayoutWidget({
    super.key,
    required this.twinned,
    required this.apiKey,
    required this.model,
    required this.deviceId,
    required this.field,
    required this.title,
    this.backgroundColor = Colors.white,
    this.titleTextStyle = const TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 14,
    ),
    this.opacity = 0.3,
    this.outerPadding = const EdgeInsets.all(20),
    this.innerPadding =
        const EdgeInsets.only(top: 10, left: 10, right: 40, bottom: 10),
    this.borderRadius = 8.0,
    this.padding = const EdgeInsets.all(9),
    this.height = 450,
    this.boxShadow = const [
      BoxShadow(
        color: Color.fromRGBO(169, 169, 169, 0.7),
        spreadRadius: 3,
        blurRadius: 5,
        offset: Offset(0, 1),
      ),
    ],
    this.chartAlignment = Alignment.center,
    this.smFontSize = 12,
    this.responsiveWidth = 768,
  });

  @override
  State<TrendsLayoutWidget> createState() => _TrendsLayoutWidgetState();
}

class _TrendsLayoutWidgetState extends State<TrendsLayoutWidget> {
  DeviceDataTrendsDeviceIdFieldGetFilter? _filter =
      DeviceDataTrendsDeviceIdFieldGetFilter.recent;
  int? _beginStamp = 0;
  int? _endStamp = 0;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    double fontSize = widget.smFontSize;
    return Padding(
      padding: widget.outerPadding,
      child: Align(
        alignment: widget.chartAlignment,
        child: Container(
          decoration: BoxDecoration(
              color: widget.backgroundColor,
              borderRadius: BorderRadius.circular(widget.borderRadius),
              boxShadow: widget.boxShadow),
          child: Padding(
            padding: widget.innerPadding,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                (screenWidth > widget.responsiveWidth)
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children:
                            buildTitleAndFiltersRow(screenWidth, fontSize),
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children:
                            buildTitleAndFiltersColumn(screenWidth, fontSize),
                      ),
                // Row(
                //   mainAxisAlignment: MainAxisAlignment.center,
                //   children: [
                //     Spacer(),
                //       Text(widget.title, style: screenWidth > widget.responsiveWidth
                //   ? widget.titleTextStyle
                //   : widget.titleTextStyle.copyWith(fontSize: fontSize)),
                //     Spacer(),
                //     DateFilterDropdown(
                //       onChanged: (filter, bStamp, eStamp) {
                //         setState(() {
                //           debugPrint('Changing filter...');
                //           _filter = null != filter
                //               ? DeviceDataTrendsDeviceIdFieldGetFilter.values
                //                   .byName(filter!.toLowerCase())
                //               : DeviceDataTrendsDeviceIdFieldGetFilter.today;
                //           _beginStamp = bStamp;
                //           _endStamp = eStamp;
                //         });
                //       },
                //     )
                //   ],
                // ),
                Container(
                  width: MediaQuery.of(context).size.width,
                  height: widget.height,
                  padding: widget.padding,
                  child: DeviceTrendsWidget(
                    key: Key(const Uuid().v4()),
                    twinned: widget.twinned,
                    apiKey: widget.apiKey,
                    height: widget.height - 25,
                    model: widget.model,
                    deviceId: widget.deviceId,
                    field: widget.field,
                    filter: null != _filter
                        ? _filter!.name
                        : DeviceDataTrendsDeviceIdFieldGetFilter.recent.name,
                    beginStamp: _beginStamp,
                    endStamp: _endStamp,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> buildTitleAndFiltersRow(double screenWidth, double fontSize) {
    return [
      const Spacer(),
      Text(widget.title,
          style: screenWidth > 380
              ? widget.titleTextStyle
              : widget.titleTextStyle.copyWith(fontSize: fontSize)),
      const Spacer(),
      const SizedBox(width: 5),
      const BusyIndicator(),
      divider(horizontal: true),
      DateFilterDropdown(
        onChanged: (filter, bStamp, eStamp) {
          setState(() {
            debugPrint('Changing filter...');
            _filter = null != filter
                ? DeviceDataTrendsDeviceIdFieldGetFilter.values
                    .byName(filter.toLowerCase())
                : DeviceDataTrendsDeviceIdFieldGetFilter.recent;
            _beginStamp = bStamp;
            _endStamp = eStamp;
          });
        },
      )
    ];
  }

  List<Widget> buildTitleAndFiltersColumn(double screenWidth, double fontSize) {
    return [
      Text(widget.title,
          style: screenWidth > 380
              ? widget.titleTextStyle
              : widget.titleTextStyle.copyWith(fontSize: fontSize)),
      const SizedBox(height: 8),
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const BusyIndicator(),
          divider(horizontal: true),
          DateFilterDropdown(
            onChanged: (filter, bStamp, eStamp) {
              setState(() {
                debugPrint('Changing filter...');
                _filter = null != filter
                    ? DeviceDataTrendsDeviceIdFieldGetFilter.values
                        .byName(filter.toLowerCase())
                    : DeviceDataTrendsDeviceIdFieldGetFilter.recent;
                _beginStamp = bStamp;
                _endStamp = eStamp;
              });
            },
          )
        ],
      ),
    ];
  }
}
