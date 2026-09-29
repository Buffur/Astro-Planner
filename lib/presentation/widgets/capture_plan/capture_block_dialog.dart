import 'package:flutter/material.dart';

import '../../../domain/models/camera_class.dart';
import '../../../domain/models/capture_block.dart';
import '../../../domain/services/calibration_match.dart';
import '../../shared/block_text.dart';
import '../../shared/calibration_text.dart';

const _filters = ['L', 'R', 'G', 'B', 'Ha', 'OIII', 'SII', 'OSC', 'None'];

/// Add/edit dialog for one capture block (TASK 4.1; policy, binning and a
/// typed gain added in TASK 5.6). Validation mirrors the domain bounds
/// (TASK 5.3), so an invalid block can never be submitted. It returns the
/// block (null when cancelled) and changes nothing itself: the caller adds
/// it, or applies an edit with Undo (TD-079, S6.16). [initial] makes it an
/// edit of that block.
///
/// S7.2b (ADR-020 §3, §5): a light block shows what applies to the rig's
/// [cameraClass]: ISO for phones and cameras, gain for astro cameras, the
/// choice for Unknown; binning only for astro cameras and Unknown. A value
/// the class does not show is kept as recorded, and named. A new light block
/// starts from [proposal] (the plan's last light block): its exposure, ISO
/// or gain and binning, marked as a proposal and stored only on Add.
///
/// S7.3a (ADR-020 §6–§7; RG-10 = L1, D1, H1): a new dark, bias, flat or dark
/// flat takes what it must match from a block of the plan's [blocks] (a
/// light, or a flat for a dark flat; the first by default), shown with its
/// origin; "Use other values" makes those fields the user's. A short tip per
/// calibration type, more on demand, hideable ([tipsShown], [onTipsShown]).
Future<CaptureBlock?> showCaptureBlockDialog(
  BuildContext context, {
  CaptureBlock? initial,
  CameraClass cameraClass = CameraClass.unknown,
  CaptureBlock? proposal,
  List<CaptureBlock> blocks = const [],
  bool tipsShown = true,
  ValueChanged<bool>? onTipsShown,
}) {
  return showDialog<CaptureBlock>(
    context: context,
    builder: (ctx) => _CaptureBlockDialog(
      initial: initial,
      cameraClass: cameraClass,
      proposal: initial == null ? proposal : null,
      blocks: blocks,
      tipsShown: tipsShown,
      onTipsShown: onTipsShown,
    ),
  );
}

class _CaptureBlockDialog extends StatefulWidget {
  const _CaptureBlockDialog({
    required this.initial,
    required this.cameraClass,
    required this.proposal,
    required this.blocks,
    required this.tipsShown,
    required this.onTipsShown,
  });

  final CaptureBlock? initial;
  final CameraClass cameraClass;
  final CaptureBlock? proposal;
  final List<CaptureBlock> blocks;
  final bool tipsShown;
  final ValueChanged<bool>? onTipsShown;

  @override
  State<_CaptureBlockDialog> createState() => _CaptureBlockDialogState();
}

class _CaptureBlockDialogState extends State<_CaptureBlockDialog> {
  final _formKey = GlobalKey<FormState>();
  late FrameType _type;
  late String _filter;
  late int _binning;
  late GainKind _gainKind;
  late CalibrationPolicy _policy;
  late final TextEditingController _exposure;
  late final TextEditingController _count;
  late final TextEditingController _gainValue;
  late bool _tipsShown = widget.tipsShown;
  bool _tipMore = false;

  /// S7.3a: which of the plan's blocks a new calibration block matches, and
  /// whether it still takes its values from it (until "Use other values").
  int _sourceIndex = 0;
  bool _inherit = true;

  List<CaptureBlock> get _sources =>
      CalibrationMatch.sourcesFor(_type, widget.blocks);

  /// The block a new calibration block takes its values from, while it does.
  CaptureBlock? get _inheritFrom {
    if (widget.initial != null || _type == FrameType.light || !_inherit) {
      return null;
    }
    final sources = _sources;
    return sources.isEmpty
        ? null
        : sources[_sourceIndex.clamp(0, sources.length - 1)];
  }

