import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../domain/models/calendar_date.dart';
import '../../../domain/models/session.dart';
import '../../../domain/services/result_action.dart';
import '../../../domain/services/session_reconciliation.dart';
import '../../navigation/app_router.dart';
import '../../shared/app_words.dart';
import '../../shared/confirmation_patterns.dart';
import '../../shared/delete_patterns.dart';
import '../../shared/entry_share_text.dart';
import '../../shared/failure_feedback.dart';
import '../../shared/night_time_formatter.dart';
import '../../shared/plan_state.dart';
import '../../viewmodels/library_viewmodels.dart';
import '../execution/results_screen.dart';

/// An entry's identity (S8.5–S8.6; RD-14): its name when it has one, else
/// its target and night, "M42 · Mon, Dec 15" ([targetAndNight]).
String entryTitle(Session s) => s.name ?? targetAndNight(s);

/// "M42 · Mon, Dec 15": the target and the night (a legacy row's stored
/// date, on the device's calendar).
String targetAndNight(Session s) {
  final night =
      s.eveningDate ??
      CalendarDate.fromDateTimeFields(s.record.sessionDate.toLocal());
  return '${s.record.targetName} · ${NightTimeFormatter.eveningDate(night)}';
}

/// Deletes [s] after the shared confirmation (S5.8; RD-09 S1): a stored
/// record. Returns whether it was deleted.
Future<bool> deleteEntry(BuildContext context, Session s) async {
  final sure = await confirmDestructive(
    context,
    title: 'Delete this entry?',
    message:
        '"${entryTitle(s)}" and its result are deleted from the '
        'Logbook. This can\'t be undone.',
  );
  if (!sure || !context.mounted) return false;
  final sessions = context.read<SessionsViewModel>();
  final deleted = await runWithFeedback(
    context,
    'delete the entry',
    () => sessions.delete(s.id),
  );
  if (deleted && context.mounted) showDone(context, 'Entry deleted');
  return deleted;
}

/// The Logbook (S8.5; ADR-019 §2, §8, §10; 08 §24): saved plans and their
/// results. Upcoming (saved plans whose night has not ended) and Past; a
/// search over the target, the site and the notes; the status, target, site
/// and night filters behind one Filters button (UX-30), kept by the
/// ViewModel so they survive navigation; Progress by target (RD-07). A tap
/// opens the entry; a swipe or the entry's Delete deletes, after a
/// confirmation.
class LogbookScreen extends StatefulWidget {
  const LogbookScreen({super.key});

  @override
  State<LogbookScreen> createState() => _LogbookScreenState();
}

class _LogbookScreenState extends State<LogbookScreen> {
  late Future<List<Session>> _sessionsFuture;
  final _search = TextEditingController();
  bool _searching = false;

  /// The ViewModel's [SessionsViewModel.revision] this list was read at.
  int _seen = 0;
  ({Map<int, String> targets, Map<int, String> sites}) _options = (
    targets: const {},
    sites: const {},
  );

  /// Planned vs actual for completed sessions (TASK 13.4), by id.
  Map<int, SessionReconciliation> _results = const {};

