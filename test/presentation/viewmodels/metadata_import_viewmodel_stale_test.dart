// S3.V6 (S3V-01 at the ViewModel level): after S3.V1–S3.V5 the validation's
// probe P5 still reverted a newer edit. It asked the ViewModel for a draft
// built from a match kept since before the edit. The ViewModel now hands out
// drafts of saved rigs only after reading the saved rigs again, so no
// caller can get a stale one. P5 restated against that API, with the real
// Drift repository.

import 'package:astroplan/data/database/app_database.dart';
import 'package:astroplan/data/repositories/drift_equipment_repository.dart';
import 'package:astroplan/domain/models/equipment_profile.dart';
import 'package:astroplan/domain/models/spec_confidence.dart';
import 'package:astroplan/domain/models/spec_provenance.dart';
import 'package:astroplan/domain/models/tracking_type.dart';
import 'package:astroplan/presentation/shared/equipment_draft.dart';
import 'package:astroplan/presentation/viewmodels/metadata_import_viewmodel.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/fake_capture_file_access.dart';
import '../../support/jpeg_fixture.dart';
import '../../support/tiff_fixture.dart';

/// The validation's saved rig: verified camera specs, a RAW size of 30.04.
const _saved = EquipmentProfile(
  id: 1,
  name: 'Saved phone',
  cameraModel: 'TestMake TestPhone',
  manufacturer: 'TestMake',
  sensorWidthMm: 9.894,
  sensorHeightMm: 7.416,
  pixelPitchUm: 2.414123,
  resolutionWidthPx: 4096,
  resolutionHeightPx: 3072,
  focalLengthMm: 6.57,
  focalRatio: 1.6,
  averageRawFileSizeMB: 30.04,
  cameraSource: 'seed:test',
  cameraConfidence: SpecConfidence.verified,
);

void main() {
  late AppDatabase db;
  late DriftEquipmentRepository repo;
  late MetadataImportViewModel vm;

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    repo = DriftEquipmentRepository(db);
    await repo.insertEquipment(_saved);
    final exif = phoneStyleJpegExif();
    exif.exif!.addAll([
      FixtureEntry.long(40962, 3072),
      FixtureEntry.long(40963, 4096),
    ]);
    final files = FakeCaptureFileAccess()
      ..file('synthetic.jpg', jpegFile([exifApp1(exif.build().bytes)]));
    vm = MetadataImportViewModel(files, repo);
    await vm.pickAndRead();
  });
  tearDown(() async {
    vm.dispose();
    await db.close();
  });

  /// Saves [value] as the rig's RAW size through the normal editor model,
  /// as an edit made elsewhere while the review is kept.
  Future<void> editElsewhere(double value) async {
    final old = (await repo.getEquipmentById(1))!;
    final changed = EquipmentDraft.forRig(old, {
      EquipmentSpec.rawFileSize: (
        value: value,
        provenance: SpecProvenance.user,
      ),
    });
    await repo.updateEquipment(
      changed.build(changed.initial, TrackingType.unknown).profile!,
    );
  }

  Future<void> save(EquipmentDraft d) async =>
      repo.updateEquipment(d.build(d.initial, TrackingType.unknown).profile!);

  test('P5 restated: a draft asked for after an edit elsewhere carries the '
      'newer value, so saving it keeps the edit', () async {
    expect(vm.match!.rigs.single.rig.averageRawFileSizeMB, 30.04);
    await editElsewhere(45);
    expect((await repo.getEquipmentById(1))!.averageRawFileSizeMB, 45);

    final draft = (await vm.rigDraft(1))!;
    expect(draft.existing!.averageRawFileSizeMB, 45);
    await save(draft);

    expect((await repo.getEquipmentById(1))!.averageRawFileSizeMB, 45);
  });

  test('a new rig with a saved rig\'s camera specs copies them as they are '
      'now', () async {
    final now = (await repo.getEquipmentById(1))!;
    await repo.updateEquipment(
      EquipmentProfile(
        id: now.id,
        name: now.name,
        manufacturer: now.manufacturer,
        cameraModel: now.cameraModel,
        sensorWidthMm: now.sensorWidthMm,
        sensorHeightMm: now.sensorHeightMm,
        pixelPitchUm: 2.5,
        resolutionWidthPx: now.resolutionWidthPx,
        resolutionHeightPx: now.resolutionHeightPx,
        focalLengthMm: now.focalLengthMm,
        focalRatio: now.focalRatio,
      ).withEditProvenance(now),
    );

    final draft = (await vm.newRigDraftWithCameraOf(1))!;
    final profile = draft.build(draft.initial, TrackingType.unknown).profile!;
    // The file gives its own pixel estimate; the saved rig only fills what
    // the file lacks, and never with the value it had before the edit.
    expect(profile.pixelPitchUm, isNot(2.414123));
  });

  test('a choice made before the edit is withdrawn from the draft', () async {
    vm.setTakesImported(
      vm.match!.rigs.single.rig,
      EquipmentSpec.pixelPitch,
      true,
    );
    final now = (await repo.getEquipmentById(1))!;
    await repo.updateEquipment(
      EquipmentProfile(
        id: now.id,
        name: now.name,
        manufacturer: now.manufacturer,
        cameraModel: now.cameraModel,
        sensorWidthMm: now.sensorWidthMm,
        sensorHeightMm: now.sensorHeightMm,
        pixelPitchUm: 2.5,
        resolutionWidthPx: now.resolutionWidthPx,
        resolutionHeightPx: now.resolutionHeightPx,
        focalLengthMm: now.focalLengthMm,
        focalRatio: now.focalRatio,
        averageRawFileSizeMB: now.averageRawFileSizeMB,
      ).withEditProvenance(now),
    );

    await save((await vm.rigDraft(1))!);
    expect((await repo.getEquipmentById(1))!.pixelPitchUm, 2.5);
  });

  test('a rig deleted meanwhile gives no draft', () async {
    await repo.deleteEquipment(1);
    expect(await vm.rigDraft(1), isNull);
    expect(await vm.newRigDraftWithCameraOf(1), isNull);
  });
}
