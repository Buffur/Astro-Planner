import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:astroplan/data/repositories/open_meteo_weather_repository.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('OpenMeteoWeatherRepository', () {
    test('returns WeatherConditions with hourly forecast on 200 OK', () async {
      final mockClient = MockClient((request) async {
        return http.Response(
          '{"current": {"temperature_2m": 15.0, "relative_humidity_2m": 65.5, "dew_point_2m": 8.0, "cloud_cover": 20.0}, "hourly": {"time": ["2023-01-01T00:00"], "temperature_2m": [14.0], "relative_humidity_2m": [70.0], "dew_point_2m": [7.0], "cloud_cover": [30.0], "precipitation_probability": [0.0]}}',
          200,
        );
      });

      final repository = OpenMeteoWeatherRepository(client: mockClient);
      final weather = await repository.getCurrentWeather(51.5, -0.1);

      expect(weather, isNotNull);
      expect(weather!.temperature, 15.0);
      expect(weather.hourlyForecasts.length, 1);
      expect(weather.hourlyForecasts.first.temperature, 14.0);
      
      // Verify caching occurred
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('weather_cache_51.50_-0.10'), isNotNull);
    });

    test('falls back to cache when network fails', () async {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('weather_cache_51.50_-0.10', '{"temperature": 10.0, "cloudCover": 50.0, "humidity": 80.0, "dewPoint": 5.0, "hourlyForecasts": [], "lastUpdated": "2023-01-01T00:00:00.000Z"}');

      final mockClient = MockClient((request) async {
        throw Exception('Offline');
      });

      final repository = OpenMeteoWeatherRepository(client: mockClient);
      final weather = await repository.getCurrentWeather(51.5, -0.1);

      expect(weather, isNotNull);
      expect(weather!.temperature, 10.0);
    });

    test('returns null when network fails and cache is empty', () async {
      final mockClient = MockClient((request) async {
        throw Exception('Offline');
      });

      final repository = OpenMeteoWeatherRepository(client: mockClient);
      final weather = await repository.getCurrentWeather(51.5, -0.1);

      expect(weather, isNull);
    });
  });
}
