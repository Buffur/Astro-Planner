import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/repositories/first_run_repository.dart';

/// [FirstRunRepository] backed by SharedPreferences.
class SharedPrefsFirstRunRepository implements FirstRunRepository {
  static const _done = 'firstRunDone';

  @override
  Future<bool> isDone() async =>
      (await SharedPreferences.getInstance()).getBool(_done) ?? false;

  @override
  Future<void> markDone() async =>
      (await SharedPreferences.getInstance()).setBool(_done, true);
}
