import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import '../../navigation/app_router.dart';
import '../../viewmodels/startup_viewmodel.dart';
import '../../viewmodels/site_viewmodel.dart';
import '../../viewmodels/session_plan_viewmodel.dart';
import '../../viewmodels/plan_lifecycle_viewmodel.dart';
import '../../viewmodels/night_conditions_viewmodel.dart';
import '../../viewmodels/capture_analysis_viewmodel.dart';
import '../../widgets/planner_summary_card.dart';
import '../../widgets/planner_sections.dart';
import '../../shared/info_row.dart';
import '../../shared/example_text.dart';
import '../../../domain/models/equipment_profile.dart';
import '../../shared/collapsible_section.dart';
import '../../widgets/plan_status.dart';
import '../../shared/capability_text.dart';
import '../../shared/location_feedback.dart';
import '../../shared/start_session.dart';
import '../../shared/night_time_formatter.dart';
import '../../../domain/models/target_types.dart';
import '../../shared/field_mode_button.dart';
import '../../widgets/capture_plan_widget.dart';
import '../../widgets/tonight_opportunity_widget.dart';
import '../../widgets/sky_darkness_widget.dart';
import '../../shared/night_text.dart';
import '../details/night_moon_screen.dart';
import '../../../core/theme/app_palette.dart';
import '../../../core/theme/app_spacing.dart';
import '../../shared/app_words.dart';
import '../../shared/context_line.dart';
import '../../shared/plan_state.dart';
import '../../shared/failure_feedback.dart';
import '../../shared/unsaved_plan_prompt.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final analysisVm = context.watch<CaptureAnalysisViewModel>();
    final conditionsVm = context.watch<NightConditionsViewModel>();
    final planVm = context.watch<SessionPlanViewModel>();
    final siteVm = context.watch<SiteViewModel>();
    final startupVm = context.watch<StartupViewModel>();
    final target = planVm.selectedTarget;
    final equipment = planVm.selectedEquipment;

    return Scaffold(
      appBar: AppBar(
        // S6.2: the plan's target, night and state are in the strip below
        // (it wraps at large text, which an app bar's title cannot).
        title: const Text(AppWords.plan),
        actions: const [FieldModeButton(), _PlanMenu()],
      ),
      body: startupVm.hasBootstrapError
          ? _BootstrapErrorView(
              onRetry: () => context.read<StartupViewModel>().retryBootstrap(),
            )
          : startupVm.isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                const _PlanIdentity(),
                if (siteVm.isDefaultLocation) const _DefaultLocationBanner(),
                if (planVm.autosaveFailure != null)
                  const _AutosaveFailureBanner(),
                Expanded(
                  // S6.6 (ADR-019 §6; UX-01, UX-02): the answer first. Since
                  // S6.16 (ADR-019 §6 as amended by the owner): the context,
                  // the target, the rig and the capture plan, then the
                  // target's night as supporting analysis, then the
                  // conditions. Without a target or a rig the structure
                  // stays, with a neutral status.
                  child: ListView(
                    padding: const EdgeInsets.all(16.0),
                    children: [
                      const PlanStatus(),
                      KeyedSubtree(
                        key: const Key('planner.context'),
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
                            final picked = await pickNight(
                              context,
                              initial: planVm.eveningDate,
                            );
                            if (picked != null && context.mounted) {
                              await runWithFeedback(
                                context,
                                'change the night',
                                () => planVm.setEveningDate(picked),
                              );
                            }
                          },
                        ),
                      ),
                      _SectionHeader('Target'),
                      if (target != null) ...[
                        PlannerSummaryCard(
                          key: const Key('planner.target'),
                          title:
                              (target.commonName != null &&
                                  target.commonName != target.catalogId)
                              ? 'Target: ${target.commonName} (${target.catalogId})'
                              : 'Target: ${target.commonName ?? target.catalogId}',
                          data: {
                            'Type': target.type,
                            // ADR-010 §3: existing moving-type targets
                            // stay usable, with a visible warning.
                            if (TargetTypes.isMoving(target.type))
                              'Note': TargetTypes.movingWarning,
                            if (conditionsVm.currentAltitude != null)
                              // UX-15 (3): the altitude now, not on
                              // the planned night.
                              'Altitude now':
                                  '${conditionsVm.currentAltitude?.toStringAsFixed(1)}°',
                            // TASK 10.3: inside tonight's windows, not
                            // at culmination (possibly in daylight).
                            if (conditionsVm.imagingOpportunity case final o?)
                              'Max altitude in windows':
                                  o.maxAltitudeInWindowsDeg == null
                                  ? 'no window tonight'
                                  : '${o.maxAltitudeInWindowsDeg!.toStringAsFixed(1)}°',
                          },
                          onTap: () => context.push(AppRouter.selectTarget),
                        ),
                      ] else
                        _ChooseCard(
                          key: const Key('planner.noTarget'),
                          text: 'No target chosen.',
                          action: 'Choose a target',
                          onTap: () => context.push(AppRouter.selectTarget),
                        ),
                      _SectionHeader(AppWords.rig),
                      if (equipment != null) ...[
                        PlannerSummaryCard(
                          key: const Key('planner.rig'),
                          title: '${AppWords.rig}: ${equipment.name}',
                          data: {
                            // RD-04 (S6.8): the example says it is one.
                            if (equipment.isExample)
                              'Note': ExampleText.rigNote,
                            // S6.6: the values this plan uses first,
                            // then any active capability warning
                            // (TASK 8.6, guidance). S6.7: the reference
                            // rows are one tap away, below.
                            if (analysisVm.rigCapability case final cap?)
                              'Field of view': CapabilityText.fov(cap),
                            'Pixel scale': analysisVm.pixelScale != null
                                ? '${analysisVm.pixelScale!.toStringAsFixed(2)} arcsec/px'
                                : 'Unknown',
                            if (analysisVm.rigCapability case final cap?
                                when cap.frameFillFraction != null)
                              'Target size': CapabilityText.frameFill(cap)!,
                            if (analysisVm.rigCapability case final cap?
                                when cap.npf != null)
                              'NPF (untracked)': CapabilityText.npf(cap)!,
                            if (analysisVm.rigCapability case final cap?
                                when cap.recommendedMaxSubS != null)
                              'Max sub (guide)':
                                  CapabilityText.recommendedMaxSub(cap)!,
                          },
                          below: CollapsibleSection(
                            sectionKey: PlannerSections.rigDetails,
                            title: 'Specifications',
                            // A fact, and the review flag stays in view.
                            summary:
                                '${_trimNumber(equipment.focalLengthMm)} mm · '
                                '${_focalRatio(equipment)} · '
                                '${AppWords.tracking}: ${equipment.trackingType.label}',
                            child: Column(
                              children: [
                                for (final (label, value) in [
                                  (
                                    'Focal length',
                                    '${_trimNumber(equipment.focalLengthMm)} mm',
                                  ),
                                  ('Focal ratio', _focalRatio(equipment)),
                                  (
                                    'Sensor',
                                    '${_trimNumber(equipment.sensorWidthMm)} × ${_trimNumber(equipment.sensorHeightMm)} mm (${_trimNumber(equipment.pixelPitchUm)} µm pixels)',
                                  ),
                                  (
                                    AppWords.tracking,
                                    equipment.trackingType.label,
                                  ),
                                ])
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 8),
                                    child: InfoRow(label: label, value: value),
                                  ),
                              ],
                            ),
                          ),
                          onTap: () => context.push(AppRouter.selectRig),
                        ),
                      ] else
                        _ChooseCard(
                          key: const Key('planner.noRig'),
                          text: 'No rig chosen.',
                          action: AppWords.chooseRig,
                          onTap: () => context.push(AppRouter.selectRig),
                        ),
                      _SectionHeader(AppWords.capturePlan),
                      const CapturePlanWidget(),
                      // The target's night, supporting the plan (S6.16): the
                      // chart and the windows, after the plan is built. With
                      // a site but no target there is nothing to show yet
                      // (the status asks for the target), so no heading.
                      if (planVm.sessionNight == null) ...[
                        _SectionHeader(TonightOpportunityWidget.title),
                        const _NoSiteCard(
                          message:
                              "Set your site to see tonight's altitude chart.",
                        ),
                      ] else if (target != null) ...[
                        _SectionHeader(TonightOpportunityWidget.title),
                        const TonightOpportunityWidget(),
                      ],
                      _SectionHeader('Conditions'),
                      // S6.5 (UX-06, UX-10): the night and its
                      // forecast in full are on their detail screens;
                      // here one factual row each. Without a site the
                      // location card is shown (ADR-012).
                      if (planVm.sessionNight case final night?) ...[
                        _DetailRow(
                          key: const Key('planner.night'),
                          title: 'Night & Moon',
                          onTap: () => context.push(AppRouter.nightMoon),
                          child: NightSummary(
                            night: night,
                            conditions: conditionsVm,
                            zoneId: siteVm.displayZoneId,
                          ),
                        ),
                        _DetailRow(
                          key: const Key('planner.weather'),
                          title: 'Weather',
                          onTap: () => context.push(AppRouter.weather),
                          child: Text(
                            WeatherText.summary(
                              conditionsVm.nightWeather,
                              conditionsVm.nightWeatherSummary,
                            ),
                          ),
                        ),
                        // S6.7: the zone rule, once for the section's
                        // times (trap 2).
                        Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: Text(
                            ContextLine.zoneRule(
                              night.startUtc,
                              zoneId: siteVm.displayZoneId,
                            ),
                            key: const Key('planner.conditionsZone'),
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
                                  color: AppPalette.of(context).textTertiary,
                                ),
                          ),
                        ),
                      ] else
                        PlannerSummaryCard(
                          title: 'Location: ${siteVm.locationName ?? "Custom"}',
                          data: {
                            'Latitude': siteVm.latitude.toStringAsFixed(4),
                            'Longitude': siteVm.longitude.toStringAsFixed(4),
                            if (siteVm.locationNameAttribution != null)
                              'Place name': siteVm.locationNameAttribution!,
                          },
                          onTap: () => context.push(AppRouter.selectSite),
                        ),
                      const SkyDarknessWidget(),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ],
            ),
      bottomNavigationBar:
          target == null ||
              equipment == null ||
              startupVm.isLoading ||
              startupVm.hasBootstrapError ||
              planVm.sessionNight == null
          ? null
          // TASK 15.3: not a BottomAppBar — its fixed 80 px height squeezed
          // the buttons below the 48 px tap target (and clips large text).
          : Material(
              color: Theme.of(context).colorScheme.surfaceContainer,
              elevation: 3,
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 8.0,
                  ),
                  // S6.2 (ADR-019 §6): Save plan is the one primary action;
                  // Track live moved into the ⋮ menu.
                  child: FilledButton.icon(
                    key: const Key('planner.save'),
                    onPressed: () async {
                      // TASK 11.3 (ADR-014): saves the plan as a planned
                      // session with a fresh plan snapshot.
                      final saved = await runWithFeedback(
                        context,
                        'save the plan',
                        analysisVm.saveSession,
                      );
                      if (saved && context.mounted) {
                        showDone(context, 'Plan saved');
                      }
                    },
                    icon: const Icon(Icons.save_outlined),
                    label: const Text(AppWords.savePlan),
                  ),
                ),
              ),
            ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;

  const _SectionHeader(this.title);

  /// S6.16: the section-heading role of the type scale (DESIGN_SYSTEM §3),
  /// a semantic header, so the sections no longer outrank the answer.
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        top: 24.0,
        bottom: 12.0,
        left: 4.0,
        right: 4.0,
      ),
      child: Semantics(
        header: true,
        child: Text(
          title,
          style: Theme.of(context).textTheme.titleMedium
              ?.copyWith(color: AppPalette.of(context).textPrimary),
        ),
      ),
    );
  }
}

