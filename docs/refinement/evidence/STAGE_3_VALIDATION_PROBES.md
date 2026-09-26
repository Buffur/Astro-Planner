# Stage 3 validation probes

Date: 2026-09-26. Baseline: `387e54b`. These synthetic probes were temporary
files under `test/`, run against unchanged application code, then removed.
They assert the required behavior, so reproduced defects intentionally fail.
Only this evidence copy is retained; these are not silently added to the normal suite.

To reproduce, restore each Dart block to its named path at the validated baseline
and run `flutter test --no-pub <path>` from the repository root. SQLite tests use
a real `AppDatabase` and `DriftEquipmentRepository`. P8 uses actual Equipment and
metadata screens, a test router with the production route paths, and a planner
stand-in (only unrelated planner refresh is stubbed). Capture bytes are synthetic.

Results: P1/P2 unknown provenance becomes user/reported; P3 explicit sensor choice
keeps the old number under new provenance; P4 copied values are rounded; P5/P8
retained review overwrites a later edit; P7 absurd dimensions remain known.
P6 normal round-trip, P9 backup/restore, and P10 transaction rollback pass.

## `test/zz_stage3_validation_test.dart`

```dart
import 'package:astroplan/data/database/app_database.dart';
import 'package:astroplan/data/repositories/drift_equipment_repository.dart';
import 'package:astroplan/domain/equipment_import/equipment_matcher.dart';
import 'package:astroplan/domain/metadata/capture_metadata.dart';
import 'package:astroplan/domain/metadata/capture_metadata_reader.dart';
import 'package:astroplan/domain/metadata/metadata_source.dart';
import 'package:astroplan/domain/metadata/metadata_value.dart';
import 'package:astroplan/domain/models/equipment_profile.dart';
import 'package:astroplan/domain/models/spec_confidence.dart';
import 'package:astroplan/domain/models/spec_provenance.dart';
import 'package:astroplan/domain/models/tracking_type.dart';
import 'package:astroplan/presentation/shared/equipment_draft.dart';
import 'package:astroplan/presentation/viewmodels/metadata_import_viewmodel.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/fake_capture_file_access.dart';
import 'support/jpeg_fixture.dart';
import 'support/memory_metadata_source.dart';
import 'support/metadata_candidates.dart';
import 'support/tiff_fixture.dart';

EquipmentProfile saved({bool verified = false, double width = 9.894}) =>
    EquipmentProfile(
      id: 1,
      name: 'Saved phone',
      cameraModel: 'TestMake TestPhone',
      manufacturer: 'TestMake',
      sensorWidthMm: width,
      sensorHeightMm: 7.416,
      pixelPitchUm: 2.414123,
      resolutionWidthPx: 4096,
      resolutionHeightPx: 3072,
      focalLengthMm: 6.57,
      focalRatio: 1.6,
      averageRawFileSizeMB: 30.04,
      cameraSource: verified ? 'seed:test' : null,
      cameraConfidence: verified ? SpecConfidence.verified : null,
    );

void main() {
  late AppDatabase db;
  late DriftEquipmentRepository repo;
  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    repo = DriftEquipmentRepository(db);
  });
  tearDown(() async => db.close());

  test(
    'P1 copied legacy camera provenance remains unknown after persistence',
    () async {
      final d = EquipmentDraft.fromCandidate(
        phoneCandidate(withDims: false, with35: false),
        cameraFrom: saved(),
      );
      final profile = d.build(d.initial, TrackingType.unknown).profile!;
      final id = await repo.insertEquipment(profile);
      final stored = (await repo.getEquipmentById(id))!;
      expect(stored.provenanceOf(EquipmentSpec.sensorSize), isNull);
    },
  );

  test('P2 editing one legacy field does not invent provenance for untouched fields', () async {
    await repo.insertEquipment(saved());
    final old = (await repo.getEquipmentById(1))!;
    final d = EquipmentDraft.forRig(old, {
      EquipmentSpec.pixelPitch: (value: 2.5, provenance: SpecProvenance.user),
    });
    await repo.updateEquipment(
      d.build(d.initial, TrackingType.unknown).profile!,
    );
    expect(
      (await repo.getEquipmentById(1))!.provenanceOf(EquipmentSpec.resolution),
      isNull,
    );
  });

  test('P3 explicitly taking imported sensor size replaces the actual value', () async {
    await repo.insertEquipment(saved(verified: true));
    final old = (await repo.getEquipmentById(1))!;
    final match = EquipmentMatcher.match(phoneCandidate(), [old]).rigs.single;
    final conflict = match.conflicts.singleWhere(
      (c) => c.spec == EquipmentSpec.sensorSize,
    );
    final d = EquipmentDraft.forRig(old, {
      conflict.spec: (
        value: conflict.imported,
        provenance: conflict.importedProvenance,
      ),
    });
    await repo.updateEquipment(
      d.build(d.initial, TrackingType.unknown).profile!,
    );
    final stored = (await repo.getEquipmentById(1))!;
    expect(
      stored.provenanceOf(EquipmentSpec.sensorSize),
      conflict.importedProvenance,
    );
    // ignore: avoid_print
    print(
      'P3 stored=${stored.sensorWidthMm} x ${stored.sensorHeightMm}; provenance=${stored.provenanceOf(EquipmentSpec.sensorSize)}',
    );
    expect(stored.sensorWidthMm, 9.89);
    expect(stored.sensorHeightMm, 7.42);
    expect(
      stored.provenanceOf(EquipmentSpec.sensorSize),
      conflict.importedProvenance,
    );
  });

  test('P4 copied verified camera specs are not rounded while retaining verified provenance', () async {
    final old = saved(verified: true);
    final d = EquipmentDraft.fromCandidate(
      phoneCandidate(withDims: false, with35: false),
      cameraFrom: old,
    );
    final id = await repo.insertEquipment(
      d.build(d.initial, TrackingType.unknown).profile!,
    );
    final stored = (await repo.getEquipmentById(id))!;
    expect(
      stored.provenanceOf(EquipmentSpec.sensorSize)?.confidence,
      SpecConfidence.verified,
    );
    // ignore: avoid_print
    print(
      'P4 width=${stored.sensorWidthMm}; pitch=${stored.pixelPitchUm}; RAW=${stored.averageRawFileSizeMB}; sensor provenance=${stored.provenanceOf(EquipmentSpec.sensorSize)}',
    );
    expect(stored.sensorWidthMm, old.sensorWidthMm);
    expect(stored.pixelPitchUm, old.pixelPitchUm);
    expect(stored.averageRawFileSizeMB, old.averageRawFileSizeMB);
  });

  test(
    'P5 revisiting retained review must not overwrite newer saved rig values',
    () async {
      await repo.insertEquipment(saved(verified: true));
      final exif = phoneStyleJpegExif();
      exif.exif!.addAll([
        FixtureEntry.long(40962, 3072),
        FixtureEntry.long(40963, 4096),
      ]);
      final files = FakeCaptureFileAccess()
        ..file('synthetic.jpg', jpegFile([exifApp1(exif.build().bytes)]));
      final vm = MetadataImportViewModel(files, repo);
      addTearDown(vm.dispose);
      await vm.pickAndRead();
      // Leave review and edit the saved rig through the normal editor model.
      final old = (await repo.getEquipmentById(1))!;
      final changed = EquipmentDraft.forRig(old, {
        EquipmentSpec.rawFileSize: (
          value: 45.0,
          provenance: SpecProvenance.user,
        ),
      });
      await repo.updateEquipment(
        changed.build(changed.initial, TrackingType.unknown).profile!,
      );
      expect((await repo.getEquipmentById(1))!.averageRawFileSizeMB, 45);
      // AppViewModels retains vm; the stateless review has no re-entry refresh.
      final reopened = vm.rigDraft(vm.match!.rigs.single);
      await repo.updateEquipment(
        reopened.build(reopened.initial, TrackingType.unknown).profile!,
      );
      expect((await repo.getEquipmentById(1))!.averageRawFileSizeMB, 45);
    },
  );

  test('P6 normal new import persists and rematches without duplicate or conflicts', () async {
    final candidate = phoneCandidate();
    final d = EquipmentDraft.fromCandidate(candidate);
    expect(await repo.getAllEquipment(), isEmpty);
    final id = await repo.insertEquipment(
      d.build(d.initial, TrackingType.unknown).profile!,
    );
    final rigs = await repo.getAllEquipment();
    expect(rigs, hasLength(1));
    final m = EquipmentMatcher.match(candidate, rigs);
    expect(m.outcome, MatchKind.sameRig);
    expect(m.rigs.single.conflicts, isEmpty);
    expect(m.rigs.single.rig.id, id);
  });

  test(
    'P7 absurd image dimensions are unparseable at the metadata boundary',
    () async {
      final exif = phoneStyleJpegExif();
      exif.exif!.addAll([
        FixtureEntry.long(40962, 0xffffffff),
        FixtureEntry.long(40963, 0xffffffff),
      ]);
      final source = BudgetedMetadataSource(
        MemoryMetadataSource(jpegFile([exifApp1(exif.build().bytes)])),
      );
      final reading = await CaptureMetadataReader.read(source) as MetadataRead;
      expect(
        reading.metadata.imageDimensions,
        isA<UnparseableValue<ImageDimensions>>(),
      );
    },
  );
}
```

