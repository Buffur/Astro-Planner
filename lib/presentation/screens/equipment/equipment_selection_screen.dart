import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import '../../viewmodels/library_viewmodels.dart';
import '../../../domain/models/equipment_limits.dart';
import '../../../domain/models/equipment_profile.dart';
import '../../../domain/models/spec_confidence.dart';
import '../../../domain/models/tracking_type.dart';
import '../../shared/equipment_form_input.dart';
import '../../viewmodels/session_plan_viewmodel.dart';
import '../../../core/theme/app_palette.dart';

class EquipmentSelectionScreen extends StatefulWidget {
  const EquipmentSelectionScreen({super.key});

  @override
  State<EquipmentSelectionScreen> createState() =>
      _EquipmentSelectionScreenState();
}

class _EquipmentSelectionScreenState extends State<EquipmentSelectionScreen> {
  // In-memory list — avoids FutureBuilder flicker on every add/edit/delete.
  List<EquipmentProfile> _equipment = [];
  bool _initialLoading = true;

  @override
  void initState() {
    super.initState();
    _loadEquipment();
  }

  Future<void> _loadEquipment() async {
    final gear = context.read<GearViewModel>();
    final results = await gear.all();
    if (mounted) {
      setState(() {
        _equipment = results;
        _initialLoading = false;
      });
    }
  }

  /// Build a concise subtitle for an equipment card.
  String _subtitle(EquipmentProfile eq) {
    final parts = <String>[];
    if (eq.manufacturer != null && eq.manufacturer!.isNotEmpty) {
      parts.add(eq.manufacturer!);
    }
    if (eq.cameraModel != null && eq.cameraModel!.isNotEmpty) {
      parts.add(eq.cameraModel!);
    }
    parts.add('${eq.resolutionWidthPx}×${eq.resolutionHeightPx} px');
    parts.add('${eq.pixelPitchUm} µm');
    parts.add('${_trim(eq.focalLengthMm)} mm');
    parts.add(
      eq.needsApertureReview
          ? 'f/${_trim(eq.focalRatio)} — please review'
          : 'f/${eq.focalRatio.toStringAsFixed(1)}',
    );
    if (eq.trackingType != TrackingType.unknown) {
      parts.add(eq.trackingType.label);
    }
    return parts.join(' · ');
  }

  static String _trim(double value) =>
      value == value.roundToDouble() ? value.toInt().toString() : '$value';

  static String _text(double? value) => value == null ? '' : _trim(value);

  static String _confidence(SpecConfidence? c) => switch (c) {
    SpecConfidence.verified => 'verified',
    SpecConfidence.reported => 'reported',
    SpecConfidence.estimated => 'estimated',
    null => 'source unknown',
  };

  /// Where the specs came from (ADR-008 §6, TASK 8.5).
  static String _provenance(EquipmentProfile eq) =>
      'Camera specs: ${_confidence(eq.cameraConfidence)}'
      '${eq.cameraSource == null ? '' : ' (${eq.cameraSource})'} · '
      'Optics: ${_confidence(eq.opticsConfidence)}'
      '${eq.opticsSource == null ? '' : ' (${eq.opticsSource})'}';

  static final _decimal = const TextInputType.numberWithOptions(decimal: true);

