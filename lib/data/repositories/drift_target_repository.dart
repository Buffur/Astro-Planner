import 'package:drift/drift.dart';

import '../../domain/repositories/target_repository.dart';
import '../../domain/models/astro_target.dart' as domain;
import '../../domain/models/target_alias.dart';
import '../../domain/services/target_search.dart';
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
      epoch: dbTarget.epoch,
      source: dbTarget.source,
      angularSizeArcmin: dbTarget.angularSizeArcmin,
      magnitude: dbTarget.magnitude,
    );
  }

  /// Escapes the `LIKE` wildcards `%` and `_` (and the escape character
  /// itself) so a search matches them literally (TASK 8.1).
  static String escapeLike(String text) => text
      .replaceAll(_escape, '$_escape$_escape')
      .replaceAll('%', '$_escape%')
      .replaceAll('_', '${_escape}_');

  static const String _escape = r'\';

  @override
  Future<List<domain.AstroTarget>> getAllTargets() async {
    final dbTargets = await _db.select(_db.astroTargets).get();
    return dbTargets.map(_mapToDomain).toList();
  }

  @override
  Future<domain.AstroTarget?> getTargetById(int id) async {
    final dbTarget = await (_db.select(
      _db.astroTargets,
    )..where((t) => t.id.equals(id))).getSingleOrNull();
    return dbTarget != null ? _mapToDomain(dbTarget) : null;
  }

  @override
  Future<int> insertTarget(domain.AstroTarget target) async {
    return _db
        .into(_db.astroTargets)
        .insert(
          AstroTargetsCompanion.insert(
            catalogId: target.catalogId,
            commonName: Value(target.commonName),
            rightAscension: target.rightAscension,
            declination: target.declination,
            type: target.type,
            epoch: Value(target.epoch),
            source: Value(target.source),
            angularSizeArcmin: Value(target.angularSizeArcmin),
            magnitude: Value(target.magnitude),
          ),
        );
  }

  /// S7.4: the pure `TargetSearch` over every target and alias (a few
  /// hundred rows), so a query matches literally and works offline.
  @override
  Future<List<domain.AstroTarget>> searchTargets(String query) async {
    final targets = await getAllTargets();
    if (query.trim().isEmpty) return targets;
    final rows = await _db.select(_db.targetAliases).get();
    final aliases = [
      for (final r in rows)
        if (TargetAliasKind.fromStorage(r.kind) case final kind?)
          TargetAlias(catalogId: r.catalogId, alias: r.alias, kind: kind),
    ];
    return TargetSearch.search(query, targets, aliases);
  }

  @override
  Future<int?> aliasCatalogVersion() {
    final newest = _db.targetAliases.catalogVersion.max();
    return (_db.selectOnly(
      _db.targetAliases,
    )..addColumns([newest])).map((r) => r.read(newest)).getSingle();
  }

  @override
  Future<void> replaceAliases(int version, List<TargetAlias> aliases) =>
      _db.transaction(() async {
        await _db.delete(_db.targetAliases).go();
        await _db.batch(
          (b) => b.insertAll(_db.targetAliases, [
            for (final a in aliases)
              TargetAliasesCompanion.insert(
                catalogId: a.catalogId,
                alias: a.alias,
                kind: a.kind.name,
                catalogVersion: version,
              ),
          ]),
        );
      });

  @override
  Future<void> deleteTarget(int id) async {
    await (_db.delete(_db.astroTargets)..where((t) => t.id.equals(id))).go();
  }

  /// Updates a target's editable fields. The catalog id is never changed by
  /// an edit (TASK 8.1), whatever [target] carries.
  @override
  Future<void> updateTarget(domain.AstroTarget target) async {
    await (_db.update(
      _db.astroTargets,
    )..where((t) => t.id.equals(target.id))).write(
      AstroTargetsCompanion(
        commonName: Value(target.commonName),
        rightAscension: Value(target.rightAscension),
        declination: Value(target.declination),
        type: Value(target.type),
        epoch: Value(target.epoch),
        source: Value(target.source),
        angularSizeArcmin: Value(target.angularSizeArcmin),
        magnitude: Value(target.magnitude),
      ),
    );
  }
}
