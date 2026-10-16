import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../../domain/models/calendar_date.dart';
import '../../../domain/models/capture_block.dart';
import '../../../domain/models/session.dart';
import '../../../domain/models/session_snapshot.dart';
import '../../../domain/repositories/session_repository.dart';
import '../../../domain/services/result_action.dart';
import '../../../domain/services/saved_night_end.dart';
import '../../../domain/services/session_reconciliation.dart';
import '../../shared/app_words.dart';
import '../../shared/context_line.dart';
import '../../shared/delete_patterns.dart';
import '../../shared/detail_scaffold.dart';
import '../../shared/entry_share_text.dart';
import '../../shared/plan_state.dart';
import '../../navigation/app_router.dart';
import '../../shared/night_time_formatter.dart';
import '../../shared/opportunity_text.dart';
import '../../viewmodels/library_viewmodels.dart';
import '../../viewmodels/plan_lifecycle_viewmodel.dart';
import '../../viewmodels/session_plan_viewmodel.dart';
import '../../shared/failure_feedback.dart';
import '../execution/results_screen.dart';
import 'progress_screen.dart';
import 'logbook_screen.dart';
import '../../shared/unsaved_plan_prompt.dart';
import '../../../core/utils/quantity_text.dart';
import '../../../core/utils/astro_math.dart';

/// A Logbook entry (TASK 14.1; S8.7, P8.7, ADR-019 §8, §10): read-only
/// history from its snapshots — never today's site, target or rig (ADR-014
/// §4). In order: the identity (the name, or target · night) and its state;
/// the result; the night, site, target and rig; planned against actual
/// (CALC-37) per block; the notes; the conditions; then the actions its
/// state allows (I-6), Share (D8-4: no notes, no coordinates) and Export as
/// file (the portable manifest v2). An old log shows its stored text only.
/// It never opens a live tracker.
class SessionDetailScreen extends StatefulWidget {
  const SessionDetailScreen({super.key, required this.sessionId});

  final int sessionId;

  @override
  State<SessionDetailScreen> createState() => _SessionDetailScreenState();
}

class _SessionDetailScreenState extends State<SessionDetailScreen> {
  late Future<SessionDetail?> _detail;

  @override
  void initState() {
    super.initState();
    _detail = context.read<SessionsViewModel>().detail(widget.sessionId);
  }

  /// Re-reads the entry after an action (a result, a name).
  void _load() {
    final sessions = context.read<SessionsViewModel>();
    setState(() {
      _detail = sessions.detail(widget.sessionId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _detail,
      builder: (context, snapshot) {
        final data = snapshot.data;
        if (snapshot.error case final error?) {
          return Scaffold(
            appBar: AppBar(title: const Text(AppWords.logbook)),
            body: LoadFailureView(
              action: 'load the entry',
              error: error,
              onRetry: _load,
            ),
          );
        }
        if (data == null) {
          return Scaffold(
            appBar: AppBar(title: const Text(AppWords.logbook)),
            body: Center(
              child: snapshot.connectionState == ConnectionState.done
                  ? const Text('This entry no longer exists.')
                  : const CircularProgressIndicator(),
            ),
          );
        }
        final s = data.session;
        final snap = s.executionStartSnapshot ?? s.planSnapshot;
        final site = snap?.siteName ?? s.record.locationName;
        final night = s.eveningDate;
        return DetailScaffold(
          title: entryTitle(s),
          context: [
            if (s.name != null) targetAndNight(s),
            ?site,
          ].join(' · ').ifEmpty,
          zoneRule: s.legacy || night == null
              ? null
              : ContextLine.zoneRule(
                  snap?.night?.startUtc ?? s.record.sessionDate,
                  zoneId: s.timeZoneId ?? snap?.timeZoneId,
                ),
          actions: [
            // S8.5 (S5.8, RD-09 S1): the entry's visible Delete.
            DeleteButton(
              key: const Key('detail.delete'),
              tooltip: 'Delete entry',
              onPressed: () async {
                if (await deleteEntry(context, s) && context.mounted) {
                  context.pop();
                }
              },
            ),
          ],
          summary: _Result(session: s, reconciliation: data.reconciliation),
          sections: [
            if (!s.legacy) _NameTile(session: s, onChanged: _load),
            if (!s.legacy) _SnapshotSections(session: s),
            _PlanVsActual(session: s, reconciliation: data.reconciliation),
            _Notes(session: s),
            _Conditions(session: s),
            if (data.progress case final p?)
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'This target so far',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  TargetProgressCard(progress: p),
                ],
              ),
            _Actions(
              session: s,
              reconciliation: data.reconciliation,
              onBack: _load,
            ),
          ],
        );
      },
    );
  }
}

