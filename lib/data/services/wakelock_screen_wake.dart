import 'package:wakelock_plus/wakelock_plus.dart';

import '../../core/diagnostics/app_log.dart';

import '../../domain/services/screen_wake.dart';

/// [ScreenWake] through `wakelock_plus` (BSD-3-Clause; a screen wakelock
/// only — no permission, nothing kept alive in the background).
class WakelockScreenWake implements ScreenWake {
  @override
  Future<void> keepOn(bool on) async {
    try {
      await WakelockPlus.toggle(enable: on);
    } catch (e) {
      // The screen just sleeps.
      AppLog.warning('display', 'Screen wakelock unavailable', error: e);
    }
  }
}
