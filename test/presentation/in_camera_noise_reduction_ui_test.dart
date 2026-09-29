// S7.3b (ADR-020 §8): in-camera noise reduction on the rig. The editor
// offers the switch only for cameras and Unknown, off by default; a stored
// value is kept, and ignored, for other types. The plan's budget, fit and
// "Fill tonight's window" follow a rig edit (trap 16: the cache is keyed on
// the plan's notifications); a matching dark is warned as darks twice; the
// snapshot records the switch.

import 'package:astroplan/core/theme/app_theme.dart';
import 'package:astroplan/core/time/clock.dart';
import 'package:astroplan/data/database/app_database.dart' show AppDatabase;
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
import 'package:astroplan/domain/services/calibration_match.dart';
import 'package:astroplan/presentation/screens/equipment/equipment_editor.dart';
import 'package:astroplan/presentation/shared/equipment_draft.dart';
import 'package:astroplan/presentation/viewmodels/library_viewmodels.dart';
import 'package:astroplan/presentation/widgets/capture_plan_widget.dart';
import 'package:astroplan/presentation/widgets/planner_sections.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../support/fake_device_time_zone.dart';
import '../support/fake_location_service.dart';
import '../support/fake_reverse_geocoder.dart';
import '../support/in_memory_equipment_repository.dart';
import '../support/no_snapshot_weather.dart';
import '../support/planner_harness.dart';

class _NoForecast with NoSnapshotWeather implements WeatherRepository {}

EquipmentProfile _rig({
  int id = 0,
  CameraClass cameraClass = CameraClass.dslrMirrorless,
  bool noiseReduction = false,
}) => EquipmentProfile(
  id: id,
  name: 'Tripod camera',
  manufacturer: 'Canon',
  cameraModel: 'EOS R6',
  cameraClass: cameraClass,
  inCameraNoiseReduction: noiseReduction,
  sensorWidthMm: 35.9,
  sensorHeightMm: 23.9,
  pixelPitchUm: 6.56,
  resolutionWidthPx: 5472,
  resolutionHeightPx: 3648,
  focalLengthMm: 135,
  focalRatio: 2.8,
);

final _lights = CaptureBlock(
  frameType: FrameType.light,
  exposureTimeSeconds: 60,
  frameCount: 30,
  gain: CaptureGain.iso(800),
);

