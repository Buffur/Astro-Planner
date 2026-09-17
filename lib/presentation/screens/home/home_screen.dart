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
