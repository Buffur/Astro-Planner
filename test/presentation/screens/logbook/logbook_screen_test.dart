// Widget tests for LogbookScreen (roadmap TASK 4.2, TD-039).
//
// Covers what the roadmap's acceptance test calls out explicitly: delete
// requires confirmation. Ordering (newest-first) is a repository concern,
// already covered by drift_logbook_repository_test.dart.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:astroplan/domain/models/session_log.dart';
import 'package:astroplan/domain/repositories/logbook_repository.dart';
import 'package:astroplan/presentation/screens/logbook/logbook_screen.dart';
import 'package:astroplan/presentation/viewmodels/planner_viewmodel.dart';

class _FakeLogbookRepository implements LogbookRepository {
  final List<SessionLog> logs;
  int deleteCount = 0;

  _FakeLogbookRepository(this.logs);

  @override
  Future<List<SessionLog>> getAllLogs() async => List.of(logs);

  @override
  Future<int> addLog(SessionLog log) async {
    logs.add(log);
    return log.id;
  }

  @override
  Future<void> updateLog(SessionLog log) async {}

  @override
  Future<void> deleteLog(int id) async {
    deleteCount++;
    logs.removeWhere((l) => l.id == id);
  }
}

class _MockPlannerViewModel extends ChangeNotifier implements PlannerViewModel {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  Widget wrap(LogbookRepository repo) {
    return MultiProvider(
      providers: [
        Provider<LogbookRepository>.value(value: repo),
        ChangeNotifierProvider<PlannerViewModel>(
          create: (_) => _MockPlannerViewModel(),
        ),
      ],
      child: const MaterialApp(home: LogbookScreen()),
    );
  }

  SessionLog buildLog(int id, String name) {
    return SessionLog(
      id: id,
      targetName: name,
      equipmentName: 'Rig',
      sessionDate: DateTime(2026, 1, 1),
      plannedLightFrames: 10,
    );
  }

  testWidgets('swiping to delete asks for confirmation before deleting', (
    tester,
  ) async {
    final repo = _FakeLogbookRepository([buildLog(1, 'M31')]);
    await tester.pumpWidget(wrap(repo));
    await tester.pumpAndSettle();

    await tester.drag(find.byType(Dismissible), const Offset(-500, 0));
    await tester.pumpAndSettle();

    expect(find.text('Delete Session?'), findsOneWidget);
    expect(repo.deleteCount, 0);
  });

  testWidgets('cancelling the confirmation keeps the entry', (tester) async {
    final repo = _FakeLogbookRepository([buildLog(1, 'M31')]);
    await tester.pumpWidget(wrap(repo));
    await tester.pumpAndSettle();

    await tester.drag(find.byType(Dismissible), const Offset(-500, 0));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();

    expect(repo.deleteCount, 0);
    expect(find.textContaining('M31'), findsOneWidget);
  });

  testWidgets('confirming the dialog deletes the entry', (tester) async {
    final repo = _FakeLogbookRepository([buildLog(1, 'M31')]);
    await tester.pumpWidget(wrap(repo));
    await tester.pumpAndSettle();

    await tester.drag(find.byType(Dismissible), const Offset(-500, 0));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();

    expect(repo.deleteCount, 1);
    expect(find.textContaining('M31'), findsNothing);
  });
}
