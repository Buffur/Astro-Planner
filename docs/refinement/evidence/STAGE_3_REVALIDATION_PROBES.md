# Stage 3 repeat-validation evidence

Date: 2026-09-27. Baseline: `d5e2b60`.

The three original files were restored from the Dart blocks in
`STAGE_3_VALIDATION_PROBES.md` (P1-P10). That historical evidence is unchanged.
P5 alone adapts to the revised production API:

```dart
// Previous API:
final reopened = vm.rigDraft(vm.match!.rigs.single);
// Current API; all following expectations remain unchanged:
final reopened = (await vm.rigDraft(vm.match!.rigs.single.rig.id))!;
```

Run from the repository root:

```text
flutter test --no-pub test/zz_stage3_validation_test.dart test/zz_stage3_widget_validation_test.dart test/zz_stage3_storage_validation_test.dart test/zz_stage3_revalidation_test.dart
```

All 11 tests passed. These temporary Dart files were removed afterwards;
this document preserves the additional probe and the execution output.
The R1 file imports the restored original probe's synthetic `saved` fixture.

## New R1 probe (`test/zz_stage3_revalidation_test.dart`)

```dart
import 'package:astroplan/data/database/app_database.dart';
import 'package:astroplan/data/repositories/drift_equipment_repository.dart';
import 'package:astroplan/domain/models/spec_provenance.dart';
import 'package:astroplan/domain/models/tracking_type.dart';
import 'package:astroplan/presentation/shared/equipment_draft.dart';
import 'package:astroplan/presentation/viewmodels/metadata_import_viewmodel.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/fake_capture_file_access.dart';
import 'support/jpeg_fixture.dart';
import 'support/tiff_fixture.dart';
import 'zz_stage3_validation_test.dart' show saved;

void main() {
  test('R1 copying a camera with no file geometry uses the latest exact saved fallback', () async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final repo = DriftEquipmentRepository(db);
    await repo.insertEquipment(saved());
    final exif = phoneStyleJpegExif();
    exif.exif!.removeWhere((e) => {37386, 41989, 40962, 40963}.contains(e.tag));
    exif.exif!.add(FixtureEntry.rational(37386, 88, 10));
    final files = FakeCaptureFileAccess()
      ..file('synthetic.jpg', jpegFile([exifApp1(exif.build().bytes)]));
    final vm = MetadataImportViewModel(files, repo);
    addTearDown(vm.dispose);
    await vm.pickAndRead();
    expect(vm.candidate!.pixelPitchUm.valueOrNull, isNull);
    final old = (await repo.getEquipmentById(1))!;
    final edited = EquipmentDraft.forRig(old, {
      EquipmentSpec.pixelPitch: (
        value: 2.56789,
        provenance: SpecProvenance.user,
      ),
    });
    await repo.updateEquipment(
      edited.build(edited.initial, TrackingType.unknown).profile!,
    );
    final draft = (await vm.newRigDraftWithCameraOf(1))!;
    final id = await repo.insertEquipment(
      draft.build(draft.initial, TrackingType.unknown).profile!,
    );
    final result = (await repo.getEquipmentById(id))!;
    expect(result.pixelPitchUm, 2.56789);
    expect(result.provenanceOf(EquipmentSpec.pixelPitch), SpecProvenance.user);
    expect(result.provenanceOf(EquipmentSpec.sensorSize), isNull);
    expect(result.sensorWidthMm, old.sensorWidthMm);
    expect(result.focalLengthMm, 8.8);
  });
}
```

## Combined execution output

```text
00:00 +0: loading C:/Users/zalub/OneDrive/Desktop/Astro Planner/Astro-Planner/test/zz_stage3_validation_test.dart
00:00 +0: C:/Users/zalub/OneDrive/Desktop/Astro Planner/Astro-Planner/test/zz_stage3_validation_test.dart: P1 copied legacy camera provenance remains unknown after persistence
00:00 +1: C:/Users/zalub/OneDrive/Desktop/Astro Planner/Astro-Planner/test/zz_stage3_validation_test.dart: P2 editing one legacy field does not invent provenance for untouched fields
00:00 +2: C:/Users/zalub/OneDrive/Desktop/Astro Planner/Astro-Planner/test/zz_stage3_validation_test.dart: P3 explicitly taking imported sensor size replaces the actual value
P3 stored=9.89 x 7.42; provenance=derived:calc-40/metadata:jpeg (estimated)
00:00 +3: C:/Users/zalub/OneDrive/Desktop/Astro Planner/Astro-Planner/test/zz_stage3_validation_test.dart: P4 copied verified camera specs are not rounded while retaining verified provenance
P4 width=9.894; pitch=2.414123; RAW=30.04; sensor provenance=seed:test (verified)
00:00 +4: C:/Users/zalub/OneDrive/Desktop/Astro Planner/Astro-Planner/test/zz_stage3_validation_test.dart: P5 revisiting retained review must not overwrite newer saved rig values
00:00 +5: C:/Users/zalub/OneDrive/Desktop/Astro Planner/Astro-Planner/test/zz_stage3_validation_test.dart: P6 normal new import persists and rematches without duplicate or conflicts
00:00 +6: C:/Users/zalub/OneDrive/Desktop/Astro Planner/Astro-Planner/test/zz_stage3_validation_test.dart: P7 absurd image dimensions are unparseable at the metadata boundary
00:00 +7: C:/Users/zalub/OneDrive/Desktop/Astro Planner/Astro-Planner/test/zz_stage3_storage_validation_test.dart: P9 backup and restore preserve all v18 import fields and identity
00:00 +8: C:/Users/zalub/OneDrive/Desktop/Astro Planner/Astro-Planner/test/zz_stage3_widget_validation_test.dart: P8 real routes and SQLite: retained import must not undo a later manual edit
00:00 +9: C:/Users/zalub/OneDrive/Desktop/Astro Planner/Astro-Planner/test/zz_stage3_widget_validation_test.dart: P8 real routes and SQLite: retained import must not undo a later manual edit
00:00 +10: C:/Users/zalub/OneDrive/Desktop/Astro Planner/Astro-Planner/test/zz_stage3_widget_validation_test.dart: P8 real routes and SQLite: retained import must not undo a later manual edit
00:03 +11: All tests passed!
```
