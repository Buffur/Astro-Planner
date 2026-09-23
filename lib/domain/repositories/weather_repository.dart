import '../models/weather_snapshot.dart';

abstract class WeatherRepository {
  /// The hourly forecast covering `[startUtc, endUtc)` for a site (ADR-012,
  /// TASK 9.2), in UTC, capped at the provider's horizon. Never throws;
  /// failures are a [WeatherFetchFailed].
  Future<WeatherFetch> fetchSnapshot({
    required double latitude,
    required double longitude,
    required DateTime startUtc,
    required DateTime endUtc,
  });
}
