// S5.3 (RD-14, ADR-019 §10): the retired terms stay out of the words shown
// to users. The test scans the string literals of lib/presentation (imports,
// `Key`/`ValueKey` values, comments and code identifiers are exempt) and
// compares what it finds with an explicit baseline of the occurrences left
// at 38925dd. A new occurrence fails; so does a baseline entry that no
// longer occurs, so the baseline only shrinks. Stages 6, 8 and 9 remove the
// entries as they redesign the screens, and P9.2 empties it. The scanner
// reads one line at a time: a term split across two literals is not seen.

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// The retired terms (ADR-019 §10), matched case-insensitively from a word
/// start, so plurals count too.
const retiredTerms = [
  'Equipment profile',
  'Session planner',
  'Draft',
  'Legacy',
  'True Night Window',
  'Astro Dusk',
  'Astro Dawn',
  'Window load',
  'Acquisition',
  'Session budget',
];

/// What is left, per file and term: `path|term` → count. Remove an entry
/// (or lower its count) when its screen stops using the term; never add one.
const baseline = {
  'lib/presentation/screens/equipment/equipment_selection_screen.dart|Equipment profile':
      1,
  'lib/presentation/screens/logbook/logbook_screen.dart|Legacy': 2,
  'lib/presentation/screens/logbook/logbook_screen.dart|Draft': 1,
  'lib/presentation/screens/logbook/session_detail_screen.dart|Legacy': 1,
  'lib/presentation/screens/logbook/session_detail_screen.dart|Window load': 1,
  'lib/presentation/screens/logbook/session_detail_screen.dart|Session budget':
      1,
};

final _literal = RegExp(r'''('(?:[^'\\]|\\.)*'|"(?:[^"\\]|\\.)*")''');
final _directive = RegExp(r'^(import|export|part)\b');
final _keyBefore = RegExp(r'\b(Key|ValueKey)\(\s*$');

/// The retired terms in [source]'s string literals: term → count.
Map<String, int> scanSource(String source) {
  final found = <String, int>{};
  for (final line in source.split('\n')) {
    final trimmed = line.trimLeft();
    if (trimmed.startsWith('//') || _directive.hasMatch(trimmed)) continue;
    for (final m in _literal.allMatches(line)) {
      if (_keyBefore.hasMatch(line.substring(0, m.start))) continue;
      final text = m.group(0)!.toLowerCase();
      for (final term in retiredTerms) {
        final n = RegExp(r'\b' + RegExp.escape(term.toLowerCase()))
            .allMatches(text)
            .length;
        if (n > 0) found[term] = (found[term] ?? 0) + n;
      }
    }
  }
  return found;
}

/// Every difference between [actual] and [expected] (`path|term` → count).
List<String> baselineProblems(
  Map<String, int> actual,
  Map<String, int> expected,
) => [
  for (final e in actual.entries)
    if (e.value > (expected[e.key] ?? 0))
      'new retired term: ${e.key} (${e.value}, baseline '
          '${expected[e.key] ?? 0}); use the glossary word (AppWords)',
  for (final e in expected.entries)
    if ((actual[e.key] ?? 0) < e.value)
      'stale baseline entry: ${e.key} (${actual[e.key] ?? 0} left, '
          'baseline ${e.value}); lower or remove it',
];

Map<String, int> _scanPresentation() {
  final found = <String, int>{};
  final files = Directory('lib/presentation')
      .listSync(recursive: true)
      .whereType<File>()
      .where((f) => f.path.endsWith('.dart'));
  for (final f in files) {
    final path = f.path.replaceAll(r'\', '/');
    scanSource(f.readAsStringSync()).forEach((term, n) {
      found['$path|$term'] = n;
    });
  }
  return found;
}

void main() {
  test('lib/presentation holds no retired term beyond the baseline, and '
      'the baseline holds nothing that is gone', () {
    expect(baselineProblems(_scanPresentation(), baseline), isEmpty);
  });

  group('the scanner', () {
    test('finds a term in a literal, in any case and in the plural', () {
      expect(scanSource("title: Text('Session budget'),"), {
        'Session budget': 1,
      });
      expect(scanSource('Text("No equipment profiles found.")'), {
        'Equipment profile': 1,
      });
      expect(scanSource("'draft' + 'Legacy log'"), {'Draft': 1, 'Legacy': 1});
    });

    test('ignores comments, imports, keys and code identifiers', () {
      expect(scanSource('// the Draft is internal'), isEmpty);
      expect(scanSource("import '../shared/equipment_draft.dart';"), isEmpty);
      expect(scanSource("key: Key('logbook.legacy.1'),"), isEmpty);
      expect(scanSource("key: ValueKey('draft'),"), isEmpty);
      expect(scanSource('final isDraft = session.legacy;'), isEmpty);
    });
  });

  group('the baseline check', () {
    test('fails on an added term', () {
      final problems = baselineProblems(
        {'a.dart|Draft': 1, 'b.dart|Legacy': 1},
        {'a.dart|Draft': 1},
      );
      expect(problems, hasLength(1));
      expect(problems.single, startsWith('new retired term: b.dart|Legacy'));
    });

    test('fails on a stale entry, so the baseline only shrinks', () {
      final problems = baselineProblems(
        {'a.dart|Draft': 1},
        {'a.dart|Draft': 2, 'b.dart|Legacy': 1},
      );
      expect(problems, hasLength(2));
      expect(problems, everyElement(startsWith('stale baseline entry')));
    });

    test('passes when they match', () {
      expect(baselineProblems(baseline, baseline), isEmpty);
    });
  });
}
