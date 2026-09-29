import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import '../../../core/utils/quantity_text.dart';
import '../../../domain/models/planning_preferences.dart';
import '../../shared/app_words.dart';
import '../../shared/collapsible_section.dart';
import '../../viewmodels/settings_viewmodel.dart';
import '../../navigation/app_router.dart';
import '../planner_sections.dart';

/// Every assumption behind the capture budget and the fit (ADR-009 §4;
/// TASK 5.6). An overhead that is off reads "Not included" — never a hidden
/// zero (SI-008). Since S6.7 (ADR-019 §7) the panel is one tap away; its
/// summary keeps the constraints that shape the window in view.
class CaptureAssumptionsPanel extends StatelessWidget {
  const CaptureAssumptionsPanel({super.key});

  /// The collapsed summary, a fact: "Darkness limit −18° · minimum
  /// altitude 30° · margin 15 %".
  static String summary(PlanningPreferences p) =>
      '${AppWords.darknessLimit} ${QuantityText.degrees(p.darknessLimit.degrees)}'
      ' · minimum altitude ${QuantityText.degrees(p.minAltitudeDeg)}'
      ' · margin ${QuantityText.percent(p.feasibilityMarginPercent)}';

  @override
  Widget build(BuildContext context) {
    final p = context.watch<SettingsViewModel>().planningPreferences;
    String secs(double s) => '${s.round()} s';
    String minutes(double m) => '${m.round()} min';
    final rows = <(String, String)>[
      ('Time between frames', secs(p.perFrameOverheadSeconds)),
      (
        'Dither',
        p.ditherEveryNFrames == null
            ? 'Not included'
            : 'every ${p.ditherEveryNFrames} lights, '
                  '${secs(p.ditherSettleSeconds)}',
      ),
      (
        'Refocus',
        p.refocusEveryMinutes == null
            ? 'Not included'
            : 'every ${minutes(p.refocusEveryMinutes!)}, '
                  '${secs(p.refocusSeconds)}',
      ),
      (
        'Filter change',
        p.filterChangeSeconds == null
            ? 'Not included'
            : secs(p.filterChangeSeconds!),
      ),
      (
        'Meridian flip',
        p.meridianFlipSeconds == null
            ? 'Not included'
            : '${minutes(p.meridianFlipSeconds! / 60)}, once if the target '
                  'crosses the meridian during the plan',
      ),
      (
        'Setup',
        p.setupMinutes == null ? 'Not included' : minutes(p.setupMinutes!),
      ),
      ('Feasibility margin', QuantityText.percent(p.feasibilityMarginPercent)),
      (AppWords.darknessLimit, QuantityText.degrees(p.darknessLimit.degrees)),
      ('Minimum target altitude', QuantityText.degrees(p.minAltitudeDeg)),
    ];
    return CollapsibleSection(
      key: const Key('capturePlan.assumptions'),
      sectionKey: PlannerSections.assumptions,
      title: 'Assumptions',
      summary: summary(p),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Preferences, not laws — measure your rig.',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          for (final (label, value) in rows)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(child: Text(label)),
                  const SizedBox(width: 8),
                  Flexible(child: Text(value, textAlign: TextAlign.end)),
                ],
              ),
            ),
          Text(
            'Frames are placed one after another and never span a gap '
            'between windows. Calibration taken outside the window or from '
            'your library does not use window time.',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton(
              // The Settings tab (ADR-015); the plan is autosaved.
              onPressed: () => context.go(AppRouter.settings),
              child: const Text('Change in Planning Settings'),
            ),
          ),
        ],
      ),
    );
  }
}
