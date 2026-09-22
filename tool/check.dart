// AstroPlan quality gate: format, analyze, test — the same three steps a
// human is asked to run before calling a change complete, run by one
// command so CI can enforce them too (roadmap TASK 1.3, TD-046).
//
// Usage:
//   dart run tool/check.dart
//
// Runs `dart format`, `flutter analyze` and `flutter test` (all --no-pub,
// scoped to lib/ and test/) and reports a summary. All three run regardless
// of earlier failures, so one pass shows every problem; the process exits
// non-zero if any step failed.
//
// Out of scope (see docs/MASTER_ROADMAP.md TASK 1.3): stricter lints
// (TD-038) and device tests.

import 'dart:io';

Future<void> main() async {
  final steps = [
    _Step('Format', 'dart', [
      'format',
      '--output=none',
      '--set-exit-if-changed',
      'lib',
      'test',
    ]),
    _Step('Analyze', 'flutter', ['analyze', '--no-pub']),
    _Step('Test', 'flutter', ['test', '--no-pub']),
  ];

  final results = <_Step, bool>{};
  for (final step in steps) {
    stdout.writeln(
      '\n=== ${step.name}: ${step.executable} ${step.args.join(' ')} ===',
    );
    final process = await Process.start(
      step.executable,
      step.args,
      runInShell: true,
    );
    process.stdout
        .transform(const SystemEncoding().decoder)
        .listen(stdout.write);
    process.stderr
        .transform(const SystemEncoding().decoder)
        .listen(stderr.write);
    final exitCode = await process.exitCode;
    results[step] = exitCode == 0;
  }

  stdout.writeln('\n=== Summary ===');
  var allPassed = true;
  for (final step in steps) {
    final passed = results[step]!;
    allPassed &= passed;
    stdout.writeln('${passed ? 'PASS' : 'FAIL'}  ${step.name}');
  }

  if (!allPassed) {
    stderr.writeln('\nQuality gate FAILED.');
    exit(1);
  }
  stdout.writeln('\nQuality gate passed.');
}

class _Step {
  const _Step(this.name, this.executable, this.args);

  final String name;
  final String executable;
  final List<String> args;
}