/// Shown instead of the whole screen when the initial load
/// (`StartupViewModel.hasBootstrapError`) failed.
class _BootstrapErrorView extends StatelessWidget {
  final VoidCallback onRetry;

  const _BootstrapErrorView({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 48,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 16),
            const Text(
              "Couldn't load your data.",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}

/// A missing target or rig in its section (S6.6): says so and offers the
/// picker; the planner's structure stays around it.
class _ChooseCard extends StatelessWidget {
  const _ChooseCard({
    super.key,
    required this.text,
    required this.action,
    required this.onTap,
  });

  final String text;
  final String action;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Wrap(
          spacing: 12,
          runSpacing: 8,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Text(text),
            OutlinedButton(onPressed: onTap, child: Text(action)),
          ],
        ),
      ),
    );
  }
}

/// A number without trailing zeros (e.g. 400.0 → "400", 3.76 → "3.76").
String _trimNumber(double value) =>
    value == value.roundToDouble() ? value.toInt().toString() : '$value';

/// The rig's focal ratio, with its review flag (TASK 8.4, trap 3).
String _focalRatio(EquipmentProfile rig) => rig.needsApertureReview
    ? 'f/${_trimNumber(rig.focalRatio)} — please review'
    : 'f/${rig.focalRatio.toStringAsFixed(1)}';

