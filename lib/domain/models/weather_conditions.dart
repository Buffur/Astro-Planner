class WeatherConditions {
  final double temperature;
  final double cloudCover;
  final double humidity;
  final double dewPoint;

  const WeatherConditions({
    required this.temperature,
    required this.cloudCover,
    required this.humidity,
    required this.dewPoint,
  });

  bool get dewWarning => (temperature - dewPoint) <= 2.0;
}
