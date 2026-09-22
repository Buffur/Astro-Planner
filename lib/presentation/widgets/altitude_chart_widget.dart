import 'package:flutter/material.dart';

import '../../domain/models/altitude_curve.dart';
import '../../domain/models/astro_target.dart';
import '../../domain/models/calendar_date.dart';
import '../../domain/models/session_night.dart';
import '../../domain/models/site_time_context.dart';
import '../../domain/services/session_night_resolver.dart';
import '../../domain/services/visibility_calculator.dart';

/// Shows a target's altitude across one night.
///
/// Render-only (TD-023, DEV-A3, TASK 2.3): astronomy is sampled once in the
/// domain (`VisibilityCalculator.calculateAltitudeCurve`), here in [build],
/// not inside the painter, and the painter never imports astronomy code.
///
/// [sessionDate]'s Y/M/D is resolved to a [SessionNight] through a
/// [MeanSolarTimeContext] (ADR-007), the same path
/// `PlannerViewModel.visibilityWindows`/`nightTimeline` use, so the chart and
/// the rest of the screen now share one window — this widget's constructor
/// is otherwise unchanged so callers (`home_screen.dart`) don't need to
/// change before TASK 2.4 gives the ViewModel a SessionNight of its own.
class AltitudeChartWidget extends StatelessWidget {
  final AstroTarget target;
  final double latitude;
  final double longitude;
  final DateTime sessionDate;

  /// Minimum usable altitude in degrees. Drawn as a dashed red threshold line.
  final double minAltitude;

  const AltitudeChartWidget({
    super.key,
    required this.target,
    required this.latitude,
    required this.longitude,
    required this.sessionDate,
    this.minAltitude = 20.0,
  });

  @override
  Widget build(BuildContext context) {
    final night = SessionNightResolver.forEveningDate(
      CalendarDate.fromDateTimeFields(sessionDate),
      latitude: latitude,
      longitude: longitude,
      timeContext: MeanSolarTimeContext(longitude),
    );
    final curve = VisibilityCalculator.calculateAltitudeCurve(
      night: night,
      target: target,
    );

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Visibility & Altitude',
              style: Theme.of(context).textTheme.titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              width: double.infinity,
              child: CustomPaint(
                painter: _AltitudeChartPainter(
                  target: target,
                  curve: curve,
                  theme: Theme.of(context),
                  minAltitude: minAltitude,
                ),
              ),
            ),
            const SizedBox(height: 12),
            _buildLegend(context),
          ],
        ),
      ),
    );
  }

  Widget _buildLegend(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _legendItem(context, 'Day', Colors.lightBlue.shade100),
        _legendItem(context, 'Twilight', Colors.indigo.shade300),
        _legendItem(context, 'Night', Colors.black87),
        const SizedBox(width: 8),
        Container(width: 12, height: 2, color: Colors.amber),
        const SizedBox(width: 4),
        const Text('Target', style: TextStyle(fontSize: 10)),
        const SizedBox(width: 8),
        // Dashed line indicator for minimum altitude threshold
        Row(
          children: [
            for (int i = 0; i < 3; i++) ...[
              Container(width: 3, height: 2, color: Colors.redAccent),
              const SizedBox(width: 2),
            ],
          ],
        ),
        const SizedBox(width: 4),
        Text(
          'Min ${minAltitude.toStringAsFixed(0)}°',
          style: const TextStyle(fontSize: 10),
        ),
      ],
    );
  }

  Widget _legendItem(BuildContext context, String label, Color color) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: Row(
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              color: isDark && color == Colors.black87
                  ? Colors.grey.shade900
                  : color,
              border: Border.all(color: Colors.grey.shade400, width: 0.5),
            ),
          ),
          const SizedBox(width: 4),
          Text(label, style: const TextStyle(fontSize: 10)),
        ],
      ),
    );
  }
}

class _AltitudeChartPainter extends CustomPainter {
  final AstroTarget target;
  final AltitudeCurve curve;
  final ThemeData theme;
  final double minAltitude;