Executed output:

```text
00:00 +0: loading C:/Users/zalub/OneDrive/Desktop/Astro Planner/Astro-Planner/test/zz_stage3_validation_test.dart
00:00 +0: P1 copied legacy camera provenance remains unknown after persistence
00:00 +0 -1: P1 copied legacy camera provenance remains unknown after persistence [E]
  Expected: null
    Actual: SpecProvenance:<user (reported)>
  
  package:matcher                                     expect
  package:flutter_test/src/widget_tester.dart 473:18  expect
  test\zz_stage3_validation_test.dart 60:7            main.<fn>
  
00:00 +0 -1: P2 editing one legacy field does not invent provenance for untouched fields
00:00 +0 -2: P2 editing one legacy field does not invent provenance for untouched fields [E]
  Expected: null
    Actual: SpecProvenance:<user (reported)>
  
  package:matcher                                     expect
  package:flutter_test/src/widget_tester.dart 473:18  expect
  test\zz_stage3_validation_test.dart 73:5            main.<fn>
  
00:00 +0 -2: P3 explicitly taking imported sensor size replaces the actual value
P3 stored=9.894 x 7.416; provenance=derived:calc-40/metadata:jpeg (estimated)
00:00 +0 -3: P3 explicitly taking imported sensor size replaces the actual value [E]
  Expected: <9.89>
    Actual: <9.894>
  
  package:matcher                                     expect
  package:flutter_test/src/widget_tester.dart 473:18  expect
  test\zz_stage3_validation_test.dart 104:5           main.<fn>
  
00:00 +0 -3: P4 copied verified camera specs are not rounded while retaining verified provenance
P4 width=9.89; pitch=2.414; RAW=30.0; sensor provenance=seed:test (verified)
00:00 +0 -4: P4 copied verified camera specs are not rounded while retaining verified provenance [E]
  Expected: <9.894>
    Actual: <9.89>
  
  package:matcher                                     expect
  package:flutter_test/src/widget_tester.dart 473:18  expect
  test\zz_stage3_validation_test.dart 130:5           main.<fn>
  
00:00 +0 -4: P5 revisiting retained review must not overwrite newer saved rig values
00:00 +0 -5: P5 revisiting retained review must not overwrite newer saved rig values [E]
  Expected: <45>
    Actual: <30.04>
  
  package:matcher                                     expect
  package:flutter_test/src/widget_tester.dart 473:18  expect
  test\zz_stage3_validation_test.dart 166:7           main.<fn>
  
00:00 +0 -5: P6 normal new import persists and rematches without duplicate or conflicts
00:00 +1 -5: P7 absurd image dimensions are unparseable at the metadata boundary
00:00 +1 -6: P7 absurd image dimensions are unparseable at the metadata boundary [E]
  Expected: <Instance of 'UnparseableValue<ImageDimensions>'>
    Actual: KnownValue<ImageDimensions>:<Known(4294967295x4294967295 from jpeg:APP1 EXIF IFD/PixelXDimension/PixelYDimension (40962/40963), raw "4294967295 x 4294967295")>
     Which: is not an instance of 'UnparseableValue<ImageDimensions>'
  
  package:matcher                                     expect
  package:flutter_test/src/widget_tester.dart 473:18  expect
  test\zz_stage3_validation_test.dart 197:7           main.<fn>
  
00:00 +1 -6: Some tests failed.

Failing tests:
  C:/Users/zalub/OneDrive/Desktop/Astro Planner/Astro-Planner/test/zz_stage3_validation_test.dart: P1 copied legacy camera provenance remains unknown after persistence
  C:/Users/zalub/OneDrive/Desktop/Astro Planner/Astro-Planner/test/zz_stage3_validation_test.dart: P2 editing one legacy field does not invent provenance for untouched fields
  C:/Users/zalub/OneDrive/Desktop/Astro Planner/Astro-Planner/test/zz_stage3_validation_test.dart: P3 explicitly taking imported sensor size replaces the actual value
  C:/Users/zalub/OneDrive/Desktop/Astro Planner/Astro-Planner/test/zz_stage3_validation_test.dart: P4 copied verified camera specs are not rounded while retaining verified provenance
  ... and 2 more
```

