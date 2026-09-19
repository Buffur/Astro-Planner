import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../viewmodels/planner_viewmodel.dart';
import '../../widgets/planner_summary_card.dart';
import '../../../domain/repositories/logbook_repository.dart';
import '../../../domain/models/session_log.dart';
import '../../../domain/models/capture_block.dart';
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
          IconButton(
            icon: Icon(context.watch<ThemeViewModel>().isFieldMode ? Icons.wb_sunny : Icons.nightlight_round),
            tooltip: 'Toggle Field Mode',
            onPressed: () => context.read<ThemeViewModel>().toggleFieldMode(),
          ),
          IconButton(
            icon: const Icon(Icons.book),
            tooltip: 'Logbook',
            onPressed: () => context.push('/logbook'),
          ),
          IconButton(
            icon: const Icon(Icons.info_outline),
            tooltip: 'Import Metadata',
            onPressed: () => context.push('/metadata'),
          ),
        ],
      ),
      body: viewModel.isLoading
          ? const Center(child: CircularProgressIndicator())
          : target == null || equipment == null
              ? const Center(
                  child: Padding(
                    padding: EdgeInsets.all(32.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.auto_awesome, size: 48, color: Colors.grey),
                        SizedBox(height: 16),
                        Text(
                          'Select a Target and Equipment profile to begin planning.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.grey, fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                )
              : ListView(
                  padding: const EdgeInsets.all(16.0),
                  children: [
                    _SectionHeader('Target / What'),
                    PlannerSummaryCard(
                      title: (target.commonName != null && target.commonName != target.catalogId)
                          ? 'Target: ${target.commonName} (${target.catalogId})'
                          : 'Target: ${target.commonName ?? target.catalogId}',
                      data: {
                        'Type': target.type,
                        if (viewModel.currentAltitude != null) 'Current Altitude': '${viewModel.currentAltitude?.toStringAsFixed(1)}°',
                        if (viewModel.maxAltitude != null) 'Max Altitude': '${viewModel.maxAltitude?.toStringAsFixed(1)}°',
                      },
                      onTap: () => context.push('/target'),
                    ),
                    Card(
                      margin: const EdgeInsets.only(bottom: 16),
                      clipBehavior: Clip.antiAlias,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: AltitudeChartWidget(
                          target: target,
                          latitude: viewModel.latitude,
                          longitude: viewModel.longitude,
                          sessionDate: viewModel.sessionDate,
                          minAltitude: viewModel.minAltitude,
                        ),
                      ),
                    ),
                    _SectionHeader('Equipment / How'),
                    PlannerSummaryCard(
                      title: 'Equipment: ${equipment.name}',
                      data: {
                        'Pixel Scale': '${viewModel.pixelScale?.toStringAsFixed(2)} arcsec/px',
                        'Aperture': 'f/${equipment.aperture.toStringAsFixed(1)}',
                        'Sensor': '${equipment.sensorWidth}x${equipment.sensorHeight}mm (${equipment.pixelPitch}µm pixels)',
                      },
                      onTap: () => context.push('/equipment'),
                    ),
                    _SectionHeader('Conditions & Timeline / When'),
                    Card(
                      margin: const EdgeInsets.only(bottom: 16),
                      child: ListTile(
                        leading: const Icon(Icons.calendar_month),
                        title: const Text('Session Date'),
                        subtitle: Text('${viewModel.sessionDate.year}-${viewModel.sessionDate.month.toString().padLeft(2, '0')}-${viewModel.sessionDate.day.toString().padLeft(2, '0')} (Night)'),
                        trailing: const Icon(Icons.edit, size: 16),
                        onTap: () async {
                          final now = DateTime.now();
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: viewModel.sessionDate,
                            firstDate: DateTime(now.year - 1, now.month, now.day),
                            lastDate: DateTime(now.year + 5, now.month, now.day),
                          );
                          if (picked != null) {
                            viewModel.setSessionDate(picked);
                          }
                        },
                      ),
                    ),
                    if (viewModel.currentWeather != null)
                      WeatherForecastWidget(
                        weather: viewModel.currentWeather!,
                        onTap: () => context.push('/location'),
                      )
                    else
                      PlannerSummaryCard(
                        title: 'Location: ${viewModel.locationName ?? "Custom"}',
                        data: {
                          'Latitude': viewModel.latitude.toStringAsFixed(4),
                          'Longitude': viewModel.longitude.toStringAsFixed(4),
                        },
                        onTap: () => context.push('/location'),
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
                              Icon(Icons.warning_amber_rounded, color: Colors.deepOrange),
                              SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  'Sky Warning: High light pollution or bright Moon will wash out faint targets!',
                                  style: TextStyle(color: Colors.deepOrange, fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    Card(
                      margin: const EdgeInsets.only(bottom: 16),
                      color: Theme.of(context).cardTheme.color,
                      child: InkWell(
                        onTap: () async {
                          final url = Uri.parse('https://www.lightpollutionmap.info/#zoom=4.00&lat=45.8720&lon=14.5470&state=eyJiYXNlbWFwIjoiTGF5ZXJCaW5nUm9hZCIsIm92ZXJsYXkiOiJzYl8yMDI1Iiwib3ZlcmxheWNvbG9yIjpmYWxzZSwib3ZlcmxheW9wYWNpdHkiOiI2MCIsImZlYXR1cmVzb3BhY2l0eSI6Ijg1In0=');
                          if (await canLaunchUrl(url)) {
                            await launchUrl(url, mode: LaunchMode.externalApplication);
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
                                  style: TextStyle(fontWeight: FontWeight.bold),
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
      bottomNavigationBar: target == null || equipment == null || viewModel.isLoading
          ? null
          : BottomAppBar(
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      final int lightFrames = viewModel.captureBlocks
                          .where((b) => b.frameType == FrameType.light)
                          .fold(0, (sum, b) => sum + b.frameCount);
                      
                      final log = viewModel.activeSessionLog?.copyWith(
                        targetName: target.commonName ?? target.catalogId,
                        equipmentName: equipment.name,
                        sessionDate: viewModel.sessionDate,
                        plannedLightFrames: lightFrames,
                        captureBlocks: viewModel.captureBlocks,
                      ) ?? SessionLog(
                        id: 0,
                        targetName: target.commonName ?? target.catalogId,
                        equipmentName: equipment.name,
                        sessionDate: viewModel.sessionDate,
                        plannedLightFrames: lightFrames,
                        captureBlocks: viewModel.captureBlocks,
                      );

                      if (viewModel.activeSessionId != null) {
                        await context.read<LogbookRepository>().updateLog(log);
                      } else {
                        await context.read<LogbookRepository>().addLog(log);
                      }
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Session saved to Logbook!')),
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
      padding: const EdgeInsets.only(top: 24.0, bottom: 12.0, left: 4.0, right: 4.0),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
