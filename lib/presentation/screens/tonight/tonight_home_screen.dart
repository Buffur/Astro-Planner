import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_palette.dart';
import '../../../domain/models/night_timeline.dart';
import '../../../domain/models/night_weather.dart';
import '../../../domain/services/fit_analyzer.dart';
import '../../navigation/app_router.dart';
import '../../../core/utils/quantity_text.dart';
import '../../shared/app_words.dart';
import '../../shared/context_line.dart';
import '../../shared/example_text.dart';
import '../../shared/field_mode_button.dart';
import '../../shared/location_feedback.dart';
import '../../shared/night_text.dart';
import '../../shared/night_time_formatter.dart';
import '../../shared/plan_state.dart';
import '../../shared/status_block.dart';
import '../../viewmodels/capture_analysis_viewmodel.dart';
import '../../../domain/models/execution.dart';
import '../../viewmodels/execution_viewmodel.dart';
import '../../viewmodels/night_conditions_viewmodel.dart';
import '../../viewmodels/resume_run_viewmodel.dart';
import '../../widgets/plan_status.dart';
import 'resume_run_dialog.dart';
import '../../viewmodels/session_plan_viewmodel.dart';
import '../../viewmodels/plan_lifecycle_viewmodel.dart';
import '../../viewmodels/site_viewmodel.dart';
import '../../viewmodels/startup_viewmodel.dart';
import '../../viewmodels/tonight_viewmodel.dart';
import '../../shared/unsaved_plan_prompt.dart';
import '../../shared/failure_feedback.dart';

/// The Tonight tab's root (ADR-015, TASK 12.5; plan first since S6.13,
/// ADR-019 §5): which site and night, the run in progress if any, the
/// current plan with its answer, then the night, the Moon and the weather,
/// each opening its detail, then the secondary actions. A summary only:
/// every value comes from the ViewModels.
///
/// S6.13 records two choices: no compact timeline here (ADR-019 §5's fixed
/// order has none, the plan card gives the usable time, and the full
/// timeline is one tap away in the planner); and no Start (UX-13): Track
/// live stays in the planner's ⋮ (S6.2) until P8.4.
class TonightHomeScreen extends StatelessWidget {
  const TonightHomeScreen({super.key});

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
          _Context(),
          _RunCard(),
          // Stage 8 (P8.3) adds "Last night: … How did it go?" here.
          _PlanCard(),
          _NightCard(),
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

/// Site ▾ · night ▾ (ADR-019 §5; UX-11): the same control as the planner's;
/// the night picker changes the current plan's night.
class _Context extends StatelessWidget {
  const _Context();

