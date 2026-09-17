import '../../domain/models/astro_target.dart';
import '../../domain/repositories/target_repository.dart';
import '../../core/utils/astro_math.dart';

/// Service responsible for populating the database with the initial catalog.
class CatalogSeeder {
  final TargetRepository _repository;

  CatalogSeeder(this._repository);

  /// Seeds the database if it is empty.
  Future<void> seedIfNeeded() async {
    final existing = await _repository.getAllTargets();
    if (existing.isNotEmpty) return;

    final initialTargets = [
      AstroTarget(
        id: 0, // Ignored by DB auto-increment
        catalogId: 'M31',
        commonName: 'Andromeda Galaxy',
        rightAscension: AstroMath.raToDecimalDegrees(0, 42, 44.3),
        declination: AstroMath.decToDecimalDegrees(41, 16, 9),
        type: 'Galaxy',
      ),
      AstroTarget(
        id: 0,
        catalogId: 'M42',
        commonName: 'Orion Nebula',
        rightAscension: AstroMath.raToDecimalDegrees(5, 35, 17.3),
        declination: AstroMath.decToDecimalDegrees(5, 23, 28, isNegative: true),
        type: 'Nebula',
      ),
      AstroTarget(
        id: 0,
        catalogId: 'M45',
        commonName: 'Pleiades',
        rightAscension: AstroMath.raToDecimalDegrees(3, 47, 24),
        declination: AstroMath.decToDecimalDegrees(24, 7, 0),
        type: 'Open Cluster',
      ),
      AstroTarget(
        id: 0,
        catalogId: 'M33',
        commonName: 'Triangulum Galaxy',
        rightAscension: AstroMath.raToDecimalDegrees(1, 33, 50.9),
        declination: AstroMath.decToDecimalDegrees(30, 39, 36),
        type: 'Galaxy',
      ),
      AstroTarget(
        id: 0,
        catalogId: 'M8',
        commonName: 'Lagoon Nebula',
        rightAscension: AstroMath.raToDecimalDegrees(18, 3, 37),
        declination: AstroMath.decToDecimalDegrees(24, 23, 12, isNegative: true),
        type: 'Nebula',
      ),
    ];

    for (final target in initialTargets) {
      await _repository.insertTarget(target);
    }
  }
}
