import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/planner_viewmodel.dart';
import '../../domain/models/capture_block.dart';

class CapturePlanWidget extends StatelessWidget {
  const CapturePlanWidget({Key? key}) : super(key: key);

  void _showAddBlockDialog(BuildContext context, PlannerViewModel viewModel) {
    FrameType selectedType = FrameType.light;
    String filter = 'L';
    double exposure = 60.0;
    int count = 30;

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
                    value: selectedType,
                    decoration: const InputDecoration(labelText: 'Frame Type'),
                    items: FrameType.values.map((t) => DropdownMenuItem(value: t, child: Text(t.name.toUpperCase()))).toList(),
                    onChanged: (v) {
                      if (v != null) setState(() => selectedType = v);
                    },
                  ),
                  if (selectedType == FrameType.light || selectedType == FrameType.flat)
                    DropdownButtonFormField<String>(
                      value: filter,
                      decoration: const InputDecoration(labelText: 'Filter'),
                      items: ['L', 'R', 'G', 'B', 'Ha', 'OIII', 'SII', 'OSC', 'None'].map((f) => DropdownMenuItem(value: f, child: Text(f))).toList(),
                      onChanged: (v) {
                        if (v != null) setState(() => filter = v);
                      },
                    ),
                  TextFormField(
                    initialValue: exposure.toString(),
                    decoration: const InputDecoration(labelText: 'Exposure (seconds)'),
                    keyboardType: TextInputType.number,
                    onChanged: (v) => exposure = double.tryParse(v) ?? 60.0,
                  ),
                  TextFormField(
                    initialValue: count.toString(),
                    decoration: const InputDecoration(labelText: 'Frame Count'),
                    keyboardType: TextInputType.number,
                    onChanged: (v) => count = int.tryParse(v) ?? 30,
                  ),
                ],
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
                ElevatedButton(
                  onPressed: () {
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

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
                onReorder: (oldIndex, newIndex) {
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
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Integration Time', style: TextStyle(fontWeight: FontWeight.bold)),
                Text(viewModel.totalIntegrationTime, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.indigo)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
