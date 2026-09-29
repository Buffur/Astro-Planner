// S7.2a (ADR-020 §2; RG-11 = C1): a camera class on the rig. It is the
// user's choice in the rig editor, Unknown by default, stored with the
// camera, recorded in a new snapshot, and never inferred: an import from a
// photo proposes none, even when a saved rig with the same camera has one.

import 'package:astroplan/core/theme/app_theme.dart';
import 'package:astroplan/data/database/app_database.dart' show AppDatabase;
import 'package:astroplan/data/repositories/drift_equipment_repository.dart';
import 'package:astroplan/data/services/equipment_seeder.dart';
import 'package:astroplan/domain/models/calendar_date.dart';
import 'package:astroplan/domain/models/camera_class.dart';
import 'package:astroplan/domain/models/capture_block.dart';
import 'package:astroplan/domain/models/equipment_profile.dart';
import 'package:astroplan/domain/models/planning_preferences.dart';
import 'package:astroplan/domain/models/session_night.dart';
import 'package:astroplan/domain/models/tracking_type.dart';
import 'package:astroplan/domain/services/capture_budget_calculator.dart';
import 'package:astroplan/domain/services/session_snapshot_builder.dart';
import 'package:astroplan/presentation/screens/equipment/equipment_editor.dart';
import 'package:astroplan/presentation/shared/equipment_draft.dart';
import 'package:astroplan/presentation/viewmodels/library_viewmodels.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import '../support/in_memory_equipment_repository.dart';
import '../support/metadata_candidates.dart';

const _rig = EquipmentProfile(
  id: 0,
  name: 'Tripod camera',
  manufacturer: 'Canon',
  cameraModel: 'EOS R6',
  sensorWidthMm: 35.9,
  sensorHeightMm: 23.9,
  pixelPitchUm: 6.56,
  resolutionWidthPx: 5472,
  resolutionHeightPx: 3648,
  focalLengthMm: 24,
  focalRatio: 2.8,
);

EquipmentProfile _withClass(EquipmentProfile r, CameraClass c) =>
    EquipmentProfile(
      id: r.id,
      name: r.name,
      manufacturer: r.manufacturer,
      cameraModel: r.cameraModel,
      cameraClass: c,
      sensorWidthMm: r.sensorWidthMm,
      sensorHeightMm: r.sensorHeightMm,
      pixelPitchUm: r.pixelPitchUm,
      resolutionWidthPx: r.resolutionWidthPx,
      resolutionHeightPx: r.resolutionHeightPx,
      focalLengthMm: r.focalLengthMm,
      focalRatio: r.focalRatio,
      trackingType: r.trackingType,
      cameraSource: r.cameraSource,
      cameraConfidence: r.cameraConfidence,
      opticsSource: r.opticsSource,
      opticsConfidence: r.opticsConfidence,
      specProvenance: r.specProvenance,
      metadataMake: r.metadataMake,
      metadataModel: r.metadataModel,
    );

