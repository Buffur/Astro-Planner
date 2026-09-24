import 'package:flutter/material.dart';

import '../../../domain/models/execution.dart';
import '../../shared/opportunity_text.dart';
import '../../viewmodels/resume_run_viewmodel.dart';

/// The resume prompt (ADR-016 §5; TASK 13.2): a session was in progress
/// when the app last stopped. Keep going, pause now, finish or abandon —
/// nothing happens to the run without an answer. Finishing is reconciled
/// in TASK 13.4; the tracking screen itself is TASK 13.3.
Future<void> showResumeRunDialog(BuildContext context, ResumeRunViewModel vm) {
  final o = vm.offer;
  if (o == null) return Future.value();
  final running = o.state.phase == ExecutionPhase.running;
  final block = o.block;
  final estimate = o.estimate;
  final target = o.session.record.targetName;

  return showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (dialogContext) {
      void close() => Navigator.of(dialogContext).pop();
      return AlertDialog(
        key: const Key('resumeRun.dialog'),
        title: Text('$target is in progress'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (block != null)
                Text(
                  '${block.filterName ?? block.frameType.name} · '
                  '${block.exposureTimeSeconds.round()} s · '
                  '${o.state.completedFor(block.id)} of ${block.frameCount} '
                  'frames confirmed',
                ),
              Text(
                running
                    ? 'Running for ${OpportunityText.duration(o.runningTime)} '
                          'in this block.'
                    : 'Paused.',
                key: const Key('resumeRun.phase'),
              ),
              if (running && estimate != null)
                Text(
                  estimate.planReached
                      ? 'About ${estimate.frames} more frames (estimated); '
                            'the plan for this block is reached.'
                      : 'About ${estimate.frames} more frames (estimated), '
                            'not counted until you confirm them.',
                  key: const Key('resumeRun.estimate'),
                ),
              if (o.stale)
                const Text(
                  "This session's night is over.",
                  key: Key('resumeRun.stale'),
                ),
              if (o.clockBehind)
                const Text(
                  "The phone's clock changed; the time shown may be off.",
                  key: Key('resumeRun.clock'),
                ),
            ],
          ),
        ),
        actions: [
          TextButton(
            key: const Key('resumeRun.abandon'),
            onPressed: () async {
              final sure = await showDialog<bool>(
                context: dialogContext,
                builder: (c) => AlertDialog(
                  title: const Text('Abandon this session?'),
                  content: const Text(
                    'It stays in Sessions as abandoned; the confirmed counts '
                    'are kept.',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(c).pop(false),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.of(c).pop(true),
                      child: const Text('Abandon'),
                    ),
                  ],
                ),
              );
              if (sure != true) return;
              await vm.abandon();
              close();
            },
            child: const Text('Abandon'),
          ),
          TextButton(
            key: const Key('resumeRun.finish'),
            onPressed: () async {
              await vm.finish();
              close();
            },
            child: const Text('Finish'),
          ),
          if (running)
            TextButton(
              key: const Key('resumeRun.pause'),
              onPressed: () async {
                await vm.pauseNow();
                close();
              },
              child: const Text('Pause now'),
            ),
          FilledButton(
            key: const Key('resumeRun.keepGoing'),
            onPressed: () {
              vm.keepGoing();
              close();
            },
            child: Text(running ? 'Keep going' : 'Keep paused'),
          ),
        ],
      );
    },
  );
}
