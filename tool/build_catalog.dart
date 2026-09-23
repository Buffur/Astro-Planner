// Builds the curated target catalog asset from OpenNGC (TASK 8.2).
//
// OpenNGC (https://github.com/mattiaverga/OpenNGC), release v20260501, by
// Mattia Verga, is licensed CC BY-SA 4.0. The generated asset is an adapted
// subset of it and is distributed under the same licence (see
// assets/catalog/OPENNGC_NOTICE.txt).
//
// Usage (download the two CSV files of that release first):
//   dart run tool/build_catalog.dart <NGC.csv> <addendum.csv>
// Writes assets/catalog/catalog_v2.json. The selection is fixed below; the
// data (coordinates, size, magnitude, names) comes only from OpenNGC.

import 'dart:convert';
import 'dart:io';

import 'package:astroplan/core/utils/astro_math.dart';

const openNgcRelease = 'v20260501';
const catalogVersion = 2;

/// Selected showpieces beyond Messier (owner-approved, TASK 8.2), by their
/// OpenNGC names. Duplicates (`Dup`) are not selectable.
const showpieces = [
  'NGC7000', 'IC5070', 'NGC6960', 'NGC6992', 'NGC6888', 'IC1805', //
  'IC1848', 'NGC0281', 'NGC7635', 'IC1396', 'NGC2237', 'IC0434', //
  'B033', 'NGC2024', 'NGC1499', 'IC0405', 'IC0410', 'NGC2264', //
  'NGC0253', 'NGC0891', 'NGC4565', 'NGC4631', 'NGC2403', 'NGC7331', //
  'NGC6946', 'NGC0869', 'NGC0884', 'NGC7293', 'NGC6543', 'NGC2392', //
  'NGC7662', 'NGC7009', 'NGC3628', 'NGC2359', 'IC0443', 'NGC7380', //
  'NGC1333', 'NGC1977', 'IC5146', 'NGC7023', 'NGC5128', 'NGC3372', //
  'NGC5139', 'NGC0104', 'NGC2070', 'C009', 'Cl399', 'NGC0055', //
  'NGC0300', 'NGC6334', 'NGC6357', 'NGC4038', 'NGC5907', 'IC2944', //
  'ESO056-115',
];

/// OpenNGC object type → the app's target types (fixed-coordinate only).
String appType(String openNgcType) => switch (openNgcType) {
  'G' || 'GPair' || 'GTrpl' || 'GGroup' => 'Galaxy',
  'GCl' => 'Globular Cluster',
  'OCl' => 'Open Cluster',
  'PN' ||
  'HII' ||
  'EmN' ||
  'Neb' ||
  'RfN' ||
  'SNR' ||
  'DrkN' ||
  'Cl+N' => 'Nebula',
  '*' || '**' => 'Star',
  _ => 'Other', // *Ass, Other, …
};

/// `NGC0224` → `NGC 224`, `IC0434` → `IC 434`, `B033` → `B 33`,
/// `C009` → `C 9`, `Cl399` → `Cl 399`; anything else unchanged.
String displayId(String name) {
  final m = RegExp(r'^([A-Za-z]+)0*(\d+)$').firstMatch(name);
  return m == null ? name : '${m[1]} ${m[2]}';
}

/// Splits one `;`-separated line, honouring `"…"` fields that contain `;`
/// (OpenNGC quotes some notes; `""` is an escaped quote).
List<String> splitLine(String line) {
  final fields = <String>[];
  final current = StringBuffer();
  var quoted = false;
  for (var i = 0; i < line.length; i++) {
    final ch = line[i];
    if (ch == '"') {
      if (quoted && i + 1 < line.length && line[i + 1] == '"') {
        current.write('"');
        i++;
      } else {
        quoted = !quoted;
      }
    } else if (ch == ';' && !quoted) {
      fields.add(current.toString());
      current.clear();
    } else {
      current.write(ch);
    }
  }
  fields.add(current.toString());
  return fields;
}

List<Map<String, String>> readCsv(String path) {
  final lines = File(path).readAsLinesSync(encoding: utf8);
  final header = splitLine(lines.first);
  return [
    for (final line in lines.skip(1).where((l) => l.trim().isNotEmpty))
      Map.fromIterables(header, splitLine(line)),
  ];
}

double? number(String? text) =>
    (text == null || text.trim().isEmpty) ? null : double.parse(text);

Map<String, Object?> entry(Map<String, String> row, String id) {
  final ra = AstroMath.parseRightAscension(row['RA']!);
  final dec = AstroMath.parseDeclination(row['Dec']!);
  if (ra == null || dec == null) {
    throw StateError('Unparseable coordinates for ${row['Name']}');
  }
  final names = row['Common names']!.split(',').where((n) => n.isNotEmpty);
  return {
    'id': id,
    'name': names.isEmpty ? null : names.first.trim(),
    'type': appType(row['Type']!),
    'ra': double.parse(ra.toStringAsFixed(7)),
    'dec': double.parse(dec.toStringAsFixed(7)),
    'sizeArcmin': number(row['MajAx']),
    'vMag': number(row['V-Mag']),
    'openNgc': row['Name'],
    'openNgcRa': row['RA'],
    'openNgcDec': row['Dec'],
    'since': catalogVersion,
  };
}

void main(List<String> args) {
  if (args.length != 2) {
    stderr.writeln(
      'usage: dart run tool/build_catalog.dart NGC.csv addendum.csv',
    );
    exit(64);
  }
  final rows = [...readCsv(args[0]), ...readCsv(args[1])];
  final byName = {for (final r in rows) r['Name']!: r};

  final objects = <Map<String, Object?>>[];
  final messier = <int, Map<String, String>>{};
  for (final r in rows) {
    final m = r['M'];
    if (m == null || m.isEmpty || r['Type'] == 'Dup') continue;
    messier[int.parse(m)] = r;
  }
  for (final n in messier.keys.toList()..sort()) {
    objects.add(entry(messier[n]!, 'M$n'));
  }
  for (final name in showpieces) {
    final row = byName[name];
    if (row == null || row['Type'] == 'Dup' || row['M']!.isNotEmpty) {
      throw StateError('Not a selectable showpiece: $name');
    }
    objects.add(entry(row, displayId(name)));
  }
  final ids = objects.map((o) => o['id']).toSet();
  if (ids.length != objects.length) throw StateError('Duplicate ids');

  final asset = {
    'version': catalogVersion,
    'source': 'catalog:openngc@$openNgcRelease',
    'licence':
        'CC BY-SA 4.0 (adapted subset of OpenNGC $openNgcRelease, '
        'by Mattia Verga; see OPENNGC_NOTICE.txt)',
    'epoch': 'J2000',
    'objects': objects,
  };
  final out = File('assets/catalog/catalog_v2.json')
    ..createSync(recursive: true)
    ..writeAsStringSync(
      '${const JsonEncoder.withIndent(' ').convert(asset)}\n',
    );
  stdout.writeln(
    'Wrote ${objects.length} objects (${messier.length} Messier) to ${out.path}',
  );
}
