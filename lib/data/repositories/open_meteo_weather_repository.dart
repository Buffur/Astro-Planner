import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../core/time/clock.dart';
import '../../domain/models/weather_snapshot.dart';
import '../../domain/repositories/weather_repository.dart';
import '../services/open_meteo_forecast_parser.dart';

class OpenMeteoWeatherRepository implements WeatherRepository {
  final http.Client _client;
  final Clock _clock;

  OpenMeteoWeatherRepository({http.Client? client, Clock? clock})
    : _client = client ?? http.Client(),
      _clock = clock ?? const SystemClock();

  /// The model requested (ADR-012 §2).
  static const String model = 'best_match';

  /// The provider's horizon: today plus 15 days (`forecast_days` ≤ 16).
  static const int horizonDays = 16;

  static String _hour(DateTime utc) =>
      '${utc.toIso8601String().substring(0, 13)}:00';

  /// The last hour the provider serves, UTC.
  DateTime horizonEndUtc() {
    final now = _clock.nowUtc();
    final today = DateTime.utc(now.year, now.month, now.day);
    return today.add(const Duration(days: horizonDays, hours: -1));
  }

  @override
  Future<WeatherFetch> fetchSnapshot({
    required double latitude,
    required double longitude,
    required DateTime startUtc,
    required DateTime endUtc,
  }) async {
    final start = startUtc.toUtc();
    final horizon = horizonEndUtc();
    if (start.isAfter(horizon)) {
      return const WeatherFetchFailed(WeatherFailure.outOfRange);
    }
    // `end_hour` is inclusive; the night is [start, end).
    var last = endUtc.toUtc().subtract(const Duration(milliseconds: 1));
    if (last.isAfter(horizon)) last = horizon;
    final uri = Uri.https('api.open-meteo.com', '/v1/forecast', {
      'latitude': '$latitude',
      'longitude': '$longitude',
      'hourly': OpenMeteoForecastParser.hourlyVariables.join(','),
      'models': model,
      'timeformat': 'unixtime',
      'start_hour': _hour(start),
      'end_hour': _hour(last),
    });
    try {
      final response = await _client
          .get(uri)
          .timeout(const Duration(seconds: 10));
      final Object? body;
      try {
        body = json.decode(response.body);
      } on FormatException {
        return WeatherFetchFailed(
          response.statusCode == 200
              ? WeatherFailure.malformed
              : WeatherFailure.unavailable,
          'HTTP ${response.statusCode}',
        );
      }
      if (response.statusCode != 200 &&
          !(body is Map && body['error'] == true)) {
        return WeatherFetchFailed(
          WeatherFailure.unavailable,
          'HTTP ${response.statusCode}',
        );
      }
      return OpenMeteoForecastParser.parse(
        body,
        model: model,
        fetchedAtUtc: _clock.nowUtc(),
        latitude: latitude,
        longitude: longitude,
      );
    } catch (e) {
      return WeatherFetchFailed(WeatherFailure.unavailable, e.toString());
    }
  }
}