/// The first-run prompt (TASK 7.3), shown while the ViewModel has no site
/// or position and is using the hard-coded default. Nothing asks for the
/// location permission until the user chooses "Use current position".
class _DefaultLocationBanner extends StatelessWidget {
  const _DefaultLocationBanner();

  @override
  Widget build(BuildContext context) {
    return MaterialBanner(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      leading: const Icon(Icons.location_off_outlined),
      content: const Text(
        'Set up your observing site. Until then a default location is used '
        'and night times are not shown.',
      ),
      actions: [
        TextButton(
          onPressed: () => useCurrentPositionWithFeedback(
            context,
            context.read<SiteViewModel>(),
          ),
          child: const Text('Use current position'),
        ),
        TextButton(
          onPressed: () => context.push(AppRouter.selectSite),
          child: const Text('Set site'),
        ),
      ],
    );
  }
}

/// A factual summary row that opens a detail screen (S6.5; ADR-019 §6): a
/// title, the summary below it (wrapping at large text), and a chevron.
class _DetailRow extends StatelessWidget {
  const _DetailRow({
    super.key,
    required this.title,
    required this.child,
    required this.onTap,
  });

  final String title;
  final Widget child;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(title, style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: AppSpacing.xs),
                    child,
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

/// A plan edit could not be saved (TASK 15.1): the change is still on
/// screen, and the next edit tries again.
class _AutosaveFailureBanner extends StatelessWidget {
  const _AutosaveFailureBanner();

