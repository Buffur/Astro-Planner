import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/planner_viewmodel.dart';
import '../../domain/models/capture_block.dart';
import '../../domain/services/session_calculator.dart';

class CapturePlanWidget extends StatelessWidget {
  const CapturePlanWidget({super.key});

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    return '${hours}h ${minutes}m';
  }

  String _formatFeasibility(FeasibilityState state) {
    switch (state) {
      case FeasibilityState.feasible:
        return 'Feasible';
      case FeasibilityState.tight:
        return 'Tight';
      case FeasibilityState.infeasible:
        return 'Infeasible';
    }
  }

  Color _feasibilityColor(FeasibilityState state) {
    switch (state) {
      case FeasibilityState.feasible:
        return Colors.green;
      case FeasibilityState.tight:
        return Colors.orange;
      case FeasibilityState.infeasible:
        return Colors.red;
    }
  }

  void _showAddBlockDialog(BuildContext context, PlannerViewModel viewModel) {
    FrameType selectedType = FrameType.light;
    String filter = 'L';
    final exposureController = TextEditingController();
    final countController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Add Capture Block'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<FrameType>(
                    initialValue: selectedType,
                    decoration: const InputDecoration(labelText: 'Frame Type'),
                    items: FrameType.values.map((t) => DropdownMenuItem(value: t, child: Text(t.name.toUpperCase()))).toList(),
                    onChanged: (v) {
                      if (v != null) setState(() => selectedType = v);
                    },
                  ),
                  if (selectedType == FrameType.light || selectedType == FrameType.flat)
                    DropdownButtonFormField<String>(
                      initialValue: filter,
                      decoration: const InputDecoration(labelText: 'Filter'),
                      items: ['L', 'R', 'G', 'B', 'Ha', 'OIII', 'SII', 'OSC', 'None'].map((f) => DropdownMenuItem(value: f, child: Text(f))).toList(),
                      onChanged: (v) {
                        if (v != null) setState(() => filter = v);
                      },
                    ),
                  TextFormField(
                    controller: exposureController,
                    decoration: const InputDecoration(
                      labelText: 'Exposure (seconds)',
                      hintText: 'e.g. 60',
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  TextFormField(
                    controller: countController,
                    decoration: const InputDecoration(
                      labelText: 'Frame Count',
                      hintText: 'e.g. 30',
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ],
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
                ElevatedButton(
                  onPressed: () {
                    final exposure = double.tryParse(exposureController.text.trim()) ?? 60.0;
                    final count = int.tryParse(countController.text.trim()) ?? 30;
                    
                    viewModel.addCaptureBlock(CaptureBlock(
                      frameType: selectedType,
                      filterName: (selectedType == FrameType.light || selectedType == FrameType.flat) ? filter : null,
                      exposureTimeSeconds: exposure,
                      frameCount: count,
                    ));
                    Navigator.pop(ctx);
                  },
                  child: const Text('Add'),
                ),
              ],
            );
          }
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<PlannerViewModel>();
    final blocks = viewModel.captureBlocks;
    final feasibility = viewModel.sessionFeasibility;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- INPUTS SECTION ---
            const Text('Inputs', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.indigo)),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Sequence Plan', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                IconButton(
                  icon: const Icon(Icons.add_circle),
                  color: Colors.indigo,
                  onPressed: () => _showAddBlockDialog(context, viewModel),
                )
              ],
            ),
            const SizedBox(height: 8),
            if (blocks.isEmpty)
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Center(child: Text('No blocks added to the sequence.')),
              )
            else
              ReorderableListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: blocks.length,
                onReorderItem: (oldIndex, newIndex) {
                  viewModel.reorderCaptureBlocks(oldIndex, newIndex);
                },
                itemBuilder: (context, index) {
                  final block = blocks[index];
                  final filterStr = block.filterName != null ? '[${block.filterName}] ' : '';
                  
                  return ListTile(
                    key: ValueKey(block.hashCode.toString() + index.toString()),
                    contentPadding: EdgeInsets.zero,
                    title: Text('${block.frameType.name.toUpperCase()} $filterStr'),
                    subtitle: Text('${block.frameCount}x ${block.exposureTimeSeconds}s'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.drag_handle, color: Colors.grey),
                        IconButton(
                          icon: const Icon(Icons.delete_outline, color: Colors.red),
                          onPressed: () => viewModel.removeCaptureBlock(index),
                        ),
                      ],
                    ),
                  );
                },
              ),
            
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 16),

            // --- OUTPUTS SECTION ---
            const Text('Outputs', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.indigo)),
            const SizedBox(height: 16),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Session Duration', style: TextStyle(fontWeight: FontWeight.bold)),
                Text(_formatDuration(viewModel.estimatedRequiredTime), style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.indigo)),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Feasibility', style: TextStyle(fontWeight: FontWeight.bold)),
                Text(_formatFeasibility(feasibility.state), style: TextStyle(fontWeight: FontWeight.bold, color: _feasibilityColor(feasibility.state))),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Integration Time', style: TextStyle(fontWeight: FontWeight.bold)),
                Text(viewModel.totalIntegrationTime, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.indigo)),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Stacking Gain (Relative SNR)', style: TextStyle(fontWeight: FontWeight.bold)),
                Text('${viewModel.relativeStackingGain.toStringAsFixed(1)}x', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.teal)),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Estimated Storage', style: TextStyle(fontWeight: FontWeight.bold)),
                Text(viewModel.estimatedStorageMB != null ? '${viewModel.estimatedStorageMB!.toStringAsFixed(1)} MB' : 'N/A', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.orange)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
