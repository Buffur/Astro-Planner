import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../domain/models/night_weather.dart';
import '../../domain/models/night_weather_summary.dart';
import '../../domain/models/weather_snapshot.dart';
import '../shared/night_time_formatter.dart';
import '../viewmodels/site_viewmodel.dart';
import '../viewmodels/session_plan_viewmodel.dart';
import '../viewmodels/night_conditions_viewmodel.dart';
import '../../core/theme/app_palette.dart';
import '../shared/night_text.dart';

/// The chosen night's weather (ADR-012; TASK 9.4): sunset to sunrise only,
/// per-hour indicators and per-variable ranges with explicit units, the
/// forecast's age and model, and no score or good/bad colouring. Hours
/// without a forecast say so; they are never shown as zero.
class WeatherForecastWidget extends StatelessWidget {
  final VoidCallback? onTap;

  const WeatherForecastWidget({super.key, this.onTap});

  @override
  Widget build(BuildContext context) {
    final conditionsVm = context.watch<NightConditionsViewModel>();
    final planVm = context.watch<SessionPlanViewModel>();
    final siteVm = context.watch<SiteViewModel>();
    final theme = Theme.of(context);
    final state = conditionsVm.nightWeather;
    final small = theme.textTheme.bodySmall?.copyWith(
      color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.75),
    );

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          InkWell(
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 8, 8),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Night weather',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          siteVm.locationName ?? 'Tap to set location',
                          style: small,
                          overflow: TextOverflow.ellipsis,
                        ),
                        // Required with a place name (TASK 7.2).
                        if (siteVm.locationName != null &&
                            siteVm.locationNameAttribution != null)
                          Text(
                            'Place name ${siteVm.locationNameAttribution}',
                            style: small,
                            overflow: TextOverflow.ellipsis,
                          ),
                      ],
                    ),
                  ),
                  IconButton(
                    key: const Key('weather.refresh'),
                    tooltip: 'Refresh forecast',
                    icon: const Icon(Icons.refresh),
                    onPressed: state is NightWeatherLoading
                        ? null
                        : () => conditionsVm.refreshWeather(),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: switch (state) {
              NightWeatherIdle() => const Text(
                "Set a site to see the night's forecast.",
              ),
              NightWeatherLoading() => const Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  LinearProgressIndicator(),
                  SizedBox(height: 8),
                  Text("Loading the night's forecast…"),
                ],
              ),
              NightWeatherOutOfRange() => const Text(
                'No forecast yet: this night is beyond the forecast '
                'horizon (16 days). Planning works without weather.',
                key: Key('weather.outOfRange'),
              ),
              NightWeatherUnavailable(:final failure) => Row(
                key: const Key('weather.unavailable'),
                children: [
                  Icon(Icons.cloud_off, color: AppPalette.of(context).muted),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("Couldn't load weather."),
                        Text(WeatherText.failure(failure), style: small),
                      ],
                    ),
                  ),
                  TextButton(
                    onPressed: () => conditionsVm.refreshWeather(),
                    child: const Text('Retry'),
                  ),
                ],
              ),
              NightWeatherAvailable() => _AvailableBody(
                state: state,
                summary: conditionsVm.nightWeatherSummary,
                zoneId: siteVm.displayZoneId,
                windowStartUtc: planVm.sessionNight?.startUtc,
              ),
            },
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: InkWell(
              onTap: () => launchUrl(
                Uri.parse('https://open-meteo.com/'),
                mode: LaunchMode.externalApplication,
              ),
              // TASK 15.3: a 48 px tap target.
              child: ConstrainedBox(
                constraints: const BoxConstraints(minHeight: 48),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Weather data by Open-Meteo.com (CC BY 4.0)',
                    key: const Key('weather.attribution'),
                    style: small?.copyWith(
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AvailableBody extends StatelessWidget {
  const _AvailableBody({
    required this.state,
    required this.summary,
    required this.zoneId,
    required this.windowStartUtc,
  });

  final NightWeatherAvailable state;
  final NightWeatherSummary? summary;
  final String? zoneId;
  final DateTime? windowStartUtc;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final small = theme.textTheme.bodySmall;
    final s = summary;
    final start = windowStartUtc;
    final snapshot = state.snapshot;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _FreshnessLine(state: state),
        Text('Model: ${snapshot.provider} / ${snapshot.model}', style: small),
        if (s != null && start != null) ...[
          const SizedBox(height: 8),
          Text(
            _spanText(context, s, start),
            key: const Key('weather.span'),
            style: theme.textTheme.bodyMedium,
          ),
          Text(
            'Times in ${NightTimeFormatter.zoneCaption(s.fromUtc, zoneId: zoneId)}',
            style: small,
          ),
          const SizedBox(height: 8),
          if (s.coveredHours == 0)
            const Text(
              'No forecast for these hours.',
              key: Key('weather.noCoverage'),
            )
          else ...[
            if (s.coveredHours < s.totalHours)
              Text(
                'Forecast for ${s.coveredHours} of ${s.totalHours} hours; '
                'the rest have no forecast.',
                key: const Key('weather.partial'),
                style: small,
              ),
            _Ranges(summary: s),
            const SizedBox(height: 8),
            _DewLine(summary: s),
          ],
          const SizedBox(height: 8),
          _HourStrip(summary: s, zoneId: zoneId),
        ],
      ],
    );
  }

  String _spanText(
    BuildContext context,
    NightWeatherSummary s,
    DateTime start,
  ) {
    String at(DateTime t) => NightTimeFormatter.instant(
      context,
      t,
      windowStartUtc: start,
      zoneId: zoneId,
    );
    return switch (s.span) {
      NightWeatherSpan.sunsetToSunrise =>
        'Sunset to sunrise: ${at(s.fromUtc)} – ${at(s.toUtc)}',
      NightWeatherSpan.midnightSun =>
        'The Sun does not set this night; the whole 24 h window is shown: '
            '${at(s.fromUtc)} – ${at(s.toUtc)}',
      NightWeatherSpan.polarNight =>
        'The Sun does not rise this night; the whole 24 h window is shown: '
            '${at(s.fromUtc)} – ${at(s.toUtc)}',
    };
  }
}

