import 'package:flutter/material.dart';

import '../../core/theme/app_palette.dart';
import '../../core/utils/quantity_text.dart';

import '../../domain/models/moon_conditions.dart';
import '../../domain/models/night_weather.dart';
import '../../domain/models/night_timeline.dart';
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

  /// One line for a summary row (S6.5): the night's cloud range with the
  /// forecast's age (and its aging or stale wording), or why there is no
  /// forecast. Never a score or a good/bad word (ADR-012).
  static String summary(NightWeather state, NightWeatherSummary? s) =>
      switch (state) {
        NightWeatherIdle() => 'Set a site to see the forecast.',
        NightWeatherLoading() => 'Loading the forecast…',
        NightWeatherOutOfRange() =>
          'No forecast yet: this night is beyond the forecast horizon.',
        NightWeatherUnavailable(:final failure) =>
          'No forecast. ${WeatherText.failure(failure)}',
        NightWeatherAvailable() =>
          'Cloud ${range(s?.cloudCover, '%')} · ${freshness(state)}',
      };
}

/// The dark span at the user's darkness limit (S6.5, TD-051): the Sun below
/// the limit the imaging opportunity uses, labelled with it.
abstract final class DarkText {
  /// "Dark (Sun below −15°): 6:02 PM – 5:40 AM (+1)", or "…: not tonight",
  /// "…: all night"; [at] formats an instant.
  static String span(SunThresholdResult r, String Function(DateTime utc) at) {
    final label = 'Dark (Sun below ${QuantityText.degrees(r.thresholdDeg)})';
    return switch (r) {
      SunCrossing(:final duskUtc, :final dawnUtc) =>
        '$label: ${duskUtc == null ? 'from the start' : at(duskUtc)} – '
            '${dawnUtc == null ? 'the end' : at(dawnUtc)}',
      SunNeverBelow() => '$label: not tonight',
      SunAlwaysBelow() => '$label: all night',
    };
  }
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

  /// The useful fact for Tonight (S6.13; UX-17), worded as the imaging
  /// windows' Moon note: "Moon down while dark (3 % lit at midnight)",
  /// "Moon up all the dark time (…)", or "Moon up 2 h of the 7 h 30 min
  /// dark (…)". Null means there is no dark span to speak of.
  static String duringDark(MoonDuringDark m) {
    final lit = '${QuantityText.percent(m.illumination * 100)} lit at midnight';
    if (m.moonDown) return 'Moon down while dark ($lit)';
    if (m.upAllDark) return 'Moon up all the dark time ($lit)';
    return 'Moon up ${QuantityText.duration(m.moonUp)} of the '
        '${QuantityText.duration(m.dark)} dark ($lit)';
  }
}

abstract final class FitText {
  static String label(FitState state) => switch (state) {
    FitState.fits => 'Fits',
    FitState.tight => 'Tight',
    FitState.doesNotFit => "Doesn't fit",
    FitState.noWindow || FitState.needsInput => 'No window',
    FitState.nothingToFit => 'Nothing to fit',
  };

  /// A real verdict in its colour; a missing input neutral (S1.9; UX-16,
  /// UX-15(2)): "Tight" is a caution at least as prominent as "Fits". Since
  /// S5.4 the colours are the palette's status tokens (the same values as
  /// before: `scheme.primary`, `caution`, `scheme.error`, the secondary
  /// text); [scheme] is kept for the callers.
  static Color color(FitState state, ColorScheme scheme, AppPalette palette) =>
      switch (state) {
        FitState.fits => palette.statusFits,
        FitState.tight => palette.statusTight,
        FitState.doesNotFit => palette.statusDoesNotFit,
        FitState.noWindow => palette.statusNoWindow,
        FitState.nothingToFit || FitState.needsInput => palette.statusNeutral,
      };
}
