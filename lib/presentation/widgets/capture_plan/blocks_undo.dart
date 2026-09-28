import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/diagnostics/app_log.dart';
import '../../shared/delete_patterns.dart';
import '../../shared/failure_feedback.dart';
import '../../viewmodels/blocks_edit.dart';
import '../../viewmodels/session_plan_viewmodel.dart';

/// A way back from a one-tap change to the capture blocks (TD-079, S6.16;
/// RD-09's Undo for edits inside a plan): Fill or Trim, a block edit saved
/// in its dialog, "Start from the example plan". [change] is applied at
/// once, then S5.8's "[message] · Undo" says what happened; Undo puts the
/// blocks and the example badge back exactly, unless they were edited again
/// meanwhile, and then nothing changes and the user is told. Nothing is kept
/// once the message closes: no undo history. Returns false when [change]
/// changed nothing (no message then). Run it through `runWithFeedback`.
Future<bool> editBlocksWithUndo(
  BuildContext context, {
  required String message,
  required Future<Object?> Function() change,
}) async {
  final plan = context.read<SessionPlanViewModel>();
  final messenger = ScaffoldMessenger.of(context);
  final edit = await plan.recordBlocksEdit(change);
  if (!edit.changed || !context.mounted) return edit.changed;
  unawaited(
    showUndo(
      context,
      message: message,
      onUndo: () => unawaited(_undo(plan, edit, messenger)),
    ),
  );
  return true;
}

/// Said when Undo comes after another edit to the blocks (TD-079).
const notUndone = 'Not undone: the capture plan was changed again since.';

/// Undo may run after the screen that offered it has gone, so it reports
/// through the [messenger] it was given (trap 18: a failed write is said).
Future<void> _undo(
  SessionPlanViewModel plan,
  BlocksEdit edit,
  ScaffoldMessengerState messenger,
) async {
  try {
    if (!await plan.undoBlocksEdit(edit)) {
      messenger.showSnackBar(const SnackBar(content: Text(notUndone)));
    }
  } catch (e, s) {
    AppLog.error('ui', 'Could not undo the change', error: e, stackTrace: s);
    messenger.showSnackBar(
      SnackBar(content: Text(FailureText.message('undo the change', e))),
    );
  }
}
