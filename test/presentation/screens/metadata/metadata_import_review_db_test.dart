// S3.V5 (S3V-06): S3.6's acceptance matrix through the real screens and
// routes with a real in-memory SQLite database (the file picker is the only
// fake). Row counts are read from all three equipment tables, so "nothing
// was written" means nothing reached the database. The list-fake tests in
// metadata_import_review_test.dart are kept alongside.

import 'package:astroplan/core/theme/app_theme.dart';
import 'package:astroplan/data/database/app_database.dart';
import 'package:astroplan/data/repositories/drift_equipment_repository.dart';
import 'package:astroplan/domain/models/equipment_profile.dart';
import 'package:astroplan/domain/models/spec_confidence.dart';
import 'package:astroplan/domain/models/spec_provenance.dart';
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

import '../../../support/fake_capture_file_access.dart';
import '../../../support/jpeg_fixture.dart';
import '../../../support/tiff_fixture.dart';

class _Planner extends ChangeNotifier implements SessionPlanViewModel {
  @override
  EquipmentProfile? get selectedEquipment => null;

  @override
  Future<void> refreshSelectedEquipment() async {}

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

Future<void> _settle(WidgetTester t) async {
  for (var i = 0; i < 8; i++) {
    await t.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 20)),
    );
    await t.pump();
  }
  await t.pumpAndSettle();
}

/// The phone's main camera as a JPEG: f 6.57, f/1.6, f₃₅ 23, 3072 × 4096.
List<int> _phoneJpeg() {
  final exif = phoneStyleJpegExif();
  exif.exif!.addAll([
    FixtureEntry.long(40962, 3072),
    FixtureEntry.long(40963, 4096),
  ]);
  return jpegFile([exifApp1(exif.build().bytes)]);
}

/// The same JPEG without a 35 mm equivalent, so no estimate: the camera
/// specs can only come from a saved rig (S3.V8).
List<int> _phoneJpegNo35() {
  final exif = phoneStyleJpegExif();
  exif.exif!.removeWhere((e) => e.tag == 41989);
  exif.exif!.addAll([
    FixtureEntry.long(40962, 3072),
    FixtureEntry.long(40963, 4096),
  ]);
  return jpegFile([exifApp1(exif.build().bytes)]);
}

/// A saved rig for that camera with verified camera specs; its 2.4 µm
/// differs from the file's 2.414 µm estimate.
const _verifiedPhone = EquipmentProfile(
  id: 0,
  name: 'My phone',
  manufacturer: 'TestMake',
  cameraModel: 'TestMake TestPhone',
  sensorWidthMm: 9.83,
  sensorHeightMm: 7.37,
  pixelPitchUm: 2.4,
  resolutionWidthPx: 4096,
  resolutionHeightPx: 3072,
  focalLengthMm: 6.57,
  focalRatio: 1.6,
  cameraSource: 'seed:test',
  cameraConfidence: SpecConfidence.verified,
);

/// The same camera with another lens (another phone module).
const _tele = EquipmentProfile(
  id: 0,
  name: 'Phone tele',
  manufacturer: 'TestMake',
  cameraModel: 'TestMake TestPhone',
  sensorWidthMm: 5.07,
  sensorHeightMm: 3.81,
  pixelPitchUm: 1.25,
  resolutionWidthPx: 4064,
  resolutionHeightPx: 3056,
  focalLengthMm: 8.8,
  focalRatio: 2,
);

class _App {
  _App(this.db, this.repo, this.files);

  final AppDatabase db;
  final DriftEquipmentRepository repo;
  final FakeCaptureFileAccess files;

  /// Rows in the device, camera-module and rig tables.
  Future<List<int>> counts(WidgetTester t) async => (await t.runAsync(
    () async => [
      (await db.select(db.devices).get()).length,
      (await db.select(db.cameraModules).get()).length,
      (await db.select(db.opticalRigs).get()).length,
    ],
  ))!;

  Future<List<EquipmentProfile>> rigs(WidgetTester t) async =>
      (await t.runAsync(repo.getAllEquipment))!;
}

