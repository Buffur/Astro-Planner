import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_motion.dart';
import '../../core/theme/app_palette.dart';
import '../../domain/models/capture_block.dart';
import '../../domain/services/fit_analyzer.dart';
import '../navigation/app_router.dart';
import '../shared/block_text.dart';
import '../shared/capability_text.dart';
import '../shared/delete_patterns.dart';
import '../shared/example_text.dart';
import '../shared/failure_feedback.dart';
import '../viewmodels/capture_analysis_viewmodel.dart';
import '../viewmodels/session_plan_viewmodel.dart';
import 'capture_plan/blocks_undo.dart';
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
  /// identical block back at its index (the plan autosaves either way),
  /// without undoing a later edit (S6.V1, TD-082).
  void _delete(int index, CaptureBlock block) => unawaited(
    deleteBlockWithUndo(
      context,
      index: index,
      block: block,
      message: 'Deleted ${BlockText.row(block, null)}',
    ),
  );

  /// A new block from the dialog.
  Future<void> _add() async {
    final block = await showCaptureBlockDialog(context);
    if (block == null || !mounted) return;
    final plan = context.read<SessionPlanViewModel>();
    await runWithFeedback(
      context,
      'add the block',
      () => plan.addCaptureBlock(block),
    );
  }

  /// TD-079 (S6.16): an edit saved in the dialog applies at once and says
  /// so, with Undo back to the block as it was.
  Future<void> _edit(int index, CaptureBlock block) async {
    final edited = await showCaptureBlockDialog(context, initial: block);
    if (edited == null || !mounted) return;
    final plan = context.read<SessionPlanViewModel>();
    await runWithFeedback(
      context,
      'change the block',
      () => editBlocksWithUndo(
        context,
        message: 'Block changed: ${BlockText.row(edited, null)}',
        change: () => plan.updateCaptureBlock(index, edited),
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
    // S6.10: what fits, only where the fit measured the plan.
    final fit = analysis.fitAnalysis;
    final measured =
        fit.state == FitState.fits ||
        fit.state == FitState.tight ||
        fit.state == FitState.doesNotFit;
    final fillIndex = measured ? analysis.fillWindowBlockIndex : null;
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
              onPressed: _add,
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
                  // TD-079 (S6.16): with Undo back to the empty plan.
                  onPressed: () => runWithFeedback(
                    context,
                    'start from the example plan',
                    () => editBlocksWithUndo(
                      context,
                      message: 'Started from the example plan',
                      change: viewModel.useExamplePlan,
                    ),
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
              final fits = measured
                  ? BlockText.whatFits(
                      block,
                      unplaced: fit.unplacedFramesByBlock[index] ?? 0,
                      upTo: index == fillIndex
                          ? analysis.fillWindowFrameCount
                          : null,
                      spare: index == fillIndex
                          ? analysis.fillWindowSpareFrames
                          : null,
                    )
                  : null;
              final unplaced = (fit.unplacedFramesByBlock[index] ?? 0) > 0;
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
                  onTap: () => _edit(index, block),
                  title: Text(BlockText.row(block, budget)),
                  subtitle: placement == null && !exceeds && fits == null
                      ? null
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (placement != null) Text(placement),
                            if (fits != null)
                              Text(
                                fits,
                                key: Key('capture.whatFits.$index'),
                                style: TextStyle(
                                  color: unplaced
                                      ? palette.statusDoesNotFit
                                      : palette.textSecondary,
                                ),
                              ),
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
