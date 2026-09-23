import 'package:flutter/foundation.dart';

import 'night_conditions_viewmodel.dart';
import 'session_plan_viewmodel.dart';
import 'settings_viewmodel.dart';
import 'site_viewmodel.dart';

/// App startup (TASK 1.2; split out of the planner ViewModel in TASK 12.3):
/// loads the site, the settings and the plan in that order, then starts the
/// night's forecast after the first frame. A failure is a state
/// ([hasBootstrapError], retried with [retryBootstrap]), never an unguarded
/// throw.
class StartupViewModel extends ChangeNotifier {
  StartupViewModel({
    required this._site,
    required this._settings,
    required this._plan,
    required this._conditions,
  }) {
    ready = _load();
  }

  final SiteViewModel _site;
  final SettingsViewModel _settings;
  final SessionPlanViewModel _plan;
  final NightConditionsViewModel _conditions;

  /// Completes when the initial state has loaded (not the forecast, reverse
  /// geocoding or any GPS lookup).
  late Future<void> ready;

  bool _isLoading = true;
  Object? _error;

  bool get isLoading => _isLoading;
  bool get hasBootstrapError => _error != null;

  Future<void> _load() async {
    try {
      await _site.load();
      await _settings.load();
      await _plan.load();
      _error = null;
    } catch (e) {
      _error = e;
      debugPrint('Startup error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
    if (_error == null) _conditions.begin();
  }

  Future<void> retryBootstrap() {
    _isLoading = true;
    notifyListeners();
    return ready = _load();
  }
}
