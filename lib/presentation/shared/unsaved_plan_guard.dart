import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../viewmodels/session_plan_viewmodel.dart';

/// Asks before an action switches the planner away from a plan with
/// unsaved changes (New, Duplicate, opening another session), so a plan is
/// never silently left in a draft no screen lists (S1.6; an interim
/// safeguard until RD-05 decides the draft model). True means go ahead.
Future<bool> confirmLeavingUnsavedPlan(BuildContext context) async {
  if (!context.read<SessionPlanViewModel>().hasUnsavedChanges) return true;
  final discard = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Discard unsaved changes?'),
      content: const Text(
        'The current plan has changes that are not saved. If you go on, it '
        'will no longer be shown in the planner. To keep it, cancel and '
        'save the plan first.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Cancel'),
        ),
        TextButton(
          key: const Key('unsavedPlan.discard'),
          onPressed: () => Navigator.pop(context, true),
          child: const Text('Discard'),
        ),
      ],
    ),
  );
  return discard == true;
}
