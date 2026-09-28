import 'package:flutter/material.dart';

import '../../core/theme/app_palette.dart';

import '../shared/night_time_formatter.dart';
import '../shared/opportunity_text.dart';

import '../../domain/models/imaging_opportunity.dart';
import 'timeline_data.dart';

/// How much the timeline shows (S6.12): [full] in the planner (altitude
/// grid, Moon, legend); [compact] for a summary such as Tonight's (bands,
/// windows, the target, the time axis).
enum TimelineDensity { full, compact }

/// The night and opportunity timeline (TASK 10.3; evolved in S6.12, P6.11):
/// the night's state at the user's darkness limit, the target's altitude,
/// the imaging windows and, as far as the fit exposes it, when the planned
/// capture ends. The Moon and "now" appear only when the domain supplies
/// them. One primitive over one mapping ([TimelineData]) at two
/// [TimelineDensity]s.
///
/// Render-only (TD-023, DEV-A3): every value comes from the domain result —
/// the same object the window list renders — so chart and list cannot
/// disagree. Times follow the device's 12- or 24-hour setting and the zone
/// rule, on whole hours; labels sit outside the plot, never over a curve
/// (UX-08).
class AltitudeChartWidget extends StatelessWidget {
  final ImagingOpportunity opportunity;

  /// The Moon's altitude on the same grid, degrees; null when not known.
  final List<double>? moonAltitudesDeg;

  /// The site's IANA zone for the time axis, or null for the device zone
  /// (TASK 7.1).
  final String? zoneId;

  /// "Now", for the current-time marker; null draws none.
  final DateTime? nowUtc;

  /// When the planned capture ends (`FitResult.endUtc`); null draws none.
  final DateTime? captureEndUtc;

  final TimelineDensity density;

  const AltitudeChartWidget({
    super.key,
    required this.opportunity,
    this.moonAltitudesDeg,
    this.zoneId,
    this.nowUtc,
    this.captureEndUtc,
    this.density = TimelineDensity.full,
  });

  @override
  Widget build(BuildContext context) {
    final palette = AppPalette.of(context);
    final full = density == TimelineDensity.full;
    final data = TimelineData.of(
      opportunity,
      captureEndUtc: captureEndUtc,
      nowUtc: nowUtc,
    );
    final ticks = [
      for (final t in TimelineData.hourTicks(
        data.startUtc,
        data.endUtc,
        zoneId: zoneId,
      ))
        (
          t,
          NightTimeFormatter.clockTime(context, t.instantUtc, zoneId: zoneId),
        ),
    ];
    String at(DateTime t) => NightTimeFormatter.instant(
      context,
      t,
      windowStartUtc: opportunity.night.startUtc,
      zoneId: zoneId,
    );
    final style = Theme.of(context).textTheme.labelSmall!
        .copyWith(color: palette.textSecondary);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // TASK 15.3; S6.12: the text alternative names the windows, the
        // usable time and the capture's end; the list below has the rest.
        Semantics(
          key: const Key('chart.altitude'),
          label: describe(opportunity, data, at),
          excludeSemantics: true,
          child: SizedBox(
            height: full ? 200 : 88,
            width: double.infinity,
            child: CustomPaint(
              painter: TimelinePainter(
                data: data,
                opportunity: opportunity,
                moonAltitudesDeg: full ? moonAltitudesDeg : null,
                ticks: ticks,
                palette: palette,
                labelStyle: style,
                textScaler: MediaQuery.textScalerOf(context),
                density: density,
              ),
            ),
          ),
        ),
        if (full) ...[
          const SizedBox(height: 8),
          Wrap(
            spacing: 10,
            runSpacing: 4,
            children: [
              _swatch(context, 'Day', palette.chartDay),
              _swatch(context, 'Twilight', palette.chartTwilight),
              _swatch(
                context,
                'Dark (Sun ≤ ${_signed(opportunity.darknessLimitDeg)})',
                palette.chartDark,
              ),
              _swatch(context, 'Imaging window', palette.chartWindow),
              _line(context, 'Target', palette.chartTarget),
              if (moonAltitudesDeg != null)
                _line(context, 'Moon', palette.chartMoon),
              _line(
                context,
                'Min ${opportunity.minAltitudeDeg.round()}°',
                palette.chartMinAltitude,
              ),
              if (data.captureEndUtc != null)
                _line(context, 'Capture ends', palette.chartTarget),
            ],
          ),
        ],
      ],
    );
  }

  /// What the timeline shows, for screen readers (TASK 15.3; S6.12): the
  /// windows with their times, the usable time and the capture's end.
  static String describe(
    ImagingOpportunity o,
    TimelineData data,
    String Function(DateTime) at,
  ) {
    final n = o.windows.length;
    final windows = n == 0
        ? 'no imaging window'
        : '${n == 1 ? 'imaging window' : 'imaging windows'} '
              '${[for (final w in o.windows) '${at(w.startUtc)} – ${at(w.endUtc)} (${OpportunityText.duration(w.duration)})'].join(', ')}';
    final end = data.captureEndUtc;
    return "Chart of the target's altitude through the night: $windows; "
        'usable time ${OpportunityText.duration(o.usableTime)}'
        '${end == null ? '' : '; capture ends ${at(end)}'}. '
        'The windows are listed below the chart.';
  }

  static String _signed(double v) =>
      v < 0 ? '−${(-v).round()}°' : '${v.round()}°';

  Widget _swatch(BuildContext context, String label, Color color) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Container(
        width: 10,
        height: 10,
        decoration: BoxDecoration(
          color: color,
          border: Border.all(
            color: AppPalette.of(context).swatchBorder,
            width: 0.5,
          ),
        ),
      ),
      const SizedBox(width: 4),
      Flexible(
        child: Text(label, style: Theme.of(context).textTheme.labelSmall),
      ),
    ],
  );

  Widget _line(BuildContext context, String label, Color color) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Container(width: 12, height: 2, color: color),
      const SizedBox(width: 4),
      Flexible(
        child: Text(label, style: Theme.of(context).textTheme.labelSmall),
      ),
    ],
  );
}

