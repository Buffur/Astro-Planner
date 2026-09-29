import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/diagnostics/app_log.dart';
import '../../core/utils/astro_math.dart';
import '../../domain/models/astro_target.dart';
import '../../domain/models/target_alias.dart';
import '../../domain/repositories/target_repository.dart';

/// One object of the bundled catalog asset (TASK 8.2).
class CatalogEntry {
  const CatalogEntry({
    required this.id,
    required this.name,
    required this.type,
    required this.rightAscension,
    required this.declination,
    required this.sizeArcmin,
    required this.vMag,
    required this.since,
    required this.openNgcName,
    required this.openNgcRa,
    required this.openNgcDec,
    this.aliasIds = const [],
    this.aliasNames = const [],
  });

  /// Catalog id shown to the user, e.g. `M31`, `NGC 7000`.
  final String id;
  final String? name;
  final String type;

  /// J2000, decimal degrees.
  final double rightAscension;
  final double declination;

  /// Major axis, arcmin; null when OpenNGC has none.
  final double? sizeArcmin;

  /// V magnitude; null when OpenNGC has none.
  final double? vMag;

  /// The catalog version that introduced this entry.
  final int since;

  /// The OpenNGC row it came from, with its original sexagesimal text.
  final String openNgcName;
  final String openNgcRa;
  final String openNgcDec;

  /// Other designations and names, from OpenNGC (catalog version 3, S7.4).
  final List<String> aliasIds;
  final List<String> aliasNames;

  List<TargetAlias> get aliases => [
    for (final a in aliasIds)
      TargetAlias(catalogId: id, alias: a, kind: TargetAliasKind.designation),
    for (final a in aliasNames)
      TargetAlias(catalogId: id, alias: a, kind: TargetAliasKind.name),
  ];

  AstroTarget toTarget(String source, {int id = 0}) => AstroTarget(
    id: id,
    catalogId: this.id,
    commonName: name,
    rightAscension: rightAscension,
    declination: declination,
    type: type,
    source: source,
    angularSizeArcmin: sizeArcmin,
    magnitude: vMag,
  );
}

/// The parsed catalog asset.
class TargetCatalog {
  const TargetCatalog({
    required this.version,
    required this.source,
    required this.entries,
  });

  factory TargetCatalog.parse(String json) {
    final data = jsonDecode(json) as Map<String, dynamic>;
    if (data['epoch'] != 'J2000') {
      throw const FormatException('The catalog must be J2000');
    }
    double? optional(Object? v) => (v as num?)?.toDouble();
    List<String> strings(Object? v) => [
      for (final s in (v as List<dynamic>?) ?? const []) s as String,
    ];
    return TargetCatalog(
      version: data['version'] as int,
      source: data['source'] as String,
      entries: [
        for (final o in data['objects'] as List<dynamic>)
          CatalogEntry(
            id: o['id'] as String,
            name: o['name'] as String?,
            type: o['type'] as String,
            rightAscension: (o['ra'] as num).toDouble(),
            declination: (o['dec'] as num).toDouble(),
            sizeArcmin: optional(o['sizeArcmin']),
            vMag: optional(o['vMag']),
            since: o['since'] as int,
            openNgcName: o['openNgc'] as String,
            openNgcRa: o['openNgcRa'] as String,
            openNgcDec: o['openNgcDec'] as String,
            aliasIds: strings(o['aliasIds']),
            aliasNames: strings(o['aliasNames']),
          ),
      ],
    );
  }

  /// Catalog version (the pre-TASK 8.2 five hard-coded seeds were version 1).
  final int version;

  /// Provenance id stored on every seeded row, e.g.
  /// `catalog:openngc@v20260501` (ADR-008 §6).
  final String source;
  final List<CatalogEntry> entries;
}

/// Seeds the bundled catalog, versioned (TASK 8.2, TD-035).
///
/// The applied catalog version is stored in preferences. Seeding runs only
/// when the asset is newer than what was applied, and then adds only the
/// entries introduced since — so a target the user deleted is **never
/// resurrected**, even if they delete every target.
///
/// First run after upgrading from a pre-8.2 install (no stored version, but
/// targets exist): a row whose catalog id and coordinates exactly equal one of
/// the five old hard-coded seeds is the untouched old seed and is updated in
/// place to the catalog data (same row id, so a selection keeps working);
/// every other row is left as it is (owner decision, TASK 8.2).
class CatalogSeeder {
  CatalogSeeder(
    this._repository, {
    Future<String> Function()? loadAsset,
    Future<SharedPreferences> Function()? preferences,
  }) : _loadAsset = loadAsset ?? (() => rootBundle.loadString(assetPath)),
       _preferences = preferences ?? SharedPreferences.getInstance;

  static const String assetPath = 'assets/catalog/catalog_v2.json';
  static const String versionKey = 'catalogSeedVersion';

  /// Forgets which catalog version was applied, so the next seeding treats
  /// the database as new. Only for a database that has been replaced (the
  /// confirmed reset, S1.V2): on an ordinary start the marker is what keeps
  /// deleted catalog targets from coming back.
  static Future<void> forgetAppliedVersion({
    Future<SharedPreferences> Function()? preferences,
  }) async {
    final prefs = await (preferences ?? SharedPreferences.getInstance)();
    await prefs.remove(versionKey);
  }

