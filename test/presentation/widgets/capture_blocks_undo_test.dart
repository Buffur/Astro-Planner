// TD-079 (S6.16; the owner's decision, DECISIONS E.1 "Stage 6 corrective
// pass decided", item 4): a way back from the three one-tap changes that had
// none — Fill or Trim, a block edit saved in its dialog, and "Start from the
// example plan". Each says what it did with Undo (S5.8's pattern); Undo puts
// back the identical blocks and the example badge, autosaved; after another
// edit it changes nothing and says so; a saved plan's snapshot is never
// touched. Through the real ViewModels and an in-memory SQLite database.

import 'dart:convert';

import 'package:astroplan/core/time/clock.dart';
import 'package:astroplan/data/database/app_database.dart' hide CaptureBlock;
import 'package:astroplan/data/repositories/drift_equipment_repository.dart';
import 'package:astroplan/data/repositories/drift_location_repository.dart';
import 'package:astroplan/data/repositories/drift_session_repository.dart';
import 'package:astroplan/data/repositories/drift_target_repository.dart';
import 'package:astroplan/data/services/catalog_seeder.dart';
import 'package:astroplan/data/services/equipment_seeder.dart';
import 'package:astroplan/domain/models/capture_block.dart';
import 'package:astroplan/domain/models/location_profile.dart' as domain;
import 'package:astroplan/domain/repositories/weather_repository.dart';
import 'package:astroplan/presentation/shared/example_text.dart';
import 'package:astroplan/presentation/widgets/capture_plan/blocks_undo.dart';
import 'package:astroplan/presentation/widgets/capture_plan_widget.dart';
import 'package:astroplan/presentation/widgets/plan_status.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../support/fake_location_service.dart';
import '../../support/no_snapshot_weather.dart';
import '../../support/planner_harness.dart';

class _NoWeather with NoSnapshotWeather implements WeatherRepository {}

CaptureBlock _ha(int frames) => CaptureBlock(
  frameType: FrameType.light,
  filterName: 'Ha',
  exposureTimeSeconds: 300,
  frameCount: frames,
);

