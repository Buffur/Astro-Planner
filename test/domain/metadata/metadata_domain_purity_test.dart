// S2.1 (ADR-017 §4): file I/O, platform code and parsing packages stay out of
// the domain. S2.5 removed the prototype extractor, the one exception.

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

const _forbidden = [
  'dart:io',
  'dart:ffi',
  'package:flutter/services.dart',
  'package:exif/',
  'package:image_picker/',
  'package:file_picker/',
];

/// The forbidden imports in [source].
List<String> forbiddenImports(String source) => [
  for (final line in source.split('\n'))
    if (RegExp(r'''^\s*(import|export)\s+['"]''').hasMatch(line))
      for (final f in _forbidden)
        if (line.contains("'$f") || line.contains('"$f')) f,
];

void main() {
  test('the check catches a domain dart:io import', () {
    expect(forbiddenImports("import 'dart:io';\n"), ['dart:io']);
    expect(forbiddenImports('import "package:exif/exif.dart";'), [
      'package:exif/',
    ]);
    expect(forbiddenImports("import 'dart:typed_data';"), isEmpty);
    expect(forbiddenImports("// see 'dart:io' in the data layer"), isEmpty);
  });

  test('no file I/O, platform or parsing package in lib/domain', () {
    final offenders = {
      for (final f in Directory('lib/domain').listSync(recursive: true))
        if (f is File && f.path.endsWith('.dart'))
          f.path.replaceAll(r'\', '/'): forbiddenImports(f.readAsStringSync()),
    }..removeWhere((_, found) => found.isEmpty);
    expect(offenders, isEmpty);
  });
}
