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

  /// Shared by the add and edit flows (TASK 4.1). When [editIndex] is given,
  /// the dialog is pre-filled from [initial] and calls `updateCaptureBlock`
  /// instead of `addCaptureBlock` — the only reachable caller of that method
  /// before this task (TD-012: "no edit UI (`updateCaptureBlock` unused)").
  void _showBlockDialog(
    BuildContext context,
    PlannerViewModel viewModel, {
    int? editIndex,
    CaptureBlock? initial,
  }) {
    FrameType selectedType = initial?.frameType ?? FrameType.light;
    String filter = initial?.filterName ?? 'L';
    final exposureController = TextEditingController(
      text: initial != null ? _trimZeros(initial.exposureTimeSeconds) : '',
    );
    final countController = TextEditingController(
      text: initial != null ? initial.frameCount.toString() : '',
    );
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(
                editIndex == null ? 'Add Capture Block' : 'Edit Capture Block',
              ),
              content: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DropdownButtonFormField<FrameType>(
                      initialValue: selectedType,
                      decoration: const InputDecoration(
                        labelText: 'Frame Type',
                      ),
                      items: FrameType.values
                          .map(
                            (t) => DropdownMenuItem(
                              value: t,
                              child: Text(t.name.toUpperCase()),
                            ),
                          )
                          .toList(),
                      onChanged: (v) {
                        if (v != null) setState(() => selectedType = v);
                      },
                    ),
                    if (selectedType == FrameType.light ||
                        selectedType == FrameType.flat)
                      DropdownButtonFormField<String>(
                        initialValue: filter,
                        decoration: const InputDecoration(labelText: 'Filter'),
                        items:
                            [
                                  'L',
                                  'R',
                                  'G',
                                  'B',
                                  'Ha',
                                  'OIII',
                                  'SII',
                                  'OSC',
                                  'None',
                                ]
                                .map(
                                  (f) => DropdownMenuItem(
                                    value: f,
                                    child: Text(f),
                                  ),
                                )
                                .toList(),
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
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      validator: (value) {
                        final exposure = double.tryParse((value ?? '').trim());
                        if (exposure == null || exposure <= 0) {
                          return 'Enter a positive number of seconds';
                        }
                        return null;
                      },
                    ),
                    TextFormField(
                      controller: countController,
                      decoration: const InputDecoration(
                        labelText: 'Frame Count',
                        hintText: 'e.g. 30',
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        final count = int.tryParse((value ?? '').trim());
                        if (count == null || count < 1) {
                          return 'Enter a whole number of at least 1';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (!(formKey.currentState?.validate() ?? false)) return;

                    final exposure = double.parse(
                      exposureController.text.trim(),
                    );
                    final count = int.parse(countController.text.trim());
                    final block = CaptureBlock(
                      id: initial?.id ?? 0,
                      sessionLogId: initial?.sessionLogId ?? 0,
                      frameType: selectedType,
                      filterName:
                          (selectedType == FrameType.light ||
                              selectedType == FrameType.flat)
                          ? filter
                          : null,
                      exposureTimeSeconds: exposure,
                      frameCount: count,
                      binning: initial?.binning ?? 1,
                      gainIso: initial?.gainIso,
                    );

                    if (editIndex == null) {
                      viewModel.addCaptureBlock(block);
                    } else {
                      viewModel.updateCaptureBlock(editIndex, block);
                    }
                    Navigator.pop(ctx);
                  },
                  child: Text(editIndex == null ? 'Add' : 'Save'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  /// Whole numbers print without a trailing ".0" (e.g. an exposure of 60.0
  /// pre-fills the edit dialog as "60", not "60.0").
  String _trimZeros(double value) {
    return value == value.roundToDouble()
        ? value.toStringAsFixed(0)
        : value.toString();
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
            const Text(
              'Inputs',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: Colors.indigo,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Text(
                      'Sequence Plan',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    if (viewModel.isExampleCapturePlan) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.indigo.shade50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.indigo.shade100),
                        ),
                        child: Text(
                          'Example plan',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: Colors.indigo.shade700,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.add_circle),
                  color: Colors.indigo,
                  onPressed: () => _showBlockDialog(context, viewModel),
                ),
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
                  final filterStr = block.filterName != null
                      ? '[${block.filterName}] '
                      : '';

                  return ListTile(
                    // TD-010/TD-012: was ValueKey(hashCode + index), which
                    // changes on every reorder (defeating the point of a
                    // ReorderableListView key) and can collide since
                    // CaptureBlock doesn't override hashCode. ObjectKey
                    // tracks this specific block instance regardless of its
                    // position, and stays stable across a drag.
                    key: ObjectKey(block),
                    contentPadding: EdgeInsets.zero,
                    onTap: () => _showBlockDialog(
                      context,
                      viewModel,
                      editIndex: index,
                      initial: block,
                    ),
                    title: Text(
                      '${block.frameType.name.toUpperCase()} $filterStr',
                    ),
                    subtitle: Text(
                      '${block.frameCount}x ${block.exposureTimeSeconds}s',
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.drag_handle, color: Colors.grey),
                        IconButton(
                          icon: const Icon(
                            Icons.delete_outline,
                            color: Colors.red,
                          ),
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
            const Text(
              'Outputs',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: Colors.indigo,
              ),
            ),
            const SizedBox(height: 16),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Session Duration',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  _formatDuration(viewModel.estimatedRequiredTime),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.indigo,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Feasibility',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  _formatFeasibility(feasibility.state),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: _feasibilityColor(feasibility.state),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Integration Time',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  viewModel.totalIntegrationTime,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.indigo,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Relative stacking gain (√N vs one frame)',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  '${viewModel.relativeStackingGain.toStringAsFixed(1)}x',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.teal,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Estimated Storage',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  viewModel.estimatedStorageMB != null
                      ? '${viewModel.estimatedStorageMB!.toStringAsFixed(1)} MB'
                      : 'Unknown',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.orange,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
