import 'package:flutter/material.dart';

import '../shared/night_time_formatter.dart';

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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 200,
          width: double.infinity,
          child: CustomPaint(
            painter: _AltitudeChartPainter(
              opportunity: opportunity,
              moonAltitudesDeg: moonAltitudesDeg,
              isDark: isDark,
              zoneId: zoneId,
              nowUtc: nowUtc,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 10,
          runSpacing: 4,
          children: [
            _swatch(context, 'Day', _Palette.day(isDark)),
            _swatch(context, 'Twilight', _Palette.twilight(isDark)),
            _swatch(
              context,
              'Dark (Sun ≤ ${_signed(opportunity.darknessLimitDeg)})',
              _Palette.dark(isDark),
            ),
            _swatch(context, 'Imaging window', _Palette.window),
            _line(context, 'Target', Colors.amber),
            if (moonAltitudesDeg != null)
              _line(context, 'Moon', Colors.blueGrey.shade200),
            _line(
              context,
              'Min ${opportunity.minAltitudeDeg.round()}°',
              Colors.redAccent,
            ),
          ],
        ),
      ],
    );
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
          border: Border.all(color: Colors.grey.shade400, width: 0.5),
        ),
      ),
      const SizedBox(width: 4),
      Text(label, style: const TextStyle(fontSize: 10)),
    ],
  );

  Widget _line(BuildContext context, String label, Color color) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Container(width: 12, height: 2, color: color),
      const SizedBox(width: 4),
      Text(label, style: const TextStyle(fontSize: 10)),
    ],
  );
}

abstract final class _Palette {
  static Color day(bool dark) =>
      dark ? Colors.blueGrey.shade800 : Colors.lightBlue.shade100;
  static Color twilight(bool dark) =>
      dark ? Colors.indigo.shade900 : Colors.indigo.shade300;
  static Color dark(bool dark) => dark ? Colors.black : Colors.black87;
  static const Color window = Color(0x6600C853);
}

class _AltitudeChartPainter extends CustomPainter {
  _AltitudeChartPainter({
    required this.opportunity,
    required this.moonAltitudesDeg,
    required this.isDark,
    required this.zoneId,
    required this.nowUtc,
  });

  final ImagingOpportunity opportunity;
  final List<double>? moonAltitudesDeg;
  final bool isDark;
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
          ? _Palette.day(isDark)
          : sun > opportunity.darknessLimitDeg
          ? _Palette.twilight(isDark)
          : _Palette.dark(isDark);
      canvas.drawRect(Rect.fromLTRB(xAt(i), 0, xAt(i + 1), size.height), zone);
    }

    // 2. Imaging windows.
    final windowPaint = Paint()..color = _Palette.window;
    for (final w in opportunity.windows) {
      canvas.drawRect(
        Rect.fromLTRB(xOf(w.startUtc), 0, xOf(w.endUtc), size.height),
        windowPaint,
      );
    }

    // 3. Grid.
    final grid = Paint()
      ..color = isDark ? Colors.white30 : Colors.white60
      ..strokeWidth = 1.0;
    final text = TextPainter(textDirection: TextDirection.ltr);
    void label(String s, Offset at, {Color? color, double size = 10}) {
      text.text = TextSpan(
        text: s,
        style: TextStyle(
          color: color ?? (isDark ? Colors.white70 : Colors.white),
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
      label(name, Offset(4, y - 14));
    }

    // 4. Minimum altitude (dashed).
    final minY = yOf(opportunity.minAltitudeDeg);
    final dash = Paint()
      ..color = Colors.redAccent
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
          ..color = Colors.blueGrey.shade200
          ..strokeWidth = 1.5
          ..style = PaintingStyle.stroke,
      );
    }
    canvas.drawPath(
      pathOf([for (final s in samples) s.targetAltitudeDeg]),
      Paint()
        ..color = Colors.amber
        ..strokeWidth = 3.0
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round,
    );

    // 6. Now, when inside the night.
    final now = nowUtc;
    if (now != null && night.contains(now)) {
      final i = (xOf(now) / size.width * numSteps).floor().clamp(0, numSteps);
      final at = Offset(xOf(now), yOf(samples[i].targetAltitudeDeg));
      canvas.drawCircle(at, 5, Paint()..color = Colors.redAccent);
      canvas.drawCircle(at, 2, Paint()..color = Colors.white);
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
      text.text = TextSpan(text: s, style: const TextStyle(fontSize: 10));
      text.layout();
      final dx = (xAt(i) - text.width / 2).clamp(0.0, size.width - text.width);
      label(s, Offset(dx, size.height - 14));
    }
  }

  @override
  bool shouldRepaint(_AltitudeChartPainter old) =>
      old.opportunity != opportunity ||
      old.moonAltitudesDeg != moonAltitudesDeg ||
      old.isDark != isDark ||
      old.zoneId != zoneId ||
      old.nowUtc != nowUtc;
}
