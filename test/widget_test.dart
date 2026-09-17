import 'package:flutter_test/flutter_test.dart';
import 'package:astroplan/main.dart';
import 'package:provider/provider.dart';
import 'package:drift/native.dart';
import 'package:astroplan/data/database/app_database.dart';
import 'package:astroplan/data/repositories/drift_target_repository.dart';
import 'package:astroplan/domain/repositories/target_repository.dart';
import 'package:astroplan/data/repositories/drift_equipment_repository.dart';
import 'package:astroplan/domain/repositories/equipment_repository.dart';
import 'package:astroplan/domain/repositories/weather_repository.dart';
import 'package:astroplan/domain/models/weather_conditions.dart';
import 'package:astroplan/presentation/viewmodels/planner_viewmodel.dart';
import 'package:astroplan/data/services/catalog_seeder.dart';
import 'package:astroplan/data/services/equipment_seeder.dart';

class MockWeatherRepository implements WeatherRepository {
  @override
  Future<WeatherConditions?> getCurrentWeather(double latitude, double longitude) async {
    return const WeatherConditions(
      temperature: 15.0,
      cloudCover: 10.0,
      humidity: 50.0,
      dewPoint: 5.0,
    );
  }
}

void main() {
  testWidgets('App should boot and show session planner', (WidgetTester tester) async {
    final database = AppDatabase(NativeDatabase.memory());
    final targetRepo = DriftTargetRepository(database);
    final seeder = CatalogSeeder(targetRepo);
    await seeder.seedIfNeeded();

    final eqRepo = DriftEquipmentRepository(database);
    final eqSeeder = EquipmentSeeder(eqRepo);
    await eqSeeder.seedIfNeeded();

    final weatherRepo = MockWeatherRepository();

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          Provider<AppDatabase>.value(value: database),
          Provider<TargetRepository>.value(value: targetRepo),
          Provider<EquipmentRepository>.value(value: eqRepo),
          Provider<WeatherRepository>.value(value: weatherRepo),
          ChangeNotifierProvider(create: (_) => PlannerViewModel(targetRepo, eqRepo, weatherRepo)),
        ],
        child: const AstroPlanApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Session Planner'), findsOneWidget);

    await database.close();
  });
}

