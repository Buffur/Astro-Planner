import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_palette.dart';
import '../../../domain/models/night_timeline.dart';
import '../../../domain/models/night_weather.dart';
import '../../../domain/models/session.dart';
import '../../../domain/services/fit_analyzer.dart';
import '../../navigation/app_router.dart';
import '../../shared/field_mode_button.dart';
import '../../shared/location_feedback.dart';
import '../../shared/night_text.dart';
import '../../shared/night_time_formatter.dart';
import '../../shared/opportunity_text.dart';
import '../../viewmodels/capture_analysis_viewmodel.dart';
import '../../../domain/models/execution.dart';
import '../../shared/start_session.dart';
import '../../viewmodels/execution_viewmodel.dart';
import '../../viewmodels/night_conditions_viewmodel.dart';
import '../../viewmodels/resume_run_viewmodel.dart';
import 'resume_run_dialog.dart';
import '../../viewmodels/session_plan_viewmodel.dart';
import '../../viewmodels/site_viewmodel.dart';
import '../../viewmodels/startup_viewmodel.dart';
import '../../viewmodels/tonight_viewmodel.dart';
import '../../shared/unsaved_plan_guard.dart';
import '../../shared/failure_feedback.dart';

/// The Tonight tab's root (ADR-015, TASK 12.5): "what can I capture
/// tonight" at a glance — the site and night, the dark window, the Moon,
/// the weather with its age, and the current session's fit with its
/// reason. A summary only: every value comes from the ViewModels, and each
/// row drills down into the planner or a picker.
class TonightHomeScreen extends StatelessWidget {
  const TonightHomeScreen({super.key});

  static String _status(Session? s) => switch (s?.status) {
    null => 'Current plan',
    SessionStatus.draft =>
      s!.plannedAtUtc != null ? 'Planned, unsaved changes' : 'Draft',
    SessionStatus.planned => 'Planned',
    SessionStatus.inProgress => 'In progress',
    SessionStatus.completed => 'Completed',
    SessionStatus.abandoned => 'Abandoned',
  };

  @override
  Widget build(BuildContext context) {
    final startupVm = context.watch<StartupViewModel>();
    final tonightVm = context.watch<TonightViewModel>();
    if (tonightVm.firstRunDue) {
      tonightVm.markOffered();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (context.mounted) context.push(AppRouter.welcome);
      });
    }
    // A run left in progress (ADR-016 §5): ask once, at start.
    final resumeVm = context.watch<ResumeRunViewModel?>();
    if (resumeVm != null && resumeVm.promptDue && !startupVm.isLoading) {
      resumeVm.markShown();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (context.mounted) showResumeRunDialog(context, resumeVm);
      });
    }

    final Widget body;
    if (startupVm.hasBootstrapError) {
      body = Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("Couldn't load your data."),
            TextButton(
              onPressed: startupVm.retryBootstrap,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    } else if (startupVm.isLoading) {
      body = const Center(child: CircularProgressIndicator());
    } else {
      body = ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          _RunCard(),
          _SiteCard(),
          _NightCard(),
          _SessionCard(),
          SizedBox(height: 8),
          _QuickActions(),
        ],
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tonight'),
        actions: const [FieldModeButton()],
      ),
      body: body,
    );
  }
}

/// The session in progress, if any (ADR-016): tracked on its own screen,
/// separate from the plan below (owner decision, TASK 13.3).
class _RunCard extends StatelessWidget {
  const _RunCard();

  @override
  Widget build(BuildContext context) {
    final execution = context.watch<ExecutionViewModel?>();
    final session = execution?.session;
    final state = execution?.state;
    if (execution == null ||
        session == null ||
        state == null ||
        !state.isActive) {
      return const SizedBox.shrink();
    }
    final block = execution.block;
    return Card(
      key: const Key('tonight.run'),
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: const Icon(Icons.radio_button_checked),
        title: Text('In progress: ${session.record.targetName}'),
        subtitle: Text(
          '${state.phase == ExecutionPhase.running ? 'Running' : 'Paused'}'
          '${block == null ? '' : ' · ${state.completedFor(block.id)} of ${block.frameCount} confirmed'}',
        ),
        trailing: const Text('Open tracker'),
        onTap: () => context.push(AppRouter.run(session.id)),
      ),
    );
  }
}

