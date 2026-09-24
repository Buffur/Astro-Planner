import 'package:astroplan/core/diagnostics/app_log.dart';
import 'package:astroplan/domain/repositories/storage_failure.dart';
import 'package:astroplan/presentation/shared/failure_feedback.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  setUp(AppLog.clear);

  test('a storage failure is worded for the user, without its cause', () {
    final text = FailureText.message(
      'save the rig',
      const StorageFailure('write to the database', 'SqliteException(13)'),
    );
    expect(text, startsWith("Couldn't save the rig"));
    expect(text, contains('data on this device'));
    expect(text, isNot(contains('Sqlite')));
    expect(
      FailureText.message('save the rig', StateError('x')),
      "Couldn't save the rig. Please try again.",
    );
  });

  Future<BuildContext> pumpHost(WidgetTester tester) async {
    late BuildContext context;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (c) {
              context = c;
              return const SizedBox();
            },
          ),
        ),
      ),
    );
    return context;
  }

  testWidgets('runWithFeedback shows and logs a failure', (tester) async {
    final context = await pumpHost(tester);
    final ok = await runWithFeedback(
      context,
      'delete the site',
      () async => throw const StorageFailure('write to the database'),
    );
    await tester.pump();
    expect(ok, isFalse);
    expect(find.textContaining("Couldn't delete the site"), findsOneWidget);
    expect(AppLog.recent.single.level, LogLevel.error);
  });

  testWidgets('runWithFeedback is silent on success', (tester) async {
    final context = await pumpHost(tester);
    final ok = await runWithFeedback(context, 'save', () async {});
    await tester.pump();
    expect(ok, isTrue);
    expect(find.byType(SnackBar), findsNothing);
    expect(AppLog.recent, isEmpty);
  });

  testWidgets('LoadFailureView says what failed and retries', (tester) async {
    var retried = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: LoadFailureView(
            action: 'load the sessions',
            error: const StorageFailure('read the database'),
            onRetry: () => retried++,
          ),
        ),
      ),
    );
    expect(find.textContaining("Couldn't load the sessions"), findsOneWidget);
    await tester.tap(find.text('Retry'));
    expect(retried, 1);
  });
}
