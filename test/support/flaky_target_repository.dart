import 'package:astroplan/domain/models/astro_target.dart' as domain;
import 'package:astroplan/domain/models/target_alias.dart';
import 'package:astroplan/domain/repositories/target_repository.dart';

/// Wraps a real [TargetRepository] and can be made to throw on every call.
///
/// Used to test bootstrap-failure and retry handling against a real backing
/// store, rather than a repository that can never succeed.
class FlakyTargetRepository implements TargetRepository {
  FlakyTargetRepository(this._delegate);

  final TargetRepository _delegate;
  bool shouldThrow = true;

  void _check() {
    if (shouldThrow) throw Exception('simulated repository failure');
  }

  @override
  Future<List<domain.AstroTarget>> searchTargets(String query) async {
    _check();
    return _delegate.searchTargets(query);
  }

  @override
  Future<int?> aliasCatalogVersion() async {
    _check();
    return _delegate.aliasCatalogVersion();
  }

  @override
  Future<void> replaceAliases(int version, List<TargetAlias> aliases) async {
    _check();
    return _delegate.replaceAliases(version, aliases);
  }

  @override
  Future<List<domain.AstroTarget>> getAllTargets() async {
    _check();
    return _delegate.getAllTargets();
  }

  @override
  Future<domain.AstroTarget?> getTargetById(int id) async {
    _check();
    return _delegate.getTargetById(id);
  }

  @override
  Future<int> insertTarget(domain.AstroTarget target) async {
    _check();
    return _delegate.insertTarget(target);
  }

  @override
  Future<void> deleteTarget(int id) async {
    _check();
    return _delegate.deleteTarget(id);
  }

  @override
  Future<void> updateTarget(domain.AstroTarget target) async {
    _check();
    return _delegate.updateTarget(target);
  }

  @override
  Future<T> inOneTransaction<T>(Future<T> Function() writes) async {
    _check();
    return _delegate.inOneTransaction(writes);
  }
}
