// S7.1 (RD-08 = T3): a plan may override its rig's tracking for its night.
// The override is a plan edit (autosaved; never written to the rig); the
// guidance uses the effective value; Save records it with its source;
// Discard on a Saved · changed plan restores it; Copy carries it; New plan
// starts without it; a rig change keeps it; the example rig stays unknown.
// Real SQLite, through the planner's ViewModels and its row.

import 'package:astroplan/core/time/clock.dart';
import 'package:astroplan/data/database/app_database.dart' show AppDatabase;
import 'package:astroplan/data/repositories/drift_equipment_repository.dart';
import 'package:astroplan/data/repositories/drift_location_repository.dart';
import 'package:astroplan/data/repositories/drift_session_repository.dart';
import 'package:astroplan/data/repositories/drift_target_repository.dart';
import 'package:astroplan/domain/models/astro_target.dart';
import 'package:astroplan/domain/models/calendar_date.dart';
import 'package:astroplan/domain/models/capture_block.dart';
import 'package:astroplan/domain/models/equipment_profile.dart';
import 'package:astroplan/domain/models/location_profile.dart' as domain;
import 'package:astroplan/domain/models/session.dart';
import 'package:astroplan/domain/models/tracking_type.dart';
import 'package:astroplan/domain/repositories/weather_repository.dart';
import 'package:astroplan/presentation/widgets/capture_plan_widget.dart';
import 'package:astroplan/presentation/widgets/plan_tracking.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../support/fake_device_time_zone.dart';
import '../support/fake_location_service.dart';
import '../support/fake_reverse_geocoder.dart';
import '../support/no_snapshot_weather.dart';
import '../support/planner_harness.dart';

class _NoForecast with NoSnapshotWeather implements WeatherRepository {}

const _m42 = AstroTarget(
  id: 1,
  catalogId: 'M42',
  rightAscension: 83.82,
  declination: -5.39,
  type: 'Nebula',
);

EquipmentProfile _rig(String name, TrackingType tracking) => EquipmentProfile(
  id: 0,
  name: name,
  sensorWidthMm: 23.5,
  sensorHeightMm: 15.7,
  pixelPitchUm: 3.76,
  resolutionWidthPx: 6248,
  resolutionHeightPx: 4176,
  focalLengthMm: 400,
  focalRatio: 5.6,
  trackingType: tracking,
);

