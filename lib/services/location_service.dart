import 'package:geolocator/geolocator.dart';

/// Thrown when location access fails.
class LocationException implements Exception {
  const LocationException(this.message);

  final String message;

  @override
  String toString() => 'LocationException: $message';
}

/// Wraps [Geolocator] with explicit permission handling.
class LocationService {
  const LocationService();

  /// Whether the device's location services are enabled.
  Future<bool> isLocationServiceEnabled() =>
      Geolocator.isLocationServiceEnabled();

  /// Checks the current permission and requests it if [denied].
  Future<LocationPermission> checkAndRequestPermission() async {
    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    return permission;
  }

  /// Returns the device's current position.
  ///
  /// Throws [LocationException] when the location service is disabled
  /// or the user denied the permission.
  Future<Position> getCurrentPosition() async {
    final enabled = await isLocationServiceEnabled();
    if (!enabled) {
      throw const LocationException('Location services are disabled');
    }

    final permission = await checkAndRequestPermission();
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      throw const LocationException('Location permission denied');
    }

    return Geolocator.getCurrentPosition();
  }
}
