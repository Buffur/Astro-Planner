// S3.6 (ADR-018 §2, §6): the import review. A picked file proposes a rig,
// matched against the saved rigs; every action opens the rig editor, and
// only its Save writes. Keeping a saved value is the default. Synthetic
// files and rigs only.

import 'dart:typed_data';

import 'package:astroplan/core/theme/app_theme.dart';
import 'package:astroplan/domain/models/equipment_profile.dart';
import 'package:astroplan/domain/models/spec_confidence.dart';
import 'package:astroplan/domain/models/spec_provenance.dart';
import 'package:astroplan/presentation/screens/metadata/metadata_import_screen.dart';
import 'package:astroplan/presentation/viewmodels/library_viewmodels.dart';
import 'package:astroplan/presentation/viewmodels/metadata_import_viewmodel.dart';
import 'package:astroplan/presentation/viewmodels/session_plan_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import '../../../support/fake_capture_file_access.dart';
import '../../../support/in_memory_equipment_repository.dart';
import '../../../support/jpeg_fixture.dart';
import '../../../support/tiff_fixture.dart';

class _Planner extends ChangeNotifier implements SessionPlanViewModel {
  int refreshes = 0;

  @override
  Future<void> refreshSelectedEquipment() async => refreshes++;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

/// A phone main camera's JPEG (neutral strings): f 6.57, f/1.6, f₃₅ 23,
/// 3072 × 4096 (portrait).
Uint8List _phoneJpeg() {
  final exif = phoneStyleJpegExif();
  exif.exif!.addAll([
    FixtureEntry.long(40962, 3072),
    FixtureEntry.long(40963, 4096),
  ]);
  return jpegFile([exifApp1(exif.build().bytes)]);
}

/// The saved rig for that camera, imported earlier, with verified camera
/// specs slightly different from the file's estimate.
EquipmentProfile _savedPhone({int id = 1, String name = 'My phone'}) =>
    EquipmentProfile(
      id: id,
      name: name,
      sensorWidthMm: 9.8,
      sensorHeightMm: 7.35,
      pixelPitchUm: 2.4,
      resolutionWidthPx: 4096,
      resolutionHeightPx: 3072,
      focalLengthMm: 6.57,
      focalRatio: 1.6,
      cameraSource: 'seed:test',
      cameraConfidence: SpecConfidence.verified,
      metadataMake: 'TestMake',
      metadataModel: 'TestMake TestPhone',
    );

class _Screen {
  _Screen(this.repo, this.files, this.planner);

  final InMemoryEquipmentRepository repo;
  final FakeCaptureFileAccess files;
  final _Planner planner;
}

Future<_Screen> _show(
  WidgetTester tester, {
  List<EquipmentProfile> rigs = const [],
  Uint8List? file,
}) async {
  final repo = InMemoryEquipmentRepository(rigs);
  final files = FakeCaptureFileAccess()..file('IMG.jpg', file ?? _phoneJpeg());
  final planner = _Planner();
  tester.view.physicalSize = const Size(800, 4000);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => GearViewModel(repo)),
        ChangeNotifierProvider<SessionPlanViewModel>.value(value: planner),
        ChangeNotifierProvider<MetadataImportViewModel?>(
          create: (_) => MetadataImportViewModel(files, repo),
        ),
      ],
      child: MaterialApp(
        theme: AppTheme.light,
        home: const MetadataImportScreen(),
      ),
    ),
  );
  await tester.tap(find.byKey(const Key('metadata.pick')));
  await tester.pumpAndSettle();
  return _Screen(repo, files, planner);
}

String _headline(WidgetTester tester) =>
    tester.widget<Text>(find.byKey(const Key('import.headline'))).data!;

