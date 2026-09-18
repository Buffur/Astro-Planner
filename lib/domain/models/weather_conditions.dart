class HourlyForecast {
  final DateTime time;
  final double temperature;
  final double cloudCover;
  final double dewPoint;
  final double humidity;
  final double precipitationProbability;
  final double windSpeed;
  final bool isDaytime;

  const HourlyForecast({
    required this.time,
    required this.temperature,
    required this.cloudCover,
    required this.dewPoint,
    required this.humidity,
    this.precipitationProbability = 0.0,
    this.windSpeed = 0.0,
    this.isDaytime = false,
  });

  factory HourlyForecast.fromJson(Map<String, dynamic> json) {
    return HourlyForecast(
      time: DateTime.parse(json['time'] as String),
      temperature: (json['temperature'] as num).toDouble(),
      cloudCover: (json['cloudCover'] as num).toDouble(),
      dewPoint: (json['dewPoint'] as num).toDouble(),
      humidity: (json['humidity'] as num).toDouble(),
      precipitationProbability: (json['precipitationProbability'] as num?)?.toDouble() ?? 0.0,
      windSpeed: (json['windSpeed'] as num?)?.toDouble() ?? 0.0,
      isDaytime: json['isDaytime'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
    'time': time.toIso8601String(),
    'temperature': temperature,
    'cloudCover': cloudCover,
    'dewPoint': dewPoint,
    'humidity': humidity,
    'precipitationProbability': precipitationProbability,
    'windSpeed': windSpeed,
    'isDaytime': isDaytime,
  };
}

class WeatherConditions {
  final double temperature;
  final double cloudCover;
  final double humidity;
  final double dewPoint;
  final double windSpeed;
  final List<HourlyForecast> hourlyForecasts;
  final DateTime? lastUpdated;

  const WeatherConditions({
    required this.temperature,
    required this.cloudCover,
    required this.humidity,
    required this.dewPoint,
    this.windSpeed = 0.0,
    this.hourlyForecasts = const [],
    this.lastUpdated,
  });

  factory WeatherConditions.fromJson(Map<String, dynamic> json) {
    return WeatherConditions(
      temperature: (json['temperature'] as num).toDouble(),
      cloudCover: (json['cloudCover'] as num).toDouble(),
      humidity: (json['humidity'] as num).toDouble(),
      dewPoint: (json['dewPoint'] as num).toDouble(),
      windSpeed: (json['windSpeed'] as num?)?.toDouble() ?? 0.0,
      hourlyForecasts: (json['hourlyForecasts'] as List<dynamic>?)
              ?.map((e) => HourlyForecast.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      lastUpdated: json['lastUpdated'] != null
          ? DateTime.parse(json['lastUpdated'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'temperature': temperature,
    'cloudCover': cloudCover,
    'humidity': humidity,
    'dewPoint': dewPoint,
    'windSpeed': windSpeed,
    'hourlyForecasts': hourlyForecasts.map((e) => e.toJson()).toList(),
    'lastUpdated': lastUpdated?.toIso8601String(),
  };
}
