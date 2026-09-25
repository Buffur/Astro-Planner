import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_palette.dart';
import '../../../domain/models/capture_block.dart';
import '../../../domain/models/execution.dart';
import '../../../domain/repositories/storage_failure.dart';
import '../../../domain/services/execution_outlook.dart';
import '../../navigation/app_router.dart';
import '../../shared/failure_feedback.dart';
import '../../shared/field_mode_button.dart';
import '../../shared/night_time_formatter.dart';
import '../../shared/opportunity_text.dart';
import '../../viewmodels/execution_viewmodel.dart';
import '../../../core/utils/quantity_text.dart';

/// The tracking screen (ADR-016; TASK 13.3): large, glanceable, red-safe,
/// every action in the lower half for one thumb, no typing. Everything is
/// re-read from the stored run; the clock only refreshes the display.
class ExecutionScreen extends StatefulWidget {
  const ExecutionScreen({super.key, required this.sessionId});

  final int sessionId;

  @override
  State<ExecutionScreen> createState() => _ExecutionScreenState();
}

class _ExecutionScreenState extends State<ExecutionScreen> {
  Timer? _tick;
  ExecutionViewModel? _vm;

  @override
  void initState() {
    super.initState();
    final vm = _vm = context.read<ExecutionViewModel?>();
    if (vm != null && vm.session?.id != widget.sessionId) {
      vm.open(widget.sessionId);
    }
    vm?.setVisible(true);
    // Countdowns and the estimate move with the clock; the run does not.
    _tick = Timer.periodic(const Duration(seconds: 30), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _tick?.cancel();
    _vm?.setVisible(false);
    super.dispose();
  }

  /// Runs [action]; a refused event (ExecutionError) or a write that could
  /// not be stored (StorageFailure, e.g. a full disk; TASK 15.4) is shown,
  /// not thrown.
  Future<void> _do(Future<void> Function() action) async {
    try {
      await action();
    } on StateError catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(e.message)));
      }
    } on StorageFailure catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(FailureText.message('record that', e))),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ExecutionViewModel?>();
    final session = vm?.session;
    final state = vm?.state;
    if (vm == null ||
        session == null ||
        state == null ||
        session.id != widget.sessionId) {
      return Scaffold(
        appBar: AppBar(title: const Text('Tracking')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }
    final ended = !state.isActive;
    return Scaffold(
      appBar: AppBar(
        title: Text(session.record.targetName),
        actions: const [FieldModeButton()],
      ),
      body: ended ? _Ended(vm: vm) : _Summary(vm: vm),
      bottomNavigationBar: ended ? null : _Controls(vm: vm, run: _do),
    );
  }
}

/// The read-only upper half: block, counts, estimate, warnings, countdowns.
class _Summary extends StatelessWidget {
  const _Summary({required this.vm});

  final ExecutionViewModel vm;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final state = vm.state!;
    final block = vm.block;
    final estimate = vm.estimate;
    final running = state.phase == ExecutionPhase.running;
    final snapshot = vm.session!.executionStartSnapshot;
    final nightStart = snapshot?.night?.startUtc;
    String at(DateTime utc) => nightStart == null
        ? NightTimeFormatter.deviceZoneCaption(utc)
        : NightTimeFormatter.instant(
            context,
            utc,
            windowStartUtc: nightStart,
            zoneId: snapshot?.timeZoneId,
          );

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          running
              ? 'Running · ${OpportunityText.duration(vm.runningTime)} in this block'
              : 'Paused${_reason(state.lastInterruption)}',
          key: const Key('run.phase'),
          style: theme.textTheme.titleMedium,
        ),
        if (block != null) ...[
          const SizedBox(height: 8),
          Text(_blockLabel(block), style: theme.textTheme.titleLarge),
          Text(
            '${state.completedFor(block.id)} of ${block.frameCount}',
            key: const Key('run.confirmed'),
            style: theme.textTheme.displaySmall,
          ),
          Text('confirmed', style: theme.textTheme.labelLarge),
          if (state.rejectedFor(block.id) > 0)
            Text(
              '${state.rejectedFor(block.id)} rejected',
              key: const Key('run.rejected'),
            ),
          if (estimate != null)
            Text(
              estimate.planReached
                  ? 'About ${estimate.frames} more (estimated); the plan for '
                        'this block is reached.'
                  : 'About ${estimate.frames} more (estimated), not counted '
                        'until you confirm them.',
              key: const Key('run.estimate'),
            ),
        ],
        if (vm.stale)
          _Warning(
            key: const Key('run.stale'),
            text: "This session's night is over. Finish or abandon it.",
          ),
        if (vm.clockBehind)
          const _Warning(
            key: Key('run.clock'),
            text: "The phone's clock changed; times may be off.",
          ),
        const SizedBox(height: 12),
        if (vm.outlook case final o?)
          _Outlook(outlook: o, at: at, nowUtc: vm.nowUtc),
      ],
    );
  }

  static String _reason(InterruptionReason? r) =>
      r == null ? '' : ' · ${_reasonLabel(r)}';
}

