import 'package:flutter/foundation.dart';

import '../models/weather_data.dart';
import '../services/weather_service.dart';

/// Loading status for the weather request.
enum WeatherStatus { idle, loading, success, error }

/// Manages weather state and exposes it to the widget tree.
class WeatherProvider extends ChangeNotifier {
  WeatherProvider(this._service);

  final WeatherService _service;

  WeatherStatus _status = WeatherStatus.idle;
  WeatherData? _data;
  String? _errorMessage;

  WeatherStatus get status => _status;
  WeatherData? get data => _data;
  String? get errorMessage => _errorMessage;

  /// Fetches the current weather for Madrid.
  Future<void> loadWeather() async {
    _status = WeatherStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      _data = await _service.fetchCurrentWeather(lat: 40.4168, lng: -3.7038);
      _status = WeatherStatus.success;
    } on WeatherException catch (e) {
      _errorMessage = e.message;
      _status = WeatherStatus.error;
    }

    notifyListeners();
  }
}
