// S2.4 (ADR-017 §6): the Dart side of Android document access, against a
// host stand-in for MetadataDocumentChannel.kt. The Kotlin side itself needs
// a device (the device check in POST_ROADMAP_PLAN's S2.4).

import 'package:astroplan/data/metadata/android_capture_file_access.dart';
import 'package:astroplan/domain/metadata/capture_metadata.dart';
import 'package:astroplan/domain/metadata/capture_metadata_reader.dart';
import 'package:astroplan/domain/metadata/metadata_source.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/tiff_fixture.dart';

Matcher _fails(MetadataReadError error) => throwsA(
  isA<MetadataReadException>().having((e) => e.error, 'error', error),
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const channel = MethodChannel(AndroidCaptureFileAccess.channelName);
  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;

  late Uint8List document;
  late List<MethodCall> calls;
  Object? Function(MethodCall call)? override;

  setUp(() {
    document = (TiffFixture()..ifd0.addAll(phoneStyleDngIfd0())).build().bytes;
    calls = [];
    override = null;
    messenger.setMockMethodCallHandler(channel, (call) async {
      calls.add(call);
      if (override case final handle?) return handle(call);
      final args = call.arguments as Map<Object?, Object?>?;
      return switch (call.method) {
        'pick' => {
          'uri': 'content://test.documents/document/1',
          'name': 'capture.dng',
          'size': 25 << 20,
        },
        'read' => () {
          final offset = args!['offset']! as int;
          final count = args['count']! as int;
          // Past the fixture's metadata the "pixels" read as zeros.
          return Uint8List(count)..setRange(
            0,
            (document.length - offset).clamp(0, count),
            document.skip(offset),
          );
        }(),
        _ => throw MissingPluginException(),
      };
    });
  });

  tearDown(() => messenger.setMockMethodCallHandler(channel, null));

  test('a picked document is read in ranges through its URI', () async {
    final file = await AndroidCaptureFileAccess().pick();
    expect(file!.name, 'capture.dng');
    final source = BudgetedMetadataSource(await file.open());
    expect(source.length, 25 << 20);

    final reading = await CaptureMetadataReader.read(source);
    expect(
      (reading as MetadataRead).metadata.exposureSeconds.valueOrNull,
      30.0,
    );
    expect(source.bytesRead, lessThanOrEqualTo(64 * 1024));

    final reads = calls.where((c) => c.method == 'read').toList();
    expect(reads, isNotEmpty);
    for (final c in reads) {
      final args = c.arguments as Map<Object?, Object?>;
      expect(args['uri'], 'content://test.documents/document/1');
      expect(args['count'], lessThanOrEqualTo(64 * 1024));
      expect(
        args['sequentialLimit'],
        BudgetedMetadataSource.defaultBudgetBytes,
      );
    }
    await source.close();
    await expectLater(source.read(0, 1), _fails(MetadataReadError.io));
  });

  test('a cancelled pick is null, not an error', () async {
    override = (_) => null;
    expect(await AndroidCaptureFileAccess().pick(), isNull);
  });

  test('platform errors become typed I/O failures', () async {
    override = (call) => throw PlatformException(
      code: call.method == 'pick' ? 'busy' : 'revoked',
    );
    await expectLater(
      AndroidCaptureFileAccess().pick(),
      _fails(MetadataReadError.io),
    );

    override = null;
    final file = (await AndroidCaptureFileAccess().pick())!;
    final source = await file.open();
    override = (_) => throw PlatformException(code: 'revoked');
    await expectLater(source.read(0, 8), _fails(MetadataReadError.io));
  });

  test(
    'a short answer is a typed failure; bad ranges never reach Android',
    () async {
      final file = (await AndroidCaptureFileAccess().pick())!;
      final source = await file.open();
      override = (_) => Uint8List(3);
      await expectLater(source.read(0, 8), _fails(MetadataReadError.io));
      override = (_) => null;
      await expectLater(source.read(0, 8), _fails(MetadataReadError.io));

      final before = calls.length;
      await expectLater(
        source.read((25 << 20) - 4, 8),
        _fails(MetadataReadError.outOfRange),
      );
      await expectLater(
        source.read(-1, 8),
        _fails(MetadataReadError.outOfRange),
      );
      expect(calls.length, before);
    },
  );

  test('a document without a known size is not opened', () async {
    override = (call) => call.method == 'pick'
        ? {'uri': 'content://x/1', 'name': null, 'size': null}
        : null;
    final file = (await AndroidCaptureFileAccess().pick())!;
    expect(file.name, isNull);
    await expectLater(file.open(), _fails(MetadataReadError.io));
  });
}