/// The Equipment screen with a real database holding [saved]; opens "Add
/// from a photo" unless [open] is false.
Future<_App> _start(
  WidgetTester t, {
  List<EquipmentProfile> saved = const [],
  bool open = true,
}) async {
  final db = AppDatabase(NativeDatabase.memory());
  final repo = DriftEquipmentRepository(db);
  addTearDown(() => t.runAsync(db.close));
  for (final rig in saved) {
    await t.runAsync(() => repo.insertEquipment(rig));
  }
  final files = FakeCaptureFileAccess();
  final vm = MetadataImportViewModel(files, repo);
  final gear = GearViewModel(repo);
  final planner = _Planner();
  addTearDown(vm.dispose);
  addTearDown(gear.dispose);
  addTearDown(planner.dispose);
  final router = GoRouter(
    routes: [
      GoRoute(path: '/', builder: (_, _) => const EquipmentSelectionScreen()),
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
      child: MaterialApp.router(theme: AppTheme.light, routerConfig: router),
    ),
  );
  await _settle(t);
  if (open) {
    await t.tap(find.byKey(const Key('rigs.addFromPhoto')));
    await _settle(t);
  }
  return _App(db, repo, files);
}

Future<void> _pickPhone(WidgetTester t, _App app) async {
  app.files.file('IMG.jpg', _phoneJpeg());
  await t.tap(find.byKey(const Key('metadata.pick')));
  await _settle(t);
}

String _headline(WidgetTester t) =>
    t.widget<Text>(find.byKey(const Key('import.headline'))).data!;

Future<void> _tapText(WidgetTester t, String text) async {
  await t.tap(find.text(text));
  await _settle(t);
}

