import 'package:flutter/material.dart';

import '../../domain/models/moon_conditions.dart';
import '../../domain/models/night_weather.dart';
import '../../domain/models/night_weather_summary.dart';
import '../../domain/models/weather_snapshot.dart';
import '../../domain/services/fit_analyzer.dart';

/// Wording shared by Tonight and the planner (TASK 12.5; moved out of the
/// weather, sky and budget widgets so both say the same thing). Formatting
/// only — every value comes from the domain.
abstract final class WeatherText {
  /// "just now", "25 min ago", "3 h ago".
  static String ago(Duration d) {
    if (d.inMinutes < 1) return 'just now';
    if (d.inMinutes < 60) return '${d.inMinutes} min ago';
    return '${d.inHours} h ago';
  }

  /// "Updated 25 min ago", or the aging/stale wording (ADR-012 §6).
  static String freshness(NightWeatherAvailable state) {
    final ago = WeatherText.ago(state.ageDuration);
    return switch (state.age) {
      WeatherAge.current => 'Updated $ago',
      WeatherAge.aging => 'Aging forecast: updated $ago',
      WeatherAge.stale => 'Stale forecast: updated $ago. Refresh to update.',
    };
  }

  /// "10–40 %", "20 %", or "no forecast" — never 0 for unknown (SI-008).
  static String range(WeatherRange? r, String unit, {int digits = 0}) {
    if (r == null) return 'no forecast';
    final lo = r.min.toStringAsFixed(digits);
    final hi = r.max.toStringAsFixed(digits);
    return lo == hi ? '$lo $unit' : '$lo–$hi $unit';
  }

  static String failure(WeatherFailure failure) => switch (failure) {
    WeatherFailure.unavailable => 'Offline or the service did not answer.',
    WeatherFailure.malformed => 'The forecast could not be read.',
    WeatherFailure.outOfRange => 'Beyond the forecast horizon.',
  };
}

abstract final class MoonText {
  /// When the Moon is up this night; [at] formats an instant.
  static String up(MoonConditions c, String Function(DateTime utc) at) {
    if (c.riseSet.alwaysAbove) return 'Moon up all night.';
    if (c.riseSet.alwaysBelow) return 'Moon below the horizon all night.';
    final spans = c.upIntervals.map(
      (i) =>
          '${i.$1 == c.night.startUtc ? 'from noon' : at(i.$1)}–'
          '${i.$2 == c.night.endUtc ? 'noon' : at(i.$2)}',
    );
    return 'Moon up ${spans.join(', ')}.';
  }
}

abstract final class FitText {
  static String label(FitState state) => switch (state) {
    FitState.fits => 'Fits',
    FitState.tight => 'Tight',
    FitState.doesNotFit => "Doesn't fit",
    FitState.noWindow => 'No window',
    FitState.nothingToFit => 'Nothing to fit',
  };

  static Color color(FitState state, ColorScheme scheme) => switch (state) {
    FitState.fits => scheme.primary,
    FitState.tight => scheme.tertiary,
    FitState.doesNotFit || FitState.noWindow => scheme.error,
    FitState.nothingToFit => scheme.outline,
  };
}
