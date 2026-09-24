import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../domain/models/capture_block.dart';
import '../../../domain/services/session_reconciliation.dart';
import '../../navigation/app_router.dart';
import '../../shared/opportunity_text.dart';
import '../../viewmodels/execution_viewmodel.dart';
import '../../viewmodels/results_viewmodel.dart';

/// Reconciliation (TASK 13.4): turn a run into a log entry. Counts per
/// block (each change is a stored, timestamped event), notes, optional
/// conditions and planned vs actual. While in progress it ends with
/// Complete or Abandon; afterwards it saves corrections.
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
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  /// Pre-fills the fields once from the stored results.
  void _fill(ResultsViewModel vm) {
    final log = vm.session?.record;
    if (_filled || log == null) return;
    _filled = true;
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

  static String? _optional(String text) =>
      text.trim().isEmpty ? null : text.trim();

  Future<void> _save(ResultsViewModel vm) async {
    if (!(_form.currentState?.validate() ?? false)) return;
    final completing = vm.inProgress;
    final execution = context.read<ExecutionViewModel?>();
    await vm.save(
      environmentalNotes: _optional(_environment.text),
      processingNotes: _optional(_processing.text),
      temperatureC: _number(_temperature.text),
      humidityPct: _number(_humidity.text),
      cloudCoverPct: _number(_cloud.text)?.round(),
    );
    await execution?.loadActive();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(completing ? 'Session completed.' : 'Results saved.'),
      ),
    );
    context.go(AppRouter.sessions);
  }

  Future<void> _abandon(ResultsViewModel vm) async {
    final sure = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('Abandon this session?'),
        content: const Text(
          'It stays in Sessions as abandoned; the confirmed counts are kept.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(c).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            key: const Key('results.confirmAbandon'),
            onPressed: () => Navigator.of(c).pop(true),
            child: const Text('Abandon'),
          ),
        ],
      ),
    );
    if (sure != true || !mounted) return;
    final execution = context.read<ExecutionViewModel?>();
    await vm.abandon();
    await execution?.loadActive();
    if (mounted) context.go(AppRouter.sessions);
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ResultsViewModel?>();
    final session = vm?.session;
    final r = vm?.reconciliation;
    if (vm == null ||
        session == null ||
        r == null ||
        session.id != widget.sessionId) {
      return Scaffold(
        appBar: AppBar(title: const Text('Results')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }
    _fill(vm);
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: Text('Results · ${session.record.targetName}')),
      body: Form(
        key: _form,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _Summary(reconciliation: r),
            const SizedBox(height: 12),
            Text('Frames per block', style: theme.textTheme.titleMedium),
            if (!vm.inProgress && vm.countsEditable)
              Text(
                'Corrections are stored with the time they were made.',
                style: theme.textTheme.bodySmall,
              ),
            for (final b in r.blocks)
              _BlockCounts(
                block: b,
                enabled: vm.countsEditable,
                onConfirmed: (d) => vm.adjust(b.block.id, d),
                onRejected: (d) => vm.adjust(b.block.id, d, rejected: true),
              ),
            const SizedBox(height: 12),
            Text('Notes', style: theme.textTheme.titleMedium),
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
              decoration: const InputDecoration(labelText: 'Processing notes'),
              maxLines: 3,
              minLines: 1,
            ),
            const SizedBox(height: 12),
            Text('Conditions (optional)', style: theme.textTheme.titleMedium),
            TextFormField(
              key: const Key('results.temperature'),
              controller: _temperature,
              decoration: const InputDecoration(labelText: 'Temperature (°C)'),
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
            const SizedBox(height: 24),
            FilledButton(
              key: const Key('results.save'),
              onPressed: () => _save(vm),
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(56),
              ),
              child: Text(vm.inProgress ? 'Complete session' : 'Save results'),
            ),
            if (vm.inProgress) ...[
              const SizedBox(height: 8),
              OutlinedButton(
                key: const Key('results.abandon'),
                onPressed: () => _abandon(vm),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(48),
                ),
                child: const Text('Abandon session'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Planned vs actual light integration (CALC-37).
class _Summary extends StatelessWidget {
  const _Summary({required this.reconciliation});

  final SessionReconciliation reconciliation;

  @override
  Widget build(BuildContext context) {
    final r = reconciliation;
    final fraction = r.fraction;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              ResultsText.integration(r),
              key: const Key('results.summary'),
              style: Theme.of(context).textTheme.titleMedium,
            ),
            if (fraction != null)
              Text('${(fraction * 100).round()} % of the plan'),
            Text(
              '${r.actualLightFrames} light frames confirmed'
              '${r.rejectedLightFrames > 0 ? ', ${r.rejectedLightFrames} rejected' : ''}',
            ),
          ],
        ),
      ),
    );
  }
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

class _BlockCounts extends StatelessWidget {
  const _BlockCounts({
    required this.block,
    required this.enabled,
    required this.onConfirmed,
    required this.onRejected,
  });

  final BlockReconciliation block;
  final bool enabled;
  final ValueChanged<int> onConfirmed;
  final ValueChanged<int> onRejected;

  @override
  Widget build(BuildContext context) {
    final b = block.block;
    final label =
        '${b.filterName ?? _type(b.frameType)} · ${b.exposureTimeSeconds.round()} s';
    Widget stepper(String name, String key, int value, ValueChanged<int> on) =>
        Row(
          children: [
            Expanded(child: Text('$name: $value', key: Key('$key.${b.id}'))),
            IconButton(
              key: Key('$key.minus.${b.id}'),
              tooltip: '$name minus one',
              onPressed: enabled && value > 0 ? () => on(-1) : null,
              icon: const Icon(Icons.remove_circle_outline),
            ),
            IconButton(
              key: Key('$key.plus.${b.id}'),
              tooltip: '$name plus one',
              onPressed: enabled ? () => on(1) : null,
              icon: const Icon(Icons.add_circle_outline),
            ),
          ],
        );
    return Card(
      margin: const EdgeInsets.only(top: 8),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 8, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('$label · ${block.planned} planned'),
            stepper(
              'Confirmed',
              'results.confirmed',
              block.confirmed,
              onConfirmed,
            ),
            stepper('Rejected', 'results.rejected', block.rejected, onRejected),
          ],
        ),
      ),
    );
  }

  static String _type(FrameType t) => switch (t) {
    FrameType.light => 'Light',
    FrameType.dark => 'Darks',
    FrameType.flat => 'Flats',
    FrameType.bias => 'Bias',
  };
}