/// Where the timeline's parts go in a given size (S6.12): the plot, and
/// the labels outside it. Public for tests (UX-08: no label over a curve;
/// time labels never overlap).
class TimelineGeometry {
  const TimelineGeometry({
    required this.plot,
    required this.altitudeLabels,
    required this.timeLabels,
    required this.hourStep,
  });

  final Rect plot;

  /// (label, where it is drawn), in the gutter left of the plot.
  final List<(String, Rect)> altitudeLabels;

  /// (tick index, where its label is drawn), below the plot.
  final List<(int, Rect)> timeLabels;

  /// Every how many hours a time is labelled (1, 2, 3, 4, 6 or 12).
  final int hourStep;
}

/// Paints the timeline from [TimelineData]; computes no astronomy.
class TimelinePainter extends CustomPainter {
  TimelinePainter({
    required this.data,
    required this.opportunity,
    required this.moonAltitudesDeg,
    required this.ticks,
    required this.palette,
    required this.labelStyle,
    required this.textScaler,
    required this.density,
  });

  final TimelineData data;
  final ImagingOpportunity opportunity;
  final List<double>? moonAltitudesDeg;
  final List<(HourTick, String)> ticks;
  final AppPalette palette;
  final TextStyle labelStyle;
  final TextScaler textScaler;
  final TimelineDensity density;

  static const _altitudes = [(0.0, '0°'), (30.0, '30°'), (60.0, '60°')];
  static const _gap = 8.0;

  TextPainter _text(String s) => TextPainter(
    text: TextSpan(text: s, style: labelStyle),
    textDirection: TextDirection.ltr,
    textScaler: textScaler,
  )..layout();

  /// Lays out the plot and its labels in [size].
  TimelineGeometry geometry(Size size) {
    final full = density == TimelineDensity.full;
    final sample = _text('0');
    final axis = sample.height + 4;
    final gutter = full
        ? _altitudes
                  .map((a) => _text(a.$2).width)
                  .reduce((a, b) => a > b ? a : b) +
              6
        : 0.0;
    final plot = Rect.fromLTRB(gutter, 0, size.width, size.height - axis);
    double y(double deg) => (plot.bottom - (deg + 10) / 100 * plot.height)
        .clamp(plot.top, plot.bottom);
    final altitudeLabels = <(String, Rect)>[];
    if (full) {
      for (final (deg, name) in _altitudes) {
        final t = _text(name);
        final top = (y(deg) - t.height / 2).clamp(0.0, plot.bottom - t.height);
        altitudeLabels.add((
          name,
          Rect.fromLTWH(gutter - 6 - t.width, top, t.width, t.height),
        ));
      }
    }
    // The fewest labels that do not touch: every 1, 2, 3, 4, 6 or 12 h.
    for (final step in const [1, 2, 3, 4, 6, 12]) {
      final rects = <(int, Rect)>[];
      var ok = true;
      for (final (i, (tick, label)) in ticks.indexed) {
        if (tick.localHour % step != 0) continue;
        final t = _text(label);
        final left = (xOf(tick.instantUtc, plot) - t.width / 2).clamp(
          plot.left,
          plot.right - t.width,
        );
        final r = Rect.fromLTWH(left, plot.bottom + 4, t.width, t.height);
        if (rects.isNotEmpty && r.left < rects.last.$2.right + _gap) {
          ok = false;
          break;
        }
        rects.add((i, r));
      }
      if (ok || step == 12) {
        return TimelineGeometry(
          plot: plot,
          altitudeLabels: altitudeLabels,
          timeLabels: rects,
          hourStep: step,
        );
      }
    }
    throw StateError('unreachable');
  }

