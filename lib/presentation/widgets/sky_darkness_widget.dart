import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../shared/twilight_bands.dart';
import '../viewmodels/site_viewmodel.dart';
import '../viewmodels/night_conditions_viewmodel.dart';
import '../shared/app_words.dart';
import '../shared/collapsible_section.dart';
import '../shared/light_pollution_map_link.dart';
import 'planner_sections.dart';
import '../shared/night_time_formatter.dart';
import '../../core/theme/app_palette.dart';
import '../../../core/config/feature_scope.dart';
import '../../../domain/models/calendar_date.dart';
import '../../../domain/models/moon_conditions.dart';
import '../../../domain/models/night_timeline.dart';
import '../../../domain/models/sky_darkness.dart';
import '../../core/utils/quantity_text.dart';

/// The site's sky darkness in the planner (TASK 7.4): Bortle and SQM as
/// entered, with their sources, or unknown. Since S6.5 the night's timeline
/// and the Moon are on the Night & Moon detail ([NightTimelineSection],
/// [MoonSection]); the planner shows a summary row for them. Since S6.7
/// (ADR-019 §7) the Bortle picker, the sources and the light-pollution map
/// link are one tap away; the summary states the values, or "Unknown".
class SkyDarknessWidget extends StatelessWidget {
  const SkyDarknessWidget({super.key});

  /// The collapsed summary, a fact: "Bortle 4 · SQM 21.30 mag/arcsec²",
  /// "Unknown", and "not saved" for a transient position's value.
  static String summary(SkyDarkness darkness) {
    if (darkness.isUnknown) return 'Unknown';
    return [
      if (darkness.hasBortle) 'Bortle ${darkness.bortleClass}',
      if (darkness.hasSqm)
        'SQM ${darkness.sqm!.toStringAsFixed(2)} mag/arcsec²',
      if (!darkness.isSaved) 'not saved',
    ].join(' · ');
  }

  @override
  Widget build(BuildContext context) {
    final siteVm = context.watch<SiteViewModel>();

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: CollapsibleSection(
          sectionKey: PlannerSections.sky,
          title: 'Sky darkness',
          summary: FeatureScope.lightPollutionContext
              ? summary(siteVm.skyDarkness)
              : null,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (FeatureScope.lightPollutionContext) ...[
                _BortleBadge(
                  bortleClass: siteVm.bortleClass,
                  onChanged: siteVm.setBortleClass,
                ),
                _SkyDarknessLine(
                  darkness: siteVm.skyDarkness,
                  hasSite: siteVm.activeSite != null,
                ),
                // TASK 7.4 (PD-05 option A): the external map, centred on
                // the current position. Hidden without one — the London
                // default is not the user's sky.
                if (!siteVm.isDefaultLocation)
                  _MapLink(lat: siteVm.latitude, lon: siteVm.longitude),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Opens the light-pollution map at the site (TASK 7.4), to read a value
/// and enter it as Bortle or SQM. Since S9.7 it names the external site and
/// what to do there, in the text roles.
class _MapLink extends StatelessWidget {
  const _MapLink({required this.lat, required this.lon});

  final double lat;
  final double lon;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return InkWell(
      key: const Key('sky.mapLink'),
      onTap: () async {
        final url = LightPollutionMapLink.at(lat, lon);
        if (await canLaunchUrl(url)) {
          await launchUrl(url, mode: LaunchMode.externalApplication);
        }
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            const Icon(Icons.map_outlined),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Look it up on lightpollutionmap.app',
                    style: text.titleSmall,
                  ),
                  Text(
                    'An external map, opened in your browser at this '
                    'position. Read the value there, then enter it as '
                    'Bortle or SQM.',
                    style: text.bodySmall,
                  ),
                ],
              ),
            ),
            const Icon(Icons.open_in_browser),
          ],
        ),
      ),
    );
  }
}

/// The known sky darkness, value first, then its source and the date it
/// was recorded; or an explicit "unknown" with the way to set it (TASK 7.4;
/// SI-007, SI-008; S9.7). Bortle and SQM are shown as entered — never
/// converted into each other (trap 6), and never inferred.
class _SkyDarknessLine extends StatelessWidget {
  const _SkyDarknessLine({required this.darkness, required this.hasSite});

  final SkyDarkness darkness;
  final bool hasSite;

  /// "Source: user · Nov 10, 2026", or "Source unknown".
  static String source(String? source, CalendarDate? date) {
    if (source == null) return 'Source unknown';
    return date == null
        ? 'Source: $source'
        : 'Source: $source · ${NightTimeFormatter.recordedDate(date)}';
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    if (darkness.isUnknown) {
      return Padding(
        padding: const EdgeInsets.only(top: 8),
        child: Text(
          hasSite
              ? 'Unknown — pick a Bortle class above, or add Bortle or SQM in '
                    'the site editor.'
              : 'Unknown — pick a Bortle class above; save this position as a '
                    'site to keep it or to record SQM.',
          key: const Key('sky.unknown'),
          style: text.bodySmall,
        ),
      );
    }
    Widget reading(String value, String caption, Key key) => Padding(
      key: key,
      padding: const EdgeInsets.only(top: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(value, style: text.bodyMedium),
          Text(caption, style: text.bodySmall),
        ],
      ),
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (darkness.hasBortle)
          reading(
            'Bortle ${darkness.bortleClass}',
            source(darkness.bortleSource, darkness.bortleDate),
            const Key('sky.bortle'),
          ),
        if (darkness.hasSqm)
          reading(
            'SQM ${darkness.sqm!.toStringAsFixed(2)} mag/arcsec²',
            source(darkness.sqmSource, darkness.sqmDate),
            const Key('sky.sqm'),
          ),
        if (!darkness.isSaved)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              'Not saved: this position is not a site.',
              style: text.bodySmall,
            ),
          ),
      ],
    );
  }
}

