import 'dart:convert';

import 'package:drift/drift.dart';

/// Stores a JSON object in a TEXT column (ADR-014 §4; TASK 11.2): the
/// session snapshots. The map is written as-is — its `v` key carries the
/// snapshot format version, which the snapshot readers (TASK 11.3) check.
///
/// Text that is not a JSON object reads as an empty map, so one damaged
/// snapshot can never break a whole list query; an empty map has no known
/// `v`, which readers treat as "snapshot unavailable" (never as zeros,
/// SI-008).
class JsonMapConverter extends TypeConverter<Map<String, Object?>, String> {
  const JsonMapConverter();

  @override
  Map<String, Object?> fromSql(String fromDb) {
    try {
      final decoded = jsonDecode(fromDb);
      if (decoded is Map<String, Object?>) return decoded;
    } on FormatException {
      // Falls through to the empty map.
    }
    return const {};
  }

  @override
  String toSql(Map<String, Object?> value) => jsonEncode(value);
}
