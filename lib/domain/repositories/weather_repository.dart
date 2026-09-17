import '../models/weather_conditions.dart';

abstract class WeatherRepository {
  Future<WeatherConditions?> getCurrentWeather(double latitude, double longitude);
}
