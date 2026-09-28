// TASK 14.1: the Sessions list filters, and the session detail from its
// snapshot — a completed run (execution-start snapshot, plan vs actual,
// notes), a planned session (plan snapshot), a legacy log (stored text,
// badge) and a session without a snapshot. Acceptance: legacy and new
// sessions both render.

import 'package:astroplan/core/time/clock.dart';
import 'package:astroplan/data/database/app_database.dart' show AppDatabase;
import 'package:astroplan/data/repositories/drift_equipment_repository.dart';
import 'package:astroplan/data/repositories/drift_location_repository.dart';
import 'package:astroplan/data/repositories/drift_session_repository.dart';
import 'package:astroplan/data/repositories/drift_target_repository.dart';
import 'package:astroplan/domain/models/astro_target.dart';
import 'package:astroplan/domain/models/capture_block.dart';
import 'package:astroplan/domain/models/equipment_profile.dart';
import 'package:astroplan/domain/models/execution.dart';
import 'package:astroplan/domain/models/session.dart';
import 'package:astroplan/domain/repositories/weather_repository.dart';
import 'package:astroplan/domain/services/session_exporter.dart';
import 'package:astroplan/main.dart';
import 'package:astroplan/presentation/navigation/app_router.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../support/fake_location_service.dart';
import '../../../support/fake_reverse_geocoder.dart';
import '../../../support/no_snapshot_weather.dart';
import '../../../support/planner_harness.dart';

class _NoForecast with NoSnapshotWeather implements WeatherRepository {}

/// Records what would be shared (TASK 14.3).
class _RecordingExporter implements SessionExporter {
  final List<List<ExportedSession>> shared = [];

  @override
  Future<void> share(List<ExportedSession> sessions) async =>
      shared.add(sessions);
}

const _m42 = AstroTarget(
  id: 1,
  catalogId: 'M42',
  commonName: 'Orion Nebula',
  type: 'Nebula',
  rightAscension: 83.82,
  declination: -5.39,
);

const _rig = EquipmentProfile(
  id: 1,
  name: 'Refractor 400',
  focalRatio: 5.0,
  focalLengthMm: 400.0,
  sensorWidthMm: 23.5,
  sensorHeightMm: 15.6,
  resolutionWidthPx: 6000,
  resolutionHeightPx: 4000,
  pixelPitchUm: 3.76,
  averageRawFileSizeMB: 50.0,
);

