// S5.9: rendered sheets of the design system for the owner's review. It is
// opt-in and stays outside the quality gate (skipped there, like the real
// metadata samples): set ASTROPLAN_RENDER_GALLERY to an output directory,
// for example docs/refinement/evidence/stage5, and run this file alone.
//
// Real fonts are loaded from the SDK (Roboto and the Material icons), so
// text reads as on Android rather than as the test font's blocks; a style
// that names no font family would still draw blocks (docs/refinement/
// evidence/STAGE_5_RENDERS.md). Field-mode images go through the app's red
// filter, as the user sees them. Host renders only: not device evidence.

import 'dart:io';
import 'dart:ui' as ui;

import 'package:astroplan/core/theme/app_theme.dart';
import 'package:astroplan/presentation/shared/confirmation_patterns.dart';
import 'package:astroplan/presentation/shared/delete_patterns.dart';
import 'package:astroplan/presentation/viewmodels/disclosure_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import '../../support/in_memory_display_preferences.dart';
import 'gallery_entries.dart';
import 'gallery_harness.dart';

const _variable = 'ASTROPLAN_RENDER_GALLERY';
const _shot = Key('render');

/// Loads Roboto and the Material icons from the SDK that runs the test.
Future<void> _loadFonts() async {
  final root =
      Platform.environment['FLUTTER_ROOT'] ??
      Platform.resolvedExecutable.substring(
        0,
        Platform.resolvedExecutable.indexOf(
          '${Platform.pathSeparator}bin${Platform.pathSeparator}cache',
        ),
      );
  final dir = [
    root,
    'bin',
    'cache',
    'artifacts',
    'material_fonts',
  ].join(Platform.pathSeparator);
  Future<ByteData> read(String f) =>
      File('$dir${Platform.pathSeparator}$f')
          .readAsBytes()
          .then((b) => ByteData.sublistView(b));
  final roboto = FontLoader('Roboto');
  for (final f in [
    'roboto-regular.ttf',
    'roboto-medium.ttf',
    'roboto-bold.ttf',
  ]) {
    roboto.addFont(read(f));
  }
  await roboto.load();
  await (FontLoader(
    'MaterialIcons',
  )..addFont(read('materialicons-regular.otf'))).load();
}

/// The app's look around [child]: the theme and the section store (the
/// callers add field mode's red filter).
Widget _app(GalleryTheme theme, Widget child) {
  return ChangeNotifierProvider(
    create: (_) => DisclosureViewModel(InMemoryDisplayPreferences()),
    child: MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: galleryThemeData(theme),
      home: child,
    ),
  );
}

Future<void> _write(WidgetTester tester, String path) async {
  final boundary = tester.renderObject<RenderRepaintBoundary>(
    find.byKey(_shot),
  );
  await tester.runAsync(() async {
    final image = await boundary.toImage();
    final png = await image.toByteData(format: ui.ImageByteFormat.png);
    image.dispose();
    await File(path).writeAsBytes(png!.buffer.asUint8List());
  });
}

/// The whole gallery as one tall sheet, cropped to its content.
Future<void> _sheet(
  WidgetTester tester,
  GalleryTheme theme,
  double scale,
  String path,
) async {
  await tester.pumpWidget(const SizedBox()); // no route or dialog left over
  tester.view.physicalSize = const Size(412, 20000);
  tester.platformDispatcher.textScaleFactorTestValue = scale;
  final t = galleryThemeData(theme);
  Widget content = ColoredBox(
    color: t.scaffoldBackgroundColor,
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: galleryEntries(),
      ),
    ),
  );
  if (theme == GalleryTheme.field) {
    content = ColorFiltered(colorFilter: AppTheme.fieldFilter, child: content);
  }
  await tester.pumpWidget(
    _app(
      theme,
      Scaffold(
        body: SingleChildScrollView(
          child: RepaintBoundary(key: _shot, child: content),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
  await _write(tester, path);
}

/// A phone screen (412 × 915) showing the sample detail page, optionally
/// with an overlay opened on it.
Future<void> _screen(
  WidgetTester tester,
  GalleryTheme theme,
  String path, {
  void Function(BuildContext context)? overlay,
}) async {
  await tester.pumpWidget(const SizedBox()); // no route or dialog left over
  tester.view.physicalSize = const Size(412, 915);
  tester.platformDispatcher.textScaleFactorTestValue = 1;
  Widget app = _app(theme, galleryDetailPage());
  if (theme == GalleryTheme.field) {
    app = ColorFiltered(colorFilter: AppTheme.fieldFilter, child: app);
  }
  await tester.pumpWidget(RepaintBoundary(key: _shot, child: app));
  await tester.pumpAndSettle();
  if (overlay != null) {
    overlay(tester.element(find.byType(ListView)));
    await tester.pumpAndSettle();
  }
  await _write(tester, path);
}

void main() {
  final out = Platform.environment[_variable];

  testWidgets('render the design system for review', (tester) async {
    await tester.runAsync(_loadFonts);
    Directory(out!).createSync(recursive: true);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    addTearDown(tester.platformDispatcher.clearAllTestValues);
    String file(String name) => '$out${Platform.pathSeparator}$name.png';

    for (final theme in GalleryTheme.values) {
      for (final scale in [1.0, 2.0]) {
        await _sheet(
          tester,
          theme,
          scale,
          file('gallery_${theme.name}_${(scale * 100).round()}'),
        );
      }
      await _screen(tester, theme, file('detail_${theme.name}'));
      await _screen(
        tester,
        theme,
        file('confirm_${theme.name}'),
        overlay: (c) => confirmDestructive(
          c,
          title: 'Delete rig "Refractor 400"?',
          message: 'Plans that use it keep their saved values.',
        ),
      );
      await _screen(
        tester,
        theme,
        file('undo_${theme.name}'),
        overlay: (c) => showUndo(c, message: 'Block deleted', onUndo: () {}),
      );
      await tester.pumpWidget(const SizedBox());
    }
  }, skip: out == null);
}
