import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';

import '../core/constants.dart';
import '../models/district_weather.dart';
import '../providers/map_provider.dart';
import '../widgets/state_views.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final mapProv = context.read<MapProvider>();
      if (mapProv.status == MapStatus.idle) {
        mapProv.loadDistrictWeather();
      }
      mapProv.loadUserLocation();
    });
  }

  Future<void> _onRefresh() async {
    final mapProv = context.read<MapProvider>();
    await mapProv.loadDistrictWeather();
    mapProv.loadUserLocation();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Heat Map')),
      body: Consumer<MapProvider>(
        builder: (context, mapProv, _) {
          return Stack(
            children: [
              RefreshIndicator(
                onRefresh: _onRefresh,
                child: Stack(
                  children: [
                    // ScrollView overlay so RefreshIndicator can trigger
                    Positioned.fill(
                      child: FlutterMap(
                        options: const MapOptions(
                          initialCenter: LatLng(40.4168, -3.7038),
                          initialZoom: 12,
                        ),
                        children: [
                          TileLayer(
                            urlTemplate:
                                'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                            userAgentPackageName: 'com.solbuddy.madrid',
                          ),
                          if (mapProv.status == MapStatus.success)
                            MarkerLayer(markers: _buildMarkers(mapProv)),
                          const RichAttributionWidget(
                            attributions: [
                              TextSourceAttribution(
                                  'OpenStreetMap contributors'),
                            ],
                          ),
                        ],
                      ),
                    ),
                    // Transparent list so pull-to-refresh works on map
                    ListView(),
                  ],
                ),
              ),
              if (mapProv.status == MapStatus.loading)
                const Positioned.fill(
                  child: ColoredBox(
                    color: Color(0x40000000),
                    child: LoadingView(),
                  ),
                ),
              if (mapProv.status == MapStatus.error)
                Positioned(
                  top: kScreenPadding,
                  left: kScreenPadding,
                  right: kScreenPadding,
                  child: Card(
                    color: Theme.of(context).colorScheme.errorContainer,
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            mapProv.errorMessage ?? 'Could not load map data',
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          FilledButton.tonal(
                            onPressed: mapProv.loadDistrictWeather,
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              if (mapProv.status == MapStatus.success &&
                  mapProv.userPosition == null)
                Positioned(
                  bottom: kScreenPadding,
                  left: kScreenPadding,
                  right: kScreenPadding,
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      child: Row(
                        children: [
                          Icon(Icons.location_off,
                              size: 18,
                              color: Theme.of(context).colorScheme.outline),
                          const SizedBox(width: 8),
                          Text(
                            'Location not available',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  List<Marker> _buildMarkers(MapProvider mapProv) {
    final markers = <Marker>[];

    for (final dw in mapProv.districtWeathers) {
      markers.add(Marker(
        point: LatLng(dw.district.lat, dw.district.lng),
        width: 46,
        height: 46,
        child: GestureDetector(
          onTap: () => _showDistrictInfo(dw),
          child: _DistrictMarker(districtWeather: dw),
        ),
      ));
    }

    final pos = mapProv.userPosition;
    if (pos != null) {
      markers.add(Marker(
        point: LatLng(pos.latitude, pos.longitude),
        width: 22,
        height: 22,
        child: const _UserLocationDot(),
      ));
    }

    return markers;
  }

  void _showDistrictInfo(DistrictWeather dw) {
    final temp = dw.weather.temperature.toStringAsFixed(1);
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(SnackBar(
        content:
            Text('${dw.district.name}: $temp °C — ${dw.heatLevel.label}'),
        duration: const Duration(seconds: 2),
      ));
  }
}

// ---------------------------------------------------------------------------
// Marker widgets
// ---------------------------------------------------------------------------

class _DistrictMarker extends StatelessWidget {
  const _DistrictMarker({required this.districtWeather});

  final DistrictWeather districtWeather;

  @override
  Widget build(BuildContext context) {
    final color = districtWeather.heatLevel.color;
    final temp = districtWeather.weather.temperature.round();

    return DecoratedBox(
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 2),
        boxShadow: const [
          BoxShadow(color: Color(0x40000000), blurRadius: 4),
        ],
      ),
      child: Center(
        child: Text(
          '$temp°',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

class _UserLocationDot extends StatelessWidget {
  const _UserLocationDot();

  @override
  Widget build(BuildContext context) {
    return const DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.blue,
        shape: BoxShape.circle,
        border: Border.fromBorderSide(
          BorderSide(color: Colors.white, width: 3),
        ),
        boxShadow: [
          BoxShadow(color: Color(0x50448AFF), blurRadius: 8, spreadRadius: 2),
        ],
      ),
    );
  }
}
