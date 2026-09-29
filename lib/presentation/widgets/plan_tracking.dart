import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../domain/models/tracking_type.dart';
import '../shared/failure_feedback.dart';
import '../viewmodels/session_plan_viewmodel.dart';

/// The words for a plan's tracking (RD-08 = T3; S7.1).
abstract final class PlanTrackingText {
  static const title = 'Tracking for this plan';

  /// The choice that follows the rig: "Rig's default (Unknown)".
  static String rigDefault(TrackingType rigDefault) =>
      "Rig's default (${rigDefault.label})";

  /// What the plan uses now, and where it comes from.
  static String summary(TrackingType? override, TrackingType rigDefault) =>
      override == null
      ? PlanTrackingText.rigDefault(rigDefault)
      : '${override.label} · this plan only';
}

/// Chooses this plan's tracking (S7.1): the rig's default, or one of the
/// known types for this plan only. A plan edit, autosaved; the rig is never
/// changed, and unknown comes only from the rig's default.
Future<void> pickPlanTracking(BuildContext context) async {
  final plan = context.read<SessionPlanViewModel>();
  final rigDefault =
      plan.selectedEquipment?.trackingType ?? TrackingType.unknown;
  final choice = await showDialog<({TrackingType? value})>(
    context: context,
    builder: (context) => SimpleDialog(
      title: const Text(PlanTrackingText.title),
      children: [
        for (final option in <TrackingType?>[null, ...TrackingType.overrides])
          SimpleDialogOption(
            key: Key('planTracking.${option?.name ?? 'rig'}'),
            onPressed: () => Navigator.pop(context, (value: option)),
            child: ConstrainedBox(
              constraints: const BoxConstraints(minHeight: 48),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      option == null
                          ? PlanTrackingText.rigDefault(rigDefault)
                          : option.label,
                    ),
                  ),
                  if (option == plan.trackingOverride)
                    const Icon(Icons.check, semanticLabel: 'Chosen'),
                ],
              ),
            ),
          ),
      ],
    ),
  );
  if (choice == null || !context.mounted) return;
  if (choice.value == plan.trackingOverride) return;
  await runWithFeedback(
    context,
    'change the tracking',
    () => plan.setTrackingOverride(choice.value),
  );
}

/// The planner's row for the plan's tracking (S7.1), under the rig: what
/// the plan's guidance uses and where it comes from; a tap changes it.
class PlanTrackingRow extends StatelessWidget {
  const PlanTrackingRow({super.key});

  @override
  Widget build(BuildContext context) {
    final plan = context.watch<SessionPlanViewModel>();
    final rigDefault =
        plan.selectedEquipment?.trackingType ?? TrackingType.unknown;
    return ListTile(
      key: const Key('planner.tracking'),
      contentPadding: EdgeInsets.zero,
      title: const Text(PlanTrackingText.title),
      subtitle: Text(
        PlanTrackingText.summary(plan.trackingOverride, rigDefault),
      ),
      trailing: const Icon(Icons.edit_outlined),
      onTap: () => pickPlanTracking(context),
    );
  }
}
