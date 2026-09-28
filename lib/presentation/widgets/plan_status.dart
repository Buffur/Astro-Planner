import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/utils/quantity_text.dart';
import '../../domain/services/fit_analyzer.dart';
import '../navigation/app_router.dart';
import '../shared/app_words.dart';
import '../shared/night_time_formatter.dart';
import '../shared/status_block.dart';
import '../viewmodels/capture_analysis_viewmodel.dart';
import '../viewmodels/session_plan_viewmodel.dart';
import '../viewmodels/site_viewmodel.dart';

/// The planner's answer, first (S6.6; ADR-019 §6.2; UX-01): the verdict with
/// its relationship ("Fits: 2 h 5 min needed of 4 h 20 min usable"), its key
/// reason, when capture ends, the integration, and the next action — fill or
/// trim from the fit, or the missing input to choose. Every value comes from
/// `FitAnalyzer` and `CaptureBudget` through the ViewModel; no percentage,
/// score or good/bad rating. A missing site, target or rig is neutral.
class PlanStatus extends StatelessWidget {
  const PlanStatus({super.key});

  /// The missing-input headlines for a site and a rig (S6.6).
  static const needsSite = 'Needs a site';
  static const needsRig = 'Needs a rig';

  @override
  Widget build(BuildContext context) {
    final analysis = context.watch<CaptureAnalysisViewModel>();
    final plan = context.watch<SessionPlanViewModel>();
    final site = context.watch<SiteViewModel>();
    final fit = analysis.fitAnalysis;
    final night = plan.sessionNight;

    // The input the answer waits for, in the order it is needed. The
    // glossary's "Needs a …" pattern (a target, a block) is applied to a
    // site and a rig here; the site's action is the banner's and the
    // context line's, so it is not repeated.
    final (String? missing, String? pick, String? route) = night == null
        ? (needsSite, null, null)
        : plan.selectedTarget == null
        ? (AppWords.needsTarget, 'Choose a target', AppRouter.selectTarget)
        : plan.selectedEquipment == null
        ? (needsRig, AppWords.chooseRig, AppRouter.selectRig)
        : (null, null, null);
    final state = missing != null ? FitState.needsInput : fit.state;

    final measured =
        missing == null &&
        (fit.state == FitState.fits ||
            fit.state == FitState.tight ||
            fit.state == FitState.doesNotFit);
    final end = fit.endUtc;
    return Card(
      key: const Key('planner.status'),
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: StatusBlock(
          state: state,
          missing: missing,
          needed: measured ? Duration(milliseconds: fit.windowLoadMs) : null,
          usable: measured && fit.availableMs > 0
              ? Duration(milliseconds: fit.availableMs)
              : null,
          reason: missing == needsRig
              ? 'A rig is needed to save the plan and to check exposures.'
              : fit.reason,
          keyNumbers: [
            // Always (S6.7): the budget's lines are folded into Budget
            // details, and integration needs no site, target or rig.
            (
              AppWords.integration,
              QuantityText.duration(
                Duration(milliseconds: analysis.captureBudget.integrationMs),
              ),
            ),
            if (missing == null &&
                end != null &&
                night != null &&
                (fit.state == FitState.fits || fit.state == FitState.tight))
              (
                'Capture ends',
                NightTimeFormatter.instant(
                  context,
                  end,
                  windowStartUtc: night.startUtc,
                  zoneId: site.displayZoneId,
                ),
              ),
          ],
          action: pick != null
              ? OutlinedButton(
                  key: const Key('status.choose'),
                  onPressed: () => context.push(route!),
                  child: Text(pick),
                )
              : measured
              ? FillWindowAction(fit: fit)
              : null,
        ),
      ),
    );
  }
}

/// "Fill tonight's window" or "Trim … to fit tonight" (TASK 5.6): one action
/// that sets the plan's last light block to the largest frame count that
/// still places. Moved into the status in S6.6; values from the ViewModel.
class FillWindowAction extends StatelessWidget {
  const FillWindowAction({super.key, required this.fit});

  final FitResult fit;

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<CaptureAnalysisViewModel>();
    final index = viewModel.fillWindowBlockIndex;
    final target = viewModel.fillWindowFrameCount;
    if (index == null || target == null) return const SizedBox.shrink();
    final block = context.watch<SessionPlanViewModel>().captureBlocks[index];
    final label =
        '${block.filterName ?? 'Light'} '
        '${QuantityText.exposure(block.exposureTimeSeconds)}';
    if (target < 1) {
      return Text(
        'Not even one $label frame fits tonight.',
        style: Theme.of(context).textTheme.bodySmall,
      );
    }
    if (target == block.frameCount) return const SizedBox.shrink();
    return Align(
      alignment: Alignment.centerLeft,
      child: TextButton.icon(
        key: const Key('capturePlan.fillWindow'),
        icon: Icon(
          target < block.frameCount ? Icons.content_cut : Icons.open_in_full,
        ),
        label: Text(
          target < block.frameCount
              ? 'Trim $label to $target frames to fit tonight'
              : 'Fill tonight\'s window: $label × $target',
        ),
        onPressed: () => viewModel.fillWindow(),
      ),
    );
  }
}
