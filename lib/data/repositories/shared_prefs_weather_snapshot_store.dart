import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../core/diagnostics/app_log.dart';
import '../../domain/models/weather_snapshot.dart';
import '../../domain/repositories/weather_snapshot_store.dart';
import 'storage_guard.dart';

/// [WeatherSnapshotStore] backed by SharedPreferences (TASK 9.3). Times are
/// stored as UTC epoch milliseconds; a null value stays null (unknown).
class SharedPrefsWeatherSnapshotStore implements WeatherSnapshotStore {
  static const int _formatVersion = 1;

  @override
  Future<WeatherSnapshot?> read(String key) async {
    final text = await guardStorage(
      'read the weather cache',
      () async => (await SharedPreferences.getInstance()).getString(key),
    );
    if (text == null) return null;
    try {
      return decode(text);
    } catch (e) {
      // An unreadable entry is treated as absent: the forecast is refetched.
      AppLog.warning('weather', 'Ignoring an unreadable cache entry', error: e);
      return null;
    }
  }

  @override
  Future<void> write(String key, WeatherSnapshot snapshot) => guardStorage(
    'save the weather cache',
    () async => (await SharedPreferences.getInstance()).setString(
      key,
      encode(snapshot),
    ),
  );

  static String encode(WeatherSnapshot s) => jsonEncode({
    'v': _formatVersion,
    'provider': s.provider,
    'model': s.model,
    'fetchedAtUtcMs': s.fetchedAtUtc.millisecondsSinceEpoch,
    'lat': s.latitude,
    'lon': s.longitude,
    'hours': [
      for (final h in s.hours)
        {
          't': h.timeUtc.millisecondsSinceEpoch,
          'cc': h.cloudCoverPct,
          'ccl': h.cloudCoverLowPct,
          'ccm': h.cloudCoverMidPct,
          'cch': h.cloudCoverHighPct,
          'pp': h.precipitationProbabilityPct,
          'ws': h.windSpeedKmh,
          'wg': h.windGustsKmh,
          'tc': h.temperatureC,
          'dp': h.dewPointC,
          'rh': h.relativeHumidityPct,
          'vis': h.visibilityM,
        },
    ],
  });

  /// Throws [FormatException] for an unknown format version.
  static WeatherSnapshot decode(String text) {
    final m = jsonDecode(text) as Map<String, dynamic>;
    if (m['v'] != _formatVersion) {
      throw const FormatException('unknown weather cache format');
    }
    double? d(Object? v) => (v as num?)?.toDouble();
    DateTime utc(Object? ms) =>
        DateTime.fromMillisecondsSinceEpoch(ms as int, isUtc: true);
    return WeatherSnapshot(
      provider: m['provider'] as String,
      model: m['model'] as String,
      fetchedAtUtc: utc(m['fetchedAtUtcMs']),
      latitude: d(m['lat'])!,
      longitude: d(m['lon'])!,
      hours: [
        for (final h in m['hours'] as List<dynamic>)
          WeatherHour(
            timeUtc: utc(h['t']),
            cloudCoverPct: d(h['cc']),
            cloudCoverLowPct: d(h['ccl']),
            cloudCoverMidPct: d(h['ccm']),
            cloudCoverHighPct: d(h['cch']),
            precipitationProbabilityPct: d(h['pp']),
            windSpeedKmh: d(h['ws']),
            windGustsKmh: d(h['wg']),
            temperatureC: d(h['tc']),
            dewPointC: d(h['dp']),
            relativeHumidityPct: d(h['rh']),
            visibilityM: d(h['vis']),
          ),
      ],
    );
  }
}
