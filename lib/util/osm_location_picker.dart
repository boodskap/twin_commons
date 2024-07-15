import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_map_cancellable_tile_provider/flutter_map_cancellable_tile_provider.dart';

typedef OnPicked = void Function(LatLng latLng);

class OSMLocationPicker extends StatefulWidget {
  final double? longitude;
  final double? latitude;
  final OnPicked onPicked;
  final bool viewMode;
  const OSMLocationPicker(
      {super.key,
      required this.onPicked,
      this.longitude,
      this.latitude,
      this.viewMode = false});

  @override
  State<OSMLocationPicker> createState() => _OSMLocationPickerState();
}

class _OSMLocationPickerState extends State<OSMLocationPicker> {
  bool counterRotate = false;
  late LatLng _point;
  Alignment selectedAlignment = Alignment.topCenter;
  late final List<Marker> customMarkers;

  @override
  void initState() {
    super.initState();
    _point =
        LatLng(widget.latitude ?? 32.776665, widget.longitude ?? -96.796989);
    customMarkers = <Marker>[
      buildPin(_point),
    ];
  }

  Marker buildPin(LatLng point) => Marker(
      width: 45,
      height: 45,
      point: point,
      child: const Icon(Icons.location_pin));

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Flexible(
          child: FlutterMap(
            options: MapOptions(
              initialCenter: _point,
              onTap: (tapPosition, point) {
                _point = point;
                setState(() {
                  customMarkers.clear();
                  customMarkers.add(buildPin(point));
                });
              },
              initialZoom: 3,
              interactionOptions: const InteractionOptions(
                  flags: InteractiveFlag.pinchZoom |
                      InteractiveFlag.doubleTapZoom |
                      InteractiveFlag.scrollWheelZoom |
                      InteractiveFlag.drag |
                      InteractiveFlag.doubleTapDragZoom),
            ),
            children: [
              openStreetMapTileLayer,
              MarkerLayer(
                markers: customMarkers,
                rotate: counterRotate,
                alignment: selectedAlignment,
              ),
            ],
          ),
        ),
        const SizedBox(
          height: 8,
        ),
        if (!widget.viewMode)
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text(
                'Lat:${_point.latitude}, Lon:${_point.longitude}',
                style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    overflow: TextOverflow.ellipsis),
              ),
            ],
          ),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            if (!widget.viewMode)
              ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text('Cancel')),
            const SizedBox(
              width: 8,
            ),
            if (!widget.viewMode)
              ElevatedButton(
                  onPressed: () {
                    widget.onPicked(_point);
                  },
                  child: const Text('Select')),
            const SizedBox(
              width: 8,
            ),
          ],
        ),
      ],
    );
  }
}

TileLayer get openStreetMapTileLayer => TileLayer(
      urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
      userAgentPackageName: 'dev.fleaflet.flutter_map.example',
      // Use the recommended flutter_map_cancellable_tile_provider package to
      // support the cancellation of loading tiles.
      tileProvider: CancellableNetworkTileProvider(),
    );
