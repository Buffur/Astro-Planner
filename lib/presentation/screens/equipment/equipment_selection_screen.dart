import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../domain/repositories/equipment_repository.dart';
import '../../../domain/models/equipment_profile.dart';
import '../../viewmodels/planner_viewmodel.dart';

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
    final repo = context.read<EquipmentRepository>();
    final results = await repo.getAllEquipment();
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
    parts.add('${eq.resolutionWidth}×${eq.resolutionHeight}px');
    parts.add('${eq.pixelPitch}Вµm');
    return parts.join(' · ');
  }

  Future<void> _showEquipmentDialog({EquipmentProfile? existing}) async {
    final isEdit = existing != null;
    final formKey = GlobalKey<FormState>();

    // Controllers — pre-filled when editing.
    final nameCtrl =
        TextEditingController(text: existing?.name ?? '');
    final manufacturerCtrl =
        TextEditingController(text: existing?.manufacturer ?? '');
    final cameraModelCtrl =
        TextEditingController(text: existing?.cameraModel ?? '');
    final resWCtrl = TextEditingController(
        text: existing != null ? existing.resolutionWidth.toString() : '');
    final resHCtrl = TextEditingController(
        text: existing != null ? existing.resolutionHeight.toString() : '');
    final pixelCtrl = TextEditingController(
        text: existing != null ? existing.pixelPitch.toString() : '');
    final sensorWCtrl = TextEditingController(
        text: existing != null ? existing.sensorWidth.toStringAsFixed(2) : '');
    final sensorHCtrl = TextEditingController(
        text: existing != null ? existing.sensorHeight.toStringAsFixed(2) : '');
    final focalCtrl = TextEditingController(
        text: existing != null ? existing.focalLength.toString() : '');
    final apertureCtrl = TextEditingController(
        text: existing != null ? existing.aperture.toString() : '');
    final multiplierCtrl = TextEditingController(
        text: existing != null ? existing.opticalMultiplier.toString() : '1.0');
    final rotationCtrl = TextEditingController(
        text: existing?.rotation != null
            ? existing!.rotation!.toString()
            : '');
    int selectedBitDepth = existing?.bitDepth ?? 14;

    /// Auto-compute sensor size from resolution × pixel pitch.
    void autoSensorSize() {
      final resW = int.tryParse(resWCtrl.text);
      final resH = int.tryParse(resHCtrl.text);
      final pitch = double.tryParse(pixelCtrl.text);
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
        return StatefulBuilder(builder: (context, setDialogState) {
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
                  // в”Ђв”Ђ Profile Identity в”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђ
                  TextFormField(
                    controller: nameCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Profile Name',
                      hintText: 'e.g. ZWO ASI2600MC + 400mm Refractor',
                    ),
                    validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
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
                  // в”Ђв”Ђ Sensor Section (Stellarium layout) в”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђ
                  Text('Camera Sensor',
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                            color: Theme.of(context).colorScheme.primary,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.5,
                          )),
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
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) return 'Required';
                        final n = int.tryParse(v);
                        if (n == null) return 'Invalid';
                        if (n <= 0) return '> 0';
                        return null;
                      },
                    ),
                    fieldH: TextFormField(
                      controller: resHCtrl,
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      onChanged: (_) => autoSensorSize(),
                      decoration: const InputDecoration(hintText: '4176'),
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) return 'Required';
                        final n = int.tryParse(v);
                        if (n == null) return 'Invalid';
                        if (n <= 0) return '> 0';
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Pixel Size W × H Вµm
                  _StellariumRow(
                    label: 'Pixel Size',
                    unit: 'Вµm',
                    fieldW: TextFormField(
                      controller: pixelCtrl,
                      keyboardType: const TextInputType.numberWithOptions(
                          decimal: true),
                      textAlign: TextAlign.center,
                      onChanged: (_) => autoSensorSize(),
                      decoration: const InputDecoration(hintText: '3.76'),
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) return 'Required';
                        final n = double.tryParse(v);
                        if (n == null) return 'Invalid';
                        if (n <= 0) return '> 0';
                        return null;
                      },
                    ),
                    // Pixel size is square — show same value label for H
                    fieldH: TextFormField(
                      controller: pixelCtrl,
                      keyboardType: const TextInputType.numberWithOptions(
                          decimal: true),
                      textAlign: TextAlign.center,
                      onChanged: (_) => autoSensorSize(),
                      decoration: const InputDecoration(hintText: '3.76'),
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) return 'Required';
                        final n = double.tryParse(v);
                        if (n == null) return 'Invalid';
                        if (n <= 0) return '> 0';
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Square pixels assumed (W = H)',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
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
                          decimal: true),
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Theme.of(context).disabledColor),
                      decoration: const InputDecoration(
                        hintText: '23.50',
                        filled: true,
                      ),
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) return 'Required';
                        final n = double.tryParse(v);
                        if (n == null) return 'Invalid';
                        if (n <= 0) return '> 0';
                        return null;
                      },
                    ),
                    fieldH: TextFormField(
                      controller: sensorHCtrl,
                      readOnly: true,
                      keyboardType: const TextInputType.numberWithOptions(
                          decimal: true),
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Theme.of(context).disabledColor),
                      decoration: const InputDecoration(
                        hintText: '15.70',
                        filled: true,
                      ),
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) return 'Required';
                        final n = double.tryParse(v);
                        if (n == null) return 'Invalid';
                        if (n <= 0) return '> 0';
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Auto-calculated from Resolution × Pixel Size',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withAlpha(128),
                        ),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<int>(
                    initialValue: selectedBitDepth,
                    decoration: const InputDecoration(
                      labelText: 'RAW Bit Depth',
                    ),
                    items: const [
                      DropdownMenuItem(value: 8, child: Text('8-bit (JPEG/Video)')),
                      DropdownMenuItem(value: 10, child: Text('10-bit')),
                      DropdownMenuItem(value: 12, child: Text('12-bit')),
                      DropdownMenuItem(value: 14, child: Text('14-bit')),
                      DropdownMenuItem(value: 16, child: Text('16-bit')),
                    ],
                    onChanged: (v) {
                      if (v != null) {
                        setDialogState(() => selectedBitDepth = v);
                      }
                    },
                  ),
                  const SizedBox(height: 20),
                  Text('Optics',
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                            color: Theme.of(context).colorScheme.primary,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.5,
                          )),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: focalCtrl,
                          keyboardType: const TextInputType.numberWithOptions(
                              decimal: true),
                          decoration: const InputDecoration(
                              labelText: 'Focal Length (mm)'),
                          validator: (v) {
                            if (v == null || v.trim().isEmpty) return 'Required';
                            final n = double.tryParse(v);
                            if (n == null) return 'Invalid';
                            if (n <= 0) return 'Must be > 0';
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextFormField(
                          controller: apertureCtrl,
                          keyboardType: const TextInputType.numberWithOptions(
                              decimal: true),
                          decoration:
                              const InputDecoration(labelText: 'Aperture (f/)'),
                          validator: (v) {
                            if (v == null || v.trim().isEmpty) return 'Required';
                            final n = double.tryParse(v);
                            if (n == null) return 'Invalid';
                            if (n <= 0) return 'Must be > 0';
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: multiplierCtrl,
                          keyboardType: const TextInputType.numberWithOptions(
                              decimal: true),
                          decoration: const InputDecoration(
                            labelText: 'Optical Multiplier',
                            hintText: '1.0',
                          ),
                          validator: (v) {
                            if (v == null || v.trim().isEmpty) return 'Required';
                            final n = double.tryParse(v);
                            if (n == null) return 'Invalid';
                            if (n <= 0) return 'Must be > 0';
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextFormField(
                          controller: rotationCtrl,
                          keyboardType: const TextInputType.numberWithOptions(
                              decimal: true, signed: true),
                          decoration: const InputDecoration(
                            labelText: 'Rotation (В°)',
                            hintText: 'Optional',
                          ),
                          validator: (v) {
                            if (v == null || v.trim().isEmpty) return null;
                            if (double.tryParse(v) == null) return 'Invalid';
                            return null;
                          },
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
                final repo = context.read<EquipmentRepository>();
                final profile = EquipmentProfile(
                  id: existing?.id ?? 0,
                  name: name,
                  manufacturer: manufacturerCtrl.text.trim().isEmpty
                      ? null
                      : manufacturerCtrl.text.trim(),
                  cameraModel: cameraModelCtrl.text.trim().isEmpty
                      ? null
                      : cameraModelCtrl.text.trim(),
                  resolutionWidth:
                      int.tryParse(resWCtrl.text) ?? 0,
                  resolutionHeight:
                      int.tryParse(resHCtrl.text) ?? 0,
                  pixelPitch:
                      double.tryParse(pixelCtrl.text) ?? 0.0,
                  sensorWidth:
                      double.tryParse(sensorWCtrl.text) ?? 0.0,
                  sensorHeight:
                      double.tryParse(sensorHCtrl.text) ?? 0.0,
                  focalLength:
                      double.tryParse(focalCtrl.text) ?? 0.0,
                  aperture:
                      double.tryParse(apertureCtrl.text) ?? 0.0,
                  opticalMultiplier:
                      double.tryParse(multiplierCtrl.text) ?? 1.0,
                  rotation: rotationCtrl.text.trim().isEmpty
                      ? null
                      : double.tryParse(rotationCtrl.text),
                  bitDepth: selectedBitDepth,
                );
                if (isEdit) {
                  await repo.updateEquipment(profile);
                } else {
                  await repo.insertEquipment(profile);
                }
                if (context.mounted) Navigator.of(context).pop();
              },
              child: Text(isEdit ? 'Save Changes' : 'Save'),
            ),
          ],
        );
        });
      },
    );
    // Always refresh list after dialog closes.
    _loadEquipment();
  }

  @override
  Widget build(BuildContext context) {
    final repo = context.read<EquipmentRepository>();
    final planner = context.watch<PlannerViewModel>();

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
                    final isSelected =
                        eq.id == planner.selectedEquipment?.id;

                    final card = Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      shape: RoundedRectangleBorder(
                        side: BorderSide(
                          color: isSelected
                              ? Theme.of(context).colorScheme.primary
                              : Colors.transparent,
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ListTile(
                        title: Text(eq.name,
                            style: const TextStyle(
                                fontWeight: FontWeight.bold)),
                        subtitle: Text(_subtitle(eq)),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit_outlined,
                                  size: 20),
                              tooltip: 'Edit',
                              onPressed: () =>
                                  _showEquipmentDialog(existing: eq),
                            ),
                            if (isSelected)
                              const Icon(Icons.check_circle,
                                  color: Colors.blue),
                          ],
                        ),
                        onTap: () {
                          planner.setEquipment(eq);
                          context.pop();
                        },
                      ),
                    );

                    return Dismissible(
                      key: ValueKey('eq_${eq.id}'),
                      direction: DismissDirection.endToStart,
                      background: Container(
                        decoration: BoxDecoration(
                          color: Colors.red.shade400,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 16),
                        margin: const EdgeInsets.only(bottom: 8),
                        child: const Icon(Icons.delete, color: Colors.white),
                      ),
                      confirmDismiss: (direction) async {
                        return await showDialog<bool>(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Delete Equipment?'),
                            content: Text(
                                'Are you sure you want to delete "${eq.name}"?'),
                            actions: [
                              TextButton(
                                  onPressed: () =>
                                      Navigator.pop(context, false),
                                  child: const Text('Cancel')),
                              TextButton(
                                  onPressed: () =>
                                      Navigator.pop(context, true),
                                  child: const Text('Delete')),
                            ],
                          ),
                        );
                      },
                      onDismissed: (direction) async {
                        await repo.deleteEquipment(eq.id);
                        setState(() =>
                            _equipment.removeWhere((e) => e.id == eq.id));
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
            child: Text(label,
                style: Theme.of(context).textTheme.bodyMedium),
          ),
        ),
        Expanded(child: fieldW),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6),
          child: Text('×',
              style: Theme.of(context).textTheme.titleMedium),
        ),
        Expanded(child: fieldH),
        const SizedBox(width: 6),
        SizedBox(
          width: 30,
          child: Padding(
            padding: const EdgeInsets.only(top: 14),
            child: Text(unit,
                style: Theme.of(context).textTheme.bodySmall),
          ),
        ),
      ],
    );
  }
}
