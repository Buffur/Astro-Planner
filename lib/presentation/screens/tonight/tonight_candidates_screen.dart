import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../domain/services/candidate_evaluator.dart';
import '../../shared/failure_feedback.dart';
import '../../shared/night_time_formatter.dart';
import '../../shared/opportunity_text.dart';
import '../../viewmodels/site_viewmodel.dart';
import '../../viewmodels/settings_viewmodel.dart';
import '../../viewmodels/session_plan_viewmodel.dart';
import '../../viewmodels/night_conditions_viewmodel.dart';

/// "What can I image tonight?" (TASK 10.4): every target evaluated for the
/// chosen night with the same rules as Home's opportunity card, sorted by a
/// column the user picks. Measured facts only — no score, no
/// recommendation.
class TonightCandidatesScreen extends StatefulWidget {
  const TonightCandidatesScreen({super.key});

  @override
  State<TonightCandidatesScreen> createState() =>
      _TonightCandidatesScreenState();
}

class _TonightCandidatesScreenState extends State<TonightCandidatesScreen> {
  Future<List<TonightCandidate>?>? _rows;
  CandidateSort _sort = CandidateSort.usableTime;
  bool _withWindowOnly = true;
  bool _ownOnly = false;
  String? _type;

  static const _sortLabels = {
    CandidateSort.usableTime: 'Usable time',
    CandidateSort.windowStart: 'Window start',
    CandidateSort.maxAltitude: 'Max altitude',
    CandidateSort.moonSeparation: 'Moon separation',
    CandidateSort.frameFill: 'Frame fill',
    CandidateSort.name: 'Name',
  };

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    _rows = context.read<NightConditionsViewModel>().tonightCandidates();
  }

  @override
  Widget build(BuildContext context) {
    final planVm = context.watch<SessionPlanViewModel>();
    final settingsVm = context.watch<SettingsViewModel>();
    final siteVm = context.watch<SiteViewModel>();
    final night = planVm.sessionNight;
    return Scaffold(
      appBar: AppBar(
        title: const Text("Tonight's candidates"),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Re-evaluate',
            onPressed: () => setState(_load),
          ),
        ],
      ),
      body: night == null
          ? const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text(
                  'Set a site first: candidates are evaluated for a night '
                  'at a site.',
                  key: Key('tonight.noSite'),
                ),
              ),
            )
          : FutureBuilder<List<TonightCandidate>?>(
              future: _rows,
              builder: (context, snapshot) {
                if (snapshot.error case final error?) {
                  return LoadFailureView(
                    action: "evaluate tonight's targets",
                    error: error,
                  );
                }
                final all = snapshot.data;
                if (all == null) {
                  return const Center(child: CircularProgressIndicator());
                }
                return _buildList(context, planVm, siteVm, settingsVm, all);
              },
            ),
    );
  }

  Widget _buildList(
    BuildContext context,
    SessionPlanViewModel planVm,
    SiteViewModel siteVm,
    SettingsViewModel settingsVm,
    List<TonightCandidate> all,
  ) {
    final theme = Theme.of(context);
    final night = planVm.sessionNight!;
    final zoneId = siteVm.displayZoneId;
    final types = {for (final r in all) r.target.type}.toList()..sort();
    final rows = CandidateList.sort(
      CandidateList.filter(
        all,
        withWindowOnly: _withWindowOnly,
        type: _type,
        ownOnly: _ownOnly,
      ),
      _sort,
    );
    String at(DateTime t) => NightTimeFormatter.instant(
      context,
      t,
      windowStartUtc: night.startUtc,
      zoneId: zoneId,
    );
    final prefs = settingsVm.planningPreferences;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
          child: Text(
            'Night of ${NightTimeFormatter.eveningDate(night.eveningDate)}'
            '${siteVm.locationName == null ? '' : ' at ${siteVm.locationName}'} · '
            '${rows.length} of ${all.length} targets · sorted by '
            '${_sortLabels[_sort]!.toLowerCase()} (no score)',
            key: const Key('tonight.header'),
            style: theme.textTheme.bodySmall,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Wrap(
            spacing: 12,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              DropdownButton<CandidateSort>(
                key: const Key('tonight.sort'),
                value: _sort,
                items: [
                  for (final e in _sortLabels.entries)
                    DropdownMenuItem(value: e.key, child: Text(e.value)),
                ],
                onChanged: (v) => setState(() => _sort = v ?? _sort),
              ),
              DropdownButton<String?>(
                key: const Key('tonight.type'),
                value: _type,
                items: [
                  const DropdownMenuItem(value: null, child: Text('All types')),
                  for (final t in types)
                    DropdownMenuItem(value: t, child: Text(t)),
                ],
                onChanged: (v) => setState(() => _type = v),
              ),
              FilterChip(
                key: const Key('tonight.own'),
                label: const Text('My own targets'),
                selected: _ownOnly,
                onSelected: (v) => setState(() => _ownOnly = v),
              ),
              FilterChip(
                key: const Key('tonight.all'),
                label: const Text('Show targets without a window'),
                selected: !_withWindowOnly,
                onSelected: (v) => setState(() => _withWindowOnly = !v),
              ),
            ],
          ),
        ),
        const Divider(height: 1),
        Expanded(
          child: rows.isEmpty
              ? const Center(
                  child: Text(
                    'No target matches: none has an imaging window with '
                    'these filters.',
                    key: Key('tonight.empty'),
                  ),
                )
              : ListView.separated(
                  itemCount: rows.length,
                  separatorBuilder: (_, _) => const Divider(height: 1),
                  itemBuilder: (context, i) {
                    final r = rows[i];
                    final t = r.target;
                    final name =
                        t.commonName != null && t.commonName != t.catalogId
                        ? '${t.commonName} (${t.catalogId})'
                        : t.commonName ?? t.catalogId;
                    final reason = r.noWindowReason;
                    final details = reason != null
                        ? 'No window: ${OpportunityText.noWindowShort(reason, darknessLimitDeg: prefs.darknessLimit.degrees, minAltitudeDeg: prefs.minAltitudeDeg)}'
                        : [
                            '${at(r.firstWindowStartUtc!)} – ${at(r.lastWindowEndUtc!)}',
                            'max ${r.maxAltitudeDeg!.round()}°',
                            r.minMoonSeparationDeg == null
                                ? 'Moon down in the windows'
                                : 'Moon ≥ ${r.minMoonSeparationDeg!.round()}° away',
                            if (r.frameFillFraction != null)
                              'fills ${(r.frameFillFraction! * 100).round()} % of the frame',
                          ].join(' · ');
                    return ListTile(
                      key: Key('tonight.row.${t.id}'),
                      title: Text(name),
                      subtitle: Text('${t.type} · $details'),
                      trailing: Text(
                        OpportunityText.duration(r.usableTime),
                        style: theme.textTheme.titleSmall,
                      ),
                      onTap: () async {
                        await planVm.setTarget(t);
                        if (context.mounted) context.pop();
                      },
                    );
                  },
                ),
        ),
        Padding(
          padding: const EdgeInsets.all(8),
          child: Text(
            'Times in ${NightTimeFormatter.zoneCaption(night.startUtc, zoneId: zoneId)}. '
            'Tap a target to open its night on Home.',
            style: theme.textTheme.bodySmall,
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }
}
