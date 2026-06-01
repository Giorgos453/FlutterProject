import 'package:flutter/material.dart';

/// Type of cooling location.
enum CoolSpotType { fountain, shade, acBuilding, park }

/// UI helpers for [CoolSpotType].
extension CoolSpotTypeUi on CoolSpotType {
  /// Material icon representing this spot type.
  IconData get icon => switch (this) {
        CoolSpotType.fountain => Icons.water_drop,
        CoolSpotType.shade => Icons.nature,
        CoolSpotType.acBuilding => Icons.ac_unit,
        CoolSpotType.park => Icons.park,
      };

  /// Human-readable label.
  String get label => switch (this) {
        CoolSpotType.fountain => 'Fountain',
        CoolSpotType.shade => 'Shade',
        CoolSpotType.acBuilding => 'AC Building',
        CoolSpotType.park => 'Park',
      };
}

/// A cooling location in Madrid.
class CoolSpot {
  const CoolSpot({
    required this.id,
    required this.name,
    required this.type,
    required this.lat,
    required this.lng,
  });

  /// Stable identifier used for check-in tracking.
  final String id;

  final String name;
  final CoolSpotType type;
  final double lat;
  final double lng;
}