  @override
  Widget build(BuildContext context) {
    final siteVm = context.watch<SiteViewModel>();
    final planVm = context.watch<SessionPlanViewModel>();
    return Padding(
      key: const Key('tonight.context'),
      padding: const EdgeInsets.only(bottom: 12),
      child: ContextLine(
        siteName: siteVm.isDefaultLocation
            ? null
            : siteVm.activeSite?.name ??
                  siteVm.locationName ??
                  'Current position',
        night: planVm.eveningDate,
        zoneId: siteVm.displayZoneId,
        nightStartUtc: planVm.sessionNight?.startUtc,
        onSite: () => context.push(AppRouter.selectSite),
        onNight: () async {
          final picked = await pickNight(context, initial: planVm.eveningDate);
          if (picked != null && context.mounted) {
            await runWithFeedback(
              context,
              'change the night',
              () => planVm.setEveningDate(picked),
            );
          }
        },
      ),
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

/// Your plan (ADR-019 §5): the target and state, the verdict with its
/// reason and usable time (`StatusBlock`, the planner's words), and Open
/// planner; without a target, Choose a target and What can I image tonight?
class _PlanCard extends StatelessWidget {
  const _PlanCard();

  @override
  Widget build(BuildContext context) {
    final planVm = context.watch<SessionPlanViewModel>();
    final fit = context.watch<CaptureAnalysisViewModel>().fitAnalysis;
    final theme = Theme.of(context);
    final target = planVm.selectedTarget;
    final rig = planVm.selectedEquipment;
    final session = planVm.activeSession;
    final (missing, _, _) = PlanStatus.missingInput(planVm);
    final measured =
        missing == null &&
        (fit.state == FitState.fits ||
            fit.state == FitState.tight ||
            fit.state == FitState.doesNotFit);

    return Card(
      key: const Key('tonight.plan'),
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(AppWords.yourPlan, style: theme.textTheme.labelLarge),
            const SizedBox(height: 4),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Text(
                  target == null
                      ? 'No target chosen'
                      : target.commonName ?? target.catalogId,
                  style: theme.textTheme.titleMedium,
                ),
                if (session != null)
                  PlanStateLabel(
                    PlanState.of(session),
                    key: const Key('tonight.planState'),
                  ),
              ],
            ),
            if (rig != null)
              Text(
                ExampleText.rigName(rig), // RD-04 (S6.8)
                style: theme.textTheme.bodySmall,
              ),
            const SizedBox(height: 8),
            StatusBlock(
              key: const Key('tonight.status'),
              state: missing != null ? FitState.needsInput : fit.state,
              missing: missing,
              needed: measured
                  ? Duration(milliseconds: fit.windowLoadMs)
                  : null,
              usable: measured && fit.availableMs > 0
                  ? Duration(milliseconds: fit.availableMs)
                  : null,
              reason: missing == PlanStatus.needsRig
                  ? 'A rig is needed to save the plan and to check exposures.'
                  : fit.reason,
              action: missing == PlanStatus.needsRig
                  ? OutlinedButton(
                      key: const Key('tonight.chooseRig'),
                      onPressed: () => context.push(AppRouter.selectRig),
                      child: const Text(AppWords.chooseRig),
                    )
                  : null,
            ),
            const SizedBox(height: 12),
            if (target == null && planVm.sessionNight != null) ...[
              FilledButton(
                key: const Key('tonight.chooseTarget'),
                onPressed: () => context.push(AppRouter.selectTarget),
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(48),
                ),
                child: const Text('Choose a target'),
              ),
              const SizedBox(height: 8),
              OutlinedButton(
                key: const Key('tonight.planCandidates'),
                onPressed: () => context.push(AppRouter.candidates),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(48),
                ),
                child: const Text('What can I image tonight?'),
              ),
              const SizedBox(height: 8),
              TextButton(
                key: const Key('tonight.openPlanner'),
                onPressed: () => context.push(AppRouter.session()),
                child: const Text('Open planner'),
              ),
            ] else
              FilledButton.icon(
                key: const Key('tonight.openPlanner'),
                onPressed: () => context.push(AppRouter.session()),
                icon: const Icon(Icons.edit_calendar_outlined),
                label: const Text('Open planner'),
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(48),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// The night, the Moon and the weather, each opening its detail (S6.5) —
/// or, without a site, the one site prompt (ADR-007 §9: no night is
/// computed for the default location).
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
    // S6.5 (UX-10): each row opens its detail, not the top of the planner.
    void openNight() => context.push(AppRouter.nightMoon);
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
            // TD-054 (S6.13): the dark span at the user's limit (S6.5).
            if (timeline.darkAtLimit case final dark?) DarkText.span(dark, at),
            'Times in ${NightTimeFormatter.zoneCaption(timeline.night.startUtc, zoneId: zoneId)}',
          ],
          onTap: openNight,
        ),
      );
      if (moon != null) {
        final during = conditions.moonDuringDark;
        rows.add(
          _Row(
            key: const Key('tonight.moon'),
            icon: Icons.nightlight_round,
            label: 'Moon',
            // UX-17 (S6.13): the Moon during the dark span, the useful
            // fact; its rise and set times are on Night & Moon.
            lines: [
              during != null
                  ? MoonText.duringDark(during)
                  : '${QuantityText.percent(moon.illuminationAtMidnight * 100)} '
                        'lit at midnight; no dark time tonight',
            ],
            onTap: openNight,
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
        onTap: () => context.push(AppRouter.weather),
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
            // S6.3 (U1): Save · Discard · Cancel first, and report a
            // failed write (trap 18).
            final leaving = await askBeforeLeavingPlan(context);
            if (leaving == null || !context.mounted) return;
            final started = await runWithFeedback(
              context,
              'start a new plan',
              () => context.read<PlanLifecycleViewModel>().newSession(
                discard: leaving == LeavingPlan.discard,
              ),
            );
            if (started && context.mounted) {
              showDone(context, 'New plan started');
              context.push(AppRouter.session());
            }
          },
          icon: const Icon(Icons.add),
          label: const Text(AppWords.newPlan),
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
