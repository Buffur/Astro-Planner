import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../domain/models/planning_preferences.dart';
import '../../viewmodels/settings_viewmodel.dart';
import '../../navigation/app_router.dart';
import '../../shared/field_mode_button.dart';
import '../../shared/failure_feedback.dart';
import 'backup_section.dart';
import '../../../core/utils/quantity_text.dart';

/// Settings (TASK 5.2, SI-006, TD-043; rebuilt by S9.4 after RG-13's
/// research, `docs/refinement/research/S9.3_SETTINGS.md` §4, D9-3).
///
/// Sections by what a value changes: the imaging window, the fit and
/// capture time, advice only, then the display, privacy, data and About.
/// Each row shows its value with its unit and its consequence. Every value
/// is a preference with a documented default, not a scientific law; the
/// screen only edits [PlanningPreferences] through the ViewModel, and every
/// calculation stays in the domain.
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settingsVm = context.watch<SettingsViewModel>();
    final p = settingsVm.planningPreferences;
    // Trap 18: a write the user starts reports a failure.
    void update(PlanningPreferences next) => runWithFeedback(
      context,
      'save the setting',
      () => settingsVm.setPlanningPreferences(next),
    );
    final small = Theme.of(context).textTheme.bodySmall;

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.md),
        children: [
          Text(
            'These are planning preferences, not scientific laws. The '
            'defaults are common rules of thumb; adjust them to your sky, '
            'your targets and your rig.',
            style: small,
          ),
          const _Section(
            'Imaging window',
            'Changes when the planner counts time as usable.',
          ),
          _SliderTile(
            key: const Key('settings.minAltitude'),
            title: 'Minimum target altitude',
            help:
                'Below this the target is not counted as usable. Low '
                'altitude means more atmosphere, extinction and poor seeing.',
            value: p.minAltitudeDeg,
            range: PlanningPreferences.minAltitudeRange,
            divisions: 55,
            label: QuantityText.degrees(p.minAltitudeDeg),
            onChanged: (v) => update(p.copyWith(minAltitudeDeg: v)),
          ),
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Darkness limit (Sun altitude)'),
            subtitle: const Text(
              '−18° is full astronomical darkness. −15° or −12° give longer '
              'windows with a brighter sky background.',
            ),
            trailing: Text(QuantityText.degrees(p.darknessLimit.degrees)),
          ),
          SegmentedButton<DarknessLimit>(
            key: const Key('settings.darknessLimit'),
            segments: [
              for (final l in DarknessLimit.values)
                ButtonSegment(
                  value: l,
                  label: Text(QuantityText.degrees(l.degrees)),
                ),
            ],
            selected: {p.darknessLimit},
            onSelectionChanged: (s) =>
                update(p.copyWith(darknessLimit: s.first)),
          ),
          const SizedBox(height: AppSpacing.sm),
          // RD-11 = S9, TD-050: the optional gates of ADR-013 (G4, G5).
          _GateTile(
            key: const Key('settings.moonGate'),
            title: 'Moon gate',
            enabled: p.moonGateEnabled,
            percent: p.moonGateMinIlluminationPct,
            on: (pct) =>
                'Excludes time when the Moon is up and at least $pct lit.',
            off: 'Off: the Moon never excludes time.',
            onToggle: (on) => update(p.copyWith(moonGateEnabled: on)),
            onPercent: (v) => update(p.copyWith(moonGateMinIlluminationPct: v)),
          ),
          _GateTile(
            key: const Key('settings.cloudGate'),
            title: 'Cloud gate',
            enabled: p.cloudGateEnabled,
            percent: p.cloudGateMaxPct,
            on: (pct) =>
                'Excludes forecast hours with more than $pct cloud. An hour '
                'without a forecast is never excluded.',
            off: 'Off: the forecast never excludes time.',
            onToggle: (on) => update(p.copyWith(cloudGateEnabled: on)),
            onPercent: (v) => update(p.copyWith(cloudGateMaxPct: v)),
          ),
          const _Section(
            'Fit and capture time',
            'Changes the capture budget and the fit verdict.',
          ),
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
            // S7.2b (ADR-020 §4, I1): the one interval concept, relabelled.
            title: 'Time between frames',
            help:
                'From the end of one frame to the start of the next: the '
                'download or processing, plus any delay you set. A camera '
                'timer counted start to start gives its interval minus the '
                'exposure. Settling after a dither is the Dither overhead, '
                'not this. An assumption — measure your rig.',
            value: p.perFrameOverheadSeconds,
            // S9.4: the model's range (0–120 s), not a narrower one.
            range: PlanningPreferences.perFrameRange,
            divisions: 120,
            label: '${p.perFrameOverheadSeconds.round()} s',
            onChanged: (v) => update(p.copyWith(perFrameOverheadSeconds: v)),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Optional overheads. Off means "not included" in the plan — '
            'not zero. When on, it is included in the capture plan\'s '
            'budget and fit; the values are assumptions — measure your rig.',
            style: small,
          ),
          _OptionalOverhead(
            key: const Key('settings.dither'),
            title: 'Dither',
            enabled: p.ditherEveryNFrames != null,
            summary: p.ditherEveryNFrames == null
                ? 'Not included'
                : 'Every ${p.ditherEveryNFrames} lights, '
                      '${p.ditherSettleSeconds.round()} s to settle each',
            onToggle: (on) => update(
              p.withOptionalOverheads(ditherEveryNFrames: (on ? 3 : null,)),
            ),
            steppers: [
              if (p.ditherEveryNFrames case final n?)
                _Stepper(
                  key: const Key('settings.dither.every'),
                  label: 'Every',
                  value: n.toDouble(),
                  range: (1, 100),
                  step: 1,
                  format: (v) => '${v.round()} lights',
                  onChanged: (v) => update(
                    p.withOptionalOverheads(ditherEveryNFrames: (v.round(),)),
                  ),
                ),
              if (p.ditherEveryNFrames != null)
                _Stepper(
                  key: const Key('settings.dither.settle'),
                  label: 'Settle',
                  value: p.ditherSettleSeconds,
                  range: PlanningPreferences.overheadSecondsRange,
                  step: 5,
                  format: (v) => '${v.round()} s',
                  onChanged: (v) => update(p.copyWith(ditherSettleSeconds: v)),
                ),
            ],
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
            steppers: [
              if (p.refocusEveryMinutes case final every?)
                _Stepper(
                  key: const Key('settings.refocus.every'),
                  label: 'Every',
                  value: every,
                  range: PlanningPreferences.refocusIntervalRange,
                  step: 10,
                  format: (v) => '${v.round()} min',
                  onChanged: (v) => update(
                    p.withOptionalOverheads(refocusEveryMinutes: (v,)),
                  ),
                ),
              if (p.refocusEveryMinutes != null)
                _Stepper(
                  key: const Key('settings.refocus.duration'),
                  label: 'Takes',
                  value: p.refocusSeconds,
                  range: PlanningPreferences.overheadSecondsRange,
                  step: 10,
                  format: (v) => '${v.round()} s',
                  onChanged: (v) => update(p.copyWith(refocusSeconds: v)),
                ),
            ],
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
            steppers: [
              if (p.filterChangeSeconds case final s?)
                _Stepper(
                  key: const Key('settings.filterChange.seconds'),
                  label: 'Takes',
                  value: s,
                  range: PlanningPreferences.overheadSecondsRange,
                  step: 5,
                  format: (v) => '${v.round()} s',
                  onChanged: (v) => update(
                    p.withOptionalOverheads(filterChangeSeconds: (v,)),
                  ),
                ),
            ],
          ),
          _OptionalOverhead(
            key: const Key('settings.flip'),
            title: 'Meridian flip',
            enabled: p.meridianFlipSeconds != null,
            summary: p.meridianFlipSeconds == null
                ? 'Not included'
                : '${QuantityText.duration(Duration(seconds: p.meridianFlipSeconds!.round()))}, '
                      'once, when the target crosses the meridian',
            onToggle: (on) => update(
              p.withOptionalOverheads(
                meridianFlipSeconds: (on ? 300.0 : null,),
              ),
            ),
            steppers: [
              if (p.meridianFlipSeconds case final s?)
                _Stepper(
                  key: const Key('settings.flip.seconds'),
                  label: 'Takes',
                  value: s,
                  range: PlanningPreferences.flipSecondsRange,
                  step: 30,
                  format: (v) => '${v.round()} s',
                  onChanged: (v) => update(
                    p.withOptionalOverheads(meridianFlipSeconds: (v,)),
                  ),
                ),
            ],
          ),
          _OptionalOverhead(
            key: const Key('settings.setup'),
            title: 'Setup before the first window',
            enabled: p.setupMinutes != null,
            summary: p.setupMinutes == null
                ? 'Not included'
                : '${p.setupMinutes!.round()} min, in the total time only',
            onToggle: (on) => update(
              p.withOptionalOverheads(setupMinutes: (on ? 30.0 : null,)),
            ),
            steppers: [
              if (p.setupMinutes case final m?)
                _Stepper(
                  key: const Key('settings.setup.minutes'),
                  label: 'Takes',
                  value: m,
                  range: PlanningPreferences.setupMinutesRange,
                  step: 5,
                  format: (v) => '${v.round()} min',
                  onChanged: (v) =>
                      update(p.withOptionalOverheads(setupMinutes: (v,))),
                ),
            ],
          ),
          const _Section(
            'Guidance',
            'Changes advice only; never the imaging window or the fit.',
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
          const _Section('Display', 'How the app looks; no value changes.'),
          const FieldModeTile(),
          const _Section('Privacy', 'What leaves this device.'),
          // TASK 16.3 (owner decision): opt-in, off by default.
          SwitchListTile(
            key: const Key('settings.placeNames'),
            contentPadding: EdgeInsets.zero,
            secondary: const Icon(Icons.place_outlined),
            title: const Text('Look up place names'),
            subtitle: const Text(
              'Sends the chosen position to OpenStreetMap Nominatim to '
              'show a place name. Off: positions are shown as coordinates '
              'and nothing is sent.',
            ),
            value: settingsVm.placeNameLookup,
            onChanged: (on) => runWithFeedback(
              context,
              'save the place-name setting',
              () => settingsVm.setPlaceNameLookup(on),
            ),
          ),
          const _Section(
            'Data',
            'Your plans, results, sites, rigs, targets and these settings.',
          ),
          // TASK 14.4: backup and restore.
          const BackupSection(),
          const _Section('About', 'Who made this, and the data it uses.'),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.info_outline),
            title: const Text('About & data sources'),
            subtitle: const Text('Attributions, licences and privacy'),
            onTap: () => context.push(AppRouter.about),
          ),
        ],
      ),
    );
  }
}

