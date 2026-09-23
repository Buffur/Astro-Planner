import 'package:geolocator/geolocator.dart';

import '../../domain/services/location_service.dart';

/// [LocationService] backed by the `geolocator` plugin.
class GeolocatorLocationService implements LocationService {
  @override
  Future<LocationResult> getCurrentLocation() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return const LocationUnavailable(LocationFailure.serviceDisabled);
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return const LocationUnavailable(LocationFailure.permissionDenied);
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return const LocationUnavailable(LocationFailure.permissionDeniedForever);
    }

    final position = await Geolocator.getCurrentPosition();
    return LocationFound(
      DeviceLocation(
        latitude: position.latitude,
        longitude: position.longitude,
      ),
    );
  }

  @override
  Future<bool> openLocationSettings() => Geolocator.openLocationSettings();

  @override
  Future<bool> openAppSettings() => Geolocator.openAppSettings();
}
