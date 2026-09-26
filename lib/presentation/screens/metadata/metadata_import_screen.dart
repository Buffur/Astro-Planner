import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../domain/metadata/capture_metadata.dart';
import '../../shared/failure_feedback.dart';
import '../../shared/metadata_text.dart';
import '../../viewmodels/metadata_import_viewmodel.dart';

/// Reads the metadata contract from one capture file (F-45; ADR-017). Hidden
/// behind `FeatureScope.metadataImport` during Stage 2 (RD-16); nothing is
/// stored, and nothing leaves the device.
class MetadataImportScreen extends StatelessWidget {
  const MetadataImportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<MetadataImportViewModel?>();
    return Scaffold(
      appBar: AppBar(title: const Text('Capture file metadata')),
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
                  "Reads a few kilobytes of a capture file's header, on this "
                  'device. Nothing is saved, and nothing leaves the phone.',
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