  /// The recorded values this dialog starts from: the block being edited,
  /// else the proposal (S7.2b), else nothing.
  CaptureBlock? get _source => widget.initial ?? widget.proposal;

  /// The sensitivity kind a block of this class records (ADR-020 §3; RG-10
  /// §4 gives calibration frames the lights' kind); null when the user
  /// chooses it (Unknown).
  GainKind? get _fixedKind => switch (widget.cameraClass.lightSensitivity) {
    LightSensitivity.iso => GainKind.iso,
    LightSensitivity.gain => GainKind.gain,
    LightSensitivity.either => null,
  };

  GainKind get _kind => _fixedKind ?? _gainKind;

  /// Binning, for every frame type, only where the class offers it (RG-10
  /// §4: not applicable for phones and cameras, where it is the rig's mode).
  bool get _showBinning => widget.cameraClass.offersLightBinning;

  @override
  void initState() {
    super.initState();
    final i = widget.initial;
    final from = _source;
    _type = i?.frameType ?? FrameType.light;
    _filter = i?.filterName ?? 'L';
    if (!_filters.contains(_filter)) _filter = 'None';
    _binning = from?.binning ?? 1;
    _gainKind = from?.gain.kind ?? GainKind.unknown;
    _policy = i?.calibrationPolicy ?? CalibrationPolicy.outsideWindow;
    _exposure = TextEditingController(
      text: from == null ? '' : _trimZeros(from.exposureTimeSeconds),
    );
    _count = TextEditingController(text: i?.frameCount.toString() ?? '');
    // A value of another kind than this class records stays as it was and
    // is named instead of being shown in the field (ADR-020 §3).
    final gv = from?.gain.value;
    final shown = _fixedKind == null || from?.gain.kind == _fixedKind;
    _gainValue = TextEditingController(
      text: gv == null || !shown ? '' : _trimZeros(gv),
    );
  }

  @override
  void dispose() {
    _exposure.dispose();
    _count.dispose();
    _gainValue.dispose();
    super.dispose();
  }

  /// Whole numbers print without a trailing ".0" (60.0 -> "60").
  static String _trimZeros(double value) => value == value.roundToDouble()
      ? value.toInt().toString()
      : value.toString();

  String? _validateGain(String? value) {
    final text = (value ?? '').trim();
    if (_kind == GainKind.unknown || text.isEmpty) return null;
    final v = double.tryParse(text);
    if (_kind == GainKind.iso) {
      if (v == null || v != v.roundToDouble() || v < 1 || v > 1000000) {
        return 'ISO is a whole number from 1 to 1000000';
      }
    } else if (v == null || v < 0 || v > 10000) {
      return 'Gain is a number from 0 to 10000';
    }
    return null;
  }

  CaptureGain _gain() {
    final v = double.tryParse(_gainValue.text.trim());
    final fixed = _fixedKind;
    if (fixed != null) {
      if (v != null) {
        return fixed == GainKind.iso
            ? CaptureGain.iso(v.round())
            : CaptureGain.gain(v);
      }
      // Cleared: none; a value of another kind is kept as recorded.
      final kept = widget.initial?.gain ?? CaptureGain.none;
      return kept.kind == fixed ? CaptureGain.none : kept;
    }
    switch (_gainKind) {
      case GainKind.iso:
        return v == null ? CaptureGain.none : CaptureGain.iso(v.round());
      case GainKind.gain:
        return v == null ? CaptureGain.none : CaptureGain.gain(v);
      case GainKind.unknown:
        return widget.initial?.gain.kind == GainKind.unknown
            ? widget
                  .initial!
                  .gain // keep a legacy unknown-kind value
            : CaptureGain.none;
    }
  }

  /// A new flat's ISO or gain is proposed from its light block (RG-10 §4:
  /// prefilled and overridable); its binning is taken from it.
  void _prefillFlatGain() {
    final from = _inheritFrom;
    if (_type != FrameType.flat || from == null) return;
    _copyGain(from.gain);
  }

