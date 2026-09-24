import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../domain/models/session.dart';
import '../../domain/repositories/storage_failure.dart';
import '../navigation/app_router.dart';
import '../viewmodels/capture_analysis_viewmodel.dart';
import '../viewmodels/execution_viewmodel.dart';
import 'failure_feedback.dart';

/// Start (ADR-016; TASK 13.3): the current plan starts with its
/// execution-start snapshot and the tracking screen opens; the planner
/// goes on with a copy (owner decision). While another session is in
/// progress, says so and offers it instead (one at a time).
Future<void> startSessionWithFeedback(BuildContext context) async {
  final execution = context.read<ExecutionViewModel?>();
  final messenger = ScaffoldMessenger.of(context);
  try {
    final started = await context
        .read<CaptureAnalysisViewModel>()
        .startSession();
    await execution?.open(started.id);
    if (context.mounted) context.push(AppRouter.run(started.id));
  } on StorageFailure catch (e) {
    messenger.showSnackBar(
      SnackBar(content: Text(FailureText.message('start the session', e))),
    );
  } on SessionStateError {
    final running = execution?.session;
    messenger.showSnackBar(
      SnackBar(
        content: const Text(
          'Another session is in progress. Finish or abandon it first.',
        ),
        action: running == null || !context.mounted
            ? null
            : SnackBarAction(
                label: 'Open it',
                onPressed: () => context.push(AppRouter.run(running.id)),
              ),
      ),
    );
  }
}
