// Encoding check for AstroPlan's quality gate (roadmap TASK 4.3, TD-015).
//
// Every `.dart` file under lib/ and test/ must be valid UTF-8. That alone
// would not have caught TD-015's actual mojibake ("Вµm", "В°", box-drawing
// comments): those bytes are themselves valid UTF-8 — they are UTF-8 text
// that was misread as a single-byte codepage (Windows-1251/1252), then
// re-saved as UTF-8, so the *decoded* text is wrong, not malformed. That
// garbage lands in the Cyrillic block (U+0400-U+04FF). This codebase is
// English-only astrophotography UI text with no legitimate use for
// Cyrillic, so its presence is a reliable, low-noise signal.
//
// Usage: dart run tool/check_encoding.dart

import 'dart:convert';
import 'dart:io';

Future<void> main() async {
  final offenders = <String>[];

  for (final dirName in ['lib', 'test']) {
    final dir = Directory(dirName);
    if (!dir.existsSync()) continue;

    await for (final entity in dir.list(recursive: true)) {
      if (entity is! File || !entity.path.endsWith('.dart')) continue;

      final bytes = await entity.readAsBytes();
      String content;
      try {
        content = utf8.decode(bytes, allowMalformed: false);
      } on FormatException {
        offenders.add('${entity.path}: not valid UTF-8');
        continue;
      }

      for (var i = 0; i < content.length; i++) {
        final code = content.codeUnitAt(i);
        if (code >= 0x0400 && code <= 0x04FF) {
          final line = '\n'.allMatches(content.substring(0, i)).length + 1;
          final hex = code.toRadixString(16).padLeft(4, '0');
          offenders.add(
            '${entity.path}:$line: unexpected Cyrillic character '
            '(likely mojibake): U+$hex',
          );
          break; // one report per file is enough to point someone at it
        }
      }
    }
  }

  if (offenders.isNotEmpty) {
    stderr.writeln('Encoding check failed:');
    for (final offender in offenders) {
      stderr.writeln('  $offender');
    }
    exit(1);
  }

  stdout.writeln('Encoding check passed: no mojibake found.');
}
