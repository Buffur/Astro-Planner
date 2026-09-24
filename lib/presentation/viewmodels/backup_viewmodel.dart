import 'package:flutter/foundation.dart';

import '../../domain/services/backup_service.dart';

/// Backup and restore in Settings (TASK 14.4). A restore is checked,
/// confirmed by the user, staged, and applied at the next start.
class BackupViewModel extends ChangeNotifier {
  BackupViewModel(this._service);

  final BackupService _service;
  bool _staged = false;
  bool _busy = false;

  bool get restoreStaged => _staged;
  bool get busy => _busy;

  Future<void> load() async {
    _staged = await _service.hasStagedRestore();
    notifyListeners();
  }

  Future<void> backUp() => _run(_service.backUpAndShare);

  /// Picks and checks a backup; null if cancelled. Throws
  /// [BackupException] for a file that cannot be restored.
  Future<({BackupPreview preview, Object file})?> pick() async {
    _busy = true;
    notifyListeners();
    try {
      return await _service.pick();
    } finally {
      _busy = false;
      notifyListeners();
    }
  }

  /// After the user confirmed [preview]: stage it for the next start.
  Future<void> stage(Object file) => _run(() async {
    await _service.stage(file);
    _staged = true;
  });

  Future<void> cancelRestore() => _run(() async {
    await _service.cancelStagedRestore();
    _staged = false;
  });

  Future<void> _run(Future<void> Function() action) async {
    _busy = true;
    notifyListeners();
    try {
      await action();
    } finally {
      _busy = false;
      notifyListeners();
    }
  }
}
