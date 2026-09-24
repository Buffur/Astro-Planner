// Checks a release app bundle before it is uploaded (TASK 16.2,
// docs/RELEASE.md):
//   - every native library (.so) has its LOAD segments aligned to at least
//     16 KB, as Google Play requires for Android 15+ devices;
//   - no native library still carries DWARF debug sections (they belong in
//     BUNDLE-METADATA, where Play reads them for crash reports);
//   - the bundle is not signed with the Android debug key (via `keytool`,
//     when it is on the PATH or in Android Studio's JBR).
//
// Usage:
//   dart run tool/check_bundle.dart [build/app/outputs/bundle/release/app-release.aab]
//
// Exits non-zero when a check fails. Reads the bundle only; never touches
// the keystore or its passwords.

import 'dart:io';
import 'dart:typed_data';

import 'package:archive/archive.dart';

/// Play's minimum ELF segment alignment for 16 KB page-size devices.
const int kMinAlignment = 0x4000;

/// What one native library looks like.
class ElfFacts {
  const ElfFacts({required this.loadAlignments, required this.debugSections});

  /// `p_align` of every PT_LOAD program header.
  final List<int> loadAlignments;

  /// Section names starting with `.debug_`.
  final List<String> debugSections;

  bool get aligned16k =>
      loadAlignments.isNotEmpty &&
      loadAlignments.every((a) => a >= kMinAlignment);
}

/// Reads the program headers and section names of an ELF file (32 or
/// 64 bit, little endian — every Android ABI). Throws [FormatException]
/// for anything else.
ElfFacts readElf(Uint8List bytes) {
  if (bytes.length < 52 ||
      bytes[0] != 0x7f ||
      bytes[1] != 0x45 || // E
      bytes[2] != 0x4c || // L
      bytes[3] != 0x46) {
    throw const FormatException('not an ELF file');
  }
  final is64 = bytes[4] == 2;
  if (bytes[5] != 1) throw const FormatException('not little-endian');
  final d = ByteData.sublistView(bytes);
  int u16(int o) => d.getUint16(o, Endian.little);
  int u32(int o) => d.getUint32(o, Endian.little);
  int word(int o) => is64 ? d.getUint64(o, Endian.little) : u32(o);

  final phoff = word(is64 ? 0x20 : 0x1C);
  final shoff = word(is64 ? 0x28 : 0x20);
  final phentsize = u16(is64 ? 0x36 : 0x2A);
  final phnum = u16(is64 ? 0x38 : 0x2C);
  final shentsize = u16(is64 ? 0x3A : 0x2E);
  final shnum = u16(is64 ? 0x3C : 0x30);
  final shstrndx = u16(is64 ? 0x3E : 0x32);

  const ptLoad = 1;
  final aligns = <int>[];
  for (var i = 0; i < phnum; i++) {
    final p = phoff + i * phentsize;
    if (u32(p) != ptLoad) continue;
    aligns.add(word(p + (is64 ? 0x30 : 0x1C)));
  }

  final debug = <String>[];
  if (shoff != 0 && shnum > 0 && shstrndx < shnum) {
    int shOffset(int index) =>
        word(shoff + index * shentsize + (is64 ? 0x18 : 0x10));
    final names = shOffset(shstrndx);
    for (var i = 0; i < shnum; i++) {
      final nameOff = u32(shoff + i * shentsize);
      var end = names + nameOff;
      while (end < bytes.length && bytes[end] != 0) {
        end++;
      }
      final name = String.fromCharCodes(bytes.sublist(names + nameOff, end));
      if (name.startsWith('.debug_')) debug.add(name);
    }
  }
  return ElfFacts(loadAlignments: aligns, debugSections: debug);
}

String? _keytool() {
  final candidates = [
    'keytool',
    if (Platform.isWindows)
      r'C:\Program Files\Android\Android Studio\jbr\bin\keytool.exe',
    if (Platform.isMacOS)
      '/Applications/Android Studio.app/Contents/jbr/Contents/Home/bin/keytool',
  ];
  for (final c in candidates) {
    try {
      final r = Process.runSync(c, ['-help'], runInShell: Platform.isWindows);
      if (r.exitCode == 0) return c;
    } on ProcessException {
      continue;
    }
  }
  return null;
}

void main(List<String> args) {
  final path = args.isNotEmpty
      ? args.first
      : 'build/app/outputs/bundle/release/app-release.aab';
  final file = File(path);
  if (!file.existsSync()) {
    stderr.writeln(
      'No bundle at $path. Build it with: flutter build appbundle',
    );
    exit(2);
  }
  final archive = ZipDecoder().decodeBytes(file.readAsBytesSync());
  var ok = true;

  final libs =
      archive.files
          .where(
            (f) =>
                f.isFile && f.name.contains('/lib/') && f.name.endsWith('.so'),
          )
          .toList()
        ..sort((a, b) => a.name.compareTo(b.name));
  if (libs.isEmpty) {
    stderr.writeln('No native libraries found in $path.');
    ok = false;
  }
  for (final lib in libs) {
    final facts = readElf(Uint8List.fromList(lib.content as List<int>));
    final aligns = facts.loadAlignments
        .map((a) => '0x${a.toRadixString(16)}')
        .toSet()
        .join(',');
    final problems = [
      if (!facts.aligned16k) 'NOT 16 KB aligned',
      if (facts.debugSections.isNotEmpty) 'debug sections left',
    ];
    ok &= problems.isEmpty;
    stdout.writeln(
      '${problems.isEmpty ? 'ok  ' : 'FAIL'}  ${lib.name}  align=$aligns'
      '${problems.isEmpty ? '' : '  (${problems.join('; ')})'}',
    );
  }

  final keytool = _keytool();
  if (keytool == null) {
    stdout.writeln(
      'skip  signer: keytool not found (install a JDK or Android Studio)',
    );
  } else {
    final r = Process.runSync(keytool, [
      '-printcert',
      '-jarfile',
      path,
    ], runInShell: Platform.isWindows);
    final out = '${r.stdout}';
    final owner = RegExp(r'Owner: (.*)').firstMatch(out)?.group(1)?.trim();
    if (owner == null) {
      stdout.writeln('FAIL  signer: the bundle is not signed');
      ok = false;
    } else if (owner.contains('CN=Android Debug')) {
      stdout.writeln(
        'FAIL  signer: $owner — the DEBUG key; Play rejects it. '
        'Create android/key.properties (docs/RELEASE.md) and rebuild.',
      );
      ok = false;
    } else {
      stdout.writeln('ok    signer: $owner');
    }
  }

  stdout.writeln(ok ? '\nBundle check passed.' : '\nBundle check FAILED.');
  exit(ok ? 0 : 1);
}
