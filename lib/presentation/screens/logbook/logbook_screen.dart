import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:go_router/go_router.dart';

import '../../../domain/models/calendar_date.dart';
import '../../../domain/models/session.dart';
import '../../viewmodels/library_viewmodels.dart';
import '../../shared/night_time_formatter.dart';
import '../../navigation/app_router.dart';
import '../../../domain/services/session_reconciliation.dart';
import '../execution/results_screen.dart';

/// A session's status as the Sessions list and detail show it (TASK 11.3;
/// "unsaved changes", TASK 11.4).
String sessionStatusLabel(Session s) {
  if (s.legacy) return 'Legacy log';
  return switch (s.status) {
    SessionStatus.draft =>
      s.plannedAtUtc != null ? 'Planned, unsaved changes' : 'Draft',
    SessionStatus.planned => 'Planned',
    SessionStatus.inProgress => 'In progress',
    SessionStatus.completed => 'Completed',
    SessionStatus.abandoned => 'Abandoned',
  };
}

/// Saved sessions (TASK 11.3, owner decision): every non-draft session —
/// planned, in progress, completed, abandoned — and the legacy logs, newest
/// first, each with its status. Since TASK 14.1: filters by status, target,
/// site and night date, and a tap opens the detail (owner decision).
class LogbookScreen extends StatefulWidget {
  const LogbookScreen({super.key});

  @override
  State<LogbookScreen> createState() => _LogbookScreenState();
}

class _LogbookScreenState extends State<LogbookScreen> {
  late Future<List<Session>> _sessionsFuture;
  SessionFilter _filter = const SessionFilter();
  ({Map<int, String> targets, Map<int, String> sites}) _options = (
    targets: const {},
    sites: const {},
  );

  /// Planned vs actual for completed sessions (TASK 13.4), by id.
  Map<int, SessionReconciliation> _results = const {};

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  void _refresh() {
    final sessions = context.read<SessionsViewModel>();
    setState(() {
      _sessionsFuture = sessions.saved(_filter).then((list) async {
        final results = await sessions.reconciliations(list);
        final options = await sessions.filterOptions();
        if (mounted) {
          setState(() {
            _results = results;
            _options = options;
          });
        }
        return list;
      });
    });
  }

  void _setFilter(SessionFilter f) {
    _filter = f;
    _refresh();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sessions')),
      body: Column(
        children: [
          _FilterBar(filter: _filter, options: _options, onChanged: _setFilter),
          Expanded(
            child: FutureBuilder<List<Session>>(
              future: _sessionsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(
                    child: Text(
                      _filter.isEmpty
                          ? 'No sessions saved yet.'
                          : 'No sessions match these filters.',
                      key: const Key('logbook.empty'),
                    ),
                  );
                }
                final sessions = snapshot.data!;
                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: sessions.length,
                  itemBuilder: (context, i) => _row(context, sessions[i]),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _row(BuildContext context, Session session) {
    final log = session.record;
    // The night key; a legacy instant maps to its device-local calendar
    // date, as it was shown before (ADR-007 §10).
    final evening =
        session.eveningDate ??
        CalendarDate.fromDateTimeFields(log.sessionDate.toLocal());
    return Dismissible(
      key: ValueKey(session.id),
      direction: DismissDirection.endToStart,
      background: Container(
        color: Theme.of(context).colorScheme.error,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: Icon(Icons.delete, color: Theme.of(context).colorScheme.onError),
      ),
      confirmDismiss: (direction) async {
        return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Delete Session?'),
            content: Text(
              'Are you sure you want to delete "${log.targetName}"?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Delete'),
              ),
            ],
          ),
        );
      },
      onDismissed: (_) async {
        await context.read<SessionsViewModel>().delete(session.id);
        _refresh();
      },
      child: Card(
        margin: const EdgeInsets.only(bottom: 16),
        child: ListTile(
          contentPadding: const EdgeInsets.all(16.0),
          onTap: () async {
            // TASK 14.1 (owner): the detail; the planner opens from there.
            await context.push(AppRouter.sessionDetail(session.id));
            if (mounted) _refresh();
          },
          title: Text(
            '${NightTimeFormatter.eveningDate(evening)} - ${log.targetName}',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              Row(
                children: [
                  Flexible(
                    child: Text(
                      sessionStatusLabel(session),
                      key: Key('logbook.status.${session.id}'),
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                  if (session.legacy) ...[
                    const SizedBox(width: 8),
                    Chip(
                      key: Key('logbook.legacy.${session.id}'),
                      label: const Text('Legacy'),
                      visualDensity: VisualDensity.compact,
                    ),
                  ],
                ],
              ),
              Text('Equipment: ${log.equipmentName}'),
              if (log.locationName case final site?) Text('Site: $site'),
              Text('Planned Frames: ${log.plannedLightFrames}'),
              if (log.actualLightFrames != null)
                Text('Actual Frames: ${log.actualLightFrames}'),
              // TASK 13.4 (owner): planned vs actual integration and
              // corrections for a completed session.
              if (_results[session.id] case final r?) ...[
                Text(
                  ResultsText.integration(r),
                  key: Key('logbook.integration.${session.id}'),
                ),
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton(
                    key: Key('logbook.editResults.${session.id}'),
                    onPressed: () async {
                      await context.push(AppRouter.results(session.id));
                      if (mounted) _refresh();
                    },
                    child: const Text('Edit results'),
                  ),
                ),
              ],
              if (log.rejectedFrames != null && log.rejectedFrames! > 0)
                Text(
                  'Rejected Frames: ${log.rejectedFrames}',
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
            ],
          ),
          trailing: IconButton(
            icon: const Icon(Icons.share),
            tooltip: 'Share',
            onPressed: () {
              SharePlus.instance.share(
                ShareParams(text: log.toShareableText()),
              );
            },
          ),
        ),
      ),
    );
  }
}

/// Status chips, target and site pickers and a night date range
/// (TASK 14.1). Empty filters mean "all".
class _FilterBar extends StatelessWidget {
  const _FilterBar({
    required this.filter,
    required this.options,
    required this.onChanged,
  });

