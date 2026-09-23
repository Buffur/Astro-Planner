// Widget tests for LogbookScreen (roadmap TASK 4.2, TD-039; on sessions
// since TASK 11.3).
//
// Delete requires confirmation; the list shows every saved (non-draft)
// session and the legacy logs, each with its status (owner decision, TASK
// 11.3). Ordering is a repository concern (drift_session_repository_test).

import 'package:astroplan/data/database/app_database.dart';
import 'package:astroplan/data/repositories/drift_session_repository.dart';
import 'package:astroplan/domain/repositories/session_repository.dart';
import 'package:astroplan/presentation/screens/logbook/logbook_screen.dart';
import 'package:astroplan/presentation/viewmodels/planner_viewmodel.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:astroplan/presentation/viewmodels/library_viewmodels.dart';

class _MockPlannerViewModel extends ChangeNotifier implements PlannerViewModel {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  late AppDatabase db;
  late DriftSessionRepository repo;

  Widget wrap() => MultiProvider(
    providers: [
      Provider<SessionRepository>.value(value: repo),
      ChangeNotifierProvider(create: (_) => SessionsViewModel(repo)),
      ChangeNotifierProvider<PlannerViewModel>(
        create: (_) => _MockPlannerViewModel(),
      ),
    ],
    child: const MaterialApp(home: LogbookScreen()),
  );

  /// Rows written directly: a legacy log, a planned session and a draft.
  Future<void> seed(WidgetTester tester) => tester.runAsync(() async {
    db = AppDatabase(NativeDatabase.memory());
    repo = DriftSessionRepository(db);
    await db.customStatement(
      "INSERT INTO session_logs (id, target_name, equipment_name, "
      "session_date, planned_light_frames, status, legacy, evening_date) "
      "VALUES (1, 'M31', 'Rig', 1767225600, 10, 'completed', 1, NULL), "
      "(2, 'M42', 'Rig', 1767225600, 10, 'planned', 0, '2026-01-01'), "
      "(3, 'M45', 'Rig', 1767225600, 10, 'draft', 0, '2026-01-01');",
    );
  });

  Future<int> rows(WidgetTester tester) async =>
      (await tester.runAsync(() => db.select(db.sessionLogs).get()))!.length;

  tearDown(() async => db.close());

  Future<void> pumpList(WidgetTester tester) async {
    await tester.pumpWidget(wrap());
    await tester.runAsync(() => Future<void>.delayed(Duration.zero));
    await tester.pumpAndSettle();
  }

  testWidgets('saved sessions and legacy logs are listed with their status; '
      'drafts are not', (tester) async {
    await seed(tester);
    await pumpList(tester);

    expect(find.textContaining('M31'), findsOneWidget);
    expect(find.textContaining('M42'), findsOneWidget);
    expect(find.textContaining('M45'), findsNothing);
    expect(find.text('Legacy log'), findsOneWidget);
    expect(find.text('Planned'), findsOneWidget);
  });

  testWidgets('swiping to delete asks for confirmation before deleting', (
    tester,
  ) async {
    await seed(tester);
    await pumpList(tester);

    await tester.drag(find.byType(Dismissible).first, const Offset(-500, 0));
    await tester.pumpAndSettle();

    expect(find.text('Delete Session?'), findsOneWidget);
    expect(await rows(tester), 3);
  });

  testWidgets('cancelling the confirmation keeps the entry', (tester) async {
    await seed(tester);
    await pumpList(tester);

    await tester.drag(find.byType(Dismissible).first, const Offset(-500, 0));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();

    expect(await rows(tester), 3);
    expect(find.byType(Dismissible), findsNWidgets(2));
  });

  testWidgets('confirming the dialog deletes the entry', (tester) async {
    await seed(tester);
    await pumpList(tester);

    await tester.drag(find.byType(Dismissible).first, const Offset(-500, 0));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Delete'));
    await tester.runAsync(() => Future<void>.delayed(Duration.zero));
    await tester.pumpAndSettle();

    expect(await rows(tester), 2);
    expect(find.byType(Dismissible), findsOneWidget);
  });
}