String _blockLabel(CaptureBlock b) =>
    '${b.filterName ?? _typeLabel(b.frameType)} · '
    '${QuantityText.exposure(b.exposureTimeSeconds)}';

String _typeLabel(FrameType t) => switch (t) {
  FrameType.light => 'Light',
  FrameType.dark => 'Darks',
  FrameType.flat => 'Flats',
  FrameType.bias => 'Bias',
};

String _reasonLabel(InterruptionReason r) => switch (r) {
  InterruptionReason.clouds => 'Clouds',
  InterruptionReason.wind => 'Wind',
  InterruptionReason.dew => 'Dew',
  InterruptionReason.equipment => 'Equipment',
  InterruptionReason.other => 'Other',
};

class _Warning extends StatelessWidget {
  const _Warning({super.key, required this.text});

  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: 8),
    child: Text(
      text,
      style: TextStyle(color: Theme.of(context).colorScheme.error),
    ),
  );
}

/// Countdowns and remaining window vs remaining plan (CALC-36).
class _Outlook extends StatelessWidget {
  const _Outlook({
    required this.outlook,
    required this.at,
    required this.nowUtc,
  });

  final ExecutionOutlook outlook;
  final String Function(DateTime) at;
  final DateTime nowUtc;

  @override
  Widget build(BuildContext context) {
    final o = outlook;
    final now = nowUtc;
    String inTime(DateTime t) =>
        'in ${OpportunityText.duration(t.difference(now).isNegative ? Duration.zero : t.difference(now))} · ${at(t)}';
    final lines = <(String, String)>[
      (
        'Astronomical dawn',
        o.astronomicalDawnUtc == null
            ? 'not ahead tonight'
            : inTime(o.astronomicalDawnUtc!),
      ),
      (
        'Target below its limit',
        o.targetBelowLimitNow
            ? 'now'
            : o.targetBelowLimitUtc == null
            ? 'not tonight'
            : inTime(o.targetBelowLimitUtc!),
      ),
      (
        'Moonrise',
        o.moonUp == true
            ? 'the Moon is up'
            : o.moonriseUtc == null
            ? 'not tonight'
            : inTime(o.moonriseUtc!),
      ),
      ('Window left', OpportunityText.duration(o.remainingWindow)),
      ('Plan left', OpportunityText.duration(o.remainingPlan)),
    ];
    final theme = Theme.of(context);
    return Card(
      key: const Key('run.outlook'),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (final (label, value) in lines)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: '$label: ',
                        style: theme.textTheme.labelLarge,
                      ),
                      TextSpan(text: value),
                    ],
                  ),
                ),
              ),
            if (o.remainingPlan > o.remainingWindow)
              Text(
                'The plan needs more time than the window has left '
                '(estimate: dither, refocus and flips not included).',
                key: const Key('run.planLonger'),
                style: TextStyle(color: AppPalette.of(context).muted),
              ),
          ],
        ),
      ),
    );
  }
}

/// The lower half: every action within one thumb's reach, 56 dp tall.
class _Controls extends StatelessWidget {
  const _Controls({required this.vm, required this.run});

  final ExecutionViewModel vm;
  final Future<void> Function(Future<void> Function()) run;

