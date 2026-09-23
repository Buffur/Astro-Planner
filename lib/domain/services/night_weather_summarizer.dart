import '../models/night_timeline.dart';
import '../models/night_weather_summary.dart';
import '../models/weather_snapshot.dart';

/// Builds the chosen night's weather summary (ADR-012 §3–§5; TASK 9.4). Pure
/// and deterministic: UTC instants in, UTC instants out.
abstract final class NightWeatherSummarizer {
  static const Duration _hour = Duration(hours: 1);

  /// The interval the summary covers: sunset to sunrise (owner decision,
  /// TASK 9.4), from the timeline's h = −0.833° result. A window edge
  /// stands in for a sunset or sunrise outside the window; midnight sun and
  /// polar night cover the whole window.
  static ({DateTime fromUtc, DateTime toUtc, NightWeatherSpan span}) spanOf(
    NightTimeline timeline,
  ) {
    final night = timeline.night;
    final whole = (fromUtc: night.startUtc, toUtc: night.endUtc);
    return switch (timeline.sunriseSunset) {
      SunNeverBelow() => (
        fromUtc: whole.fromUtc,
        toUtc: whole.toUtc,
        span: NightWeatherSpan.midnightSun,
      ),
      SunAlwaysBelow() => (
        fromUtc: whole.fromUtc,
        toUtc: whole.toUtc,
        span: NightWeatherSpan.polarNight,
      ),
      SunCrossing(:final duskUtc, :final dawnUtc) => () {
        final from = duskUtc ?? night.startUtc;
        final to = dawnUtc ?? night.endUtc;
        // A sunrise before the sunset (the Sun down at both edges of the
        // window, up in between) has no single night: show the window.
        if (!to.isAfter(from)) {
          return (
            fromUtc: whole.fromUtc,
            toUtc: whole.toUtc,
            span: NightWeatherSpan.sunsetToSunrise,
          );
        }
        return (
          fromUtc: from,
          toUtc: to,
          span: NightWeatherSpan.sunsetToSunrise,
        );
      }(),
    };
  }

  /// One slot per hour overlapping `[fromUtc, toUtc)`, matched to the
  /// snapshot's hour at the same UTC instant ("no forecast" otherwise), and
  /// the per-variable ranges over the covered hours. A dew spread
  /// (temperature − dew point) at or below [dewMarginC] °C is flagged as a
  /// dew risk — a heuristic (CALC-32), unknown when either value is missing.
  static NightWeatherSummary summarize(
    WeatherSnapshot snapshot, {
    required DateTime fromUtc,
    required DateTime toUtc,
    required double dewMarginC,
    NightWeatherSpan span = NightWeatherSpan.sunsetToSunrise,
  }) {
    final from = fromUtc.toUtc();
    final to = toUtc.toUtc();
    final byTime = {
      for (final h in snapshot.hours)
        h.timeUtc.toUtc().millisecondsSinceEpoch: h,
    };

    final slots = <NightWeatherSlot>[];
    var t = DateTime.utc(from.year, from.month, from.day, from.hour);
    while (t.isBefore(to)) {
      final hour = byTime[t.millisecondsSinceEpoch];
      final temp = hour?.temperatureC;
      final dew = hour?.dewPointC;
      final spread = (temp != null && dew != null) ? temp - dew : null;
      slots.add(
        NightWeatherSlot(
          timeUtc: t,
          hour: hour,
          dewSpreadC: spread,
          dewRisk: spread == null ? null : spread <= dewMarginC,
        ),
      );
      t = t.add(_hour);
    }

    final hours = [
      for (final s in slots)
        if (s.hour != null) s.hour!,
    ];
    WeatherRange? range(double? Function(WeatherHour h) value) {
      double? lo;
      double? hi;
      for (final h in hours) {
        final v = value(h);
        if (v == null) continue;
        if (lo == null || v < lo) lo = v;
        if (hi == null || v > hi) hi = v;
      }
      return lo == null ? null : WeatherRange(lo, hi!);
    }

    double? lo;
    double? hi;
    for (final s in slots) {
      final v = s.dewSpreadC;
      if (v == null) continue;
      if (lo == null || v < lo) lo = v;
      if (hi == null || v > hi) hi = v;
    }

    return NightWeatherSummary(
      fromUtc: from,
      toUtc: to,
      span: span,
      slots: slots,
      dewMarginC: dewMarginC,
      cloudCover: range((h) => h.cloudCoverPct),
      cloudCoverLow: range((h) => h.cloudCoverLowPct),
      cloudCoverMid: range((h) => h.cloudCoverMidPct),
      cloudCoverHigh: range((h) => h.cloudCoverHighPct),
      precipitationProbability: range((h) => h.precipitationProbabilityPct),
      windSpeed: range((h) => h.windSpeedKmh),
      windGusts: range((h) => h.windGustsKmh),
      temperature: range((h) => h.temperatureC),
      dewPoint: range((h) => h.dewPointC),
      relativeHumidity: range((h) => h.relativeHumidityPct),
      visibility: range((h) => h.visibilityM),
      dewSpread: lo == null ? null : WeatherRange(lo, hi!),
    );
  }
}
