import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../domain/models/session_night.dart';
import '../../shared/app_words.dart';
import '../../shared/context_line.dart';
import '../../shared/detail_scaffold.dart';
import '../../shared/night_text.dart';
import '../../shared/night_time_formatter.dart';
import '../../viewmodels/night_conditions_viewmodel.dart';
import '../../viewmodels/session_plan_viewmodel.dart';
import '../../viewmodels/site_viewmodel.dart';
import '../../widgets/sky_darkness_widget.dart';

/// The Night & Moon detail (S6.5; ADR-019 §5, §9; UX-10): the plan's
/// night — the dark span at the user's limit (TD-051), the Sun's timeline
/// with the standard twilight names, and the Moon. Opened from the
/// planner's and Tonight's Night rows. Every time is in the zone the header
/// names once.
class NightMoonScreen extends StatelessWidget {
  const NightMoonScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final plan = context.watch<SessionPlanViewModel>();
    final site = context.watch<SiteViewModel>();
    final conditions = context.watch<NightConditionsViewModel>();
    final night = plan.sessionNight;
    return DetailScaffold(
      title: 'Night & Moon',
      context: detailContext(night, site.locationName),
      zoneRule: night == null
          ? null
          : ContextLine.zoneRule(night.startUtc, zoneId: site.displayZoneId),
      summary: night == null
          ? const Text('Set a site to see the night.')
          : NightSummary(
              night: night,
              conditions: conditions,
              zoneId: site.displayZoneId,
            ),
      sections: night == null
          ? const []
          : const [NightTimelineSection(), MoonSection()],
    );
  }
}

/// "Night of Tue, Nov 10 · Ljubljana" for a detail's header (S6.5).
String? detailContext(SessionNight? night, String? siteName) {
  if (night == null) return null;
  final date =
      '${AppWords.nightOf} '
      '${NightTimeFormatter.eveningDate(night.eveningDate)}';
  return siteName == null ? date : '$date · $siteName';
}

/// The night in two lines (S6.5): the dark span at the user's limit, and
/// when the Moon is up. Shared by the Night & Moon detail's summary and the
/// planner's Night row; facts only.
class NightSummary extends StatelessWidget {
  const NightSummary({
    super.key,
    required this.night,
    required this.conditions,
    required this.zoneId,
  });

  final SessionNight night;
  final NightConditionsViewModel conditions;
  final String? zoneId;

  @override
  Widget build(BuildContext context) {
    String at(DateTime utc) => NightTimeFormatter.instant(
      context,
      utc,
      windowStartUtc: night.startUtc,
      zoneId: zoneId,
    );
    final dark = conditions.nightTimeline?.darkAtLimit;
    final moon = conditions.moonConditions;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (dark != null)
          Text(DarkText.span(dark, at), key: const Key('nightSummary.dark')),
        if (moon != null)
          Text(MoonText.up(moon, at), key: const Key('nightSummary.moon')),
      ],
    );
  }
}