extension on String {
  /// Null for an empty string (an optional caption).
  String? get ifEmpty => isEmpty ? null : this;
}

/// The result first (ADR-019 §4): the state, how it was reported, planned
/// against actual when counted, or when a result can be recorded.
class _Result extends StatelessWidget {
  const _Result({required this.session, required this.reconciliation});

  final Session session;
  final SessionReconciliation? reconciliation;

  @override
  Widget build(BuildContext context) {
    final s = session;
    final r = reconciliation;
    final theme = Theme.of(context);
    final end = SavedNightEnd.of(s);
    final zone = s.timeZoneId ?? s.planSnapshot?.timeZoneId;
    final counted =
        s.status == SessionStatus.completed ||
        s.status == SessionStatus.inProgress;
    final upcoming =
        s.isSavedPlan &&
        context.read<SessionsViewModel>().resultAction(s) == ResultAction.none;
    return Column(
      key: const Key('detail.result'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 4,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            PlanStateLabel(PlanState.of(s), key: const Key('detail.status')),
            if (s.legacy)
              const Text(
                '${AppWords.oldLog} — stored text only',
                key: Key('detail.legacy'),
              ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          EntryShareText.result(s),
          key: const Key('detail.resultText'),
          style: theme.textTheme.titleSmall,
        ),
        if (counted && r != null)
          Text(ResultsText.integration(r), key: const Key('detail.summary')),
        if (upcoming && end != null)
          Text(
            'A result can be recorded after the night: from '
            '${NightTimeFormatter.eveningDate(CalendarDate.fromDateTimeFields(NightTimeFormatter.wallClock(end, zoneId: zone)))}, '
            '${NightTimeFormatter.clockTime(context, end, zoneId: zone)}.',
            key: const Key('detail.resultWhen'),
            style: theme.textTheme.bodySmall,
          ),
      ],
    );
  }
}

/// The context the session was planned or started in, from its snapshot.
class _SnapshotSections extends StatelessWidget {
  const _SnapshotSections({required this.session});

  final Session session;

