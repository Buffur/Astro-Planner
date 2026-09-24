/// A repository could not read or write its store (TASK 15.1): the typed
/// failure every repository throws in place of a database or preferences
/// error. Domain refusals ([ArgumentError], `SessionStateError`,
/// `ExecutionError`) are not storage failures and pass through unchanged.
class StorageFailure implements Exception {
  const StorageFailure(this.action, [this.cause]);

  /// What was being done, as a verb phrase: "save a site", "read the
  /// sessions". User-facing wording is built from it in the presentation.
  final String action;

  /// The underlying error, for the log; never shown to the user.
  final Object? cause;

  @override
  String toString() =>
      'StorageFailure: could not $action${cause == null ? '' : ' ($cause)'}';
}
