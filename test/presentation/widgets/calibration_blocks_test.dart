// S7.3a (ADR-020 §6–§7; RG-10 = L1, D1, H1): a new calibration block takes
// what it must match from a light (a flat for a dark flat), shown with its
// origin, until "Use other values"; mismatches are warnings with a one-tap
// fix; tips are short, with more on demand, and can be hidden (remembered);
// a dark flat round-trips through the store, the snapshot read-back and the
// export.

import 'package:astroplan/core/time/clock.dart';
import 'package:astroplan/data/database/app_database.dart' show AppDatabase;
import 'package:astroplan/data/export/session_manifest_codec.dart';
import 'package:astroplan/data/repositories/drift_equipment_repository.dart';
import 'package:astroplan/data/repositories/drift_location_repository.dart';
import 'package:astroplan/data/repositories/drift_session_repository.dart';
import 'package:astroplan/data/repositories/drift_target_repository.dart';
import 'package:astroplan/domain/models/astro_target.dart';
import 'package:astroplan/domain/models/camera_class.dart';
import 'package:astroplan/domain/models/capture_block.dart';
import 'package:astroplan/domain/models/equipment_profile.dart';
import 'package:astroplan/domain/models/location_profile.dart' as domain;
import 'package:astroplan/domain/repositories/weather_repository.dart';
import 'package:astroplan/domain/services/saved_plan_reader.dart';
import 'package:astroplan/domain/services/session_exporter.dart';
import 'package:astroplan/presentation/shared/calibration_text.dart';
import 'package:astroplan/presentation/widgets/capture_plan/capture_block_dialog.dart';
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

final _ha = CaptureBlock(
  frameType: FrameType.light,
  filterName: 'Ha',
  exposureTimeSeconds: 300,
  frameCount: 20,
  binning: 2,
  gain: CaptureGain.gain(100),
);
final _oiii = CaptureBlock(
  frameType: FrameType.light,
  filterName: 'OIII',
  exposureTimeSeconds: 180,
  frameCount: 20,
  binning: 2,
  gain: CaptureGain.gain(120),
);