  @override
  Widget build(BuildContext context) {
    return const MaterialBanner(
      key: Key('planner.autosaveFailure'),
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      leading: Icon(Icons.sync_problem),
      content: Text(
        "Your latest changes couldn't be saved on this device. They stay "
        'on screen and are saved again with your next change.',
      ),
      actions: [SizedBox.shrink()],
    );
  }
}

/// Shown in place of a night-dependent section (the altitude chart) when
/// there is no site — there is no SessionNight to compute it from
/// (ADR-007 §9), so it must not silently use the default London
/// coordinates (SI-008).
class _NoSiteCard extends StatelessWidget {
  final String message;

  const _NoSiteCard({required this.message});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Icon(
              Icons.location_off_outlined,
              color: AppPalette.of(context).muted,
            ),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
      ),
    );
  }
}

/// The plan's actions (S6.2; ADR-019 §6): New plan, Copy to another night
/// and, for a saved plan, Track live — interim, until Stage 8 retires the
/// tracker (P8.4). Each says what happened.
class _PlanMenu extends StatelessWidget {
  const _PlanMenu();

  @override
  Widget build(BuildContext context) {
    final plan = context.watch<SessionPlanViewModel>();
    final session = plan.activeSession;
    final state = session == null ? null : PlanState.of(session);
    // Start's requirements (a site, a target, a rig), for a saved plan.
    final canTrack =
        (state == PlanState.saved || state == PlanState.savedChanged) &&
        plan.sessionNight != null &&
        plan.selectedTarget != null &&
        plan.selectedEquipment != null;
    return PopupMenuButton<_PlanAction>(
      key: const Key('planner.menu'),
      tooltip: 'Plan actions',
      icon: const Icon(Icons.more_vert),
      onSelected: (action) => switch (action) {
        _PlanAction.newPlan => _newPlan(context),
        _PlanAction.copy => _copy(context),
        _PlanAction.trackLive => startSessionWithFeedback(context),
      },
      itemBuilder: (context) => [
        const PopupMenuItem(
          key: Key('planner.newPlan'),
          value: _PlanAction.newPlan,
          child: Text(AppWords.newPlan),
        ),
        const PopupMenuItem(
          key: Key('planner.copy'),
          value: _PlanAction.copy,
          child: Text(AppWords.copyToAnotherNight),
        ),
        if (canTrack)
          const PopupMenuItem(
            key: Key('planner.start'),
            value: _PlanAction.trackLive,
            child: Text(AppWords.trackLiveOptional),
          ),
      ],
    );
  }