void main() {
  late AppDatabase database;
  late DriftSessionRepository sessions;
  late PlannerHarness vm;

  /// London, M42, the example rig, 2026-03-01 at 18:00 UTC; [blocks]
  /// replace the example plan (none: an empty plan).
  Future<void> build(
    WidgetTester tester, {
    List<CaptureBlock> blocks = const [],
    bool reducedMotion = false,
  }) async {
    tester.view.physicalSize = const Size(800, 3000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    await tester.runAsync(() async {
      database = AppDatabase(NativeDatabase.memory());
      final clock = FixedClock(DateTime.utc(2026, 3, 1, 18));
      sessions = DriftSessionRepository(database, clock: clock);
      final targets = DriftTargetRepository(database);
      await CatalogSeeder(targets).seedIfNeeded();
      await EquipmentSeeder(DriftEquipmentRepository(database)).seedIfNeeded();
      final locations = DriftLocationRepository(database);
      final id = await locations.insertLocation(
        domain.LocationProfile(
          id: 0,
          name: 'London',
          latitude: 51.5,
          longitude: -0.1,
          elevation: 10,
        ),
      );
      SharedPreferences.setMockInitialValues({'activeLocationId': id});
      vm = PlannerHarness(
        targets,
        DriftEquipmentRepository(database),
        _NoWeather(),
        locations,
        locationService: FakeLocationService(),
        clock: clock,
        sessionRepository: sessions,
      );
      await vm.ready;
      await vm.choosePlan();
      while (vm.captureBlocks.isNotEmpty) {
        await vm.removeCaptureBlock(0);
      }
      for (final b in blocks) {
        await vm.addCaptureBlock(b);
      }
      await vm.plan.idle;
    });
    addTearDown(() => tester.runAsync(database.close));
    await tester.pumpWidget(
      MultiProvider(
        providers: vm.providers,
        child: MaterialApp(
          home: MediaQuery(
            data: MediaQueryData(disableAnimations: reducedMotion),
            child: const Scaffold(
              body: SingleChildScrollView(
                child: Column(children: [PlanStatus(), CapturePlanWidget()]),
              ),
            ),
          ),
        ),
      ),
    );
    await settle(tester);
  }

  /// What the database holds for the current plan.
  Future<List<int>> storedFrames(WidgetTester tester) async {
    await tester.runAsync(() => vm.plan.idle);
    final s = await tester.runAsync(
      () => sessions.get(vm.plan.activeSessionId!),
    );
    return [for (final b in s!.blocks) b.frameCount];
  }

  Future<void> tapUndo(WidgetTester tester) async {
    await tester.tap(find.text('Undo'));
    await settle(tester);
    await tester.runAsync(() => vm.plan.idle);
    await settle(tester);
  }

  testWidgets('Trim says what it did, and Undo puts the identical block back', (
    tester,
  ) async {
    await build(tester, blocks: [_ha(500)]);
    final original = vm.captureBlocks.single;
    final target = vm.fillWindowFrameCount!;
    expect(target, inInclusiveRange(1, 499));

    await tester.tap(find.byKey(const Key('capturePlan.fillWindow')));
    await settle(tester);
    expect(vm.captureBlocks.single.frameCount, target);
    expect(find.text('Trimmed Ha 300 s to $target frames'), findsOneWidget);
    expect(await storedFrames(tester), [target]);

    await tapUndo(tester);
    expect(identical(vm.captureBlocks.single, original), isTrue);
    expect(await storedFrames(tester), [500]);
    // The action is offered again, as before the trim.
    expect(find.byKey(const Key('capturePlan.fillWindow')), findsOneWidget);
  });

  testWidgets('Fill says what it did, and Undo restores the count', (
    tester,
  ) async {
    await build(tester, blocks: [_ha(2)]);
    final target = vm.fillWindowFrameCount!;
    expect(target, greaterThan(2));

    await tester.tap(find.byKey(const Key('capturePlan.fillWindow')));
    await settle(tester);
    expect(vm.captureBlocks.single.frameCount, target);
    expect(find.text('Filled Ha 300 s to $target frames'), findsOneWidget);

    await tapUndo(tester);
    expect(vm.captureBlocks.single.frameCount, 2);
    expect(await storedFrames(tester), [2]);
  });

  testWidgets('a block edit saved in its dialog has Undo back to the block as '
      'it was', (tester) async {
    await build(tester, blocks: [_ha(10), _ha(20)]);
    final before = vm.captureBlocks.toList();

    await tester.tap(find.text('Ha · 300 s × 20 · 1 h 40 min'));
    await settle(tester);
    expect(find.text('Edit Capture Block'), findsOneWidget);
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Frame Count'),
      '7',
    );
    await tester.tap(find.byKey(const Key('blockDialog.submit')));
    await settle(tester);
    expect(vm.captureBlocks[1].frameCount, 7);
    expect(
      find.textContaining('Block changed: Ha · 300 s × 7'),
      findsOneWidget,
    );
    expect(await storedFrames(tester), [10, 7]);

    await tapUndo(tester);
    expect(identical(vm.captureBlocks[0], before[0]), isTrue);
    expect(identical(vm.captureBlocks[1], before[1]), isTrue);
    expect(await storedFrames(tester), [10, 20]);
  });

  testWidgets('"Start from the example plan" has Undo back to the empty plan '
      'without the badge', (tester) async {
    await build(tester);
    expect(vm.captureBlocks, isEmpty);

    await tester.tap(find.byKey(const Key('capturePlan.useExample')));
    await settle(tester);
    expect(vm.captureBlocks, hasLength(3));
    expect(vm.plan.isExampleCapturePlan, isTrue);
    expect(find.text(ExampleText.plan), findsOneWidget);
    expect(find.text('Started from the example plan'), findsOneWidget);

    await tapUndo(tester);
    expect(vm.captureBlocks, isEmpty);
    expect(vm.plan.isExampleCapturePlan, isFalse);
    expect(find.byKey(const Key('capturePlan.useExample')), findsOneWidget);
    expect(await storedFrames(tester), isEmpty);
  });

  testWidgets('Undo after another edit to the blocks changes nothing and says '
      'so', (tester) async {
    await build(tester, blocks: [_ha(500)]);
    await tester.tap(find.byKey(const Key('capturePlan.fillWindow')));
    await settle(tester);
    final trimmed = vm.captureBlocks.single.frameCount;

    // Another edit while the message is still up (no message of its own).
    await tester.runAsync(() => vm.addCaptureBlock(_ha(3)));
    await settle(tester);
    await tapUndo(tester);

    expect([for (final b in vm.captureBlocks) b.frameCount], [trimmed, 3]);
    expect(find.text(notUndone), findsOneWidget);
    expect(await storedFrames(tester), [trimmed, 3]);
  });

  testWidgets("on a saved plan an Undo is an edit: the saved snapshot is "
      'unchanged', (tester) async {
    await build(tester, blocks: [_ha(500)]);
    await tester.runAsync(() => vm.saveSession());
    await settle(tester);
    final id = vm.plan.activeSessionId!;
    final saved = (await tester.runAsync(() => sessions.get(id)))!;
    final snapshot = jsonEncode(saved.planSnapshot!.json);

    await tester.tap(find.byKey(const Key('capturePlan.fillWindow')));
    await settle(tester);
    await tapUndo(tester);

    expect(vm.captureBlocks.single.frameCount, 500);
    final after = (await tester.runAsync(() => sessions.get(id)))!;
    expect(jsonEncode(after.planSnapshot!.json), snapshot);
    expect(after.plannedAtUtc, saved.plannedAtUtc);
    expect([for (final b in after.blocks) b.frameCount], [500]);
  });

  // The recovery adds no motion of its own: the marks on what changed follow
  // AppMotion, so with reduced motion there is none (the message is the
  // app's standard one; TD-081 records the framework's message animation).
  for (final reduced in [false, true]) {
    testWidgets('the change is marked, without motion when reduced '
        '(reduced: $reduced)', (tester) async {
      await build(tester, blocks: [_ha(500)], reducedMotion: reduced);
      await tester.tap(find.byKey(const Key('capturePlan.fillWindow')));
      await tester.pump(); // the edit applies at once; no time passes
      final tints = [
        for (final mark in tester.widgetList<DecoratedBox>(
          find.byKey(const Key('changeMark')),
        ))
          (mark.decoration as BoxDecoration).color!.a,
      ];
      expect(tints, isNotEmpty);
      if (reduced) {
        expect(tints, everyElement(0));
      } else {
        expect(tints.any((a) => a > 0), isTrue, reason: 'the control');
      }
      await settle(tester);
      expect(find.text('Undo'), findsOneWidget);
    });
  }
}

/// Pumps fixed frames with real-time gaps (database work; TASK 12.2).
Future<void> settle(WidgetTester tester) async {
  for (var i = 0; i < 8; i++) {
    await tester.runAsync(() => Future<void>.delayed(Duration.zero));
    await tester.pump(const Duration(milliseconds: 200));
  }
}
