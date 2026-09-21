import 'package:astroplan/domain/services/location_service.dart';

/// Test double for [LocationService]: never touches GPS or platform channels.
///
/// With no [location] it behaves like a denied permission or a disabled
/// location service (`getCurrentLocation()` returns `null`).
class FakeLocationService implements LocationService {
  FakeLocationService({this.location});

  final DeviceLocation? location;

  /// How many times `getCurrentLocation()` has been called.
  int calls = 0;

  @override
  Future<DeviceLocation?> getCurrentLocation() async {
    calls++;
    return location;
  }
}
