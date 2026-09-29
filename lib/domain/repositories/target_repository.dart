import '../models/astro_target.dart';
import '../models/target_alias.dart';
import 'storage_failure.dart';

/// Abstract repository for managing astronomical targets.
///
/// Every method throws [StorageFailure] when the store cannot be read or
/// written (TASK 15.1).
abstract class TargetRepository {
  /// Targets matching [query] by designation (the catalog id and, for
  /// catalog rows, their aliases) or name, best first (`TargetSearch`, S7.4);
  /// every target when [query] is blank.
  Future<List<AstroTarget>> searchTargets(String query);

  /// The catalog version the stored aliases were built from; null when
  /// there are none (S7.4).
  Future<int?> aliasCatalogVersion();

  /// Replaces every stored alias with [aliases], built from catalog
  /// [version], in one transaction (S7.4). Never changes a target row.
  Future<void> replaceAliases(int version, List<TargetAlias> aliases);

  /// Retrieves all available targets.
  Future<List<AstroTarget>> getAllTargets();

  /// Retrieves a specific target by its internal ID.
  Future<AstroTarget?> getTargetById(int id);

  /// Inserts a new target into the catalog (e.g., during seeding or custom user input).
  Future<int> insertTarget(AstroTarget target);

  /// Deletes a target by its internal ID.
  Future<void> deleteTarget(int id);

  /// Updates an existing target.
  Future<void> updateTarget(AstroTarget target);
}
