import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../../domain/models/capture_block.dart';
import '../../../domain/models/session.dart';
import '../../../domain/models/session_snapshot.dart';
import '../../../domain/services/session_reconciliation.dart';
import '../../navigation/app_router.dart';
import '../../shared/night_time_formatter.dart';
import '../../shared/opportunity_text.dart';
import '../../viewmodels/library_viewmodels.dart';
import '../../viewmodels/session_plan_viewmodel.dart';
import '../../shared/failure_feedback.dart';
import '../execution/results_screen.dart';
import '../library/progress_screen.dart';
import 'logbook_screen.dart';
import '../../shared/unsaved_plan_guard.dart';
import '../../../core/utils/quantity_text.dart';
import '../../../core/utils/astro_math.dart';

/// One saved session (TASK 14.1): read-only, from its snapshot — history
/// never reads live sites, targets or rigs (ADR-014 §4). A started session
/// shows its execution-start snapshot, a planned one its plan snapshot
/// (owner decision). Legacy logs show their stored text only.
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

  /// Re-reads the session after an action (for example Edit results).
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
            appBar: AppBar(title: const Text('Session')),
            body: LoadFailureView(
              action: 'load the session',
              error: error,
              onRetry: _load,
            ),
          );
        }
        if (data == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Session')),
            body: Center(
              child: snapshot.connectionState == ConnectionState.done
                  ? const Text('This session no longer exists.')
                  : const CircularProgressIndicator(),
            ),
          );
        }
        final s = data.session;
        return Scaffold(
          appBar: AppBar(title: Text(s.record.targetName)),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _Header(session: s),
              if (!s.legacy) _SnapshotSections(session: s),
              _PlanVsActual(session: s, reconciliation: data.reconciliation),
              _Notes(session: s),
              if (data.progress case final p?) ...[
                const SizedBox(height: 8),
                Text(
                  'This target so far',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                TargetProgressCard(progress: p),
              ],
              const SizedBox(height: 12),
              _Actions(session: s, onBack: _load),
            ],
          ),
        );
      },
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.session});

  final Session session;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final evening = session.eveningDate;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Wrap(
        spacing: 8,
        runSpacing: 4,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          Text(
            evening == null
                ? NightTimeFormatter.deviceZoneCaption(
                    session.record.sessionDate.toUtc(),
                  )
                : 'Night of ${NightTimeFormatter.eveningDate(evening)}',
            style: theme.textTheme.titleMedium,
          ),
          Chip(
            key: const Key('detail.status'),
            label: Text(sessionStatusLabel(session)),
          ),
          if (session.legacy)
            const Chip(
              key: Key('detail.legacy'),
              label: Text('Legacy log — stored text only'),
            ),
        ],
      ),
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
            'Integration': dur(snap.integration),
            'Window load': dur(snap.windowLoad),
            'Session budget': dur(snap.sessionBudget),
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
      // Legacy: the stored totals only (ADR-014 §7).
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
    final started = session.startedAtUtc != null;
    return _Section(
      key: const Key('detail.planVsActual'),
      title: 'Plan vs actual',
      rows: {
        for (final b in r.blocks)
          _label(b.block): started
              ? '${b.confirmed} of ${b.planned}'
                    '${b.rejected > 0 ? ' · ${b.rejected} rejected' : ''}'
              : '${b.planned} planned',
        if (started) 'Integration': ResultsText.integrationValue(r),
      },
    );
  }

  static String _label(CaptureBlock b) =>
      '${b.filterName ?? switch (b.frameType) {
            FrameType.light => 'Light',
            FrameType.dark => 'Darks',
            FrameType.flat => 'Flats',
            FrameType.bias => 'Bias',
          }} · ${QuantityText.exposure(b.exposureTimeSeconds)}';
}

class _Notes extends StatelessWidget {
  const _Notes({required this.session});

  final Session session;

  @override
  Widget build(BuildContext context) {
    final log = session.record;
    final rows = {
      if (log.environmentalNotes case final n? when n.isNotEmpty)
        'Conditions and events': n,
      if (log.processingNotes case final n? when n.isNotEmpty)
        'Processing notes': n,
      if (log.temperature case final t?)
        'Temperature': '${QuantityText.signed(t, digits: 1)} °C',
      if (log.humidity case final h?) 'Humidity': '$h %',
      if (log.cloudCover case final c?) 'Cloud cover': '$c %',
    };
    return _Section(
      key: const Key('detail.notes'),
      title: 'Notes',
      rows: rows,
      empty: 'None recorded.',
    );
  }
}

class _Actions extends StatelessWidget {
  const _Actions({required this.session, required this.onBack});

  final Session session;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final s = session;
    const tall = Size.fromHeight(48);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (s.status == SessionStatus.inProgress && !s.legacy)
          FilledButton(
            key: const Key('detail.openTracker'),
            onPressed: () => context.push(AppRouter.run(s.id)),
            style: FilledButton.styleFrom(minimumSize: tall),
            child: const Text('Open tracker'),
          ),
        if (s.status == SessionStatus.completed && !s.legacy)
          FilledButton(
            key: const Key('detail.editResults'),
            onPressed: () async {
              await context.push(AppRouter.results(s.id));
              onBack();
            },
            style: FilledButton.styleFrom(minimumSize: tall),
            child: const Text('Edit results'),
          ),
        const SizedBox(height: 8),
        OutlinedButton(
          key: const Key('detail.openInPlanner'),
          onPressed: () async {
            // A frozen session opens as a copy in a new draft (TASK 11.4);
            // S1.6: ask before another plan's unsaved changes are left.
            final plan = context.read<SessionPlanViewModel>();
            if (s.id != plan.activeSessionId &&
                !await confirmLeavingUnsavedPlan(context)) {
              return;
            }
            if (!context.mounted) return;
            final opened = await runWithFeedback(
              context,
              'open the session',
              () => plan.openSession(s),
            );
            if (opened && context.mounted) context.push(AppRouter.session());
          },
          style: OutlinedButton.styleFrom(minimumSize: tall),
          child: Text(s.planEditable ? 'Open in planner' : 'Plan again (copy)'),
        ),
        const SizedBox(height: 8),
        OutlinedButton.icon(
          key: const Key('detail.share'),
          onPressed: () => SharePlus.instance.share(
            ShareParams(text: s.record.toShareableText()),
          ),
          icon: const Icon(Icons.share),
          label: const Text('Share'),
          style: OutlinedButton.styleFrom(minimumSize: tall),
        ),
        // TASK 14.3: the portable manifest v2 file (with the event log).
        if (context.read<SessionsViewModel>().canExport) ...[
          const SizedBox(height: 8),
          OutlinedButton.icon(
            key: const Key('detail.export'),
            onPressed: () => runWithFeedback(
              context,
              'export the session',
              () => context.read<SessionsViewModel>().exportOne(s.id),
            ),
            icon: const Icon(Icons.file_download_outlined),
            label: const Text('Export file'),
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
