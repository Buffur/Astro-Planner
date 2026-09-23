import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/config/feature_scope.dart';
import '../../viewmodels/planner_viewmodel.dart';
import '../../widgets/planner_summary_card.dart';
import '../../shared/location_feedback.dart';
import '../../shared/night_time_formatter.dart';
import '../../../domain/models/calendar_date.dart';
import '../../../domain/repositories/logbook_repository.dart';
import '../../../domain/models/session_log.dart';
import '../../../domain/models/capture_block.dart';
import '../../../domain/models/astro_target.dart';
import '../../../domain/models/equipment_profile.dart';
import '../../viewmodels/theme_viewmodel.dart';
import '../../widgets/capture_plan_widget.dart';
import '../../widgets/altitude_chart_widget.dart';
import '../../widgets/sky_darkness_widget.dart';
import '../../widgets/weather_forecast_widget.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<PlannerViewModel>();
    final target = viewModel.selectedTarget;
    final equipment = viewModel.selectedEquipment;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Session Planner'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'New Session',
            onPressed: () => context.read<PlannerViewModel>().newSession(),
          ),
          if (FeatureScope.fieldMode)
            IconButton(
              icon: Icon(
                context.watch<ThemeViewModel>().isFieldMode
                    ? Icons.wb_sunny
                    : Icons.nightlight_round,
              ),
              tooltip: 'Toggle Field Mode',
              onPressed: () => context.read<ThemeViewModel>().toggleFieldMode(),
            ),
          IconButton(
            icon: const Icon(Icons.tune),
            tooltip: 'Planning Settings',
            onPressed: () => context.push('/settings'),
          ),
          if (FeatureScope.logbook)
            IconButton(
              icon: const Icon(Icons.book),
              tooltip: 'Logbook',
              onPressed: () => context.push('/logbook'),
            ),
          if (FeatureScope.metadataImport)
            IconButton(
              icon: const Icon(Icons.info_outline),
              tooltip: 'Import Metadata',
              onPressed: () => context.push('/metadata'),
            ),
        ],
      ),
      body: viewModel.hasBootstrapError
          ? _BootstrapErrorView(
              onRetry: () => context.read<PlannerViewModel>().retryBootstrap(),
            )
          : viewModel.isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                if (viewModel.isDefaultLocation) const _DefaultLocationBanner(),
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
                                if (viewModel.currentAltitude != null)
                                  'Current Altitude':
                                      '${viewModel.currentAltitude?.toStringAsFixed(1)}°',
                                if (viewModel.maxAltitude != null)
                                  'Max Altitude':
                                      '${viewModel.maxAltitude?.toStringAsFixed(1)}°',
                              },
                              onTap: () => context.push('/target'),
                            ),
                            if (viewModel.sessionNight != null)
                              Card(
                                margin: const EdgeInsets.only(bottom: 16),
                                clipBehavior: Clip.antiAlias,
                                child: Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: AltitudeChartWidget(
                                    target: target,
                                    night: viewModel.sessionNight!,
                                    minAltitude: viewModel.minAltitude,
                                    zoneId: viewModel.displayZoneId,
                                  ),
                                ),
                              )
                            else
                              const _NoSiteCard(
                                message: "Set your site to see tonight's altitude chart.",
                              ),
                            _SectionHeader('Equipment / How'),
                            PlannerSummaryCard(
                              title: 'Equipment: ${equipment.name}',
                              data: {
                                'Pixel Scale': viewModel.pixelScale != null
                                    ? '${viewModel.pixelScale!.toStringAsFixed(2)} arcsec/px'
                                    : 'Unknown',
                                'Aperture':
                                    'f/${equipment.aperture.toStringAsFixed(1)}',
                                'Sensor':
                                    '${equipment.sensorWidth}x${equipment.sensorHeight}mm (${equipment.pixelPitch}µm pixels)',
                              },
                              onTap: () => context.push('/equipment'),
                            ),
                            _SectionHeader('Conditions & Timeline / When'),
                            Card(
                              margin: const EdgeInsets.only(bottom: 16),
                              child: ListTile(
                                leading: const Icon(Icons.calendar_month),
                                title: const Text('Session Date'),
                                subtitle: Text(
                                  viewModel.eveningDate != null
                                      ? 'Night of ${NightTimeFormatter.eveningDate(viewModel.eveningDate!)}'
                                      : 'No site set',
                                ),
                                trailing: const Icon(Icons.edit, size: 16),
                                onTap: () async {
                                  final evening = viewModel.eveningDate;
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
                                    viewModel.setEveningDate(
                                      CalendarDate.fromDateTimeFields(picked),
                                    );
                                  }
                                },
                              ),
                            ),
                            if (viewModel.currentWeather != null)
                              WeatherForecastWidget(
                                weather: viewModel.currentWeather!,
                                onTap: () => context.push('/sites'),
                              )
                            else if (viewModel.weatherError)
                              _WeatherErrorCard(
                                onRetry: () => context
                                    .read<PlannerViewModel>()
                                    .refreshWeather(),
                              )
                            else
                              PlannerSummaryCard(
                                title:
                                    'Location: ${viewModel.locationName ?? "Custom"}',
                                data: {
                                  'Latitude': viewModel.latitude
                                      .toStringAsFixed(4),
                                  'Longitude': viewModel.longitude
                                      .toStringAsFixed(4),
                                  if (viewModel.locationNameAttribution != null)
                                    'Place name':
                                        viewModel.locationNameAttribution!,
                                },
                                onTap: () => context.push('/sites'),
                              ),
                            const SkyDarknessWidget(),
                            if (viewModel.skyDarknessWarning)
                              Card(
                                margin: const EdgeInsets.only(bottom: 16),
                                color: Colors.orange.shade100,
                                child: const Padding(
                                  padding: EdgeInsets.all(16.0),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.warning_amber_rounded,
                                        color: Colors.deepOrange,
                                      ),
                                      SizedBox(width: 12),
                                      Expanded(
                                        child: Text(
                                          'Sky Warning: High light pollution or a bright Moon reduces contrast on faint targets.',
                                          style: TextStyle(
                                            color: Colors.deepOrange,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            // TD-014: hidden until TASK 7.4 — the hard-coded
                            // Slovenia coordinates below aren't the site's,
                            // so it stays hidden rather than gaining a real
                            // gate that just shows a wrong location (PD-06
                            // E.1; fixing the coordinates is 7.4's job, not
                            // this one).
                            if (FeatureScope.lightPollutionContext)
                              Card(
                                margin: const EdgeInsets.only(bottom: 16),
                                color: Theme.of(context).cardTheme.color,
                                child: InkWell(
                                  onTap: () async {
                                    final url = Uri.parse(
                                      'https://www.lightpollutionmap.info/#zoom=4.00&lat=45.8720&lon=14.5470&state=eyJiYXNlbWFwIjoiTGF5ZXJCaW5nUm9hZCIsIm92ZXJsYXkiOiJzYl8yMDI1Iiwib3ZlcmxheWNvbG9yIjpmYWxzZSwib3ZlcmxheW9wYWNpdHkiOiI2MCIsImZlYXR1cmVzb3BhY2l0eSI6Ijg1In0=',
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
                                          child: Text(
                                            'Open Light Pollution Map',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                            ),
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
              viewModel.isLoading ||
              viewModel.hasBootstrapError ||
              viewModel.sessionNight == null
          ? null
          : BottomAppBar(
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 8.0,
                  ),
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      final int lightFrames = viewModel.captureBlocks
                          .where((b) => b.frameType == FrameType.light)
                          .fold(0, (sum, b) => sum + b.frameCount);
                      // The button is only shown when sessionNight != null.
                      final evening = viewModel.eveningDate!;
                      // Legacy storage: SessionLog.sessionDate is still an
                      // instant (G11 persists SessionNight properly). Local
                      // midnight of the evening date round-trips correctly
                      // through loadSession (ADR-007 §10 "legacy rows").
                      final sessionDateInstant = DateTime(
                        evening.year,
                        evening.month,
                        evening.day,
                      );

                      final log =
                          viewModel.activeSessionLog?.copyWith(
                            targetName: target.commonName ?? target.catalogId,
                            equipmentName: equipment.name,
                            sessionDate: sessionDateInstant,
                            plannedLightFrames: lightFrames,
                            captureBlocks: viewModel.captureBlocks,
                          ) ??
                          SessionLog(
                            id: 0,
                            targetName: target.commonName ?? target.catalogId,
                            equipmentName: equipment.name,
                            sessionDate: sessionDateInstant,
                            plannedLightFrames: lightFrames,
                            captureBlocks: viewModel.captureBlocks,
                          );

                      // TD-011: track the saved row's id so a second tap
                      // updates it instead of inserting a duplicate.
                      if (viewModel.activeSessionId != null) {
                        await context.read<LogbookRepository>().updateLog(log);
                        viewModel.markSessionSaved(log);
                      } else {
                        final newId = await context
                            .read<LogbookRepository>()
                            .addLog(log);
                        viewModel.markSessionSaved(log.copyWith(id: newId));
                      }
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
/// (`PlannerViewModel.hasBootstrapError`) failed.
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
            const Icon(Icons.error_outline, size: 48, color: Colors.redAccent),
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
            const Icon(Icons.auto_awesome, size: 48, color: Colors.grey),
            const SizedBox(height: 16),
            const Text(
              'Select a Target and Equipment profile to begin planning.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey, fontSize: 16),
            ),
            const SizedBox(height: 20),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              alignment: WrapAlignment.center,
              children: [
                if (target == null)
                  ElevatedButton.icon(
                    onPressed: () => context.push('/target'),
                    icon: const Icon(Icons.explore_outlined),
                    label: const Text('Choose a Target'),
                  ),
                if (equipment == null)
                  ElevatedButton.icon(
                    onPressed: () => context.push('/equipment'),
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
            context.read<PlannerViewModel>(),
          ),
          child: const Text('Use current position'),
        ),
        TextButton(
          onPressed: () => context.push('/sites'),
          child: const Text('Set site'),
        ),
      ],
    );
  }
}

/// Shown in place of the weather card when the most recent fetch failed.
class _WeatherErrorCard extends StatelessWidget {
  final VoidCallback onRetry;

  const _WeatherErrorCard({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            const Icon(Icons.cloud_off, color: Colors.grey),
            const SizedBox(width: 12),
            const Expanded(child: Text("Couldn't load weather.")),
            TextButton(onPressed: onRetry, child: const Text('Retry')),
          ],
        ),
      ),
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
            const Icon(Icons.location_off_outlined, color: Colors.grey),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
      ),
    );
  }
}
