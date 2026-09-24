import 'package:astroplan/core/diagnostics/app_log.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  setUp(AppLog.clear);

  test('keeps entries with their level, scope and error', () {
    final error = StateError('boom');
    AppLog.info('startup', 'ready');
    AppLog.warning('weather', 'cache unreadable');
    AppLog.error('storage', 'Could not save', error: error);

    final entries = AppLog.recent;
    expect(entries.map((e) => e.level), [
      LogLevel.info,
      LogLevel.warning,
      LogLevel.error,
    ]);
    expect(entries.last.scope, 'storage');
    expect(entries.last.error, same(error));
    expect(entries.last.timeUtc.isUtc, isTrue);
    expect(entries.last.toString(), contains('[storage] Could not save'));
  });

  test('is bounded: only the most recent entries are kept', () {
    for (var i = 0; i < AppLog.capacity + 5; i++) {
      AppLog.info('test', 'entry $i');
    }
    final entries = AppLog.recent;
    expect(entries, hasLength(AppLog.capacity));
    expect(entries.first.message, 'entry 5');
    expect(entries.last.message, 'entry ${AppLog.capacity + 4}');
  });

  test('recent is a read-only copy', () {
    AppLog.info('test', 'one');
    expect(() => AppLog.recent.clear(), throwsUnsupportedError);
  });
}
