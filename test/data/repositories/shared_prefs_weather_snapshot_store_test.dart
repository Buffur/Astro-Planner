// TASK 9.3: the persistent weather cache keeps UTC instants, the fetch time
// and unknown (null) values exactly; unreadable entries are treated as
// absent.

import 'package:astroplan/data/repositories/shared_prefs_weather_snapshot_store.dart';
import 'package:astroplan/domain/models/weather_snapshot.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final snapshot = WeatherSnapshot(
    provider: 'open-meteo',
    model: 'best_match',
    fetchedAtUtc: DateTime.utc(2026, 9, 24, 12, 30),
    latitude: 46.05,
    longitude: 14.51,
    hours: [
      WeatherHour(
        timeUtc: DateTime.utc(2026, 9, 24, 18),
        cloudCoverPct: 12,
        cloudCoverHighPct: 40,
        windGustsKmh: 22.5,
        visibilityM: 24140,
      ),
      WeatherHour(timeUtc: DateTime.utc(2026, 9, 24, 19)),
    ],
  );

  test('round trip keeps UTC instants, metadata and nulls', () async {
    SharedPreferences.setMockInitialValues({});
    final store = SharedPrefsWeatherSnapshotStore();
    await store.write('k', snapshot);
    final back = (await store.read('k'))!;

    expect(back.provider, 'open-meteo');
    expect(back.model, 'best_match');
    expect(back.fetchedAtUtc, snapshot.fetchedAtUtc);
    expect(back.fetchedAtUtc.isUtc, isTrue);
    expect(back.hours.first.timeUtc, DateTime.utc(2026, 9, 24, 18));
    expect(back.hours.first.cloudCoverHighPct, 40);
    expect(back.hours.first.visibilityM, 24140);
    expect(back.hours.first.precipitationProbabilityPct, isNull);
    expect(
      back.hours.last.cloudCoverPct,
      isNull,
      reason: 'unknown stays unknown',
    );
  });

  test('missing and unreadable entries read as absent', () async {
    SharedPreferences.setMockInitialValues({
      'bad': 'not json',
      'future': '{"v": 99}',
    });
    final store = SharedPrefsWeatherSnapshotStore();
    expect(await store.read('none'), isNull);
    expect(await store.read('bad'), isNull);
    expect(await store.read('future'), isNull);
  });
}
