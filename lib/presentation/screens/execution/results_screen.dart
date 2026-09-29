import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/quantity_text.dart';
import '../../../domain/models/capture_block.dart';
import '../../../domain/models/session_result.dart';
import '../../../domain/services/session_reconciliation.dart';
import '../../navigation/app_router.dart';
import '../../shared/app_words.dart';
import '../../shared/failure_feedback.dart';
import '../../shared/night_time_formatter.dart';
import '../../shared/opportunity_text.dart';
import '../../shared/plan_state.dart';
import '../../viewmodels/execution_viewmodel.dart';
import '../../viewmodels/results_viewmodel.dart';

/// "How did it go?" (S8.2; ADR-019 §3.1, §4): review the saved plan, then
/// Completed as planned · Partly (a number per light block, not ±1; UX-25)
/// · Not done (an optional reason), with optional notes and conditions, and
/// Save result. Back writes nothing. It never asks about the planner's plan.
class ResultsScreen extends StatefulWidget {
  const ResultsScreen({super.key, required this.sessionId});

  final int sessionId;

  @override
  State<ResultsScreen> createState() => _ResultsScreenState();
}

class _ResultsScreenState extends State<ResultsScreen> {
  final _form = GlobalKey<FormState>();
  final _environment = TextEditingController();
  final _processing = TextEditingController();
  final _temperature = TextEditingController();
  final _humidity = TextEditingController();
  final _cloud = TextEditingController();
  final _counts = <int, TextEditingController>{};
  ResultOutcome? _outcome;
  NotDoneReason? _reason;
  bool _filled = false;

  @override
  void initState() {
    super.initState();
    context.read<ResultsViewModel?>()?.load(widget.sessionId);
  }

