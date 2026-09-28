import 'package:flutter/material.dart';

import '../../../core/theme/app_palette.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../domain/services/stacking_gain_curve.dart';
import '../../shared/app_words.dart';

/// "How does relative √N change as the frame count grows?" (S6.11; P6.10),
/// for one (filter, exposure) group: the curve from one frame to twice the
/// planned count, with the planned count marked. It draws the domain's
/// points ([StackingGainCurve], CALC-42) and computes nothing; the figure
/// itself stays in the row above it. Relative only (SI-003).
///
/// S6.16 (TD-076): the plan's own point is named — "Your plan", its count
/// and value, beside a swatch drawn like the dot — and the curve's end is
/// named as a comparison, so it never reads as a target or a recommendation.
class StackingGainGraph extends StatelessWidget {
  const StackingGainGraph({
    super.key,
    required this.curve,
    required this.groupLabel,
  });

  final StackingGainCurve curve;

  /// The group, e.g. "Ha · 60 s", for the text alternative.
  final String groupLabel;

  static String _x(double gain) => '${gain.toStringAsFixed(1)}x';

  /// The plan's point, as its label says it: "Your plan: 100 frames ·
  /// 10.0x" (TD-076).
  static String planLabel(StackingGainCurve c) =>
      '${AppWords.yourPlan}: ${c.frames} frames · ${_x(c.markedGain)}';

  /// The curve's end, named as a comparison (TD-076).
  static String comparisonLabel(StackingGainCurve c) =>
      'For comparison: ${c.maxFrames} frames · ${_x(c.endGain)}';

  /// The text alternative: the group's value (the plan's point), and where
  /// the curve ends, for comparison.
  static String describe(StackingGainCurve c, String groupLabel) =>
      'Relative stacking gain graph, $groupLabel: ${_x(c.markedGain)} at '
      '${c.frames} frames, your plan; rising more slowly to '
      '${_x(c.endGain)} at ${c.maxFrames} frames, for comparison.';

  @override
  Widget build(BuildContext context) {
    final palette = AppPalette.of(context);
    final text = Theme.of(context).textTheme;
    final small = text.bodySmall?.copyWith(color: palette.textTertiary);
    return Semantics(
      label: describe(curve, groupLabel),
      excludeSemantics: true,
      child: Padding(
        padding: const EdgeInsets.only(bottom: AppSpacing.sm),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              height: 48,
              child: CustomPaint(painter: StackingGainPainter(curve, palette)),
            ),
            // The axis' ends, as text so it scales and wraps (200 %).
            Row(
              children: [
                Expanded(child: Text('1 frame', style: small)),
                Flexible(
                  child: Text(
                    comparisonLabel(curve),
                    key: const Key('gainGraph.comparison'),
                    style: small,
                    textAlign: TextAlign.end,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xs),
            // The plan's point, keyed to the dot by the same drawing.
            Row(
              children: [
                SizedBox(
                  width: 12,
                  height: 12,
                  child: CustomPaint(painter: PlanPointSwatch(palette)),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    planLabel(curve),
                    key: const Key('gainGraph.plan'),
                    style: text.bodySmall?.copyWith(color: palette.textPrimary),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// The plan's point as the graph draws it (S6.16, TD-076), for its label.
class PlanPointSwatch extends CustomPainter {
  PlanPointSwatch(this.palette);

  final AppPalette palette;

  @override
  void paint(Canvas canvas, Size size) =>
      StackingGainPainter.paintPoint(canvas, size.center(Offset.zero), palette);

  @override
  bool shouldRepaint(PlanPointSwatch old) => old.palette != palette;
}

/// Paints [curve]: frames along x (from 1 to its end), relative √N along y
/// (from 0); the planned count as a guide line and a dot. Public for tests,
/// which check that it draws exactly the domain's points.
class StackingGainPainter extends CustomPainter {
  StackingGainPainter(this.curve, this.palette);

  final StackingGainCurve curve;
  final AppPalette palette;

  @override
  void paint(Canvas canvas, Size size) {
    final span = (curve.maxFrames - 1).toDouble();
    final top = curve.endGain;
    Offset at(int frames, double gain) => Offset(
      span <= 0 ? 0 : (frames - 1) / span * size.width,
      size.height - (top <= 0 ? 0 : gain / top) * (size.height - 4),
    );

    canvas.drawLine(
      Offset(0, size.height),
      Offset(size.width, size.height),
      Paint()
        ..color = palette.chartGrid
        ..strokeWidth = 1,
    );
    final path = Path();
    for (final (i, p) in curve.points.indexed) {
      final o = at(p.frames, p.gain);
      i == 0 ? path.moveTo(o.dx, o.dy) : path.lineTo(o.dx, o.dy);
    }
    canvas.drawPath(
      path,
      Paint()
        ..color = palette.chartTarget
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
    if (curve.frames >= 1) {
      final mark = at(curve.frames, curve.markedGain);
      canvas.drawLine(
        Offset(mark.dx, size.height),
        mark,
        Paint()
          ..color = palette.chartGrid
          ..strokeWidth = 1,
      );
      paintPoint(canvas, mark, palette);
    }
  }

  /// The plan's point: the altitude chart's "now" dot (S6.11); its label's
  /// swatch draws the same (S6.16).
  static void paintPoint(Canvas canvas, Offset at, AppPalette palette) {
    canvas.drawCircle(at, 5, Paint()..color = palette.chartNow);
    canvas.drawCircle(at, 2, Paint()..color = palette.chartNowCentre);
  }

  @override
  bool shouldRepaint(StackingGainPainter old) =>
      old.curve.frames != curve.frames || old.palette != palette;
}
