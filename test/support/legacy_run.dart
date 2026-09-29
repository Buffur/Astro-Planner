import 'package:astroplan/domain/models/session.dart';
import 'package:astroplan/domain/repositories/session_repository.dart';

/// A run in progress as the retired live mode left one (S8.4): a new row
/// with [saved]'s plan, started with its plan snapshot. The app no longer
/// starts runs; the repository still stores and replays them (history).
Future<Session> startLegacyRun(SessionRepository repo, Session saved) async {
  final row = await repo.create(
    SessionPlan(
      eveningDate: saved.eveningDate!,
      timeZoneId: saved.timeZoneId,
      siteId: saved.siteId,
      targetId: saved.targetId,
      rigId: saved.rigId,
      blocks: saved.blocks,
      targetLabel: saved.record.targetName,
      rigLabel: saved.record.equipmentName,
      siteLabel: saved.record.locationName,
      trackingOverride: saved.trackingOverride,
    ),
  );
  return repo.start(row.id, saved.planSnapshot!);
}
