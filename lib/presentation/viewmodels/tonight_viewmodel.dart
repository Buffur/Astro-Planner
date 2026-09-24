import 'package:flutter/foundation.dart';

import '../../core/diagnostics/app_log.dart';
import '../../domain/repositories/first_run_repository.dart';
import 'site_viewmodel.dart';
import 'startup_viewmodel.dart';

/// The Tonight tab's own state (TASK 12.5): whether to offer the first-run
/// setup. Everything the dashboard shows comes from the other ViewModels.
///
/// Owner decision: the setup is offered once, on a start with no site or
/// position, until it is finished or skipped; users who already have a
/// site never see it.
class TonightViewModel extends ChangeNotifier {
  TonightViewModel({
    required this._site,
    required this._startup,
    required this._firstRun,
  }) {
    _site.addListener(notifyListeners);
    _startup.addListener(notifyListeners);
  }

  final SiteViewModel _site;
  final StartupViewModel _startup;
  final FirstRunRepository _firstRun;

  /// Treated as done until [load] reads the stored flag, so nothing is
  /// offered before it is known.
  bool _done = true;
  bool _offered = false;

  /// Reads the stored flag; a failed read offers nothing.
  Future<void> load() async {
    try {
      _done = await _firstRun.isDone();
    } catch (e) {
      _done = true;
      AppLog.warning('startup', 'First-run state unreadable', error: e);
    }
    notifyListeners();
  }

  /// True once the app has loaded without a site and the setup was never
  /// finished, skipped or already offered in this run.
  bool get firstRunDue =>
      !_done &&
      !_offered &&
      !_startup.isLoading &&
      !_startup.hasBootstrapError &&
      _site.isDefaultLocation;

  /// The setup page is open; don't offer it again in this run.
  void markOffered() => _offered = true;

  /// Finished or skipped: never offered again.
  Future<void> finishFirstRun() async {
    _done = true;
    notifyListeners();
    await _firstRun.markDone();
  }

  @override
  void dispose() {
    _site.removeListener(notifyListeners);
    _startup.removeListener(notifyListeners);
    super.dispose();
  }
}