  @override
  void dispose() {
    for (final c in [
      _environment,
      _processing,
      _temperature,
      _humidity,
      _cloud,
      ..._counts.values,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  /// Pre-fills the form once from the stored entry: its outcome and reason,
  /// the counts (a run's confirmed counts, else the plan's), notes and
  /// conditions.
  void _fill(ResultsViewModel vm) {
    final s = vm.session;
    if (_filled || s == null) return;
    _filled = true;
    final log = s.record;
    _outcome = vm.onlyNotDone ? ResultOutcome.notDone : vm.storedOutcome;
    _reason = s.notDoneReason;
    final counted = vm.storedOutcome != null;
    for (final b in vm.lightBlocks) {
      (_counts[b.id] ??= TextEditingController()).text =
          '${counted ? vm.confirmedFor(b.id) : b.frameCount}';
    }
    _environment.text = log.environmentalNotes ?? '';
    _processing.text = log.processingNotes ?? '';
    _temperature.text = _text(log.temperature);
    _humidity.text = _text(log.humidity);
    _cloud.text = log.cloudCover?.toString() ?? '';
  }

  static String _text(double? v) => v == null
      ? ''
      : (v == v.roundToDouble() ? v.round().toString() : v.toString());

  static double? _number(String text) =>
      double.tryParse(text.trim().replaceAll(',', '.'));

  static String? Function(String?) _range(
    double min,
    double max,
    String unit,
  ) => (text) {
    if (text == null || text.trim().isEmpty) return null; // optional
    final v = _number(text);
    if (v == null) return 'Enter a number, or leave it empty.';
    if (v < min || v > max) {
      return 'Between ${min.round()} and ${max.round()} $unit.';
    }
    return null;
  };

  static String? _frames(String? text) {
    final v = int.tryParse(text?.trim() ?? '');
    if (v == null || v < 0) return 'Enter the frames you took (0 or more).';
    if (v > 100000) return 'At most 100,000 frames.';
    return null;
  }

  static String? _optional(String text) =>
      text.trim().isEmpty ? null : text.trim();

  ResultReport? _report() {
    final notes = ResultNotes(
      environmentalNotes: _optional(_environment.text),
      processingNotes: _optional(_processing.text),
      temperatureC: _number(_temperature.text),
      humidityPct: _number(_humidity.text),
      cloudCoverPct: _number(_cloud.text)?.round(),
    );
    return switch (_outcome) {
      null => null,
      ResultOutcome.asPlanned => CompletedAsPlanned(notes: notes),
      ResultOutcome.partly => PartlyDone({
        for (final e in _counts.entries) e.key: int.parse(e.value.text.trim()),
      }, notes: notes),
      ResultOutcome.notDone => NotDone(reason: _reason, notes: notes),
    };
  }

  Future<void> _save(ResultsViewModel vm) async {
    if (!(_form.currentState?.validate() ?? false)) return;
    final report = _report();
    if (report == null) return;
    final execution = context.read<ExecutionViewModel?>();
    final saved = await runWithFeedback(
      context,
      'save the result',
      () => vm.save(report),
    );
    if (!mounted) return;
    if (!saved) {
      // A stale form was reloaded: show the entry as it is now.
      setState(() => _filled = false);
      return;
    }
    await execution?.loadActive();
    if (!mounted) return;
    showDone(context, 'Result saved.');
    context.go(AppRouter.sessions);
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ResultsViewModel?>();
    final session = vm?.session;
    if (vm == null || session == null || session.id != widget.sessionId) {
      return Scaffold(
        appBar: AppBar(title: const Text('How did it go?')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }
    _fill(vm);
    final theme = Theme.of(context);
    final gap = const SizedBox(height: AppSpacing.md);
    return Scaffold(
      appBar: AppBar(title: const Text('How did it go?')),
      body: Form(
        key: _form,
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.md),
          children: [
            _Review(vm: vm),
            gap,
            if (!vm.canRecord)
              _NotYet(vm: vm)
            else ...[
              if (vm.storedOutcome != null && vm.reconciliation != null)
                _SoFar(reconciliation: vm.reconciliation!),
              Text('How did it go?', style: theme.textTheme.titleMedium),
              _Outcomes(
                selected: _outcome,
                onlyNotDone: vm.onlyNotDone,
                onSelected: (o) => setState(() => _outcome = o),
              ),
              if (_outcome == ResultOutcome.asPlanned)
                Text(
                  'Every light block as planned, reported by you.',
                  key: const Key('results.asPlannedNote'),
                  style: theme.textTheme.bodySmall,
                ),
              if (_outcome == ResultOutcome.partly)
                for (final b in vm.lightBlocks)
                  TextFormField(
                    key: Key('results.count.${b.id}'),
                    controller: _counts[b.id],
                    decoration: InputDecoration(
                      labelText: '${_label(b)} · light frames',
                      helperText: '${b.frameCount} planned',
                    ),
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    validator: _frames,
                  ),
              if (_outcome == ResultOutcome.notDone)
                _Reasons(
                  selected: _reason,
                  onSelected: (r) => setState(() => _reason = r),
                ),
              gap,
              Text('Notes (optional)', style: theme.textTheme.titleMedium),
              TextFormField(
                key: const Key('results.environment'),
                controller: _environment,
                decoration: const InputDecoration(
                  labelText: 'Conditions and events',
                ),
                maxLines: 3,
                minLines: 1,
              ),
              TextFormField(
                key: const Key('results.processing'),
                controller: _processing,
                decoration: const InputDecoration(
                  labelText: 'Processing notes',
                ),
                maxLines: 3,
                minLines: 1,
              ),
              gap,
              Text('Conditions (optional)', style: theme.textTheme.titleMedium),
              TextFormField(
                key: const Key('results.temperature'),
                controller: _temperature,
                decoration: const InputDecoration(
                  labelText: 'Temperature (°C)',
                ),
                keyboardType: const TextInputType.numberWithOptions(
                  signed: true,
                  decimal: true,
                ),
                validator: _range(-60, 60, '°C'),
              ),
              TextFormField(
                key: const Key('results.humidity'),
                controller: _humidity,
                decoration: const InputDecoration(
                  labelText: 'Relative humidity (%)',
                ),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                validator: _range(0, 100, '%'),
              ),
              TextFormField(
                key: const Key('results.cloud'),
                controller: _cloud,
                decoration: const InputDecoration(labelText: 'Cloud cover (%)'),
                keyboardType: TextInputType.number,
                validator: _range(0, 100, '%'),
              ),
              const SizedBox(height: AppSpacing.xl),
              FilledButton(
                key: const Key('results.save'),
                onPressed: _outcome == null ? null : () => _save(vm),
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(56),
                ),
                child: const Text('Save result'),
              ),
            ],
          ],
        ),
      ),
    );
  }

  static String _label(CaptureBlock b) =>
      '${b.filterName ?? 'Light'} · ${QuantityText.exposure(b.exposureTimeSeconds)}';
}

/// The saved plan under review (ADR-019 §3.1): the snapshot's night, target,
/// site and rig, and the planned light blocks. What it lacks is unavailable,
/// never filled from today's site or rig (SI-008).
class _Review extends StatelessWidget {
  const _Review({required this.vm});

  final ResultsViewModel vm;

  @override
  Widget build(BuildContext context) {
    final s = vm.session!;
    final snap = vm.review;
    final theme = Theme.of(context);
    final night = snap?.eveningDate ?? s.eveningDate;
    String row(String name, String? value) => '$name: ${value ?? 'unknown'}';
    return Card(
      key: const Key('results.review'),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.xs,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Text('Saved plan', style: theme.textTheme.titleMedium),
                PlanStateLabel(
                  PlanState.of(s),
                  key: const Key('results.state'),
                ),
              ],
            ),
            if (snap == null)
              Text(
                "The saved plan's details can't be read.",
                key: const Key('results.reviewUnavailable'),
                style: theme.textTheme.bodySmall,
              ),
            Text(
              row(
                AppWords.night,
                night == null ? null : NightTimeFormatter.eveningDate(night),
              ),
            ),
            Text(row('Target', snap?.targetName ?? s.record.targetName)),
            Text(row(AppWords.site, snap?.siteName)),
            Text(row(AppWords.rig, snap?.rigName)),
            for (final b in vm.lightBlocks)
              Text(
                '${_ResultsScreenState._label(b)} · ${b.frameCount} planned',
                key: Key('results.planned.${b.id}'),
              ),
          ],
        ),
      ),
    );
  }
}