## `test/zz_stage3_widget_validation_test.dart`

```dart
import 'package:astroplan/core/theme/app_theme.dart';
import 'package:astroplan/data/database/app_database.dart';
import 'package:astroplan/data/repositories/drift_equipment_repository.dart';
import 'package:astroplan/domain/models/equipment_profile.dart';
import 'package:astroplan/presentation/navigation/app_router.dart';
import 'package:astroplan/presentation/screens/equipment/equipment_selection_screen.dart';
import 'package:astroplan/presentation/screens/metadata/metadata_import_screen.dart';
import 'package:astroplan/presentation/viewmodels/library_viewmodels.dart';
import 'package:astroplan/presentation/viewmodels/metadata_import_viewmodel.dart';
import 'package:astroplan/presentation/viewmodels/session_plan_viewmodel.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'support/fake_capture_file_access.dart';
import 'support/jpeg_fixture.dart';
import 'support/tiff_fixture.dart';

class _Planner extends ChangeNotifier implements SessionPlanViewModel {
  @override
  EquipmentProfile? get selectedEquipment => null;
  @override
  Future<void> refreshSelectedEquipment() async {}
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

Future<void> settle(WidgetTester t) async {
  for (var i = 0; i < 8; i++) {
    await t.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 20)),
    );
    await t.pump();
  }
  await t.pumpAndSettle();
}

void main() {
  testWidgets(
    'P8 real routes and SQLite: retained import must not undo a later manual edit',
    (t) async {
      final db = AppDatabase(NativeDatabase.memory());
      final repo = DriftEquipmentRepository(db);
      addTearDown(() => t.runAsync(db.close));
      await t.runAsync(
        () => repo.insertEquipment(
          const EquipmentProfile(
            id: 0,
            name: 'My phone',
            manufacturer: 'TestMake',
            cameraModel: 'TestMake TestPhone',
            sensorWidthMm: 9.89,
            sensorHeightMm: 7.42,
            pixelPitchUm: 2.414,
            resolutionWidthPx: 4096,
            resolutionHeightPx: 3072,
            focalLengthMm: 6.57,
            focalRatio: 1.6,
            averageRawFileSizeMB: 30,
          ),
        ),
      );
      final exif = phoneStyleJpegExif();
      exif.exif!.addAll([
        FixtureEntry.long(40962, 3072),
        FixtureEntry.long(40963, 4096),
      ]);
      final files = FakeCaptureFileAccess()
        ..file('synthetic.jpg', jpegFile([exifApp1(exif.build().bytes)]));
      final vm = MetadataImportViewModel(files, repo);
      final planner = _Planner();
      final gear = GearViewModel(repo);
      addTearDown(vm.dispose);
      addTearDown(planner.dispose);
      addTearDown(gear.dispose);
      final router = GoRouter(
        routes: [
          GoRoute(
            path: '/',
            builder: (_, _) => const EquipmentSelectionScreen(),
          ),
          GoRoute(
            path: AppRouter.metadata,
            builder: (_, _) => const MetadataImportScreen(),
          ),
        ],
      );
      addTearDown(router.dispose);
      t.view.physicalSize = const Size(800, 4000);
      t.view.devicePixelRatio = 1;
      addTearDown(t.view.reset);
      await t.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider.value(value: gear),
            ChangeNotifierProvider<SessionPlanViewModel>.value(value: planner),
            ChangeNotifierProvider<MetadataImportViewModel?>.value(value: vm),
          ],
          child: MaterialApp.router(
            theme: AppTheme.light,
            routerConfig: router,
          ),
        ),
      );
      await settle(t);
      await t.tap(find.byKey(const Key('rigs.addFromPhoto')));
      await settle(t);
      await t.tap(find.byKey(const Key('metadata.pick')));
      await settle(t);
      expect(
        find.text('You already have this rig: "My phone".'),
        findsOneWidget,
      );
      router.pop();
      await settle(t);
      await t.tap(find.byTooltip('Edit'));
      await settle(t);
      await t.enterText(find.widgetWithText(TextFormField, '30'), '45');
      await t.tap(find.text('Save Changes'));
      await settle(t);
      expect(
        (await t.runAsync(() => repo.getEquipmentById(1)))!
            .averageRawFileSizeMB,
        45,
      );
      await t.tap(find.byKey(const Key('rigs.addFromPhoto')));
      await settle(t);
      await t.tap(find.byKey(const Key('import.open.1')));
      await settle(t);
      await t.tap(find.text('Save Changes'));
      await settle(t);
      expect(
        (await t.runAsync(() => repo.getEquipmentById(1)))!
            .averageRawFileSizeMB,
        45,
      );
    },
  );
}
```

