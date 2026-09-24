import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../domain/models/location_profile.dart';
import '../../shared/location_feedback.dart';
import '../../viewmodels/site_viewmodel.dart';
import '../../shared/failure_feedback.dart';
import 'site_editor_screen.dart';
import '../../navigation/app_router.dart';

/// Saved sites and the current position (TASK 7.3): select, create, edit
/// and delete sites; use the device position or a map pick as a transient
/// position, and save it as a site.
class SitesScreen extends StatelessWidget {
  const SitesScreen({super.key});

  static String _coordinates(double lat, double lon) =>
      '${lat.toStringAsFixed(4)}, ${lon.toStringAsFixed(4)}';

  Future<void> _confirmDelete(
    BuildContext context,
    SiteViewModel viewModel,
    LocationProfile site,
  ) async {
    final active = viewModel.activeSite?.id == site.id;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Delete ${site.name}?'),
        content: Text(
          active
              ? 'This is the active site. Its position stays as your current '
                    'position, but its time zone and sky data no longer apply.'
              : 'This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed == true && context.mounted) {
      await runWithFeedback(
        context,
        'delete the site',
        () => viewModel.deleteSite(site.id),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final siteVm = context.watch<SiteViewModel>();
    final activeId = siteVm.activeSite?.id;
    final hasTransient = siteVm.activeSite == null && !siteVm.isDefaultLocation;
    final sites = siteVm.sites;

    return Scaffold(
      appBar: AppBar(title: const Text('Sites')),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 88),
        children: [
          if (hasTransient)
            Card(
              margin: const EdgeInsets.all(12),
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
              padding: EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: Text(
                'No site yet. Use your current position, pick a point on the '
                'map, or add a site.',
              ),
            ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 16, 16, 4),
            child: Text(
              'Saved sites',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          if (sites.isEmpty)
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text('No saved sites yet.'),
            ),
          for (final site in sites)
            ListTile(
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
              onTap: () => runWithFeedback(
                context,
                'select the site',
                () => siteVm.selectSite(site.id),
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit_outlined),
                    tooltip: 'Edit site',
                    onPressed: () => context.push(
                      AppRouter.siteEdit,
                      extra: SiteEditorArgs(site: site),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline),
                    tooltip: 'Delete site',
                    onPressed: () => _confirmDelete(context, siteVm, site),
                  ),
                ],
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
