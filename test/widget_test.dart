import 'package:flutter_test/flutter_test.dart';
import 'package:astroplan/main.dart';
import 'package:provider/provider.dart';
import 'package:drift/native.dart';
import 'package:astroplan/data/database/app_database.dart';
import 'package:astroplan/data/repositories/drift_target_repository.dart';
import 'package:astroplan/domain/repositories/target_repository.dart';
import 'package:astroplan/data/repositories/drift_equipment_repository.dart';
import 'package:astroplan/domain/repositories/equipment_repository.dart';
import 'package:astroplan/presentation/viewmodels/planner_viewmodel.dart';
import 'package:astroplan/data/services/catalog_seeder.dart';
import 'package:astroplan/data/services/equipment_seeder.dart';

void main() {
  testWidgets('App should boot and show session planner', (WidgetTester tester) async {
    final database = AppDatabase(NativeDatabase.memory());
    final targetRepo = DriftTargetRepository(database);
    final seeder = CatalogSeeder(targetRepo);
    await seeder.seedIfNeeded();

    final eqRepo = DriftEquipmentRepository(database);
    final eqSeeder = EquipmentSeeder(eqRepo);
    await eqSeeder.seedIfNeeded();

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          Provider<AppDatabase>.value(value: database),
          Provider<TargetRepository>.value(value: targetRepo),
          Provider<EquipmentRepository>.value(value: eqRepo),
          ChangeNotifierProvider(create: (_) => PlannerViewModel(targetRepo, eqRepo)),
        ],
        child: const AstroPlanApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Session Planner'), findsOneWidget);

    await database.close();
  });
}

