import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

import '../viewmodels/night_conditions_viewmodel.dart';
import '../viewmodels/plan_lifecycle_viewmodel.dart';

/// Keeps the night's forecast in step with the clock while the app runs
/// (ADR-012 §6; S1.3): every [period] it asks [NightConditionsViewModel] to
/// re-age the forecast and follow a night that has rolled over, and when
/// the app returns to the foreground it lets the ViewModel reload a
/// forecast that is no longer current. First the plan follows the night
/// (S6.4: a never-saved draft's night key is written at the rollover). The
/// timer lives here, not in the ViewModels, so it stops with the widget
/// tree.
class NightClock extends StatefulWidget {
  const NightClock({
    super.key,
    required this.child,
    this.period = const Duration(minutes: 1),
  });

  final Widget child;
  final Duration period;

  @override
  State<NightClock> createState() => _NightClockState();
}

class _NightClockState extends State<NightClock> {
  late final Timer _timer;
  late final AppLifecycleListener _lifecycle;

  NightConditionsViewModel get _conditions =>
      context.read<NightConditionsViewModel>();

  /// The plan first, so the forecast's check sees the night it follows.
  void _tick() {
    unawaited(context.read<PlanLifecycleViewModel>().followNight());
    _conditions.checkClock();
  }

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(widget.period, (_) => _tick());
    _lifecycle = AppLifecycleListener(
      onResume: () {
        unawaited(context.read<PlanLifecycleViewModel>().followNight());
        _conditions.resumed();
      },
    );
  }

  @override
  void dispose() {
    _timer.cancel();
    _lifecycle.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
