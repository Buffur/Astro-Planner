// S8.7 (D8-4; 08 §24): an entry's Share text is structured and holds only
// what the entry holds: its identity, night, site name, rig, result,
// planned against actual and conditions — never the notes and never the
// site's coordinates.

import 'package:astroplan/core/config/app_identity.dart';
import 'package:astroplan/domain/models/calendar_date.dart';
import 'package:astroplan/domain/models/capture_block.dart';
import 'package:astroplan/domain/models/equipment_profile.dart';
import 'package:astroplan/domain/models/execution.dart';
import 'package:astroplan/domain/models/location_profile.dart';
import 'package:astroplan/domain/models/planning_preferences.dart';
import 'package:astroplan/domain/models/session.dart';
import 'package:astroplan/domain/models/session_log.dart';
import 'package:astroplan/domain/models/session_night.dart';
import 'package:astroplan/domain/models/session_result.dart';
import 'package:astroplan/domain/services/capture_budget_calculator.dart';
import 'package:astroplan/domain/services/execution_machine.dart';
import 'package:astroplan/domain/services/session_reconciliation.dart';
import 'package:astroplan/domain/services/session_snapshot_builder.dart';
import 'package:astroplan/presentation/shared/entry_share_text.dart';
import 'package:flutter_test/flutter_test.dart';

final _light = CaptureBlock(
  id: 7,
  frameType: FrameType.light,
  filterName: 'Ha',
  exposureTimeSeconds: 300,
  frameCount: 24,
);

final _snapshot = SessionSnapshotBuilder.build(
  takenAtUtc: DateTime.utc(2026, 12, 15, 18),
  night: SessionNight(
    eveningDate: CalendarDate(2026, 12, 15),
    startUtc: DateTime.utc(2026, 12, 15, 11),
    endUtc: DateTime.utc(2026, 12, 16, 11),
    latitude: 46.05123,
    longitude: 14.51234,
    timeContextId: 'Europe/Ljubljana',
  ),
  timeZoneId: 'Europe/Ljubljana',
  preferences: PlanningPreferences(),
  budget: CaptureBudgetCalculator.calculate(
    blocks: [_light],
    overheads: CaptureOverheads.fromPreferences(PlanningPreferences()),
    targetTransitsInWindow: false,
  ),
  blocks: [_light],
  site: LocationProfile(
    id: 3,
    name: 'Dark Site',
    latitude: 46.05123,
    longitude: 14.51234,
  ),
  rig: const EquipmentProfile(
    id: 1,
    name: 'Refractor 400',
    focalRatio: 5.0,
    focalLengthMm: 400.0,
    sensorWidthMm: 23.5,
    sensorHeightMm: 15.6,
    resolutionWidthPx: 6000,
    resolutionHeightPx: 4000,
    pixelPitchUm: 3.76,
  ),
);

Session _entry({
  SessionStatus status = SessionStatus.completed,
  ResultKind? kind = ResultKind.asPlanned,
  NotDoneReason? reason,
  String? name,
  bool legacy = false,
}) => Session(
  record: SessionLog(
    id: 1,
    targetName: 'M42',
    equipmentName: 'Refractor 400',
    sessionDate: DateTime.utc(2026, 12, 15),
    locationName: 'Dark Site',
    captureBlocks: [_light],
    plannedLightFrames: 24,
    actualLightFrames: legacy ? 20 : null,
    temperature: -3,
    humidity: 80,
    cloudCover: 20,
    environmentalNotes: 'Private: the gate code is 1234',
    processingNotes: 'Private processing notes',
  ),
  status: status,
  legacy: legacy,
  eveningDate: legacy ? null : CalendarDate(2026, 12, 15),
  timeZoneId: legacy ? null : 'Europe/Ljubljana',
  planSnapshot: legacy ? null : _snapshot,
  resultKind: kind,
  notDoneReason: reason,
  name: name,
);

SessionReconciliation _counts(int frames) => SessionReconciliation.of(
  [_light],
  ExecutionMachine.fold(
    {7},
    [
      ExecutionEvent(
        seq: 1,
        atUtc: DateTime.utc(2026, 12, 16, 7),
        kind: ExecutionEventKind.reported,
      ),
      if (frames > 0)
        ExecutionEvent(
          seq: 2,
          atUtc: DateTime.utc(2026, 12, 16, 7),
          kind: ExecutionEventKind.framesConfirmed,
          blockId: 7,
          delta: frames,
        ),
    ],
  ),
);

void main() {
  test('a completed entry: identity, night, site name, rig, result, counts, '
      'conditions; no notes and no coordinates', () {
    final text = EntryShareText.of(
      _entry(name: 'First light'),
      reconciliation: _counts(24),
    );
    expect(text, startsWith('First light\nM42 · '));
    expect(text, contains('Night of '));
    expect(text, contains('(Europe/Ljubljana)'));
    expect(text, contains('Site: Dark Site'));
    expect(text, contains('Rig: Refractor 400'));
    expect(text, contains('Result: Completed, reported as planned'));
    expect(text, contains('Integration: 2 h of 2 h planned'));
    expect(text, contains('Ha · 300 s: 24 of 24'));
    expect(text, contains('Conditions: '));
    expect(text, contains('80 % humidity'));
    expect(text, endsWith('— ${AppIdentity.appName}'));
    expect(text, isNot(contains('Private')));
    expect(text, isNot(contains('1234')));
    expect(text, isNot(contains('46.05')));
    expect(text, isNot(contains('14.51')));
  });

  test('Partly, Not done with a reason, a plan awaiting its result', () {
    expect(
      EntryShareText.of(
        _entry(kind: ResultKind.partly),
        reconciliation: _counts(10),
      ),
      allOf(contains('Result: Partly'), contains('Ha · 300 s: 10 of 24')),
    );
    expect(
      EntryShareText.of(
        _entry(
          status: SessionStatus.abandoned,
          kind: null,
          reason: NotDoneReason.clouds,
        ),
        reconciliation: _counts(0),
      ),
      allOf(
        contains('Result: Not done (clouds)'),
        contains('Ha · 300 s: 24 planned'),
      ),
    );
    expect(
      EntryShareText.of(
        _entry(status: SessionStatus.planned, kind: null),
        reconciliation: _counts(0),
      ),
      allOf(
        contains('Result: Saved, no result yet'),
        contains('Integration planned: 2 h'),
      ),
    );
  });

  test('an old log shares its stored totals only', () {
    final text = EntryShareText.of(_entry(legacy: true, kind: null));
    expect(text, contains('Result: Old log'));
    expect(text, contains('Light frames: 24 planned, 20 taken'));
    expect(text, contains('Rig: Refractor 400'));
    expect(text, isNot(contains('Private')));
  });
}
