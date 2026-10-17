// The Material fonts bundled with the Flutter SDK that runs the test
// (`bin/cache/artifacts/material_fonts`), for tests that need real glyph
// widths instead of the test font's full-em boxes.
//
// S12.1 (TD-104): the file names' case differs by platform for the same SDK
// version: Windows ships `roboto-regular.ttf`, Linux `Roboto-Regular.ttf`.
// Windows file names are case-insensitive and Linux's are not, so a fixed
// spelling found the file on one platform only (CI runs on Linux). Files are
// found by a case-insensitive comparison instead.

import 'dart:io';

/// The SDK's `material_fonts` directory.
Directory sdkMaterialFontsDirectory() {
  final root =
      Platform.environment['FLUTTER_ROOT'] ??
      Platform.resolvedExecutable.substring(
        0,
        Platform.resolvedExecutable.indexOf(
          '${Platform.pathSeparator}bin${Platform.pathSeparator}cache',
        ),
      );
  return Directory(
    [
      root,
      'bin',
      'cache',
      'artifacts',
      'material_fonts',
    ].join(Platform.pathSeparator),
  );
}

/// The font file named [name] in [sdkMaterialFontsDirectory], whatever the
/// case of its name on this platform; null when the SDK has no such file.
File? sdkMaterialFont(String name) {
  final dir = sdkMaterialFontsDirectory();
  if (!dir.existsSync()) return null;
  final wanted = name.toLowerCase();
  for (final entity in dir.listSync()) {
    if (entity is File &&
        entity.uri.pathSegments.last.toLowerCase() == wanted) {
      return entity;
    }
  }
  return null;
}
