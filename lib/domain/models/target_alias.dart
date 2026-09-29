/// Whether an alias is a designation ("NGC 224", "C 20", "LBN 25") or a
/// name ("Orion Nebula") (RG-07 = T1, S7.4).
enum TargetAliasKind {
  designation,
  name;

  static TargetAliasKind? fromStorage(String? value) =>
      TargetAliasKind.values.where((k) => k.name == value).firstOrNull;
}

/// Another designation or name of a bundled catalog object, from the pinned
/// OpenNGC release only (S7.4). Keyed by the catalog id, never by a row: it
/// applies to the catalog row with that id while one exists, so a deleted
/// target's aliases are never shown, and it never changes a row.
class TargetAlias {
  const TargetAlias({
    required this.catalogId,
    required this.alias,
    required this.kind,
  });

  final String catalogId;
  final String alias;
  final TargetAliasKind kind;

  @override
  bool operator ==(Object other) =>
      other is TargetAlias &&
      other.catalogId == catalogId &&
      other.alias == alias &&
      other.kind == kind;

  @override
  int get hashCode => Object.hash(catalogId, alias, kind);

  @override
  String toString() => 'TargetAlias($catalogId: $alias, ${kind.name})';
}
