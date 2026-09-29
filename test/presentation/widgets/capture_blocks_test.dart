// S6.9 (P6.8; UX-09, UX-15 (1); 08 §14; RD-09 = M + S1; RD-08 = T3): each
// capture block's row says what will be captured; delete comes with Undo
// that restores the identical block; unknown tracking is a missing input,
// not a warning; the dialog's Save is its primary button; an edit briefly
// marks the row it changed.

import 'package:astroplan/core/theme/app_palette.dart';
import 'package:astroplan/core/time/clock.dart';
import 'package:astroplan/data/database/app_database.dart' show AppDatabase;
import 'package:astroplan/data/repositories/drift_equipment_repository.dart';
import 'package:astroplan/data/repositories/drift_location_repository.dart';
import 'package:astroplan/data/repositories/drift_session_repository.dart';
import 'package:astroplan/data/repositories/drift_target_repository.dart';
import 'package:astroplan/domain/models/astro_target.dart';
import 'package:astroplan/domain/models/capture_block.dart';
import 'package:astroplan/domain/models/equipment_profile.dart';
import 'package:astroplan/domain/models/location_profile.dart' as domain;
import 'package:astroplan/domain/models/tracking_type.dart';
import 'package:astroplan/domain/repositories/weather_repository.dart';
import 'package:astroplan/presentation/widgets/capture_plan_widget.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../support/fake_device_time_zone.dart';
import '../../support/fake_location_service.dart';
import '../../support/fake_reverse_geocoder.dart';
import '../../support/no_snapshot_weather.dart';
import '../../support/planner_harness.dart';

class _NoForecast with NoSnapshotWeather implements WeatherRepository {}

const _m42 = AstroTarget(
  id: 1,
  catalogId: 'M42',
  rightAscension: 83.82,
  declination: -5.39,
  type: 'Nebula',
);

EquipmentProfile _rig(TrackingType tracking, {double? maxExposureS}) =>
    EquipmentProfile(
      id: 1,
      name: 'Phone',
      sensorWidthMm: 9.8,
      sensorHeightMm: 7.3,
      pixelPitchUm: 1.22,
      resolutionWidthPx: 8064,
      resolutionHeightPx: 6048,
      focalLengthMm: 6.86,
      focalRatio: 1.78,
      trackingType: tracking,
      maxExposureS: maxExposureS,
    );

CaptureBlock _light(double s, int n, {String? filter}) => CaptureBlock(
  frameType: FrameType.light,
  filterName: filter,
  exposureTimeSeconds: s,
  frameCount: n,
);

