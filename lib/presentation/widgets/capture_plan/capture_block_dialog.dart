import 'package:flutter/material.dart';

import '../../../domain/models/camera_class.dart';
import '../../../domain/models/capture_block.dart';

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
Future<CaptureBlock?> showCaptureBlockDialog(
  BuildContext context, {
  CaptureBlock? initial,
  CameraClass cameraClass = CameraClass.unknown,
  CaptureBlock? proposal,
}) {
  return showDialog<CaptureBlock>(
    context: context,
    builder: (ctx) => _CaptureBlockDialog(
      initial: initial,
      cameraClass: cameraClass,
      proposal: initial == null ? proposal : null,
    ),
  );
}

class _CaptureBlockDialog extends StatefulWidget {
  const _CaptureBlockDialog({
    required this.initial,
    required this.cameraClass,
    required this.proposal,
  });

  final CaptureBlock? initial;
  final CameraClass cameraClass;
  final CaptureBlock? proposal;

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

  /// The recorded values this dialog starts from: the block being edited,
  /// else the proposal (S7.2b), else nothing.
  CaptureBlock? get _source => widget.initial ?? widget.proposal;

  /// The sensitivity kind a light block of this class records (ADR-020 §3);
  /// null when the user chooses it (Unknown, and calibration frames until
  /// S7.3a).
  GainKind? get _fixedKind => _type != FrameType.light
      ? null
      : switch (widget.cameraClass.lightSensitivity) {
          LightSensitivity.iso => GainKind.iso,
          LightSensitivity.gain => GainKind.gain,
          LightSensitivity.either => null,
        };

  GainKind get _kind => _fixedKind ?? _gainKind;

  bool get _showBinning =>
      _type != FrameType.light || widget.cameraClass.offersLightBinning;

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

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final isLight = _type == FrameType.light;
    final block = CaptureBlock(
      id: widget.initial?.id ?? 0,
      sessionLogId: widget.initial?.sessionLogId ?? 0,
      frameType: _type,
      filterName: (isLight || _type == FrameType.flat) && _filter != 'None'
          ? _filter
          : null,
      exposureTimeSeconds: double.parse(_exposure.text.trim()),
      frameCount: int.parse(_count.text.trim()),
      binning: _binning,
      gain: _gain(),
      calibrationPolicy: isLight ? null : _policy,
    );
    Navigator.pop(context, block);
  }

  /// The recorded values a light block keeps without showing them (ADR-020
  /// §3): named, so nothing is hidden silently.
  List<String> _kept() {
    if (_type != FrameType.light) return const [];
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
                    DropdownMenuItem(
                      value: t,
                      child: Text(t.name.toUpperCase()),
                    ),
                ],
                onChanged: (v) {
                  if (v != null) setState(() => _type = v);
                },
              ),
              if (isLight || _type == FrameType.flat)
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
              TextFormField(
                controller: _exposure,
                decoration: const InputDecoration(
                  labelText: 'Exposure (seconds)',
                  hintText: 'e.g. 60',
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
              if (_showBinning)
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
              if (fixed == null)
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
              if (_kind != GainKind.unknown)
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
