import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';

import '../core/constants.dart';
import '../models/cool_spot.dart';
import '../providers/user_provider.dart';

/// Displays all cool spots in a toggleable list or map view with check-in.
class CoolSpotsScreen extends StatefulWidget {
  const CoolSpotsScreen({super.key});

  @override
  State<CoolSpotsScreen> createState() => _CoolSpotsScreenState();
}

class _CoolSpotsScreenState extends State<CoolSpotsScreen> {
  bool _showMap = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cool Spots'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Selector<UserProvider, int>(
              selector: (_, p) => p.user.visitedSpotIds.length,
              builder: (_, count, _) => Chip(
                avatar: const Icon(Icons.check_circle_outline, size: 18),
                label: Text('$count / ${coolSpots.length}'),
              ),
            ),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: SegmentedButton<bool>(
              segments: const [
                ButtonSegment(
                  value: false,
                  label: Text('List'),
                  icon: Icon(Icons.list),
                ),
                ButtonSegment(
                  value: true,
                  label: Text('Map'),
                  icon: Icon(Icons.map),
                ),
              ],
              selected: {_showMap},
              onSelectionChanged: (selected) =>
                  setState(() => _showMap = selected.first),
            ),
          ),
        ),
      ),
      body: _showMap ? const _CoolSpotMapView() : const _CoolSpotListView(),
    );
  }
}

// ---------------------------------------------------------------------------
// List view
// ---------------------------------------------------------------------------

class _CoolSpotListView extends StatelessWidget {
  const _CoolSpotListView();

  @override
  Widget build(BuildContext context) {
    return Selector<UserProvider, Set<String>>(
      selector: (_, p) => p.user.visitedSpotIds,
      builder: (context, visitedIds, _) {
        return ListView.separated(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 0),
          itemCount: coolSpots.length,
          separatorBuilder: (_, _) => const Divider(height: 1),
          itemBuilder: (context, index) {
            final spot = coolSpots[index];
            final visited = visitedIds.contains(spot.id);
            return _CoolSpotTile(spot: spot, visited: visited);
          },
        );
      },
    );
  }
}

class _CoolSpotTile extends StatelessWidget {
  const _CoolSpotTile({required this.spot, required this.visited});

  final CoolSpot spot;
  final bool visited;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListTile(
      leading: CircleAvatar(
        backgroundColor:
            visited ? Colors.green.shade50 : theme.colorScheme.primaryContainer,
        child: Icon(
          spot.type.icon,
          color: visited ? Colors.green : theme.colorScheme.primary,
        ),
      ),
      title: Text(
        spot.name,
        style: visited
            ? TextStyle(color: theme.colorScheme.onSurfaceVariant)
            : null,
      ),
      subtitle: Text(spot.type.label),
      trailing: visited
          ? Icon(Icons.check_circle, color: Colors.green.shade600)
          : FilledButton.tonal(
              onPressed: () => _checkIn(context),
              child: const Text('Check in'),
            ),
    );
  }

  void _checkIn(BuildContext context) {
    final success = context.read<UserProvider>().onCoolSpotCheckIn(spot.id);
    final messenger = ScaffoldMessenger.of(context);
    messenger
      ..clearSnackBars()
      ..showSnackBar(SnackBar(
        content:
            Text(success ? '+5 XP — checked in!' : 'Already checked in'),
        duration: const Duration(seconds: 2),
      ));
  }
}

// ---------------------------------------------------------------------------
// Map view
// ---------------------------------------------------------------------------

class _CoolSpotMapView extends StatelessWidget {
  const _CoolSpotMapView();

  static const _madridCenter = LatLng(40.4168, -3.7038);

  @override
  Widget build(BuildContext context) {
    return Selector<UserProvider, Set<String>>(
      selector: (_, p) => p.user.visitedSpotIds,
      builder: (context, visitedIds, _) {
        return FlutterMap(
          options: const MapOptions(
            initialCenter: _madridCenter,
            initialZoom: 13,
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.solbuddy.madrid',
            ),
            MarkerLayer(
              markers: coolSpots.map((spot) {
                final visited = visitedIds.contains(spot.id);
                return Marker(
                  point: LatLng(spot.lat, spot.lng),
                  width: 40,
                  height: 40,
                  child: GestureDetector(
                    onTap: () =>
                        _showSpotSheet(context, spot, visited: visited),
                    child: _SpotMarker(spot: spot, visited: visited),
                  ),
                );
              }).toList(),
            ),
            const RichAttributionWidget(
              attributions: [
                TextSourceAttribution('OpenStreetMap contributors'),
              ],
            ),
          ],
        );
      },
    );
  }

  void _showSpotSheet(
    BuildContext context,
    CoolSpot spot, {
    required bool visited,
  }) {
    final messenger = ScaffoldMessenger.of(context);
    final userProvider = context.read<UserProvider>();

    showModalBottomSheet<void>(
      context: context,
      builder: (sheetContext) {
        final theme = Theme.of(sheetContext);
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(spot.type.icon, size: 40, color: theme.colorScheme.primary),
              const SizedBox(height: 12),
              Text(spot.name, style: theme.textTheme.titleLarge),
              const SizedBox(height: 4),
              Text(spot.type.label, style: theme.textTheme.bodyMedium),
              const SizedBox(height: 20),
              if (visited)
                Chip(
                  avatar:
                      Icon(Icons.check_circle, color: Colors.green.shade600),
                  label: const Text('Already visited'),
                )
              else
                FilledButton.icon(
                  onPressed: () {
                    final success =
                        userProvider.onCoolSpotCheckIn(spot.id);
                    Navigator.pop(sheetContext);
                    messenger
                      ..clearSnackBars()
                      ..showSnackBar(SnackBar(
                        content: Text(
                          success
                              ? '+5 XP — checked in!'
                              : 'Already checked in',
                        ),
                        duration: const Duration(seconds: 2),
                      ));
                  },
                  icon: const Icon(Icons.location_on),
                  label: const Text('Check in'),
                ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }
}

class _SpotMarker extends StatelessWidget {
  const _SpotMarker({required this.spot, required this.visited});

  final CoolSpot spot;
  final bool visited;

  @override
  Widget build(BuildContext context) {
    final color = visited ? Colors.green : Colors.orange;
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
        child: Icon(
          visited ? Icons.check : spot.type.icon,
          color: Colors.white,
          size: 20,
        ),
      ),
    );
  }
}