/// A section heading and one line saying what its values change (S9.4).
class _Section extends StatelessWidget {
  const _Section(this.title, this.consequence);
  final String title;
  final String consequence;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.lg, bottom: AppSpacing.xs),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Semantics(header: true, child: Text(title, style: text.titleMedium)),
          Text(consequence, style: text.bodySmall),
        ],
      ),
    );
  }
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

/// An optional ADR-013 gate (S9.4; TD-050): a switch with its consequence,
/// and its percentage when on.
class _GateTile extends StatelessWidget {
  const _GateTile({
    super.key,
    required this.title,
    required this.enabled,
    required this.percent,
    required this.on,
    required this.off,
    required this.onToggle,
    required this.onPercent,
  });

  final String title;
  final bool enabled;
  final double percent;
  final String Function(String percent) on;
  final String off;
  final ValueChanged<bool> onToggle;
  final ValueChanged<double> onPercent;

  @override
  Widget build(BuildContext context) {
    final label = '${percent.round()} %';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(title),
          subtitle: Text(enabled ? on(label) : off),
          value: enabled,
          onChanged: onToggle,
        ),
        if (enabled)
          Slider(
            value: percent.clamp(0, 100),
            min: PlanningPreferences.gatePctRange.$1,
            max: PlanningPreferences.gatePctRange.$2,
            divisions: 20,
            label: label,
            onChanged: onPercent,
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
    this.steppers = const [],
  });

  final String title;
  final bool enabled;
  final String summary;
  final ValueChanged<bool> onToggle;

  /// Its values, editable while it is on (S9.4, D9-3).
  final List<Widget> steppers;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      SwitchListTile(
        contentPadding: EdgeInsets.zero,
        title: Text(title),
        subtitle: Text(summary),
        value: enabled,
        onChanged: onToggle,
      ),
      ...steppers,
    ],
  );
}

/// One value, stepped within the model's [range] (S9.4): "Every  − 3 lights +".
class _Stepper extends StatelessWidget {
  const _Stepper({
    super.key,
    required this.label,
    required this.value,
    required this.range,
    required this.step,
    required this.format,
    required this.onChanged,
  });

  final String label;
  final double value;
  final (double, double) range;
  final double step;
  final String Function(double) format;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    final shown = format(value);
    return Padding(
      padding: const EdgeInsets.only(left: AppSpacing.md),
      child: Row(
        children: [
          Expanded(child: Text(label)),
          IconButton(
            tooltip: '$label: less',
            icon: const Icon(Icons.remove),
            onPressed: value > range.$1
                ? () => onChanged((value - step).clamp(range.$1, range.$2))
                : null,
          ),
          Semantics(liveRegion: true, child: Text(shown)),
          IconButton(
            tooltip: '$label: more',
            icon: const Icon(Icons.add),
            onPressed: value < range.$2
                ? () => onChanged((value + step).clamp(range.$1, range.$2))
                : null,
          ),
        ],
      ),
    );
  }
}