/// The Bortle picker (TASK 7.4). Since S6.7 the class's conventional colour
/// is a swatch beside the text, which uses the text roles, so every class
/// reads at AA contrast; a 48 dp target (trap 17).
class _BortleBadge extends StatelessWidget {
  /// Null when unknown (SI-007, TASK 7.1).
  final int? bortleClass;
  final ValueChanged<int?> onChanged;

  const _BortleBadge({required this.bortleClass, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final palette = AppPalette.of(context);
    final text = Theme.of(context).textTheme;

    Widget swatch(int i) => Container(
      width: 16,
      height: 16,
      decoration: BoxDecoration(
        color: palette.bortle[i],
        shape: BoxShape.circle,
        border: Border.all(color: palette.swatchBorder),
      ),
    );

    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 48),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<int?>(
          value: bortleClass,
          dropdownColor: Theme.of(context).cardColor,
          icon: Icon(Icons.arrow_drop_down, color: palette.textSecondary),
          items: [
            DropdownMenuItem<int?>(
              value: null,
              child: Text(
                'Bortle unknown',
                style: TextStyle(color: text.bodyLarge?.color),
              ),
            ),
            ...List.generate(
              9,
              (index) => DropdownMenuItem<int?>(
                value: index + 1,
                child: Text(
                  'Bortle ${index + 1}',
                  style: TextStyle(color: text.bodyLarge?.color),
                ),
              ),
            ),
          ],
          onChanged: onChanged,
          selectedItemBuilder: (BuildContext context) {
            return List.generate(10, (i) {
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  swatch(i),
                  const SizedBox(width: 8),
                  Text(
                    i == 0 ? 'Bortle ?' : 'Bortle $i',
                    style: text.titleSmall?.copyWith(
                      color: palette.textPrimary,
                    ),
                  ),
                  const SizedBox(width: 4),
                ],
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
/// appear (ADR-019 §10). Times are in the zone the detail's header names
/// once. Since S6.16 (TD-078) the dark span at the user's darkness limit is
/// the detail's summary alone, not repeated here, and the section has its
/// own heading.
class NightTimelineSection extends StatelessWidget {
  const NightTimelineSection({super.key});

  static const title = 'Sun and twilight';

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
    final bands = TwilightBands.of(timeline);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _SectionTitle(title, key: const Key('night.timelineTitle')),
        // S9.6: the same crossings as a bar; the times below are its text.
        if (bands != null && bands.isNotEmpty) ...[
          TwilightBar(bands: bands),
          const SizedBox(height: 8),
        ],
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

/// The night from sunset to sunrise as the standard twilights (S9.6): each
/// band's width is its duration and its shade its depth, from the chart's
/// twilight to its dark token. Visual only: the table under it states the
/// same times, so the bar is hidden from screen readers.
class TwilightBar extends StatelessWidget {
  const TwilightBar({super.key, required this.bands});

  final List<TwilightBand> bands;

  @override
  Widget build(BuildContext context) {
    final p = AppPalette.of(context);
    return ExcludeSemantics(
      child: ClipRRect(
        key: const Key('night.twilightBar'),
        borderRadius: BorderRadius.circular(4),
        child: SizedBox(
          height: 16,
          child: Row(
            children: [
              for (final (i, b) in bands.indexed)
                Expanded(
                  key: Key('night.band.$i.${b.depth}'),
                  flex: b.length.inMinutes.clamp(1, 1 << 20),
                  child: ColoredBox(
                    color: Color.lerp(
                      p.chartTwilight,
                      p.chartDark,
                      (b.depth - 1) / 3,
                    )!,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// The Moon for the Night & Moon detail (TASK 6.4; moved here in S6.5):
/// its illumination at midnight and how close it comes to the target —
/// annotations only, never an "impact %" (ADR-010). Since S6.16 (TD-078)
/// when it is up is the detail's summary alone, and the section has its own
/// heading.
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
            Icon(Icons.nightlight_round, color: AppPalette.of(context).moon),
            const SizedBox(width: 8),
            const Expanded(child: _SectionTitle('Moon')),
          ],
        ),
        Padding(
          padding: const EdgeInsets.only(left: 32),
          child: Text(
            'Illumination at midnight: $lunarIllum',
            key: const Key('sky.moonIllumination'),
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
        _MoonDetails(conditions: conditionsVm.moonConditions, zoneId: zoneId),
      ],
    );
  }
}

/// A detail section's heading (S6.16, TD-078): the scale's group-heading
/// role, a semantic header, so each section reads apart from the summary.
class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 8),
    child: Semantics(
      header: true,
      child: Text(
        text,
        style: Theme.of(context).textTheme.titleSmall
            ?.copyWith(color: AppPalette.of(context).textPrimary),
      ),
    ),
  );
}

/// How close the Moon comes to the target tonight (its up-times are the
/// detail's summary, S6.16).
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

    final hasTarget =
        c.samples.isNotEmpty && c.samples.first.separationDeg != null;
    final approach = c.closestApproachWhileBothUp;
    final String? sepText = !hasTarget
        ? null
        : approach == null
        ? 'The Moon and the target are not up at the same time tonight.'
        : 'Closest to the target while both are up: '
              '${approach.separationDeg.round()}° at ${at(approach.instantUtc)}.';

    if (sepText == null) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(left: 32, top: 4),
      child: Text(sepText, key: const Key('sky.moonSeparation'), style: style),
    );
  }
}
