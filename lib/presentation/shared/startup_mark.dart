import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_motion.dart';

/// The Culmina mark shown while startup really loads (S13.3, ID-6 = S2): it
/// continues the Android 12+ splash in the same colours. The star breathes
/// softly only while the view is on screen, which is only while loading — no
/// progress is implied — and stays still when the platform asks for less
/// motion. The geometry is the launcher icon's
/// (`drawable/ic_launcher_foreground.xml`, 108-unit canvas; trap 20).
class StartupMark extends StatefulWidget {
  const StartupMark({super.key, this.size = 112});

  /// The diameter of the navy disc behind the mark, in logical pixels.
  final double size;

  @override
  State<StartupMark> createState() => _StartupMarkState();
}

class _StartupMarkState extends State<StartupMark>
    with SingleTickerProviderStateMixin {
  /// One breath of the star: bright → dim → bright.
  static const Duration breath = Duration(milliseconds: 1600);

  late final AnimationController _breath = AnimationController(
    vsync: this,
    duration: breath,
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (AppMotion.duration(context, breath) == Duration.zero) {
      _breath
        ..stop()
        ..value = 0;
    } else if (!_breath.isAnimating) {
      _breath.repeat();
    }
  }

  @override
  void dispose() {
    _breath.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Loading',
      liveRegion: true,
      child: ExcludeSemantics(
        child: SizedBox.square(
          dimension: widget.size,
          child: AnimatedBuilder(
            animation: _breath,
            builder: (context, _) => CustomPaint(
              painter: _MarkPainter(
                // 1 at rest and at both ends of a breath, 0.6 at its middle.
                starOpacity:
                    1 - 0.4 * (1 - math.cos(2 * math.pi * _breath.value)) / 2,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _MarkPainter extends CustomPainter {
  _MarkPainter({required this.starOpacity});

  final double starOpacity;

  static const _navy = AppColors.markNavy;
  static const _orbit = AppColors.markOrbit;
  static const _inner = AppColors.markInnerOrbit;
  static const _star = AppColors.markStar;

  /// Degrees, counter-clockwise from east with y up, as the vector's arcs.
  static Rect _circle(double r) =>
      Rect.fromCircle(center: const Offset(54, 54), radius: r);

  static double _rad(double degrees) => degrees * math.pi / 180;

  @override
  void paint(Canvas canvas, Size size) {
    final r = size.shortestSide / 2;
    canvas.drawCircle(size.center(Offset.zero), r, Paint()..color = _navy);
    // The disc shows the launcher's 72-unit visible area (18..90).
    final scale = size.shortestSide / 72;
    canvas
      ..save()
      ..scale(scale)
      ..translate(-18, -18);
    final stroke = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(
      _circle(13.2),
      _rad(-94.08),
      _rad(-(345.92 - 94.08)),
      false,
      stroke
        ..color = _inner
        ..strokeWidth = 2.4,
    );
    canvas.drawArc(
      _circle(22),
      _rad(-72.07),
      _rad(-(367.94 - 72.07)),
      false,
      stroke
        ..color = _orbit
        ..strokeWidth = 6,
    );
    final star = Path()
      ..moveTo(70.85, 30.26)
      ..quadraticBezierTo(72.39, 38.32, 80.45, 39.86)
      ..quadraticBezierTo(72.39, 41.39, 70.85, 49.46)
      ..quadraticBezierTo(69.32, 41.39, 61.25, 39.86)
      ..quadraticBezierTo(69.32, 38.32, 70.85, 30.26)
      ..close();
    canvas
      ..drawPath(star, Paint()..color = _star.withValues(alpha: starOpacity))
      ..restore();
  }

  @override
  bool shouldRepaint(_MarkPainter old) => old.starOpacity != starOpacity;
}
