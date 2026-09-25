import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../viewmodels/site_viewmodel.dart';
import '../viewmodels/night_conditions_viewmodel.dart';
import '../shared/night_time_formatter.dart';
import '../../core/theme/app_palette.dart';
import '../../../core/config/feature_scope.dart';
import '../../../domain/models/moon_conditions.dart';
import '../../../domain/models/night_timeline.dart';
import '../../../domain/models/sky_darkness.dart';
import '../shared/night_text.dart';
import '../../core/utils/quantity_text.dart';

class SkyDarknessWidget extends StatelessWidget {
  const SkyDarknessWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final conditionsVm = context.watch<NightConditionsViewModel>();
    final siteVm = context.watch<SiteViewModel>();
    final timeline = conditionsVm.nightTimeline;
    final theme = Theme.of(context);

    final illum = conditionsVm.lunarIllumination;
    final lunarIllum = illum == null ? '--' : QuantityText.percent(illum * 100);

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
                  'Sky Darkness & Timeline',
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
            const SizedBox(height: 16),

            // Moon Status
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
            _MoonDetails(
              conditions: conditionsVm.moonConditions,
              zoneId: siteVm.displayZoneId,
            ),

            const SizedBox(height: 16),

            // Night Timeline
            _NightTimelineVisual(
              timeline: timeline,
              zoneId: siteVm.displayZoneId,
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

class _NightTimelineVisual extends StatelessWidget {
  final NightTimeline? timeline;

  /// The site's IANA zone, or null for the device zone (TASK 7.1).
  final String? zoneId;

  const _NightTimelineVisual({required this.timeline, required this.zoneId});

  @override
  Widget build(BuildContext context) {
    final timeline = this.timeline;
    if (timeline == null) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Text(
          'Set your site to see tonight\'s timeline.',
          style: TextStyle(color: AppPalette.of(context).muted),
        ),
      );
    }
    final windowStart = timeline.night.startUtc;

    String dusk(SunThresholdResult r) => switch (r) {
      SunCrossing(:final duskUtc?) => NightTimeFormatter.instant(
        context,
        duskUtc,
        windowStartUtc: windowStart,
        zoneId: zoneId,
      ),
      SunCrossing() => 'Before start',
      SunNeverBelow() => 'N/A',
      SunAlwaysBelow() => 'All night',
    };
    String dawn(SunThresholdResult r) => switch (r) {
      SunCrossing(:final dawnUtc?) => NightTimeFormatter.instant(
        context,
        dawnUtc,
        windowStartUtc: windowStart,
        zoneId: zoneId,
      ),
      SunCrossing() => 'After end',
      SunNeverBelow() => 'N/A',
      SunAlwaysBelow() => 'All night',
    };

    final palette = AppPalette.of(context);
    return Column(
      children: [
        // TASK 15.3: four equal columns whose text wraps, so neither a
        // narrow phone nor 200 % text overflows.
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _TimelinePoint(
              label: 'Sunset',
              time: dusk(timeline.sunriseSunset),
              icon: Icons.wb_sunny_outlined,
              color: palette.sunEvent,
            ),
            _TimelinePoint(
              label: 'Astro Dusk',
              time: dusk(timeline.astronomicalTwilight),
              icon: Icons.nights_stay_outlined,
              color: palette.twilightEvent,
            ),
            _TimelinePoint(
              label: 'Astro Dawn',
              time: dawn(timeline.astronomicalTwilight),
              icon: Icons.nights_stay,
              color: palette.twilightEvent,
            ),
            _TimelinePoint(
              label: 'Sunrise',
              time: dawn(timeline.sunriseSunset),
              icon: Icons.wb_sunny,
              color: palette.sunEvent,
            ),
          ],
        ),
        // TASK 10.3 (TD-034): the decorative gradient bar is removed; the
        // data-driven darkness bands are in "Tonight for this target".
        const SizedBox(height: 8),
        Text(
          'True Night Window: ${dusk(timeline.astronomicalTwilight)} - '
          '${dawn(timeline.astronomicalTwilight)} '
          '(${NightTimeFormatter.zoneCaption(windowStart, zoneId: zoneId)})',
          style: Theme.of(context).textTheme.bodySmall
              ?.copyWith(fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}

class _TimelinePoint extends StatelessWidget {
  final String label;
  final String time;
  final IconData icon;
  final Color color;

  const _TimelinePoint({
    required this.label,
    required this.time,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(height: 4),
          Text(
            time,
            textAlign: TextAlign.center,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
          ),
          Text(
            label,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.labelSmall,
          ),
        ],
      ),
    );
  }
}

/// When the Moon is up tonight and how close it comes to the target —
/// annotations only, never an "impact %" (ADR-010, TASK 6.4).
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
          Text(
            'Times in ${NightTimeFormatter.zoneCaption(c.night.startUtc, zoneId: zoneId)}.',
            style: style,
          ),
        ],
      ),
    );
  }
}
