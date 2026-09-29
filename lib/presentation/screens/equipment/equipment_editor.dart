import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../domain/models/camera_class.dart';
import '../../../domain/models/equipment_limits.dart';
import '../../../domain/models/equipment_profile.dart';
import '../../../domain/models/spec_confidence.dart';
import '../../../domain/models/spec_provenance.dart';
import '../../../domain/models/tracking_type.dart';
import '../../shared/equipment_draft.dart';
import '../../shared/equipment_form_input.dart';
import '../../shared/equipment_import_text.dart';
import '../../shared/failure_feedback.dart';
import '../../viewmodels/library_viewmodels.dart';

/// The rig editor (S3.5): Add, Edit, or a draft pre-filled from a metadata
/// import (ADR-018 §2). Every value is built by [EquipmentDraft]; this dialog
/// holds only controllers and layout. Returns true when the rig was saved.
/// Nothing is written unless the user presses Save.
Future<bool> showEquipmentEditor(
  BuildContext context, {
  EquipmentProfile? existing,
  EquipmentDraft? draft,
}) =>
    _EquipmentEditor(draft ?? EquipmentDraft.fromProfile(existing))
        .show(context);

class _EquipmentEditor {
  _EquipmentEditor(this.form);

  final EquipmentDraft form;

  static String _trim(double value) =>
      value == value.roundToDouble() ? value.toInt().toString() : '$value';

  static String _confidence(SpecConfidence? c) => switch (c) {
    SpecConfidence.verified => 'verified',
    SpecConfidence.reported => 'reported',
    SpecConfidence.estimated => 'estimated',
    null => 'source unknown',
  };

  static String _named(SpecProvenance? p) => p == null
      ? _confidence(null)
      : '${_confidence(p.confidence)}'
            '${p.source == null ? '' : ' (${p.source})'}';

  /// Where the specs came from (ADR-008 §6, TASK 8.5), read per spec
  /// (ADR-018 §5; S3.V7, S3S-01): one phrase for a group whose specs share
  /// a provenance, else one per spec. Never the group pair alone, which is
  /// `user` on an imported rig whose values the user did not type.
  static String _provenance(EquipmentProfile eq) =>
      '${_group(eq, camera: true)} · ${_group(eq, camera: false)}';

  static String _group(EquipmentProfile eq, {required bool camera}) {
    final specs = eq.groupProvenance(camera: camera);
    if ({for (final (_, p) in specs) p}.length == 1) {
      return '${camera ? 'Camera specs' : 'Optics'}: ${_named(specs.first.$2)}';
    }
    return [
      for (final (spec, p) in specs)
        '${EquipmentImportText.spec(spec)}: ${_named(p)}',
    ].join(' · ');
  }

  static final _decimal = const TextInputType.numberWithOptions(decimal: true);

