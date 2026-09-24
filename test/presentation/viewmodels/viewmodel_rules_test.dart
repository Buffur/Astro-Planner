// Architecture rules for the screen-scoped ViewModels (TASK 12.3,
// TD-019/TD-021): they see domain interfaces only — no HTTP,
// SharedPreferences, Drift, Geolocator or data-layer imports (main.dart
// picks the implementations) — and each stays small.

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  final files = Directory('lib/presentation/viewmodels')
      .listSync(recursive: true)
      .whereType<File>()
      .where((f) => f.path.endsWith('.dart'))
      .toList();

  test('the ViewModels directory is not empty', () {
    expect(files, isNotEmpty);
  });

  test('no ViewModel imports an I/O package or the data layer', () {
    const banned = [
      'package:http/',
      'package:shared_preferences/',
      'package:drift/',
      'package:geolocator/',
      '/data/',
    ];
    final offenders = [
      for (final f in files)
        for (final line in f.readAsLinesSync())
          if (line.startsWith('import ') && banned.any(line.contains))
            '${f.path}: $line',
    ];
    expect(offenders, isEmpty);
  });

  test('no ViewModel is over about 250 lines of code', () {
    // Code lines exclude comments and blank lines; the roadmap's "about
    // 250" also allows for documentation, capped at 300 physical lines.
    final offenders = [
      for (final f in files)
        if (f.readAsLinesSync() case final lines
            when lines.length > 300 ||
                lines.where((l) {
                      final t = l.trim();
                      return t.isNotEmpty && !t.startsWith('//');
                    }).length >
                    250)
          f.path,
    ];
    expect(offenders, isEmpty);
  });

  test('the planner god-object is gone', () {
    expect(
      File('lib/presentation/viewmodels/planner_viewmodel.dart').existsSync(),
      isFalse,
    );
  });
}
