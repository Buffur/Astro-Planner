import '../models/astro_target.dart';
import '../models/target_alias.dart';

/// How a target matched a query, best first (RG-07 §6; S7.4).
enum TargetMatchKind { exactDesignation, designationPrefix, nameSubstring }

/// Finds targets by designation and name, offline and pure (RG-07 = T1,
/// S7.4). A designation matches ignoring case, spaces, hyphens and leading
/// zeros in its number, with "Messier" read as "M" and "Caldwell" as "C":
/// "M 31", "Messier 31", "NGC 0224" and "C020" all match. A name matches by
/// case-insensitive substring, as before. Results are ordered by how they
/// match (exact designation, designation prefix, name substring), then by
/// the id; no score, no popularity (ADR-013's rule applies to lists).
///
/// A target's designations are its catalog id and, for a catalog row, its
/// designation aliases; its names are its common name, its id (a custom
/// target's id is its name) and its name aliases.
abstract final class TargetSearch {
  static const _synonyms = {'messier': 'm', 'caldwell': 'c'};

  /// The comparable form of a designation: lower case, no spaces or
  /// hyphens, synonyms replaced, and the first number without leading zeros
  /// ("NGC 0224" -> "ngc224", "Caldwell 20" -> "c20").
  static String designationKey(String text) {
    final compact = text.toLowerCase().replaceAll(RegExp(r'[\s\-]+'), '');
    final m = RegExp(r'^([a-z]*)(\d+)(.*)$').firstMatch(compact);
    if (m == null) return compact;
    final prefix = _synonyms[m[1]] ?? m[1]!;
    final digits = m[2]!.replaceFirst(RegExp(r'^0+(?=\d)'), '');
    return '$prefix$digits${m[3]}';
  }

  /// [targets] matching [query], best first; every target, in the given
  /// order, when [query] is blank. [aliases] apply only to catalog rows.
  static List<AstroTarget> search(
    String query,
    List<AstroTarget> targets,
    List<TargetAlias> aliases,
  ) {
    final q = query.trim();
    if (q.isEmpty) return List.of(targets);
    final key = designationKey(q);
    final lower = q.toLowerCase();
    final byId = <String, List<TargetAlias>>{};
    for (final a in aliases) {
      (byId[a.catalogId] ??= []).add(a);
    }

    final found = <(TargetMatchKind, AstroTarget)>[];
    for (final t in targets) {
      final own = isCatalogRow(t) ? byId[t.catalogId] ?? const [] : const [];
      final designations = [
        designationKey(t.catalogId),
        for (final a in own)
          if (a.kind == TargetAliasKind.designation) designationKey(a.alias),
      ];
      final names = [
        t.catalogId,
        if (t.commonName != null) t.commonName!,
        for (final a in own)
          if (a.kind == TargetAliasKind.name) a.alias,
      ];
      final kind = designations.contains(key)
          ? TargetMatchKind.exactDesignation
          : key.isNotEmpty && designations.any((d) => d.startsWith(key))
          ? TargetMatchKind.designationPrefix
          : names.any((n) => n.toLowerCase().contains(lower))
          ? TargetMatchKind.nameSubstring
          : null;
      if (kind != null) found.add((kind, t));
    }
    found.sort((a, b) {
      final byKind = a.$1.index.compareTo(b.$1.index);
      if (byKind != 0) return byKind;
      final byCatalogId = compareIds(a.$2.catalogId, b.$2.catalogId);
      return byCatalogId != 0 ? byCatalogId : a.$2.id.compareTo(b.$2.id);
    });
    return [for (final (_, t) in found) t];
  }

  /// Catalog ids in reading order: letters, then the number as a number
  /// ("M2" before "M10"), then the rest; case-insensitive.
  static int compareIds(String a, String b) {
    final pa = _parts(a), pb = _parts(b);
    final byPrefix = pa.$1.compareTo(pb.$1);
    if (byPrefix != 0) return byPrefix;
    final byNumber = pa.$2.compareTo(pb.$2);
    if (byNumber != 0) return byNumber;
    return pa.$3.compareTo(pb.$3);
  }

  static (String, int, String) _parts(String id) {
    final m = RegExp(r'^([^\d]*?)\s*(\d+)(.*)$').firstMatch(id.toLowerCase());
    if (m == null) return (id.toLowerCase(), -1, '');
    return (m[1]!, int.tryParse(m[2]!) ?? -1, m[3]!);
  }

  /// A row seeded from the bundled catalog (its aliases apply to it).
  static bool isCatalogRow(AstroTarget t) =>
      (t.source?.startsWith('catalog:') ?? false) ||
      (t.source?.startsWith('seed:') ?? false);
}
