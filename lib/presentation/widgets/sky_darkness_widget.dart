import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../viewmodels/site_viewmodel.dart';
import '../viewmodels/night_conditions_viewmodel.dart';
import '../shared/app_words.dart';
import '../shared/night_time_formatter.dart';
import '../../core/theme/app_palette.dart';
import '../../../core/config/feature_scope.dart';
import '../../../domain/models/moon_conditions.dart';
import '../../../domain/models/night_timeline.dart';
import '../../../domain/models/sky_darkness.dart';
import '../shared/night_text.dart';
import '../../core/utils/quantity_text.dart';

/// The site's sky darkness in the planner (TASK 7.4): Bortle and SQM as
/// entered, with their sources, or unknown. Since S6.5 the night's timeline
/// and the Moon are on the Night & Moon detail ([NightTimelineSection],
/// [MoonSection]); the planner shows a summary row for them.
class SkyDarknessWidget extends StatelessWidget {
  const SkyDarknessWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final siteVm = context.watch<SiteViewModel>();
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // TASK 15.3: wraps instead of overflowing at large text.
            Wrap(
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 8,
              runSpacing: 4,
              children: [
                Text(
                  'Sky darkness',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (FeatureScope.lightPollutionContext)
                  _BortleBadge(
                    bortleClass: siteVm.bortleClass,
                    onChanged: siteVm.setBortleClass,
                  ),
              ],
            ),
            if (FeatureScope.lightPollutionContext)
              _SkyDarknessLine(
                darkness: siteVm.skyDarkness,
                hasSite: siteVm.activeSite != null,
              ),
          ],
        ),
      ),
    );
  }
}

/// The known sky darkness with its source, or an explicit "unknown"
/// (TASK 7.4; SI-007, SI-008). Bortle and SQM are shown as entered — never
/// converted into each other.
class _SkyDarknessLine extends StatelessWidget {
  const _SkyDarknessLine({required this.darkness, required this.hasSite});

  final SkyDarkness darkness;
  final bool hasSite;

  static String _source(String? source, Object? date) {
    if (source == null) return 'source unknown';
    return date == null ? source : '$source, $date';
  }

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context).textTheme.bodySmall;
    final String text;
    if (darkness.isUnknown) {
      text = hasSite
          ? 'Sky darkness unknown — pick a Bortle class above, or add Bortle '
                'or SQM in the site editor.'
          : 'Sky darkness unknown — pick a Bortle class above; save this '
                'position as a site to keep it or to record SQM.';
    } else {
      final parts = [
        if (darkness.hasBortle)
          'Bortle ${darkness.bortleClass} '
              '(${_source(darkness.bortleSource, darkness.bortleDate?.toIso8601String())})',
        if (darkness.hasSqm)
          'SQM ${darkness.sqm!.toStringAsFixed(2)} mag/arcsec² '
              '(${_source(darkness.sqmSource, darkness.sqmDate?.toIso8601String())})',
      ];
      text = parts.join(' · ') + (darkness.isSaved ? '' : ' — not saved');
    }
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Text(text, style: style),
    );
  }
}

class _BortleBadge extends StatelessWidget {
  /// Null when unknown (SI-007, TASK 7.1).
  final int? bortleClass;
  final ValueChanged<int?> onChanged;

  const _BortleBadge({required this.bortleClass, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final palette = AppPalette.of(context);
    final i = bortleClass ?? 0;
    final badgeColor = palette.bortle[i];
    final textColor = palette.onBortle[i];

    return Container(
      height: 32,
      padding: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: badgeColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: palette.swatchBorder, width: 0.5),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<int?>(
          value: bortleClass,
          dropdownColor: Theme.of(context).cardColor,
          icon: Icon(Icons.arrow_drop_down, color: textColor),
          items: [
            DropdownMenuItem<int?>(
              value: null,
              child: Text(
                'Bortle unknown',
                style: TextStyle(
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                ),
              ),
            ),
            ...List.generate(
              9,
              (index) => DropdownMenuItem<int?>(
                value: index + 1,
                child: Text(
                  'Bortle ${index + 1}',
                  style: TextStyle(
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                  ),
                ),
              ),
            ),
          ],
          onChanged: onChanged,
          selectedItemBuilder: (BuildContext context) {
            return List.generate(10, (i) {
              final index = i - 1; // item 0 is "unknown"
              return Center(
                child: Padding(
                  padding: const EdgeInsets.only(left: 8.0, right: 4.0),
                  child: Text(
                    i == 0 ? 'Bortle ?' : 'Bortle ${index + 1}',
                    style: TextStyle(
                      color: textColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ),
              );
            });
          },
        ),
      ),
    );
  }
}

/// The night's Sun timeline for the Night & Moon detail (S6.5, TD-051):
/// sunset, each standard twilight and sunrise — the only place their names
/// appear (ADR-019 §10) — and the dark span at the user's darkness limit,
/// which the imaging opportunity uses. Times are in the zone the detail's
/// header names once.
class NightTimelineSection extends StatelessWidget {
  const NightTimelineSection({super.key});