void main() {
  testWidgets('Cancel at every step writes nothing: the picker, leaving the '
      'review, and Cancel in each editor it opens', (t) async {
    final app = await _start(t, saved: [_verifiedPhone, _tele]);
    final before = await app.counts(t);
    expect(before, [2, 2, 2]);

    // The picker cancelled.
    app.files.cancel();
    await t.tap(find.byKey(const Key('metadata.pick')));
    await _settle(t);
    expect(await app.counts(t), before);

    // A read file, then each editor the review opens, cancelled.
    await _pickPhone(t, app);
    expect(_headline(t), 'You already have this rig: "My phone".');
    await t.tap(find.byKey(const Key('import.open.1')));
    await _settle(t);
    await _tapText(t, 'Cancel');
    await t.tap(find.byKey(const Key('import.new')));
    await _settle(t);
    await _tapText(t, 'Cancel');
    expect(await app.counts(t), before);

    // Leaving the review writes nothing either.
    await t.tap(find.byTooltip('Back'));
    await _settle(t);
    expect(find.text('Select Equipment'), findsOneWidget);
    expect(await app.counts(t), before);
  });

  testWidgets('a new rig is written once, only by Save; the file then matches '
      'it, and Open and Save create no duplicate', (t) async {
    final app = await _start(t);
    await _pickPhone(t, app);
    expect(_headline(t), 'No saved rig has this camera.');
    expect(await app.counts(t), [0, 0, 0]);

    await t.tap(find.byKey(const Key('import.new')));
    await _settle(t);
    await _tapText(t, 'Save');
    expect(await app.counts(t), [1, 1, 1]);
    final rig = (await app.rigs(t)).single;
    expect(rig.metadataModel, 'TestMake TestPhone');
    expect(
      rig.provenanceOf(EquipmentSpec.focalLength),
      const SpecProvenance('metadata:jpeg', SpecConfidence.reported),
    );
    expect(_headline(t), startsWith('You already have this rig'));

    await t.tap(find.byKey(Key('import.open.${rig.id}')));
    await _settle(t);
    await _tapText(t, 'Save Changes');
    expect(await app.counts(t), [1, 1, 1], reason: 'no duplicate');
  });

  testWidgets('a difference is kept by default and a verified value survives '
      'Open and Save; only an explicit choice replaces it', (t) async {
    final app = await _start(t, saved: [_verifiedPhone]);
    await _pickPhone(t, app);
    final take = find.byKey(const Key('import.take.1.pixelPitch'));
    expect(t.widget<SwitchListTile>(take).value, isFalse);

    await t.tap(find.byKey(const Key('import.open.1')));
    await _settle(t);
    await _tapText(t, 'Save Changes');
    var rig = (await app.rigs(t)).single;
    expect(rig.pixelPitchUm, 2.4);
    expect(
      rig.provenanceOf(EquipmentSpec.pixelPitch)?.confidence,
      SpecConfidence.verified,
    );

    await t.tap(take);
    await _settle(t);
    await t.tap(find.byKey(const Key('import.open.1')));
    await _settle(t);
    await _tapText(t, 'Save Changes');
    rig = (await app.rigs(t)).single;
    expect(rig.pixelPitchUm, 2.414);
    expect(
      rig.provenanceOf(EquipmentSpec.pixelPitch)?.confidence,
      SpecConfidence.estimated,
    );
    // The untouched verified values stay verified and exact.
    expect(rig.sensorWidthMm, 9.83);
    expect(await app.counts(t), [1, 1, 1]);
  });

  testWidgets('another module of the same camera: a new rig with the saved '
      'camera specs is added beside the saved one', (t) async {
    final app = await _start(t, saved: [_tele]);
    await _pickPhone(t, app);
    expect(_headline(t), startsWith('Same camera as "Phone tele"'));
    await t.tap(find.byKey(const Key('import.newFrom.1')));
    await _settle(t);
    await _tapText(t, 'Save');
    expect(await app.counts(t), [2, 2, 2]);
    final saved = await app.rigs(t);
    expect(saved.map((r) => r.focalLengthMm), containsAll([8.8, 6.57]));
  });

  testWidgets('navigation and re-entry: the list shows the new rig, and the '
      'reopened review matches the database without a new pick', (t) async {
    final app = await _start(t);
    await _pickPhone(t, app);
    await t.tap(find.byKey(const Key('import.new')));
    await _settle(t);
    await _tapText(t, 'Save');

    await t.tap(find.byTooltip('Back'));
    await _settle(t);
    expect(find.textContaining('TestMake TestPhone'), findsWidgets);

    await t.tap(find.byKey(const Key('rigs.addFromPhoto')));
    await _settle(t);
    expect(app.files.picks, 1, reason: 'no new pick');
    expect(_headline(t), startsWith('You already have this rig'));
    expect(await app.counts(t), [1, 1, 1]);
  });

  // S3.V8 (S3S-02): the tele module's 4064 × 3056 px is not this file's
  // 4096 × 3072 px, so its pixel and sensor size are not copied.
  testWidgets("another pixel count: the saved pixel size is not copied, Save "
      "waits for the user's, and only then writes", (t) async {
    final app = await _start(t, saved: [_tele]);
    app.files.file('IMG.jpg', _phoneJpegNo35());
    await t.tap(find.byKey(const Key('metadata.pick')));
    await _settle(t);
    expect(_headline(t), startsWith('Same camera as "Phone tele"'));
    await t.tap(find.byKey(const Key('import.newFrom.1')));
    await _settle(t);

    final pitch = find.widgetWithText(TextFormField, '3.76').first;
    expect(t.widget<TextFormField>(pitch).controller!.text, '');
    expect(find.byKey(const Key('editor.withheld')), findsOneWidget);
    await _tapText(t, 'Save');
    expect(await app.counts(t), [1, 1, 1], reason: 'nothing without it');

    await t.enterText(pitch, '1.4');
    await _settle(t);
    expect(find.byKey(const Key('editor.withheld')), findsNothing);
    await _tapText(t, 'Save');
    expect(await app.counts(t), [2, 2, 2]);
    final rig = (await app.rigs(t)).firstWhere((r) => r.focalLengthMm == 6.57);
    expect(rig.pixelPitchUm, 1.4);
    expect(rig.resolutionWidthPx, 4096);
    expect(rig.sensorWidthMm, closeTo(4096 * 1.4 / 1000, 0.005));
    expect(rig.provenanceOf(EquipmentSpec.pixelPitch), SpecProvenance.user);
    // The saved tele rig is unchanged.
    final tele = (await app.rigs(t)).firstWhere((r) => r.focalLengthMm == 8.8);
    expect(tele.pixelPitchUm, 1.25);
  });
}
