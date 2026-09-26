// S2.5 (F-45; ADR-017 §10): the hidden metadata screen on the new
// foundation. Success, unsupported, unreadable, cancelled, a picker failure
// and a time without a zone, with synthetic files only.

import 'dart:typed_data';

import 'package:astroplan/core/theme/app_theme.dart';
import 'package:astroplan/domain/metadata/metadata_source.dart';
import 'package:astroplan/presentation/screens/metadata/metadata_import_screen.dart';
import 'package:astroplan/presentation/viewmodels/metadata_import_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import '../../../support/fake_capture_file_access.dart';
import '../../../support/in_memory_equipment_repository.dart';
import '../../../support/tiff_fixture.dart';

void main() {
  late FakeCaptureFileAccess files;
  late MetadataImportViewModel vm;

  Uint8List dng() =>
      (TiffFixture()..ifd0.addAll(phoneStyleDngIfd0())).build().bytes;

  Future<void> show(WidgetTester tester, {bool withVm = true}) async {
    files = FakeCaptureFileAccess();
    vm = MetadataImportViewModel(files, InMemoryEquipmentRepository());
    await tester.pumpWidget(
      ChangeNotifierProvider<MetadataImportViewModel?>.value(
        value: withVm ? vm : null,
        child: MaterialApp(
          theme: AppTheme.light,
          home: const MetadataImportScreen(),
        ),
      ),
    );
  }

  Future<void> pick(WidgetTester tester) async {
    await tester.tap(find.byKey(const Key('metadata.pick')));
    await tester.pumpAndSettle();
  }

  testWidgets('a DNG shows its values with units, sources and unknowns', (
    tester,
  ) async {
    await show(tester);
    files.file('capture.dng', dng(), length: 25 << 20);
    await pick(tester);

    expect(find.text('capture.dng'), findsOneWidget);
    expect(find.text('DNG'), findsOneWidget);
    expect(find.text('30 s'), findsOneWidget);
    expect(find.text('ISO 50 (standard not stated)'), findsOneWidget);
    expect(find.text('8.8 mm'), findsOneWidget);
    expect(
      find.text('60 mm (field of view, not the focal length)'),
      findsOneWidget,
    );
    expect(find.text('f/2'), findsOneWidget);
    expect(
      find.text('2000-01-02 21:30:05 (time zone not recorded)'),
      findsOneWidget,
    );
    expect(find.text('DNG · IFD0 · ExposureTime (33434)'), findsOneWidget);
    expect(find.text('Not in the file'), findsNWidgets(2)); // lens make, model
    expect(find.text('0 s'), findsNothing, reason: 'unknown is never zero');
  });

  testWidgets('the screen meets the tap-target and label guidelines at 200 %', (
    tester,
  ) async {
    tester.platformDispatcher.textScaleFactorTestValue = 2;
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    final semantics = tester.ensureSemantics();
    await show(tester);
    files.file('capture.dng', dng());
    await pick(tester);
    expect(tester.takeException(), isNull);
    await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
    await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
    await expectLater(tester, meetsGuideline(textContrastGuideline));
    semantics.dispose();
  });

  testWidgets('an unsupported format says so, and nothing else', (
    tester,
  ) async {
    await show(tester);
    files.file('light.fits', 'SIMPLE  =                    T'.codeUnits);
    await pick(tester);
    expect(
      find.text("This file's format (FITS) is not supported yet."),
      findsOneWidget,
    );
    expect(find.text('Exposure'), findsNothing);
  });

  testWidgets(
    'a truncated DNG and a file that cannot be opened are unreadable',
    (tester) async {
      await show(tester);
      files.file('cut.dng', Uint8List.sublistView(dng(), 0, 100));
      await pick(tester);
      expect(
        find.text('The file ends before its metadata does.'),
        findsOneWidget,
      );

      files.file(
        'gone.dng',
        dng(),
        openError: const MetadataReadException(MetadataReadError.io),
      );
      await pick(tester);
      expect(find.text('gone.dng'), findsOneWidget);
      expect(find.text('The file could not be read.'), findsOneWidget);
    },
  );

  testWidgets('a cancel changes nothing; a picker failure is reported', (
    tester,
  ) async {
    await show(tester);
    files.cancel();
    await pick(tester);
    expect(files.picks, 1);
    expect(find.byKey(const Key('metadata.result')), findsNothing);
    expect(vm.busy, isFalse);

    files.error(const MetadataReadException(MetadataReadError.io, 'busy'));
    await pick(tester);
    expect(find.byType(SnackBar), findsOneWidget);
    expect(find.byKey(const Key('metadata.result')), findsNothing);
    expect(vm.busy, isFalse);
  });

  testWidgets('without file access (off Android) it says it is unavailable', (
    tester,
  ) async {
    await show(tester, withVm: false);
    expect(
      find.text(
        'Reading capture-file metadata is not available on this device.',
      ),
      findsOneWidget,
    );
    expect(find.byKey(const Key('metadata.pick')), findsNothing);
  });
}
