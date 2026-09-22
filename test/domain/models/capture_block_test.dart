import 'package:astroplan/domain/models/capture_block.dart';
import 'package:astroplan/domain/models/session_log.dart';
import 'package:flutter_test/flutter_test.dart';

CaptureBlock _light({
  double exposure = 60,
  int count = 10,
  int binning = 1,
  String? filter,
}) => CaptureBlock(
  frameType: FrameType.light,
  exposureTimeSeconds: exposure,
  frameCount: count,
  binning: binning,
  filterName: filter,
);

void main() {
  group('CaptureBlock validation (TASK 5.3: invalid blocks cannot exist)', () {
    test('rejects non-positive, non-finite and over-bound exposures', () {
      for (final bad in [0.0, -1.0, double.nan, double.infinity, 3600.001]) {
        expect(
          () => _light(exposure: bad),
          throwsArgumentError,
          reason: '$bad',
        );
      }
      expect(_light(exposure: 3600).exposureTimeSeconds, 3600);
      expect(_light(exposure: 0.001).exposureTimeSeconds, 0.001);
    });

    test('rejects frame counts outside [1, 100000]', () {
      expect(() => _light(count: 0), throwsArgumentError);
      expect(() => _light(count: -5), throwsArgumentError);
      expect(() => _light(count: 100001), throwsArgumentError);
      expect(_light(count: 1).frameCount, 1);
      expect(_light(count: 100000).frameCount, 100000);
    });

    test('rejects binning outside [1, 4]', () {
      expect(() => _light(binning: 0), throwsArgumentError);
      expect(() => _light(binning: 5), throwsArgumentError);
      expect(_light(binning: 4).binning, 4);
    });

    test('filter name is trimmed; blank means none; too long rejected', () {
      expect(_light(filter: '  Ha ').filterName, 'Ha');
      expect(_light(filter: '   ').filterName, isNull);
      expect(() => _light(filter: 'x' * 33), throwsArgumentError);
    });

    test('copyWith validates too', () {
      expect(() => _light().copyWith(frameCount: 0), throwsArgumentError);
    });
  });

  group('calibration policy (ADR-009 §3)', () {
    test('lights have none, and passing one is rejected', () {
      expect(_light().calibrationPolicy, isNull);
      expect(
        () => CaptureBlock(
          frameType: FrameType.light,
          exposureTimeSeconds: 60,
          frameCount: 1,
          calibrationPolicy: CalibrationPolicy.inWindow,
        ),
        throwsArgumentError,
      );
    });

    test('calibration frames default to outsideWindow', () {
      for (final t in [FrameType.dark, FrameType.flat, FrameType.bias]) {
        final b = CaptureBlock(
          frameType: t,
          exposureTimeSeconds: 1,
          frameCount: 1,
        );
        expect(b.calibrationPolicy, CalibrationPolicy.outsideWindow);
      }
    });

    test('changing type through copyWith keeps the invariant', () {
      final dark = CaptureBlock(
        frameType: FrameType.dark,
        exposureTimeSeconds: 60,
        frameCount: 5,
        calibrationPolicy: CalibrationPolicy.library,
      );
      expect(
        dark.copyWith(frameType: FrameType.light).calibrationPolicy,
        isNull,
      );
      expect(
        _light().copyWith(frameType: FrameType.flat).calibrationPolicy,
        CalibrationPolicy.outsideWindow,
      );
      expect(
        dark.copyWith(frameCount: 6).calibrationPolicy,
        CalibrationPolicy.library,
      );
    });
  });

  group('CaptureGain (descriptive only, SI-004)', () {
    test('typed constructors validate their ranges', () {
      expect(CaptureGain.iso(800).kind, GainKind.iso);
      expect(() => CaptureGain.iso(0), throwsArgumentError);
      expect(CaptureGain.gain(0).value, 0);
      expect(() => CaptureGain.gain(-1), throwsArgumentError);
      expect(() => CaptureGain.unknown(double.nan), throwsArgumentError);
      expect(CaptureGain.none.kind, GainKind.unknown);
      expect(CaptureGain.none.value, isNull);
    });

    test('fromStored round-trips and never invents a kind', () {
      expect(CaptureGain.fromStored('iso', 1600), CaptureGain.iso(1600));
      expect(CaptureGain.fromStored('gain', 120), CaptureGain.gain(120));
      expect(CaptureGain.fromStored('unknown', 100), CaptureGain.unknown(100));
      expect(CaptureGain.fromStored('weird', null), CaptureGain.none);
    });
  });

  test(
    'frame type parsing is case-insensitive and never defaults to light',
    () {
      expect(CaptureBlock.tryParseFrameType('DARK'), FrameType.dark);
      expect(CaptureBlock.tryParseFrameType(' Flat '), FrameType.flat);
      expect(CaptureBlock.tryParseFrameType('lights'), isNull);
      expect(CaptureBlock.tryParseFrameType(null), isNull);
    },
  );

  group('session manifest blocks', () {
    Map<String, dynamic> manifest(List<Map<String, dynamic>> blocks) => {
      'target_name': 'M31',
      'equipment_name': 'Rig',
      'session_date_utc': '2026-09-22T01:30:00.000Z',
      'capture_plan': {'blocks': blocks},
    };

    test('typed gain and policy round trip through toJson/fromJson', () {
      final log = SessionLog(
        id: 1,
        targetName: 'M31',
        equipmentName: 'Rig',
        sessionDate: DateTime.utc(2026, 9, 22),
        captureBlocks: [
          CaptureBlock(
            frameType: FrameType.light,
            exposureTimeSeconds: 300,
            frameCount: 20,
            gain: CaptureGain.iso(800),
          ),
          CaptureBlock(
            frameType: FrameType.dark,
            exposureTimeSeconds: 300,
            frameCount: 10,
            calibrationPolicy: CalibrationPolicy.library,
          ),
        ],
      );
      final back = SessionLog.fromJson(log.toJson());
      expect(back.captureBlocks[0].gain, CaptureGain.iso(800));
      expect(
        back.captureBlocks[1].calibrationPolicy,
        CalibrationPolicy.library,
      );
    });

    test(
      'legacy gain_iso reads as unknown kind; invalid blocks are skipped',
      () {
        final log = SessionLog.fromJson(
          manifest([
            {
              'frame_type': 'light',
              'exposure_seconds': 60,
              'frame_count': 5,
              'gain_iso': '100',
            },
            {'frame_type': 'dark', 'exposure_seconds': 0, 'frame_count': 5},
            {'frame_type': 'mystery', 'exposure_seconds': 60, 'frame_count': 5},
          ]),
        );
        expect(log.captureBlocks, hasLength(1));
        expect(log.captureBlocks.single.gain, CaptureGain.unknown(100));
      },
    );
  });
}
