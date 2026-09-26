import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../domain/equipment_import/equipment_candidate.dart';
import '../../../domain/equipment_import/equipment_matcher.dart';
import '../../../domain/metadata/capture_metadata.dart';
import '../../../domain/models/spec_provenance.dart';
import '../../shared/equipment_draft.dart';
import '../../shared/equipment_import_text.dart';
import '../../shared/failure_feedback.dart';
import '../../shared/metadata_text.dart';
import '../../viewmodels/metadata_import_viewmodel.dart';
import '../../viewmodels/session_plan_viewmodel.dart';
import '../equipment/equipment_editor.dart';

/// Reads the metadata contract from one capture file (F-45; ADR-017) and
/// proposes equipment from it (S3.6, ADR-018): the match against the saved
/// rigs comes first, the file's values below. Nothing is stored except
/// through the rig editor's Save, and nothing leaves the device.
class MetadataImportScreen extends StatefulWidget {
  const MetadataImportScreen({super.key});

  @override
  State<MetadataImportScreen> createState() => _MetadataImportScreenState();
}

class _MetadataImportScreenState extends State<MetadataImportScreen> {
  @override
  void initState() {
    super.initState();
    // S3.V1: a review kept from an earlier visit is matched again against
    // the rigs as they are now, so it never shows (or reopens) stale ones.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final vm = context.read<MetadataImportViewModel?>();
      if (!mounted || vm?.candidate == null) return;
      runWithFeedback(context, 'match the saved rigs', vm!.refreshMatch);
    });
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<MetadataImportViewModel?>();
    return Scaffold(
      appBar: AppBar(title: const Text('Add from a photo')),
      body: vm == null
          ? const Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'Reading capture-file metadata is not available on this '
                'device.',
              ),
            )
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                const Text(
                  "Reads a few kilobytes of a photo's or RAW file's header, on "
                  'this device, and proposes a rig from it. Nothing is saved '
                  'until you press Save in the rig editor, and nothing leaves '
                  'the phone.',
                ),
                const SizedBox(height: 12),
                FilledButton.icon(
                  key: const Key('metadata.pick'),
                  onPressed: vm.busy
                      ? null
                      : () => runWithFeedback(
                          context,
                          'choose a capture file',
                          vm.pickAndRead,
                        ),
                  icon: const Icon(Icons.file_open_outlined),
                  label: const Text('Choose a capture file'),
                ),
                if (vm.busy) ...[
                  const SizedBox(height: 12),
                  const LinearProgressIndicator(),
                ],
                if ((vm.candidate, vm.match) case (
                  final candidate?,
                  final match?,
                )) ...[
                  const SizedBox(height: 16),
                  _EquipmentCard(vm: vm, candidate: candidate, match: match),
                ],
                if (vm.reading case final reading?) ...[
                  const SizedBox(height: 16),
                  _Result(name: vm.fileName, reading: reading),
                ],
              ],
            ),
    );
  }
}

class _Result extends StatelessWidget {
  const _Result({required this.name, required this.reading});

  final String? name;
  final MetadataReading reading;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final title = Text(
      name ?? 'Unnamed file',
      style: theme.textTheme.titleMedium,
    );
    return Card(
      key: const Key('metadata.result'),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: switch (reading) {
          MetadataRead(:final format, :final metadata) => Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              title,
              Text(MetadataText.format(format)),
              const SizedBox(height: 8),
              for (final row in MetadataText.rows(metadata))
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(row.label, style: theme.textTheme.labelLarge),
                      Text(row.value),
                      if (row.source case final source?)
                        Text(
                          source,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                    ],
                  ),
                ),
            ],
          ),
          MetadataUnsupported(:final format) => Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [title, Text(MetadataText.unsupported(format))],
          ),
          MetadataUnreadable(:final reason) => Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [title, Text(MetadataText.unreadable(reason))],
          ),
        },
      ),
    );
  }
}

/// The equipment the file proposes and how it matches the saved rigs
/// (ADR-018 §6). Every action opens the rig editor; only its Save writes.
class _EquipmentCard extends StatelessWidget {
  const _EquipmentCard({
    required this.vm,
    required this.candidate,
    required this.match,
  });