void main() {
  group('the dialog', () {
    Future<void> open(
      WidgetTester tester,
      List<CaptureBlock?> result, {
      List<CaptureBlock> blocks = const [],
      CaptureBlock? initial,
      bool tipsShown = true,
      List<bool>? tipsChanges,
      CameraClass cameraClass = CameraClass.astroMono,
    }) async {
      tester.view.physicalSize = const Size(412, 1400);
      tester.view.devicePixelRatio = 1;
      tester.platformDispatcher.textScaleFactorTestValue = 2;
      addTearDown(tester.view.reset);
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => TextButton(
                onPressed: () async => result.add(
                  await showCaptureBlockDialog(
                    context,
                    initial: initial,
                    blocks: blocks,
                    cameraClass: cameraClass,
                    tipsShown: tipsShown,
                    onTipsShown: tipsChanges?.add,
                  ),
                ),
                child: const Text('open'),
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();
    }

    Future<void> pickType(WidgetTester tester, String label) async {
      await tester.tap(find.text('LIGHT'));
      await tester.pumpAndSettle();
      await tester.tap(find.text(label).last);
      await tester.pumpAndSettle();
    }

    Future<void> enter(WidgetTester tester, String field, String text) async {
      final f = find.widgetWithText(TextFormField, field);
      await tester.ensureVisible(f);
      await tester.enterText(f, text);
    }

    Future<void> submit(WidgetTester tester) async {
      await tester.ensureVisible(find.byKey(const Key('blockDialog.submit')));
      await tester.tap(find.byKey(const Key('blockDialog.submit')));
      await tester.pumpAndSettle();
    }

    testWidgets('a new dark takes the exposure, gain and binning of the first '
        'light, shown with its origin, at 200 % text', (tester) async {
      final result = <CaptureBlock?>[];
      await open(tester, result, blocks: [_ha, _oiii]);
      await pickType(tester, 'DARK');
      expect(
        tester
            .widget<Text>(find.byKey(const Key('blockDialog.inherited')))
            .data,
        'From Ha · 300 s × 20: exposure 300 s, gain 100, 2 × 2 binning',
      );
      expect(
        find.widgetWithText(TextFormField, 'Exposure (seconds)'),
        findsNothing,
      );
      expect(find.byKey(const Key('blockDialog.gainValue')), findsNothing);
      expect(find.byKey(const Key('blockDialog.binning')), findsNothing);
      expect(tester.takeException(), isNull, reason: 'no overflow');
      await enter(tester, 'Frame Count', '30');
      await submit(tester);
      final d = result.single!;
      expect(
        (d.frameType, d.exposureTimeSeconds, d.gain, d.binning, d.frameCount),
        (FrameType.dark, 300.0, CaptureGain.gain(100), 2, 30),
      );
      expect(d.calibrationPolicy, CalibrationPolicy.outsideWindow);
    });

    testWidgets('another light can be chosen; "Use other values" makes the '
        'fields the user\'s', (tester) async {
      final result = <CaptureBlock?>[];
      await open(tester, result, blocks: [_ha, _oiii]);
      await pickType(tester, 'DARK');
      await tester.tap(find.byKey(const Key('blockDialog.source')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('OIII · 180 s × 20').last);
      await tester.pumpAndSettle();
      expect(find.textContaining('exposure 180 s, gain 120'), findsOneWidget);

      await tester.ensureVisible(find.byKey(const Key('blockDialog.useOther')));
      await tester.tap(find.byKey(const Key('blockDialog.useOther')));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('blockDialog.inherited')), findsNothing);
      await enter(tester, 'Exposure (seconds)', '200');
      await enter(tester, 'Frame Count', '10');
      await submit(tester);
      final d = result.single!;
      expect(d.exposureTimeSeconds, 200);
      expect(d.gain, CaptureGain.gain(120), reason: 'kept from the fields');
    });

    testWidgets('a new flat takes the filter and binning; its gain is '
        'proposed and its exposure is its own', (tester) async {
      final result = <CaptureBlock?>[];
      await open(tester, result, blocks: [_ha]);
      await pickType(tester, 'FLAT');
      expect(
        find.text('From Ha · 300 s × 20: filter Ha, 2 × 2 binning'),
        findsOneWidget,
      );
      await enter(tester, 'Exposure (seconds)', '2');
      await enter(tester, 'Frame Count', '20');
      await submit(tester);
      final f = result.single!;
      expect(
        (f.filterName, f.binning, f.exposureTimeSeconds, f.gain),
        ('Ha', 2, 2.0, CaptureGain.gain(100)),
      );
    });

    testWidgets('bias: its exposure is the shortest the camera allows; the '
        'gain and binning come from the light', (tester) async {
      final result = <CaptureBlock?>[];
      await open(tester, result, blocks: [_ha]);
      await pickType(tester, 'BIAS');
      expect(find.text('The shortest your camera allows.'), findsOneWidget);
      await enter(tester, 'Exposure (seconds)', '0.001');
      await enter(tester, 'Frame Count', '50');
      await submit(tester);
      final b = result.single!;
      expect(
        (b.exposureTimeSeconds, b.gain, b.binning),
        (0.001, CaptureGain.gain(100), 2),
      );
    });

    testWidgets('a dark flat matches a flat', (tester) async {
      final flat = CaptureBlock(
        frameType: FrameType.flat,
        filterName: 'Ha',
        exposureTimeSeconds: 2.5,
        frameCount: 20,
        binning: 2,
        gain: CaptureGain.gain(100),
        calibrationPolicy: CalibrationPolicy.outsideWindow,
      );
      final result = <CaptureBlock?>[];
      await open(tester, result, blocks: [_ha, flat]);
      await pickType(tester, 'DARK FLAT');
      expect(find.textContaining('From Flat (Ha) · 2.5 s × 20'), findsOne);
      await enter(tester, 'Frame Count', '20');
      await submit(tester);
      final d = result.single!;
      expect(
        (d.frameType, d.exposureTimeSeconds, d.gain),
        (FrameType.darkFlat, 2.5, CaptureGain.gain(100)),
      );
    });

    testWidgets('without a light to match, the fields are the user\'s', (
      tester,
    ) async {
      await open(tester, []);
      await pickType(tester, 'DARK');
      expect(find.byKey(const Key('blockDialog.source')), findsNothing);
      expect(
        find.widgetWithText(TextFormField, 'Exposure (seconds)'),
        findsOneWidget,
      );
    });

    testWidgets('tips: one line, more on demand, hideable; hiding them hides '
        'no field', (tester) async {
      final changes = <bool>[];
      await open(tester, [], blocks: [_ha], tipsChanges: changes);
      await pickType(tester, 'DARK');
      final (line, more) = CalibrationText.tip(FrameType.dark)!;
      expect(
        tester.widget<Text>(find.byKey(const Key('blockDialog.tip'))).data,
        line,
      );
      await tester.tap(find.byKey(const Key('blockDialog.tipMore')));
      await tester.pumpAndSettle();
      expect(
        tester.widget<Text>(find.byKey(const Key('blockDialog.tip'))).data,
        '$line $more',
      );
      await tester.ensureVisible(find.byKey(const Key('blockDialog.hideTips')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('blockDialog.hideTips')));
      await tester.pumpAndSettle();
      expect(changes, [false]);
      expect(find.byKey(const Key('blockDialog.tip')), findsNothing);
      expect(find.byKey(const Key('blockDialog.showTips')), findsOneWidget);
      expect(find.byKey(const Key('blockDialog.inherited')), findsOneWidget);
    });

    // RG-10 §4, cell by cell: what each calibration type takes from its
    // source, and which fields "Use other values" shows, per camera class.
    for (final c in CameraClass.values) {
      final iso = c.lightSensitivity == LightSensitivity.iso;
      final light = CaptureBlock(
        frameType: FrameType.light,
        filterName: 'Ha',
        exposureTimeSeconds: 30,
        frameCount: 20,
        binning: c.offersLightBinning ? 2 : 1,
        gain: iso ? CaptureGain.iso(800) : CaptureGain.gain(100),
      );
      final flat = CaptureBlock(
        frameType: FrameType.flat,
        filterName: 'Ha',
        exposureTimeSeconds: 2,
        frameCount: 20,
        binning: light.binning,
        gain: light.gain,
        calibrationPolicy: CalibrationPolicy.outsideWindow,
      );
      final sens = iso ? 'ISO 800' : 'gain 100';
      for (final (label, type) in [
        ('DARK', FrameType.dark),
        ('FLAT', FrameType.flat),
        ('BIAS', FrameType.bias),
        ('DARK FLAT', FrameType.darkFlat),
      ]) {
        testWidgets('${c.label}, ${type.name}: the matrix cell', (
          tester,
        ) async {
          await open(tester, [], blocks: [light, flat], cameraClass: c);
          await pickType(tester, label);
          final line = tester
              .widget<Text>(find.byKey(const Key('blockDialog.inherited')))
              .data!;
          expect(
            line.contains('binning'),
            c.offersLightBinning,
            reason: 'binning is not applicable for phones and cameras',
          );
          expect(
            line.contains('exposure'),
            type != FrameType.flat && type != FrameType.bias,
          );
          if (type == FrameType.flat) {
            expect(line, contains('filter Ha'));
          } else {
            expect(line, contains(sens));
          }
          expect(find.byKey(const Key('blockDialog.binning')), findsNothing);

          await tester.ensureVisible(
            find.byKey(const Key('blockDialog.useOther')),
          );
          await tester.tap(find.byKey(const Key('blockDialog.useOther')));
          await tester.pumpAndSettle();
          expect(
            find.byKey(const Key('blockDialog.binning')),
            c.offersLightBinning ? findsOneWidget : findsNothing,
          );
          expect(
            find.byKey(const Key('blockDialog.gainKind')),
            c == CameraClass.unknown ? findsOneWidget : findsNothing,
            reason: 'the class records one kind; Unknown chooses',
          );
          final value = tester.widget<TextField>(
            find.descendant(
              of: find.byKey(const Key('blockDialog.gainValue')),
              matching: find.byType(TextField),
            ),
          );
          expect(value.controller!.text, iso ? '800' : '100');
          if (c != CameraClass.unknown) {
            expect(
              find.text(
                iso ? 'ISO (for your records)' : 'Gain (for your records)',
              ),
              findsOneWidget,
            );
          }
          expect(tester.takeException(), isNull, reason: 'no overflow');
        });
      }
    }

    testWidgets('a value of the kind the class does not record is never '
        'relabelled as the other kind (SI-004)', (tester) async {
      final result = <CaptureBlock?>[];
      final legacy = CaptureBlock(
        frameType: FrameType.light,
        filterName: 'Ha',
        exposureTimeSeconds: 300,
        frameCount: 20,
        gain: CaptureGain.iso(800),
      );
      await open(
        tester,
        result,
        blocks: [legacy],
        cameraClass: CameraClass.astroMono,
      );
      await pickType(tester, 'FLAT');
      final value = tester.widget<TextField>(
        find.descendant(
          of: find.byKey(const Key('blockDialog.gainValue')),
          matching: find.byType(TextField),
        ),
      );
      expect(value.controller!.text, isEmpty, reason: 'not "gain 800"');
      await enter(tester, 'Exposure (seconds)', '2');
      await enter(tester, 'Frame Count', '20');
      await submit(tester);
      expect(result.single!.gain, CaptureGain.none);
    });

    testWidgets('an edited calibration block keeps its own values', (
      tester,
    ) async {
      final dark = CaptureBlock(
        frameType: FrameType.dark,
        exposureTimeSeconds: 60,
        frameCount: 10,
        calibrationPolicy: CalibrationPolicy.inWindow,
      );
      await open(tester, [], blocks: [_ha, dark], initial: dark);
      expect(find.byKey(const Key('blockDialog.source')), findsNothing);
      expect(
        find.widgetWithText(TextFormField, 'Exposure (seconds)'),
        findsOneWidget,
      );
    });
  });

  group('in the plan (real SQLite)', () {
    late AppDatabase db;
    late PlannerHarness vm;
    late DriftSessionRepository sessions;

    Future<void> start(WidgetTester tester) async {
      tester.view.physicalSize = const Size(412, 2400);
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
        final rigs = DriftEquipmentRepository(db);
        final targets = DriftTargetRepository(db);
        final rigId = await rigs.insertEquipment(
          const EquipmentProfile(
            id: 0,
            name: 'Mono',
            cameraClass: CameraClass.astroMono,
            sensorWidthMm: 23.5,
            sensorHeightMm: 15.7,
            pixelPitchUm: 3.76,
            resolutionWidthPx: 6248,
            resolutionHeightPx: 4176,
            focalLengthMm: 400,
            focalRatio: 5.6,
          ),
        );
        final targetId = await targets.insertTarget(
          const AstroTarget(
            id: 0,
            catalogId: 'M42',
            rightAscension: 83.82,
            declination: -5.39,
            type: 'Nebula',
          ),
        );
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
        await vm.plan.setEquipment((await rigs.getEquipmentById(rigId))!);
        await vm.plan.idle;
      });
      addTearDown(() => tester.runAsync(db.close));
      await tester.pumpWidget(
        MultiProvider(
          providers: vm.providers,
          child: const MaterialApp(
            home: Scaffold(
              body: SingleChildScrollView(child: CapturePlanWidget()),
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
      await tester.pump();
      await tester.pump(const Duration(seconds: 2));
    }

    Future<void> settle(WidgetTester tester, {int frames = 8}) async {
      for (var i = 0; i < frames; i++) {
        await tester.runAsync(() => Future<void>.delayed(Duration.zero));
        await tester.pump(const Duration(milliseconds: 200));
      }
    }

    testWidgets('a dark that matches no light is warned in words, and "Match '
        'the lights" fixes it with Undo', (tester) async {
      await start(tester);
      final dark = CaptureBlock(
        frameType: FrameType.dark,
        exposureTimeSeconds: 60,
        frameCount: 15,
        calibrationPolicy: CalibrationPolicy.inWindow,
        binning: 1,
        gain: CaptureGain.gain(100),
      );
      await blocks(tester, [_ha, dark]);
      expect(
        find.byKey(const Key('capture.mismatch.1.matchesNoLight')),
        findsOneWidget,
      );
      await tester.tap(find.byKey(const Key('capture.match.1')));
      await settle(tester);
      final fixed = vm.plan.captureBlocks[1];
      expect(
        (fixed.exposureTimeSeconds, fixed.binning, fixed.frameCount),
        (300.0, 2, 15),
      );
      expect(fixed.calibrationPolicy, CalibrationPolicy.inWindow);
      expect(
        find.byKey(const Key('capture.mismatch.1.matchesNoLight')),
        findsNothing,
      );
      expect(find.text('Undo'), findsOneWidget);
    });

    testWidgets('hiding tips hides no warning (ADR-020 §7)', (tester) async {
      await start(tester);
      await tester.runAsync(
        () => vm.disclosure.setOpen(CalibrationText.tipsKey, false),
      );
      await blocks(tester, [
        _ha,
        CaptureBlock(
          frameType: FrameType.dark,
          exposureTimeSeconds: 60,
          frameCount: 15,
          calibrationPolicy: CalibrationPolicy.inWindow,
          gain: CaptureGain.gain(100),
        ),
        CaptureBlock(
          frameType: FrameType.flat,
          filterName: 'SII',
          exposureTimeSeconds: 2,
          frameCount: 20,
          binning: 2,
          calibrationPolicy: CalibrationPolicy.outsideWindow,
        ),
      ]);
      expect(vm.disclosure.isOpen(CalibrationText.tipsKey), isFalse);
      expect(
        find.byKey(const Key('capture.mismatch.1.matchesNoLight')),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('capture.mismatch.2.filterUnused')),
        findsOneWidget,
      );
      expect(find.byKey(const Key('capture.flatsMissing')), findsOneWidget);
      expect(find.byKey(const Key('capture.match.1')), findsOneWidget);
    });

    testWidgets('a light filter without flats is named once the plan has '
        'flats', (tester) async {
      await start(tester);
      await blocks(tester, [
        _ha,
        _oiii,
        CaptureBlock(
          frameType: FrameType.flat,
          filterName: 'Ha',
          exposureTimeSeconds: 2,
          frameCount: 20,
          binning: 2,
          calibrationPolicy: CalibrationPolicy.outsideWindow,
        ),
      ]);
      expect(find.text('No flats for: OIII'), findsOneWidget);
    });

    testWidgets('a dark flat round-trips through the store, Discard\'s '
        'read-back and the export', (tester) async {
      await start(tester);
      final darkFlat = CaptureBlock(
        frameType: FrameType.darkFlat,
        exposureTimeSeconds: 2,
        frameCount: 20,
        calibrationPolicy: CalibrationPolicy.outsideWindow,
      );
      await blocks(tester, [_ha, darkFlat]);
      final saved = (await tester.runAsync(() => vm.analysis.saveSession()))!;
      expect(saved.blocks.last.frameType, FrameType.darkFlat);
      final read = SavedPlanReader.read(saved.planSnapshot!)!;
      expect(read.blocks.last.frameType, FrameType.darkFlat);
      final events = (await tester.runAsync(() => sessions.events(saved.id)))!;
      final manifest = SessionManifestCodec.encode(
        [ExportedSession(saved, events)],
        exportedAtUtc: DateTime.utc(2026, 11, 10, 18),
        appVersion: '1.0.0',
      );
      final back = SessionManifestCodec.decode(manifest);
      expect(
        back.sessions.single.session.blocks.last.frameType,
        FrameType.darkFlat,
      );
    });
  });
}
