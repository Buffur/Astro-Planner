import 'package:flutter/material.dart';

import '../../../core/config/app_identity.dart';
import '../../../core/theme/app_theme.dart';
import '../../shared/failure_feedback.dart';

/// Shown instead of the app when the database file is at a schema version
/// this build cannot open (ADR-008 §2; TASK 3.2, TD-047, S1.5).
///
/// - **Newer than the app:** explains that a newer version saved the data
///   and must be installed. The file is never reset.
/// - **Below the supported floor:** explains that the data comes from a
///   pre-release build, and offers to start with fresh data after an
///   explicit confirmation. [onReset] keeps the old file (renamed), never
///   deletes it.
class UnsupportedDatabaseApp extends StatelessWidget {
  const UnsupportedDatabaseApp({
    super.key,
    required this.newerThanApp,
    required this.foundVersion,
    required this.onReset,
  });

  final bool newerThanApp;
  final int foundVersion;

  /// Starts with fresh data; only offered below the floor.
  final Future<void> Function() onReset;

  @override
  Widget build(BuildContext context) => MaterialApp(
    title: AppIdentity.appName,
    theme: AppTheme.light,
    darkTheme: AppTheme.dark,
    debugShowCheckedModeBanner: false,
    home: UnsupportedDatabaseScreen(
      newerThanApp: newerThanApp,
      foundVersion: foundVersion,
      onReset: onReset,
    ),
  );
}

class UnsupportedDatabaseScreen extends StatefulWidget {
  const UnsupportedDatabaseScreen({
    super.key,
    required this.newerThanApp,
    required this.foundVersion,
    required this.onReset,
  });

  final bool newerThanApp;
  final int foundVersion;
  final Future<void> Function() onReset;

  @override
  State<UnsupportedDatabaseScreen> createState() =>
      _UnsupportedDatabaseScreenState();
}

class _UnsupportedDatabaseScreenState extends State<UnsupportedDatabaseScreen> {
  bool _busy = false;

  Future<void> _confirmReset() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Start with fresh data?'),
        content: const Text(
          'Your old sites, rigs, targets and sessions will no longer be shown '
          'in the app. The old data file is kept on this device, renamed, '
          'and is not deleted.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            key: const Key('unsupportedDb.confirm'),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Start fresh'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    setState(() => _busy = true);
    final done = await runWithFeedback(
      context,
      'start with fresh data',
      widget.onReset,
    );
    if (!done && mounted) setState(() => _busy = false);
  }

  @override
  Widget build(BuildContext context) {
    final version = widget.foundVersion;
    final name = AppIdentity.appName;
    return Scaffold(
      appBar: AppBar(title: Text(name)),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            Text(
              widget.newerThanApp
                  ? 'Your data needs a newer version'
                  : "Your data can't be upgraded",
              key: const Key('unsupportedDb.title'),
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            Text(
              widget.newerThanApp
                  ? 'Your planner data was saved by a newer version of $name '
                        '(data version $version). This version cannot open '
                        'it. Install the latest version of $name to continue. '
                        'Nothing has been changed.'
                  : 'Your planner data comes from a pre-release build of '
                        '$name (data version $version) and cannot be '
                        'upgraded. Nothing has been changed. You can start '
                        'with fresh data; the old file is kept on this '
                        'device, not deleted.',
              key: const Key('unsupportedDb.message'),
            ),
            if (!widget.newerThanApp) ...[
              const SizedBox(height: 24),
              FilledButton(
                key: const Key('unsupportedDb.reset'),
                onPressed: _busy ? null : _confirmReset,
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(48),
                ),
                child: const Text('Start with fresh data'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
