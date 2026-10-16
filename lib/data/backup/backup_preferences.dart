import 'package:shared_preferences/shared_preferences.dart';

import '../../core/diagnostics/app_log.dart';
import '../repositories/shared_prefs_display_preferences_repository.dart';
import '../repositories/shared_prefs_first_run_repository.dart';
import '../repositories/shared_prefs_planner_state_repository.dart';
import '../repositories/shared_prefs_planning_preferences_repository.dart';

/// The settings a backup carries (S8.9; TD-056, ENG-14; DECISIONS E.1,
/// I-10): the planning preferences, the display preferences, the active
/// site id and the first-run flag, as `preferences.json` in the archive.
/// Never the transient position, the catalog seed marker or the plan ids:
/// the position is the device's, the marker describes the device's own
/// database, and the plan ids are cleared instead ([restore],
/// [forgetStaleIds]).
///
/// The file groups values by type: `{"version": 1, "bool": {...},
/// "int": {...}, "double": {...}}`. Only the keys above are read or
/// written, whatever a file holds.
abstract final class BackupPreferences {
  static const version = 1;

  /// Whether [key] is carried by a backup.
  static bool carries(String key) =>
      _keys.contains(key) ||
      key.startsWith(SharedPrefsDisplayPreferencesRepository.sectionPrefix);

  static const _keys = {
    ...SharedPrefsPlanningPreferencesRepository.keys,
    SharedPrefsDisplayPreferencesRepository.fieldModeKey,
    SharedPrefsPlannerStateRepository.activeLocationIdKey,
    SharedPrefsFirstRunRepository.doneKey,
  };

  static Future<SharedPreferences> _open(
    Future<SharedPreferences> Function()? preferences,
  ) => (preferences ?? SharedPreferences.getInstance)();

  /// The carried settings as stored on this device.
  static Future<Map<String, Object?>> read({
    Future<SharedPreferences> Function()? preferences,
  }) async {
    final p = await _open(preferences);
    final bools = <String, bool>{};
    final ints = <String, int>{};
    final doubles = <String, double>{};
    for (final key in p.getKeys().where(carries).toList()..sort()) {
      switch (p.get(key)) {
        case final bool v:
          bools[key] = v;
        case final int v:
          ints[key] = v;
        case final double v:
          doubles[key] = v;
        case final other:
          AppLog.warning('backup', 'Setting $key not carried: $other');
      }
    }
    return {'version': version, 'bool': bools, 'int': ints, 'double': doubles};
  }

  /// A backup's settings checked and reduced to the carried keys with the
  /// right types. Throws [FormatException] for a file this app cannot read.
  static Map<String, Object?> parse(Object? json) {
    if (json is! Map || json['version'] != version) {
      throw const FormatException('Unknown backup preferences');
    }
    Map<String, T> group<T>(String name, T? Function(Object?) cast) {
      final values = json[name];
      if (values == null) return {};
      if (values is! Map) throw FormatException('Bad group $name');
      return {
        for (final MapEntry(:key, :value) in values.entries)
          if (key is String && carries(key))
            key: cast(value) ?? (throw FormatException('Bad value for $key')),
      };
    }

    return {
      'version': version,
      'bool': group<bool>('bool', (v) => v is bool ? v : null),
      'int': group<int>('int', (v) => v is int ? v : null),
      'double': group<double>(
        'double',
        (v) => v is num && v.isFinite ? v.toDouble() : null,
      ),
    };
  }

  /// Applies a restored backup's settings ([parse]d; null for a version 1
  /// archive, which has none) before the restored database opens. The
  /// carried keys are replaced as a whole (an absent key is the default,
  /// as on the device that made the backup). A version 1 archive keeps the
  /// device's settings but not its active site, which may name another
  /// site in the restored database. The plan ids are cleared either way.
  static Future<void> restore(
    Map<String, Object?>? carried, {
    Future<SharedPreferences> Function()? preferences,
  }) async {
    final p = await _open(preferences);
    if (carried == null) {
      await p.remove(SharedPrefsPlannerStateRepository.activeLocationIdKey);
    } else {
      for (final key in p.getKeys().where(carries).toList()) {
        await p.remove(key);
      }
      for (final e in (carried['bool']! as Map<String, bool>).entries) {
        await p.setBool(e.key, e.value);
      }
      for (final e in (carried['int']! as Map<String, int>).entries) {
        await p.setInt(e.key, e.value);
      }
      for (final e in (carried['double']! as Map<String, double>).entries) {
        await p.setDouble(e.key, e.value);
      }
    }
    await _forgetPlanIds(p);
  }

  /// Forgets every id that points into the replaced database: the active
  /// site and the plan ids (a confirmed reset, S8.9).
  static Future<void> forgetStaleIds({
    Future<SharedPreferences> Function()? preferences,
  }) async {
    final p = await _open(preferences);
    await p.remove(SharedPrefsPlannerStateRepository.activeLocationIdKey);
    await _forgetPlanIds(p);
  }

  static Future<void> _forgetPlanIds(SharedPreferences p) async {
    for (final key in SharedPrefsPlannerStateRepository.planIdKeys) {
      await p.remove(key);
    }
  }
}
