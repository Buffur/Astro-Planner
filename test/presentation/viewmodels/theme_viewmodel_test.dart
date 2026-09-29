// Field mode is persisted (TASK 12.4, F-46): it survives a restart.

import 'package:astroplan/domain/repositories/display_preferences_repository.dart';
import 'package:astroplan/presentation/viewmodels/theme_viewmodel.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/in_memory_display_preferences.dart';

class _BrokenStore implements DisplayPreferencesRepository {
  @override
  Future<bool> loadFieldMode() => throw StateError('unreadable');

  @override
  Future<void> saveFieldMode(bool on) async {}

  @override
  Future<Map<String, bool>> loadSectionStates() async => {};

  @override
  Future<void> saveSectionState(String key, bool open) async {}
}

void main() {
  test('off by default', () async {
    final vm = ThemeViewModel(InMemoryDisplayPreferences());
    await vm.load();
    expect(vm.isFieldMode, isFalse);
  });

  test('a toggle is saved and restored after a restart', () async {
    final store = InMemoryDisplayPreferences();
    final before = ThemeViewModel(store);
    await before.load();
    await before.toggleFieldMode();
    expect(store.fieldMode, isTrue);

    final after = ThemeViewModel(store); // a new app start
    await after.load();
    expect(after.isFieldMode, isTrue);

    await after.toggleFieldMode();
    final again = ThemeViewModel(store);
    await again.load();
    expect(again.isFieldMode, isFalse);
  });

  test('an unreadable store leaves field mode off', () async {
    final vm = ThemeViewModel(_BrokenStore());
    await vm.load();
    expect(vm.isFieldMode, isFalse);
  });
}
