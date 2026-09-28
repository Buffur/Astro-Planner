// S6.3 (S4-DEF-04 = R): a saved snapshot is read back into the plan it
// records, or not at all. Pure.

import 'package:astroplan/domain/models/astro_target.dart';
import 'package:astroplan/domain/models/calendar_date.dart';
import 'package:astroplan/domain/models/capture_block.dart';
import 'package:astroplan/domain/models/equipment_profile.dart';
import 'package:astroplan/domain/models/location_profile.dart';
import 'package:astroplan/domain/models/planning_preferences.dart';
import 'package:astroplan/domain/models/session_night.dart';
import 'package:astroplan/domain/models/session_snapshot.dart';
import 'package:astroplan/domain/services/capture_budget_calculator.dart';
import 'package:astroplan/domain/services/saved_plan_reader.dart';
import 'package:astroplan/domain/services/session_snapshot_builder.dart';
import 'package:flutter_test/flutter_test.dart';

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
    filterName: 'Ha',
    exposureTimeSeconds: 300,
    frameCount: 20,
    binning: 2,
    gain: CaptureGain.gain(100),
  ),
  CaptureBlock(
    frameType: FrameType.dark,
    exposureTimeSeconds: 300,
    frameCount: 10,
    gain: CaptureGain.iso(800),
    calibrationPolicy: CalibrationPolicy.library,
  ),
];

SessionSnapshot _snapshot({
  LocationProfile? site,
  AstroTarget? target,
  EquipmentProfile? rig,
}) {
  final prefs = PlanningPreferences();
  return SessionSnapshotBuilder.build(
    takenAtUtc: DateTime.utc(2026, 12, 15, 18),
    night: _night,
    timeZoneId: 'Europe/Ljubljana',
    preferences: prefs,
    budget: CaptureBudgetCalculator.calculate(
      blocks: _blocks,
      overheads: CaptureOverheads.fromPreferences(prefs),
    ),
    blocks: _blocks,
    site: site,
    target: target,
    rig: rig,
  );
}

void main() {
  test('reads back the night key, zone, references, labels and every block '
      'field', () {
    final plan = SavedPlanReader.read(
      _snapshot(
        site: LocationProfile(
          id: 3,
          name: 'Dark Site',
          latitude: 46.05,
          longitude: 14.51,
          elevation: 300,
          timeZoneId: 'Europe/Ljubljana',
        ),
        target: AstroTarget(
          id: 7,
          catalogId: 'M31',
          commonName: 'Andromeda Galaxy',
          type: 'Galaxy',
          rightAscension: 10.68,
          declination: 41.27,
        ),
        rig: const EquipmentProfile(
          id: 9,
          name: 'Refractor 400',
          focalRatio: 5.6,
          focalLengthMm: 400,
          sensorWidthMm: 23.5,
          sensorHeightMm: 15.7,
          resolutionWidthPx: 6248,
          resolutionHeightPx: 4176,
          pixelPitchUm: 3.76,
        ),
      ),
    )!;
    expect(plan.eveningDate, CalendarDate(2026, 12, 15));
    expect(plan.timeZoneId, 'Europe/Ljubljana');
    expect((plan.siteId, plan.targetId, plan.rigId), (3, 7, 9));
    expect(plan.siteLabel, 'Dark Site');
    expect(plan.targetLabel, 'Andromeda Galaxy');
    expect(plan.rigLabel, 'Refractor 400');
    expect(plan.blocks, hasLength(2));
    for (var i = 0; i < 2; i++) {
      final (a, b) = (plan.blocks[i], _blocks[i]);
      expect(a.frameType, b.frameType);
      expect(a.filterName, b.filterName);
      expect(a.exposureTimeSeconds, b.exposureTimeSeconds);
      expect(a.frameCount, b.frameCount);
      expect(a.binning, b.binning);
      expect(a.gain, b.gain);
      expect(a.calibrationPolicy, b.calibrationPolicy);
    }
  });

  test('a plan without a saved site keeps no site, as saved', () {
    final plan = SavedPlanReader.read(_snapshot())!;
    expect(plan.siteId, isNull);
    expect(plan.siteLabel, isNull);
    expect(plan.targetLabel, '(no target)');
    expect(plan.rigLabel, '(no rig)');
  });

  test('anything unreadable gives no plan, never a partial one', () {
    final good = Map<String, Object?>.of(_snapshot().json);
    SessionSnapshot withValue(String key, Object? value) =>
        SessionSnapshot.fromBuilder({...good, key: value});

    expect(SavedPlanReader.read(withValue('blocks', 'junk')), isNull);
    expect(SavedPlanReader.read(withValue('night', null)), isNull);
    expect(
      SavedPlanReader.read(
        withValue('blocks', [
          {'frameType': 'light', 'exposureS': 300, 'frameCount': 0},
        ]),
      ),
      isNull,
      reason: 'a block the domain refuses',
    );
    expect(
      SavedPlanReader.read(
        withValue('blocks', [
          {
            'frameType': 'dark',
            'exposureS': 300,
            'frameCount': 5,
            'calibrationPolicy': 'sometimes',
          },
        ]),
      ),
      isNull,
      reason: 'an unknown calibration policy',
    );
  });
}
