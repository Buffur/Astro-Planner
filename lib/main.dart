import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';
import 'presentation/navigation/app_router.dart';
import 'data/database/app_database.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  final database = AppDatabase();

  runApp(
    Provider<AppDatabase>.value(
      value: database,
      child: const AstroPlanApp(),
    ),
  );
}

class AstroPlanApp extends StatelessWidget {
  const AstroPlanApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // TODO: Add view models and repositories here in future phases
        Provider.value(value: 'placeholder'),
      ],
      child: MaterialApp.router(
        title: 'AstroPlan',
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        routerConfig: AppRouter.router,
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
