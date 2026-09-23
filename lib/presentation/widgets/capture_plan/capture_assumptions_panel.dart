import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../viewmodels/planner_viewmodel.dart';
import '../../navigation/app_router.dart';

/// Every assumption behind the capture budget and the fit, visible
/// (ADR-009 §4; TASK 5.6). An overhead that is off reads "Not included" —
/// never a hidden zero (SI-008).
class CaptureAssumptionsPanel extends StatelessWidget {
  const CaptureAssumptionsPanel({super.key, required this.viewModel});

  final PlannerViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final p = viewModel.planningPreferences;
    String secs(double s) => '${s.round()} s';
    String minutes(double m) => '${m.round()} min';
    final rows = <(String, String)>[
      ('Per-frame overhead', secs(p.perFrameOverheadSeconds)),
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
      ('Feasibility margin', '${p.feasibilityMarginPercent.round()} %'),
      ('Darkness limit', '${p.darknessLimit.degrees.round()}°'),
      ('Minimum target altitude', '${p.minAltitudeDeg.round()}°'),
    ];
    return ExpansionTile(
      key: const Key('capturePlan.assumptions'),
      tilePadding: EdgeInsets.zero,
      title: const Text('Assumptions'),
      subtitle: const Text('Preferences, not laws — measure your rig'),
      children: [
        for (final (label, value) in rows)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 2),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(label),
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
    );
  }
}
