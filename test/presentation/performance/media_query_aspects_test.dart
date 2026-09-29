// S10.3 (Stage 10; 08 §22): `MediaQuery.of(context)` makes a widget depend
// on every MediaQuery field, the keyboard's inset included, so it rebuilds
// on every frame of the keyboard animation. The rig editor's form did (the
// owner's typing lag). Read one aspect instead: `MediaQuery.sizeOf`,
// `paddingOf`, `viewInsetsOf`, `textScalerOf` and so on.

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('lib/ reads MediaQuery by aspect, never MediaQuery.of', () {
    final offenders = [
      for (final f in Directory('lib').listSync(recursive: true))
        if (f is File && f.path.endsWith('.dart'))
          for (final (i, line) in f.readAsLinesSync().indexed)
            if (line.contains('MediaQuery.of(')) '${f.path}:${i + 1}',
    ];
    expect(offenders, isEmpty);
  });
}