  double xOf(DateTime t, Rect plot) {
    final span = data.endUtc.difference(data.startUtc).inMilliseconds;
    if (span <= 0) return plot.left;
    return plot.left +
        t.difference(data.startUtc).inMilliseconds / span * plot.width;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final samples = opportunity.samples;
    if (samples.length < 2) return;
    final g = geometry(size);
    final plot = g.plot;
    double yOf(double deg) => (plot.bottom - (deg + 10) / 100 * plot.height)
        .clamp(plot.top, plot.bottom);
    double x(DateTime t) => xOf(t, plot);

    // 1. The night's state, one rectangle per band (no seams).
    for (final b in data.bands) {
      canvas.drawRect(
        Rect.fromLTRB(x(b.startUtc), plot.top, x(b.endUtc), plot.bottom),
        Paint()
          ..color = switch (b.kind) {
            SkyBand.day => palette.chartDay,
            SkyBand.twilight => palette.chartTwilight,
            SkyBand.dark => palette.chartDark,
          },
      );
    }
    // 2. Imaging windows, each on its own: no time across a gap.
    for (final w in data.windows) {
      canvas.drawRect(
        Rect.fromLTRB(x(w.startUtc), plot.top, x(w.endUtc), plot.bottom),
        Paint()..color = palette.chartWindow,
      );
    }
    // 3. Band edges, so the bands stay apart in field mode (UX-08).
    final grid = Paint()
      ..color = palette.chartGrid
      ..strokeWidth = 1;
    for (final e in data.bandEdges) {
      canvas.drawLine(Offset(x(e), plot.top), Offset(x(e), plot.bottom), grid);
    }
    // 4. Altitude grid (full).
    if (density == TimelineDensity.full) {
      for (final (deg, _) in _altitudes) {
        final y = yOf(deg);
        canvas.drawLine(Offset(plot.left, y), Offset(plot.right, y), grid);
      }
    }
    // 5. Minimum altitude, dashed.
    final minY = yOf(opportunity.minAltitudeDeg);
    final dash = Paint()
      ..color = palette.chartMinAltitude
      ..strokeWidth = 1.5;
    for (var dx = plot.left; dx < plot.right; dx += 10) {
      canvas.drawLine(
        Offset(dx, minY),
        Offset((dx + 6).clamp(plot.left, plot.right), minY),
        dash,
      );
    }
    // 6. Moon and target altitude.
    Path pathOf(List<double> values) {
      final p = Path()..moveTo(x(samples[0].instantUtc), yOf(values[0]));
      for (var i = 1; i < values.length; i++) {
        p.lineTo(x(samples[i].instantUtc), yOf(values[i]));
      }
      return p;
    }

    final moon = moonAltitudesDeg;
    if (moon != null && moon.length == samples.length) {
      canvas.drawPath(
        pathOf(moon),
        Paint()
          ..color = palette.chartMoon
          ..strokeWidth = 1.5
          ..style = PaintingStyle.stroke,
      );
    }
    canvas.drawPath(
      pathOf([for (final s in samples) s.targetAltitudeDeg]),
      Paint()
        ..color = palette.chartTarget
        ..strokeWidth = 3.0
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round,
    );
    // 7. When the planned capture ends (the fit's own output), dashed.
    if (data.captureEndUtc case final end?) {
      final ex = x(end);
      final line = Paint()
        ..color = palette.chartTarget
        ..strokeWidth = 2;
      for (var dy = plot.top; dy < plot.bottom; dy += 8) {
        canvas.drawLine(
          Offset(ex, dy),
          Offset(ex, (dy + 4).clamp(plot.top, plot.bottom)),
          line,
        );
      }
    }
    // 8. Now, when inside the night.
    if (data.nowUtc case final now?) {
      var i = 0;
      while (i + 1 < samples.length &&
          !samples[i + 1].instantUtc.isAfter(now)) {
        i++;
      }
      final at = Offset(x(now), yOf(samples[i].targetAltitudeDeg));
      canvas.drawCircle(at, 5, Paint()..color = palette.chartNow);
      canvas.drawCircle(at, 2, Paint()..color = palette.chartNowCentre);
    }
    // 9. Labels, outside the plot.
    for (final (name, r) in g.altitudeLabels) {
      _text(name).paint(canvas, r.topLeft);
    }
    for (final (i, r) in g.timeLabels) {
      _text(ticks[i].$2).paint(canvas, r.topLeft);
    }
  }

  @override
  bool shouldRepaint(TimelinePainter old) =>
      old.opportunity != opportunity ||
      old.moonAltitudesDeg != moonAltitudesDeg ||
      old.palette != palette ||
      old.data.captureEndUtc != data.captureEndUtc ||
      old.data.nowUtc != data.nowUtc ||
      old.density != density ||
      old.textScaler != textScaler ||
      old.labelStyle != labelStyle ||
      old.ticks.length != ticks.length;
}