void main() {
  test('the classes, and anything unrecognised reads as unknown', () {
    expect(CameraClass.values.map((c) => c.label), [
      'Phone',
      'DSLR or mirrorless',
      'Astro camera (colour)',
      'Astro camera (mono)',
      'Unknown',
    ]);
    for (final c in CameraClass.values) {
      expect(CameraClass.fromStorage(c.name), c);
    }
    expect(CameraClass.fromStorage('mirrorless'), CameraClass.unknown);
    expect(CameraClass.fromStorage(null), CameraClass.unknown);
  });

  test('a new profile and the example rig are Unknown', () {
    expect(_rig.cameraClass, CameraClass.unknown);
    expect(
      EquipmentSeeder.defaults.single.cameraClass,
      CameraClass.unknown,
      reason: 'the owner kept the example rig Unknown (RG-11)',
    );
  });

  group('stored with the camera (real SQLite)', () {
    late AppDatabase db;
    late DriftEquipmentRepository repo;
    setUp(() {
      db = AppDatabase(NativeDatabase.memory());
      repo = DriftEquipmentRepository(db);
    });
    tearDown(() => db.close());

    test('insert, update and read it back; an edit keeps it', () async {
      final id = await repo.insertEquipment(
        _withClass(_rig, CameraClass.dslrMirrorless).withEditProvenance(null),
      );
      final stored = (await repo.getEquipmentById(id))!;
      expect(stored.cameraClass, CameraClass.dslrMirrorless);

      final draft = EquipmentDraft.fromProfile(stored);
      expect(draft.cameraClass, CameraClass.dslrMirrorless);
      final kept = draft.build(draft.initial, stored.trackingType).profile!;
      await repo.updateEquipment(kept);
      expect(
        (await repo.getEquipmentById(id))!.cameraClass,
        CameraClass.dslrMirrorless,
      );

      final changed = draft
          .build(
            draft.initial,
            stored.trackingType,
            cameraClass: CameraClass.phone,
          )
          .profile!;
      await repo.updateEquipment(changed);
      expect((await repo.getEquipmentById(id))!.cameraClass, CameraClass.phone);
    });
  });

  group('never inferred', () {
    test('an import proposes no class, even from a saved rig with this '
        'camera that has one', () {
      final saved = _withClass(
        EquipmentSeeder.defaults.single,
        CameraClass.astroColour,
      );
      for (final d in [
        EquipmentDraft.fromCandidate(phoneCandidate()),
        EquipmentDraft.fromCandidate(
          phoneCandidate(withDims: false, with35: false),
          cameraFrom: saved,
        ),
      ]) {
        expect(d.cameraClass, CameraClass.unknown);
        expect(
          d.build(d.initial, TrackingType.unknown).profile!.cameraClass,
          CameraClass.unknown,
        );
      }
    });

    test('an import never proposes in-camera noise reduction (S7.3b)', () {
      final d = EquipmentDraft.fromCandidate(phoneCandidate());
      expect(d.inCameraNoiseReduction, isFalse);
      expect(
        d
            .build(d.initial, TrackingType.unknown)
            .profile!
            .inCameraNoiseReduction,
        isFalse,
      );
      const saved = EquipmentProfile(
        id: 3,
        name: 'Tripod camera',
        cameraClass: CameraClass.dslrMirrorless,
        inCameraNoiseReduction: true,
        sensorWidthMm: 35.9,
        sensorHeightMm: 23.9,
        pixelPitchUm: 6.56,
        resolutionWidthPx: 5472,
        resolutionHeightPx: 3648,
        focalLengthMm: 24,
        focalRatio: 2.8,
      );
      expect(
        EquipmentDraft.forRig(saved, const {}).inCameraNoiseReduction,
        isTrue,
      );
      expect(EquipmentDraft.fromProfile(saved).inCameraNoiseReduction, isTrue);
    });

    test('opening a saved rig with a file\'s values keeps the rig\'s own '
        'class', () {
      final saved = _withClass(_rig, CameraClass.dslrMirrorless);
      final d = EquipmentDraft.forRig(saved, const {});
      expect(d.cameraClass, CameraClass.dslrMirrorless);
    });
  });

  test('a new snapshot records the class; a later change never alters a '
      'snapshot already taken', () {
    final prefs = PlanningPreferences();
    final blocks = [
      CaptureBlock(
        frameType: FrameType.light,
        exposureTimeSeconds: 30,
        frameCount: 10,
      ),
    ];
    Map<String, Object?> snapshot(EquipmentProfile rig) =>
        SessionSnapshotBuilder.build(
          takenAtUtc: DateTime.utc(2026, 12, 15, 18),
          night: SessionNight(
            eveningDate: CalendarDate(2026, 12, 15),
            startUtc: DateTime.utc(2026, 12, 15, 11),
            endUtc: DateTime.utc(2026, 12, 16, 11),
            latitude: 46.05,
            longitude: 14.51,
            timeContextId: 'Europe/Ljubljana',
          ),
          preferences: prefs,
          budget: CaptureBudgetCalculator.calculate(
            blocks: blocks,
            overheads: CaptureOverheads.fromPreferences(prefs),
          ),
          blocks: blocks,
          rig: rig,
        ).json;
    final taken = snapshot(_rig);
    expect((taken['rig']! as Map)['cameraClass'], 'unknown');
    final later = snapshot(_withClass(_rig, CameraClass.phone));
    expect((later['rig']! as Map)['cameraClass'], 'phone');
    expect((taken['rig']! as Map)['cameraClass'], 'unknown');
  });

  testWidgets('the editor offers the classes, Unknown first chosen for a new '
      'rig, and saves the user\'s choice, at 200 % text', (tester) async {
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
                  draft: EquipmentDraft.fromProfile(_rig),
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

    final field = find.byKey(const Key('equipmentEditor.cameraClass'));
    expect(field, findsOneWidget);
    expect(
      find.descendant(of: field, matching: find.text('Unknown')),
      findsOneWidget,
    );
    await tester.tap(field);
    await tester.pumpAndSettle();
    await tester.tap(find.text('DSLR or mirrorless').last);
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull, reason: 'no overflow');

    await tester.tap(find.widgetWithText(ElevatedButton, 'Save Changes'));
    await tester.pumpAndSettle();
    expect(repo.updated.single.cameraClass, CameraClass.dslrMirrorless);
  });
}
