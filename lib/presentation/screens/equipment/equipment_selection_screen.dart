import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import '../../viewmodels/library_viewmodels.dart';
import '../../../domain/models/camera_class.dart';
import '../../../domain/models/equipment_profile.dart';
import '../../../domain/models/tracking_type.dart';
import '../../../core/config/feature_scope.dart';
import '../../navigation/app_router.dart';
import '../../shared/app_words.dart';
import '../../shared/confirmation_patterns.dart';
import '../../shared/delete_patterns.dart';
import '../../shared/example_text.dart';
import '../../shared/failure_feedback.dart';
import '../../shared/list_mode.dart';
import 'equipment_editor.dart';
import '../../viewmodels/session_plan_viewmodel.dart';
import '../../../core/theme/app_palette.dart';
import '../../../core/theme/app_spacing.dart';

/// The rigs (ADR-015; S9.1, D9-1): managed in the Library, chosen for the
/// plan from `/select/rig`. Deleting confirms (RD-09 = M + S1).
class EquipmentSelectionScreen extends StatefulWidget {
  const EquipmentSelectionScreen({super.key, this.mode = ListMode.choose});

  final ListMode mode;

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
    // RD-04 (S6.8): the shipped example is labelled where it is listed.
    final parts = <String>[if (eq.isExample) ExampleText.rig];
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
    // S7.2a: the camera class, once the user chose one (never inferred).
    if (eq.cameraClass != CameraClass.unknown) parts.add(eq.cameraClass.label);
    if (eq.trackingType != TrackingType.unknown) {
      parts.add(eq.trackingType.label);
    }
    return parts.join(' · ');
  }

  static String _trim(double value) =>
      value == value.roundToDouble() ? value.toInt().toString() : '$value';

  /// Opens the metadata import; a rig saved there shows up on return.
  Future<void> _importFromPhoto() async {
    await context.push(AppRouter.metadata);
    if (!mounted) return;
    await _loadEquipment();
    if (mounted) {
      await context.read<SessionPlanViewModel>().refreshSelectedEquipment();
    }
  }

  /// Deletes [eq] after the shared confirmation (a stored record, RD-09):
  /// saved plans keep their own copy of it (ADR-014 §4). Returns whether it
  /// was deleted.
  Future<bool> _delete(EquipmentProfile eq) async {
    final sure = await confirmDestructive(
      context,
      title: 'Delete this rig?',
      message:
          '"${eq.name}" is deleted from your rigs. Saved plans keep what '
          "they recorded. This can't be undone.",
    );
    if (!sure || !mounted) return false;
    final deleted = await runWithFeedback(
      context,
      'delete the rig',
      () => context.read<GearViewModel>().delete(eq.id),
    );
    if (!mounted) return deleted;
    if (deleted) showDone(context, 'Rig deleted');
    await _loadEquipment();
    // TD-028: clear the planner's selection if this was it.
    if (mounted) {
      await context.read<SessionPlanViewModel>().refreshSelectedEquipment();
    }
    return deleted;
  }

  Future<void> _showEquipmentDialog({EquipmentProfile? existing}) async {
    await showEquipmentEditor(
      context,
      existing: existing,
      onDelete: existing == null ? null : () => _delete(existing),
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
    final planVm = context.watch<SessionPlanViewModel>();
    final choosing = widget.mode == ListMode.choose;

    return Scaffold(
      appBar: AppBar(
        title: Text(choosing ? AppWords.chooseRig : AppWords.rigs),
      ),
      body: _initialLoading
          ? const Center(child: CircularProgressIndicator())
          : _loadError != null
          ? LoadFailureView(
              action: 'load the rigs',
              error: _loadError!,
              onRetry: _loadEquipment,
            )
          : _equipment.isEmpty
          ? const Center(child: Text(AppWords.noRigs))
          : ListView.builder(
              padding: const EdgeInsets.all(AppSpacing.md),
              itemCount: _equipment.length,
              itemBuilder: (context, index) {
                final eq = _equipment[index];
                // Only when choosing: the Library describes the rigs, not
                // the plan (S9.1).
                final isSelected =
                    choosing && eq.id == planVm.selectedEquipment?.id;

                final card = Card(
                  margin: const EdgeInsets.only(bottom: AppSpacing.sm),
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
                    trailing: choosing
                        ? Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit_outlined, size: 20),
                                tooltip: AppWords.editRig,
                                onPressed: () =>
                                    _showEquipmentDialog(existing: eq),
                              ),
                              if (isSelected)
                                Icon(
                                  Icons.check_circle,
                                  color: AppPalette.of(context).selected,
                                ),
                            ],
                          )
                        : const Icon(Icons.chevron_right),
                    onTap: choosing
                        ? () {
                            planVm.setEquipment(eq);
                            context.pop();
                          }
                        : () => _showEquipmentDialog(existing: eq),
                  ),
                );

                return SwipeToDelete(
                  itemKey: ValueKey('eq_${eq.id}'),
                  onDelete: () => _delete(eq),
                  child: card,
                );
              },
            ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // S3.7 (ADR-018 §7): a rig proposed from a capture file's
          // metadata; nothing is saved without the editor's Save.
          if (FeatureScope.metadataImport) ...[
            FloatingActionButton.small(
              key: const Key('rigs.addFromPhoto'),
              heroTag: 'rigs.addFromPhoto',
              tooltip: 'Add from a photo',
              onPressed: _importFromPhoto,
              child: const Icon(Icons.add_photo_alternate_outlined),
            ),
            const SizedBox(height: 12),
          ],
          FloatingActionButton(
            heroTag: 'rigs.add',
            tooltip: 'Add rig',
            onPressed: () => _showEquipmentDialog(),
            child: const Icon(Icons.add),
          ),
        ],
      ),
    );
  }
}