void main() {
  late AppDatabase db;
  late PlannerHarness vm;
  late DriftSessionRepository sessions;

  /// The capture plan alone, on a real database, with a site.
  Future<void> start(
    WidgetTester tester, {
    Size size = const Size(412, 3000),
    double textScale = 1,
    bool reducedMotion = false,
  }) async {
    tester.view.physicalSize = size;
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
      vm = PlannerHarness(
        DriftTargetRepository(db),
        DriftEquipmentRepository(db),
        _NoForecast(),
        DriftLocationRepository(db),
        locationService: FakeLocationService(),
        reverseGeocoder: FakeReverseGeocoder(),
        deviceTimeZone: FakeDeviceTimeZone(),
        clock: clock,
        sessionRepository: sessions,
      );
      await vm.ready;
    });
    addTearDown(() => tester.runAsync(db.close));
    await tester.pumpWidget(
      MultiProvider(
        providers: vm.providers,
        child: MaterialApp(
          home: MediaQuery(
            data: MediaQueryData(
              size: size,
              textScaler: TextScaler.linear(textScale),
              disableAnimations: reducedMotion,
            ),
            child: const Scaffold(
              body: SingleChildScrollView(child: CapturePlanWidget()),
            ),
          ),
        ),
      ),
    );
    await tester.pump();
  }

  Future<void> blocks(WidgetTester tester, List<CaptureBlock> b) async {
    await tester.runAsync(() async {
      for (final block in b) {
        await vm.plan.addCaptureBlock(block);
      }
      await vm.plan.idle;
    });
    await tester.pump(); // builds the new rows
    await tester.pump(const Duration(seconds: 2)); // past any change mark
  }

  List<String> stored(List<CaptureBlock> b) => [
    for (final x in b)
      '${x.frameType.name}/${x.filterName}/${x.exposureTimeSeconds}/'
          '${x.frameCount}/${x.binning}/${x.gain}/${x.calibrationPolicy}',
  ];

  testWidgets('each frame type and edge case reads as what will be '
      'captured, at 200 % text on a phone', (tester) async {
    await start(tester, textScale: 2);
    await blocks(tester, [
      _light(60, 100, filter: 'Ha'),
      _light(30, 10),
      _light(30, 10, filter: ''),
      _light(120, 12, filter: 'Hydrogen-alpha 3 nm narrowband 2'),
      CaptureBlock(
        frameType: FrameType.dark,
        exposureTimeSeconds: 60,
        frameCount: 20,
        calibrationPolicy: CalibrationPolicy.inWindow,
        gain: CaptureGain.iso(800),
        binning: 2,
      ),
      CaptureBlock(
        frameType: FrameType.flat,
        filterName: 'Ha',
        exposureTimeSeconds: 2,
        frameCount: 20,
        calibrationPolicy: CalibrationPolicy.outsideWindow,
      ),
      CaptureBlock(
        frameType: FrameType.bias,
        exposureTimeSeconds: 0.001,
        frameCount: 50,
        calibrationPolicy: CalibrationPolicy.library,
      ),
    ]);
    for (final row in [
      'Ha · 60 s × 100 · 1 h 40 min',
      'Light · 30 s × 10 · 5 min',
      'Hydrogen-alpha 3 nm narrowband 2 · 120 s × 12 · 24 min',
      'Dark · 60 s × 20 · 20 min',
      'Flat (Ha) · 2 s × 20 · 40 s',
      'Bias · 1/1000 s × 50 · from your library',
    ]) {
      expect(find.text(row), findsWidgets, reason: row);
    }
    // The empty filter reads as no filter: two "Light" rows.
    expect(find.text('Light · 30 s × 10 · 5 min'), findsNWidgets(2));
    expect(find.text('During the imaging window'), findsOneWidget);
    expect(find.text('Outside the imaging window'), findsOneWidget);
    // Camera values live in the block's editor, not in the row. The dark
    // matches no light (S7.3a), which is named in words: fields, no values.
    expect(
      find.byKey(const Key('capture.mismatch.4.matchesNoLight')),
      findsOneWidget,
    );
    bool warning(Widget w) =>
        w.key is ValueKey<String> &&
        (w.key! as ValueKey<String>).value.startsWith('capture.mismatch.');
    final rowTexts = [
      for (final t in tester.widgetList<Text>(find.byType(Text)))
        if (!warning(t)) t.data ?? '',
    ];
    expect(rowTexts.where((t) => t.contains('ISO')), isEmpty);
    expect(rowTexts.where((t) => t.contains('bin')), isEmpty);
    expect(find.textContaining('800'), findsNothing);
    // One heading: the planner's; none of the old four.
    for (final old in ['Inputs', 'Outputs', 'Sequence Plan']) {
      expect(find.text(old), findsNothing, reason: old);
    }
    expect(tester.takeException(), isNull, reason: 'no overflow');
  });

  testWidgets('Delete, then Undo, restores the identical block at its index; '
      'the autosaved plan equals the one before', (tester) async {
    await start(tester);
    await blocks(tester, [
      _light(60, 10, filter: 'R'),
      CaptureBlock(
        frameType: FrameType.flat,
        filterName: 'G',
        exposureTimeSeconds: 2.5,
        frameCount: 15,
        binning: 2,
        gain: CaptureGain.gain(120),
        calibrationPolicy: CalibrationPolicy.inWindow,
      ),
      _light(60, 10, filter: 'B'),
    ]);
    final before = stored(vm.captureBlocks);
    final middle = vm.captureBlocks[1];

    await tester.tap(find.byTooltip('Delete block').at(1));
    await settle(tester);
    expect(vm.captureBlocks, hasLength(2));
    expect(find.textContaining('Deleted Flat (G)'), findsOneWidget);

    await tester.tap(find.text('Undo'));
    await settle(tester);
    expect(identical(vm.captureBlocks[1], middle), isTrue);
    expect(stored(vm.captureBlocks), before);
    final row = await tester.runAsync(
      () => sessions.get(vm.plan.activeSessionId!),
    );
    expect(stored(row!.blocks), before);
  });

  testWidgets('a timed-out Undo commits the delete', (tester) async {
    await start(tester);
    await blocks(tester, [_light(60, 10, filter: 'R'), _light(60, 5)]);
    await tester.tap(find.byTooltip('Delete block').first);
    await settle(tester);
    await settle(tester, frames: 40); // 8 s: the message times out
    expect(find.text('Undo'), findsNothing);
    expect(vm.captureBlocks.single.filterName, isNull);
    final row = await tester.runAsync(
      () => sessions.get(vm.plan.activeSessionId!),
    );
    expect(row!.blocks.single.frameCount, 5);
  });

  group('tracking (RD-08 = T3: the rig\'s default until Stage 7)', () {
    Future<void> plan(WidgetTester tester, EquipmentProfile rig) async {
      await start(tester);
      await tester.runAsync(() async {
        final rigs = DriftEquipmentRepository(db);
        final targets = DriftTargetRepository(db);
        final rigId = await rigs.insertEquipment(rig);
        final targetId = await targets.insertTarget(_m42);
        await vm.plan.setEquipment((await rigs.getEquipmentById(rigId))!);
        await vm.plan.setTarget((await targets.getTargetById(targetId))!);
      });
      await blocks(tester, [_light(300, 10, filter: 'L')]);
    }

    Color? colourOf(WidgetTester tester, Key key) =>
        tester.widget<Text>(find.byKey(key)).style?.color;

    testWidgets('unknown tracking is a missing input: neutral, with the way '
        'to set it, and PD-11\'s "if untracked"', (tester) async {
      await plan(tester, _rig(TrackingType.unknown));
      expect(vm.plan.effectiveTracking, TrackingType.unknown);
      expect(find.byKey(const Key('capture.subWarning')), findsNothing);
      final note = find.byKey(const Key('capture.trackingUnknown'));
      expect(note, findsOneWidget);
      expect(
        tester.widget<Text>(note).data,
        contains('if this rig is untracked'),
      );
      final palette = AppPalette.of(tester.element(note));
      final scheme = Theme.of(tester.element(note)).colorScheme;
      final colour = colourOf(tester, const Key('capture.trackingUnknown'));
      expect(colour, palette.statusNeutral);
      expect(colour, isNot(scheme.error));
      expect(colour, isNot(palette.statusDoesNotFit));
      expect(find.byKey(const Key('capture.setTracking')), findsOneWidget);
    });

    testWidgets('a known untracked rig\'s exceedance keeps the warning, with '
        'the tracking it rests on', (tester) async {
      await plan(tester, _rig(TrackingType.untracked));
      final warning = find.byKey(const Key('capture.subWarning'));
      expect(warning, findsOneWidget);
      expect(
        tester.widget<Text>(warning).data,
        allOf(
          contains('stars may trail'),
          contains('Tracking: ${TrackingType.untracked.label}'),
        ),
      );
      expect(
        colourOf(tester, const Key('capture.subWarning')),
        AppPalette.of(tester.element(warning)).statusDoesNotFit,
      );
      expect(find.byKey(const Key('capture.trackingUnknown')), findsNothing);
    });

    testWidgets('a guided rig past its own maximum is warned with its '
        'tracking', (tester) async {
      await plan(tester, _rig(TrackingType.guided, maxExposureS: 120));
      final warning = find.byKey(const Key('capture.subWarning'));
      expect(
        tester.widget<Text>(warning).data,
        contains('Tracking: ${TrackingType.guided.label}'),
      );
    });
  });

  testWidgets("the block dialog's Save is its primary (filled) button", (
    tester,
  ) async {
    await start(tester);
    await blocks(tester, [_light(60, 10, filter: 'L')]);
    await tester.tap(find.text('L · 60 s × 10 · 10 min'));
    await tester.pumpAndSettle();
    final submit = find.byKey(const Key('blockDialog.submit'));
    expect(tester.widget(submit), isA<FilledButton>());
    expect(find.descendant(of: submit, matching: find.text('Save')), findsOne);
  });

  group('an edit briefly marks the row it changed', () {
    double markOf(WidgetTester tester, String row) =>
        tester
            .widget<ListTile>(
              find.ancestor(
                of: find.text(row),
                matching: find.byType(ListTile),
              ),
            )
            .tileColor
            ?.a ??
        0;

    testWidgets('a new block is marked, then the mark fades; the others '
        'are not marked', (tester) async {
      await start(tester);
      await blocks(tester, [_light(60, 10, filter: 'L')]);
      expect(markOf(tester, 'L · 60 s × 10 · 10 min'), 0);

      await tester.runAsync(() => vm.plan.addCaptureBlock(_light(60, 5)));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      expect(markOf(tester, 'Light · 60 s × 5 · 5 min'), greaterThan(0));
      expect(markOf(tester, 'L · 60 s × 10 · 10 min'), 0);
      await tester.pump(const Duration(seconds: 2));
      expect(markOf(tester, 'Light · 60 s × 5 · 5 min'), 0);
      await tester.runAsync(() => vm.plan.idle);
    });

    testWidgets('no mark with reduced motion', (tester) async {
      await start(tester, reducedMotion: true);
      await blocks(tester, [_light(60, 10, filter: 'L')]);
      await tester.runAsync(() => vm.plan.addCaptureBlock(_light(60, 5)));
      await tester.pump();
      expect(markOf(tester, 'Light · 60 s × 5 · 5 min'), 0);
      await tester.runAsync(() => vm.plan.idle);
    });
  });
}

/// Pumps fixed frames with real-time gaps, so database writes started by a
/// tap finish (TASK 12.2; a fake-time pump alone never lets them).
Future<void> settle(WidgetTester tester, {int frames = 8}) async {
  for (var i = 0; i < frames; i++) {
    await tester.runAsync(() => Future<void>.delayed(Duration.zero));
    await tester.pump(const Duration(milliseconds: 200));
  }
}