void main() {
  group('the rig editor', () {
    Future<InMemoryEquipmentRepository> open(
      WidgetTester tester,
      EquipmentProfile rig,
    ) async {
      tester.view.physicalSize = const Size(375, 812);
      tester.view.devicePixelRatio = 1;
      tester.platformDispatcher.textScaleFactorTestValue = 2;
      addTearDown(tester.view.reset);
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
      final repo = InMemoryEquipmentRepository();
      await tester.pumpWidget(
        ChangeNotifierProvider(
          create: (_) => GearViewModel(repo),
          child: MaterialApp(
            theme: AppTheme.dark,
            home: Scaffold(
              body: Builder(
                builder: (context) => TextButton(
                  onPressed: () => showEquipmentEditor(
                    context,
                    draft: EquipmentDraft.fromProfile(rig),
                  ),
                  child: const Text('open'),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();
      return repo;
    }

    Future<void> chooseClass(WidgetTester tester, String label) async {
      final field = find.byKey(const Key('equipmentEditor.cameraClass'));
      await tester.ensureVisible(field);
      await tester.tap(field);
      await tester.pumpAndSettle();
      await tester.tap(find.text(label).last);
      await tester.pumpAndSettle();
    }

    const toggle = Key('equipmentEditor.noiseReduction');

    for (final c in CameraClass.values) {
      final offered = c.offersInCameraNoiseReduction;
      testWidgets(
        '${c.label}: the switch is ${offered ? 'offered, off' : ''
                  'not offered'}',
        (tester) async {
          await open(tester, _rig(cameraClass: c));
          expect(find.byKey(toggle), offered ? findsOneWidget : findsNothing);
          if (offered) {
            expect(
              tester.widget<SwitchListTile>(find.byKey(toggle)).value,
              false,
            );
          }
          expect(tester.takeException(), isNull, reason: 'no overflow');
        },
      );
    }

    testWidgets('turned on, then the type changed to an astro camera: the '
        'switch hides, and the stored value is kept (and ignored)', (
      tester,
    ) async {
      final repo = await open(tester, _rig());
      final control = find.descendant(
        of: find.byKey(toggle),
        matching: find.byType(Switch),
      );
      await tester.ensureVisible(control);
      await tester.pumpAndSettle();
      await tester.tap(control);
      await tester.pumpAndSettle();
      expect(tester.widget<SwitchListTile>(find.byKey(toggle)).value, isTrue);
      await chooseClass(tester, 'Astro camera (mono)');
      expect(find.byKey(toggle), findsNothing);
      await tester.tap(find.widgetWithText(ElevatedButton, 'Save Changes'));
      await tester.pumpAndSettle();
      final saved = repo.updated.single;
      expect(saved.cameraClass, CameraClass.astroMono);
      expect(saved.inCameraNoiseReduction, isTrue);
      expect(saved.noiseReductionApplies, isFalse);
    });
  });

  group('the plan (real SQLite)', () {
    late AppDatabase db;
    late PlannerHarness vm;
    late DriftEquipmentRepository rigs;
    late int rigId;

    Future<void> start(WidgetTester tester, EquipmentProfile rig) async {
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
        rigs = DriftEquipmentRepository(db);
        final targets = DriftTargetRepository(db);
        rigId = await rigs.insertEquipment(rig.withEditProvenance(null));
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
          sessionRepository: DriftSessionRepository(db, clock: clock),
        );
        await vm.ready;
        await vm.plan.setTarget((await targets.getTargetById(targetId))!);
        await vm.plan.setEquipment((await rigs.getEquipmentById(rigId))!);
        await vm.plan.addCaptureBlock(_lights);
        await vm.plan.idle;
      });
      addTearDown(() => tester.runAsync(db.close));
    }

    Future<void> editRig(WidgetTester tester, EquipmentProfile rig) =>
        tester.runAsync(() async {
          final stored = (await rigs.getEquipmentById(rigId))!;
          await rigs.updateEquipment(
            _rig(
              id: rigId,
              cameraClass: rig.cameraClass,
              noiseReduction: rig.inCameraNoiseReduction,
            ).withEditProvenance(stored),
          );
          await vm.plan.refreshSelectedEquipment();
        });

    testWidgets('a rig edit reaches the cached budget, fit and fill count; '
        'other types ignore the switch', (tester) async {
      await start(tester, _rig());
      final a = vm.analysis;
      final before = (a.captureBudget, a.fitAnalysis, a.fillWindowFrameCount);
      expect(before.$1.inCameraDarkMs, 0);
      expect(before.$3, isNotNull);

      await editRig(tester, _rig(noiseReduction: true));
      // 30 x 60 s of in-camera darks, in-window calibration (ADR-020 §8).
      expect(a.captureBudget.inCameraDarkMs, 1800000);
      expect(a.captureBudget.inWindowCalibrationMs, 1800000);
      expect(a.captureBudget.integrationMs, before.$1.integrationMs);
      expect(a.captureBudget.acquisitionMs, before.$1.acquisitionMs);
      expect(a.fitAnalysis.windowLoadMs, before.$2.windowLoadMs + 1800000);
      expect(a.fillWindowFrameCount, lessThan(before.$3!));

      await editRig(
        tester,
        _rig(cameraClass: CameraClass.phone, noiseReduction: true),
      );
      expect(vm.plan.selectedEquipment!.inCameraNoiseReduction, isTrue);
      expect(a.captureBudget.inCameraDarkMs, 0, reason: 'ignored for phones');
      expect(a.fillWindowFrameCount, before.$3);
    });

    testWidgets('the snapshot records the switch', (tester) async {
      await start(tester, _rig(noiseReduction: true));
      final saved = (await tester.runAsync(() => vm.analysis.saveSession()))!;
      final rig = saved.planSnapshot!.json['rig']! as Map;
      expect(rig['inCameraNoiseReduction'], isTrue);
      expect(rig['cameraClass'], 'dslrMirrorless');
    });

    testWidgets('a matching dark is warned as darks twice, with no "Match" '
        'fix; the budget and the assumptions name the darks', (tester) async {
      tester.view.physicalSize = const Size(412, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);
      await start(tester, _rig(noiseReduction: true));
      await tester.runAsync(() async {
        await vm.plan.addCaptureBlock(
          CaptureBlock(
            frameType: FrameType.dark,
            exposureTimeSeconds: 60,
            frameCount: 20,
            gain: CaptureGain.iso(800),
            calibrationPolicy: CalibrationPolicy.outsideWindow,
          ),
        );
        await vm.plan.idle;
        await vm.disclosure.setOpen(PlannerSections.budgetDetails, true);
        await vm.disclosure.setOpen(PlannerSections.assumptions, true);
      });
      expect(vm.analysis.calibrationMismatches[1], [
        CalibrationMismatch.darksTwice,
      ]);
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
      expect(
        find.byKey(const Key('capture.mismatch.1.darksTwice')),
        findsOneWidget,
      );
      expect(find.byKey(const Key('capture.match.1')), findsNothing);
      expect(find.byKey(const Key('budget.inCameraDarks')), findsOneWidget);
      expect(find.text('In-camera noise reduction'), findsOneWidget);
      expect(
        find.text("a dark as long as each light (the rig's setting)"),
        findsOneWidget,
      );
    });

    testWidgets('off, the assumptions say "Not included"; for an astro '
        'camera the row is absent', (tester) async {
      tester.view.physicalSize = const Size(412, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);
      await start(tester, _rig());
      await tester.runAsync(
        () => vm.disclosure.setOpen(PlannerSections.assumptions, true),
      );
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
      final row = find.ancestor(
        of: find.text('In-camera noise reduction'),
        matching: find.byType(Row),
      );
      expect(
        find.descendant(of: row, matching: find.text('Not included')),
        findsOneWidget,
      );
      await editRig(
        tester,
        _rig(cameraClass: CameraClass.astroColour, noiseReduction: true),
      );
      await tester.pump();
      expect(find.text('In-camera noise reduction'), findsNothing);
    });
  });
}
