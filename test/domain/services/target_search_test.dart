// S7.4 (RG-07 = T1, §6): the search rules, pure. A designation matches
// ignoring case, spaces, hyphens and leading zeros, with "Messier" as M and
// "Caldwell" as C; a name by substring; ordered by match kind, then id; no
// score. Aliases apply only to catalog rows that exist.

import 'package:astroplan/domain/models/astro_target.dart';
import 'package:astroplan/domain/models/target_alias.dart';
import 'package:astroplan/domain/services/target_search.dart';
import 'package:flutter_test/flutter_test.dart';

const _catalog = 'catalog:openngc@v20260501';

AstroTarget _t(int id, String catalogId, {String? name, String? source}) =>
    AstroTarget(
      id: id,
      catalogId: catalogId,
      commonName: name,
      rightAscension: 10,
      declination: 20,
      type: 'Nebula',
      source: source ?? _catalog,
    );

TargetAlias _d(String id, String alias) =>
    TargetAlias(catalogId: id, alias: alias, kind: TargetAliasKind.designation);
TargetAlias _n(String id, String alias) =>
    TargetAlias(catalogId: id, alias: alias, kind: TargetAliasKind.name);

void main() {
  test('the designation key', () {
    for (final (typed, key) in [
      ('M31', 'm31'),
      ('M 31', 'm31'),
      ('m31', 'm31'),
      ('Messier 31', 'm31'),
      ('NGC 0224', 'ngc224'),
      ('NGC224', 'ngc224'),
      ('C020', 'c20'),
      ('Caldwell 20', 'c20'),
      ('LBN 25', 'lbn25'),
      ('Sh2-129', 'sh2129'),
      ('ESO056-115', 'eso56115'),
      ('Andromeda', 'andromeda'),
    ]) {
      expect(TargetSearch.designationKey(typed), key, reason: typed);
    }
  });

  final m3 = _t(3, 'M3');
  final m31 = _t(31, 'M31', name: 'Andromeda Galaxy');
  final m33 = _t(33, 'M33', name: 'Triangulum Galaxy');
  final m8 = _t(8, 'M8', name: 'Lagoon Nebula');
  final ngc7000 = _t(70, 'NGC 7000', name: 'North America Nebula');
  final custom = _t(99, 'M3 field', source: 'user');
  final targets = [ngc7000, m33, custom, m31, m8, m3];
  final aliases = [
    _d('M31', 'NGC 224'),
    _d('M8', 'LBN 25'),
    _d('NGC 7000', 'C 20'),
    _n('M33', 'Triangulum Pinwheel'),
  ];
  List<String> ids(String q, [List<AstroTarget>? ts]) => [
    for (final t in TargetSearch.search(q, ts ?? targets, aliases)) t.catalogId,
  ];

  test('exact designation, then designation prefix, then name; each by '
      'the id in reading order', () {
    expect(ids('M3'), ['M3', 'M3 field', 'M31', 'M33']);
    expect(ids('m 3'), ids('M3'));
    expect(ids('Galaxy'), ['M31', 'M33']);
  });

  test('aliases find their object; a second name too', () {
    expect(ids('NGC 0224'), ['M31']);
    expect(ids('LBN 25'), ['M8']);
    expect(ids('Caldwell 20'), ['NGC 7000']);
    expect(ids('pinwheel'), ['M33']);
    expect(ids('Sh2-129'), isEmpty);
  });

  test('a custom target never takes a catalog alias, even with a catalog '
      'id', () {
    final lookalike = _t(5, 'M31', source: 'user');
    expect(ids('NGC 224', [lookalike]), isEmpty);
    expect(ids('M31', [lookalike]), ['M31']);
  });

  test('a deleted target\'s aliases are never shown', () {
    expect(ids('NGC 224', [m33, m8]), isEmpty);
  });

  test('a blank query returns every target in the given order', () {
    expect(ids('  '), [for (final t in targets) t.catalogId]);
  });

  test('the ids in reading order', () {
    final sorted = ['M10', 'NGC 7000', 'M2', 'IC 434', 'M1', 'C 9']
      ..sort(TargetSearch.compareIds);
    expect(sorted, ['C 9', 'IC 434', 'M1', 'M2', 'M10', 'NGC 7000']);
  });
}