  @override
  Widget build(BuildContext context) {
    final started = session.executionStartSnapshot;
    final snap = started ?? session.planSnapshot;
    if (snap == null) {
      return const _Section(
        key: Key('detail.noSnapshot'),
        title: 'Context',
        rows: {'Snapshot': 'unavailable (not saved or unreadable)'},
      );
    }
    final night = snap.night;
    String at(DateTime utc) => night == null
        ? NightTimeFormatter.deviceZoneCaption(utc)
        : NightTimeFormatter.instant(
            context,
            utc,
            windowStartUtc: night.startUtc,
            zoneId: snap.timeZoneId,
          );
    String deg(double? v, [int digits = 0]) =>
        v == null ? 'unknown' : QuantityText.degrees(v, digits: digits);
    String dur(Duration? d) =>
        d == null ? 'unknown' : OpportunityText.duration(d);
    String? known(Object? v, [String unit = '']) =>
        v == null ? null : '$v$unit';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          '${started != null ? 'At the start of imaging' : 'Plan as saved'}'
          ' · taken ${at(snap.takenAtUtc)}',
          key: const Key('detail.snapshotLabel'),
          style: Theme.of(context).textTheme.labelLarge,
        ),
        _Section(
          key: const Key('detail.night'),
          title: 'Night',
          rows: {
            if (night != null) ...{
              // The noon-to-noon night key, not an imaging window (UX-18).
              'Night span': '${at(night.startUtc)} – ${at(night.endUtc)}',
              'Times in': NightTimeFormatter.zoneCaption(
                night.startUtc,
                zoneId: snap.timeZoneId,
              ),
            },
            'Darkness limit': deg(snap.darknessLimitDeg),
            'Minimum altitude': deg(snap.minAltitudeDeg),
            'Usable time': dur(snap.usableTime),
            for (final (i, (a, b)) in snap.windows.indexed)
              'Window ${i + 1}': '${at(a)} – ${at(b)}',
          },
        ),
        _Section(
          key: const Key('detail.site'),
          title: 'Site',
          rows: {
            'Name': snap.siteName ?? 'transient position',
            'Position':
                '${deg(snap.siteLatitudeDeg ?? night?.latitude, 3)}, '
                '${deg(snap.siteLongitudeDeg ?? night?.longitude, 3)}',
            'Elevation': known(snap.siteElevationM?.round(), ' m') ?? 'unknown',
            'Bortle': known(snap.bortleClass) ?? 'unknown',
            'SQM': known(snap.sqm, ' mag/arcsec²') ?? 'unknown',
          },
        ),
        _Section(
          key: const Key('detail.target'),
          title: 'Target',
          rows: {
            'Name': snap.targetName ?? 'none',
            if (snap.target case final t?) ...{
              'RA / Dec (J2000)':
                  '${AstroMath.formatRightAscension(t.rightAscension)}, '
                  '${AstroMath.formatDeclination(t.declination)}',
            },
          },
        ),
        _Section(
          key: const Key('detail.rig'),
          title: 'Rig',
          rows: {
            'Name': snap.rigName ?? 'none',
            'Focal length':
                known(snap.rigFocalLengthMm?.round(), ' mm') ?? 'unknown',
            'Focal ratio': snap.rigFocalRatio == null
                ? 'unknown'
                : 'f/${snap.rigFocalRatio!.toStringAsFixed(1)}',
            'Pixel pitch': known(snap.rigPixelPitchUm, ' µm') ?? 'unknown',
          },
        ),
        _Section(
          key: const Key('detail.budget'),
          title: 'Budget',
          rows: {
            AppWords.integration: dur(snap.integration),
            AppWords.timeNeeded: dur(snap.windowLoad),
            AppWords.totalTime: dur(snap.sessionBudget),
          },
        ),
        _Section(
          key: const Key('detail.weather'),
          title: 'Weather',
          rows: _weather(snap, at),
        ),
      ],
    );
  }

  static Map<String, String> _weather(
    SessionSnapshot snap,
    String Function(DateTime) at,
  ) => switch (snap.weatherState) {
    'available' => {
      'Source': snap.weatherSource ?? 'unknown',
      if (snap.weatherFetchedAtUtc case final t?) 'Fetched': at(t),
    },
    'outOfRange' => {'Forecast': 'beyond the forecast horizon'},
    'unavailable' => {'Forecast': 'unavailable'},
    _ => {'Forecast': 'none recorded'},
  };
}

class _PlanVsActual extends StatelessWidget {
  const _PlanVsActual({required this.session, required this.reconciliation});

  final Session session;
  final SessionReconciliation? reconciliation;

  @override
  Widget build(BuildContext context) {
    final r = reconciliation;
    final log = session.record;
    if (r == null) {
      // An old log: the stored totals only (ADR-014 §7).
      return _Section(
        key: const Key('detail.planVsActual'),
        title: 'Plan vs actual',
        rows: {
          for (final b in session.blocks) _label(b): '${b.frameCount} planned',
          'Planned light frames': '${log.plannedLightFrames}',
          'Actual light frames': log.actualLightFrames?.toString() ?? 'unknown',
          'Rejected frames': log.rejectedFrames?.toString() ?? 'unknown',
        },
      );
    }
    // Counts exist once a result was recorded, or a run was started.
    final counted =
        session.status == SessionStatus.completed ||
        session.status == SessionStatus.inProgress ||
        session.startedAtUtc != null;
    return _Section(
      key: const Key('detail.planVsActual'),
      title: 'Plan vs actual',
      rows: {
        for (final b in r.blocks)
          _label(b.block): counted
              ? '${b.confirmed} of ${b.planned}'
                    '${b.rejected > 0 ? ' · ${b.rejected} rejected' : ''}'
              : '${b.planned} planned',
        if (counted) AppWords.integration: ResultsText.integrationValue(r),
      },
    );
  }

