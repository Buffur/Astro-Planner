import 'package:drift/drift.dart';
import '../../domain/repositories/target_repository.dart';
import '../../domain/models/astro_target.dart' as domain;
import '../database/app_database.dart';

class DriftTargetRepository implements TargetRepository {
  final AppDatabase _db;

  DriftTargetRepository(this._db);

  domain.AstroTarget _mapToDomain(AstroTarget dbTarget) {
    return domain.AstroTarget(
      id: dbTarget.id,
      catalogId: dbTarget.catalogId,
      commonName: dbTarget.commonName,
      rightAscension: dbTarget.rightAscension,
      declination: dbTarget.declination,
      type: dbTarget.type,
    );
  }

  @override
  Future<List<domain.AstroTarget>> getAllTargets() async {
    final dbTargets = await _db.select(_db.astroTargets).get();
    return dbTargets.map(_mapToDomain).toList();
  }

  @override
  Future<domain.AstroTarget?> getTargetById(int id) async {
    final dbTarget = await (_db.select(_db.astroTargets)..where((t) => t.id.equals(id))).getSingleOrNull();
    return dbTarget != null ? _mapToDomain(dbTarget) : null;
  }

  @override
  Future<int> insertTarget(domain.AstroTarget target) async {
    return _db.into(_db.astroTargets).insert(
      AstroTargetsCompanion.insert(
        catalogId: target.catalogId,
        commonName: Value(target.commonName),
        rightAscension: target.rightAscension,
        declination: target.declination,
        type: target.type,
      ),
    );
  }

  @override
  Future<List<domain.AstroTarget>> searchTargets(String query) async {
    final likeQuery = '%$query%';
    final dbTargets = await (_db.select(_db.astroTargets)
          ..where((t) => t.catalogId.like(likeQuery) | t.commonName.like(likeQuery)))
        .get();
    return dbTargets.map(_mapToDomain).toList();
  }
}
