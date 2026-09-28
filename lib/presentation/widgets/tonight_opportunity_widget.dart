import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_palette.dart';
import '../../core/theme/app_spacing.dart';
import '../../domain/models/imaging_opportunity.dart';
import '../../domain/services/fit_analyzer.dart';
import '../shared/night_time_formatter.dart';
import '../shared/opportunity_text.dart';
import '../viewmodels/capture_analysis_viewmodel.dart';
import '../viewmodels/site_viewmodel.dart';
import '../viewmodels/night_conditions_viewmodel.dart';
import 'altitude_chart_widget.dart';

/// "Tonight for this target" (TASK 10.3, ADR-013): the chart and the text
/// list of windows and excluded periods, both rendered from the same
/// [ImagingOpportunity]. Every excluded period shows its reasons; no score.
///
/// S6.16 (the owner's review, 6.1): the planner shows it after the capture
/// plan, as supporting analysis, under its own section heading ([title]);
/// its text uses the text roles, so the facts lead and the notes recede.
/// The chart is unchanged.
class TonightOpportunityWidget extends StatelessWidget {
  const TonightOpportunityWidget({super.key});

  /// The planner's heading for this section.
  static const title = 'Tonight for this target';

  @override
  Widget build(BuildContext context) {
    final conditionsVm = context.watch<NightConditionsViewModel>();
    final siteVm = context.watch<SiteViewModel>();
    final o = conditionsVm.imagingOpportunity;
    if (o == null) return const SizedBox.shrink();
    final theme = Theme.of(context);
    final palette = AppPalette.of(context);
    final zoneId = siteVm.displayZoneId;
    final moon = conditionsVm.moonConditions;
    // S6.12: the planned capture, as far as the fit exposes it (its end),
    // and only when the fit measured the plan.
    final fit = context.watch<CaptureAnalysisViewModel>().fitAnalysis;
    final measured =
        fit.state == FitState.fits ||
        fit.state == FitState.tight ||
        fit.state == FitState.doesNotFit;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: 'Usable time: ',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: palette.textSecondary,
                    ),
                  ),
                  TextSpan(
                    text: OpportunityText.duration(o.usableTime),
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: palette.textPrimary,
                    ),
                  ),
                ],
              ),
              key: const Key('opportunity.usable'),
            ),
            const SizedBox(height: AppSpacing.md),
            AltitudeChartWidget(
              opportunity: o,
              moonAltitudesDeg: moon == null
                  ? null
                  : [for (final s in moon.samples) s.altitudeDeg],
              zoneId: zoneId,
              nowUtc: conditionsVm.nowUtc,
              captureEndUtc: measured ? fit.endUtc : null,
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
    final palette = AppPalette.of(context);
    // S6.16: the text roles — group headings, the windows as the facts,
    // their notes and the excluded time quieter, the zone a caption.
    final heading = theme.textTheme.titleSmall?.copyWith(
      color: palette.textPrimary,
    );
    final fact = theme.textTheme.bodyMedium?.copyWith(
      color: palette.textPrimary,
    );
    final small = theme.textTheme.bodySmall?.copyWith(
      color: palette.textSecondary,
    );
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
        Text('Imaging windows', style: heading),
        if (reason != null)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Text(
              OpportunityText.noWindow(reason, o),
              key: const Key('opportunity.noWindow'),
              style: fact,
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
                  style: fact,
                ),
                if (OpportunityText.moon(w) case final m?)
                  Text(m, style: small),
                if (OpportunityText.weather(w) case final x?)
                  Text(x, style: small),
              ],
            ),
          ),
        const SizedBox(height: AppSpacing.sm),
        Text('Excluded time', style: heading),
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
          style: theme.textTheme.bodySmall?.copyWith(
            color: palette.textTertiary,
          ),
        ),
      ],
    );
  }
}
