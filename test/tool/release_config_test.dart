// TASK 16.2: release signing and the bundle check. Signing secrets never
// enter the repository; the release build takes the upload key from the
// gitignored android/key.properties; tool/check_bundle.dart reads the ELF
// facts Play checks (16 KB LOAD alignment, no debug sections left).

import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';

import '../../tool/check_bundle.dart';

/// A minimal little-endian ELF with the given PT_LOAD alignments and
/// section names ([is64] picks the class).
Uint8List _elf({
  required bool is64,
  required List<int> loadAligns,
  List<String> sections = const [],
}) {
  final ehsize = is64 ? 64 : 52;
  final phentsize = is64 ? 56 : 32;
  final shentsize = is64 ? 64 : 40;
  final names = <int>[0]; // the string table starts with an empty name
  final nameOffsets = <int>[];
  for (final s in [...sections, '.shstrtab']) {
    nameOffsets.add(names.length);
    names
      ..addAll(s.codeUnits)
      ..add(0);
  }
  final phoff = ehsize;
  final strOff = phoff + phentsize * loadAligns.length;
  final shoff = strOff + names.length;
  final shnum = 1 + nameOffsets.length; // a null section, then the named ones
  final size = shoff + shentsize * shnum;
  final d = ByteData(size);
  void u16(int o, int v) => d.setUint16(o, v, Endian.little);
  void u32(int o, int v) => d.setUint32(o, v, Endian.little);
  void word(int o, int v) =>
      is64 ? d.setUint64(o, v, Endian.little) : u32(o, v);

  for (final (i, b) in [0x7f, 0x45, 0x4c, 0x46, is64 ? 2 : 1, 1].indexed) {
    d.setUint8(i, b);
  }
  word(is64 ? 0x20 : 0x1C, phoff);
  word(is64 ? 0x28 : 0x20, shoff);
  u16(is64 ? 0x36 : 0x2A, phentsize);
  u16(is64 ? 0x38 : 0x2C, loadAligns.length);
  u16(is64 ? 0x3A : 0x2E, shentsize);
  u16(is64 ? 0x3C : 0x30, shnum);
  u16(is64 ? 0x3E : 0x32, shnum - 1); // .shstrtab is the last section
  for (final (i, align) in loadAligns.indexed) {
    final p = phoff + i * phentsize;
    u32(p, 1); // PT_LOAD
    word(p + (is64 ? 0x30 : 0x1C), align);
  }
  for (final (i, b) in names.indexed) {
    d.setUint8(strOff + i, b);
  }
  for (final (i, nameOff) in nameOffsets.indexed) {
    final s = shoff + (i + 1) * shentsize;
    u32(s, nameOff);
    word(s + (is64 ? 0x18 : 0x10), strOff); // sh_offset (read for shstrtab)
  }
  return d.buffer.asUint8List();
}

void main() {
  group('the ELF check', () {
    test('64-bit: 16 KB and 64 KB alignments pass', () {
      final f = readElf(_elf(is64: true, loadAligns: [0x4000, 0x10000]));
      expect(f.loadAlignments, [0x4000, 0x10000]);
      expect(f.aligned16k, isTrue);
      expect(f.debugSections, isEmpty);
    });

    test('32-bit: a 4 KB segment fails', () {
      final f = readElf(_elf(is64: false, loadAligns: [0x4000, 0x1000]));
      expect(f.loadAlignments, [0x4000, 0x1000]);
      expect(f.aligned16k, isFalse);
    });

    test('debug sections are found; other sections are not', () {
      final f = readElf(
        _elf(
          is64: true,
          loadAligns: [0x4000],
          sections: ['.text', '.debug_info', '.rodata', '.debug_line'],
        ),
      );
      expect(f.debugSections, ['.debug_info', '.debug_line']);
    });

    test('a library without LOAD segments is not called aligned', () {
      expect(readElf(_elf(is64: true, loadAligns: [])).aligned16k, isFalse);
    });

    test('anything but an ELF is refused', () {
      expect(
        () => readElf(Uint8List.fromList(List.filled(64, 0))),
        throwsFormatException,
      );
    });
  });

  group('release signing', () {
    test('signing secrets are gitignored at the root and in android/', () {
      final root = File('.gitignore').readAsLinesSync();
      final android = File('android/.gitignore').readAsLinesSync();
      for (final p in ['key.properties', '*.jks', '*.keystore']) {
        expect(root, contains(p));
      }
      expect(android, contains('key.properties'));
      expect(android, contains('**/*.jks'));
    });

    test('the release build takes the upload key from key.properties, '
        'with no secret in the build file', () {
      final gradle = File('android/app/build.gradle.kts').readAsStringSync();
      expect(gradle, contains('rootProject.file("key.properties")'));
      expect(gradle, contains('create("release")'));
      expect(gradle, contains('signingConfigs.getByName("release")'));
      for (final key in ['storePassword', 'keyPassword', 'keyAlias']) {
        expect(
          gradle,
          contains('$key = keystoreProperties.getProperty("$key")'),
        );
        expect(gradle, isNot(contains(RegExp('$key\\s*=\\s*"'))));
      }
      // The debug key is only the fallback when key.properties is absent.
      expect(gradle, contains('if (hasUploadKey)'));
    });

    test('the version is "x.y.z+code" with a positive version code', () {
      final line = File('pubspec.yaml')
          .readAsLinesSync()
          .firstWhere((l) => l.startsWith('version:'));
      final m = RegExp(r'^version: (\d+)\.(\d+)\.(\d+)\+(\d+)$')
          .firstMatch(line.trim());
      expect(m, isNotNull, reason: line);
      expect(int.parse(m!.group(4)!), greaterThan(0));
    });
  });
}