  final SessionFilter filter;
  final ({Map<int, String> targets, Map<int, String> sites}) options;
  final ValueChanged<SessionFilter> onChanged;

  static const _statusLabels = {
    SessionListStatus.planned: 'Planned',
    SessionListStatus.inProgress: 'In progress',
    SessionListStatus.completed: 'Completed',
    SessionListStatus.abandoned: 'Abandoned',
  };

  SessionFilter _copy({
    Set<SessionListStatus>? statuses,
    int? Function()? targetId,
    int? Function()? siteId,
    (CalendarDate?, CalendarDate?)? range,
  }) => SessionFilter(
    statuses: statuses ?? filter.statuses,
    targetId: targetId == null ? filter.targetId : targetId(),
    siteId: siteId == null ? filter.siteId : siteId(),
    from: range == null ? filter.from : range.$1,
    to: range == null ? filter.to : range.$2,
  );

  Future<int?> _pick(
    BuildContext context,
    String title,
    Map<int, String> choices,
  ) => showModalBottomSheet<int?>(
    context: context,
    builder: (sheet) => SafeArea(
      child: ListView(
        shrinkWrap: true,
        children: [
          ListTile(title: Text(title), enabled: false),
          ListTile(
            key: const Key('logbook.pick.all'),
            title: const Text('All'),
            onTap: () => Navigator.of(sheet).pop(-1),
          ),
          for (final MapEntry(:key, :value) in choices.entries)
            ListTile(
              key: Key('logbook.pick.$key'),
              title: Text(value),
              onTap: () => Navigator.of(sheet).pop(key),
            ),
        ],
      ),
    ),
  );

  @override
  Widget build(BuildContext context) {
    final f = filter;
    String dates() {
      if (f.from == null && f.to == null) return 'Any night';
      final a = f.from == null ? '…' : NightTimeFormatter.eveningDate(f.from!);
      final b = f.to == null ? '…' : NightTimeFormatter.eveningDate(f.to!);
      return '$a – $b';
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: Wrap(
        spacing: 8,
        runSpacing: 4,
        children: [
          for (final MapEntry(:key, :value) in _statusLabels.entries)
            FilterChip(
              key: Key('logbook.filter.${key.name}'),
              label: Text(value),
              selected: f.statuses.contains(key),
              onSelected: (on) => onChanged(
                _copy(
                  statuses: on
                      ? {...f.statuses, key}
                      : ({...f.statuses}..remove(key)),
                ),
              ),
            ),
          ActionChip(
            key: const Key('logbook.filter.target'),
            label: Text(
              'Target: ${f.targetId == null ? 'all' : options.targets[f.targetId] ?? 'selected'}',
            ),
            onPressed: () async {
              final id = await _pick(context, 'Target', options.targets);
              if (id != null) {
                onChanged(_copy(targetId: () => id < 0 ? null : id));
              }
            },
          ),
          ActionChip(
            key: const Key('logbook.filter.site'),
            label: Text(
              'Site: ${f.siteId == null ? 'all' : options.sites[f.siteId] ?? 'selected'}',
            ),
            onPressed: () async {
              final id = await _pick(context, 'Site', options.sites);
              if (id != null) {
                onChanged(_copy(siteId: () => id < 0 ? null : id));
              }
            },
          ),
          ActionChip(
            key: const Key('logbook.filter.dates'),
            label: Text(dates()),
            onPressed: () async {
              final now = DateTime.now();
              final range = await showDateRangePicker(
                context: context,
                firstDate: DateTime(2000),
                lastDate: DateTime(now.year + 5),
                helpText: 'Nights from – to',
              );
              if (range != null) {
                onChanged(
                  _copy(
                    range: (
                      CalendarDate.fromDateTimeFields(range.start),
                      CalendarDate.fromDateTimeFields(range.end),
                    ),
                  ),
                );
              }
            },
          ),
          if (!f.isEmpty)
            ActionChip(
              key: const Key('logbook.filter.clear'),
              label: const Text('Clear filters'),
              onPressed: () => onChanged(const SessionFilter()),
            ),
        ],
      ),
    );
  }
}
