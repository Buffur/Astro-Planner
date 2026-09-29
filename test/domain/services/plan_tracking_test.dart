// S7.1 (RD-08 = T3): a plan may override its rig's tracking. The effective
// value is the override, else the rig's default, else unknown; the
// capability guidance reads it; a saved snapshot records the value and its
// source, and Discard's read-back restores the override from it. Pure.

import 'package:astroplan/domain/models/astro_target.dart';
import 'package:astroplan/domain/models/calendar_date.dart';
import 'package:astroplan/domain/models/capture_block.dart';
import 'package:astroplan/domain/models/equipment_profile.dart';
import 'package:astroplan/domain/models/planning_preferences.dart';
import 'package:astroplan/domain/models/session_night.dart';
import 'package:astroplan/domain/models/session_snapshot.dart';
import 'package:astroplan/domain/models/tracking_type.dart';
import 'package:astroplan/domain/services/capability_calculator.dart';
import 'package:astroplan/domain/services/capture_budget_calculator.dart';
import 'package:astroplan/domain/services/saved_plan_reader.dart';
import 'package:astroplan/domain/services/session_snapshot_builder.dart';
import 'package:flutter_test/flutter_test.dart';

EquipmentProfile _rig(TrackingType tracking, {double? maxExposureS}) =>
    EquipmentProfile(
      id: 9,
      name: 'Refractor 400',
      focalRatio: 5.6,
      focalLengthMm: 400,
      sensorWidthMm: 23.5,
      sensorHeightMm: 15.7,
      resolutionWidthPx: 6248,
      resolutionHeightPx: 4176,
      pixelPitchUm: 3.76,
      trackingType: tracking,
      maxExposureS: maxExposureS,
    );

const _target = AstroTarget(
  id: 7,
  catalogId: 'M42',
  rightAscension: 83.82,
  declination: -5.39,
  type: 'Nebula',
);

final _night = SessionNight(
  eveningDate: CalendarDate(2026, 12, 15),
  startUtc: DateTime.utc(2026, 12, 15, 11),
  endUtc: DateTime.utc(2026, 12, 16, 11),
  latitude: 46.05,
  longitude: 14.51,
  timeContextId: 'Europe/Ljubljana',
);

final _blocks = [
  CaptureBlock(
    frameType: FrameType.light,
    exposureTimeSeconds: 60,
    frameCount: 10,
  ),
];

SessionSnapshot _snapshot(EquipmentProfile? rig, TrackingType? override) {
  final prefs = PlanningPreferences();
  return SessionSnapshotBuilder.build(
    takenAtUtc: DateTime.utc(2026, 12, 15, 18),
    night: _night,
    preferences: prefs,
    budget: CaptureBudgetCalculator.calculate(
      blocks: _blocks,
      overheads: CaptureOverheads.fromPreferences(prefs),
    ),
    blocks: _blocks,
    rig: rig,
    trackingOverride: override,
  );
}

