import 'package:flutter/material.dart';

import '../../core/theme/app_palette.dart';
import '../../core/theme/app_spacing.dart';
import '../../domain/models/calendar_date.dart';
import 'app_words.dart';
import 'night_time_formatter.dart';

/// "Ljubljana ▾ · Fri, Nov 14 ▾" (S5.6; ADR-019 §5, §6; addendum §3.1–§3.2):
/// the one control that says which site and night a screen describes, for
/// Tonight and the planner. Each part is its own 48 dp target that reports
/// a tap; what choosing does (the site picker, or changing the plan's
/// night, UX-11) is the adopting screen's (P6.3, P6.6).
///
/// Below it, once, the zone rule (trap 2): times are in the site's zone, or
/// labelled as the device zone when the site has none. Without a site there
/// is no night (ADR-007 §9), so only the site part shows.
///
/// S6.16: [framed] sets it on a card, so the site and night read as one
/// deliberate context area (Tonight and the planner); each part leads with
/// its icon (a place, a date).
class ContextLine extends StatelessWidget {
  const ContextLine({
    super.key,
    required this.siteName,
    required this.night,
    required this.onSite,
    required this.onNight,
    this.zoneId,
    this.nightStartUtc,
    this.framed = false,
  });

  /// Null when no site is set.
  final String? siteName;

  /// The night's evening date; null without a site.
  final CalendarDate? night;

  final VoidCallback onSite;
  final VoidCallback onNight;

  /// The site's IANA zone, if it has one.
  final String? zoneId;

  /// When the night starts, for the zone caption's offset; no caption
  /// without it.
  final DateTime? nightStartUtc;

  /// On a card (S6.16).
  final bool framed;

  /// Shown instead of a site name when none is set.
  static const noSite = 'No site set';

  /// "Times in site zone Europe/Ljubljana, CET, UTC+01:00", or the device
  /// zone's caption when the site has no zone. Pure formatting.
  static String zoneRule(DateTime nightStartUtc, {String? zoneId}) =>
      'Times in ${NightTimeFormatter.zoneCaption(nightStartUtc, zoneId: zoneId)}';

  @override
  Widget build(BuildContext context) {
    final p = AppPalette.of(context);
    final text = Theme.of(context).textTheme;
    final nightText = night == null
        ? null
        : NightTimeFormatter.eveningDate(night!);
    final line = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            _Choice(
              key: const Key('context.site'),
              icon: Icons.place_outlined,
              text: siteName ?? noSite,
              semanticsLabel: '${AppWords.site}: ${siteName ?? noSite}',
              hint: 'Choose a site',
              onTap: onSite,
            ),
            if (nightText != null) ...[
              ExcludeSemantics(
                child: Text(
                  ' · ',
                  style: text.titleSmall?.copyWith(color: p.textTertiary),
                ),
              ),
              _Choice(
                key: const Key('context.night'),
                icon: Icons.event_outlined,
                text: nightText,
                semanticsLabel: '${AppWords.night}: $nightText',
                hint: 'Choose a night',
                onTap: onNight,
              ),
            ],
          ],
        ),
        if (night != null && nightStartUtc != null)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
            child: Text(
              zoneRule(nightStartUtc!, zoneId: zoneId),
              key: const Key('context.zone'),
              style: text.bodySmall?.copyWith(color: p.textTertiary),
            ),
          ),
      ],
    );
    if (!framed) return line;
    return Card(
      key: const Key('context.card'),
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.sm,
          AppSpacing.xs,
          AppSpacing.md,
          AppSpacing.sm,
        ),
        child: line,
      ),
    );
  }
}

/// One part of the line: its value and a ▾, a 48 dp button.
class _Choice extends StatelessWidget {
  const _Choice({
    super.key,
    required this.icon,
    required this.text,
    required this.semanticsLabel,
    required this.hint,
    required this.onTap,
  });

  final IconData icon;
  final String text;
  final String semanticsLabel;
  final String hint;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final p = AppPalette.of(context);
    return Semantics(
      button: true,
      enabled: true,
      onTap: onTap,
      label: semanticsLabel,
      hint: hint,
      excludeSemantics: true,
      child: InkWell(
        onTap: onTap,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 48, minWidth: 48),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, color: p.textSecondary),
                const SizedBox(width: AppSpacing.xs),
                Flexible(
                  child: Text(
                    text,
                    style: Theme.of(context).textTheme.titleSmall
                        ?.copyWith(color: p.textPrimary),
                  ),
                ),
                Icon(Icons.arrow_drop_down, color: p.textSecondary),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// The shared night picker (S5.6): the date picker in the app's theme (red
/// in field mode), from a year ago to five years ahead as the planner's
/// picker allows, starting at [initial] (else [today]). Returns the chosen
/// evening, or null when cancelled.
Future<CalendarDate?> pickNight(
  BuildContext context, {
  CalendarDate? initial,
  DateTime? today,
}) async {
  final now = today ?? DateTime.now();
  final picked = await showDatePicker(
    context: context,
    initialDate: initial == null
        ? now
        : DateTime(initial.year, initial.month, initial.day),
    firstDate: DateTime(now.year - 1, now.month, now.day),
    lastDate: DateTime(now.year + 5, now.month, now.day),
    helpText: 'Choose a night',
  );
  return picked == null ? null : CalendarDate.fromDateTimeFields(picked);
}
