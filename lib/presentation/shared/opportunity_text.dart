import '../../domain/models/imaging_opportunity.dart';
import '../../domain/models/night_weather.dart';
import '../../core/utils/quantity_text.dart';

/// Wording for an [ImagingOpportunity] (ADR-013; TASK 10.3): windows,
/// annotations and the reasons for excluded time. Facts only — no verdicts,
/// no score. Times are formatted by the caller (NightTimeFormatter).
abstract final class OpportunityText {
  /// "5 h 35 min", "45 min", "0 min" — the app's one duration form
  /// ([QuantityText.duration], S1.7).
  static String duration(Duration d) => QuantityText.duration(d);

  static String _deg(double v) => '${v.round()}°';

  /// One gate's reason, for example "Sun above −18°".
  static String reason(
    OpportunityGate gate,
    ImagingOpportunity o,
  ) => switch (gate) {
    OpportunityGate.darkness => 'Sun above ${_signed(o.darknessLimitDeg)}',
    OpportunityGate.altitude => 'target below ${_deg(o.minAltitudeDeg)}',
    OpportunityGate.moon =>
      'Moon up and at least '
          '${o.gates.moonMinIlluminationPct?.round()} % lit (your Moon gate)',
    OpportunityGate.cloud =>
      'cloud above ${o.gates.cloudMaxPct?.round()} % (your cloud gate)',
  };

  /// Every failing gate of an excluded segment, in a fixed order.
  static String reasons(ExcludedSegment s, ImagingOpportunity o) => [
    for (final g in OpportunityGate.values)
      if (s.reasons.contains(g)) reason(g, o),
  ].join('; ');

  static String _signed(double v) =>
      v < 0 ? '−${(-v).round()}°' : '${v.round()}°';

  /// Why there is no window tonight (ADR-013 §4).
  static String noWindow(NoWindowReason r, ImagingOpportunity o) =>
      'No imaging window: ${noWindowShort(r, darknessLimitDeg: o.darknessLimitDeg, minAltitudeDeg: o.minAltitudeDeg)}';

  /// The reason alone, for a list row (TASK 10.4), for example "the Sun
  /// never gets below −18° tonight."
  static String noWindowShort(
    NoWindowReason r, {
    required double darknessLimitDeg,
    required double minAltitudeDeg,
  }) => switch (r) {
    NoWindowReason.noDarkness =>
      'the Sun never gets below ${_signed(darknessLimitDeg)} tonight.',
    NoWindowReason.targetNeverHighEnough =>
      'the target never rises above ${_deg(minAltitudeDeg)} tonight.',
    NoWindowReason.targetNeverHighEnoughInDarkness =>
      'the target is above ${_deg(minAltitudeDeg)} only while the Sun is '
          'above ${_signed(darknessLimitDeg)}.',
    NoWindowReason.excludedByOptionalGates =>
      "your Moon or cloud gate excludes all of tonight's dark time with the "
          'target high enough.',
  };

  /// "max 55° at 01:20" — [at] is the formatted instant.
  static String maxAltitude(OpportunityWindow w, String at) =>
      'max ${_deg(w.maxAltitudeDeg)} at $at';

  /// The Moon during a window; null when no Moon data was supplied.
  static String? moon(OpportunityWindow w) {
    final m = w.moon;
    if (m == null) return null;
    final lit = '${(m.illumination * 100).round()} % lit';
    if (m.moonDown) return 'Moon down ($lit)';
    final sep = m.minSeparationDeg;
    return 'Moon up ${duration(m.upDuration)} of it, $lit'
        '${sep == null ? '' : ', at least ${_deg(sep)} from the target'}';
  }

  /// The forecast during a window; null when no forecast was supplied.
  static String? weather(OpportunityWindow w) {
    final x = w.weather;
    if (x == null) return null;
    final parts = <String>[];
    final lo = x.cloudMinPct;
    final hi = x.cloudMaxPct;
    if (lo == null || hi == null) {
      parts.add('no cloud forecast');
    } else {
      parts.add(
        lo.round() == hi.round()
            ? 'cloud ${lo.round()} %'
            : 'cloud ${lo.round()}–${hi.round()} %',
      );
      if (x.hoursWithoutForecast > 0) {
        parts.add('${x.hoursWithoutForecast} h without forecast');
      }
    }
    if (x.dewKnownHours > 0) {
      parts.add(
        x.dewRiskHours == 0
            ? 'no dew risk (heuristic)'
            : 'dew risk ${x.dewRiskHours} h (heuristic)',
      );
    }
    final age = switch (x.age) {
      WeatherAge.current => null,
      WeatherAge.aging => 'aging forecast',
      WeatherAge.stale => 'stale forecast',
    };
    if (age != null) parts.add(age);
    return parts.join(', ');
  }
}
