import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../domain/models/imaging_opportunity.dart';
import '../shared/night_time_formatter.dart';
import '../shared/opportunity_text.dart';
import '../viewmodels/site_viewmodel.dart';
import '../viewmodels/night_conditions_viewmodel.dart';
import 'altitude_chart_widget.dart';

/// "Tonight for this target" (TASK 10.3, ADR-013): the chart and the text
/// list of windows and excluded periods, both rendered from the same
/// [ImagingOpportunity]. Every excluded period shows its reasons; no score.
class TonightOpportunityWidget extends StatelessWidget {
  const TonightOpportunityWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final conditionsVm = context.watch<NightConditionsViewModel>();
    final siteVm = context.watch<SiteViewModel>();
    final o = conditionsVm.imagingOpportunity;
    if (o == null) return const SizedBox.shrink();
    final theme = Theme.of(context);
    final zoneId = siteVm.displayZoneId;
    final moon = conditionsVm.moonConditions;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Tonight for this target',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Usable time: ${OpportunityText.duration(o.usableTime)}',
              key: const Key('opportunity.usable'),
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            AltitudeChartWidget(
              opportunity: o,
              moonAltitudesDeg: moon == null
                  ? null
                  : [for (final s in moon.samples) s.altitudeDeg],
              zoneId: zoneId,
              nowUtc: conditionsVm.nowUtc,
            ),
            const SizedBox(height: 12),
            OpportunityList(opportunity: o, zoneId: zoneId),
          ],
        ),
      ),
    );
  }
}

/// The windows with their annotations, then every excluded period with its
/// reasons (TASK 10.3).
class OpportunityList extends StatelessWidget {
  const OpportunityList({super.key, required this.opportunity, this.zoneId});

  final ImagingOpportunity opportunity;
  final String? zoneId;

  @override
  Widget build(BuildContext context) {
    final o = opportunity;
    final theme = Theme.of(context);
    final small = theme.textTheme.bodySmall;
    String at(DateTime t) => NightTimeFormatter.instant(
      context,
      t,
      windowStartUtc: o.night.startUtc,
      zoneId: zoneId,
    );
    String span(
      DateTime a,
      DateTime b, {
      bool fromStart = false,
      bool toEnd = false,
    }) =>
        '${fromStart ? 'from the start of the night' : at(a)} – '
        '${toEnd ? 'the end of the night' : at(b)}';

    final reason = o.noWindowReason;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('Imaging windows', style: theme.textTheme.labelLarge),
        if (reason != null)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Text(
              OpportunityText.noWindow(reason, o),
              key: const Key('opportunity.noWindow'),
            ),
          ),
        for (final (i, w) in o.windows.indexed)
          Padding(
            key: Key('opportunity.window.$i'),
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${span(w.startUtc, w.endUtc, fromStart: w.window.clippedAtStart, toEnd: w.window.clippedAtEnd)}'
                  ' · ${OpportunityText.duration(w.duration)}'
                  ' · ${OpportunityText.maxAltitude(w, at(w.maxAltitudeAtUtc))}',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (OpportunityText.moon(w) case final m?)
                  Text(m, style: small),
                if (OpportunityText.weather(w) case final x?)
                  Text(x, style: small),
              ],
            ),
          ),
        const SizedBox(height: 8),
        Text('Excluded time', style: theme.textTheme.labelLarge),
        for (final (i, s) in o.excluded.indexed)
          Padding(
            key: Key('opportunity.excluded.$i'),
            padding: const EdgeInsets.symmetric(vertical: 1),
            child: Text(
              '${span(s.startUtc, s.endUtc)}: ${OpportunityText.reasons(s, o)}',
              style: small,
            ),
          ),
        const SizedBox(height: 4),
        Text(
          'Times in ${NightTimeFormatter.zoneCaption(o.night.startUtc, zoneId: zoneId)}.',
          style: small,
        ),
      ],
    );
  }
}
