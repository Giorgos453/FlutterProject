import '../models/district.dart';

/// Central app constants — no magic numbers elsewhere.
class XpReward {
  const XpReward._();

  static const int dailyLogin = 1;
  static const int quizCorrect = 2;
  static const int quizPerfect = 3;
  static const int coolSpotCheckIn = 5;
  static const int sevenDayStreak = 10;
}

class XpPenalty {
  const XpPenalty._();

  static const int tempAbove38 = -15;
  static const int tempAbove34 = -8;
  static const int inactivity3Days = -4;
}

class TemperatureThreshold {
  const TemperatureThreshold._();

  static const double warmThreshold = 28;
  static const double hotThreshold = 34;
  static const double extremeThreshold = 38;
}

/// Stage XP thresholds used by [SolStage].
class StageThreshold {
  const StageThreshold._();

  static const int melting = 0;
  static const int hot = 10;
  static const int warm = 30;
  static const int cool = 60;
  static const int radiant = 100;
}

/// Display-only XP penalty per heat level (not persisted).
class TempDisplayPenalty {
  const TempDisplayPenalty._();

  static const int comfortable = 0;
  static const int warm = 5;
  static const int hot = 15;
  static const int extreme = 30;
}

/// Returns the display XP penalty for a given temperature in °C.
int tempPenalty(double temp) {
  if (temp >= TemperatureThreshold.extremeThreshold) {
    return TempDisplayPenalty.extreme;
  }
  if (temp >= TemperatureThreshold.hotThreshold) {
    return TempDisplayPenalty.hot;
  }
  if (temp >= TemperatureThreshold.warmThreshold) {
    return TempDisplayPenalty.warm;
  }
  return TempDisplayPenalty.comfortable;
}

/// Madrid districts with approximate centroid coordinates.
const List<District> madridDistricts = [
  District(name: 'Centro', lat: 40.4156, lng: -3.7038),
  District(name: 'Salamanca', lat: 40.4300, lng: -3.6780),
  District(name: 'Chamberí', lat: 40.4350, lng: -3.7030),
  District(name: 'Retiro', lat: 40.4080, lng: -3.6770),
  District(name: 'Arganzuela', lat: 40.3950, lng: -3.6950),
  District(name: 'Chamartín', lat: 40.4600, lng: -3.6770),
  District(name: 'Tetuán', lat: 40.4600, lng: -3.7000),
  District(name: 'Latina', lat: 40.4020, lng: -3.7400),
];

enum CoolSpotType { fountain, shade, acBuilding, park }

class CoolSpot {
  const CoolSpot({
    required this.name,
    required this.type,
    required this.lat,
    required this.lng,
  });

  final String name;
  final CoolSpotType type;
  final double lat;
  final double lng;
}

const List<CoolSpot> coolSpots = [
  CoolSpot(
    name: 'Parque del Retiro',
    type: CoolSpotType.park,
    lat: 40.4153,
    lng: -3.6844,
  ),
  CoolSpot(
    name: 'Fuente de Cibeles',
    type: CoolSpotType.fountain,
    lat: 40.4193,
    lng: -3.6936,
  ),
  CoolSpot(
    name: 'Templo de Debod',
    type: CoolSpotType.park,
    lat: 40.4240,
    lng: -3.7176,
  ),
  CoolSpot(
    name: 'Madrid Río',
    type: CoolSpotType.park,
    lat: 40.3936,
    lng: -3.7186,
  ),
  CoolSpot(
    name: 'Jardín Botánico',
    type: CoolSpotType.shade,
    lat: 40.4110,
    lng: -3.6906,
  ),
  CoolSpot(
    name: 'Parque del Oeste',
    type: CoolSpotType.park,
    lat: 40.4290,
    lng: -3.7200,
  ),
  CoolSpot(
    name: 'Estanque del Retiro',
    type: CoolSpotType.fountain,
    lat: 40.4170,
    lng: -3.6824,
  ),
  CoolSpot(
    name: 'CaixaForum',
    type: CoolSpotType.acBuilding,
    lat: 40.4112,
    lng: -3.6936,
  ),
  CoolSpot(
    name: 'Mercado de San Miguel',
    type: CoolSpotType.acBuilding,
    lat: 40.4154,
    lng: -3.7090,
  ),
  CoolSpot(
    name: 'El Corte Inglés Callao',
    type: CoolSpotType.acBuilding,
    lat: 40.4200,
    lng: -3.7058,
  ),
];
