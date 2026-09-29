import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../domain/models/location_profile.dart';
import '../../shared/app_words.dart';
import '../../shared/confirmation_patterns.dart';
import '../../shared/delete_patterns.dart';
import '../../shared/list_mode.dart';
import '../../shared/location_feedback.dart';
import '../../viewmodels/site_viewmodel.dart';
import '../../shared/failure_feedback.dart';
import 'site_editor_screen.dart';
import '../../navigation/app_router.dart';
import '../../../core/theme/app_spacing.dart';

/// Saved sites and the current position (TASK 7.3): create, edit and delete
/// sites; use the device position or a map pick as a transient position,
/// and save it as a site. Since S9.1 (D9-1) the Library **manages** them (a
/// tap opens the site) and the active site is chosen only from
/// `/select/site` (a tap makes it active). Deleting confirms (RD-09).
class SitesScreen extends StatelessWidget {
  const SitesScreen({super.key, this.mode = ListMode.choose});

  final ListMode mode;

  static String _coordinates(double lat, double lon) =>
      '${lat.toStringAsFixed(4)}, ${lon.toStringAsFixed(4)}';

  Future<void> _confirmDelete(
    BuildContext context,
    SiteViewModel viewModel,
    LocationProfile site,
  ) async {
    final active = viewModel.activeSite?.id == site.id;
    final confirmed = await confirmDestructive(
      context,
      title: 'Delete this site?',
      message: active
          ? '"${site.name}" is the active site. Its position stays as your '
                'current position, but its time zone and sky data no longer '
                "apply. Saved plans keep what they recorded. This can't be "
                'undone.'
          : '"${site.name}" is deleted from your sites. Saved plans keep what '
                "they recorded. This can't be undone.",
    );
    if (!confirmed || !context.mounted) return;
    final deleted = await runWithFeedback(
      context,
      'delete the site',
      () => viewModel.deleteSite(site.id),
    );
    if (deleted && context.mounted) showDone(context, 'Site deleted');
  }

  void _open(BuildContext context, LocationProfile site) =>
      context.push(AppRouter.siteEdit, extra: SiteEditorArgs(site: site));

  @override
  Widget build(BuildContext context) {
    final siteVm = context.watch<SiteViewModel>();
    final activeId = siteVm.activeSite?.id;
    final hasTransient = siteVm.activeSite == null && !siteVm.isDefaultLocation;
    final sites = siteVm.sites;

    final choosing = mode == ListMode.choose;
    return Scaffold(
      appBar: AppBar(
        title: Text(choosing ? AppWords.chooseSite : AppWords.sites),
      ),
      body: ListView(
        padding: const EdgeInsets.only(
          bottom: AppSpacing.xxl + AppSpacing.xl + AppSpacing.sm,
        ),
        children: [
          if (hasTransient)
            Card(
              margin: const EdgeInsets.all(AppSpacing.md),
              child: ListTile(
                leading: const Icon(Icons.my_location),
                title: Text(siteVm.locationName ?? 'Current position'),
                subtitle: Text(
                  '${_coordinates(siteVm.latitude, siteVm.longitude)}'
                  ' · not saved',
                ),
                trailing: TextButton(
                  onPressed: () => context.push(
                    AppRouter.siteEdit,
                    extra: SiteEditorArgs(
                      latitude: siteVm.latitude,
                      longitude: siteVm.longitude,
                      name: siteVm.locationName,
                    ),
                  ),
                  child: const Text('Save as site'),
                ),
              ),
            )
          else if (siteVm.isDefaultLocation)
            const Padding(
              padding: EdgeInsets.fromLTRB(
                AppSpacing.md,
                AppSpacing.md,
                AppSpacing.md,
                0,
              ),
              child: Text(
                'No site yet. Use your current position, pick a point on the '
                'map, or add a site.',
              ),
            ),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm,
            ),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                OutlinedButton.icon(
                  onPressed: () =>
                      useCurrentPositionWithFeedback(context, siteVm),
                  icon: const Icon(Icons.my_location),
                  label: const Text('Use current position'),
                ),
                OutlinedButton.icon(
                  onPressed: () => context.push(AppRouter.position),
                  icon: const Icon(Icons.map_outlined),
                  label: const Text('Pick on map'),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.md,
              AppSpacing.md,
              AppSpacing.md,
              AppSpacing.xs,
            ),
            child: Semantics(
              header: true,
              child: Text(
                'Saved sites',
                style: Theme.of(context).textTheme.titleSmall,
              ),
            ),
          ),
          if (sites.isEmpty)
            const Padding(
              padding: EdgeInsets.all(AppSpacing.md),
              child: Text('No saved sites yet.'),
            ),
          for (final site in sites)
            SwipeToDelete(
              itemKey: ValueKey('site-swipe-${site.id}'),
              onDelete: () => _confirmDelete(context, siteVm, site),
              child: ListTile(
                key: ValueKey('site-${site.id}'),
                leading: Icon(
                  site.id == activeId
                      ? Icons.radio_button_checked
                      : Icons.radio_button_unchecked,
                  semanticLabel: site.id == activeId ? 'Active site' : null,
                ),
                title: Text(site.name),
                subtitle: Text(
                  '${_coordinates(site.latitude, site.longitude)} · '
                  '${site.timeZoneId ?? 'zone unknown'}',
                ),
                selected: site.id == activeId,
                onTap: choosing
                    ? () => runWithFeedback(
                        context,
                        'select the site',
                        () => siteVm.selectSite(site.id),
                      )
                    : () => _open(context, site),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (choosing)
                      IconButton(
                        icon: const Icon(Icons.edit_outlined),
                        tooltip: 'Edit site',
                        onPressed: () => _open(context, site),
                      ),
                    DeleteButton(
                      tooltip: 'Delete site',
                      onPressed: () => _confirmDelete(context, siteVm, site),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push(
          AppRouter.siteEdit,
          extra: siteVm.isDefaultLocation
              ? const SiteEditorArgs()
              : SiteEditorArgs(
                  latitude: siteVm.latitude,
                  longitude: siteVm.longitude,
                ),
        ),
        icon: const Icon(Icons.add_location_alt_outlined),
        label: const Text('Add site'),
      ),
    );
  }
}