  @override
  Widget build(BuildContext context) {
    final state = vm.state!;
    final block = vm.block;
    final running = state.phase == ExecutionPhase.running;
    final estimate = vm.estimate?.frames ?? 0;
    final canMinus = block != null && state.completedFor(block.id) > 0;
    const big = Size.fromHeight(56);

    Widget button(
      String key,
      String label,
      String semantics,
      VoidCallback? onPressed, {
      bool filled = false,
      IconData? icon,
    }) {
      final child = icon == null
          ? Text(label)
          : Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon),
                const SizedBox(width: 6),
                Flexible(child: Text(label)),
              ],
            );
      return Expanded(
        child: Padding(
          padding: const EdgeInsets.all(4),
          // The label replaces the button's own semantics, so the tap action
          // and enabled state are given here, or a screen reader could not
          // press it (S1.11; UX-28).
          child: Semantics(
            button: true,
            enabled: onPressed != null,
            label: semantics,
            onTap: onPressed,
            excludeSemantics: true,
            child: filled
                ? FilledButton(
                    key: Key(key),
                    onPressed: onPressed,
                    style: FilledButton.styleFrom(minimumSize: big),
                    child: child,
                  )
                : OutlinedButton(
                    key: Key(key),
                    onPressed: onPressed,
                    style: OutlinedButton.styleFrom(minimumSize: big),
                    child: child,
                  ),
          ),
        ),
      );
    }

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(8, 4, 8, 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                button(
                  'run.minus',
                  '−1',
                  'Remove one confirmed frame',
                  canMinus ? () => run(() => vm.confirm(-1)) : null,
                ),
                button(
                  'run.plus',
                  '+1',
                  'Confirm one frame',
                  block == null ? null : () => run(() => vm.confirm(1)),
                  filled: true,
                ),
                button(
                  'run.reject',
                  'Reject',
                  'Reject one frame',
                  block == null ? null : () => run(vm.reject),
                ),
              ],
            ),
            Row(
              children: [
                button(
                  'run.accept',
                  'Accept $estimate',
                  'Accept the estimate of $estimate frames',
                  estimate > 0 ? () => run(vm.acceptEstimate) : null,
                ),
                button(
                  'run.pauseResume',
                  running ? 'Pause' : 'Resume',
                  running ? 'Pause the run' : 'Resume the run',
                  running ? () => _pauseSheet(context) : () => run(vm.resume),
                  icon: running ? Icons.pause : Icons.play_arrow,
                ),
              ],
            ),
            Row(
              children: [
                button(
                  'run.block',
                  'Block',
                  'Choose the block you are capturing',
                  () => _blockSheet(context),
                  icon: Icons.layers_outlined,
                ),
                button(
                  'run.more',
                  'More',
                  'Finish, abandon or keep the screen on',
                  () => _moreSheet(context),
                  icon: Icons.more_horiz,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pauseSheet(BuildContext context) => showModalBottomSheet<void>(
    context: context,
    builder: (sheet) => SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            key: const Key('run.pause.plain'),
            leading: const Icon(Icons.pause),
            title: const Text('Pause'),
            onTap: () {
              Navigator.of(sheet).pop();
              run(() => vm.pause());
            },
          ),
          for (final r in InterruptionReason.values)
            ListTile(
              key: Key('run.pause.${r.name}'),
              title: Text('Interrupted: ${_reasonLabel(r)}'),
              onTap: () {
                Navigator.of(sheet).pop();
                run(() => vm.pause(r));
              },
            ),
        ],
      ),
    ),
  );

  Future<void> _blockSheet(BuildContext context) => showModalBottomSheet<void>(
    context: context,
    builder: (sheet) => SafeArea(
      child: ListView(
        shrinkWrap: true,
        children: [
          for (final b in vm.session!.blocks)
            ListTile(
              key: Key('run.block.${b.id}'),
              selected: b.id == vm.block?.id,
              title: Text(_blockLabel(b)),
              subtitle: Text(
                '${vm.state!.completedFor(b.id)} of ${b.frameCount} confirmed',
              ),
              onTap: () {
                Navigator.of(sheet).pop();
                if (b.id != vm.block?.id) run(() => vm.selectBlock(b.id));
              },
            ),
        ],
      ),
    ),
  );

  Future<void> _moreSheet(BuildContext context) => showModalBottomSheet<void>(
    context: context,
    builder: (sheet) => SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          StatefulBuilder(
            builder: (context, setState) => SwitchListTile(
              key: const Key('run.keepScreenOn'),
              title: const Text('Keep the screen on while tracking'),
              value: vm.keepScreenOn,
              onChanged: (on) async {
                await runWithFeedback(
                  context,
                  'save the keep-screen-on setting',
                  () => vm.setKeepScreenOn(on),
                );
                setState(() {});
              },
            ),
          ),
          ListTile(
            key: const Key('run.finish'),
            leading: const Icon(Icons.flag_outlined),
            title: const Text('Finish'),
            subtitle: const Text('Review the counts, then complete'),
            onTap: () {
              Navigator.of(sheet).pop();
              // Owner decision (TASK 13.4): Finish opens reconciliation;
              // nothing is completed until Complete there.
              context.push(AppRouter.results(vm.session!.id));
            },
          ),
          ListTile(
            key: const Key('run.abandon'),
            leading: const Icon(Icons.close),
            title: const Text('Abandon'),
            onTap: () async {
              Navigator.of(sheet).pop();
              if (await _confirm(context, 'Abandon this session?', 'Abandon')) {
                await run(vm.abandon);
              }
            },
          ),
        ],
      ),
    ),
  );

  static Future<bool> _confirm(
    BuildContext context,
    String title,
    String action,
  ) async =>
      await showDialog<bool>(
        context: context,
        builder: (c) => AlertDialog(
          title: Text(title),
          content: const Text(
            'The confirmed counts are kept. Results and notes stay editable.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(c).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              key: Key('run.confirm.$action'),
              onPressed: () => Navigator.of(c).pop(true),
              child: Text(action),
            ),
          ],
        ),
      ) ??
      false;
}

/// After Finish or Abandon; reconciliation is TASK 13.4.
class _Ended extends StatelessWidget {
  const _Ended({required this.vm});

  final ExecutionViewModel vm;

  @override
  Widget build(BuildContext context) {
    final finished = vm.state!.phase == ExecutionPhase.finished;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              finished ? 'Session finished' : 'Session abandoned',
              key: const Key('run.ended'),
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            FilledButton(
              key: const Key('run.results'),
              onPressed: () => context.push(AppRouter.results(vm.session!.id)),
              style: FilledButton.styleFrom(minimumSize: const Size(200, 56)),
              child: const Text('Results'),
            ),
            const SizedBox(height: 8),
            OutlinedButton(
              onPressed: () => context.go(AppRouter.tonight),
              style: OutlinedButton.styleFrom(minimumSize: const Size(200, 48)),
              child: const Text('Back to Tonight'),
            ),
          ],
        ),
      ),
    );
  }
}
