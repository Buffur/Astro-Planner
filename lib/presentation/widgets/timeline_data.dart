import '../../domain/models/imaging_opportunity.dart';
import '../shared/night_time_formatter.dart';

/// The state of the sky in one stretch of the night, at the user's
/// darkness limit (the same test as the opportunity's darkness gate).
enum SkyBand { day, twilight, dark }

/// A stretch of the night, [startUtc] to [endUtc].
class TimelineSpan {
  const TimelineSpan(this.startUtc, this.endUtc);

  final DateTime startUtc;
  final DateTime endUtc;

  @override
  bool operator ==(Object other) =>
      other is TimelineSpan &&
      other.startUtc == startUtc &&
      other.endUtc == endUtc;

  @override
  int get hashCode => Object.hash(startUtc, endUtc);
}

/// A stretch of one [SkyBand].
class TimelineBand extends TimelineSpan {
  const TimelineBand(this.kind, super.startUtc, super.endUtc);

  final SkyBand kind;
}

/// A whole hour on the time axis, in the zone the times are shown in.
class HourTick {
  const HourTick(this.instantUtc, this.localHour);

  final DateTime instantUtc;

  /// 0–23 on the wall clock of the site's zone (else the device's).
  final int localHour;
}

/// The one data mapping behind the night and opportunity timeline (S6.12;
/// P6.11): what the timeline draws, taken from the domain's results and
/// nothing else. The night state comes from the opportunity's own Sun
/// samples at the user's limit (CALC-41 agrees with them), merged into
/// bands, so there are no seams (UX-08); the windows are exactly the
/// opportunity's; the planned capture is shown only as far as the fit
/// exposes it: its end. No time is drawn continuous across a gap.
class TimelineData {
  const TimelineData._({
    required this.startUtc,
    required this.endUtc,
    required this.bands,
    required this.windows,
    required this.captureEndUtc,
    required this.nowUtc,
  });

  /// [captureEndUtc] is the fit's end (`FitResult.endUtc`), or null when
  /// the fit placed nothing or did not measure the plan; [nowUtc] is shown
  /// only inside the night.
  factory TimelineData.of(
    ImagingOpportunity o, {
    DateTime? captureEndUtc,
    DateTime? nowUtc,
  }) {
    final night = o.night;
    bool inside(DateTime? t) =>
        t != null && !t.isBefore(night.startUtc) && !t.isAfter(night.endUtc);
    return TimelineData._(
      startUtc: night.startUtc,
      endUtc: night.endUtc,
      bands: _bands(o),
      windows: [for (final w in o.windows) TimelineSpan(w.startUtc, w.endUtc)],
      captureEndUtc: inside(captureEndUtc) ? captureEndUtc : null,
      nowUtc: inside(nowUtc) ? nowUtc : null,
    );
  }

  final DateTime startUtc;
  final DateTime endUtc;

  /// Contiguous, in order, never two of the same kind side by side.
  final List<TimelineBand> bands;
  final List<TimelineSpan> windows;
  final DateTime? captureEndUtc;
  final DateTime? nowUtc;

  /// Where one band gives way to the next: drawn as a thin line, so the
  /// bands stay distinguishable in field mode too (UX-08).
  List<DateTime> get bandEdges => [for (final b in bands.skip(1)) b.startUtc];

  static SkyBand _kind(double sunDeg, double limitDeg) => sunDeg > 0
      ? SkyBand.day
      : sunDeg > limitDeg
      ? SkyBand.twilight
      : SkyBand.dark;

  /// Sample i stands for [t(i), t(i+1)); runs of one kind become one band.
  static List<TimelineBand> _bands(ImagingOpportunity o) {
    final s = o.samples;
    if (s.length < 2) return const [];
    final bands = <TimelineBand>[];
    var kind = _kind(s.first.sunAltitudeDeg, o.darknessLimitDeg);
    var start = s.first.instantUtc;
    for (var i = 1; i < s.length - 1; i++) {
      final k = _kind(s[i].sunAltitudeDeg, o.darknessLimitDeg);
      if (k == kind) continue;
      bands.add(TimelineBand(kind, start, s[i].instantUtc));
      kind = k;
      start = s[i].instantUtc;
    }
    bands.add(TimelineBand(kind, start, s.last.instantUtc));
    return bands;
  }

  /// Every whole hour between [fromUtc] and [toUtc] on the wall clock of
  /// [zoneId] (else the device's zone), as the other times on the page
  /// (UX-08: ticks on whole hours, not on the night's odd start). Found on
  /// a 15-minute UTC grid, so zones with half- or quarter-hour offsets and
  /// DST changes are handled; a repeated hour at a DST change appears twice.
  static List<HourTick> hourTicks(
    DateTime fromUtc,
    DateTime toUtc, {
    String? zoneId,
  }) {
    const step = Duration(minutes: 15);
    final ms = step.inMilliseconds;
    var t = DateTime.fromMillisecondsSinceEpoch(
      (fromUtc.millisecondsSinceEpoch + ms - 1) ~/ ms * ms,
      isUtc: true,
    );
    final ticks = <HourTick>[];
    while (!t.isAfter(toUtc)) {
      final local = NightTimeFormatter.wallClock(t, zoneId: zoneId);
      if (local.minute == 0) ticks.add(HourTick(t, local.hour));
      t = t.add(step);
    }
    return ticks;
  }
}
