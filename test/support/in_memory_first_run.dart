import 'package:astroplan/domain/repositories/first_run_repository.dart';

/// In-memory [FirstRunRepository] for tests; [done] is the stored flag.
class InMemoryFirstRun implements FirstRunRepository {
  InMemoryFirstRun({this.done = false});

  bool done;

  @override
  Future<bool> isDone() async => done;

  @override
  Future<void> markDone() async => done = true;
}
