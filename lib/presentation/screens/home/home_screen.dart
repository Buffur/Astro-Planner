import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../viewmodels/planner_viewmodel.dart';
import '../../widgets/planner_summary_card.dart';

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
                  title: 'Target: ${target.commonName} (${target.catalogId})',
                  data: {
                    'Type': target.type,
                    'Current Altitude': '${viewModel.currentAltitude?.toStringAsFixed(1)}°',
                    'Max Altitude': '${viewModel.maxAltitude?.toStringAsFixed(1)}°',
                  },
                  onTap: () => context.push('/target'),
                ),
                PlannerSummaryCard(
                  title: 'Equipment: ${equipment.name}',
                  data: {
                    'Pixel Scale': '${viewModel.pixelScale?.toStringAsFixed(2)} arcsec/px',
                  },
                  onTap: () => context.push('/equipment'),
                ),
                if (viewModel.currentWeather != null)
                  PlannerSummaryCard(
                    title: 'Current Weather (London)',
                    data: {
                      'Temperature': '${viewModel.currentWeather!.temperature.toStringAsFixed(1)}°C',
                      'Cloud Cover': '${viewModel.currentWeather!.cloudCover.toStringAsFixed(0)}%',
                      'Dew Point': '${viewModel.currentWeather!.dewPoint.toStringAsFixed(1)}°C',
                    },
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
                                  onPressed: () => viewModel.setLightFrames(viewModel.lightFrames - 10 > 0 ? viewModel.lightFrames - 10 : 1),
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
                        const SizedBox(height: 8),
                        Text('Total Integration: ${viewModel.totalIntegrationTime}'),
                        Text('Stacking Gain: ${viewModel.relativeStackingGain.toStringAsFixed(1)}x'),
                        Text('Estimated Storage: ${viewModel.theoreticalStorageMB?.toStringAsFixed(1)} MB'),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
