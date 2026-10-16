import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/repositories/first_run_repository.dart';
import 'storage_guard.dart';

/// [FirstRunRepository] backed by SharedPreferences.
class SharedPrefsFirstRunRepository implements FirstRunRepository {
  static const doneKey = 'firstRunDone';

  @override
  Future<bool> isDone() => guardStorage(
    'read the first-run state',
    () async =>
        (await SharedPreferences.getInstance()).getBool(doneKey) ?? false,
  );

  @override
  Future<void> markDone() => guardStorage(
    'save the first-run state',
    () async => (await SharedPreferences.getInstance()).setBool(doneKey, true),
  );
}
