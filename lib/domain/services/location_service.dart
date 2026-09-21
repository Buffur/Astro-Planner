/// A device position in WGS-84 geographic coordinates.
class DeviceLocation {
  const DeviceLocation({required this.latitude, required this.longitude});

  /// Latitude in decimal degrees, north positive.
  final double latitude;

  /// Longitude in decimal degrees, east positive.
  final double longitude;
}

/// Source of the device's current position.
///
/// This is the seam between the app and the platform's location API: everything
/// that touches GPS, permissions or platform channels lives in an
/// implementation, so ViewModels and tests never depend on them.
abstract class LocationService {
  /// Returns the device's current position, or `null` when it cannot be obtained
  /// without further user action: location services are switched off, or the
  /// permission is denied (including permanently denied).
  ///
  /// Unexpected platform errors are not swallowed.
  Future<DeviceLocation?> getCurrentLocation();
}