  static Future<void> _newPlan(BuildContext context) async {
    // S6.3 (U1): Save · Discard · Cancel before an unsaved plan is left.
    final leaving = await askBeforeLeavingPlan(context);
    if (leaving == null || !context.mounted) return;
    final started = await runWithFeedback(
      context,
      'start a new plan',
      () => context.read<PlanLifecycleViewModel>().newSession(
        discard: leaving == LeavingPlan.discard,
      ),
    );
    if (started && context.mounted) showDone(context, 'New plan started');
  }

  /// TASK 11.4: a copy of the current plan as a new draft for another
  /// night; the current session is not changed.
  static Future<void> _copy(BuildContext context) async {
    final lifecycle = context.read<PlanLifecycleViewModel>();
    final night = context.read<SessionPlanViewModel>().eveningDate;
    final leaving = await askBeforeLeavingPlan(context);
    if (leaving == null || !context.mounted) return;
    final picked = await pickNight(context, initial: night?.addDays(1));
    if (picked == null || !context.mounted) return;
    final copied = await runWithFeedback(
      context,
      'copy the plan',
      () => lifecycle.duplicateForNight(
        picked,
        discard: leaving == LeavingPlan.discard,
      ),
    );
    if (copied && context.mounted) {
      showDone(context, 'Copied to ${NightTimeFormatter.eveningDate(picked)}');
    }
  }
}

enum _PlanAction { newPlan, copy, trackLive }

/// Which plan the planner shows (S6.2; UX-04, ADR-019 §6): the target, the
/// night and the plan's state, under the app bar. It wraps at large text.
class _PlanIdentity extends StatelessWidget {
  const _PlanIdentity();

  @override
  Widget build(BuildContext context) {
    final plan = context.watch<SessionPlanViewModel>();
    final target = plan.selectedTarget;
    final evening = plan.eveningDate;
    final session = plan.activeSession;
    final text = Theme.of(context).textTheme;
    return Semantics(
      key: const Key('planner.identity'),
      container: true,
      child: Material(
        color: Theme.of(context).colorScheme.surfaceContainer,
        child: SizedBox(
          width: double.infinity,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.md,
              AppSpacing.xs,
              AppSpacing.md,
              AppSpacing.sm,
            ),
            child: Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.xs,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Text(
                  target == null
                      ? 'No target'
                      : target.commonName ?? target.catalogId,
                  style: text.titleMedium,
                ),
                Text(
                  evening == null
                      ? 'No night without a site'
                      : '${AppWords.nightOf} '
                            '${NightTimeFormatter.eveningDate(evening)}',
                  style: text.bodyMedium,
                ),
                if (session != null) PlanStateLabel(PlanState.of(session)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
