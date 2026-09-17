import '../models/astro_target.dart';

/// Abstract repository for managing astronomical targets.
abstract class TargetRepository {
  /// Searches for targets by catalog ID or common name.
  Future<List<AstroTarget>> searchTargets(String query);

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
