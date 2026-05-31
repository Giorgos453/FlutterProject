import '../models/district.dart';
import '../models/heat_level.dart';
import '../models/weather_data.dart';

/// View-model pairing a district with its current weather.
class DistrictWeather {
  const DistrictWeather({
    required this.district,
    required this.weather,
  });

  final District district;
  final WeatherData weather;

  /// Heat classification for this district's temperature.
  HeatLevel get heatLevel => weather.heatLevel;
}
