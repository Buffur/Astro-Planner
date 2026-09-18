import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../domain/models/weather_conditions.dart';
import '../../presentation/viewmodels/planner_viewmodel.dart';

class WeatherForecastWidget extends StatelessWidget {
  final WeatherConditions weather;
  final VoidCallback? onTap;

  const WeatherForecastWidget({super.key, required this.weather, this.onTap});

  @override
  Widget build(BuildContext context) {
    if (weather.hourlyForecasts.isEmpty) {
      return Card(
        margin: const EdgeInsets.only(bottom: 16),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: const Padding(
            padding: EdgeInsets.all(16),
            child: Text('No hourly forecast available. Tap to change location.'),
          ),
        ),
      );
    }

    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header with tap area
          InkWell(
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Weather & Conditions',
                              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                            ),
                            Builder(builder: (ctx) {
                              final name = ctx.watch<PlannerViewModel>().locationName;
                              final updateStr = weather.lastUpdated != null ? ' • Updated: ${_formatTime(weather.lastUpdated!)}' : '';
                              return Text(
                                name != null ? '$name$updateStr' : 'Tap to set location$updateStr',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.75),
                                ),
                                overflow: TextOverflow.ellipsis,
                              );
                            }),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.refresh),
                        onPressed: () {
                          context.read<PlannerViewModel>().refreshWeather();
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Current Summary
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _SummaryItem(icon: Icons.thermostat, value: '${weather.temperature.toInt()}°C', label: 'Temp', color: Colors.blue.shade700),
                      _SummaryItem(icon: Icons.cloud, value: '${weather.cloudCover.toInt()}%', label: 'Cloud', color: _getCloudColor(weather.cloudCover)),
                      _SummaryItem(icon: Icons.air, value: '${weather.windSpeed.toInt()} km/h', label: 'Wind', color: Colors.teal),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const Divider(height: 1),
          // Hourly Forecast
          SizedBox(
            height: 165, // Increased for day label
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: weather.hourlyForecasts.length,
              itemBuilder: (context, index) {
                final forecast = weather.hourlyForecasts[index];
                return _buildHourColumn(context, index, forecast);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHourColumn(BuildContext context, int index, HourlyForecast forecast) {
    final theme = Theme.of(context);
    final isNight = !forecast.isDaytime;

    return Container(
      width: 60,
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: isNight ? (theme.brightness == Brightness.dark ? Colors.black26 : Colors.indigo.shade50.withValues(alpha: 0.3)) : null,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Text(
            _getWeekday(forecast.time.weekday),
            style: theme.textTheme.labelSmall?.copyWith(
              color: isNight 
                  ? (theme.brightness == Brightness.dark ? Colors.white70 : Colors.indigo.shade400) 
                  : theme.colorScheme.primary.withValues(alpha: 0.8),
              fontWeight: FontWeight.bold,
              fontSize: 10,
            ),
          ),
          Text(
            _formatTime(forecast.time), 
            style: theme.textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: isNight ? (theme.brightness == Brightness.dark ? Colors.white : Colors.indigo.shade900) : null,
            )
          ),
          const SizedBox(height: 4),
          _IconMetric(icon: Icons.cloud, value: '${forecast.cloudCover.toInt()}%', color: _getCloudColor(forecast.cloudCover)),
          _IconMetric(icon: Icons.thermostat, value: '${forecast.temperature.toInt()}°', color: Colors.blue.shade700),
          _IconMetric(icon: Icons.water_drop_outlined, value: '${forecast.precipitationProbability.toInt()}%', color: Colors.blue),
          _IconMetric(icon: Icons.opacity, value: '${forecast.humidity.toInt()}%', color: Colors.blueGrey),
          _IconMetric(icon: Icons.air, value: '${forecast.windSpeed.toInt()}', color: Colors.teal),
        ],
      ),
    );
  }

  Color _getCloudColor(double cloudCover) {
    if (cloudCover <= 20) return Colors.green;
    if (cloudCover <= 50) return Colors.orange;
    return Colors.red;
  }

  String _formatTime(DateTime time) {
    final h = time.hour.toString().padLeft(2, '0');
    final m = time.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  String _getWeekday(int weekday) {
    switch (weekday) {
      case 1: return 'Mon';
      case 2: return 'Tue';
      case 3: return 'Wed';
      case 4: return 'Thu';
      case 5: return 'Fri';
      case 6: return 'Sat';
      case 7: return 'Sun';
      default: return '';
    }
  }
}

class _SummaryItem extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;

  const _SummaryItem({required this.icon, required this.value, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: color, size: 28),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}

class _IconMetric extends StatelessWidget {
  final IconData icon;
  final String value;
  final Color color;

  const _IconMetric({required this.icon, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            value,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(fontSize: 11),
          ),
        ],
      ),
    );
  }
}