void main() {
  late AppDatabase database;
  late DriftSessionRepository sessions;
  late PlannerHarness vm;
  late int completedId;
  late int plannedId;
  late _RecordingExporter exporter;
  const legacyId = 900;
  const noSnapshotId = 901;

  /// A completed run (10 of 24 × 300 s, with notes), a planned session, a
  /// legacy log and a planned session saved without a snapshot.
  Future<void> seed(WidgetTester tester) async {
    tester.view.physicalSize = const Size(800, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    await tester.runAsync(() async {
      SharedPreferences.setMockInitialValues({});
      exporter = _RecordingExporter();
      final clock = FixedClock(DateTime.utc(2026, 12, 15, 19));
      database = AppDatabase(NativeDatabase.memory());
      sessions = DriftSessionRepository(database, clock: clock);
      await DriftTargetRepository(database).insertTarget(_m42);
      await DriftEquipmentRepository(database).insertEquipment(_rig);
      vm = PlannerHarness(
        DriftTargetRepository(database),
        DriftEquipmentRepository(database),
        _NoForecast(),
        DriftLocationRepository(database),
        locationService: FakeLocationService(),
        reverseGeocoder: FakeReverseGeocoder(),
        sessionRepository: sessions,
        clock: clock,
        exporter: exporter,
      );
      await vm.ready;
      await vm.choosePlan(); // S6.8: nothing is preselected
      await vm.site.setLocation(46.05, 14.5);
      while (vm.plan.captureBlocks.isNotEmpty) {
        await vm.plan.removeCaptureBlock(0);
      }
      await vm.plan.addCaptureBlock(
        CaptureBlock(
          frameType: FrameType.light,
          filterName: 'L',
          exposureTimeSeconds: 300,
          frameCount: 24,
        ),
      );
      await vm.plan.idle;
      final run = await vm.analysis.startSession();
      completedId = run.id;
      await sessions.record(
        run.id,
        ExecutionEventKind.framesConfirmed,
        blockId: run.blocks.single.id,
        delta: 10,
      );
      await sessions.complete(run.id);
      await sessions.updateResults(
        run.id,
        const SessionResults(
          actualLightFrames: 10,
          environmentalNotes: 'Wind after 23:00',
          temperatureC: -3,
        ),
      );
      plannedId = (await vm.analysis.saveSession()).id;
      await database.customStatement(
        "INSERT INTO session_logs (id, target_name, equipment_name, "
        "session_date, planned_light_frames, actual_light_frames, status, "
        "legacy) VALUES ($legacyId, 'M31', 'Old rig', 1767225600, 40, 35, "
        "'completed', 1), ($noSnapshotId, 'M45', 'Rig', 1767225600, 5, NULL, "
        "'planned', 0);",
      );
      await database.customStatement(
        "UPDATE session_logs SET evening_date = '2026-12-10' "
        'WHERE id = $noSnapshotId;',
      );
    });
    addTearDown(() => tester.runAsync(database.close));
  }

  Future<void> pumpAt(WidgetTester tester, String location) async {
    AppRouter.router.go(location);
    await tester.pumpWidget(
      MultiProvider(providers: vm.providers, child: const AstroPlanApp()),
    );
    await settle(tester);
  }

  testWidgets('the Completed chip filters the list in the query', (
    tester,
  ) async {
    await seed(tester);
    await pumpAt(tester, AppRouter.sessions);
    expect(find.byKey(Key('logbook.status.$plannedId')), findsOneWidget);
    await tester.tap(find.byKey(const Key('logbook.filter.completed')));
    await settle(tester);
    expect(find.byKey(Key('logbook.status.$completedId')), findsOneWidget);
    expect(find.byKey(const Key('logbook.status.$legacyId')), findsOneWidget);
    expect(find.byKey(Key('logbook.status.$plannedId')), findsNothing);
    await tester.tap(find.byKey(const Key('logbook.filter.clear')));
    await settle(tester);
    expect(find.byKey(Key('logbook.status.$plannedId')), findsOneWidget);
  });

  testWidgets('the target filter keeps only that target (legacy excluded)', (
    tester,
  ) async {
    await seed(tester);
    await pumpAt(tester, AppRouter.sessions);
    await tester.tap(find.byKey(const Key('logbook.filter.target')));
    await settle(tester);
    await tester.tap(find.byKey(const Key('logbook.pick.1')));
    await settle(tester);
    expect(find.byKey(Key('logbook.status.$completedId')), findsOneWidget);
    expect(find.byKey(const Key('logbook.status.$legacyId')), findsNothing);
    expect(find.textContaining('Target: Orion Nebula'), findsOneWidget);
  });

  testWidgets('the legacy row carries a badge; a tap opens the detail', (
    tester,
  ) async {
    await seed(tester);
    await pumpAt(tester, AppRouter.sessions);
    expect(find.byKey(const Key('logbook.legacy.$legacyId')), findsOneWidget);
    await tester.tap(find.textContaining('M31'));
    await settle(tester);
    expect(find.byKey(const Key('detail.legacy')), findsOneWidget);
  });

  testWidgets('acceptance: a completed run renders from its execution-start '
      'snapshot with plan vs actual and notes', (tester) async {
    await seed(tester);
    await pumpAt(tester, AppRouter.sessionDetail(completedId));
    expect(find.textContaining('At the start of imaging'), findsOneWidget);
    expect(find.byKey(const Key('detail.night')), findsOneWidget);
    expect(find.textContaining('Times in: '), findsOneWidget);
    expect(find.text('Completed'), findsOneWidget);
    expect(find.textContaining('Refractor 400'), findsWidgets);
    expect(find.textContaining('Orion Nebula'), findsWidgets);
    expect(
      find.textContaining('L · 300 s: 10 of 24', findRichText: true),
      findsOneWidget,
    );
    expect(
      find.textContaining(
        'Integration: 50 min of 2 h planned',
        findRichText: true,
      ),
      findsOneWidget,
    );
    expect(
      find.textContaining('Wind after 23:00', findRichText: true),
      findsOneWidget,
    );
    expect(
      find.textContaining('Temperature: −3.0 °C', findRichText: true),
      findsOneWidget,
    );
    expect(find.byKey(const Key('detail.editResults')), findsOneWidget);
    expect(find.text('Plan again (copy)'), findsOneWidget);
    // S1.7 (UX-19): RA/Dec as in the target editor; typographic minus.
    expect(
      find.textContaining('05h35m16.8s, −05°23′24″', findRichText: true),
      findsOneWidget,
    );
    expect(
      find.textContaining('Darkness limit: −18°', findRichText: true),
      findsOneWidget,
    );
  });

  testWidgets('a planned session renders from its plan snapshot', (
    tester,
  ) async {
    await seed(tester);
    await pumpAt(tester, AppRouter.sessionDetail(plannedId));
    expect(find.textContaining('Plan as saved'), findsOneWidget);
    expect(
      find.textContaining('L · 300 s: 24 planned', findRichText: true),
      findsOneWidget,
    );
    expect(find.text('Open in planner'), findsOneWidget);
    expect(find.byKey(const Key('detail.editResults')), findsNothing);
    // S1.8 (UX-20, UX-18): no raw double, no "Notes: none", and the night
    // key is not called a window.
    expect(
      find.textContaining('Focal ratio: f/5.0', findRichText: true),
      findsOneWidget,
    );
    expect(find.text('None recorded.'), findsOneWidget);
    expect(find.textContaining('Notes: ', findRichText: true), findsNothing);
    expect(
      find.textContaining('Night span: ', findRichText: true),
      findsOneWidget,
    );
    expect(find.textContaining('Window: ', findRichText: true), findsNothing);
  });

  testWidgets('acceptance: a legacy log renders its stored text only', (
    tester,
  ) async {
    await seed(tester);
    await pumpAt(tester, AppRouter.sessionDetail(legacyId));
    expect(find.byKey(const Key('detail.legacy')), findsOneWidget);
    expect(find.byKey(const Key('detail.night')), findsNothing);
    expect(
      find.textContaining('Actual light frames: 35', findRichText: true),
      findsOneWidget,
    );
    expect(
      find.textContaining('Rejected frames: unknown', findRichText: true),
      findsOneWidget,
    );
    expect(find.textContaining('unknown'), findsWidgets);
  });

  testWidgets('a session without a snapshot says so, never zeros', (
    tester,
  ) async {
    await seed(tester);
    await pumpAt(tester, AppRouter.sessionDetail(noSnapshotId));
    expect(find.byKey(const Key('detail.noSnapshot')), findsOneWidget);
  });

  testWidgets('TASK 14.2: the detail shows the target so far; Library → '
      'Progress lists it', (tester) async {
    await seed(tester);
    await pumpAt(tester, AppRouter.sessionDetail(completedId));
    expect(find.text('This target so far'), findsOneWidget);
    expect(find.text('50 min over 1 session'), findsOneWidget);
    expect(find.text('L: 50 min'), findsOneWidget);
    AppRouter.router.go(AppRouter.libraryProgress);
    await settle(tester);
    expect(find.byKey(const Key('progress.1')), findsOneWidget);
    expect(find.text('Orion Nebula'), findsWidgets);
  });

  testWidgets('TASK 14.2: Progress says so when nothing is completed', (
    tester,
  ) async {
    await seed(tester);
    await tester.runAsync(() => sessions.delete(completedId));
    await pumpAt(tester, AppRouter.libraryProgress);
    expect(find.byKey(const Key('progress.empty')), findsOneWidget);
  });

  testWidgets('TASK 14.3: Export file shares that session with its events', (
    tester,
  ) async {
    await seed(tester);
    await pumpAt(tester, AppRouter.sessionDetail(completedId));
    await tester.tap(find.byKey(const Key('detail.export')));
    await settle(tester);
    final shared = exporter.shared.single.single;
    expect(shared.session.id, completedId);
    expect(shared.events.first.kind, ExecutionEventKind.started);
    expect(shared.events.last.kind, ExecutionEventKind.finished);
  });

  testWidgets('TASK 14.3: Export all shares every saved session', (
    tester,
  ) async {
    await seed(tester);
    await pumpAt(tester, AppRouter.sessions);
    await tester.tap(find.byKey(const Key('logbook.exportAll')));
    await settle(tester);
    final ids = {for (final e in exporter.shared.single) e.session.id};
    expect(ids, {completedId, plannedId, legacyId, noSnapshotId});
  });

  testWidgets('no overflow at 200 % text on a 360 × 640 dp phone', (
    tester,
  ) async {
    await seed(tester);
    tester.view.physicalSize = const Size(360, 640);
    tester.platformDispatcher.textScaleFactorTestValue = 2.0;
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    await pumpAt(tester, AppRouter.sessionDetail(completedId));
    await tester.drag(find.byType(ListView).first, const Offset(0, -4000));
    await settle(tester);
    expect(tester.takeException(), isNull);
    AppRouter.router.go(AppRouter.sessions);
    await settle(tester);
    expect(tester.takeException(), isNull);
  });
}

/// Pumps fixed frames with real-time gaps (database reads; TASK 12.2).
Future<void> settle(WidgetTester tester) async {
  for (var i = 0; i < 6; i++) {
    await tester.runAsync(() => Future<void>.delayed(Duration.zero));
    await tester.pump(const Duration(milliseconds: 200));
  }
}