/// Save in the editor: "Save" for a new rig, "Save Changes" for an edit.
Future<void> _save(WidgetTester tester, {bool edit = false}) async {
  await tester.tap(find.text('Save'));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('no saved rig: a new rig is created only through the editor\'s '
      'Save, and the file then matches it', (tester) async {
    final s = await _show(tester);
    expect(_headline(tester), 'No saved rig has this camera.');
    expect(s.repo.inserted, isEmpty, reason: 'reading writes nothing');

    await tester.tap(find.byKey(const Key('import.new')));
    await tester.pumpAndSettle();
    expect(find.text('Add rig'), findsOneWidget);
    expect(find.widgetWithText(TextFormField, '6.57'), findsOneWidget);
    await _save(tester);

    final rig = s.repo.inserted.single;
    expect(rig.metadataModel, 'TestMake TestPhone');
    expect(
      rig.specProvenance[EquipmentSpec.focalLength],
      const SpecProvenance('metadata:jpeg', SpecConfidence.reported),
    );
    expect(_headline(tester), startsWith('You already have this rig'));
  });

  testWidgets('Cancel in the editor writes nothing', (tester) async {
    final s = await _show(tester);
    await tester.tap(find.byKey(const Key('import.new')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(s.repo.inserted, isEmpty);
    expect(_headline(tester), 'No saved rig has this camera.');
  });

  testWidgets('same rig: differences are listed and kept by default; the '
      'verified values survive an Open and Save', (tester) async {
    final s = await _show(tester, rigs: [_savedPhone()]);
    expect(_headline(tester), 'You already have this rig: "My phone".');
    final take = find.byKey(const Key('import.take.1.pixelPitch'));
    expect(tester.widget<SwitchListTile>(take).value, isFalse);
    expect(find.textContaining('Saved: 2.4 µm (verified'), findsOneWidget);

    await tester.tap(find.byKey(const Key('import.open.1')));
    await tester.pumpAndSettle();
    expect(find.text('Edit rig'), findsOneWidget);
    await _save(tester, edit: true);

    final saved = s.repo.updated.single;
    expect(saved.pixelPitchUm, 2.4);
    expect(
      saved.provenanceOf(EquipmentSpec.pixelPitch)?.confidence,
      SpecConfidence.verified,
    );
    expect(s.planner.refreshes, 1, reason: 'the planner rereads the rig');
    expect(s.repo.inserted, isEmpty, reason: 'no duplicate');
  });

  testWidgets('taking the file\'s value is an explicit, per-field choice; it '
      'arrives in the editor with its origin', (tester) async {
    final s = await _show(tester, rigs: [_savedPhone()]);
    await tester.tap(find.byKey(const Key('import.take.1.pixelPitch')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('import.open.1')));
    await tester.pumpAndSettle();
    expect(find.widgetWithText(TextFormField, '2.414'), findsWidgets);
    expect(
      find.text('Estimated from the 35 mm equivalent — check it'),
      findsOneWidget,
    );
    await _save(tester, edit: true);

    final saved = s.repo.updated.single;
    expect(saved.pixelPitchUm, 2.414);
    expect(
      saved.provenanceOf(EquipmentSpec.pixelPitch)?.confidence,
      SpecConfidence.estimated,
    );
    // The sensor size was not taken: it keeps its exact verified value.
    expect(saved.sensorWidthMm, 9.8);
    expect(
      saved.provenanceOf(EquipmentSpec.sensorSize)?.confidence,
      SpecConfidence.verified,
    );
  });

  testWidgets('another module of the same camera: a new rig can take the '
      'saved camera specs', (tester) async {
    final other = EquipmentProfile(
      id: 1,
      name: 'Phone tele',
      sensorWidthMm: 5.07,
      sensorHeightMm: 3.81,
      pixelPitchUm: 1.25,
      resolutionWidthPx: 4064,
      resolutionHeightPx: 3056,
      focalLengthMm: 8.8,
      focalRatio: 2,
      metadataMake: 'TestMake',
      metadataModel: 'TestMake TestPhone',
    );
    final s = await _show(tester, rigs: [other]);
    expect(_headline(tester), startsWith('Same camera as "Phone tele"'));
    await tester.tap(find.byKey(const Key('import.newFrom.1')));
    await tester.pumpAndSettle();
    // The file gives resolution and an estimate itself; the saved rig only
    // fills what the file lacks, so the file's values are shown.
    expect(find.widgetWithText(TextFormField, '6.57'), findsOneWidget);
    await _save(tester);
    expect(s.repo.inserted.single.focalLengthMm, 6.57);
  });

  testWidgets('two identical saved bodies: ambiguous, nothing chosen', (
    tester,
  ) async {
    final s = await _show(
      tester,
      rigs: [
        _savedPhone(id: 1, name: 'Phone A'),
        _savedPhone(id: 2, name: 'Phone B'),
      ],
    );
    expect(_headline(tester), startsWith('Several saved rigs match'));
    expect(find.byKey(const Key('import.open.1')), findsOneWidget);
    expect(find.byKey(const Key('import.open.2')), findsOneWidget);
    expect(s.repo.updated, isEmpty);
  });

  testWidgets('a file with no camera and no optics proposes nothing', (
    tester,
  ) async {
    final bare =
        (TiffFixture()
              ..ifd0.addAll([
                FixtureEntry.bytes(50706, [1, 4, 0, 0]),
                FixtureEntry.rational(33434, 30, 1),
              ]))
            .build()
            .bytes;
    await _show(tester, file: bare);
    expect(_headline(tester), startsWith('This file names no camera'));
    expect(find.byKey(const Key('import.new')), findsNothing);
  });

  group('S3.8: the RAW size of a DNG (ADR-018 §4, D4)', () {
    // The phone-style DNG fixture: f 8.8, f/2, f35 60, 4000 x 3000, and a
    // model with a code suffix. 25 MiB long.
    Uint8List dng() =>
        (TiffFixture()..ifd0.addAll(phoneStyleDngIfd0())).build().bytes;
    EquipmentProfile tele({double? raw}) => EquipmentProfile(
      id: 1,
      name: 'Phone tele',
      sensorWidthMm: 5.08,
      sensorHeightMm: 3.81,
      pixelPitchUm: 1.27,
      resolutionWidthPx: 4000,
      resolutionHeightPx: 3000,
      focalLengthMm: 8.8,
      focalRatio: 2,
      averageRawFileSizeMB: raw,
      metadataMake: 'TestMake',
      metadataModel: 'TestMake TestPhone/TEST0001',
    );

    Future<_Screen> showDng(WidgetTester tester, EquipmentProfile rig) async {
      final repo = InMemoryEquipmentRepository([rig]);
      final files = FakeCaptureFileAccess()
        ..file('IMG.dng', dng(), length: 25 << 20);
      final planner = _Planner();
      tester.view.physicalSize = const Size(800, 4000);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => GearViewModel(repo)),
            ChangeNotifierProvider<SessionPlanViewModel>.value(value: planner),
            ChangeNotifierProvider<MetadataImportViewModel?>(
              create: (_) => MetadataImportViewModel(files, repo),
            ),
          ],
          child: MaterialApp(
            theme: AppTheme.light,
            home: const MetadataImportScreen(),
          ),
        ),
      );
      await tester.tap(find.byKey(const Key('metadata.pick')));
      await tester.pumpAndSettle();
      return _Screen(repo, files, planner);
    }

    testWidgets('an unknown RAW size is offered, and saved as an estimate '
        'from one file only through Save', (tester) async {
      final s = await showDng(tester, tele());
      expect(_headline(tester), startsWith('You already have this rig'));
      expect(
        find.byKey(const Key('import.fill.1.rawFileSize')),
        findsOneWidget,
      );
      expect(find.textContaining('26.2 MB'), findsOneWidget);
      await tester.tap(find.byKey(const Key('import.open.1')));
      await tester.pumpAndSettle();
      expect(find.widgetWithText(TextFormField, '26.2'), findsOneWidget);
      await _save(tester, edit: true);

      final saved = s.repo.updated.single;
      expect(saved.averageRawFileSizeMB, 26.2);
      expect(
        saved.provenanceOf(EquipmentSpec.rawFileSize),
        const SpecProvenance(
          'metadata:dng:file-size',
          SpecConfidence.estimated,
        ),
      );
    });

    testWidgets('a saved RAW size is kept unless its switch is turned on', (
      tester,
    ) async {
      final s = await showDng(tester, tele(raw: 30));
      expect(find.byKey(const Key('import.fill.1.rawFileSize')), findsNothing);
      final take = find.byKey(const Key('import.take.1.rawFileSize'));
      expect(tester.widget<SwitchListTile>(take).value, isFalse);
      await tester.tap(find.byKey(const Key('import.open.1')));
      await tester.pumpAndSettle();
      await _save(tester, edit: true);
      expect(s.repo.updated.single.averageRawFileSizeMB, 30);
    });

    testWidgets('a JPEG never offers a RAW size', (tester) async {
      await _show(tester, rigs: [_savedPhone()]);
      expect(find.byKey(const Key('import.fill.1.rawFileSize')), findsNothing);
      expect(find.byKey(const Key('import.take.1.rawFileSize')), findsNothing);
    });
  });
}
