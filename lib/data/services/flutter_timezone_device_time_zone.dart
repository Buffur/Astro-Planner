import 'package:flutter_timezone/flutter_timezone.dart';

import '../../core/diagnostics/app_log.dart';
import '../../domain/services/device_time_zone.dart';

/// [DeviceTimeZone] backed by the `flutter_timezone` plugin (Apache-2.0;
/// owner decision, TASK 7.3).
class FlutterTimezoneDeviceTimeZone implements DeviceTimeZone {
  @override
  Future<String?> zoneId() async {
    try {
      final info = await FlutterTimezone.getLocalTimezone();
      final id = info.identifier;
      return id.isEmpty ? null : id;
    } catch (e) {
      AppLog.warning('time', 'Device time zone unavailable', error: e);
      return null;
    }
  }
}