/// A saved night that has not ended: no result yet (ADR-019 §3.1; D8-1).
class _NotYet extends StatelessWidget {
  const _NotYet({required this.vm});

  final ResultsViewModel vm;

  @override
  Widget build(BuildContext context) {
    final end = vm.endsAt;
    final zone = vm.review?.timeZoneId ?? vm.session?.timeZoneId;
    final when = end == null
        ? 'after its night'
        : 'after its night ends, from '
              '${NightTimeFormatter.clockTime(context, end, zoneId: zone)} '
              '(${NightTimeFormatter.zoneCaption(end, zoneId: zone)})';
    return Text(
      "This night hasn't ended yet. You can record how it went $when.",
      key: const Key('results.notYet'),
    );
  }
}

/// Planned vs actual so far (CALC-37), for a run or a result being edited.
class _SoFar extends StatelessWidget {
  const _SoFar({required this.reconciliation});

  final SessionReconciliation reconciliation;

  @override
  Widget build(BuildContext context) {
    final r = reconciliation;
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(ResultsText.integration(r), key: const Key('results.summary')),
          if (r.rejectedLightFrames > 0)
            Text(
              '${r.rejectedLightFrames} light frames rejected earlier',
              key: const Key('results.rejected'),
            ),
        ],
      ),
    );
  }
}

class _Outcomes extends StatelessWidget {
  const _Outcomes({
    required this.selected,
    required this.onlyNotDone,
    required this.onSelected,
  });

  final ResultOutcome? selected;
  final bool onlyNotDone;
  final ValueChanged<ResultOutcome> onSelected;

  @override
  Widget build(BuildContext context) {
    Widget chip(ResultOutcome o, String label) => ChoiceChip(
      key: Key('results.outcome.${o.name}'),
      label: Text(label),
      selected: selected == o,
      onSelected: onlyNotDone && o != ResultOutcome.notDone
          ? null
          : (_) => onSelected(o),
    );
    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.xs,
      children: [
        chip(ResultOutcome.asPlanned, AppWords.completedAsPlanned),
        chip(ResultOutcome.partly, AppWords.partly),
        chip(ResultOutcome.notDone, AppWords.notDone),
      ],
    );
  }
}

/// Not done's optional reason (ADR-019 §4); tapping the chosen one clears it.
class _Reasons extends StatelessWidget {
  const _Reasons({required this.selected, required this.onSelected});

  final NotDoneReason? selected;
  final ValueChanged<NotDoneReason?> onSelected;

  static String _word(NotDoneReason r) => switch (r) {
    NotDoneReason.clouds => 'Clouds',
    NotDoneReason.wind => 'Wind',
    NotDoneReason.dew => 'Dew',
    NotDoneReason.equipment => 'Equipment',
    NotDoneReason.other => 'Other',
  };

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      Text('Why? (optional)', style: Theme.of(context).textTheme.bodySmall),
      Wrap(
        spacing: AppSpacing.sm,
        runSpacing: AppSpacing.xs,
        children: [
          for (final r in NotDoneReason.values)
            ChoiceChip(
              key: Key('results.reason.${r.name}'),
              label: Text(_word(r)),
              selected: selected == r,
              onSelected: (on) => onSelected(on ? r : null),
            ),
        ],
      ),
    ],
  );
}

/// Wording for planned vs actual, shared with the Sessions list.
abstract final class ResultsText {
  static String integration(SessionReconciliation r) =>
      'Integration: ${integrationValue(r)}';

  /// "1 h 40 min of 2 h planned".
  static String integrationValue(SessionReconciliation r) =>
      '${OpportunityText.duration(r.actualIntegration)} of '
      '${OpportunityText.duration(r.plannedIntegration)} planned';
}