  /// ADR-011 §6: a stored focal ratio above f/32 is shown for review, never
  /// converted. The f/ field's own bounds make the user fix it on save.
  static Widget _reviewBanner(BuildContext context, EquipmentProfile eq) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: scheme.errorContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        'Please review: the stored focal ratio is '
        'f/${_trim(eq.focalRatio)}, above f/32. It may be an aperture '
        'diameter typed into the f/ field. Enter the focal ratio, or the '
        'diameter in mm.',
        style: TextStyle(color: scheme.onErrorContainer),
      ),
    );
  }

  Future<bool> show(BuildContext context) async {
    final existing = form.existing;
    final isEdit = existing != null;
    final formKey = GlobalKey<FormState>();

    final t = form.initial;
    final nameCtrl = TextEditingController(text: t.name);
    final manufacturerCtrl = TextEditingController(text: t.manufacturer);
    final cameraModelCtrl = TextEditingController(text: t.cameraModel);
    final resWCtrl = TextEditingController(text: t.resolutionWidth);
    final resHCtrl = TextEditingController(text: t.resolutionHeight);
    final pixelCtrl = TextEditingController(text: t.pixelPitch);
    final sensorWCtrl = TextEditingController(text: t.sensorWidth);
    final sensorHCtrl = TextEditingController(text: t.sensorHeight);
    final focalCtrl = TextEditingController(text: t.focalLength);
    final apertureCtrl = TextEditingController(text: t.focalRatio);
    final diameterCtrl = TextEditingController(text: t.diameter);
    final averageRawFileSizeMBCtrl = TextEditingController(text: t.rawFileSize);
    final rotationCtrl = TextEditingController(text: t.rotation);
    final maxExposureCtrl = TextEditingController(text: t.maxExposure);
    var trackingType = form.trackingType;
    var cameraClass = form.cameraClass;
    String? apertureError;
    var saved = false;

    EquipmentFormTexts currentTexts() => EquipmentFormTexts(
      name: nameCtrl.text,
      manufacturer: manufacturerCtrl.text,
      cameraModel: cameraModelCtrl.text,
      resolutionWidth: resWCtrl.text,
      resolutionHeight: resHCtrl.text,
      pixelPitch: pixelCtrl.text,
      sensorWidth: sensorWCtrl.text,
      sensorHeight: sensorHCtrl.text,
      focalLength: focalCtrl.text,
      focalRatio: apertureCtrl.text,
      diameter: diameterCtrl.text,
      rawFileSize: averageRawFileSizeMBCtrl.text,
      rotation: rotationCtrl.text,
      maxExposure: maxExposureCtrl.text,
    );

    /// ADR-018 §4, §7: where a pre-filled value came from, while unchanged.
    Widget prefillNote(BuildContext context, EquipmentSpec spec) {
      final p = form.unchangedPrefill(spec, currentTexts());
      if (p == null) return const SizedBox.shrink();
      return Padding(
        padding: const EdgeInsets.only(top: 4),
        child: Text(
          PrefillText.note(p),
          key: Key('editor.prefill.${spec.name}'),
          style: Theme.of(context).textTheme.bodySmall,
        ),
      );
    }

    /// With a diameter, the focal ratio is derived: N = f / D (ADR-011 §4).
    void deriveFocalRatio() {
      final focal = EquipmentFormInput.parse(focalCtrl.text);
      final diameter = EquipmentFormInput.parse(diameterCtrl.text);
      if (focal != null && diameter != null && diameter > 0) {
        apertureCtrl.text = (focal / diameter).toStringAsFixed(2);
      }
    }

    /// The sensor size from resolution × pixel pitch (the form model).
    void autoSensorSize() {
      final size = EquipmentDraft.sensorSizeText(
        resWCtrl.text,
        resHCtrl.text,
        pixelCtrl.text,
      );
      if (size != null) {
        sensorWCtrl.text = size.width;
        sensorHCtrl.text = size.height;
      }
    }

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text(isEdit ? 'Edit Equipment' : 'Add Equipment Profile'),
              // Constrain width on larger screens.
              content: SizedBox(
                width: min(MediaQuery.of(context).size.width * 0.9, 480),
                child: SingleChildScrollView(
                  child: Form(
                    key: formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ── Profile Identity ────────────────────────────
                        TextFormField(
                          controller: nameCtrl,
                          decoration: const InputDecoration(
                            labelText: 'Profile Name',
                            hintText: 'e.g. ZWO ASI2600MC + 400mm Refractor',
                          ),
                          validator: (v) =>
                              v == null || v.trim().isEmpty ? 'Required' : null,
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: manufacturerCtrl,
                                decoration: const InputDecoration(
                                  labelText: 'Manufacturer',
                                  hintText: 'e.g. ZWO',
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: TextFormField(
                                controller: cameraModelCtrl,
                                decoration: const InputDecoration(
                                  labelText: 'Model',
                                  hintText: 'e.g. ASI2600MC',
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        // S7.2a (ADR-020 §2): the user's choice, never
                        // inferred; it decides the capture settings offered.
                        DropdownButtonFormField<CameraClass>(
                          key: const Key('equipmentEditor.cameraClass'),
                          initialValue: cameraClass,
                          isExpanded: true,
                          decoration: const InputDecoration(
                            labelText: 'Camera type',
                          ),
                          items: [
                            for (final c in CameraClass.values)
                              DropdownMenuItem(value: c, child: Text(c.label)),
                          ],
                          onChanged: (c) {
                            if (c != null) cameraClass = c;
                          },
                        ),
                        const SizedBox(height: 20),
                        // ── Sensor Section (Stellarium layout) ──────────
                        Text(
                          'Camera Sensor',
                          style: Theme.of(context).textTheme.labelMedium
                              ?.copyWith(
                                color: Theme.of(context).colorScheme.primary,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.5,
                              ),
                        ),
                        const SizedBox(height: 8),
                        // Resolution W × H px
                        _StellariumRow(
                          label: 'Resolution',
                          unit: 'px',
                          fieldW: TextFormField(
                            controller: resWCtrl,
                            keyboardType: TextInputType.number,
                            textAlign: TextAlign.center,
                            onChanged: (_) => setDialogState(autoSensorSize),
                            decoration: const InputDecoration(hintText: '6248'),
                            validator: EquipmentFormInput.validateResolution,
                          ),
                          fieldH: TextFormField(
                            controller: resHCtrl,
                            keyboardType: TextInputType.number,
                            textAlign: TextAlign.center,
                            onChanged: (_) => setDialogState(autoSensorSize),
                            decoration: const InputDecoration(hintText: '4176'),
                            validator: EquipmentFormInput.validateResolution,
                          ),
                        ),
                        prefillNote(context, EquipmentSpec.resolution),
                        const SizedBox(height: 8),
                        // Pixel Size W × H µm
                        _StellariumRow(
                          label: 'Pixel Size',
                          unit: 'µm',
                          fieldW: TextFormField(
                            controller: pixelCtrl,
                            keyboardType: _decimal,
                            textAlign: TextAlign.center,
                            onChanged: (_) => setDialogState(autoSensorSize),
                            decoration: const InputDecoration(hintText: '3.76'),
                            validator: EquipmentFormInput.required(
                              EquipmentLimits.pixelPitchUm,
                              'µm',
                            ),
                          ),
                          // Pixel size is square — show same value label for H
                          fieldH: TextFormField(
                            controller: pixelCtrl,
                            keyboardType: _decimal,
                            textAlign: TextAlign.center,
                            onChanged: (_) => setDialogState(autoSensorSize),
                            decoration: const InputDecoration(hintText: '3.76'),
                            validator: EquipmentFormInput.required(
                              EquipmentLimits.pixelPitchUm,
                              'µm',
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Square pixels assumed (W = H)',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                color: Theme.of(context).colorScheme.onSurface
                                    .withAlpha(128),
                              ),
                        ),
                        const SizedBox(height: 8),
                        // S3.V8: a saved rig's pixel size of another
                        // output mode was not copied; say why while empty.
                        if (form.withheldFromSavedRig case final w?
                            when pixelCtrl.text.trim().isEmpty)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 4),
                            child: Text(
                              PrefillText.withheld(w),
                              key: const Key('editor.withheld'),
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ),
                        prefillNote(context, EquipmentSpec.pixelPitch),
                        // Sensor Size W × H mm — auto-calculated
                        _StellariumRow(
                          label: 'Sensor Size',
                          unit: 'mm',
                          fieldW: TextFormField(
                            controller: sensorWCtrl,
                            readOnly: true,
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Theme.of(context).disabledColor,
                            ),
                            decoration: const InputDecoration(
                              hintText: '23.50',
                              filled: true,
                            ),
                            validator: EquipmentFormInput.required(
                              EquipmentLimits.sensorSideMm,
                              'mm',
                            ),
                          ),
                          fieldH: TextFormField(
                            controller: sensorHCtrl,
                            readOnly: true,
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Theme.of(context).disabledColor,
                            ),
                            decoration: const InputDecoration(
                              hintText: '15.70',
                              filled: true,
                            ),
                            validator: EquipmentFormInput.required(
                              EquipmentLimits.sensorSideMm,
                              'mm',
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Auto-calculated from Resolution × Pixel Size',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                color: Theme.of(context).colorScheme.onSurface
                                    .withAlpha(128),
                              ),
                        ),
                        prefillNote(context, EquipmentSpec.sensorSize),
                        const SizedBox(height: 12),
                        // Bit Depth removed
                        const SizedBox(height: 20),
                        Text(
                          'Optics',
                          style: Theme.of(context).textTheme.labelMedium
                              ?.copyWith(
                                color: Theme.of(context).colorScheme.primary,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.5,
                              ),
                        ),
                        const SizedBox(height: 8),
                        if (existing?.needsApertureReview ?? false)
                          _reviewBanner(context, existing!),
                        if (existing != null)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Text(
                              _provenance(existing),
                              key: const Key('editor.provenance'),
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ),
                        TextFormField(
                          controller: focalCtrl,
                          keyboardType: _decimal,
                          onChanged: (_) => setDialogState(deriveFocalRatio),
                          decoration: const InputDecoration(
                            labelText: 'Effective Focal Length (mm)',
                          ),
                          validator: EquipmentFormInput.required(
                            EquipmentLimits.focalLengthMm,
                            'mm',
                          ),
                        ),
                        prefillNote(context, EquipmentSpec.focalLength),
                        const SizedBox(height: 12),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: apertureCtrl,
                                onChanged: (_) => setDialogState(() {}),
                                // ADR-011 §4: with a diameter, N = f / D.
                                readOnly: diameterCtrl.text.trim().isNotEmpty,
                                keyboardType: _decimal,
                                decoration: InputDecoration(
                                  labelText: 'Focal ratio (f/)',
                                  helperText:
                                      diameterCtrl.text.trim().isNotEmpty
                                      ? 'From focal length ÷ diameter'
                                      : null,
                                ),
                                validator: diameterCtrl.text.trim().isNotEmpty
                                    ? null
                                    : EquipmentFormInput.required(
                                        EquipmentLimits.focalRatio,
                                        '',
                                      ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: TextFormField(
                                controller: diameterCtrl,
                                keyboardType: _decimal,
                                onChanged: (_) =>
                                    setDialogState(deriveFocalRatio),
                                decoration: const InputDecoration(
                                  labelText: 'Aperture diameter (mm)',
                                  hintText: 'Optional',
                                ),
                                validator: EquipmentFormInput.optional(
                                  EquipmentLimits.apertureDiameterMm,
                                  'mm',
                                ),
                              ),
                            ),
                          ],
                        ),
                        prefillNote(context, EquipmentSpec.focalRatio),
                        if (apertureError != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              apertureError!,
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.error,
                              ),
                            ),
                          ),
                        const SizedBox(height: 12),
                        DropdownButtonFormField<TrackingType>(
                          initialValue: trackingType,
                          // S3.10: the chosen label wraps inside the field
                          // instead of overflowing on a phone at large text.
                          isExpanded: true,
                          decoration: const InputDecoration(
                            // S7.1 (RD-08 = T3): a plan may override it.
                            labelText: 'Tracking (default for plans)',
                          ),
                          items: [
                            for (final t in TrackingType.values)
                              DropdownMenuItem(value: t, child: Text(t.label)),
                          ],
                          onChanged: (t) {
                            if (t != null) trackingType = t;
                          },
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: maxExposureCtrl,
                          keyboardType: _decimal,
                          decoration: const InputDecoration(
                            labelText: 'Maximum sub-exposure (s)',
                            hintText: 'Optional — your mount/guiding limit',
                          ),
                          validator: EquipmentFormInput.optional(
                            EquipmentLimits.maxExposureS,
                            's',
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: averageRawFileSizeMBCtrl,
                                onChanged: (_) => setDialogState(() {}),
                                keyboardType: _decimal,
                                decoration: const InputDecoration(
                                  labelText: 'Average RAW File Size (MB)',
                                  hintText: 'e.g. 50.0',
                                ),
                                validator: EquipmentFormInput.optional(
                                  EquipmentLimits.rawFileSizeMB,
                                  'MB',
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: TextFormField(
                                controller: rotationCtrl,
                                keyboardType:
                                    const TextInputType.numberWithOptions(
                                      decimal: true,
                                      signed: true,
                                    ),
                                decoration: const InputDecoration(
                                  labelText: 'Rotation (°)',
                                  hintText: 'Optional',
                                ),
                                validator: EquipmentFormInput.optional(
                                  EquipmentLimits.rotationDeg,
                                  '°',
                                ),
                              ),
                            ),
                          ],
                        ),
                        prefillNote(context, EquipmentSpec.rawFileSize),
                      ],
                    ),
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (!formKey.currentState!.validate()) return;
                    final name = nameCtrl.text.trim();
                    if (name.isEmpty) return;
                    final gear = context.read<GearViewModel>();
                    // S3.5: the form model builds the profile and its
                    // provenance (TASK 8.5, ADR-018 §5).
                    final result = form.build(
                      currentTexts(),
                      trackingType,
                      cameraClass: cameraClass,
                    );
                    final recorded = result.profile;
                    if (recorded == null) {
                      setDialogState(
                        () =>
                            apertureError = EquipmentFormInput.apertureMessage(
                              result.apertureProblem!,
                            ),
                      );
                      return;
                    }
                    saved = await runWithFeedback(
                      context,
                      'save the rig',
                      () => isEdit ? gear.update(recorded) : gear.add(recorded),
                    );
                    if (saved && context.mounted) Navigator.of(context).pop();
                  },
                  child: Text(isEdit ? 'Save Changes' : 'Save'),
                ),
              ],
            );
          },
        );
      },
    );
    return saved;
  }
}

/// A Stellarium-style row: the label, then [FieldW] × [FieldH] Unit.
class _StellariumRow extends StatelessWidget {
  const _StellariumRow({
    required this.label,
    required this.unit,
    required this.fieldW,
    required this.fieldH,
  });

  final String label;
  final String unit;
  final Widget fieldW;
  final Widget fieldH;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // S3.10 (TD-069): the label sits above the W × H fields, so the fields
    // get the dialog's whole width. Beside a fixed 90 dp label they were
    // too narrow on a phone, and the read-only sensor fields clipped
    // "9.89" to "9.8".
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: theme.textTheme.bodyMedium),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: fieldW),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6),
              child: Text('×', style: theme.textTheme.titleMedium),
            ),
            Expanded(child: fieldH),
            const SizedBox(width: 6),
            Padding(
              padding: const EdgeInsets.only(top: 14),
              child: Text(unit, style: theme.textTheme.bodySmall),
            ),
          ],
        ),
      ],
    );
  }
}
