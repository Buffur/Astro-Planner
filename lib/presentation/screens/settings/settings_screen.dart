import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../domain/models/planning_preferences.dart';
import '../../viewmodels/planner_viewmodel.dart';
import '../../../core/config/feature_scope.dart';
import '../../navigation/app_router.dart';

/// Planning preferences (TASK 5.2, SI-006, TD-043).
///
/// Every value here is a preference with a documented default, not a
/// scientific law. The screen only edits [PlanningPreferences]; all
/// calculations stay in the domain.
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<PlannerViewModel>();
    final p = vm.planningPreferences;
    void update(PlanningPreferences next) => vm.setPlanningPreferences(next);

    return Scaffold(
      appBar: AppBar(title: const Text('Planning Settings')),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.md),
        children: [
          Text(
            'These are planning preferences, not scientific laws. The '
            'defaults are common rules of thumb; adjust them to your sky, '
            'your targets and your rig.',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: AppSpacing.md),
          _Section('Visibility'),
          _SliderTile(
            key: const Key('settings.minAltitude'),
            title: 'Minimum target altitude',
            help:
                'Below this the target is not counted as usable. Low '
                'altitude means more atmosphere, extinction and poor seeing.',
            value: p.minAltitudeDeg,
            range: PlanningPreferences.minAltitudeRange,
            divisions: 55,
            label: '${p.minAltitudeDeg.round()}°',
            onChanged: (v) => update(p.copyWith(minAltitudeDeg: v)),
          ),
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Darkness limit (Sun altitude)'),
            subtitle: const Text(
              '−18° is full astronomical darkness. −15° or −12° give longer '
              'windows with a brighter sky background.',
            ),
          ),
          SegmentedButton<DarknessLimit>(
            key: const Key('settings.darknessLimit'),
            segments: [
              for (final l in DarknessLimit.values)
                ButtonSegment(value: l, label: Text('${l.degrees.round()}°')),
            ],
            selected: {p.darknessLimit},
            onSelectionChanged: (s) =>
                update(p.copyWith(darknessLimit: s.first)),
          ),
          const SizedBox(height: AppSpacing.md),
          _SliderTile(
            key: const Key('settings.dewMargin'),
            title: 'Dew warning margin',
            help:
                'Warn when the air temperature is within this many °C of the '
                'dew point.',
            value: p.dewMarginC,
            range: PlanningPreferences.dewMarginRange,
            divisions: 20,
            label: '${p.dewMarginC.toStringAsFixed(1)} °C',
            onChanged: (v) => update(p.copyWith(dewMarginC: v)),
          ),
          _SliderTile(
            key: const Key('settings.npfK'),
            title: 'NPF star-trail tolerance (k)',
            help:
                'For untracked exposures (Michaud NPF rule): 1 = round stars, '
                'up to 3 = slightly elongated. Higher allows longer '
                'sub-exposures.',
            value: p.npfK,
            range: PlanningPreferences.npfKRange,
            divisions: 4,
            label: 'k = ${p.npfK.toStringAsFixed(1)}',
            onChanged: (v) => update(p.copyWith(npfK: v)),
          ),
          _Section('Capture plan'),
          _SliderTile(
            key: const Key('settings.margin'),
            title: 'Feasibility margin',
            help:
                'A plan that leaves less than this share of the available '
                'time free is marked "tight".',
            value: p.feasibilityMarginPercent,
            range: PlanningPreferences.marginRange,
            divisions: 50,
            label: '${p.feasibilityMarginPercent.round()} %',
            onChanged: (v) => update(p.copyWith(feasibilityMarginPercent: v)),
          ),
          _SliderTile(
            key: const Key('settings.perFrame'),
            title: 'Per-frame overhead',
            help:
                'Download or interval time added to every frame. An '
                'assumption — measure your rig.',
            value: p.perFrameOverheadSeconds,
            range: (0.0, 60.0),
            divisions: 60,
            label: '${p.perFrameOverheadSeconds.round()} s',
            onChanged: (v) => update(p.copyWith(perFrameOverheadSeconds: v)),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Optional overheads. Off means "not included" in the plan — '
            'not zero.',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          _OptionalOverhead(
            key: const Key('settings.dither'),
            title: 'Dither',
            enabled: p.ditherEveryNFrames != null,
            summary: p.ditherEveryNFrames == null
                ? 'Not included'
                : 'Every ${p.ditherEveryNFrames} lights, '
                      '${p.ditherSettleSeconds.round()} s each',
            onToggle: (on) => update(
              p.withOptionalOverheads(ditherEveryNFrames: (on ? 3 : null,)),
            ),
          ),
          _OptionalOverhead(
            key: const Key('settings.refocus'),
            title: 'Refocus',
            enabled: p.refocusEveryMinutes != null,
            summary: p.refocusEveryMinutes == null
                ? 'Not included'
                : 'Every ${p.refocusEveryMinutes!.round()} min, '
                      '${p.refocusSeconds.round()} s each',
            onToggle: (on) => update(
              p.withOptionalOverheads(refocusEveryMinutes: (on ? 60.0 : null,)),
            ),
          ),
          _OptionalOverhead(
            key: const Key('settings.filterChange'),
            title: 'Filter change',
            enabled: p.filterChangeSeconds != null,
            summary: p.filterChangeSeconds == null
                ? 'Not included'
                : '${p.filterChangeSeconds!.round()} s per change',
            onToggle: (on) => update(
              p.withOptionalOverheads(filterChangeSeconds: (on ? 30.0 : null,)),
            ),
          ),
          _OptionalOverhead(
            key: const Key('settings.flip'),
            title: 'Meridian flip',
            enabled: p.meridianFlipSeconds != null,
            summary: p.meridianFlipSeconds == null
                ? 'Not included'
                : '${(p.meridianFlipSeconds! / 60).round()} min, once',
            onToggle: (on) => update(
              p.withOptionalOverheads(
                meridianFlipSeconds: (on ? 300.0 : null,),
              ),
            ),
          ),
          _OptionalOverhead(
            key: const Key('settings.setup'),
            title: 'Setup before the first window',
            enabled: p.setupMinutes != null,
            summary: p.setupMinutes == null
                ? 'Not included'
                : '${p.setupMinutes!.round()} min',
            onToggle: (on) => update(
              p.withOptionalOverheads(setupMinutes: (on ? 30.0 : null,)),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Values used when an overhead is switched on are assumptions — '
            'measure your rig. Optional overheads are saved now and will be '
            'applied to the capture plan in a later update.',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const Divider(height: AppSpacing.lg * 2),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.info_outline),
            title: const Text('About & data sources'),
            subtitle: const Text('Catalog attribution and licences'),
            onTap: () => context.push(AppRouter.about),
          ),
          // TASK 12.2 (ADR-015): metadata import lives under Settings; still
          // gated until G17 (FeatureScope, PD-06).
          if (FeatureScope.metadataImport)
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.info_outline),
              title: const Text('Import metadata'),
              onTap: () => context.push(AppRouter.metadata),
            ),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section(this.title);
  final String title;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: AppSpacing.md, bottom: AppSpacing.xs),
    child: Text(title, style: Theme.of(context).textTheme.titleMedium),
  );
}

class _SliderTile extends StatelessWidget {
  const _SliderTile({
    super.key,
    required this.title,
    required this.help,
    required this.value,
    required this.range,
    required this.divisions,
    required this.label,
    required this.onChanged,
  });

  final String title;
  final String help;
  final double value;
  final (double, double) range;
  final int divisions;
  final String label;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(title),
          subtitle: Text(help),
          trailing: Text(label),
        ),
        Slider(
          value: value.clamp(range.$1, range.$2),
          min: range.$1,
          max: range.$2,
          divisions: divisions,
          label: label,
          onChanged: onChanged,
        ),
      ],
    );
  }
}

class _OptionalOverhead extends StatelessWidget {
  const _OptionalOverhead({
    super.key,
    required this.title,
    required this.enabled,
    required this.summary,
    required this.onToggle,
  });

  final String title;
  final bool enabled;
  final String summary;
  final ValueChanged<bool> onToggle;

  @override
  Widget build(BuildContext context) => SwitchListTile(
    contentPadding: EdgeInsets.zero,
    title: Text(title),
    subtitle: Text(summary),
    value: enabled,
    onChanged: onToggle,
  );
}
