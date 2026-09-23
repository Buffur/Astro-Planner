import '../models/weather_conditions.dart';
import '../models/weather_snapshot.dart';

abstract class WeatherRepository {
  /// The legacy "now + 48 h" forecast used by the current weather card.
  /// Superseded by [fetchSnapshot] (ADR-012); the UI moves to it in TASKs
  /// 9.3–9.4.
  Future<WeatherConditions?> getCurrentWeather(
    double latitude,
    double longitude, {
    bool forceRefresh = false,
  });

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
