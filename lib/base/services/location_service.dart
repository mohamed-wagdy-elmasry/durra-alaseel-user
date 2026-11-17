import 'package:geolocator/geolocator.dart';
import 'dart:developer' as developer;

/// Location service with mock support for development/testing.
/// On emulators without GPS, use [setMockLocation] to inject test coordinates.
class LocationService {
  static final LocationService _instance = LocationService._internal();

  factory LocationService() {
    return _instance;
  }

  LocationService._internal();

  double? _mockLat;
  double? _mockLng;
  bool _useMock = false;

  /// Enable mock location (for emulator testing)
  void setMockLocation(double latitude, double longitude) {
    _mockLat = latitude;
    _mockLng = longitude;
    _useMock = true;
    developer.log(
      'Mock location enabled: lat=$latitude, lng=$longitude',
      name: 'LocationService',
    );
  }

  /// Disable mock location
  void clearMockLocation() {
    _useMock = false;
    _mockLat = null;
    _mockLng = null;
    developer.log('Mock location disabled', name: 'LocationService');
  }

  /// Get current position with fallback to mock if enabled
  Future<Position?> getCurrentPosition({
    Duration timeout = const Duration(seconds: 30),
  }) async {
    // If mock is enabled, return immediately
    if (_useMock && _mockLat != null && _mockLng != null) {
      developer.log(
        'Returning mock position: lat=$_mockLat, lng=$_mockLng',
        name: 'LocationService',
      );
      return Position(
        latitude: _mockLat!,
        longitude: _mockLng!,
        timestamp: DateTime.now(),
        accuracy: 5.0,
        altitude: 0.0,
        altitudeAccuracy: 0.0,
        heading: 0.0,
        headingAccuracy: 0.0,
        speed: 0.0,
        speedAccuracy: 0.0,
      );
    }

    // Otherwise get real position
    try {
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.low,
        timeLimit: timeout,
        forceAndroidLocationManager: true,
      );
      return position;
    } catch (e) {
      developer.log('Error getting position: $e', name: 'LocationService');
      return null;
    }
  }

  /// Check if location services are enabled
  Future<bool> isLocationServiceEnabled() async {
    return await Geolocator.isLocationServiceEnabled();
  }

  /// Check and request location permission
  Future<LocationPermission> checkAndRequestPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    return permission;
  }

  /// Open location settings
  Future<bool> openLocationSettings() async {
    return await Geolocator.openLocationSettings();
  }

  /// Get mock status
  bool get isMockEnabled => _useMock;
  double? get mockLat => _mockLat;
  double? get mockLng => _mockLng;
}