  /// ADR-011 §6: a stored focal ratio above f/32 is shown for review, never
  /// converted. The f/ field's own bounds make the user fix it on save.
  Widget _reviewBanner(BuildContext context, EquipmentProfile eq) {
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

  Future<void> _showEquipmentDialog({EquipmentProfile? existing}) async {
    final isEdit = existing != null;
    final formKey = GlobalKey<FormState>();

    // Controllers — pre-filled when editing.
    final nameCtrl = TextEditingController(text: existing?.name ?? '');
    final manufacturerCtrl = TextEditingController(
      text: existing?.manufacturer ?? '',
    );
    final cameraModelCtrl = TextEditingController(
      text: existing?.cameraModel ?? '',
    );
    final resWCtrl = TextEditingController(
      text: existing?.resolutionWidthPx.toString() ?? '',
    );
    final resHCtrl = TextEditingController(
      text: existing?.resolutionHeightPx.toString() ?? '',
    );
    final pixelCtrl = TextEditingController(
      text: _text(existing?.pixelPitchUm),
    );
    final sensorWCtrl = TextEditingController(
      text: existing?.sensorWidthMm.toStringAsFixed(2) ?? '',
    );
    final sensorHCtrl = TextEditingController(
      text: existing?.sensorHeightMm.toStringAsFixed(2) ?? '',
    );
    final focalCtrl = TextEditingController(
      text: _text(existing?.focalLengthMm),
    );
    final apertureCtrl = TextEditingController(
      text: _text(existing?.focalRatio),
    );
    final diameterCtrl = TextEditingController(
      text: _text(existing?.apertureDiameterMm),
    );
    final averageRawFileSizeMBCtrl = TextEditingController(
      text: _text(existing?.averageRawFileSizeMB),
    );
    final rotationCtrl = TextEditingController(
      text: _text(existing?.rotationDeg),
    );
    final maxExposureCtrl = TextEditingController(
      text: _text(existing?.maxExposureS),
    );
    var trackingType = existing?.trackingType ?? TrackingType.unknown;
    // The sensor fields show 2 decimals; an untouched field keeps the stored
    // value exactly, so opening and saving never alters verified specs or
    // their provenance (TASK 8.5).
    final sensorWShown = sensorWCtrl.text;
    final sensorHShown = sensorHCtrl.text;
    String? apertureError;

    /// With a diameter, the focal ratio is derived: N = f / D (ADR-011 §4).
    void deriveFocalRatio() {
      final focal = EquipmentFormInput.parse(focalCtrl.text);
      final diameter = EquipmentFormInput.parse(diameterCtrl.text);
      if (focal != null && diameter != null && diameter > 0) {
        apertureCtrl.text = (focal / diameter).toStringAsFixed(2);
      }
    }

    /// Auto-compute sensor size from resolution × pixel pitch.
    void autoSensorSize() {
      final resW = int.tryParse(resWCtrl.text);
      final resH = int.tryParse(resHCtrl.text);
      final pitch = EquipmentFormInput.parse(pixelCtrl.text);
      if (resW != null && resH != null && pitch != null && pitch > 0) {
        final sw = (resW * pitch / 1000);
        final sh = (resH * pitch / 1000);
        sensorWCtrl.text = sw.toStringAsFixed(2);
        sensorHCtrl.text = sh.toStringAsFixed(2);
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
                            onChanged: (_) => autoSensorSize(),
                            decoration: const InputDecoration(hintText: '6248'),
                            validator: EquipmentFormInput.validateResolution,
                          ),
                          fieldH: TextFormField(
                            controller: resHCtrl,
                            keyboardType: TextInputType.number,
                            textAlign: TextAlign.center,
                            onChanged: (_) => autoSensorSize(),
                            decoration: const InputDecoration(hintText: '4176'),
                            validator: EquipmentFormInput.validateResolution,
                          ),
                        ),
                        const SizedBox(height: 8),
                        // Pixel Size W × H µm
                        _StellariumRow(
                          label: 'Pixel Size',
                          unit: 'µm',
                          fieldW: TextFormField(
                            controller: pixelCtrl,
                            keyboardType: _decimal,
                            textAlign: TextAlign.center,
                            onChanged: (_) => autoSensorSize(),
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
                            onChanged: (_) => autoSensorSize(),
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
                        const SizedBox(height: 12),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: apertureCtrl,
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
                          decoration: const InputDecoration(
                            labelText: 'Tracking',
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
                    final focal = EquipmentFormInput.parse(focalCtrl.text)!;
                    final diameterText = diameterCtrl.text.trim();
                    final aperture = resolveAperture(
                      focalLengthMm: focal,
                      focalRatio: diameterText.isEmpty
                          ? EquipmentFormInput.parse(apertureCtrl.text)
                          : null,
                      diameterMm: diameterText.isEmpty
                          ? null
                          : EquipmentFormInput.parse(diameterText),
                    );
                    if (!aperture.isValid) {
                      setDialogState(
                        () =>
                            apertureError = EquipmentFormInput.apertureMessage(
                              aperture.problem!,
                            ),
                      );
                      return;
                    }
                    double? optional(TextEditingController c) =>
                        EquipmentFormInput.parse(c.text);
                    final profile = EquipmentProfile(
                      id: existing?.id ?? 0,
                      name: name,
                      manufacturer: manufacturerCtrl.text.trim().isEmpty
                          ? null
                          : manufacturerCtrl.text.trim(),
                      cameraModel: cameraModelCtrl.text.trim().isEmpty
                          ? null
                          : cameraModelCtrl.text.trim(),
                      resolutionWidthPx: int.parse(resWCtrl.text.trim()),
                      resolutionHeightPx: int.parse(resHCtrl.text.trim()),
                      pixelPitchUm: EquipmentFormInput.parse(pixelCtrl.text)!,
                      sensorWidthMm:
                          existing != null && sensorWCtrl.text == sensorWShown
                          ? existing.sensorWidthMm
                          : EquipmentFormInput.parse(sensorWCtrl.text)!,
                      sensorHeightMm:
                          existing != null && sensorHCtrl.text == sensorHShown
                          ? existing.sensorHeightMm
                          : EquipmentFormInput.parse(sensorHCtrl.text)!,
                      focalLengthMm: focal,
                      focalRatio: aperture.focalRatio!,
                      apertureDiameterMm: aperture.diameterMm,
                      averageRawFileSizeMB: optional(averageRawFileSizeMBCtrl),
                      rotationDeg: optional(rotationCtrl),
                      trackingType: trackingType,
                      maxExposureS: optional(maxExposureCtrl),
                    );
                    // TASK 8.5: changed specs become the user's own.
                    final recorded = profile.withEditProvenance(existing);
                    if (isEdit) {
                      await gear.update(recorded);
                    } else {
                      await gear.add(recorded);
                    }
                    if (context.mounted) Navigator.of(context).pop();
                  },
                  child: Text(isEdit ? 'Save Changes' : 'Save'),
                ),
              ],
            );
          },
        );
      },
    );
    // Always refresh list after dialog closes.
    _loadEquipment();
    // TD-028: pick up an edit to the currently selected equipment instead of
    // leaving the planner showing stale field values. A no-op unless the
    // edited profile is the selected one.
    if (mounted) {
      await context.read<SessionPlanViewModel>().refreshSelectedEquipment();
    }
  }

  @override
  Widget build(BuildContext context) {
    final gear = context.read<GearViewModel>();
    final planVm = context.watch<SessionPlanViewModel>();

    return Scaffold(
      appBar: AppBar(title: const Text('Select Equipment')),
      body: _initialLoading
          ? const Center(child: CircularProgressIndicator())
          : _equipment.isEmpty
          ? const Center(child: Text('No equipment profiles found.'))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _equipment.length,
              itemBuilder: (context, index) {
                final eq = _equipment[index];
                final isSelected = eq.id == planVm.selectedEquipment?.id;

                final card = Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  shape: RoundedRectangleBorder(
                    side: BorderSide(
                      color: isSelected
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context).colorScheme.primary.withAlpha(0),
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    title: Text(
                      eq.name,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(_subtitle(eq)),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit_outlined, size: 20),
                          tooltip: 'Edit',
                          onPressed: () => _showEquipmentDialog(existing: eq),
                        ),
                        if (isSelected)
                          Icon(
                            Icons.check_circle,
                            color: AppPalette.of(context).selected,
                          ),
                      ],
                    ),
                    onTap: () {
                      planVm.setEquipment(eq);
                      context.pop();
                    },
                  ),
                );

                return Dismissible(
                  key: ValueKey('eq_${eq.id}'),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.error,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 16),
                    margin: const EdgeInsets.only(bottom: 8),
                    child: Icon(
                      Icons.delete,
                      color: Theme.of(context).colorScheme.onError,
                    ),
                  ),
                  confirmDismiss: (direction) async {
                    return await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Delete Equipment?'),
                        content: Text(
                          'Are you sure you want to delete "${eq.name}"?',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: const Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(context, true),
                            child: const Text('Delete'),
                          ),
                        ],
                      ),
                    );
                  },
                  onDismissed: (direction) async {
                    await gear.delete(eq.id);
                    setState(
                      () => _equipment.removeWhere((e) => e.id == eq.id),
                    );
                    // TD-028: clear the planner's selection if this was it,
                    // instead of leaving a reference to a deleted profile.
                    await planVm.refreshSelectedEquipment();
                  },
                  child: card,
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showEquipmentDialog(),
        child: const Icon(Icons.add),
      ),
    );
  }
}

/// A Stellarium-style row: Label   [FieldW] × [FieldH]   Unit
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
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 90,
          child: Padding(
            padding: const EdgeInsets.only(top: 14),
            child: Text(label, style: Theme.of(context).textTheme.bodyMedium),
          ),
        ),
        Expanded(child: fieldW),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6),
          child: Text('×', style: Theme.of(context).textTheme.titleMedium),
        ),
        Expanded(child: fieldH),
        const SizedBox(width: 6),
        SizedBox(
          width: 30,
          child: Padding(
            padding: const EdgeInsets.only(top: 14),
            child: Text(unit, style: Theme.of(context).textTheme.bodySmall),
          ),
        ),
      ],
    );
  }
}