Executed output:

```text
00:00 +0: loading C:/Users/zalub/OneDrive/Desktop/Astro Planner/Astro-Planner/test/zz_stage3_widget_validation_test.dart
00:00 +0: P8 real routes and SQLite: retained import must not undo a later manual edit
══╡ EXCEPTION CAUGHT BY FLUTTER TEST FRAMEWORK ╞════════════════════════════════════════════════════
The following TestFailure was thrown running a test:
Expected: <45>
  Actual: <30.0>

When the exception was thrown, this was the stack:
#4      main.<anonymous closure> (file:///C:/Users/zalub/OneDrive/Desktop/Astro%20Planner/Astro-Planner/test/zz_stage3_widget_validation_test.dart:134:7)
<asynchronous suspension>
#5      testWidgets.<anonymous closure>.<anonymous closure> (package:flutter_test/src/widget_tester.dart:192:15)
<asynchronous suspension>
#6      TestWidgetsFlutterBinding._runTestBody (package:flutter_test/src/binding.dart:1953:5)
<asynchronous suspension>
<asynchronous suspension>
(elided one frame from package:stack_trace)

This was caught by the test expectation on the following line:
  file:///C:/Users/zalub/OneDrive/Desktop/Astro%20Planner/Astro-Planner/test/zz_stage3_widget_validation_test.dart line 134
The test description was:
  P8 real routes and SQLite: retained import must not undo a later manual edit
════════════════════════════════════════════════════════════════════════════════════════════════════
00:03 +0 -1: P8 real routes and SQLite: retained import must not undo a later manual edit [E]
  Test failed. See exception logs above.
  The test description was: P8 real routes and SQLite: retained import must not undo a later manual edit
  
00:03 +0 -1: Some tests failed.

Failing tests:
  C:/Users/zalub/OneDrive/Desktop/Astro Planner/Astro-Planner/test/zz_stage3_widget_validation_test.dart: P8 real routes and SQLite: retained import must not undo a later manual edit
```

