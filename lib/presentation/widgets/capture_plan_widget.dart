import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_motion.dart';
import '../../core/theme/app_palette.dart';
import '../../domain/models/capture_block.dart';
import '../navigation/app_router.dart';
import '../shared/block_text.dart';
import '../shared/capability_text.dart';
import '../shared/delete_patterns.dart';
import '../shared/example_text.dart';
import '../shared/failure_feedback.dart';
import '../viewmodels/capture_analysis_viewmodel.dart';
import '../viewmodels/session_plan_viewmodel.dart';
import 'capture_plan/capture_assumptions_panel.dart';
import 'capture_plan/capture_block_dialog.dart';
import 'capture_plan/capture_budget_summary.dart';

/// The capture plan (TASK 5.6; S6.9): the blocks, then the outputs and the
/// assumptions. Since S6.9 the planner's "Capture plan" header is its one
/// heading (UX-09), and each row says what will be captured. Composes
/// smaller widgets; no calculations happen here.
class CapturePlanWidget extends StatelessWidget {
  const CapturePlanWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return const Card(
      margin: EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _BlockList(),
            Divider(height: 32),
            CaptureBudgetSummary(),
            SizedBox(height: 8),
            CaptureAssumptionsPanel(),
          ],
        ),
      ),
    );
  }
}

class _BlockList extends StatefulWidget {
  const _BlockList();

  @override
  State<_BlockList> createState() => _BlockListState();
}

class _BlockListState extends State<_BlockList> {
  /// False until the list has been built once: rows built after that are
  /// blocks just added, edited or restored, and are briefly marked.
  bool _built = false;

  /// RD-09 (M + S1): the block goes at once, with Undo; Undo puts the
  /// identical block back at its index (the plan autosaves either way).
  void _delete(int index, CaptureBlock block) {
    final plan = context.read<SessionPlanViewModel>();
    final wasExample = plan.isExampleCapturePlan;
    unawaited(plan.removeCaptureBlock(index));
    unawaited(
      showUndo(
        context,
        message: 'Deleted ${BlockText.row(block, null)}',
        onUndo: () => unawaited(
          plan.restoreCaptureBlock(index, block, wasExample: wasExample),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final palette = AppPalette.of(context);
    final viewModel = context.watch<SessionPlanViewModel>();
    final analysis = context.watch<CaptureAnalysisViewModel>();
    final blocks = viewModel.captureBlocks;
    final budgets = analysis.captureBudget.blocks;
    final capability = analysis.rigCapability;
    final fresh = _built;
    _built = true;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            // TASK 15.3: the badge wraps rather than push the add button off
            // a narrow screen.
            Expanded(
              child: Wrap(
                children: [
                  if (viewModel.isExampleCapturePlan)
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
                        ExampleText.plan,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: scheme.onPrimaryContainer,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            IconButton(
              tooltip: 'Add capture block',
              icon: const Icon(Icons.add_circle),
              color: scheme.primary,
              onPressed: () => showCaptureBlockDialog(context, viewModel),
            ),
          ],
        ),
        // RD-04 (S6.8): a plan starts empty; the example is one tap away
        // and never looks like the user's own (TASK 4.4's badge).
        if (blocks.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Wrap(
              spacing: 12,
              runSpacing: 8,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                const Text('No blocks yet.'),
                OutlinedButton(
                  key: const Key('capturePlan.useExample'),
                  onPressed: () => runWithFeedback(
                    context,
                    'start from the example plan',
                    viewModel.useExamplePlan,
                  ),
                  child: const Text(ExampleText.startFromExample),
                ),
              ],
            ),
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
              final budget = index < budgets.length ? budgets[index] : null;
              final placement = BlockText.placement(block, budget);
              // TASK 8.6: guidance only — never blocks the plan.
              final exceeds =
                  block.frameType == FrameType.light &&
                  capability != null &&
                  capability.exceedsRecommendation(block.exposureTimeSeconds);
              return _ChangeMark(
                // TD-010/TD-012: ObjectKey tracks this block instance
                // regardless of position, and stays stable across a drag.
                key: ObjectKey(block),
                fresh: fresh,
                builder: (tint) => ListTile(
                  tileColor: tint,
                  contentPadding: EdgeInsets.zero,
                  onTap: () => showCaptureBlockDialog(
                    context,
                    viewModel,
                    editIndex: index,
                    initial: block,
                  ),
                  title: Text(BlockText.row(block, budget)),
                  subtitle: placement == null && !exceeds
                      ? null
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (placement != null) Text(placement),
                            // S6.9 (UX-15 (1); RD-08): a known tracking's
                            // exceedance is a warning, in words and the
                            // status colour; unknown tracking is a missing
                            // input, neutral, with the way to set it.
                            if (exceeds &&
                                !capability.recommendationIsConditional)
                              Text(
                                CapabilityText.subWarningFor(
                                  capability,
                                  viewModel.effectiveTracking,
                                ),
                                key: const Key('capture.subWarning'),
                                style: TextStyle(
                                  color: palette.statusDoesNotFit,
                                ),
                              ),
                            if (exceeds &&
                                capability.recommendationIsConditional) ...[
                              Text(
                                CapabilityText.unknownTracking(capability),
                                key: const Key('capture.trackingUnknown'),
                                style: TextStyle(color: palette.statusNeutral),
                              ),
                              TextButton(
                                key: const Key('capture.setTracking'),
                                onPressed: () =>
                                    context.push(AppRouter.selectRig),
                                child: const Text("Set the rig's tracking"),
                              ),
                            ],
                          ],
                        ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      DeleteButton(
                        tooltip: 'Delete block',
                        onPressed: () => _delete(index, block),
                      ),
                      Icon(Icons.drag_indicator, color: palette.textTertiary),
                    ],
                  ),
                ),
              );
            },
          ),
      ],
    );
  }
}

/// Briefly marks a row an edit just changed (S6.9; P6.9's notes): a tint
/// on the tile that fades over [AppMotion.highlight]; none with reduced
/// motion.
class _ChangeMark extends StatelessWidget {
  const _ChangeMark({super.key, required this.fresh, required this.builder});

  final bool fresh;
  final Widget Function(Color tint) builder;

  @override
  Widget build(BuildContext context) {
    final tint = Theme.of(context).colorScheme.primaryContainer;
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: fresh ? 1 : 0, end: 0),
      duration: AppMotion.duration(context, AppMotion.highlight),
      curve: AppMotion.curve,
      builder: (context, v, _) => builder(tint.withValues(alpha: 0.6 * v)),
    );
  }
}