  static String _label(CaptureBlock b) =>
      '${b.filterName ?? switch (b.frameType) {
            FrameType.light => 'Light',
            FrameType.dark => 'Darks',
            FrameType.flat => 'Flats',
            FrameType.bias => 'Bias',
            FrameType.darkFlat => 'Dark flats',
          }} · ${QuantityText.exposure(b.exposureTimeSeconds)}';
}

class _Notes extends StatelessWidget {
  const _Notes({required this.session});

  final Session session;

  @override
  Widget build(BuildContext context) {
    final log = session.record;
    return _Section(
      key: const Key('detail.notes'),
      title: 'Notes',
      rows: {
        if (log.environmentalNotes case final n? when n.isNotEmpty)
          'Conditions and events': n,
        if (log.processingNotes case final n? when n.isNotEmpty)
          'Processing notes': n,
      },
      empty: 'None recorded.',
    );
  }
}

class _Conditions extends StatelessWidget {
  const _Conditions({required this.session});

  final Session session;

  @override
  Widget build(BuildContext context) {
    final log = session.record;
    return _Section(
      key: const Key('detail.conditions'),
      title: 'Conditions',
      rows: {
        if (log.temperature case final t?)
          'Temperature': '${QuantityText.signed(t, digits: 1)} °C',
        if (log.humidity case final h?) 'Humidity': '$h %',
        if (log.cloudCover case final c?) 'Cloud cover': '$c %',
      },
      empty: 'None recorded.',
    );
  }
}

/// What the entry offers (I-6): a saved plan before its night ends — Open in
/// planner; after it — Record result; with a result — Edit result; each
/// but an old log — Copy to another night; then Share and Export as file.
class _Actions extends StatelessWidget {
  const _Actions({
    required this.session,
    required this.reconciliation,
    required this.onBack,
  });

  final Session session;
  final SessionReconciliation? reconciliation;
  final VoidCallback onBack;

  Future<void> _open(BuildContext context, {bool copy = false}) async {
    final s = session;
    final plan = context.read<SessionPlanViewModel>();
    final lifecycle = context.read<PlanLifecycleViewModel>();
    final night = copy
        ? await pickNight(context, initial: plan.tonightKey)
        : null;
    if (copy && night == null) return;
    if (!context.mounted) return;
    // S6.3 (U1): Save · Discard · Cancel, unless it is the plan already open.
    final leaving = !copy && s.id == plan.activeSessionId
        ? LeavingPlan.keep
        : await askBeforeLeavingPlan(context);
    if (leaving == null || !context.mounted) return;
    final opened = await runWithFeedback(
      context,
      copy ? 'copy the plan' : 'open the plan',
      () => lifecycle.openSession(
        s,
        discard: leaving == LeavingPlan.discard,
        copyTo: night,
      ),
    );
    if (opened && context.mounted) {
      showDone(
        context,
        copy
            ? 'Copied to ${NightTimeFormatter.eveningDate(night!)}'
            : 'Plan opened',
      );
      context.push(AppRouter.session());
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = session;
    const tall = Size.fromHeight(48);
    final sessions = context.read<SessionsViewModel>();
    final action = sessions.resultAction(s);
    final upcoming = s.isSavedPlan && action == ResultAction.none && !s.legacy;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (action != ResultAction.none)
          FilledButton(
            key: Key(
              action == ResultAction.record
                  ? 'detail.recordResult'
                  : 'detail.editResults',
            ),
            onPressed: () async {
              await context.push(AppRouter.results(s.id));
              onBack();
            },
            style: FilledButton.styleFrom(minimumSize: tall),
            child: Text(
              action == ResultAction.record
                  ? AppWords.recordResult
                  : AppWords.editResult,
            ),
          ),
        if (upcoming) ...[
          const SizedBox(height: 8),
          OutlinedButton(
            key: const Key('detail.openInPlanner'),
            onPressed: () => _open(context),
            style: OutlinedButton.styleFrom(minimumSize: tall),
            child: const Text('Open in planner'),
          ),
        ],
        if (!s.legacy) ...[
          const SizedBox(height: 8),
          OutlinedButton(
            key: const Key('detail.copy'),
            onPressed: () => _open(context, copy: true),
            style: OutlinedButton.styleFrom(minimumSize: tall),
            child: const Text(AppWords.copyToAnotherNight),
          ),
        ],
        const SizedBox(height: 8),
        OutlinedButton.icon(
          key: const Key('detail.share'),
          onPressed: () => SharePlus.instance.share(
            ShareParams(
              text: EntryShareText.of(s, reconciliation: reconciliation),
            ),
          ),
          icon: const Icon(Icons.share),
          label: const Text('Share'),
          style: OutlinedButton.styleFrom(minimumSize: tall),
        ),
        // TASK 14.3; S8.7: the portable manifest v2 file with the event log,
        // distinct from Share (the download icon, now named for what it is).
        if (sessions.canExport) ...[
          const SizedBox(height: 8),
          OutlinedButton.icon(
            key: const Key('detail.export'),
            onPressed: () async {
              final done = await runWithFeedback(
                context,
                'export the entry',
                () => sessions.exportOne(s.id),
              );
              // S9.8 (D9-5): after the share sheet returns.
              if (done && context.mounted) {
                showDone(context, 'Export file created');
              }
            },
            icon: const Icon(Icons.file_download_outlined),
            label: const Text(AppWords.exportAsFile),
            style: OutlinedButton.styleFrom(minimumSize: tall),
          ),
        ],
      ],
    );
  }
}

