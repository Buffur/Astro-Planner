import 'package:astroplan/domain/models/weather_snapshot.dart';

/// For test doubles of `WeatherRepository` that serve no forecast: every
/// night's snapshot is unavailable (TASK 9.2; the only weather path since
/// TASK 9.4).
mixin NoSnapshotWeather {
  Future<WeatherFetch> fetchSnapshot({
    required double latitude,
    required double longitude,
    required DateTime startUtc,
    required DateTime endUtc,
  }) async => const WeatherFetchFailed(WeatherFailure.unavailable);
}