  @override
  Widget build(BuildContext context) {
    final timeline = context.watch<NightConditionsViewModel>().nightTimeline;
    final zoneId = context.watch<SiteViewModel>().displayZoneId;
    final theme = Theme.of(context);
    if (timeline == null) {
      return Text(
        'Set your site to see the night.',
        style: TextStyle(color: AppPalette.of(context).textSecondary),
      );
    }
    String at(DateTime utc) => NightTimeFormatter.instant(
      context,
      utc,
      windowStartUtc: timeline.night.startUtc,
      zoneId: zoneId,
    );
    String dusk(SunThresholdResult r) => switch (r) {
      SunCrossing(:final duskUtc?) => at(duskUtc),
      SunCrossing() => 'before the night starts',
      SunNeverBelow() => 'not tonight',
      SunAlwaysBelow() => 'all night',
    };
    String dawn(SunThresholdResult r) => switch (r) {
      SunCrossing(:final dawnUtc?) => at(dawnUtc),
      SunCrossing() => 'after the night ends',
      SunNeverBelow() => 'not tonight',
      SunAlwaysBelow() => 'all night',
    };
    final rows = [
      ('Sunset', dusk(timeline.sunriseSunset)),
      (AppWords.civilDusk, dusk(timeline.civilTwilight)),
      (AppWords.nauticalDusk, dusk(timeline.nauticalTwilight)),
      (AppWords.astronomicalDusk, dusk(timeline.astronomicalTwilight)),
      (AppWords.astronomicalDawn, dawn(timeline.astronomicalTwilight)),
      (AppWords.nauticalDawn, dawn(timeline.nauticalTwilight)),
      (AppWords.civilDawn, dawn(timeline.civilTwilight)),
      ('Sunrise', dawn(timeline.sunriseSunset)),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (timeline.darkAtLimit case final dark?)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              DarkText.span(dark, at),
              key: const Key('night.dark'),
              style: theme.textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        for (final (label, time) in rows)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 2),
            // Wraps at large text rather than overflowing (TASK 15.3).
            child: Wrap(
              alignment: WrapAlignment.spaceBetween,
              spacing: 8,
              children: [
                Text(label, style: theme.textTheme.bodyMedium),
                Text(time, style: theme.textTheme.bodyMedium),
              ],
            ),
          ),
      ],
    );
  }
}

/// The Moon for the Night & Moon detail (TASK 6.4; moved here in S6.5):
/// its illumination at midnight, when it is up, and how close it comes to
/// the target — annotations only, never an "impact %" (ADR-010).
class MoonSection extends StatelessWidget {
  const MoonSection({super.key});

  @override
  Widget build(BuildContext context) {
    final conditionsVm = context.watch<NightConditionsViewModel>();
    final zoneId = context.watch<SiteViewModel>().displayZoneId;
    final illum = conditionsVm.lunarIllumination;
    final lunarIllum = illum == null ? '--' : QuantityText.percent(illum * 100);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Icon(
              Icons.nightlight_round,
              size: 20,
              color: AppPalette.of(context).moon,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Moon Illumination at midnight: $lunarIllum',
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
        _MoonDetails(conditions: conditionsVm.moonConditions, zoneId: zoneId),
      ],
    );
  }
}

/// When the Moon is up tonight and how close it comes to the target.
class _MoonDetails extends StatelessWidget {
  const _MoonDetails({required this.conditions, required this.zoneId});

  final MoonConditions? conditions;

  /// The site's IANA zone, or null for the device zone (TASK 7.1).
  final String? zoneId;

  @override
  Widget build(BuildContext context) {
    final c = conditions;
    if (c == null) return const SizedBox.shrink();
    final style = Theme.of(context).textTheme.bodySmall;
    String at(DateTime utc) => NightTimeFormatter.instant(
      context,
      utc,
      windowStartUtc: c.night.startUtc,
      zoneId: zoneId,
    );

    final upText = MoonText.up(c, at);

    final hasTarget =
        c.samples.isNotEmpty && c.samples.first.separationDeg != null;
    final approach = c.closestApproachWhileBothUp;
    final String? sepText = !hasTarget
        ? null
        : approach == null
        ? 'The Moon and the target are not up at the same time tonight.'
        : 'Closest to the target while both are up: '
              '${approach.separationDeg.round()}° at ${at(approach.instantUtc)}.';

    return Padding(
      padding: const EdgeInsets.only(left: 28, top: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(upText, key: const Key('sky.moonUp'), style: style),
          if (sepText != null)
            Text(sepText, key: const Key('sky.moonSeparation'), style: style),
        ],
      ),
    );
  }
}
