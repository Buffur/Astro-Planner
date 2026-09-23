import 'package:astroplan/domain/models/weather_snapshot.dart';

/// For test doubles of `WeatherRepository` that only serve the legacy
/// `getCurrentWeather` path: the night snapshot (TASK 9.2) is unavailable.
mixin NoSnapshotWeather {
  Future<WeatherFetch> fetchSnapshot({
    required double latitude,
    required double longitude,
    required DateTime startUtc,
    required DateTime endUtc,
  }) async => const WeatherFetchFailed(WeatherFailure.unavailable);
}
