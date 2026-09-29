// S3.V1 (S3V-01): an import review kept from earlier must never silently
// revert Equipment changes made since, unless the user explicitly chooses
// to replace a value. Real routes, real screens and a real SQLite database.

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

/// Lets Drift's real I/O finish between frames.
Future<void> _settle(WidgetTester t) async {
  for (var i = 0; i < 8; i++) {
    await t.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 20)),
    );
    await t.pump();
  }
  await t.pumpAndSettle();
}

/// The saved rig for the phone's main camera (the file's estimate is
/// 9.89 × 7.42 mm and 2.414 µm, so the saved 2.4 µm is a listed difference).
const _phone = EquipmentProfile(
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
  averageRawFileSizeMB: 30,
);

class _App {
  _App(this.repo, this.router);

  final DriftEquipmentRepository repo;
  final GoRouter router;

  Future<EquipmentProfile> rig(WidgetTester t) async =>
      (await t.runAsync(() => repo.getEquipmentById(1)))!;
}

Future<_App> _start(WidgetTester t) async {
  final db = AppDatabase(NativeDatabase.memory());
  final repo = DriftEquipmentRepository(db);
  addTearDown(() => t.runAsync(db.close));
  await t.runAsync(() => repo.insertEquipment(_phone));
  final exif = phoneStyleJpegExif();
  exif.exif!.addAll([
    FixtureEntry.long(40962, 3072),
    FixtureEntry.long(40963, 4096),
  ]);
  final files = FakeCaptureFileAccess()
    ..file('IMG.jpg', jpegFile([exifApp1(exif.build().bytes)]));
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
  // Import the file once: the review matches the saved rig.
  await t.tap(find.byKey(const Key('rigs.addFromPhoto')));
  await _settle(t);
  await t.tap(find.byKey(const Key('metadata.pick')));
  await _settle(t);
  expect(find.text('You already have this rig: "My phone".'), findsOneWidget);
  return _App(repo, router);
}

/// Opens the rig editor's "More (optional)" section (S7.6).
Future<void> _openMore(WidgetTester t) async {
  final header = find.byKey(const Key('section.rigEditor.more'));
  await t.ensureVisible(header);
  await _settle(t);
  await t.tap(header);
  await _settle(t);
}

/// Edits the rig through the Equipment screen's own editor.
Future<void> _editElsewhere(
  WidgetTester t,
  _App app, {
  required String from,
  required String to,
}) async {
  app.router.pop();
  await _settle(t);
  await t.tap(find.byTooltip('Edit rig'));
  await _settle(t);
  // S7.6: the RAW size is one tap away, in "More (optional)".
  if (find.widgetWithText(TextFormField, from).evaluate().isEmpty) {
    await _openMore(t);
  }
  await t.enterText(find.widgetWithText(TextFormField, from).first, to);
  await t.pump();
  await t.tap(find.text('Save Changes'));
  await _settle(t);
}

void main() {
  testWidgets('an edit made elsewhere survives reopening the review, Open '
      'and Save (the validation\'s P8)', (t) async {
    final app = await _start(t);
    await _editElsewhere(t, app, from: '30', to: '45');
    expect((await app.rig(t)).averageRawFileSizeMB, 45);

    await t.tap(find.byKey(const Key('rigs.addFromPhoto')));
    await _settle(t);
    await t.tap(find.byKey(const Key('import.open.1')));
    await _settle(t);
    await _openMore(t); // S7.6: the rig's own RAW size, one tap away
    expect(find.widgetWithText(TextFormField, '45'), findsOneWidget);
    await t.tap(find.text('Save Changes'));
    await _settle(t);

    expect((await app.rig(t)).averageRawFileSizeMB, 45);
  });

  testWidgets('a change saved while the review stays open is not reverted by '
      'its Open button', (t) async {
    final app = await _start(t);
    final current = await app.rig(t);
    await t.runAsync(
      () => app.repo.updateEquipment(
        EquipmentProfile(
          id: current.id,
          name: current.name,
          manufacturer: current.manufacturer,
          cameraModel: current.cameraModel,
          sensorWidthMm: current.sensorWidthMm,
          sensorHeightMm: current.sensorHeightMm,
          pixelPitchUm: current.pixelPitchUm,
          resolutionWidthPx: current.resolutionWidthPx,
          resolutionHeightPx: current.resolutionHeightPx,
          focalLengthMm: current.focalLengthMm,
          focalRatio: current.focalRatio,
          averageRawFileSizeMB: 45,
        ).withEditProvenance(current),
      ),
    );

    await t.tap(find.byKey(const Key('import.open.1')));
    await _settle(t);
    await t.tap(find.text('Save Changes'));
    await _settle(t);

    expect((await app.rig(t)).averageRawFileSizeMB, 45);
  });

  testWidgets('a "use the file\'s value" choice made before a newer edit is '
      'withdrawn; replacing needs a fresh, explicit choice', (t) async {
    final app = await _start(t);
    final take = find.byKey(const Key('import.take.1.pixelPitch'));
    await t.tap(take);
    await _settle(t);
    expect(t.widget<SwitchListTile>(take).value, isTrue);

    // The user then types their own pixel size in the Equipment editor.
    await _editElsewhere(t, app, from: '2.4', to: '2.5');
    expect((await app.rig(t)).pixelPitchUm, 2.5);

    await t.tap(find.byKey(const Key('rigs.addFromPhoto')));
    await _settle(t);
    expect(
      t.widget<SwitchListTile>(take).value,
      isFalse,
      reason: 'the choice was made against 2.4 µm, not the newer 2.5 µm',
    );
    await t.tap(find.byKey(const Key('import.open.1')));
    await _settle(t);
    await t.tap(find.text('Save Changes'));
    await _settle(t);
    expect((await app.rig(t)).pixelPitchUm, 2.5);

    // An explicit choice made now does replace it.
    await t.tap(take);
    await _settle(t);
    await t.tap(find.byKey(const Key('import.open.1')));
    await _settle(t);
    await t.tap(find.text('Save Changes'));
    await _settle(t);
    expect((await app.rig(t)).pixelPitchUm, 2.414);
  });

  testWidgets('a rig deleted elsewhere is no longer offered by the review', (
    t,
  ) async {
    final app = await _start(t);
    await t.runAsync(() => app.repo.deleteEquipment(1));

    await t.tap(find.byKey(const Key('import.open.1')));
    await _settle(t);

    expect(find.text('Edit rig'), findsNothing);
    expect(find.text('No saved rig has this camera.'), findsOneWidget);
    expect(find.byKey(const Key('import.open.1')), findsNothing);
    expect(await t.runAsync(() => app.repo.getAllEquipment()), isEmpty);
  });
}
