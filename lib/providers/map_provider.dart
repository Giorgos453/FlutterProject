import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';

import '../core/constants.dart';
import '../models/district_weather.dart';
import '../services/location_service.dart';
import '../services/weather_service.dart';

/// Loading status for the map data.
enum MapStatus { idle, loading, success, error }

/// Manages district weather data and the user's GPS position.
class MapProvider extends ChangeNotifier {
  MapProvider({
    required WeatherService weatherService,
    required LocationService locationService,
  })  : _weatherService = weatherService,
        _locationService = locationService;

  final WeatherService _weatherService;
  final LocationService _locationService;

  MapStatus _status = MapStatus.idle;
  String? _errorMessage;
  List<DistrictWeather> _districtWeathers = const [];
  Position? _userPosition;

  MapStatus get status => _status;
  String? get errorMessage => _errorMessage;
  List<DistrictWeather> get districtWeathers => _districtWeathers;
  Position? get userPosition => _userPosition;

  /// Fetches the current temperature for all Madrid districts.
  Future<void> loadDistrictWeather() async {
    _status = MapStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      final coords = madridDistricts
          .map((d) => (lat: d.lat, lng: d.lng))
          .toList();
      final weathers =
          await _weatherService.fetchWeatherForCoordinates(coords);

      _districtWeathers = [
        for (var i = 0; i < madridDistricts.length; i++)
          DistrictWeather(
            district: madridDistricts[i],
            weather: weathers[i],
          ),
      ];
      _status = MapStatus.success;
    } on WeatherException catch (e) {
      _errorMessage = e.message;
      _status = MapStatus.error;
    }

    notifyListeners();
  }

  /// Requests the user's GPS position. Fails silently — the map
  /// works without a location marker.
  Future<void> loadUserLocation() async {
    try {
      _userPosition = await _locationService.getCurrentPosition();
      notifyListeners();
    } on LocationException {
      // GPS denied or disabled — no marker, no error
    }
  }
}
