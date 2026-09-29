// TASK 14.4: the Settings backup section — back up, restore (picked,
// checked, confirmed, staged for the next start), a refused file explained,
// a staged restore cancelled.

import 'package:astroplan/data/database/app_database.dart' show AppDatabase;
import 'package:astroplan/data/repositories/drift_equipment_repository.dart';
import 'package:astroplan/data/repositories/drift_location_repository.dart';
import 'package:astroplan/data/repositories/drift_target_repository.dart';
import 'package:astroplan/domain/repositories/weather_repository.dart';
import 'package:astroplan/domain/services/backup_service.dart';
import 'package:astroplan/presentation/screens/settings/settings_screen.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../support/fake_location_service.dart';
import '../../../support/no_snapshot_weather.dart';
import '../../../support/planner_harness.dart';

class _NoWeather with NoSnapshotWeather implements WeatherRepository {}

class _FakeBackup implements BackupService {
  int backups = 0;
  bool staged = false;
  Object? stagedFile;
  BackupProblem? refuse;
  bool cancelPick = false;

  @override
  Future<void> backUpAndShare() async => backups++;

  @override
  Future<({BackupPreview preview, Object file})?> pick() async {
    if (refuse != null) throw BackupException(refuse!);
    if (cancelPick) return null;
    return (
      preview: BackupPreview(
        createdAtUtc: DateTime.utc(2026, 12, 16, 8),
        schemaVersion: 17,
        appVersion: '1.0.0',
        sessionCount: 12,
      ),
      file: 'backup-bytes',
    );
  }

  @override
  Future<void> stage(Object file) async {
    stagedFile = file;
    staged = true;
  }

  @override
  Future<bool> hasStagedRestore() async => staged;

  @override
  Future<void> cancelStagedRestore() async => staged = false;
}

void main() {
  late AppDatabase database;
  late PlannerHarness vm;
  late _FakeBackup backup;

  Future<void> pump(WidgetTester tester) async {
    tester.view.physicalSize = const Size(800, 3000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    await tester.runAsync(() async {
      SharedPreferences.setMockInitialValues({});
      database = AppDatabase(NativeDatabase.memory());
      backup = _FakeBackup();
      vm = PlannerHarness(
        DriftTargetRepository(database),
        DriftEquipmentRepository(database),
        _NoWeather(),
        DriftLocationRepository(database),
        locationService: FakeLocationService(),
        backup: backup,
      );
      await vm.ready;
      await vm.vms.backup!.load();
    });
    addTearDown(() => tester.runAsync(database.close));
    await tester.pumpWidget(
      MultiProvider(
        providers: vm.providers,
        child: const MaterialApp(home: SettingsScreen()),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('Back up now shares a backup', (tester) async {
    await pump(tester);
    await tester.tap(find.byKey(const Key('backup.backUp')));
    await tester.pumpAndSettle();
    expect(backup.backups, 1);
  });

  testWidgets('restore: the preview is confirmed, then staged', (tester) async {
    await pump(tester);
    await tester.tap(find.byKey(const Key('backup.restore')));
    await tester.pumpAndSettle();
    expect(find.textContaining('with 12 sessions'), findsOneWidget);
    expect(backup.staged, isFalse, reason: 'nothing before confirmation');
    await tester.tap(find.byKey(const Key('confirm.action')) /* S9.4 */);
    await tester.pumpAndSettle();
    expect(backup.stagedFile, 'backup-bytes');
    expect(find.byKey(const Key('backup.staged')), findsOneWidget);

    await tester.tap(find.byKey(const Key('backup.staged'))); // cancel
    await tester.pumpAndSettle();
    expect(backup.staged, isFalse);
    expect(find.byKey(const Key('backup.restore')), findsOneWidget);
  });

  testWidgets('cancelling the confirmation stages nothing', (tester) async {
    await pump(tester);
    await tester.tap(find.byKey(const Key('backup.restore')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(backup.staged, isFalse);
  });

  testWidgets('a backup from a newer app is refused with the reason', (
    tester,
  ) async {
    await pump(tester);
    backup.refuse = BackupProblem.newerSchema;
    await tester.tap(find.byKey(const Key('backup.restore')));
    await tester.pumpAndSettle();
    expect(
      find.textContaining('newer version of Astro Planner'),
      findsOneWidget,
    );
    expect(backup.staged, isFalse);
  });
}
