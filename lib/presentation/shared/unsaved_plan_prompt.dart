import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../viewmodels/capture_analysis_viewmodel.dart';
import '../viewmodels/session_plan_viewmodel.dart';
import 'confirmation_patterns.dart';
import 'failure_feedback.dart';

/// What an action that replaces the current plan does with the plan it
/// leaves (S6.3; U1, ADR-019 §3).
enum LeavingPlan {
  /// Nothing to discard: the plan has no unsaved changes, or was just saved.
  /// An untouched plan that was never saved is still deleted by the switch.
  keep,

  /// The user chose Discard: a never-saved plan is deleted; a saved plan
  /// with changes goes back to what was saved (S4-DEF-04 = R).
  discard,
}

/// Asks before New plan, Copy to another night or Open replaces a plan with
/// unsaved changes (S6.3; U1; supersedes S1.6's guard): Save · Discard ·
/// Cancel. Save saves the plan as the Save plan button does, then goes on; a
/// failed Save stops and says so. Cancel, back and a tap outside stop, and
/// nothing changes. Null means stop; otherwise the caller goes on and passes
/// the answer to the lifecycle (`discard:`).
Future<LeavingPlan?> askBeforeLeavingPlan(BuildContext context) async {
  final plan = context.read<SessionPlanViewModel>();
  if (!plan.hasUnsavedChanges) return LeavingPlan.keep;
  final target = plan.selectedTarget;
  final choice = await askUnsavedChanges(
    context,
    plan: target == null ? 'This plan' : target.commonName ?? target.catalogId,
  );
  switch (choice) {
    case UnsavedChoice.cancel:
      return null;
    case UnsavedChoice.discard:
      return LeavingPlan.discard;
    case UnsavedChoice.save:
      if (!context.mounted) return null;
      final saved = await runWithFeedback(
        context,
        'save the plan',
        context.read<CaptureAnalysisViewModel>().saveSession,
      );
      return saved ? LeavingPlan.keep : null;
  }
}