  final TargetRepository _repository;
  final Future<String> Function() _loadAsset;
  final Future<SharedPreferences> Function() _preferences;

  /// The five targets seeded before TASK 8.2 (catalog version 1), exactly as
  /// that seeder computed them — used only to recognise untouched old rows.
  static final List<AstroTarget> legacySeeds = [
    AstroTarget(
      id: 0,
      catalogId: 'M31',
      rightAscension: AstroMath.raToDecimalDegrees(0, 42, 44.3),
      declination: AstroMath.decToDecimalDegrees(41, 16, 9),
      type: 'Galaxy',
    ),
    AstroTarget(
      id: 0,
      catalogId: 'M42',
      rightAscension: AstroMath.raToDecimalDegrees(5, 35, 17.3),
      declination: AstroMath.decToDecimalDegrees(5, 23, 28, isNegative: true),
      type: 'Nebula',
    ),
    AstroTarget(
      id: 0,
      catalogId: 'M45',
      rightAscension: AstroMath.raToDecimalDegrees(3, 47, 24),
      declination: AstroMath.decToDecimalDegrees(24, 7, 0),
      type: 'Open Cluster',
    ),
    AstroTarget(
      id: 0,
      catalogId: 'M33',
      rightAscension: AstroMath.raToDecimalDegrees(1, 33, 50.9),
      declination: AstroMath.decToDecimalDegrees(30, 39, 36),
      type: 'Galaxy',
    ),
    AstroTarget(
      id: 0,
      catalogId: 'M8',
      rightAscension: AstroMath.raToDecimalDegrees(18, 3, 37),
      declination: AstroMath.decToDecimalDegrees(24, 23, 12, isNegative: true),
      type: 'Nebula',
    ),
  ];

  static bool _isUntouchedLegacySeed(AstroTarget row) => legacySeeds.any(
    (s) =>
        s.catalogId == row.catalogId &&
        s.rightAscension == row.rightAscension &&
        s.declination == row.declination,
  );

  Future<void> seedIfNeeded() async {
    final catalog = TargetCatalog.parse(await _loadAsset());

    SharedPreferences? prefs;
    try {
      prefs = await _preferences();
    } catch (e) {
      AppLog.warning('seeding', 'Preferences unavailable', error: e);
    }
    await _syncAliases(catalog);
    final applied = prefs?.getInt(versionKey);
    if (applied != null && applied >= catalog.version) return;

    final existing = await _repository.getAllTargets();
    if (prefs == null && existing.isNotEmpty) {
      // Without a stored version we cannot tell what was deleted: do nothing
      // rather than risk resurrecting deletions.
      return;
    }

    // Catalog ids already held by a catalog row: the partial unique index
    // would refuse them, so they are skipped rather than attempted (S1.2).
    final present = {
      for (final t in existing)
        if (_isCatalogRow(t)) t.catalogId,
    };
    final failures = <Object>[];
    Future<void> insert(CatalogEntry entry) async {
      if (present.contains(entry.id)) return;
      try {
        await _repository.insertTarget(entry.toTarget(catalog.source));
      } catch (e) {
        failures.add(e);
      }
    }

    if (applied != null) {
      // A newer catalog: add only what it introduced.
      for (final entry in catalog.entries.where((e) => e.since > applied)) {
        await insert(entry);
      }
    } else if (existing.isEmpty) {
      for (final entry in catalog.entries) {
        await insert(entry);
      }
    } else {
      // First run after a pre-8.2 install, or a retry after failed inserts.
      for (final entry in catalog.entries) {
        final legacy = existing
            .where((t) => t.catalogId == entry.id && _isUntouchedLegacySeed(t))
            .firstOrNull;
        if (legacy != null) {
          await _repository.updateTarget(
            entry.toTarget(catalog.source, id: legacy.id),
          );
        } else {
          await insert(entry);
        }
      }
    }
    if (failures.isNotEmpty) {
      // Not recorded as applied: the next launch retries, and the rows that
      // did go in are skipped then (ENG-02, S1.2).
      AppLog.error(
        'seeding',
        '${failures.length} catalog insert(s) failed; will retry next launch',
        error: failures.first,
      );
      return;
    }
    await prefs?.setInt(versionKey, catalog.version);
  }

  /// Rebuilds the aliases when the asset's version differs from theirs
  /// (S7.4). Recorded in the database itself, so a restored or reset
  /// database gets them too. Changes no target row. A failure is logged and
  /// retried on the next launch; search then finds ids and names only.
  Future<void> _syncAliases(TargetCatalog catalog) async {
    try {
      if (await _repository.aliasCatalogVersion() == catalog.version) return;
      await _repository.replaceAliases(catalog.version, [
        for (final e in catalog.entries) ...e.aliases,
      ]);
    } catch (e) {
      AppLog.error('seeding', 'Catalog aliases not stored', error: e);
    }
  }

  static bool _isCatalogRow(AstroTarget t) =>
      (t.source?.startsWith('seed:') ?? false) ||
      (t.source?.startsWith('catalog:') ?? false);
}