void main() {
  late AppDatabase db;
  late PlannerHarness vm;
  late DriftSessionRepository sessions;
  late DriftEquipmentRepository rigs;
  late int guidedId;
  late int untrackedId;

  /// A planner on a real database with a site, M42 and a guided rig chosen,
  /// and one light block longer than NPF would allow untracked.
  Future<void> start(WidgetTester tester, {Widget? child}) async {
    tester.view.physicalSize = const Size(412, 3000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    await tester.runAsync(() async {
      db = AppDatabase(NativeDatabase.memory());
      final siteId = await DriftLocationRepository(db).insertLocation(
        domain.LocationProfile(
          id: 0,
          name: 'Ljubljana',
          latitude: 46.05,
          longitude: 14.51,
          elevation: 300,
          timeZoneId: 'Europe/Ljubljana',
        ),
      );
      SharedPreferences.setMockInitialValues({'activeLocationId': siteId});
      final clock = FixedClock(DateTime.utc(2026, 11, 10, 16));
      sessions = DriftSessionRepository(db, clock: clock);
      rigs = DriftEquipmentRepository(db);
      final targets = DriftTargetRepository(db);
      guidedId = await rigs.insertEquipment(
        _rig('Guided refractor', TrackingType.guided),
      );
      untrackedId = await rigs.insertEquipment(
        _rig('Tripod camera', TrackingType.untracked),
      );
      final targetId = await targets.insertTarget(_m42);
      vm = PlannerHarness(
        targets,
        rigs,
        _NoForecast(),
        DriftLocationRepository(db),
        locationService: FakeLocationService(),
        reverseGeocoder: FakeReverseGeocoder(),
        deviceTimeZone: FakeDeviceTimeZone(),
        clock: clock,
        sessionRepository: sessions,
      );
      await vm.ready;
      await vm.plan.setTarget((await targets.getTargetById(targetId))!);
      await vm.plan.setEquipment((await rigs.getEquipmentById(guidedId))!);
      await vm.plan.addCaptureBlock(
        CaptureBlock(
          frameType: FrameType.light,
          exposureTimeSeconds: 300,
          frameCount: 10,
        ),
      );
      await vm.plan.idle;
    });
    addTearDown(() => tester.runAsync(db.close));
    await tester.pumpWidget(
      MultiProvider(
        providers: vm.providers,
        child: MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child:
                  child ??
                  const Column(
                    children: [PlanTrackingRow(), CapturePlanWidget()],
                  ),
            ),
          ),
        ),
      ),
    );
    await tester.pump();
  }

  Future<Session> stored(WidgetTester tester) async =>
      (await tester.runAsync(() => sessions.get(vm.plan.activeSessionId!)))!;

  Future<void> choose(WidgetTester tester, TrackingType? t) async {
    await tester.runAsync(() async {
      await vm.plan.setTrackingOverride(t);
      await vm.plan.idle;
    });
    await tester.pump();
  }

  testWidgets('the override changes the effective tracking and the guidance, '
      'is autosaved with the plan, and never writes the rig', (tester) async {
    await start(tester);
    expect(vm.plan.trackingOverride, isNull);
    expect(vm.plan.effectiveTracking, TrackingType.guided);
    expect(vm.analysis.rigCapability!.npf, isNull);
    expect(find.byKey(const Key('capture.subWarning')), findsNothing);

    await choose(tester, TrackingType.untracked);
    expect(vm.plan.effectiveTracking, TrackingType.untracked);
    expect(vm.analysis.rigCapability!.npf, isNotNull);
    expect(find.byKey(const Key('capture.subWarning')), findsOneWidget);
    expect((await stored(tester)).trackingOverride, TrackingType.untracked);
    final rig = await tester.runAsync(() => rigs.getEquipmentById(guidedId));
    expect(rig!.trackingType, TrackingType.guided, reason: 'the rig is kept');

    await choose(tester, null);
    expect(vm.plan.effectiveTracking, TrackingType.guided);
    expect((await stored(tester)).trackingOverride, isNull);
  });

  testWidgets('unknown is never stored as an override', (tester) async {
    await start(tester);
    await choose(tester, TrackingType.unknown);
    expect(vm.plan.trackingOverride, isNull);
    expect((await stored(tester)).trackingOverride, isNull);
  });

  testWidgets('Save records the effective value and its source; Discard on '
      'Saved · changed restores the saved override', (tester) async {
    await start(tester);
    await choose(tester, TrackingType.untracked);
    final saved = (await tester.runAsync(() => vm.analysis.saveSession()))!;
    expect(saved.planSnapshot!.json['tracking'], {
      'effective': 'untracked',
      'source': 'plan',
    });
    expect((saved.planSnapshot!.json['rig']! as Map)['tracking'], 'guided');

    await choose(tester, TrackingType.tracked);
    final changed = await stored(tester);
    expect(changed.status, SessionStatus.draft, reason: 'Saved · changed');
    expect(changed.trackingOverride, TrackingType.tracked);

    final reverted = (await tester.runAsync(
      () => sessions.revertToSaved(saved.id),
    ))!;
    expect(reverted.status, SessionStatus.planned);
    expect(reverted.trackingOverride, TrackingType.untracked);
    expect(
      reverted.planSnapshot!.json,
      saved.planSnapshot!.json,
      reason: 'the snapshot is never touched',
    );
  });

  testWidgets('a later rig edit never changes a saved snapshot\'s tracking', (
    tester,
  ) async {
    await start(tester);
    final saved = (await tester.runAsync(() => vm.analysis.saveSession()))!;
    await tester.runAsync(() async {
      final rig = (await rigs.getEquipmentById(guidedId))!;
      final edited = EquipmentProfile(
        id: rig.id,
        name: rig.name,
        sensorWidthMm: rig.sensorWidthMm,
        sensorHeightMm: rig.sensorHeightMm,
        pixelPitchUm: rig.pixelPitchUm,
        resolutionWidthPx: rig.resolutionWidthPx,
        resolutionHeightPx: rig.resolutionHeightPx,
        focalLengthMm: rig.focalLengthMm,
        focalRatio: rig.focalRatio,
        trackingType: TrackingType.untracked,
      );
      await rigs.updateEquipment(edited.withEditProvenance(rig));
    });
    final after = await tester.runAsync(() => sessions.get(saved.id));
    expect(after!.planSnapshot!.json['tracking'], {
      'effective': 'guided',
      'source': 'rig',
    });
  });

  testWidgets('Copy carries the override; New plan starts without one; Open '
      'reads each plan\'s own', (tester) async {
    await start(tester);
    await choose(tester, TrackingType.untracked);
    final original = vm.plan.activeSessionId!;

    await tester.runAsync(
      () => vm.lifecycle.duplicateForNight(CalendarDate(2026, 11, 20)),
    );
    expect(vm.plan.activeSessionId, isNot(original));
    expect(vm.plan.trackingOverride, TrackingType.untracked);
    expect((await stored(tester)).trackingOverride, TrackingType.untracked);

    await tester.runAsync(() => vm.lifecycle.newSession());
    expect(vm.plan.trackingOverride, isNull);
    expect(vm.plan.effectiveTracking, TrackingType.guided);
    expect((await stored(tester)).trackingOverride, isNull);

    final first = (await tester.runAsync(() => sessions.get(original)))!;
    await tester.runAsync(() => vm.lifecycle.openSession(first));
    expect(vm.plan.activeSessionId, original);
    expect(vm.plan.trackingOverride, TrackingType.untracked);
  });

  testWidgets('a rig change keeps the plan\'s override; without one the new '
      'rig\'s default applies', (tester) async {
    await start(tester);
    await choose(tester, TrackingType.tracked);
    await tester.runAsync(() async {
      await vm.plan.setEquipment((await rigs.getEquipmentById(untrackedId))!);
      await vm.plan.idle;
    });
    expect(vm.plan.effectiveTracking, TrackingType.tracked);
    expect(vm.analysis.rigCapability!.npf, isNull);

    await choose(tester, null);
    expect(vm.plan.effectiveTracking, TrackingType.untracked);
    expect(vm.analysis.rigCapability!.npf, isNotNull);
  });

  testWidgets('the planner\'s row shows the source and changes the plan '
      'through its dialog, at 200 % text', (tester) async {
    await start(tester);
    tester.platformDispatcher.textScaleFactorTestValue = 2;
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    await tester.pump();

    final row = find.byKey(const Key('planner.tracking'));
    expect(
      find.descendant(
        of: row,
        matching: find.text("Rig's default (${TrackingType.guided.label})"),
      ),
      findsOneWidget,
    );
    await tester.tap(row);
    await tester.pumpAndSettle();
    expect(find.text(PlanTrackingText.title), findsWidgets);
    await tester.tap(find.byKey(const Key('planTracking.untracked')));
    await settle(tester);
    expect(vm.plan.trackingOverride, TrackingType.untracked);
    expect(
      find.descendant(
        of: row,
        matching: find.text('${TrackingType.untracked.label} · this plan only'),
      ),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull, reason: 'no overflow');
  });

  testWidgets('unknown tracking\'s way to set it opens the plan\'s choice, '
      'and the example rig stays unknown', (tester) async {
    await start(tester);
    late int exampleId;
    await tester.runAsync(() async {
      exampleId = await rigs.insertEquipment(
        _rig('Example', TrackingType.unknown),
      );
      await vm.plan.setEquipment((await rigs.getEquipmentById(exampleId))!);
      await vm.plan.idle;
    });
    await tester.pump();
    expect(vm.plan.effectiveTracking, TrackingType.unknown);
    await tester.tap(find.byKey(const Key('capture.setTracking')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('planTracking.tracked')));
    await settle(tester);
    expect(vm.plan.effectiveTracking, TrackingType.tracked);
    final rig = await tester.runAsync(() => rigs.getEquipmentById(exampleId));
    expect(rig!.trackingType, TrackingType.unknown, reason: 'never a fact');
  });
}

/// Lets a write started by a tap (in the test's fake zone) reach the real
/// database: real event-loop turns between frames (as capture_blocks_test).
Future<void> settle(WidgetTester tester, {int frames = 8}) async {
  for (var i = 0; i < frames; i++) {
    await tester.runAsync(() => Future<void>.delayed(Duration.zero));
    await tester.pump(const Duration(milliseconds: 200));
  }
}
