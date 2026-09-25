import 'dart:io';

import 'package:shared_preferences/shared_preferences.dart';

import '../services/catalog_seeder.dart';
import 'app_database.dart';

/// The confirmed reset of a refused below-floor database, as the app runs
/// it (ADR-008 §2; S1.5, S1.V2):
///
/// 1. a database newer than the app is refused before anything changes;
/// 2. the catalog's seed marker is forgotten: it describes the old file and
///    would stop the replacement from being seeded (TD-060). Every other
///    preference is kept;
/// 3. the database is closed and its file kept as `<name>.v<N>.bak`
///    ([resetRefusedDatabase]).
///
/// A failure at any step leaves the earlier ones harmless, so the user can
/// try again. On an ordinary start the marker is untouched, so catalog
/// targets the user deleted are still never brought back.
Future<File> confirmDatabaseReset(
  AppDatabase database,
  File file,
  UnsupportedSchemaVersionException refused, {
  Future<SharedPreferences> Function()? preferences,
}) async {
  if (refused.isNewerThanApp) {
    throw ArgumentError.value(refused, 'refused', 'newer databases are kept');
  }
  await CatalogSeeder.forgetAppliedVersion(preferences: preferences);
  return resetRefusedDatabase(database, file, refused);
}
