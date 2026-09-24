import 'package:flutter/material.dart';

import '../../core/theme/app_palette.dart';

import '../shared/night_time_formatter.dart';
import '../shared/opportunity_text.dart';

import '../../domain/models/imaging_opportunity.dart';

/// Draws one night's [ImagingOpportunity] (TASK 10.3): darkness bands from
/// the Sun at the user's darkness limit, the target's altitude, the Moon's
/// altitude when known, the minimum altitude, and the imaging windows
/// highlighted.
///
/// Render-only (TD-023, DEV-A3): every value comes from the domain result —
/// the same object the window list renders — so chart and list cannot
/// disagree.
class AltitudeChartWidget extends StatelessWidget {
  final ImagingOpportunity opportunity;

  /// The Moon's altitude on the same grid, degrees; null when not known.
  final List<double>? moonAltitudesDeg;

  /// The site's IANA zone for the time axis, or null for the device zone
  /// (TASK 7.1).
  final String? zoneId;

  /// "Now", for the current-time marker; null draws none.
  final DateTime? nowUtc;

  const AltitudeChartWidget({
    super.key,
    required this.opportunity,
    this.moonAltitudesDeg,
    this.zoneId,
    this.nowUtc,
  });

  @override
  Widget build(BuildContext context) {
    final palette = AppPalette.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // TASK 15.3: the chart's text alternative for screen readers; the
        // window list below it has the details.
        Semantics(
          key: const Key('chart.altitude'),
          label: semanticsLabel(opportunity),
          excludeSemantics: true,
          child: SizedBox(
            height: 200,
            width: double.infinity,
            child: CustomPaint(
              painter: _AltitudeChartPainter(
                opportunity: opportunity,
                moonAltitudesDeg: moonAltitudesDeg,
                palette: palette,
                zoneId: zoneId,
                nowUtc: nowUtc,
              ),
            ),
          ),
        ),
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
          ],
        ),
      ],
    );
  }

  /// What the chart shows, for screen readers (TASK 15.3).
  static String semanticsLabel(ImagingOpportunity o) {
    final n = o.windows.length;
    final windows = switch (n) {
      0 => 'no imaging window',
      1 => 'one imaging window',
      _ => '$n imaging windows',
    };
    return "Chart of the target's altitude through the night: $windows, "
        'usable time ${OpportunityText.duration(o.usableTime)}. '
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

class _AltitudeChartPainter extends CustomPainter {
  _AltitudeChartPainter({
    required this.opportunity,
    required this.moonAltitudesDeg,
    required this.palette,
    required this.zoneId,
    required this.nowUtc,
  });

  final ImagingOpportunity opportunity;
  final List<double>? moonAltitudesDeg;
  final AppPalette palette;
  final String? zoneId;
  final DateTime? nowUtc;

  @override
  void paint(Canvas canvas, Size size) {
    final samples = opportunity.samples;
    final numSteps = samples.length - 1;
    if (numSteps <= 0) return;
    final night = opportunity.night;
    final spanMs = night.endUtc.difference(night.startUtc).inMilliseconds;

    double xOf(DateTime t) =>
        t.difference(night.startUtc).inMilliseconds / spanMs * size.width;
    double xAt(int i) => i / numSteps * size.width;
    double yOf(double altitudeDeg) {
      // −10° … 90°, bottom to top; lower values are clipped.
      final y = size.height - ((altitudeDeg + 10) / 100) * size.height;
      return y.clamp(0.0, size.height);
    }

    // 1. Darkness bands from the Sun samples at the user's limit.
    final zone = Paint()..style = PaintingStyle.fill;
    for (var i = 0; i < numSteps; i++) {
      final sun = samples[i].sunAltitudeDeg;
      zone.color = sun > 0
          ? palette.chartDay
          : sun > opportunity.darknessLimitDeg
          ? palette.chartTwilight
          : palette.chartDark;
      canvas.drawRect(Rect.fromLTRB(xAt(i), 0, xAt(i + 1), size.height), zone);
    }

    // 2. Imaging windows.
    final windowPaint = Paint()..color = palette.chartWindow;
    for (final w in opportunity.windows) {
      canvas.drawRect(
        Rect.fromLTRB(xOf(w.startUtc), 0, xOf(w.endUtc), size.height),
        windowPaint,
      );
    }

    // 3. Grid.
    final grid = Paint()
      ..color = palette.chartGrid
      ..strokeWidth = 1.0;
    final text = TextPainter(textDirection: TextDirection.ltr);
    void label(String s, Offset at, {Color? color, double size = 12}) {
      text.text = TextSpan(
        text: s,
        style: TextStyle(
          color: color ?? palette.chartLabel,
          fontSize: size,
          fontWeight: FontWeight.bold,
        ),
      );
      text.layout();
      text.paint(canvas, at);
    }

    for (final (alt, name) in const [
      (0.0, 'Horizon (0°)'),
      (30.0, '30°'),
      (60.0, '60°'),
    ]) {
      final y = yOf(alt);
      canvas.drawLine(Offset(0, y), Offset(size.width, y), grid);
      label(name, Offset(4, y - 16));
    }

    // 4. Minimum altitude (dashed).
    final minY = yOf(opportunity.minAltitudeDeg);
    final dash = Paint()
      ..color = palette.chartMinAltitude
      ..strokeWidth = 1.5;
    for (var x = 0.0; x < size.width; x += 10) {
      canvas.drawLine(
        Offset(x, minY),
        Offset((x + 6).clamp(0, size.width), minY),
        dash,
      );
    }

    // 5. Moon and target altitude.
    Path pathOf(List<double> values) {
      final p = Path()..moveTo(xAt(0), yOf(values[0]));
      for (var i = 1; i < values.length; i++) {
        p.lineTo(xAt(i), yOf(values[i]));
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

    // 6. Now, when inside the night.
    final now = nowUtc;
    if (now != null && night.contains(now)) {
      final i = (xOf(now) / size.width * numSteps).floor().clamp(0, numSteps);
      final at = Offset(xOf(now), yOf(samples[i].targetAltitudeDeg));
      canvas.drawCircle(at, 5, Paint()..color = palette.chartNow);
      canvas.drawCircle(at, 2, Paint()..color = palette.chartNowCentre);
    }

    // 7. Hour labels in the site's zone (else the device's).
    final step = (numSteps / 6).round().clamp(1, numSteps);
    for (var i = 0; i <= numSteps; i += step) {
      final local = NightTimeFormatter.wallClock(
        samples[i].instantUtc,
        zoneId: zoneId,
      );
      final s =
          "${local.hour.toString().padLeft(2, '0')}:"
          "${local.minute.toString().padLeft(2, '0')}";
      text.text = TextSpan(text: s, style: const TextStyle(fontSize: 12));
      text.layout();
      final dx = (xAt(i) - text.width / 2).clamp(0.0, size.width - text.width);
      label(s, Offset(dx, size.height - 16));
    }
  }

  @override
  bool shouldRepaint(_AltitudeChartPainter old) =>
      old.opportunity != opportunity ||
      old.moonAltitudesDeg != moonAltitudesDeg ||
      old.palette != palette ||
      old.zoneId != zoneId ||
      old.nowUtc != nowUtc;
}