  @override
  void initState() {
    super.initState();
    final vm = context.read<SessionsViewModel>();
    _search.text = vm.query;
    _searching = vm.query.isNotEmpty;
    _seen = vm.revision;
    _refresh();
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  void _refresh() {
    final sessions = context.read<SessionsViewModel>();
    setState(() {
      _sessionsFuture = sessions.saved(sessions.filter).then((list) async {
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
    context.read<SessionsViewModel>().setFilter(f);
    _refresh();
  }

  void _toggleSearch(SessionsViewModel vm) {
    setState(() => _searching = !_searching);
    if (!_searching) {
      _search.clear();
      vm.setQuery('');
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<SessionsViewModel>();
    if (vm.revision != _seen) {
      // An entry changed elsewhere (a name, a result): read them again.
      _seen = vm.revision;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _refresh();
      });
    }
    final count = vm.filter.count;
    return Scaffold(
      appBar: AppBar(
        title: _searching
            ? TextField(
                key: const Key('logbook.search'),
                controller: _search,
                autofocus: true,
                decoration: const InputDecoration(
                  hintText: 'Search name, target, site or notes',
                  border: InputBorder.none,
                ),
                onChanged: vm.setQuery,
              )
            : const Text(AppWords.logbook),
        actions: [
          IconButton(
            key: const Key('logbook.searchToggle'),
            tooltip: _searching ? 'Close search' : 'Search',
            icon: Icon(_searching ? Icons.close : Icons.search),
            onPressed: () => _toggleSearch(vm),
          ),
          IconButton(
            key: const Key('logbook.filters'),
            tooltip: count == 0 ? 'Filters' : 'Filters, $count on',
            icon: Badge(
              isLabelVisible: count > 0,
              label: Text('$count'),
              child: const Icon(Icons.filter_list),
            ),
            onPressed: () => _FilterPanel.show(
              context,
              options: _options,
              onChanged: _setFilter,
            ),
          ),
          // TASK 14.3 (owner): every saved entry in one manifest file.
          if (vm.canExport)
            IconButton(
              key: const Key('logbook.exportAll'),
              tooltip: AppWords.exportAllAsFile,
              icon: const Icon(Icons.file_download_outlined),
              onPressed: () =>
                  runWithFeedback(context, 'export the Logbook', vm.exportAll),
            ),
        ],
      ),
      body: FutureBuilder<List<Session>>(
        future: _sessionsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.error case final error?) {
            return LoadFailureView(
              action: 'load the Logbook',
              error: error,
              onRetry: _refresh,
            );
          }
          final all = snapshot.data ?? const <Session>[];
          final groups = vm.grouped(vm.searched(all));
          final narrowed = !vm.filter.isEmpty || vm.query.trim().isNotEmpty;
          return ListView(
            padding: const EdgeInsets.all(AppSpacing.md),
            children: [
              ListTile(
                key: const Key('logbook.progress'),
                leading: const Icon(Icons.stacked_line_chart),
                title: const Text(AppWords.progressByTarget),
                subtitle: const Text('Integration so far, from your results'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.push(AppRouter.logbookProgress),
              ),
              if (count > 0)
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton.icon(
                    key: const Key('logbook.filter.clear'),
                    onPressed: () => _setFilter(const SessionFilter()),
                    icon: const Icon(Icons.filter_list_off),
                    label: Text(
                      '$count ${count == 1 ? 'filter' : 'filters'} on · Clear',
                    ),
                  ),
                ),
              if (groups.upcoming.isEmpty && groups.past.isEmpty)
                Padding(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: Text(
                    narrowed
                        ? 'Nothing matches the search or the filters.'
                        : 'Nothing saved yet. Plans you save appear here, '
                              'and their results once you record them.',
                    key: const Key('logbook.empty'),
                    textAlign: TextAlign.center,
                  ),
                ),
              if (groups.upcoming.isNotEmpty) ...[
                const _GroupHeader('Upcoming', key: Key('logbook.upcoming')),
                for (final s in groups.upcoming) _row(context, vm, s),
              ],
              if (groups.past.isNotEmpty) ...[
                const _GroupHeader('Past', key: Key('logbook.past')),
                for (final s in groups.past) _row(context, vm, s),
              ],
            ],
          );
        },
      ),
    );
  }

  Widget _row(BuildContext context, SessionsViewModel vm, Session session) {
    final log = session.record;
    final action = vm.resultAction(session);
    final record = action == ResultAction.record;
    final details = [
      if (session.name != null) targetAndNight(session),
      log.equipmentName,
      ?log.locationName,
    ].join(' · ');
    return SwipeToDelete(
      itemKey: ValueKey('logbook_${session.id}'),
      onDelete: () async {
        if (await deleteEntry(context, session) && mounted) _refresh();
      },
      child: Card(
        margin: const EdgeInsets.only(bottom: AppSpacing.sm),
        child: ListTile(
          onTap: () async {
            // TASK 14.1 (owner): the entry; the planner opens from there.
            await context.push(AppRouter.sessionDetail(session.id));
            if (mounted) _refresh();
          },
          title: Text(
            entryTitle(session),
            key: Key('logbook.title.${session.id}'),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: AppSpacing.xs),
              PlanStateLabel(
                PlanState.of(session),
                key: Key('logbook.status.${session.id}'),
              ),
              Text(details),
              // TASK 13.4 (owner): planned vs actual for a result.
              if (_results[session.id] case final r?)
                Text(
                  ResultsText.integration(r),
                  key: Key('logbook.integration.${session.id}'),
                ),
              // S8.2 (I-6): Record result once the saved night has ended;
              // Edit result for a result.
              if (action != ResultAction.none)
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton(
                    key: Key(
                      '${record ? 'logbook.recordResult' : 'logbook.editResults'}'
                      '.${session.id}',
                    ),
                    onPressed: () async {
                      await context.push(AppRouter.results(session.id));
                      if (mounted) _refresh();
                    },
                    child: Text(
                      record ? AppWords.recordResult : AppWords.editResult,
                    ),
                  ),
                ),
            ],
          ),
          trailing: IconButton(
            icon: const Icon(Icons.share),
            tooltip: 'Share',
            onPressed: () => SharePlus.instance.share(
              ShareParams(
                text: EntryShareText.of(
                  session,
                  reconciliation: _results[session.id],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _GroupHeader extends StatelessWidget {
  const _GroupHeader(this.title, {super.key});

  final String title;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(0, AppSpacing.md, 0, AppSpacing.sm),
    child: Semantics(
      header: true,
      child: Text(title, style: Theme.of(context).textTheme.titleMedium),
    ),
  );
}

/// The filters in one panel (S8.5; UX-30): today's status, target, site and
/// night semantics (TASK 14.1), shown as they change and cleared at once.
abstract final class _FilterPanel {
  static const _statusLabels = {
    SessionListStatus.planned: AppWords.saved,
    SessionListStatus.inProgress: AppWords.tracking,
    SessionListStatus.completed: AppWords.completed,
    SessionListStatus.abandoned: AppWords.notDone,
  };

  static Future<void> show(
    BuildContext context, {
    required ({Map<int, String> targets, Map<int, String> sites}) options,
    required ValueChanged<SessionFilter> onChanged,
  }) {
    final vm = context.read<SessionsViewModel>();
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (sheet) => SafeArea(
        child: ListenableBuilder(
          listenable: vm,
          builder: (context, _) =>
              _body(context, vm.filter, options, onChanged),
        ),
      ),
    );
  }

  static SessionFilter _copy(
    SessionFilter f, {
    Set<SessionListStatus>? statuses,
    int? Function()? targetId,
    int? Function()? siteId,
    (CalendarDate?, CalendarDate?)? range,
  }) => SessionFilter(
    statuses: statuses ?? f.statuses,
    targetId: targetId == null ? f.targetId : targetId(),
    siteId: siteId == null ? f.siteId : siteId(),
    from: range == null ? f.from : range.$1,
    to: range == null ? f.to : range.$2,
  );

  static Future<int?> _pick(
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

  static Widget _body(
    BuildContext context,
    SessionFilter f,
    ({Map<int, String> targets, Map<int, String> sites}) options,
    ValueChanged<SessionFilter> onChanged,
  ) {
    String dates() {
      if (f.from == null && f.to == null) return 'Any night';
      final a = f.from == null ? '…' : NightTimeFormatter.eveningDate(f.from!);
      final b = f.to == null ? '…' : NightTimeFormatter.eveningDate(f.to!);
      return '$a – $b';
    }

    final theme = Theme.of(context);
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Filters', style: theme.textTheme.titleMedium),
          const SizedBox(height: AppSpacing.sm),
          Text('State', style: theme.textTheme.bodySmall),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.xs,
            children: [
              for (final MapEntry(:key, :value) in _statusLabels.entries)
                FilterChip(
                  key: Key('logbook.filter.${key.name}'),
                  label: Text(value),
                  selected: f.statuses.contains(key),
                  onSelected: (on) => onChanged(
                    _copy(
                      f,
                      statuses: on
                          ? {...f.statuses, key}
                          : ({...f.statuses}..remove(key)),
                    ),
                  ),
                ),
            ],
          ),
          ListTile(
            key: const Key('logbook.filter.target'),
            contentPadding: EdgeInsets.zero,
            title: const Text('Target'),
            subtitle: Text(
              f.targetId == null
                  ? 'All'
                  : options.targets[f.targetId] ?? 'Selected',
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: () async {
              final id = await _pick(context, 'Target', options.targets);
              if (id != null) {
                onChanged(_copy(f, targetId: () => id < 0 ? null : id));
              }
            },
          ),
          ListTile(
            key: const Key('logbook.filter.site'),
            contentPadding: EdgeInsets.zero,
            title: const Text(AppWords.site),
            subtitle: Text(
              f.siteId == null ? 'All' : options.sites[f.siteId] ?? 'Selected',
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: () async {
              final id = await _pick(context, 'Site', options.sites);
              if (id != null) {
                onChanged(_copy(f, siteId: () => id < 0 ? null : id));
              }
            },
          ),
          ListTile(
            key: const Key('logbook.filter.dates'),
            contentPadding: EdgeInsets.zero,
            title: const Text('Nights'),
            subtitle: Text(dates()),
            trailing: const Icon(Icons.chevron_right),
            onTap: () async {
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
                    f,
                    range: (
                      CalendarDate.fromDateTimeFields(range.start),
                      CalendarDate.fromDateTimeFields(range.end),
                    ),
                  ),
                );
              }
            },
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  key: const Key('logbook.filters.clear'),
                  onPressed: f.isEmpty
                      ? null
                      : () => onChanged(const SessionFilter()),
                  child: const Text('Clear'),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: FilledButton(
                  key: const Key('logbook.filters.done'),
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Done'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
