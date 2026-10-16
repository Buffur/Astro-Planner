import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_palette.dart';
import '../../../core/theme/app_spacing.dart';
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
import '../../viewmodels/library_viewmodels.dart';
import '../../viewmodels/night_conditions_viewmodel.dart';
import '../../widgets/plan_status.dart';
import '../../viewmodels/session_plan_viewmodel.dart';
import '../../viewmodels/plan_lifecycle_viewmodel.dart';
import '../../viewmodels/site_viewmodel.dart';
import '../../viewmodels/startup_viewmodel.dart';
import '../../viewmodels/tonight_viewmodel.dart';
import '../../shared/unsaved_plan_prompt.dart';
import '../../shared/failure_feedback.dart';

/// The Tonight tab's root (ADR-015, TASK 12.5; plan first since S6.13,
/// ADR-019 §5): which site and night, a result due (S8.3), the
/// current plan with its answer, then the night, the Moon and the weather,
/// each opening its detail, then the secondary actions. A summary only:
/// every value comes from the ViewModels.
///
/// S6.13 records two choices: no compact timeline here (ADR-019 §5's fixed
/// order has none, the plan card gives the usable time, and the full
/// timeline is one tap away in the planner); and no Start (UX-13). The live
/// tracker, its run card and its resume prompt left in S8.4: a run still in
/// progress from before is offered by the result line.
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
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.md,
          0,
          AppSpacing.md,
          AppSpacing.md,
        ),
        children: const [
          _Title(),
          _Context(),
          _ResultDue(),
          _PlanCard(),
          _NightCard(),
          SizedBox(height: 8),
          _QuickActions(),
        ],
      );
    }

    // S6.16 (the owner's review, 1.1): the screen's title is the page's own
    // header, in the scale's headline role, as on the detail screens
    // (S5.7): it wraps at large text, which an app bar's title cannot. The
    // app bar keeps the actions.
    return Scaffold(
      appBar: AppBar(actions: const [FieldModeButton()]),
      body: body,
    );
  }
}

/// "Tonight", the page's title (S6.16): a semantic header.
class _Title extends StatelessWidget {
  const _Title();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Semantics(
        header: true,
        child: Text(
          'Tonight',
          key: const Key('tonight.title'),
          style: theme.textTheme.headlineSmall?.copyWith(
            color: AppPalette.of(context).textPrimary,
          ),
        ),
      ),
    );
  }
}

/// Site ▾ · night ▾ (ADR-019 §5; UX-11): the same control as the planner's;
/// the night picker changes the current plan's night. On a card since S6.16
/// (the owner's review, 1.2).
class _Context extends StatelessWidget {
  const _Context();

