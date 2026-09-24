import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../domain/services/backup_service.dart';
import '../../shared/night_time_formatter.dart';
import '../../viewmodels/backup_viewmodel.dart';
import '../../../core/config/app_identity.dart';

/// Backup and restore (TASK 14.4, owner decisions): a backup is one
/// `.astroplan` file shared wherever the user wants it; a restore is
/// checked, confirmed, and applied when the app next starts.
class BackupSection extends StatelessWidget {
  const BackupSection({super.key});

  static String problemText(BackupProblem p) => switch (p) {
    BackupProblem.notABackup =>
      'This file is not an ${AppIdentity.appName} backup, or it is damaged.',
    BackupProblem.newerSchema =>
      'This backup was made by a newer version of ${AppIdentity.appName}. Update the '
          'app first.',
    BackupProblem.tooOld =>
      'This backup is too old for this version of ${AppIdentity.appName}.',
  };

  Future<void> _restore(BuildContext context, BackupViewModel vm) async {
    final messenger = ScaffoldMessenger.of(context);
    final ({BackupPreview preview, Object file})? picked;
    try {
      picked = await vm.pick();
    } on BackupException catch (e) {
      messenger.showSnackBar(SnackBar(content: Text(problemText(e.problem))));
      return;
    }
    if (picked == null || !context.mounted) return;
    final p = picked.preview;
    final sure = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('Restore this backup?'),
        content: Text(
          'Made ${NightTimeFormatter.deviceZoneCaption(p.createdAtUtc)} '
          'by ${AppIdentity.appName} ${p.appVersion}, with ${p.sessionCount} '
          'sessions.\n\nAll current sessions, sites, rigs, targets and '
          'settings stored in the database are replaced when ${AppIdentity.appName} next '
          'starts. The current data is kept as a safety copy on this device.',
          key: const Key('backup.preview'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(c).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            key: const Key('backup.confirmRestore'),
            onPressed: () => Navigator.of(c).pop(true),
            child: const Text('Restore at next start'),
          ),
        ],
      ),
    );
    if (sure != true) return;
    await vm.stage(picked.file);
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<BackupViewModel?>();
    if (vm == null) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ListTile(
          key: const Key('backup.backUp'),
          contentPadding: EdgeInsets.zero,
          leading: const Icon(Icons.backup_outlined),
          title: const Text('Back up now'),
          subtitle: const Text(
            'One .astroplan file with all your data. Save it anywhere.',
          ),
          enabled: !vm.busy,
          onTap: vm.backUp,
        ),
        if (vm.restoreStaged)
          ListTile(
            key: const Key('backup.staged'),
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.restart_alt),
            title: const Text(
              'Restore ready: close and reopen ${AppIdentity.appName}',
            ),
            subtitle: const Text('Tap to cancel the restore.'),
            enabled: !vm.busy,
            onTap: vm.cancelRestore,
          )
        else
          ListTile(
            key: const Key('backup.restore'),
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.settings_backup_restore),
            title: const Text('Restore from a backup'),
            subtitle: const Text('Checked first; applied at the next start.'),
            enabled: !vm.busy,
            onTap: () => _restore(context, vm),
          ),
      ],
    );
  }
}
