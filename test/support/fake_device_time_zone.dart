import 'package:astroplan/domain/services/device_time_zone.dart';

/// Test double for [DeviceTimeZone]: never touches the platform channel.
class FakeDeviceTimeZone implements DeviceTimeZone {
  FakeDeviceTimeZone([this.id]);

  final String? id;

  @override
  Future<String?> zoneId() async => id;
}
