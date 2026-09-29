import '../../core/utils/quantity_text.dart';
import '../../domain/models/capture_block.dart';
import '../../domain/services/calibration_match.dart';
import 'block_text.dart';

/// The words for calibration blocks (S7.3a; ADR-020 §6–§7; RG-10 §6's
/// candidate tips). Warnings say what does not match, in words; tips are
/// short, with more one tap away.
abstract final class CalibrationText {
  /// The display-preference key for "Hide tips" (remembered on the device).
  static const tipsKey = 'tips.calibration';

  static String mismatch(CalibrationMismatch m, FrameType type) => switch (m) {
    CalibrationMismatch.matchesNoLight =>
      type == FrameType.bias
          ? 'Matches no light block (ISO or gain, binning)'
          : 'Matches no light block (exposure, ISO or gain, binning)',
    CalibrationMismatch.filterUnused => 'No light block uses this filter',
    CalibrationMismatch.binningMatchesNoLight =>
      'Its binning matches no light block',
    CalibrationMismatch.matchesNoFlat =>
      'Matches no flat block (exposure, ISO or gain, binning)',
  };

  /// The one-tap fix's label.
  static String match(FrameType type) =>
      type == FrameType.darkFlat ? 'Match the flats' : 'Match the lights';

  /// The light filters without flats, when the plan has flats.
  static String flatsMissing(List<String?> filters) =>
      'No flats for: ${[for (final f in filters) f ?? 'no filter'].join(', ')}';

  /// The values a new calibration block takes from [source] (ADR-020 §6).
  static String inherited(
    FrameType type,
    CaptureBlock source, {
    required bool withBinning,
  }) {
    final parts = [
      if (type == FrameType.flat)
        'filter ${source.filterName ?? 'none'}'
      else if (type != FrameType.bias)
        'exposure ${QuantityText.exposure(source.exposureTimeSeconds)}',
      if (type != FrameType.flat) sensitivity(source.gain),
      if (withBinning) '${source.binning} × ${source.binning} binning',
    ];
    return 'From ${BlockText.row(source, null)}: ${parts.join(', ')}';
  }

  /// A recorded ISO or gain, never called "sensitivity" (SI-004).
  static String sensitivity(CaptureGain g) => switch (g.kind) {
    _ when g.value == null => 'ISO or gain not recorded',
    GainKind.iso => 'ISO ${_trim(g.value!)}',
    GainKind.gain => 'gain ${_trim(g.value!)}',
    GainKind.unknown => 'ISO or gain ${_trim(g.value!)}',
  };

  static String _trim(double v) =>
      v == v.roundToDouble() ? v.toInt().toString() : v.toString();

  /// One line per calibration type, and more on demand (RG-10 §6).
  static (String, String)? tip(FrameType type) => switch (type) {
    FrameType.light => null,
    FrameType.dark => (
      'Lens or scope covered; the same exposure, ISO or gain and binning as '
          'the lights, at a similar temperature.',
      'Take darks during or right after the session, while the camera is at '
          "the lights' temperature; a cooled camera can reuse a library at "
          'the same set point. Processing software needs them to match.',
    ),
    FrameType.flat => (
      'Evenly lit, not saturated; the same focus, camera position and filter '
          'as the lights.',
      'Flats record the vignetting and dust of this optical train, so take '
          "them before anything moves, per filter, at the lights' binning. "
          'Their exposure comes from the light source, not from the lights.',
    ),
    FrameType.bias => (
      'Covered, at the shortest exposure; the same ISO or gain as the lights.',
      'Temperature does not matter. Some astro cameras give unstable short '
          'exposures: dark flats replace bias for them.',
    ),
    FrameType.darkFlat => (
      'Covered; the same exposure and ISO or gain as your flats.',
      'Dark flats remove the dark signal from flats, instead of bias where '
          'short exposures are unreliable.',
    ),
  };
}
