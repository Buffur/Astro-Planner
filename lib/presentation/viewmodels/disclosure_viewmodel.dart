import 'package:flutter/foundation.dart';

import '../../core/diagnostics/app_log.dart';
import '../../domain/repositories/display_preferences_repository.dart';

/// Which collapsible sections the user left open (S5.5; ADR-019 §7): one
/// remembered state per section key, a display preference like field mode.
/// Call [load] before the first frame, so a section never jumps open after
/// it is drawn. A store that cannot be read or written only costs the
/// memory of the state: sections still open and close (logged, never
/// shown as an error; nothing else is at stake).
class DisclosureViewModel extends ChangeNotifier {
  DisclosureViewModel(this._repository);

  final DisplayPreferencesRepository _repository;
  final Map<String, bool> _open = {};

  /// Restores every remembered state; a failed read remembers none.
  Future<void> load() async {
    try {
      _open
        ..clear()
        ..addAll(await _repository.loadSectionStates());
    } catch (e) {
      _open.clear();
      AppLog.warning('display', 'Section states unreadable', error: e);
    }
    notifyListeners();
  }

  /// Whether [key]'s section is open; [initiallyOpen] until the user has
  /// opened or closed it.
  bool isOpen(String key, {bool initiallyOpen = false}) =>
      _open[key] ?? initiallyOpen;

  /// Opens or closes [key]'s section at once, then remembers it.
  Future<void> setOpen(String key, bool open) async {
    _open[key] = open;
    notifyListeners();
    try {
      await _repository.saveSectionState(key, open);
    } catch (e) {
      AppLog.warning('display', 'Section state not saved: $key', error: e);
    }
  }
}
