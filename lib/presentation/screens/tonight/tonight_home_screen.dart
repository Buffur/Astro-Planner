import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../domain/models/session.dart';
import '../../navigation/app_router.dart';
import '../../shared/night_time_formatter.dart';
import '../../shared/opportunity_text.dart';
import '../../viewmodels/planner_viewmodel.dart';

/// The Tonight tab's root (ADR-015). **Interim (TASK 12.2):** the site, the
/// night, the current session and quick actions only; the full dashboard
/// (night window, Moon, weather age, fit) and the first-run flow are TASK
/// 12.5.
class TonightHomeScreen extends StatelessWidget {
  const TonightHomeScreen({super.key});

  static String _status(Session? s) => switch (s?.status) {
    null => 'Current plan',
    SessionStatus.draft =>
      s!.plannedAtUtc != null ? 'Planned, unsaved changes' : 'Draft',
    SessionStatus.planned => 'Planned',
    SessionStatus.inProgress => 'In progress',
    SessionStatus.completed => 'Completed',
    SessionStatus.abandoned => 'Abandoned',
  };

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<PlannerViewModel>();
    final theme = Theme.of(context);
    final evening = vm.eveningDate;
    final target = vm.selectedTarget;
    final rig = vm.selectedEquipment;

    Widget body;
    if (vm.hasBootstrapError) {
      body = Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("Couldn't load your data."),
            TextButton(
              onPressed: vm.retryBootstrap,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    } else if (vm.isLoading) {
      body = const Center(child: CircularProgressIndicator());
    } else {
      body = ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: ListTile(
              key: const Key('tonight.site'),
              leading: const Icon(Icons.place_outlined),
              title: Text(
                vm.isDefaultLocation
                    ? 'No site set'
                    : vm.locationName ?? 'Current position',
              ),
              subtitle: Text(
                evening == null
                    ? 'Set a site to see tonight.'
                    : 'Night of ${NightTimeFormatter.eveningDate(evening)}',
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => context.push(AppRouter.selectSite),
            ),
          ),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    _status(vm.activeSession),
                    key: const Key('tonight.sessionStatus'),
                    style: theme.textTheme.labelLarge,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    target == null
                        ? 'No target chosen'
                        : target.commonName ?? target.catalogId,
                    style: theme.textTheme.titleMedium,
                  ),
                  Text(rig?.name ?? 'No rig chosen'),
                  if (vm.imagingOpportunity case final o?)
                    Text(
                      'Usable time tonight: '
                      '${OpportunityText.duration(o.usableTime)}',
                    ),
                  const SizedBox(height: 12),
                  FilledButton.icon(
                    key: const Key('tonight.openPlanner'),
                    onPressed: () => context.push(AppRouter.session()),
                    icon: const Icon(Icons.edit_calendar_outlined),
                    label: const Text('Open planner'),
                    style: FilledButton.styleFrom(
                      minimumSize: const Size.fromHeight(48),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            key: const Key('tonight.candidates'),
            onPressed: () => context.push(AppRouter.candidates),
            icon: const Icon(Icons.format_list_numbered),
            label: const Text('What can I image tonight?'),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size.fromHeight(48),
            ),
          ),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            key: const Key('tonight.newSession'),
            onPressed: () async {
              await vm.newSession();
              if (context.mounted) context.push(AppRouter.session());
            },
            icon: const Icon(Icons.add),
            label: const Text('New session'),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size.fromHeight(48),
            ),
          ),
        ],
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Tonight')),
      body: body,
    );
  }
}