class _SiteCard extends StatelessWidget {
  const _SiteCard();

  @override
  Widget build(BuildContext context) {
    final siteVm = context.watch<SiteViewModel>();
    final evening = context.watch<SessionPlanViewModel>().eveningDate;
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        key: const Key('tonight.site'),
        leading: const Icon(Icons.place_outlined),
        title: Text(
          siteVm.isDefaultLocation
              ? 'No site set'
              : siteVm.locationName ?? 'Current position',
        ),
        subtitle: Text(
          evening == null
              ? 'Set a site to see tonight.'
              : 'Night of ${NightTimeFormatter.eveningDate(evening)}',
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => context.push(AppRouter.selectSite),
      ),
    );
  }
}

/// The night, the Moon and the weather — or the site prompt without a site
/// (ADR-007 §9: no night is computed for the default location).
class _NightCard extends StatelessWidget {
  const _NightCard();

  @override
  Widget build(BuildContext context) {
    final siteVm = context.watch<SiteViewModel>();
    final theme = Theme.of(context);
    if (siteVm.isDefaultLocation) {
      return Card(
        key: const Key('tonight.noSite'),
        margin: const EdgeInsets.only(bottom: 12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Set up your observing site to see tonight: the night, the '
                'Moon and the weather are computed for it.',
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  FilledButton(
                    onPressed: () =>
                        useCurrentPositionWithFeedback(context, siteVm),
                    child: const Text('Use current position'),
                  ),
                  OutlinedButton(
                    onPressed: () => context.push(AppRouter.selectSite),
                    child: const Text('Set site'),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    }

    final conditions = context.watch<NightConditionsViewModel>();
    final timeline = conditions.nightTimeline;
    final zoneId = siteVm.displayZoneId;
    void openPlanner() => context.push(AppRouter.session());
    final moon = conditions.moonConditions;

    final rows = <Widget>[];
    if (timeline != null) {
      String at(DateTime utc) => NightTimeFormatter.instant(
        context,
        utc,
        windowStartUtc: timeline.night.startUtc,
        zoneId: zoneId,
      );
      rows.add(
        _Row(
          key: const Key('tonight.night'),
          icon: Icons.nights_stay_outlined,
          label: 'Night',
          lines: [
            _span('Sunset to sunrise', timeline.sunriseSunset, at),
            _span('Dark (Sun below −18°)', timeline.astronomicalTwilight, at),
            'Times in ${NightTimeFormatter.zoneCaption(timeline.night.startUtc, zoneId: zoneId)}',
          ],
          onTap: openPlanner,
        ),
      );
      if (moon != null) {
        rows.add(
          _Row(
            key: const Key('tonight.moon'),
            icon: Icons.nightlight_round,
            label: 'Moon',
            lines: [
              '${(moon.illuminationAtMidnight * 100).round()} % lit',
              MoonText.up(moon, at),
            ],
            onTap: openPlanner,
          ),
        );
      }
    }
    rows.add(
      _Row(
        key: const Key('tonight.weather'),
        icon: Icons.cloud_outlined,
        label: 'Weather',
        lines: _weatherLines(conditions),
        onTap: openPlanner,
      ),
    );

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Column(children: rows),
    );
  }

  /// "Sunset to sunrise: 18:02 – 06:41", or what the Sun does instead.
  static String _span(
    String label,
    SunThresholdResult r,
    String Function(DateTime) at,
  ) => switch (r) {
    SunCrossing(:final duskUtc, :final dawnUtc) =>
      '$label: ${duskUtc == null ? 'from the start' : at(duskUtc)} – '
          '${dawnUtc == null ? 'the end' : at(dawnUtc)}',
    SunNeverBelow() => '$label: not tonight',
    SunAlwaysBelow() => '$label: all night',
  };

  /// The forecast's cloud range and age, or why there is none — unknown
  /// is never shown as 0 (SI-008).
  static List<String> _weatherLines(NightConditionsViewModel c) =>
      switch (c.nightWeather) {
        NightWeatherIdle() || NightWeatherLoading() => ['Loading forecast…'],
        NightWeatherOutOfRange() => [
          'No forecast yet: this night is beyond the forecast horizon.',
        ],
        NightWeatherUnavailable(:final failure) => [
          'No forecast. ${WeatherText.failure(failure)}',
        ],
        final NightWeatherAvailable a => [
          'Cloud ${WeatherText.range(c.nightWeatherSummary?.cloudCover, '%')}',
          WeatherText.freshness(a),
        ],
      };
}

class _SessionCard extends StatelessWidget {
  const _SessionCard();

  @override
  Widget build(BuildContext context) {
    final planVm = context.watch<SessionPlanViewModel>();
    final theme = Theme.of(context);
    final target = planVm.selectedTarget;
    final rig = planVm.selectedEquipment;
    final hasNight = planVm.sessionNight != null;
    final fit = hasNight
        ? context.watch<CaptureAnalysisViewModel>().fitAnalysis
        : null;
    final opportunity = hasNight
        ? context.watch<NightConditionsViewModel>().imagingOpportunity
        : null;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              TonightHomeScreen._status(planVm.activeSession),
              key: const Key('tonight.sessionStatus'),
              style: theme.textTheme.labelLarge,
            ),
            const SizedBox(height: 4),
            Text(
              target == null
                  ? 'No target chosen'
                  : target.commonName ?? target.catalogId,
              style: theme.textTheme.titleMedium,
            ),
            if (rig == null)
              Wrap(
                key: const Key('tonight.noRig'),
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  const Text('No rig chosen'),
                  TextButton(
                    onPressed: () => context.push(AppRouter.selectRig),
                    child: const Text('Choose rig'),
                  ),
                ],
              )
            else
              Text(rig.name),
            if (fit != null) ...[
              const SizedBox(height: 8),
              Text(
                FitText.label(fit.state),
                key: const Key('tonight.fit'),
                style: theme.textTheme.titleSmall?.copyWith(
                  color: FitText.color(fit.state, theme.colorScheme),
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (fit.reason.isNotEmpty)
                Text(fit.reason, key: const Key('tonight.fitReason')),
              if (opportunity != null && fit.state != FitState.noWindow)
                Text(
                  'Usable time tonight: '
                  '${OpportunityText.duration(opportunity.usableTime)}',
                  style: theme.textTheme.bodySmall,
                ),
            ],
            const SizedBox(height: 12),
            FilledButton.icon(
              key: const Key('tonight.openPlanner'),
              onPressed: () => context.push(AppRouter.session()),
              icon: const Icon(Icons.edit_calendar_outlined),
              label: const Text('Open planner'),
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(48),
              ),
            ),
            // TASK 13.3 (ADR-016; owner: same requirements as Save).
            if (hasNight && target != null && rig != null) ...[
              const SizedBox(height: 8),
              OutlinedButton.icon(
                key: const Key('tonight.start'),
                onPressed: () => startSessionWithFeedback(context),
                icon: const Icon(Icons.play_arrow),
                label: const Text('Start'),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(48),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _QuickActions extends StatelessWidget {
  const _QuickActions();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        OutlinedButton.icon(
          key: const Key('tonight.candidates'),
          onPressed: () => context.push(AppRouter.candidates),
          icon: const Icon(Icons.format_list_numbered),
          label: const Text('What can I image tonight?'),
          style: OutlinedButton.styleFrom(
            minimumSize: const Size.fromHeight(48),
          ),
        ),
        const SizedBox(height: 8),
        OutlinedButton.icon(
          key: const Key('tonight.newSession'),
          onPressed: () async {
            // S1.6: ask first, and report a failed write (trap 18).
            if (!await confirmLeavingUnsavedPlan(context)) return;
            if (!context.mounted) return;
            final started = await runWithFeedback(
              context,
              'start a new session',
              context.read<SessionPlanViewModel>().newSession,
            );
            if (started && context.mounted) context.push(AppRouter.session());
          },
          icon: const Icon(Icons.add),
          label: const Text('New session'),
          style: OutlinedButton.styleFrom(
            minimumSize: const Size.fromHeight(48),
          ),
        ),
      ],
    );
  }
}

/// One summary row: an icon, a label and a few lines; tap to drill down.
class _Row extends StatelessWidget {
  const _Row({
    super.key,
    required this.icon,
    required this.label,
    required this.lines,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final List<String> lines;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 48),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: AppPalette.of(context).moon),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(label, style: theme.textTheme.labelLarge),
                    for (final l in lines)
                      Text(l, style: theme.textTheme.bodyMedium),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }
}
