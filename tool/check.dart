// AstroPlan quality gate: encoding, format, analyze, test — the same steps a
// human is asked to run before calling a change complete, run by one
// command so CI can enforce them too (roadmap TASK 1.3, TD-046; encoding
// added TASK 4.3, TD-015).
//
// Usage:
//   dart run tool/check.dart
//
// Runs the encoding check (tool/check_encoding.dart), `dart format`,
// `flutter analyze` and `flutter test` (all --no-pub, scoped to lib/ and
// test/), then the end-to-end suite in integration_test/ on the host test
// device, one run per file (TASK 15.5, S10.2; on an emulator run `flutter
// test integration_test -d <device>`), and reports a summary. All steps run regardless of earlier
// failures, so one pass shows every problem; the process exits non-zero if
// any step failed.
//
// Out of scope (see docs/MASTER_ROADMAP.md TASK 1.3): stricter lints
// (TD-038) and device runs.

import 'dart:io';

Future<void> main() async {
  final steps = [
    _Step('Encoding', 'dart', ['run', 'tool/check_encoding.dart']),
    _Step('Format', 'dart', [
      'format',
      '--output=none',
      '--set-exit-if-changed',
      'lib',
      'test',
      'integration_test',
    ]),
    _Step('Analyze', 'flutter', ['analyze', '--no-pub']),
    _Step('Test', 'flutter', ['test', '--no-pub']),
    // One run per file (S10.2): with two files in one run, flutter-tester
    // fails to start the second app ("The log reader failed unexpectedly").
    for (final file in _integrationTests())
      _Step('E2E (host): ${file.split('/').last}', 'flutter', [
        'test',
        '--no-pub',
        file,
        '-d',
        'flutter-tester',
      ]),
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

/// The end-to-end test files, in a stable order.
List<String> _integrationTests() => [
  for (final f in Directory('integration_test').listSync())
    if (f is File && f.path.endsWith('_test.dart'))
      f.path.replaceAll(Platform.pathSeparator, '/'),
]..sort();

class _Step {
  const _Step(this.name, this.executable, this.args);

  final String name;
  final String executable;
  final List<String> args;
}