class _FreshnessLine extends StatelessWidget {
  const _FreshnessLine({required this.state});

  final NightWeatherAvailable state;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final text = WeatherText.freshness(state);
    final failed = state.refreshFailed;
    final prefix = failed == null
        ? ''
        : failed == WeatherFailure.unavailable
        ? 'Offline, showing the cached forecast. '
        : 'Refresh failed, showing the cached forecast. ';
    final warn = failed != null || state.age != WeatherAge.current;
    return Row(
      key: const Key('weather.freshness'),
      children: [
        if (warn) ...[
          Icon(Icons.history, size: 16, color: theme.colorScheme.error),
          const SizedBox(width: 4),
        ],
        Expanded(
          child: Text(
            '$prefix$text',
            style: theme.textTheme.bodySmall?.copyWith(
              color: warn ? theme.colorScheme.error : null,
              fontWeight: warn ? FontWeight.bold : null,
            ),
          ),
        ),
      ],
    );
  }
}

WeatherRange? _km(WeatherRange? m) =>
    m == null ? null : WeatherRange(m.min / 1000, m.max / 1000);

class _Ranges extends StatelessWidget {
  const _Ranges({required this.summary});

  final NightWeatherSummary summary;

  @override
  Widget build(BuildContext context) {
    final s = summary;
    final rows = <(String, String)>[
      ('Cloud cover (total)', WeatherText.range(s.cloudCover, '%')),
      ('Low cloud (below 3 km)', WeatherText.range(s.cloudCoverLow, '%')),
      ('Mid cloud (3–8 km)', WeatherText.range(s.cloudCoverMid, '%')),
      ('High cloud (above 8 km)', WeatherText.range(s.cloudCoverHigh, '%')),
      (
        'Chance of precipitation',
        WeatherText.range(s.precipitationProbability, '%'),
      ),
      ('Wind at 10 m', WeatherText.range(s.windSpeed, 'km/h')),
      ('Gusts (max of preceding hour)', WeatherText.range(s.windGusts, 'km/h')),
      ('Temperature', WeatherText.range(s.temperature, '°C')),
      ('Dew point', WeatherText.range(s.dewPoint, '°C')),
      ('Relative humidity', WeatherText.range(s.relativeHumidity, '%')),
      (
        'Horizontal visibility (not transparency)',
        WeatherText.range(_km(s.visibility), 'km', digits: 1),
      ),
    ];
    final style = Theme.of(context).textTheme.bodySmall;
    return Column(
      key: const Key('weather.ranges'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('Night ranges', style: Theme.of(context).textTheme.labelLarge),
        for (final (label, value) in rows)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 1),
            child: Row(
              children: [
                Expanded(child: Text(label, style: style)),
                Text(
                  value,
                  style: style?.copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _DewLine extends StatelessWidget {
  const _DewLine({required this.summary});

  final NightWeatherSummary summary;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final s = summary;
    final margin = s.dewMarginC.toStringAsFixed(1);
    final String text;
    if (s.dewKnownHours == 0) {
      text = 'Dew risk: unknown (no temperature or dew point).';
    } else if (s.dewRiskHours == 0) {
      text =
          'Dew risk (heuristic): none of ${s.dewKnownHours} hours has a '
          'temperature − dew point spread at or below $margin °C.';
    } else {
      text =
          'Dew risk (heuristic): ${s.dewRiskHours} of ${s.dewKnownHours} '
          'hours have a temperature − dew point spread at or below '
          '$margin °C (the margin in Settings).';
    }
    final risk = s.dewRiskHours > 0;
    return Row(
      key: const Key('weather.dew'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          risk ? Icons.warning_amber_rounded : Icons.water_drop_outlined,
          size: 16,
          color: risk ? theme.colorScheme.error : null,
        ),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            text,
            style: theme.textTheme.bodySmall?.copyWith(
              color: risk ? theme.colorScheme.error : null,
            ),
          ),
        ),
      ],
    );
  }
}

/// One column per hour; a legend column first gives each row's unit.
class _HourStrip extends StatelessWidget {
  const _HourStrip({required this.summary, required this.zoneId});

  final NightWeatherSummary summary;
  final String? zoneId;

  static const _rows = <(IconData, String)>[
    (Icons.cloud, 'cloud %'),
    (Icons.water_drop_outlined, 'precip. %'),
    (Icons.air, 'wind km/h'),
    (Icons.thermostat, 'temp. °C'),
    (Icons.opacity, 'T − Td °C'),
  ];

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context).textTheme.bodySmall;
    final slots = summary.slots;
    return SizedBox(
      height: 130,
      child: ListView.builder(
        key: const Key('weather.hours'),
        scrollDirection: Axis.horizontal,
        itemCount: slots.length + 1,
        itemBuilder: (context, index) {
          if (index == 0) {
            return SizedBox(
              width: 84,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Text('Hour', style: style),
                  for (final (icon, label) in _rows)
                    Row(
                      children: [
                        Icon(icon, size: 12),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            label,
                            style: style,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            );
          }
          return _HourColumn(
            slot: slots[index - 1],
            zoneId: zoneId,
            style: style,
          );
        },
      ),
    );
  }
}

class _HourColumn extends StatelessWidget {
  const _HourColumn({
    required this.slot,
    required this.zoneId,
    required this.style,
  });

  final NightWeatherSlot slot;
  final String? zoneId;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final h = slot.hour;
    String v(double? x, {int digits = 0}) =>
        x == null ? '—' : x.toStringAsFixed(digits);
    final time = Text(
      NightTimeFormatter.clockTime(context, slot.timeUtc, zoneId: zoneId),
      style: style?.copyWith(fontWeight: FontWeight.bold),
    );
    return SizedBox(
      width: 56,
      child: h == null
          ? Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                time,
                Text(
                  'no\nforecast',
                  textAlign: TextAlign.center,
                  style: style?.copyWith(fontStyle: FontStyle.italic),
                ),
              ],
            )
          : Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                time,
                Text(v(h.cloudCoverPct), style: style),
                Text(v(h.precipitationProbabilityPct), style: style),
                Text(v(h.windSpeedKmh), style: style),
                Text(v(h.temperatureC), style: style),
                Text(
                  v(slot.dewSpreadC, digits: 1),
                  style: slot.dewRisk == true
                      ? style?.copyWith(
                          color: theme.colorScheme.error,
                          fontWeight: FontWeight.bold,
                        )
                      : style,
                ),
              ],
            ),
    );
  }
}
