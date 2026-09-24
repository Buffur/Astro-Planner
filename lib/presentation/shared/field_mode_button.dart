import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/config/feature_scope.dart';
import '../viewmodels/theme_viewmodel.dart';
import 'failure_feedback.dart';

/// Red field mode, one tap from Tonight and the planner (ADR-015 §4,
/// TASK 12.4). Reads the gate itself, so call sites never gate it again.
class FieldModeButton extends StatelessWidget {
  const FieldModeButton({super.key});

  @override
  Widget build(BuildContext context) {
    if (!FeatureScope.fieldMode) return const SizedBox.shrink();
    final on = context.watch<ThemeViewModel>().isFieldMode;
    return IconButton(
      key: const Key('fieldMode.toggle'),
      icon: Icon(on ? Icons.wb_sunny_outlined : Icons.nightlight_round),
      tooltip: on ? 'Leave field mode' : 'Red field mode',
      onPressed: () => _toggle(context),
    );
  }
}

/// The same switch as a Settings row.
class FieldModeTile extends StatelessWidget {
  const FieldModeTile({super.key});

  @override
  Widget build(BuildContext context) {
    if (!FeatureScope.fieldMode) return const SizedBox.shrink();
    return SwitchListTile(
      key: const Key('fieldMode.tile'),
      contentPadding: EdgeInsets.zero,
      secondary: const Icon(Icons.nightlight_round),
      title: const Text('Red field mode'),
      subtitle: const Text(
        'Red on black only, to keep your night vision. Stays on after a '
        'restart.',
      ),
      value: context.watch<ThemeViewModel>().isFieldMode,
      onChanged: (_) => _toggle(context),
    );
  }
}

/// Switches field mode; it switches even when it cannot be stored, and
/// then says it will not survive a restart (TASK 15.4).
Future<void> _toggle(BuildContext context) => runWithFeedback(
  context,
  'remember field mode for the next start',
  context.read<ThemeViewModel>().toggleFieldMode,
);
