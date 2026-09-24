import 'package:flutter/foundation.dart';

import '../../core/diagnostics/app_log.dart';
import '../../domain/repositories/display_preferences_repository.dart';

/// Red field mode (F-46): on or off, persisted across restarts since
/// TASK 12.4. Call [load] before the first frame so a restart in field
/// mode never flashes the normal theme.
class ThemeViewModel extends ChangeNotifier {
  ThemeViewModel(this._repository);

  final DisplayPreferencesRepository _repository;
  bool _isFieldMode = false;

  bool get isFieldMode => _isFieldMode;

  /// Restores the saved mode; a failed read leaves it off.
  Future<void> load() async {
    try {
      _isFieldMode = await _repository.loadFieldMode();
    } catch (e) {
      _isFieldMode = false;
      AppLog.warning('display', 'Field-mode setting unreadable', error: e);
    }
    notifyListeners();
  }

  Future<void> toggleFieldMode() async {
    _isFieldMode = !_isFieldMode;
    notifyListeners();
    await _repository.saveFieldMode(_isFieldMode);
  }
}