  _AltitudeChartPainter({
    required this.target,
    required this.curve,
    required this.theme,
    required this.minAltitude,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final isDark = theme.brightness == Brightness.dark;
    final samples = curve.samples;
    final numSteps = samples.length - 1;
    if (numSteps <= 0) return;

    double yOf(double altitudeDeg) {
      // Map Y from 90 to 0 (top to bottom). Altitude can be negative.
      // Clip the visual plot from -10 to 90 degrees to show setting.
      final y = size.height - ((altitudeDeg + 10) / 100) * size.height;
      return y.clamp(0.0, size.height);
    }

    final targetPoints = <Offset>[
      for (var i = 0; i <= numSteps; i++)
        Offset((i / numSteps) * size.width, yOf(samples[i].targetAltitudeDeg)),
    ];

    // 1. Draw Background Zones based on Sun Altitude
    final paintZone = Paint()..style = PaintingStyle.fill;

    for (int i = 0; i < numSteps; i++) {
      final sunAlt = samples[i].sunAltitudeDeg;
      Color zoneColor;

      if (sunAlt > 0) {
        zoneColor = isDark
            ? Colors.blueGrey.shade800
            : Colors.lightBlue.shade100; // Day
      } else if (sunAlt > -18) {
        // Twilight transition
        zoneColor = isDark ? Colors.indigo.shade900 : Colors.indigo.shade300;
      } else {
        zoneColor = isDark ? Colors.black : Colors.black87; // True Night
      }

      paintZone.color = zoneColor;
      final x1 = (i / numSteps) * size.width;
      final x2 = ((i + 1) / numSteps) * size.width;
      canvas.drawRect(Rect.fromLTRB(x1, 0, x2, size.height), paintZone);
    }

    // 2. Draw Reference Grid (0 horizon, 30 deg optimal)
    final paintGrid = Paint()
      ..color = isDark ? Colors.white30 : Colors.white60
      ..strokeWidth = 1.0;

    final paintText = TextPainter(textDirection: TextDirection.ltr);

    void drawLine(double alt, String label, {bool dashed = false}) {
      final y = yOf(alt);
      if (y >= 0 && y <= size.height) {
        canvas.drawLine(Offset(0, y), Offset(size.width, y), paintGrid);

        paintText.text = TextSpan(
          text: label,
          style: TextStyle(
            color: isDark ? Colors.white70 : Colors.white,
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
        );
        paintText.layout();
        paintText.paint(canvas, Offset(4, y - 14));
      }
    }

    drawLine(0, 'Horizon (0°)');
    drawLine(30, '30°');
    drawLine(60, '60°');

    // 2b. Draw Minimum Altitude Threshold Line (dashed red)
    final thresholdY = yOf(minAltitude);
    if (thresholdY >= 0 && thresholdY <= size.height) {
      final paintThreshold = Paint()
        ..color = Colors.redAccent
        ..strokeWidth = 1.5
        ..style = PaintingStyle.stroke;

      // Draw dashed line
      const dashWidth = 6.0;
      const dashGap = 4.0;
      double x = 0;
      while (x < size.width) {
        canvas.drawLine(
          Offset(x, thresholdY),
          Offset((x + dashWidth).clamp(0, size.width), thresholdY),
          paintThreshold,
        );
        x += dashWidth + dashGap;
      }

      // Label
      final thresholdLabel = 'Min ${minAltitude.toStringAsFixed(0)}°';
      final paintThresholdText = TextPainter(textDirection: TextDirection.ltr);
      paintThresholdText.text = TextSpan(
        text: thresholdLabel,
        style: const TextStyle(
          color: Colors.redAccent,
          fontSize: 9,
          fontWeight: FontWeight.bold,
        ),
      );
      paintThresholdText.layout();
      // Position label at right side to avoid overlap with left labels
      paintThresholdText.paint(
        canvas,
        Offset(size.width - paintThresholdText.width - 4, thresholdY - 12),
      );
    }

    // 3. Draw Target Trajectory Line
    final paintLine = Paint()
      ..color = Colors.amber
      ..strokeWidth = 3.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path();
    if (targetPoints.isNotEmpty) {
      path.moveTo(targetPoints.first.dx, targetPoints.first.dy);
      for (int i = 1; i < targetPoints.length; i++) {
        // Smooth curve
        final p0 = targetPoints[i - 1];
        final p1 = targetPoints[i];
        path.quadraticBezierTo(
          p0.dx,
          p0.dy,
          (p0.dx + p1.dx) / 2,
          (p0.dy + p1.dy) / 2,
        );
      }
      path.lineTo(targetPoints.last.dx, targetPoints.last.dy);
    }

    canvas.drawPath(path, paintLine);

    // Draw dot for current time if it's within the window
    final nowUtc = DateTime.now().toUtc();
    if (curve.night.contains(nowUtc)) {
      final percent =
          nowUtc.difference(curve.night.startUtc).inMilliseconds /
          SessionNight.length.inMilliseconds;
      final x = percent * size.width;

      // Interpolate Y
      final index = (percent * numSteps).floor().clamp(0, numSteps);
      final y = targetPoints[index].dy;

      canvas.drawCircle(Offset(x, y), 5, Paint()..color = Colors.redAccent);
      canvas.drawCircle(Offset(x, y), 2, Paint()..color = Colors.white);
    }

    // X-Axis Time Labels. Local-hour labels only, as before this task; a
    // zone-labelled formatter is TASK 2.4 (ADR-007 §6).
    final labelStep = (numSteps / 6).round().clamp(1, numSteps); // ~4-hourly
    for (int i = 0; i <= numSteps; i += labelStep) {
      final x = (i / numSteps) * size.width;
      final localTime = samples[i].instantUtc.toLocal();
      final label = "${localTime.hour.toString().padLeft(2, '0')}:00";
      paintText.text = TextSpan(
        text: label,
        style: TextStyle(
          color: isDark ? Colors.white70 : Colors.white,
          fontSize: 10,
        ),
      );
      paintText.layout();
      // Adjust edge labels to not clip
      double dx = x - paintText.width / 2;
      if (dx < 0) dx = 0;
      if (dx + paintText.width > size.width) dx = size.width - paintText.width;

      paintText.paint(canvas, Offset(dx, size.height - 14));
    }
  }

  @override
  bool shouldRepaint(_AltitudeChartPainter oldDelegate) {
    return oldDelegate.target != target ||
        oldDelegate.curve.night != curve.night ||
        oldDelegate.theme.brightness != theme.brightness ||
        oldDelegate.minAltitude != minAltitude;
  }
}
