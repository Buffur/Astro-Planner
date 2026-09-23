/// A device position in WGS-84 geographic coordinates.
class DeviceLocation {
  const DeviceLocation({required this.latitude, required this.longitude});

  /// Latitude in decimal degrees, north positive.
  final double latitude;

  /// Longitude in decimal degrees, east positive.
  final double longitude;
}

/// Why the device position could not be obtained without further user action
/// (TASK 7.2). Each value needs a different remedy, so the UI can explain it.
enum LocationFailure {
  /// Location services are switched off for the whole device.
  serviceDisabled,

  /// The user denied the permission; asking again is possible.
  permissionDenied,

  /// The permission is denied permanently; only the app settings can change it.
  permissionDeniedForever,
}

/// Outcome of a position request: a [LocationFound] (permission granted) or a
/// [LocationUnavailable] with its [LocationFailure].
sealed class LocationResult {
  const LocationResult();
}

final class LocationFound extends LocationResult {
  const LocationFound(this.location);

  final DeviceLocation location;
}

final class LocationUnavailable extends LocationResult {
  const LocationUnavailable(this.reason);

  final LocationFailure reason;
}

/// Source of the device's current position.
///
/// This is the seam between the app and the platform's location API: everything
/// that touches GPS, permissions or platform channels lives in an
/// implementation, so ViewModels and tests never depend on them.
abstract class LocationService {
  /// Requests the device's current position, asking for the permission when it
  /// has not been decided yet. Returns [LocationUnavailable] when the position
  /// cannot be obtained without further user action.
  ///
  /// Unexpected platform errors are not swallowed.
  Future<LocationResult> getCurrentLocation();

  /// Opens the device's location settings (the remedy for
  /// [LocationFailure.serviceDisabled]). Returns false if they could not be
  /// opened.
  Future<bool> openLocationSettings();

  /// Opens this app's settings page (the remedy for
  /// [LocationFailure.permissionDeniedForever]). Returns false if it could not
  /// be opened.
  Future<bool> openAppSettings();
}
