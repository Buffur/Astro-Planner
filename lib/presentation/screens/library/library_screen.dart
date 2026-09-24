import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../navigation/app_router.dart';
import '../../viewmodels/site_viewmodel.dart';
import '../../viewmodels/session_plan_viewmodel.dart';

/// The Library tab (ADR-015): rigs, targets and sites.
class LibraryScreen extends StatelessWidget {
  const LibraryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final planVm = context.watch<SessionPlanViewModel>();
    final siteVm = context.watch<SiteViewModel>();
    final site = siteVm.activeSite?.name;
    return Scaffold(
      appBar: AppBar(title: const Text('Library')),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.camera_alt_outlined),
            title: const Text('Rigs'),
            subtitle: Text(planVm.selectedEquipment?.name ?? 'None selected'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push(AppRouter.libraryRigs),
          ),
          ListTile(
            leading: const Icon(Icons.auto_awesome_outlined),
            title: const Text('Targets'),
            subtitle: Text(
              planVm.selectedTarget == null
                  ? 'None selected'
                  : planVm.selectedTarget!.commonName ??
                        planVm.selectedTarget!.catalogId,
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push(AppRouter.libraryTargets),
          ),
          ListTile(
            leading: const Icon(Icons.place_outlined),
            title: const Text('Sites'),
            subtitle: Text(
              site == null
                  ? '${siteVm.sites.length} saved · no active site'
                  : '${siteVm.sites.length} saved · active: $site',
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push(AppRouter.librarySites),
          ),
        ],
      ),
    );
  }
}
