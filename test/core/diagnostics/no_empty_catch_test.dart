// TASK 15.1 acceptance: no empty catch blocks remain. The `empty_catches`
// lint (analysis_options.yaml) allows `catch (_) {}` and a comment-only
// body; this test does not — a caught error is handled, logged (AppLog) or
// rethrown.

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// A `catch (...)` or `on Type` clause followed by a body holding nothing
/// but whitespace and `//` comments.
final _emptyCatch = RegExp(
  r'(catch\s*\([^)]*\)|\bon\s+[A-Z]\w*(<[^>]*>)?)\s*\{(\s|//[^\n]*\n)*\}',
);

void main() {
  test('the pattern recognises empty and comment-only catches', () {
    expect(_emptyCatch.hasMatch('try {} catch (_) {}'), isTrue);
    expect(_emptyCatch.hasMatch('} on FormatException {\n  // x\n}'), isTrue);
    expect(_emptyCatch.hasMatch('} catch (e) {\n  log(e);\n}'), isFalse);
  });

  test('no empty catch block in lib', () {
    final offenders = [
      for (final f in Directory('lib').listSync(recursive: true))
        if (f is File &&
            f.path.endsWith('.dart') &&
            !f.path.endsWith('.g.dart'))
          for (final m in _emptyCatch.allMatches(f.readAsStringSync()))
            '${f.path}: ${m.group(0)}',
    ];
    expect(offenders, isEmpty);
  });
}
