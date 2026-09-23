import 'package:astroplan/domain/services/location_service.dart';

/// Test double for [LocationService]: never touches GPS or platform channels.
///
/// With a [location] it behaves like a granted permission; without one it
/// returns [LocationUnavailable] with [failure] (by default a denied
/// permission).
class FakeLocationService implements LocationService {
  FakeLocationService({
    this.location,
    this.failure = LocationFailure.permissionDenied,
  });

  final DeviceLocation? location;
  final LocationFailure failure;

  /// How many times `getCurrentLocation()` has been called.
  int calls = 0;

  /// How many times each settings page was opened.
  int locationSettingsOpened = 0;
  int appSettingsOpened = 0;

  @override
  Future<LocationResult> getCurrentLocation() async {
    calls++;
    final found = location;
    return found != null ? LocationFound(found) : LocationUnavailable(failure);
  }

  @override
  Future<bool> openLocationSettings() async {
    locationSettingsOpened++;
    return true;
  }

  @override
  Future<bool> openAppSettings() async {
    appSettingsOpened++;
    return true;
  }
}
