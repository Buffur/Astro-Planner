import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/config/feature_scope.dart';
import '../../navigation/app_router.dart';
import '../../viewmodels/startup_viewmodel.dart';
import '../../viewmodels/site_viewmodel.dart';
import '../../viewmodels/session_plan_viewmodel.dart';
import '../../viewmodels/night_conditions_viewmodel.dart';
import '../../viewmodels/capture_analysis_viewmodel.dart';
import '../../widgets/planner_summary_card.dart';
import '../../shared/capability_text.dart';
import '../../shared/light_pollution_map_link.dart';
import '../../shared/location_feedback.dart';
import '../../shared/start_session.dart';
import '../../shared/night_time_formatter.dart';
import '../../../domain/models/calendar_date.dart';
import '../../../domain/models/astro_target.dart';
import '../../../domain/models/equipment_profile.dart';
import '../../../domain/models/target_types.dart';
import '../../shared/field_mode_button.dart';
import '../../widgets/capture_plan_widget.dart';
import '../../widgets/tonight_opportunity_widget.dart';
import '../../widgets/sky_darkness_widget.dart';
import '../../widgets/weather_forecast_widget.dart';
import '../../../core/theme/app_palette.dart';

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
        title: const Text('Session planner'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'New Session',
            onPressed: () => context.read<SessionPlanViewModel>().newSession(),
          ),
          // TASK 11.4: a copy of the current plan as a new draft for another
          // night; the current session is not changed.
          IconButton(
            icon: const Icon(Icons.copy_all),
            tooltip: 'Duplicate for another night',
            onPressed: () async {
              final planVm = context.read<SessionPlanViewModel>();
              final now = DateTime.now();
              final picked = await showDatePicker(
                context: context,
                initialDate: now.add(const Duration(days: 1)),
                firstDate: DateTime(now.year - 1, now.month, now.day),
                lastDate: DateTime(now.year + 5, now.month, now.day),
                helpText: 'Duplicate for which night?',
              );
              if (picked != null) {
                await planVm.duplicateForNight(
                  CalendarDate.fromDateTimeFields(picked),
                );
              }
            },
          ),
          const FieldModeButton(),
          // TASK 12.2 (ADR-015): candidates, settings, the logbook and
          // metadata import moved to the Tonight, Settings and Sessions tabs.
        ],
      ),
      body: startupVm.hasBootstrapError
          ? _BootstrapErrorView(
              onRetry: () => context.read<StartupViewModel>().retryBootstrap(),
            )
          : startupVm.isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                if (siteVm.isDefaultLocation) const _DefaultLocationBanner(),
                Expanded(
                  child: target == null || equipment == null
                      ? _EmptyStateView(target: target, equipment: equipment)
                      : ListView(
                          padding: const EdgeInsets.all(16.0),
                          children: [
                            _SectionHeader('Target / What'),
                            PlannerSummaryCard(
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
                                  'Current Altitude':
                                      '${conditionsVm.currentAltitude?.toStringAsFixed(1)}°',
                                // TASK 10.3: inside tonight's windows, not
                                // at culmination (possibly in daylight).
                                if (conditionsVm.imagingOpportunity
                                    case final o?)
                                  'Max altitude in windows':
                                      o.maxAltitudeInWindowsDeg == null
                                      ? 'no window tonight'
                                      : '${o.maxAltitudeInWindowsDeg!.toStringAsFixed(1)}°',
                              },
                              onTap: () => context.push(AppRouter.selectTarget),
                            ),
                            if (planVm.sessionNight != null)
                              const TonightOpportunityWidget()
                            else
                              const _NoSiteCard(
                                message: "Set your site to see tonight's altitude chart.",
                              ),
                            _SectionHeader('Equipment / How'),
                            PlannerSummaryCard(
                              title: 'Equipment: ${equipment.name}',
                              data: {
                                'Pixel Scale': analysisVm.pixelScale != null
                                    ? '${analysisVm.pixelScale!.toStringAsFixed(2)} arcsec/px'
                                    : 'Unknown',
                                // TASK 8.6: capability summary (guidance).
                                if (analysisVm.rigCapability case final cap?)
                                  'Field of view': CapabilityText.fov(cap),
                                if (analysisVm.rigCapability case final cap?
                                    when cap.npf != null)
                                  'NPF (untracked)': CapabilityText.npf(cap)!,
                                if (analysisVm.rigCapability case final cap?
                                    when cap.recommendedMaxSubS != null)
                                  'Max sub (guide)':
                                      CapabilityText.recommendedMaxSub(cap)!,
                                if (analysisVm.rigCapability case final cap?
                                    when cap.frameFillFraction != null)
                                  'Target size': CapabilityText.frameFill(cap)!,
                                'Focal length':
                                    '${_trimNumber(equipment.focalLengthMm)} mm',
                                'Focal ratio': equipment.needsApertureReview
                                    ? 'f/${_trimNumber(equipment.focalRatio)} — please review'
                                    : 'f/${equipment.focalRatio.toStringAsFixed(1)}',
                                'Sensor':
                                    '${_trimNumber(equipment.sensorWidthMm)} × ${_trimNumber(equipment.sensorHeightMm)} mm (${_trimNumber(equipment.pixelPitchUm)} µm pixels)',
                                'Tracking': equipment.trackingType.label,
                              },
                              onTap: () => context.push(AppRouter.selectRig),
                            ),
                            _SectionHeader('Conditions & Timeline / When'),
                            Card(
                              margin: const EdgeInsets.only(bottom: 16),
                              child: ListTile(
                                leading: const Icon(Icons.calendar_month),
                                title: const Text('Session Date'),
                                subtitle: Text(
                                  planVm.eveningDate != null
                                      ? 'Night of ${NightTimeFormatter.eveningDate(planVm.eveningDate!)}'
                                      : 'No site set',
                                ),
                                trailing: const Icon(Icons.edit, size: 16),
                                onTap: () async {
                                  final evening = planVm.eveningDate;
                                  final now = DateTime.now();
                                  final picked = await showDatePicker(
                                    context: context,
                                    initialDate: evening != null
                                        ? DateTime(
                                            evening.year,
                                            evening.month,
                                            evening.day,
                                          )
                                        : now,
                                    firstDate: DateTime(
                                      now.year - 1,
                                      now.month,
                                      now.day,
                                    ),
                                    lastDate: DateTime(
                                      now.year + 5,
                                      now.month,
                                      now.day,
                                    ),
                                  );
                                  if (picked != null) {
                                    planVm.setEveningDate(
                                      CalendarDate.fromDateTimeFields(picked),
                                    );
                                  }
                                },
                              ),
                            ),
                            // The night's forecast needs a night (ADR-012);
                            // without a site the location card is shown.
                            if (planVm.sessionNight != null)
                              WeatherForecastWidget(
                                onTap: () => context.push(AppRouter.selectSite),
                              )
                            else
                              PlannerSummaryCard(
                                title:
                                    'Location: ${siteVm.locationName ?? "Custom"}',
                                data: {
                                  'Latitude': siteVm.latitude.toStringAsFixed(
                                    4,
                                  ),
                                  'Longitude': siteVm.longitude.toStringAsFixed(
                                    4,
                                  ),
                                  if (siteVm.locationNameAttribution != null)
                                    'Place name':
                                        siteVm.locationNameAttribution!,
                                },
                                onTap: () => context.push(AppRouter.selectSite),
                              ),
                            const SkyDarknessWidget(),
                            // TASK 10.3 (ADR-013 §6): the fixed sky warning
                            // is gone; the Moon and sky darkness are shown as
                            // facts per window and in the card above.
                            // TASK 7.4 (PD-05 option A): the external map,
                            // centred on the current position. Hidden
                            // without one — the London default is not the
                            // user's sky.
                            if (FeatureScope.lightPollutionContext &&
                                !siteVm.isDefaultLocation)
                              Card(
                                margin: const EdgeInsets.only(bottom: 16),
                                color: Theme.of(context).cardTheme.color,
                                child: InkWell(
                                  onTap: () async {
                                    final url = LightPollutionMapLink.at(
                                      siteVm.latitude,
                                      siteVm.longitude,
                                    );
                                    if (await canLaunchUrl(url)) {
                                      await launchUrl(
                                        url,
                                        mode: LaunchMode.externalApplication,
                                      );
                                    }
                                  },
                                  borderRadius: BorderRadius.circular(6),
                                  child: const Padding(
                                    padding: EdgeInsets.all(16.0),
                                    child: Row(
                                      children: [
                                        Icon(Icons.map_outlined),
                                        SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                'Open Light Pollution Map',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              Text(
                                                'Centred here. Read the value, '
                                                'then enter it as Bortle or '
                                                'SQM for your site.',
                                              ),
                                            ],
                                          ),
                                        ),
                                        Icon(Icons.open_in_browser),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            _SectionHeader('Capture Plan'),
                            const CapturePlanWidget(),
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
          : BottomAppBar(
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 8.0,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () async {
                            // TASK 11.3 (ADR-014): saves the plan as a
                            // planned session with a fresh plan snapshot.
                            await analysisVm.saveSession();
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Session saved to Logbook!'),
                                ),
                              );
                            }
                          },
                          icon: const Icon(Icons.save),
                          label: const Text('Save Session'),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.all(16),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      // TASK 13.3 (ADR-016): start tracking this plan.
                      Expanded(
                        child: FilledButton.icon(
                          key: const Key('planner.start'),
                          onPressed: () => startSessionWithFeedback(context),
                          icon: const Icon(Icons.play_arrow),
                          label: const Text('Start'),
                          style: FilledButton.styleFrom(
                            padding: const EdgeInsets.all(16),
                          ),
                        ),
                      ),
                    ],
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

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        top: 24.0,
        bottom: 12.0,
        left: 4.0,
        right: 4.0,
      ),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleLarge
            ?.copyWith(fontWeight: FontWeight.bold),
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

/// Shown when target and/or equipment have not been selected yet, with an
/// action for each missing piece.
class _EmptyStateView extends StatelessWidget {
  final AstroTarget? target;
  final EquipmentProfile? equipment;

  const _EmptyStateView({required this.target, required this.equipment});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.auto_awesome,
              size: 48,
              color: AppPalette.of(context).muted,
            ),
            const SizedBox(height: 16),
            Text(
              'Select a Target and Equipment profile to begin planning.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppPalette.of(context).muted,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 20),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              alignment: WrapAlignment.center,
              children: [
                if (target == null)
                  ElevatedButton.icon(
                    onPressed: () => context.push(AppRouter.selectTarget),
                    icon: const Icon(Icons.explore_outlined),
                    label: const Text('Choose a Target'),
                  ),
                if (equipment == null)
                  ElevatedButton.icon(
                    onPressed: () => context.push(AppRouter.selectRig),
                    icon: const Icon(Icons.camera_alt_outlined),
                    label: const Text('Choose Equipment'),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// A number without trailing zeros (e.g. 400.0 → "400", 3.76 → "3.76").
String _trimNumber(double value) =>
    value == value.roundToDouble() ? value.toInt().toString() : '$value';

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
