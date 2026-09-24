import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../domain/services/target_progress.dart';
import '../../shared/night_time_formatter.dart';
import '../../shared/opportunity_text.dart';
import '../../viewmodels/library_viewmodels.dart';
import '../../shared/failure_feedback.dart';

/// Integration so far per target, across nights (TASK 14.2, CALC-38):
/// completed sessions only, confirmed light frames × exposure, per filter,
/// last imaged night and the number of sessions. No goals (out of scope).
class ProgressScreen extends StatefulWidget {
  const ProgressScreen({super.key});

  @override
  State<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen> {
  late final Future<List<TargetProgress>> _progress = context
      .read<SessionsViewModel>()
      .targetProgress();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Progress')),
      body: FutureBuilder<List<TargetProgress>>(
        future: _progress,
        builder: (context, snapshot) {
          final list = snapshot.data;
          if (snapshot.error case final error?) {
            return LoadFailureView(action: 'load the progress', error: error);
          }
          if (list == null) {
            return const Center(child: CircularProgressIndicator());
          }
          if (list.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text(
                  'No completed sessions yet. Integration adds up here once '
                  'you complete a tracked session.',
                  key: Key('progress.empty'),
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [for (final p in list) TargetProgressCard(progress: p)],
          );
        },
      ),
    );
  }
}

/// One target's progress; also shown on a session's detail.
class TargetProgressCard extends StatelessWidget {
  const TargetProgressCard({super.key, required this.progress});

  final TargetProgress progress;

  @override
  Widget build(BuildContext context) {
    final p = progress;
    final theme = Theme.of(context);
    final night = p.lastNight;
    return Card(
      key: Key('progress.${p.targetId}'),
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(p.label, style: theme.textTheme.titleMedium),
            Text(
              '${OpportunityText.duration(p.integration)} over '
              '${p.sessionCount} ${p.sessionCount == 1 ? 'session' : 'sessions'}',
              key: Key('progress.total.${p.targetId}'),
              style: theme.textTheme.titleSmall,
            ),
            if (night != null)
              Text('Last imaged: ${NightTimeFormatter.eveningDate(night)}'),
            for (final MapEntry(:key, :value) in p.perFilter.entries)
              Text('$key: ${OpportunityText.duration(value)}'),
          ],
        ),
      ),
    );
  }
}
