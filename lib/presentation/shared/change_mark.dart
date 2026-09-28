import 'package:flutter/material.dart';

import '../../core/theme/app_motion.dart';
import '../../core/theme/app_radius.dart';

/// Cause and effect after an edit (S6.10; P6.9's notes): when [value]
/// changes, [child] is briefly tinted, fading over [AppMotion.highlight].
/// Never on the first build, and not at all with reduced motion. It keeps
/// no calculation state: [value] is what the ViewModel already shows.
class ChangeMark extends StatefulWidget {
  const ChangeMark({super.key, required this.value, required this.child});

  /// The shown value that, when it changes, is marked (e.g. a headline).
  final Object? value;
  final Widget child;

  @override
  State<ChangeMark> createState() => _ChangeMarkState();
}

class _ChangeMarkState extends State<ChangeMark>
    with SingleTickerProviderStateMixin {
  late final AnimationController _fade = AnimationController(
    vsync: this,
    value: 0,
  );

  @override
  void didUpdateWidget(ChangeMark old) {
    super.didUpdateWidget(old);
    if (old.value == widget.value) return;
    final duration = AppMotion.duration(context, AppMotion.highlight);
    if (duration == Duration.zero) return;
    _fade
      ..duration = duration
      ..value = 1;
    _fade.animateTo(0, curve: AppMotion.curve);
  }

  @override
  void dispose() {
    _fade.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tint = Theme.of(context).colorScheme.primaryContainer;
    return AnimatedBuilder(
      animation: _fade,
      builder: (context, child) => DecoratedBox(
        key: const Key('changeMark'),
        decoration: BoxDecoration(
          color: tint.withValues(alpha: 0.6 * _fade.value),
          borderRadius: BorderRadius.circular(AppRadius.small),
        ),
        child: child,
      ),
      child: widget.child,
    );
  }
}
