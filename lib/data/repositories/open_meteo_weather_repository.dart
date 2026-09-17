import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../domain/models/weather_conditions.dart';
import '../../domain/repositories/weather_repository.dart';

class OpenMeteoWeatherRepository implements WeatherRepository {
  @override
  Future<WeatherConditions?> getCurrentWeather(double latitude, double longitude) async {
    try {
      final uri = Uri.parse(
        'https://api.open-meteo.com/v1/forecast?latitude=$latitude&longitude=$longitude&current=temperature_2m,relative_humidity_2m,dew_point_2m,cloud_cover',
      );
      final response = await http.get(uri).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final current = data['current'];
        if (current != null) {
          return WeatherConditions(
            temperature: (current['temperature_2m'] as num).toDouble(),
            humidity: (current['relative_humidity_2m'] as num).toDouble(),
            dewPoint: (current['dew_point_2m'] as num).toDouble(),
            cloudCover: (current['cloud_cover'] as num).toDouble(),
          );
        }
      }
      return null;
    } catch (e) {
      // In an offline or failing network state, simply return null
      // rather than crashing the MVP planner.
      return null;
    }
  }
}
