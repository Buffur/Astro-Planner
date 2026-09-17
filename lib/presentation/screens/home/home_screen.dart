import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../viewmodels/planner_viewmodel.dart';
import '../../widgets/planner_summary_card.dart';
import '../../../domain/repositories/logbook_repository.dart';
import '../../../domain/models/session_log.dart';
import '../../viewmodels/theme_viewmodel.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  void _showLocationDialog(BuildContext context, PlannerViewModel viewModel) {
    final latCtrl = TextEditingController(text: viewModel.latitude.toString());
    final lonCtrl = TextEditingController(text: viewModel.longitude.toString());

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Set Location (Lat, Lon)'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: latCtrl,
                keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
                decoration: const InputDecoration(labelText: 'Latitude'),
              ),
              TextField(
                controller: lonCtrl,
                keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
                decoration: const InputDecoration(labelText: 'Longitude'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final lat = double.tryParse(latCtrl.text);
                final lon = double.tryParse(lonCtrl.text);
                if (lat != null && lon != null) {
                  viewModel.setLocation(lat, lon);
                }
                Navigator.of(context).pop();
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

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
      body: target == null || equipment == null
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
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
                PlannerSummaryCard(
                  title: 'Equipment: ${equipment.name}',
                  data: {
                    'Pixel Scale': '${viewModel.pixelScale?.toStringAsFixed(2)} arcsec/px',
                    'Aperture': 'f/${equipment.aperture.toStringAsFixed(1)}',
                    'Sensor': '${equipment.sensorWidth}x${equipment.sensorHeight}mm (${equipment.pixelPitch}µm pixels)',
                  },
                  onTap: () => context.push('/equipment'),
                ),
                if (viewModel.currentWeather != null)
                  PlannerSummaryCard(
                    title: 'Weather (${viewModel.latitude.toStringAsFixed(2)}, ${viewModel.longitude.toStringAsFixed(2)})',
                    data: {
                      'Temperature': '${viewModel.currentWeather!.temperature.toStringAsFixed(1)}°C',
                      'Cloud Cover': '${viewModel.currentWeather!.cloudCover.toStringAsFixed(0)}%',
                      'Dew Point': '${viewModel.currentWeather!.dewPoint.toStringAsFixed(1)}°C',
                    },
                    onTap: () => _showLocationDialog(context, viewModel),
                  ),
                if (viewModel.currentWeather?.dewWarning == true)
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
                              'Dew Warning: Temperature is close to dew point. Activate dew heaters!',
                              style: TextStyle(color: Colors.deepOrange, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Sky Conditions', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Moon Illumination:'),
                            Text('${(viewModel.lunarIllumination * 100).toStringAsFixed(1)}%', style: const TextStyle(fontWeight: FontWeight.bold)),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Bortle Class:'),
                            DropdownButton<int>(
                              value: viewModel.bortleClass,
                              items: List.generate(9, (index) => DropdownMenuItem(
                                value: index + 1,
                                child: Text('Class ${index + 1}'),
                              )),
                              onChanged: (val) {
                                if (val != null) viewModel.setBortleClass(val);
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
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
                Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Capture Plan', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Light Frames:'),
                            Row(
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.remove_circle_outline),
                                  onPressed: () => viewModel.setLightFrames(viewModel.lightFrames - 10 > 0 ? viewModel.lightFrames - 10 : 0),
                                ),
                                Text('${viewModel.lightFrames}', style: const TextStyle(fontWeight: FontWeight.bold)),
                                IconButton(
                                  icon: const Icon(Icons.add_circle_outline),
                                  onPressed: () => viewModel.setLightFrames(viewModel.lightFrames + 10),
                                ),
                              ],
                            )
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Dark Frames:'),
                            Row(
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.remove_circle_outline),
                                  onPressed: () => viewModel.setDarkFrames(viewModel.darkFrames - 10 > 0 ? viewModel.darkFrames - 10 : 0),
                                ),
                                Text('${viewModel.darkFrames}', style: const TextStyle(fontWeight: FontWeight.bold)),
                                IconButton(
                                  icon: const Icon(Icons.add_circle_outline),
                                  onPressed: () => viewModel.setDarkFrames(viewModel.darkFrames + 10),
                                ),
                              ],
                            )
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Flat Frames:'),
                            Row(
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.remove_circle_outline),
                                  onPressed: () => viewModel.setFlatFrames(viewModel.flatFrames - 10 > 0 ? viewModel.flatFrames - 10 : 0),
                                ),
                                Text('${viewModel.flatFrames}', style: const TextStyle(fontWeight: FontWeight.bold)),
                                IconButton(
                                  icon: const Icon(Icons.add_circle_outline),
                                  onPressed: () => viewModel.setFlatFrames(viewModel.flatFrames + 10),
                                ),
                              ],
                            )
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Bias Frames:'),
                            Row(
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.remove_circle_outline),
                                  onPressed: () => viewModel.setBiasFrames(viewModel.biasFrames - 10 > 0 ? viewModel.biasFrames - 10 : 0),
                                ),
                                Text('${viewModel.biasFrames}', style: const TextStyle(fontWeight: FontWeight.bold)),
                                IconButton(
                                  icon: const Icon(Icons.add_circle_outline),
                                  onPressed: () => viewModel.setBiasFrames(viewModel.biasFrames + 10),
                                ),
                              ],
                            )
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text('Total Integration: ${viewModel.totalIntegrationTime}'),
                        Text('Stacking Gain: ${viewModel.relativeStackingGain.toStringAsFixed(1)}x'),
                        Text('Estimated Storage: ${viewModel.theoreticalStorageMB?.toStringAsFixed(1)} MB'),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () async {
                    final log = SessionLog(
                      id: 0,
                      targetName: target.commonName ?? target.catalogId,
                      equipmentName: equipment.name,
                      sessionDate: viewModel.sessionDate,
                      plannedLightFrames: viewModel.lightFrames,
                    );
                    await context.read<LogbookRepository>().addLog(log);
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
                const SizedBox(height: 32),
              ],
            ),
    );
  }
}
