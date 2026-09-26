import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import '../../viewmodels/library_viewmodels.dart';
import '../../../domain/models/equipment_profile.dart';
import '../../../domain/models/tracking_type.dart';
import '../../shared/failure_feedback.dart';
import 'equipment_editor.dart';
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
  Object? _loadError;

  @override
  void initState() {
    super.initState();
    _loadEquipment();
  }

  Future<void> _loadEquipment() async {
    final gear = context.read<GearViewModel>();
    try {
      final results = await gear.all();
      if (mounted) {
        setState(() {
          _equipment = results;
          _loadError = null;
          _initialLoading = false;
        });
      }
    } catch (e) {
      // TASK 15.1: an unreadable list says so instead of looking empty.
      if (mounted) {
        setState(() {
          _loadError = e;
          _initialLoading = false;
        });
      }
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

  Future<void> _showEquipmentDialog({EquipmentProfile? existing}) async {
    await showEquipmentEditor(context, existing: existing);
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
          : _loadError != null
          ? LoadFailureView(
              action: 'load the rigs',
              error: _loadError!,
              onRetry: _loadEquipment,
            )
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
                    setState(
                      () => _equipment.removeWhere((e) => e.id == eq.id),
                    );
                    final deleted = await runWithFeedback(
                      context,
                      'delete the rig',
                      () => gear.delete(eq.id),
                    );
                    if (!deleted) return _loadEquipment(); // it is still there
                    // TD-028: clear the planner's selection if this was it,
                    // instead of leaving a reference to a deleted profile.
                    await planVm.refreshSelectedEquipment();
                  },
                  child: card,
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        tooltip: 'Add rig',
        onPressed: () => _showEquipmentDialog(),
        child: const Icon(Icons.add),
      ),
    );
  }
}