  @override
  Widget build(BuildContext context) {
    final siteVm = context.watch<SiteViewModel>();
    final planVm = context.watch<SessionPlanViewModel>();
    return KeyedSubtree(
      key: const Key('tonight.context'),
      child: ContextLine(
        framed: true,
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

/// "Last night: M42. How did it go?" (S8.3; ADR-019 §4–§5, I-8): the saved
/// plan (or run in progress) whose night has ended most recently without a
/// result; it opens the result form. Quiet, and gone once recorded; no
/// notification.
class _ResultDue extends StatelessWidget {
  const _ResultDue();

  @override
  Widget build(BuildContext context) {
    final s = context.watch<SessionsViewModel?>()?.dueResult;
    final night = s?.eveningDate;
    if (s == null || night == null) return const SizedBox.shrink();
    final tonight = context.watch<SessionPlanViewModel>().tonightKey;
    final lastNight = night == tonight || night.addDays(1) == tonight;
    final target = s.record.targetName;
    return Card(
      key: const Key('tonight.resultDue'),
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: const Icon(Icons.edit_note_outlined),
        title: Text(
          lastNight
              ? AppWords.howDidItGo(target)
              : AppWords.howDidItGoOn(
                  target,
                  NightTimeFormatter.eveningDate(night),
                ),
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => context.push(AppRouter.results(s.id)),
      ),
    );
  }
}

/// Your plan (ADR-019 §5): the target and state, the verdict with its
/// reason and usable time (`StatusBlock`, the planner's words), and Open
/// planner; without a target, Choose a target and What can I image tonight?
///
/// S6.16: "Your plan" is the card's heading in the card-heading role, above
/// the target (body text) and the rig (a caption) (TD-077); Open planner is
/// the card's primary action in every state (the owner's review, 3.2); the
/// two ways to a target each say what they offer (TD-080).
class _PlanCard extends StatelessWidget {
  const _PlanCard();

  @override
  Widget build(BuildContext context) {
    final planVm = context.watch<SessionPlanViewModel>();
    final fit = context.watch<CaptureAnalysisViewModel>().fitAnalysis;
    final theme = Theme.of(context);
    final palette = AppPalette.of(context);
    final target = planVm.selectedTarget;
    final rig = planVm.selectedEquipment;
    final session = planVm.activeSession;
    final missing = PlanStatus.missingInput(planVm);
    final measured =
        missing == null &&
        (fit.state == FitState.fits ||
            fit.state == FitState.tight ||
            fit.state == FitState.doesNotFit);

    return Card(
      key: const Key('tonight.plan'),
      margin: const EdgeInsets.only(bottom: 12),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.md,
              AppSpacing.md,
              AppSpacing.md,
              AppSpacing.sm,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Wrap(
                  alignment: WrapAlignment.spaceBetween,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: AppSpacing.sm,
                  runSpacing: AppSpacing.xs,
                  children: [
                    Semantics(
                      header: true,
                      child: Text(
                        AppWords.yourPlan,
                        key: const Key('tonight.planHeading'),
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: palette.textPrimary,
                        ),
                      ),
                    ),
                    if (session != null)
                      PlanStateLabel(
                        PlanState.of(session),
                        key: const Key('tonight.planState'),
                      ),
                  ],
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  target == null
                      ? 'No target chosen'
                      : target.commonName ?? target.catalogId,
                  key: const Key('tonight.planTarget'),
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: target == null
                        ? palette.textSecondary
                        : palette.textPrimary,
                  ),
                ),
                if (rig != null)
                  Text(
                    ExampleText.rigName(rig), // RD-04 (S6.8)
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: palette.textTertiary,
                    ),
                  ),
                const SizedBox(height: AppSpacing.md),
                StatusBlock(
                  key: const Key('tonight.status'),
                  state: missing != null ? FitState.needsInput : fit.state,
                  missing: missing?.headline,
                  needed: measured
                      ? Duration(milliseconds: fit.windowLoadMs)
                      : null,
                  usable: measured && fit.availableMs > 0
                      ? Duration(milliseconds: fit.availableMs)
                      : null,
                  // TD-075: a missing input's own reason, else the fit's.
                  reason: missing?.reason ?? fit.reason,
                  action: missing?.headline == PlanStatus.needsRig
                      ? OutlinedButton(
                          key: const Key('tonight.chooseRig'),
                          onPressed: () => context.push(AppRouter.selectRig),
                          child: const Text(AppWords.chooseRig),
                        )
                      : null,
                ),
              ],
            ),
          ),
          // TD-080: the two ways to a target, each saying what it offers.
          if (_offersTargets(planVm)) ...[
            const Divider(height: 1),
            _Row(
              key: const Key('tonight.chooseTarget'),
              icon: Icons.search,
              label: 'Choose a target',
              lines: const ['Any object in the catalogue'],
              onTap: () => context.push(AppRouter.selectTarget),
            ),
            const Divider(height: 1, indent: AppSpacing.md),
            _Row(
              key: const Key('tonight.planCandidates'),
              icon: Icons.format_list_numbered,
              label: _candidatesLabel,
              lines: const [_candidatesLine],
              onTap: () => context.push(AppRouter.candidates),
            ),
            const Divider(height: 1),
          ],
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: FilledButton.icon(
              key: const Key('tonight.openPlanner'),
              onPressed: () => context.push(AppRouter.session()),
              icon: const Icon(Icons.edit_calendar_outlined),
              label: const Text('Open planner'),
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(48),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// "What can I image tonight?" and its line (TD-080): the candidates for
/// this site and night, in RD-10's order.
const _candidatesLabel = 'What can I image tonight?';
const _candidatesLine = 'Candidates for this site and night, by usable time';

/// Your plan offers the two ways to a target (no target yet, and a night to
/// list candidates for); the secondary actions then leave the second out,
/// so it is shown once (TD-080).
bool _offersTargets(SessionPlanViewModel plan) =>
    plan.selectedTarget == null && plan.sessionNight != null;

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
    final inPlanCard = _offersTargets(context.watch<SessionPlanViewModel>());
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (!inPlanCard) ...[
          OutlinedButton.icon(
            key: const Key('tonight.candidates'),
            onPressed: () => context.push(AppRouter.candidates),
            icon: const Icon(Icons.format_list_numbered),
            label: const Text(_candidatesLabel),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size.fromHeight(48),
            ),
          ),
          const SizedBox(height: 8),
        ],
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
