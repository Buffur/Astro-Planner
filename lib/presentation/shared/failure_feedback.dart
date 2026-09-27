import 'package:flutter/material.dart';

import '../../core/diagnostics/app_log.dart';
import '../../domain/repositories/storage_failure.dart';

/// User-facing wording for a failed action (TASK 15.1). The error itself
/// goes to the log ([AppLog]), never onto the screen.
abstract final class FailureText {
  /// [action] is a verb phrase: "save the rig", "load the sessions".
  static String message(String action, Object error) => switch (error) {
    StorageFailure() =>
      "Couldn't $action: the app's data on this device could not be read "
          'or written. Please try again.',
    _ => "Couldn't $action. Please try again.",
  };
}

/// Runs a user action; a failure is logged and shown as a message instead
/// of being lost (TASK 15.1). Returns whether it succeeded.
Future<bool> runWithFeedback(
  BuildContext context,
  String action,
  Future<void> Function() run,
) async {
  final messenger = ScaffoldMessenger.of(context);
  try {
    await run();
    return true;
  } catch (e, s) {
    AppLog.error('ui', 'Could not $action', error: e, stackTrace: s);
    messenger.showSnackBar(
      SnackBar(content: Text(FailureText.message(action, e))),
    );
    return false;
  }
}

/// Says what an action did (S5.8; 08 §5, §8): a short message naming the
/// result, "New plan started", "Copied to Sat 15 Nov", "Plan saved". The
/// success twin of [runWithFeedback]'s failure message; red in field mode
/// by the theme. Call it after the action succeeded.
void showDone(BuildContext context, String message) {
  ScaffoldMessenger.maybeOf(context)
    ?..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(content: Text(message), duration: const Duration(seconds: 3)),
    );
}

/// A list or page that could not be loaded (TASK 15.1): says so, instead of
/// looking empty, and offers to try again.
class LoadFailureView extends StatelessWidget {
  const LoadFailureView({
    super.key,
    required this.action,
    required this.error,
    this.onRetry,
  });

  final String action;
  final Object error;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              FailureText.message(action, error),
              key: const Key('loadFailure.message'),
              textAlign: TextAlign.center,
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 12),
              OutlinedButton(onPressed: onRetry, child: const Text('Retry')),
            ],
          ],
        ),
      ),
    );
  }
}
