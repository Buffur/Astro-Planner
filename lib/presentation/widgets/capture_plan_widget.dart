import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../domain/models/capture_block.dart';
import '../shared/capability_text.dart';
import '../viewmodels/capture_analysis_viewmodel.dart';
import '../viewmodels/session_plan_viewmodel.dart';
import 'capture_plan/capture_assumptions_panel.dart';
import 'capture_plan/capture_block_dialog.dart';
import 'capture_plan/capture_budget_summary.dart';

/// The capture planner: inputs (the block sequence) -> outputs (budget,
/// fit, gain, storage) with the assumptions visible (TASK 5.6). Composes
/// smaller widgets; no calculations happen here.
class CapturePlanWidget extends StatelessWidget {
  const CapturePlanWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final sectionStyle = TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 18,
      color: scheme.primary,
    );

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Inputs', style: sectionStyle),
            const SizedBox(height: 8),
            const _BlockList(),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 16),
            Text('Outputs', style: sectionStyle),
            const SizedBox(height: 8),
            const CaptureBudgetSummary(),
            const SizedBox(height: 8),
            const CaptureAssumptionsPanel(),
          ],
        ),
      ),
    );
  }
}

class _BlockList extends StatelessWidget {
  const _BlockList();

  static String _policyLabel(CalibrationPolicy? p) => switch (p) {
    CalibrationPolicy.inWindow => ' · during the window',
    CalibrationPolicy.outsideWindow => ' · outside the window',
    CalibrationPolicy.library => ' · from library',
    null => '',
  };

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final viewModel = context.watch<SessionPlanViewModel>();
    final blocks = viewModel.captureBlocks;
    final capability = context.watch<CaptureAnalysisViewModel>().rigCapability;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const Text(
                  'Sequence Plan',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                if (viewModel.isExampleCapturePlan) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: scheme.primaryContainer,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'Example plan',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: scheme.onPrimaryContainer,
                      ),
                    ),
                  ),
                ],
              ],
            ),
            IconButton(
              icon: const Icon(Icons.add_circle),
              color: scheme.primary,
              onPressed: () => showCaptureBlockDialog(context, viewModel),
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
                // TD-010/TD-012: ObjectKey tracks this block instance
                // regardless of position, and stays stable across a drag.
                key: ObjectKey(block),
                contentPadding: EdgeInsets.zero,
                onTap: () => showCaptureBlockDialog(
                  context,
                  viewModel,
                  editIndex: index,
                  initial: block,
                ),
                title: Text('${block.frameType.name.toUpperCase()} $filterStr'),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${block.frameCount}x ${block.exposureTimeSeconds}s'
                      '${_policyLabel(block.calibrationPolicy)}',
                    ),
                    // TASK 8.6: guidance only — never blocks the plan.
                    if (block.frameType == FrameType.light &&
                        capability != null &&
                        capability.exceedsRecommendation(
                          block.exposureTimeSeconds,
                        ))
                      Text(
                        CapabilityText.subWarning(capability),
                        key: const Key('capture.subWarning'),
                        style: TextStyle(color: scheme.error),
                      ),
                  ],
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.drag_handle, color: scheme.outline),
                    IconButton(
                      icon: Icon(Icons.delete_outline, color: scheme.error),
                      onPressed: () => viewModel.removeCaptureBlock(index),
                    ),
                  ],
                ),
              );
            },
          ),
      ],
    );
  }
}
