import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../shared/night_time_formatter.dart';
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
/// (`PlanStatus`), shown once. Renders ViewModel/domain values only — no
/// calculations here.
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _Line(
          'Integration (light exposure)',
          formatBudgetDuration(budget.integrationMs),
        ),
        _Line(
          'Acquisition (lights + overheads)',
          formatBudgetDuration(budget.acquisitionMs),
        ),
        if (budget.inWindowCalibrationMs > 0)
          _Line(
            'Calibration during the window',
            formatBudgetDuration(budget.inWindowCalibrationMs),
          ),
        _Line(
          'Time needed in window',
          fit.availableMs > 0
              ? '${formatBudgetDuration(budget.windowLoadMs)} of '
                    '${formatBudgetDuration(fit.availableMs)}'
              : formatBudgetDuration(budget.windowLoadMs),
          emphasis: true,
        ),
        _Line(
          'Calibration outside the window',
          budget.outsideWindowCalibrationMs > 0
              ? formatBudgetDuration(budget.outsideWindowCalibrationMs)
              : 'None',
        ),
        _Line(
          'Setup',
          budget.setupMs == null
              ? 'Not included'
              : setupStart == null
              ? formatBudgetDuration(budget.setupMs!)
              : '${formatBudgetDuration(budget.setupMs!)} — start by '
                    '${clock(setupStart)}',
        ),
        _Line(
          'Session budget',
          formatBudgetDuration(budget.sessionBudgetMs),
          emphasis: true,
        ),
        if (budget.libraryBlockIndexes.isNotEmpty)
          Text(
            '${budget.libraryBlockIndexes.length} calibration '
            'block${budget.libraryBlockIndexes.length == 1 ? '' : 's'} '
            'from your library (no time needed).',
            style: theme.textTheme.bodySmall,
          ),
        const SizedBox(height: 12),
        const Text(
          'Relative stacking gain (√N vs one frame)',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        if (budget.lightGroups.isEmpty)
          Text('No light frames.', style: theme.textTheme.bodySmall)
        else
          for (final g in budget.lightGroups)
            _Line(
              '${g.filterName ?? 'No filter'} · '
                  '${_seconds(g.exposureMs)} × ${g.frames}',
              '${g.relativeStackingGain.toStringAsFixed(1)}x',
            ),
        Text(
          '√N compares the random noise of a stack with one frame of the '
          'same filter and exposure. It only applies within such a group, '
          'is not a signal-to-noise ratio of your image, and ignores sky '
          'brightness, the target and your camera.',
          key: const Key('capturePlan.gainHelp'),
          style: theme.textTheme.bodySmall,
        ),
        const SizedBox(height: 12),
        _Line(
          'Estimated Storage',
          budget.storageMB != null
              ? '${budget.storageMB!.toStringAsFixed(1)} MB'
              : 'Unknown',
          emphasis: true,
        ),
        if (budget.storageMB != null)
          Text(
            'An estimate from the rig\'s average RAW file size; binning and '
            'compression are ignored.',
            style: theme.textTheme.bodySmall,
          ),
      ],
    );
  }

  static String _seconds(int ms) {
    final s = ms / 1000;
    return s == s.roundToDouble() ? '${s.round()} s' : '$s s';
  }
}

class _Line extends StatelessWidget {
  const _Line(this.label, this.value, {this.emphasis = false});

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
