import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../domain/services/capture_budget_calculator.dart';
import '../../../domain/models/equipment_profile.dart';
import '../../../domain/models/spec_confidence.dart';
import '../../../domain/models/spec_provenance.dart';
import '../../navigation/app_router.dart';
import '../../shared/app_words.dart';
import '../../shared/change_mark.dart';
import '../../shared/collapsible_section.dart';
import '../../shared/context_line.dart';
import '../../shared/night_time_formatter.dart';
import '../planner_sections.dart';
import 'stacking_gain_graph.dart';
import '../../viewmodels/capture_analysis_viewmodel.dart';
import '../../viewmodels/night_conditions_viewmodel.dart';
import '../../viewmodels/session_plan_viewmodel.dart';
import '../../viewmodels/site_viewmodel.dart';
import '../../../core/utils/quantity_text.dart';

/// A millisecond duration in the app's one duration form (S1.7).
String formatBudgetDuration(int ms) =>
    QuantityText.duration(Duration(milliseconds: ms));

/// The capture plan's outputs (ADR-009 §2, §7; TASK 5.6): the budget
/// breakdown, relative stacking gain per group and storage. The fit, its
/// reason, its end and "fill the window" are the planner's status since S6.6
/// (`PlanStatus`), shown once. Since S6.7 (ADR-019 §7) the breakdown is in
/// Budget details and the √N explanation one tap away, each behind a
/// factual summary; the √N values and storage stay visible. Renders
/// ViewModel/domain values only — no calculations here.
class CaptureBudgetSummary extends StatelessWidget {
  const CaptureBudgetSummary({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final analysis = context.watch<CaptureAnalysisViewModel>();
    final plan = context.watch<SessionPlanViewModel>();
    final budget = analysis.captureBudget;
    final fit = analysis.fitAnalysis;
    final night = plan.sessionNight;
    final windows = context.watch<NightConditionsViewModel>().visibilityWindows;
    final setupStart = budget.setupStartUtc(windows);

    final zoneId = context.watch<SiteViewModel>().displayZoneId;
    String clock(DateTime utc) => night == null
        ? NightTimeFormatter.clockTime(context, utc, zoneId: zoneId)
        : NightTimeFormatter.instant(
            context,
            utc,
            windowStartUtc: night.startUtc,
            zoneId: zoneId,
          );

    final library = budget.libraryBlockIndexes.length;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // S6.7 (ADR-019 §7): every ADR-009 line on its own line, one tap
        // away; the status above shows the answer's numbers.
        // S6.10 (P6.9): Time needed · Total time stay in view, marked
        // briefly when an edit changes them; every line is inside.
        ChangeMark(
          value: budgetSummary(budget),
          child: CollapsibleSection(
            sectionKey: PlannerSections.budgetDetails,
            title: AppWords.budgetDetails,
            summary: budgetSummary(budget),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _Line(
                  '${AppWords.integration} (light exposure)',
                  formatBudgetDuration(budget.integrationMs),
                  key: const Key('budget.integration'),
                ),
                _Line(
                  '${AppWords.imagingTime} (lights + overheads)',
                  formatBudgetDuration(budget.acquisitionMs),
                  key: const Key('budget.imagingTime'),
                ),
                if (budget.inWindowCalibrationMs > 0)
                  _Line(
                    'Calibration during the window',
                    formatBudgetDuration(budget.inWindowCalibrationMs),
                    key: const Key('budget.calibrationIn'),
                  ),
                // S7.3b (ADR-020 §8): the part the camera's noise reduction
                // takes, one dark as long as each light.
                if (budget.inCameraDarkMs > 0)
                  _Line(
                    'Of which in-camera darks',
                    formatBudgetDuration(budget.inCameraDarkMs),
                    key: const Key('budget.inCameraDarks'),
                  ),
                _Line(
                  '${AppWords.timeNeeded} (in the window)',
                  fit.availableMs > 0
                      ? '${formatBudgetDuration(budget.windowLoadMs)} of '
                            '${formatBudgetDuration(fit.availableMs)}'
                      : formatBudgetDuration(budget.windowLoadMs),
                  key: const Key('budget.timeNeeded'),
                  emphasis: true,
                ),
                _Line(
                  'Calibration outside the window',
                  budget.outsideWindowCalibrationMs > 0
                      ? formatBudgetDuration(budget.outsideWindowCalibrationMs)
                      : 'None',
                  key: const Key('budget.calibrationOut'),
                ),
                _Line(
                  'Setup',
                  budget.setupMs == null
                      ? 'Not included'
                      : setupStart == null
                      ? formatBudgetDuration(budget.setupMs!)
                      : '${formatBudgetDuration(budget.setupMs!)} — start by '
                            '${clock(setupStart)}',
                  key: const Key('budget.setup'),
                ),
                _Line(
                  AppWords.totalTime,
                  formatBudgetDuration(budget.sessionBudgetMs),
                  key: const Key('budget.totalTime'),
                  emphasis: true,
                ),
                if (library > 0)
                  _Line(
                    'Library calibration',
                    '$library block${library == 1 ? '' : 's'}, no time needed',
                    key: const Key('budget.library'),
                  ),
                // The zone rule, once for the section's one time (trap 2).
                if (setupStart != null && night != null)
                  Text(
                    ContextLine.zoneRule(night.startUtc, zoneId: zoneId),
                    style: theme.textTheme.bodySmall,
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        // The √N values stay visible and relative (SI-003); the long
        // explanation is one tap away.
        CollapsibleSection(
          sectionKey: PlannerSections.gainHelp,
          title: AppWords.relativeStackingGain,
          summary: 'Per filter and exposure, against one frame',
          child: Text(
            '√N compares the random noise of a stack with one frame of the '
            'same filter and exposure. It only applies within such a group, '
            'is not a signal-to-noise ratio of your image, and ignores sky '
            'brightness, the target and your camera.',
            key: const Key('capturePlan.gainHelp'),
            style: theme.textTheme.bodySmall,
          ),
        ),
        if (budget.lightGroups.isEmpty)
          Text('No light frames.', style: theme.textTheme.bodySmall)
        else
          for (final g in budget.lightGroups) ...[
            _Line(
              '${g.filterName ?? 'No filter'} · '
                  '${_seconds(g.exposureMs)} × ${g.frames}',
              '${g.relativeStackingGain.toStringAsFixed(1)}x',
            ),
            // S6.11 (P6.10): how the gain grows with more frames, per group
            // (never combined); the number stays in the line above.
            StackingGainGraph(
              key: Key('capturePlan.gainGraph.${g.filterName}.${g.exposureMs}'),
              curve: g.gainCurve,
              groupLabel:
                  '${g.filterName ?? 'No filter'} · ${_seconds(g.exposureMs)}',
            ),
          ],
        const SizedBox(height: 12),
        _Line(
          'Estimated Storage',
          budget.storageMB != null
              ? '${budget.storageMB!.toStringAsFixed(1)} MB'
              : 'Unknown',
          key: const Key('capturePlan.storage'),
          emphasis: true,
        ),
        // S6.10 (P6.9; the trace's case C): a known value says what it
        // rests on; an unknown one says why, and how to supply it.
        Text(
          storageNote(plan.selectedEquipment, known: budget.storageMB != null),
          key: const Key('capturePlan.storageNote'),
          style: theme.textTheme.bodySmall,
        ),
        if (budget.storageMB == null && plan.selectedEquipment != null)
          TextButton(
            key: const Key('capturePlan.setFileSize'),
            onPressed: () => context.push(AppRouter.selectRig),
            child: const Text('Set the RAW file size'),
          ),
      ],
    );
  }

  /// Budget details' collapsed summary, a fact in the glossary's words:
  /// "Time needed 2 h 5 min · Total time 3 h" (S6.7; S6.10).
  static String budgetSummary(CaptureBudget budget) =>
      '${AppWords.timeNeeded} ${formatBudgetDuration(budget.windowLoadMs)} · '
      '${AppWords.totalTime} ${formatBudgetDuration(budget.sessionBudgetMs)}';

  /// What the storage figure rests on, or why there is none (S6.10).
  static String storageNote(EquipmentProfile? rig, {required bool known}) {
    if (!known) {
      return rig == null
          ? 'Unknown: no rig chosen, so the file size is not known.'
          : 'Unknown: the RAW file size is not known for this rig. Enter it '
                "in the rig's editor, or read it from a DNG photo with "
                '"Add from a photo".';
    }
    final estimated =
        rig?.provenanceOf(EquipmentSpec.rawFileSize)?.confidence ==
        SpecConfidence.estimated;
    return "An estimate from the rig's average RAW file size; binning and "
        'compression are ignored.'
        "${estimated ? " The rig's RAW size is itself an estimate, from one file." : ''}";
  }

  static String _seconds(int ms) {
    final s = ms / 1000;
    return s == s.roundToDouble() ? '${s.round()} s' : '$s s';
  }
}

class _Line extends StatelessWidget {
  const _Line(this.label, this.value, {super.key, this.emphasis = false});

  final String label;
  final String value;
  final bool emphasis;

  @override
  Widget build(BuildContext context) {
    final style = TextStyle(
      fontWeight: emphasis ? FontWeight.bold : FontWeight.normal,
    );
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(child: Text(label, style: style)),
          const SizedBox(width: 8),
          // TASK 15.3: the value wraps too at 200 % text.
          Flexible(
            child: Text(value, style: style, textAlign: TextAlign.end),
          ),
        ],
      ),
    );
  }
}
