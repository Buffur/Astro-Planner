import 'dart:collection';
import 'dart:developer' as developer;

/// How serious a [LogEntry] is.
enum LogLevel { info, warning, error }

/// One diagnostic message kept by [AppLog].
class LogEntry {
  const LogEntry(
    this.timeUtc,
    this.level,
    this.scope,
    this.message, {
    this.error,
    this.stackTrace,
  });

  final DateTime timeUtc;
  final LogLevel level;

  /// Where it happened, e.g. `storage`, `weather`, `startup`.
  final String scope;
  final String message;
  final Object? error;
  final StackTrace? stackTrace;

  @override
  String toString() =>
      '${timeUtc.toIso8601String()} ${level.name} [$scope] $message'
      '${error == null ? '' : ': $error'}';
}

/// The app's debug logger (TASK 15.1). Every caught failure that is not
/// shown to the user is logged here instead of being swallowed.
///
/// Local only: entries go to the developer console (`dart:developer`) and a
/// bounded in-memory buffer ([recent]); nothing is written to disk or sent
/// anywhere — crash reporting is deferred for privacy (MASTER_ROADMAP 15.1).
/// Pure Dart, so the domain can use it.
abstract final class AppLog {
  /// How many entries [recent] keeps.
  static const int capacity = 200;

  static final Queue<LogEntry> _entries = Queue<LogEntry>();

  /// The most recent entries, oldest first.
  static List<LogEntry> get recent => List.unmodifiable(_entries);

  static void info(String scope, String message) =>
      _add(LogLevel.info, scope, message, null, null);

  static void warning(
    String scope,
    String message, {
    Object? error,
    StackTrace? stackTrace,
  }) => _add(LogLevel.warning, scope, message, error, stackTrace);

  static void error(
    String scope,
    String message, {
    Object? error,
    StackTrace? stackTrace,
  }) => _add(LogLevel.error, scope, message, error, stackTrace);

  /// Empties [recent] (tests).
  static void clear() => _entries.clear();

  static void _add(
    LogLevel level,
    String scope,
    String message,
    Object? error,
    StackTrace? stackTrace,
  ) {
    _entries.addLast(
      LogEntry(
        DateTime.now().toUtc(),
        level,
        scope,
        message,
        error: error,
        stackTrace: stackTrace,
      ),
    );
    while (_entries.length > capacity) {
      _entries.removeFirst();
    }
    developer.log(
      message,
      name: 'astroplan.$scope',
      level: switch (level) {
        LogLevel.info => 800,
        LogLevel.warning => 900,
        LogLevel.error => 1000,
      },
      error: error,
      stackTrace: stackTrace,
    );
  }
}