  /// Puts [g] in the ISO or gain field, unless this class records the other
  /// kind: never relabelled as it (SI-004), the field is left empty.
  void _copyGain(CaptureGain g) {
    final fits = _fixedKind == null || g.kind == _fixedKind;
    _gainKind = g.kind;
    _gainValue.text = g.value == null || !fits ? '' : _trimZeros(g.value!);
  }

  /// Whether the exposure is the user's to type (not taken from a source).
  bool get _typesExposure =>
      _inheritFrom == null ||
      _type == FrameType.flat ||
      _type == FrameType.bias;

  /// "Use other values" (ADR-020 §6): the source's values become the
  /// fields', which are the user's from now on.
  void _useOtherValues() {
    final from = _inheritFrom;
    if (from == null) return;
    setState(() {
      _inherit = false;
      _exposure.text = _trimZeros(from.exposureTimeSeconds);
      _binning = from.binning;
      _copyGain(from.gain);
      final filter = from.filterName ?? 'None';
      if (_type == FrameType.flat) {
        _filter = _filters.contains(filter) ? filter : 'None';
      }
    });
  }

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final isLight = _type == FrameType.light;
    final from = _inheritFrom;
    final block = CaptureBlock(
      id: widget.initial?.id ?? 0,
      sessionLogId: widget.initial?.sessionLogId ?? 0,
      frameType: _type,
      filterName: (isLight || _type == FrameType.flat) && _filter != 'None'
          ? _filter
          : null,
      exposureTimeSeconds: _typesExposure
          ? double.parse(_exposure.text.trim())
          : from!.exposureTimeSeconds,
      frameCount: int.parse(_count.text.trim()),
      binning: _binning,
      gain: _gain(),
      calibrationPolicy: isLight ? null : _policy,
    );
    Navigator.pop(context, from == null ? block : _withSource(block, from));
  }

  /// [block] with what it inherits from [from] (L1): a flat keeps the ISO or
  /// gain typed in the dialog, which the source only proposes.
  CaptureBlock _withSource(CaptureBlock block, CaptureBlock from) =>
      CalibrationMatch.matched(block, from);

  void _setTipsShown(bool shown) {
    setState(() => _tipsShown = shown);
    widget.onTipsShown?.call(shown);
  }

  /// The frame types as the dropdown names them.
  static String _typeLabel(FrameType t) => switch (t) {
    FrameType.darkFlat => 'DARK FLAT',
    _ => t.name.toUpperCase(),
  };

  /// The recorded values a light block keeps without showing them (ADR-020
  /// §3): named, so nothing is hidden silently.
  List<String> _kept() {
    if (_inheritFrom != null) return const []; // the source's values show
    final gain = widget.initial?.gain ?? CaptureGain.none;
    return [
      if (!_showBinning && _binning != 1) '$_binning × $_binning binning',
      if (_fixedKind != null && gain.kind != _fixedKind && gain.value != null)
        switch (gain.kind) {
          GainKind.iso => 'ISO ${_trimZeros(gain.value!)}',
          GainKind.gain => 'gain ${_trimZeros(gain.value!)}',
          GainKind.unknown =>
            'ISO or gain ${_trimZeros(gain.value!)} (kind not recorded)',
        },
    ];
  }

  @override
  Widget build(BuildContext context) {
    final isLight = _type == FrameType.light;
    final fixed = _fixedKind;
    final kept = _kept();
    final muted = Theme.of(context).textTheme.bodySmall;
    final from = _inheritFrom;
    final sources = _sources;
    final tip = CalibrationText.tip(_type);
    // What the source gives is not typed while it is taken (ADR-020 §6).
    final takesGain = from != null && _type != FrameType.flat;
    final takesBinning = from != null;
    final takesFilter = from != null && _type == FrameType.flat;
    return AlertDialog(
      title: Text(
        widget.initial == null ? 'Add Capture Block' : 'Edit Capture Block',
      ),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (widget.proposal != null && isLight)
                Padding(
                  key: const Key('blockDialog.proposal'),
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(
                    'Proposed from your last light block: exposure, '
                    '${fixed == GainKind.gain ? 'gain' : 'ISO or gain'} and '
                    'binning. Change them if needed.',
                    style: muted,
                  ),
                ),
              DropdownButtonFormField<FrameType>(
                initialValue: _type,
                isExpanded: true, // S7.2b: wraps at 200 % text
                decoration: const InputDecoration(labelText: 'Frame Type'),
                items: [
                  for (final t in FrameType.values)
                    DropdownMenuItem(value: t, child: Text(_typeLabel(t))),
                ],
                onChanged: (v) {
                  if (v != null) {
                    setState(() {
                      _type = v;
                      _sourceIndex = 0;
                      _prefillFlatGain();
                    });
                  }
                },
              ),
              if (tip != null && _tipsShown) ...[
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    _tipMore ? '${tip.$1} ${tip.$2}' : tip.$1,
                    key: const Key('blockDialog.tip'),
                    style: muted,
                  ),
                ),
                Wrap(
                  spacing: 8,
                  children: [
                    TextButton(
                      key: const Key('blockDialog.tipMore'),
                      onPressed: () => setState(() => _tipMore = !_tipMore),
                      child: Text(_tipMore ? 'Less' : 'More'),
                    ),
                    TextButton(
                      key: const Key('blockDialog.hideTips'),
                      onPressed: () => _setTipsShown(false),
                      child: const Text('Hide tips'),
                    ),
                  ],
                ),
              ] else if (tip != null)
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton(
                    key: const Key('blockDialog.showTips'),
                    onPressed: () => _setTipsShown(true),
                    child: const Text('Show tips'),
                  ),
                ),
              if (from != null) ...[
                DropdownButtonFormField<int>(
                  key: const Key('blockDialog.source'),
                  initialValue: _sourceIndex.clamp(0, sources.length - 1),
                  isExpanded: true,
                  decoration: InputDecoration(
                    labelText: _type == FrameType.darkFlat
                        ? 'Matches the flat block'
                        : 'Matches the light block',
                  ),
                  items: [
                    for (var i = 0; i < sources.length; i++)
                      DropdownMenuItem(
                        value: i,
                        child: Text(BlockText.row(sources[i], null)),
                      ),
                  ],
                  onChanged: (v) {
                    if (v != null) {
                      setState(() {
                        _sourceIndex = v;
                        _prefillFlatGain();
                      });
                    }
                  },
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    CalibrationText.inherited(
                      _type,
                      from,
                      withBinning: widget.cameraClass.offersLightBinning,
                    ),
                    key: const Key('blockDialog.inherited'),
                  ),
                ),
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton(
                    key: const Key('blockDialog.useOther'),
                    onPressed: _useOtherValues,
                    child: const Text('Use other values'),
                  ),
                ),
              ],
              if ((isLight || _type == FrameType.flat) && !takesFilter)
                DropdownButtonFormField<String>(
                  initialValue: _filter,
                  isExpanded: true, // S7.2b: wraps at 200 % text
                  decoration: const InputDecoration(labelText: 'Filter'),
                  items: [
                    for (final f in _filters)
                      DropdownMenuItem(value: f, child: Text(f)),
                  ],
                  onChanged: (v) {
                    if (v != null) setState(() => _filter = v);
                  },
                ),
              if (_typesExposure)
                TextFormField(
                  controller: _exposure,
                  decoration: InputDecoration(
                    labelText: 'Exposure (seconds)',
                    hintText: 'e.g. 60',
                    helperText: _type == FrameType.bias
                        ? 'The shortest your camera allows.'
                        : null,
                  ),
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  validator: (value) {
                    final exposure = double.tryParse((value ?? '').trim());
                    if (exposure == null || exposure <= 0) {
                      return 'Enter a positive number of seconds';
                    }
                    if (exposure > CaptureBlock.maxExposureSeconds) {
                      return 'At most '
                          '${CaptureBlock.maxExposureSeconds.round()} s';
                    }
                    return null;
                  },
                ),
              TextFormField(
                controller: _count,
                decoration: const InputDecoration(
                  labelText: 'Frame Count',
                  hintText: 'e.g. 30',
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  final count = int.tryParse((value ?? '').trim());
                  if (count == null || count < 1) {
                    return 'Enter a whole number of at least 1';
                  }
                  if (count > CaptureBlock.maxFrameCount) {
                    return 'At most ${CaptureBlock.maxFrameCount}';
                  }
                  return null;
                },
              ),
              if (!isLight)
                DropdownButtonFormField<CalibrationPolicy>(
                  key: const Key('blockDialog.policy'),
                  initialValue: _policy,
                  isExpanded: true, // S7.2b: wraps at 200 % text
                  decoration: const InputDecoration(
                    labelText: 'When is it taken?',
                  ),
                  items: const [
                    DropdownMenuItem(
                      value: CalibrationPolicy.outsideWindow,
                      child: Text('Outside the window (twilight/dawn)'),
                    ),
                    DropdownMenuItem(
                      value: CalibrationPolicy.inWindow,
                      child: Text('During the window'),
                    ),
                    DropdownMenuItem(
                      value: CalibrationPolicy.library,
                      child: Text('From my library (no time)'),
                    ),
                  ],
                  onChanged: (v) {
                    if (v != null) setState(() => _policy = v);
                  },
                ),
              if (_showBinning && !takesBinning)
                DropdownButtonFormField<int>(
                  key: const Key('blockDialog.binning'),
                  initialValue: _binning,
                  isExpanded: true, // S7.2b: wraps at 200 % text
                  decoration: const InputDecoration(labelText: 'Binning'),
                  items: [
                    for (final b in [1, 2, 3, 4])
                      DropdownMenuItem(value: b, child: Text('${b}x$b')),
                  ],
                  onChanged: (v) {
                    if (v != null) setState(() => _binning = v);
                  },
                ),
              if (fixed == null && !takesGain)
                DropdownButtonFormField<GainKind>(
                  key: const Key('blockDialog.gainKind'),
                  initialValue: _gainKind,
                  isExpanded: true, // S7.2b: wraps at 200 % text
                  decoration: const InputDecoration(
                    // RD-03 (S1.8): never called "sensitivity" (SI-004).
                    labelText: 'ISO / gain (for your records)',
                    helperText: 'Recorded only; it does not change the plan.',
                    helperMaxLines: 5,
                  ),
                  items: const [
                    DropdownMenuItem(
                      value: GainKind.unknown,
                      child: Text('Not recorded'),
                    ),
                    DropdownMenuItem(value: GainKind.iso, child: Text('ISO')),
                    DropdownMenuItem(
                      value: GainKind.gain,
                      child: Text('Camera gain'),
                    ),
                  ],
                  onChanged: (v) {
                    if (v != null) setState(() => _gainKind = v);
                  },
                ),
              if (_kind != GainKind.unknown && !takesGain)
                TextFormField(
                  key: const Key('blockDialog.gainValue'),
                  controller: _gainValue,
                  decoration: InputDecoration(
                    labelText: fixed == null
                        ? (_kind == GainKind.iso ? 'ISO' : 'Gain')
                        : (fixed == GainKind.iso
                              ? 'ISO (for your records)'
                              : 'Gain (for your records)'),
                    helperText: fixed == null
                        ? null
                        : 'Optional; recorded only, it does not change the '
                              'plan.',
                    helperMaxLines: 5,
                  ),
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  validator: _validateGain,
                ),
              if (kept.isNotEmpty)
                Padding(
                  key: const Key('blockDialog.kept'),
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    'Also recorded: ${kept.join(', ')} (kept as it was).',
                    style: muted,
                  ),
                ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        // S6.9: the dialog's primary action (§6.1's button hierarchy).
        FilledButton(
          key: const Key('blockDialog.submit'),
          onPressed: _submit,
          child: Text(widget.initial == null ? 'Add' : 'Save'),
        ),
      ],
    );
  }
}
