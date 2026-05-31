import 'heat_level.dart';

/// Snapshot of the current weather conditions.
class WeatherData {
  const WeatherData({required this.temperature, required this.fetchedAt});

  final double temperature;
  final DateTime fetchedAt;

  /// Heat classification for the current temperature.
  HeatLevel get heatLevel => HeatLevel.fromTemperature(temperature);

  /// Parses the Open-Meteo JSON response.
  factory WeatherData.fromOpenMeteo(Map<String, dynamic> json) {
    final current = json['current'] as Map<String, dynamic>;
    return WeatherData(
      temperature: (current['temperature_2m'] as num).toDouble(),
      fetchedAt: DateTime.now(),
    );
  }

  WeatherData copyWith({double? temperature, DateTime? fetchedAt}) {
    return WeatherData(
      temperature: temperature ?? this.temperature,
      fetchedAt: fetchedAt ?? this.fetchedAt,
    );
  }
}
