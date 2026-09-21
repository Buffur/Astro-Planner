import 'package:geolocator/geolocator.dart';

import '../../domain/services/location_service.dart';

/// [LocationService] backed by the `geolocator` plugin.
class GeolocatorLocationService implements LocationService {
  @override
  Future<DeviceLocation?> getCurrentLocation() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return null;
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return null;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return null;
    }

    final position = await Geolocator.getCurrentPosition();
    return DeviceLocation(
      latitude: position.latitude,
      longitude: position.longitude,
    );
  }
}