void main() {
  group('EffectiveTracking.of', () {
    test('the override wins, and says it is the plan\'s', () {
      expect(
        EffectiveTracking.of(
          override: TrackingType.untracked,
          rigDefault: TrackingType.guided,
        ),
        const EffectiveTracking(TrackingType.untracked, TrackingSource.plan),
      );
    });

    test('without an override, the rig\'s default; without a rig, unknown', () {
      expect(
        EffectiveTracking.of(rigDefault: TrackingType.guided),
        const EffectiveTracking(TrackingType.guided, TrackingSource.rig),
      );
      expect(
        EffectiveTracking.of(),
        const EffectiveTracking(TrackingType.unknown, TrackingSource.rig),
      );
    });

    test('unknown is never an override: it reads as the rig\'s default', () {
      expect(
        EffectiveTracking.of(
          override: TrackingType.unknown,
          rigDefault: TrackingType.tracked,
        ),
        const EffectiveTracking(TrackingType.tracked, TrackingSource.rig),
      );
    });

    test('only the three known types are stored overrides', () {
      expect(TrackingType.overrides, [
        TrackingType.untracked,
        TrackingType.tracked,
        TrackingType.guided,
      ]);
      for (final t in TrackingType.overrides) {
        expect(TrackingType.overrideFromStorage(t.name), t);
      }
      expect(TrackingType.overrideFromStorage('unknown'), isNull);
      expect(TrackingType.overrideFromStorage('equatorial'), isNull);
      expect(TrackingType.overrideFromStorage(null), isNull);
    });
  });

  group('the capability guidance reads the effective tracking', () {
    test('a guided rig used untracked for this plan gets NPF and its '
        'warning', () {
      final rig = _rig(TrackingType.guided);
      expect(CapabilityCalculator.evaluate(rig, target: _target).npf, isNull);
      final c = CapabilityCalculator.evaluate(
        rig,
        target: _target,
        tracking: TrackingType.untracked,
      );
      expect(c.npf, isNotNull);
      expect(c.npf!.conditional, isFalse);
      expect(c.exceedsRecommendation(c.recommendedMaxSubS! + 1), isTrue);
    });

    test('an untracked rig used tracked for this plan gets no NPF; only the '
        'rig\'s own maximum, if set, guides the sub', () {
      final plain = CapabilityCalculator.evaluate(
        _rig(TrackingType.untracked),
        target: _target,
        tracking: TrackingType.tracked,
      );
      expect(plain.npf, isNull);
      expect(plain.recommendedMaxSubS, isNull);
      final capped = CapabilityCalculator.evaluate(
        _rig(TrackingType.untracked, maxExposureS: 120),
        target: _target,
        tracking: TrackingType.guided,
      );
      expect(capped.npf, isNull);
      expect(capped.recommendedMaxSubS, 120);
    });

    test('unknown keeps PD-11\'s "if untracked"', () {
      final c = CapabilityCalculator.evaluate(
        _rig(TrackingType.guided),
        target: _target,
        tracking: TrackingType.unknown,
      );
      expect(c.npf!.conditional, isTrue);
      expect(c.recommendationIsConditional, isTrue);
    });

    test('without a tracking, the rig\'s default, as before S7.1', () {
      final c = CapabilityCalculator.evaluate(
        _rig(TrackingType.untracked),
        target: _target,
      );
      expect(c.npf, isNotNull);
    });
  });

  group('the snapshot', () {
    test('records the effective value and its source; the rig keeps its '
        'default', () {
      final json = _snapshot(
        _rig(TrackingType.guided),
        TrackingType.untracked,
      ).json;
      expect(json['tracking'], {'effective': 'untracked', 'source': 'plan'});
      expect((json['rig']! as Map)['tracking'], 'guided');

      final byRig = _snapshot(_rig(TrackingType.tracked), null).json;
      expect(byRig['tracking'], {'effective': 'tracked', 'source': 'rig'});
    });

    test('an unknown default stays unknown: never made a fact', () {
      final json = _snapshot(_rig(TrackingType.unknown), null).json;
      expect(json['tracking'], {'effective': 'unknown', 'source': 'rig'});
    });

    test('no rig, no tracking', () {
      expect(_snapshot(null, TrackingType.untracked).json['tracking'], isNull);
    });
  });

  group('Discard\'s read-back (SavedPlanReader)', () {
    test('restores the plan\'s override', () {
      final plan = SavedPlanReader.read(
        _snapshot(_rig(TrackingType.guided), TrackingType.untracked),
      )!;
      expect(plan.trackingOverride, TrackingType.untracked);
    });

    test('a rig\'s default is no override', () {
      final plan = SavedPlanReader.read(
        _snapshot(_rig(TrackingType.guided), null),
      )!;
      expect(plan.trackingOverride, isNull);
    });

    test('a snapshot taken before S7.1 had none', () {
      final json = Map<String, Object?>.of(
        _snapshot(_rig(TrackingType.guided), null).json,
      )..remove('tracking');
      final plan = SavedPlanReader.read(SessionSnapshot.fromBuilder(json))!;
      expect(plan.trackingOverride, isNull);
    });

    test('a plan override it cannot read gives no plan, never a guess', () {
      final json = Map<String, Object?>.of(
        _snapshot(_rig(TrackingType.guided), null).json,
      );
      json['tracking'] = {'effective': 'unknown', 'source': 'plan'};
      expect(SavedPlanReader.read(SessionSnapshot.fromBuilder(json)), isNull);
    });
  });
}