/// A titled card of label/value rows.
class _Section extends StatelessWidget {
  const _Section({
    super.key,
    required this.title,
    required this.rows,
    this.empty,
  });

  final String title;
  final Map<String, String> rows;

  /// Shown instead of the rows when there are none.
  final String? empty;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.only(top: 8, bottom: 4),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(title, style: theme.textTheme.titleMedium),
            const SizedBox(height: 4),
            if (rows.isEmpty && empty != null) Text(empty!),
            for (final MapEntry(:key, :value) in rows.entries)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: '$key: ',
                        style: theme.textTheme.labelLarge,
                      ),
                      TextSpan(text: value),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// "Name (optional)" (S8.6; 08 §24): never asked at Save plan; set, changed
/// or removed here. Without one the entry is shown as target · night.
class _NameTile extends StatelessWidget {
  const _NameTile({required this.session, required this.onChanged});

  final Session session;
  final VoidCallback onChanged;

  Future<void> _edit(BuildContext context) async {
    final name = await showDialog<String>(
      context: context,
      builder: (_) => _NameDialog(initial: session.name ?? ''),
    );
    if (name == null || !context.mounted) return;
    final sessions = context.read<SessionsViewModel>();
    final saved = await runWithFeedback(
      context,
      'save the name',
      () => sessions.rename(session.id, name),
    );
    if (!saved) return;
    // S9.8 (D9-5): a rename says so.
    if (context.mounted) {
      showDone(context, name.trim().isEmpty ? 'Name removed' : 'Name saved');
    }
    onChanged();
  }

  @override
  Widget build(BuildContext context) => ListTile(
    key: const Key('detail.name'),
    contentPadding: EdgeInsets.zero,
    title: const Text(AppWords.nameOptional),
    subtitle: Text(session.name ?? 'None · shown as target · night'),
    trailing: const Icon(Icons.edit_outlined),
    onTap: () => _edit(context),
  );
}

/// The name's editor; it owns its field, which lives as long as the dialog.
class _NameDialog extends StatefulWidget {
  const _NameDialog({required this.initial});

  final String initial;

  @override
  State<_NameDialog> createState() => _NameDialogState();
}

class _NameDialogState extends State<_NameDialog> {
  late final _field = TextEditingController(text: widget.initial);

  @override
  void dispose() {
    _field.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: const Text(AppWords.nameOptional),
    content: TextField(
      key: const Key('detail.nameField'),
      controller: _field,
      autofocus: true,
      maxLength: SessionRepository.maxNameLength,
      decoration: const InputDecoration(
        helperText: 'Leave it empty to show target · night.',
      ),
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: const Text('Cancel'),
      ),
      FilledButton(
        key: const Key('detail.nameSave'),
        onPressed: () => Navigator.pop(context, _field.text),
        child: const Text('Save'),
      ),
    ],
  );
}