  final MetadataImportViewModel vm;
  final EquipmentCandidate candidate;
  final EquipmentMatch match;

  /// Opens rig [rigId] as it is now (S3.V1): the saved rigs are read again
  /// first, so a change made since the review was shown is never reverted,
  /// and a rig that changed so it no longer matches, or was deleted, is not
  /// opened (the review then shows the current match).
  Future<void> _openCurrent(
    BuildContext context,
    int rigId,
    EquipmentDraft Function(RigMatch current) draftFor,
  ) async {
    RigMatch? current;
    final read = await runWithFeedback(
      context,
      'check the saved rigs',
      () async => current = await vm.currentMatchFor(rigId),
    );
    if (!read || !context.mounted) return;
    final rig = current;
    if (rig == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'That rig has changed or was removed. The review now shows '
            'the saved rigs as they are.',
          ),
        ),
      );
      return;
    }
    await _edit(context, draftFor(rig));
  }

  Future<void> _edit(BuildContext context, EquipmentDraft draft) async {
    final saved = await showEquipmentEditor(context, draft: draft);
    if (!saved || !context.mounted) return;
    if (draft.existing != null) {
      // TD-028: the planner may be showing the rig that was just changed.
      await context.read<SessionPlanViewModel>().refreshSelectedEquipment();
    }
    if (!context.mounted) return;
    await runWithFeedback(context, 'match the saved rigs', vm.refreshMatch);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final outcome = match.outcome;
    final opens = {
      MatchKind.sameRig,
      MatchKind.likelySameRig,
      MatchKind.ambiguous,
      MatchKind.croppedOrBinnedMode,
    }.contains(outcome);
    return Card(
      key: const Key('import.equipment'),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Equipment', style: theme.textTheme.titleMedium),
            const SizedBox(height: 4),
            Text(
              EquipmentImportText.headline(candidate, match),
              key: const Key('import.headline'),
            ),
            if (candidate.hasEnoughEvidence)
              for (final r in match.rigs) ...[
                const SizedBox(height: 12),
                Text(r.rig.name, style: theme.textTheme.labelLarge),
                Text(
                  EquipmentImportText.reasons(r.reasons),
                  style: theme.textTheme.bodySmall,
                ),
                for (final spec in r.fillable)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      EquipmentImportText.fillable(spec, candidate),
                      key: Key('import.fill.${r.rig.id}.${spec.name}'),
                    ),
                  ),
                for (final c in r.conflicts)
                  SwitchListTile(
                    key: Key('import.take.${r.rig.id}.${c.spec.name}'),
                    contentPadding: EdgeInsets.zero,
                    title: Text(EquipmentImportText.useFileValue(c.spec)),
                    subtitle: Text(
                      [
                        EquipmentImportText.conflict(c),
                        if (c.spec == EquipmentSpec.focalRatio &&
                            r.rig.apertureDiameterMm != null)
                          'Taking it clears the saved diameter.',
                      ].join(' '),
                    ),
                    value: vm.takesImported(r.rig, c.spec),
                    onChanged: (take) =>
                        vm.setTakesImported(r.rig, c.spec, take),
                  ),
                if (opens)
                  OutlinedButton(
                    key: Key('import.open.${r.rig.id}'),
                    onPressed: () =>
                        _openCurrent(context, r.rig.id, vm.rigDraft),
                    child: Text('Open "${r.rig.name}"'),
                  ),
                if (outcome == MatchKind.sameCameraOtherOptics)
                  OutlinedButton(
                    key: Key('import.newFrom.${r.rig.id}'),
                    onPressed: () => _openCurrent(
                      context,
                      r.rig.id,
                      (current) => vm.newRigDraft(cameraFrom: current.rig),
                    ),
                    child: Text(
                      'New rig with the camera specs of "${r.rig.name}"',
                    ),
                  ),
              ],
            if (candidate.hasEnoughEvidence) ...[
              const SizedBox(height: 12),
              FilledButton(
                key: const Key('import.new'),
                onPressed: () => _edit(context, vm.newRigDraft()),
                child: Text(
                  outcome == MatchKind.none
                      ? 'New rig from this file'
                      : 'Create a new rig from this file instead',
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
