import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/weather_data.dart';

/// Thrown when the weather API request fails.
class WeatherException implements Exception {
  const WeatherException(this.message);

  final String message;

  @override
  String toString() => 'WeatherException: $message';
}

/// Fetches current weather data from the Open-Meteo API.
class WeatherService {
  const WeatherService();

  static const _baseUrl = 'https://api.open-meteo.com/v1/forecast';

  /// Returns the current weather for multiple coordinates in one request.
  ///
  /// Open-Meteo accepts comma-separated latitude/longitude values and
  /// returns results in the same order as the input.
  Future<List<WeatherData>> fetchWeatherForCoordinates(
    List<({double lat, double lng})> coords,
  ) async {
    if (coords.isEmpty) return const [];

    final latitudes = coords.map((c) => c.lat.toString()).join(',');
    final longitudes = coords.map((c) => c.lng.toString()).join(',');

    final uri = Uri.parse(_baseUrl).replace(queryParameters: {
      'latitude': latitudes,
      'longitude': longitudes,
      'current': 'temperature_2m',
    });

    final http.Response response;
    try {
      response = await http.get(uri).timeout(const Duration(seconds: 15));
    } on Exception catch (e) {
      throw WeatherException('Network error: $e');
    }

    if (response.statusCode != 200) {
      throw WeatherException('HTTP ${response.statusCode}: ${response.body}');
    }

    try {
      final json = jsonDecode(response.body);
      if (json is List) {
        return json
            .cast<Map<String, dynamic>>()
            .map(WeatherData.fromOpenMeteo)
            .toList();
      }
      return [WeatherData.fromOpenMeteo(json as Map<String, dynamic>)];
    } on Exception catch (e) {
      throw WeatherException('Failed to parse response: $e');
    }
  }

  /// Returns the current weather for the given coordinates.
  Future<WeatherData> fetchCurrentWeather({
    required double lat,
    required double lng,
  }) async {
    final uri = Uri.parse(_baseUrl).replace(queryParameters: {
      'latitude': lat.toString(),
      'longitude': lng.toString(),
      'current': 'temperature_2m',
    });

    final http.Response response;
    try {
      response = await http.get(uri).timeout(const Duration(seconds: 10));
    } on Exception catch (e) {
      throw WeatherException('Network error: $e');
    }

    if (response.statusCode != 200) {
      throw WeatherException('HTTP ${response.statusCode}: ${response.body}');
    }

    try {
      final json = jsonDecode(response.body) as Map<String, dynamic>;
      return WeatherData.fromOpenMeteo(json);
    } on Exception catch (e) {
      throw WeatherException('Failed to parse response: $e');
    }
  }
}
