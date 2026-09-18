import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/models/weather_conditions.dart';
import '../../domain/repositories/weather_repository.dart';

class OpenMeteoWeatherRepository implements WeatherRepository {
  final http.Client _client;

  OpenMeteoWeatherRepository({http.Client? client}) : _client = client ?? http.Client();

  @override
  Future<WeatherConditions?> getCurrentWeather(double latitude, double longitude, {bool forceRefresh = false}) async {
    final cacheKey = 'weather_cache_${latitude.toStringAsFixed(2)}_${longitude.toStringAsFixed(2)}';
    SharedPreferences? prefs;
    try {
      prefs = await SharedPreferences.getInstance();
    } catch (_) {}

    try {
      final uri = Uri.parse(
        'https://api.open-meteo.com/v1/forecast?latitude=$latitude&longitude=$longitude&current=temperature_2m,relative_humidity_2m,dew_point_2m,cloud_cover,wind_speed_10m,is_day&hourly=temperature_2m,relative_humidity_2m,dew_point_2m,cloud_cover,precipitation_probability,wind_speed_10m,is_day&timezone=auto&models=icon_seamless',
      );
      final response = await _client.get(uri).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final current = data['current'];
        final hourly = data['hourly'];
        
        if (current != null) {
          final List<HourlyForecast> forecasts = [];
          if (hourly != null) {
            final times = hourly['time'] as List<dynamic>?;
            final temps = hourly['temperature_2m'] as List<dynamic>?;
            final hums = hourly['relative_humidity_2m'] as List<dynamic>?;
            final dews = hourly['dew_point_2m'] as List<dynamic>?;
            final clouds = hourly['cloud_cover'] as List<dynamic>?;
            final precips = hourly['precipitation_probability'] as List<dynamic>?;
            final winds = hourly['wind_speed_10m'] as List<dynamic>?;
            final isDays = hourly['is_day'] as List<dynamic>?;

            if (times != null && temps != null && hums != null && dews != null && clouds != null && precips != null) {
              final limit = times.length < 48 ? times.length : 48; // Max 48 hours
              for (var i = 0; i < limit; i++) {
                forecasts.add(HourlyForecast(
                  time: DateTime.parse(times[i] as String),
                  temperature: (temps[i] as num).toDouble(),
                  humidity: (hums[i] as num).toDouble(),
                  dewPoint: (dews[i] as num).toDouble(),
                  cloudCover: (clouds[i] as num).toDouble(),
                  precipitationProbability: (precips[i] as num).toDouble(),
                  windSpeed: winds != null ? (winds[i] as num).toDouble() : 0.0,
                  isDaytime: isDays != null ? (isDays[i] as num).toInt() == 1 : false,
                ));
              }
            }
          }

          final conditions = WeatherConditions(
            temperature: (current['temperature_2m'] as num).toDouble(),
            humidity: (current['relative_humidity_2m'] as num).toDouble(),
            dewPoint: (current['dew_point_2m'] as num).toDouble(),
            cloudCover: (current['cloud_cover'] as num).toDouble(),
            windSpeed: current['wind_speed_10m'] != null ? (current['wind_speed_10m'] as num).toDouble() : 0.0,
            hourlyForecasts: forecasts,
            lastUpdated: DateTime.now(),
          );

          if (prefs != null) {
            await prefs.setString(cacheKey, json.encode(conditions.toJson()));
          }

          return conditions;
        }
      }
    } catch (e) {
      // Network failed or parsing error, fallback to cache
      if (forceRefresh) {
        // if user explicitly forced refresh and network fails, maybe we still fallback or throw? 
        // Let's fallback so it doesn't break entirely, but we could notify.
      }
    }

    // Network failed — always fall back to cache regardless of forceRefresh
    if (prefs != null) {
      final cachedJson = prefs.getString(cacheKey);
      if (cachedJson != null) {
        try {
          return WeatherConditions.fromJson(json.decode(cachedJson));
        } catch (_) {}
      }
    }

    return null;
  }
}
