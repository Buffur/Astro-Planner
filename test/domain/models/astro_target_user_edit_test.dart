// AstroTarget.userEdit and TargetTypes (TASK 8.1): edits keep the catalog
// id; provenance becomes "user" only when the data changes; moving types.

import 'package:astroplan/domain/models/astro_target.dart';
import 'package:astroplan/domain/models/target_types.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const seeded = AstroTarget(
    id: 3,
    catalogId: 'M42',
    commonName: 'Orion Nebula',
    rightAscension: 83.8221,
    declination: -5.3911,
    type: 'Nebula',
    source: 'seed:catalog@1',
    angularSizeArcmin: 85,
    magnitude: 4.0,
  );

  AstroTarget edit({
    String name = 'Orion Nebula',
    String type = 'Nebula',
    double ra = 83.8221,
    double dec = -5.3911,
    double? size = 85,
    double? mag = 4.0,
  }) => AstroTarget.userEdit(
    original: seeded,
    name: name,
    type: type,
    rightAscension: ra,
    declination: dec,
    angularSizeArcmin: size,
    magnitude: mag,
  );

  test('a new custom target: name is the catalog id, source user, J2000', () {
    final t = AstroTarget.userEdit(
      name: 'My blob',
      type: 'Other',
      rightAscension: 10,
      declination: 20,
    );
    expect(t.id, 0);
    expect(t.catalogId, 'My blob');
    expect(t.commonName, 'My blob');
    expect(t.source, 'user');
    expect(t.epoch, 'J2000');
    expect(t.isCatalogEntry, isFalse);
  });

  test('an edit never changes the catalog id', () {
    final t = edit(name: 'Great Orion Nebula');
    expect(t.id, 3);
    expect(t.catalogId, 'M42');
    expect(t.commonName, 'Great Orion Nebula');
  });

  test('a rename or retype keeps the source', () {
    expect(edit(name: 'Renamed').source, 'seed:catalog@1');
    expect(edit(type: 'Other').source, 'seed:catalog@1');
  });

  test('changed coordinates, size or magnitude make the source user', () {
    expect(edit(ra: 83.9).source, 'user');
    expect(edit(dec: -5.4).source, 'user');
    expect(edit(size: 90).source, 'user');
    expect(edit(mag: null).source, 'user');
  });

  test('catalog entries are seed:/catalog: sources only', () {
    expect(seeded.isCatalogEntry, isTrue);
    expect(
      const AstroTarget(
        id: 1,
        catalogId: 'NGC 1',
        rightAscension: 0,
        declination: 0,
        type: 'Galaxy',
        source: 'catalog:openngc@1',
      ).isCatalogEntry,
      isTrue,
    );
    expect(
      const AstroTarget(
        id: 1,
        catalogId: 'x',
        rightAscension: 0,
        declination: 0,
        type: 'Galaxy',
      ).isCatalogEntry,
      isFalse,
      reason: 'legacy (unknown) rows are not catalog entries',
    );
  });

  test('moving types are not selectable (ADR-010 §3)', () {
    for (final moving in TargetTypes.moving) {
      expect(TargetTypes.selectable, isNot(contains(moving)));
      expect(TargetTypes.isMoving(moving), isTrue);
    }
    expect(TargetTypes.isMoving('Galaxy'), isFalse);
  });
}