## `test/zz_stage3_storage_validation_test.dart`

```dart
import 'dart:io';

import 'package:astroplan/data/backup/backup_staging.dart';
import 'package:astroplan/data/backup/file_backup_service.dart';
import 'package:astroplan/data/database/app_database.dart';
import 'package:astroplan/data/repositories/drift_equipment_repository.dart';
import 'package:astroplan/data/repositories/drift_session_repository.dart';
import 'package:astroplan/domain/models/tracking_type.dart';
import 'package:astroplan/presentation/shared/equipment_draft.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;

import 'support/metadata_candidates.dart';

void main() {
  test(
    'P9 backup and restore preserve all v18 import fields and identity',
    () async {
      final root = await Directory.systemTemp.createTemp(
        'astro_stage3_validation_',
      );
      addTearDown(() => root.delete(recursive: true));
      final dest = await Directory(p.join(root.path, 'restored')).create();
      final db = AppDatabase(
        NativeDatabase(File(p.join(root.path, 'source.sqlite'))),
      );
      final repo = DriftEquipmentRepository(db);
      final draft = EquipmentDraft.fromCandidate(phoneCandidate());
      final id = await repo.insertEquipment(
        draft.build(draft.initial, TrackingType.unknown).profile!,
      );
      final before = (await repo.getEquipmentById(id))!;
      final service = FileBackupService(
        db,
        DriftSessionRepository(db),
        dataDir: () async => dest,
        tempDir: () async => root,
      );
      final bytes = await service.createBackup();
      final checked = service.check(bytes);
      await service.stage(checked.database);
      await db.close();
      expect(
        await BackupStaging.apply(dest, nowUtc: DateTime.utc(2026, 9, 26)),
        isNull,
      );
      final restored = AppDatabase(
        NativeDatabase(File(p.join(dest.path, BackupStaging.database))),
      );
      try {
        final after = (await DriftEquipmentRepository(restored)
            .getEquipmentById(id))!;
        expect(after.specProvenance, before.specProvenance);
        expect(after.metadataMake, before.metadataMake);
        expect(after.metadataModel, before.metadataModel);
        expect(after.sensorWidthMm, before.sensorWidthMm);
        expect(after.pixelPitchUm, before.pixelPitchUm);
        expect(after.resolutionWidthPx, before.resolutionWidthPx);
        expect(after.focalLengthMm, before.focalLengthMm);
      } finally {
        await restored.close();
      }
    },
  );

  test(
    'P10 a failed rig insertion rolls back the entire device-camera-rig chain',
    () async {
      final db = AppDatabase(NativeDatabase.memory());
      addTearDown(db.close);
      await db.customStatement(
        "CREATE TRIGGER validation_fail BEFORE INSERT ON optical_rigs BEGIN SELECT RAISE(ABORT, 'validation injected failure'); END;",
      );
      final draft = EquipmentDraft.fromCandidate(phoneCandidate());
      await expectLater(
        DriftEquipmentRepository(db).insertEquipment(
          draft.build(draft.initial, TrackingType.unknown).profile!,
        ),
        throwsA(anything),
      );
      expect(await db.select(db.devices).get(), isEmpty);
      expect(await db.select(db.cameraModules).get(), isEmpty);
      expect(await db.select(db.opticalRigs).get(), isEmpty);
    },
  );
}
```

Executed output:

```text
00:00 +0: loading C:/Users/zalub/OneDrive/Desktop/Astro Planner/Astro-Planner/test/zz_stage3_storage_validation_test.dart
00:00 +0: P9 backup and restore preserve all v18 import fields and identity
00:00 +1: P10 a failed rig insertion rolls back the entire device-camera-rig chain
00:00 +2: All tests passed!
```
