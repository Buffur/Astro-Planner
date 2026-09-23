import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../navigation/app_router.dart';
import '../../viewmodels/planner_viewmodel.dart';

/// The Library tab (ADR-015): rigs, targets and sites.
class LibraryScreen extends StatelessWidget {
  const LibraryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<PlannerViewModel>();
    final site = vm.activeSite?.name;
    return Scaffold(
      appBar: AppBar(title: const Text('Library')),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.camera_alt_outlined),
            title: const Text('Rigs'),
            subtitle: Text(vm.selectedEquipment?.name ?? 'None selected'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push(AppRouter.libraryRigs),
          ),
          ListTile(
            leading: const Icon(Icons.auto_awesome_outlined),
            title: const Text('Targets'),
            subtitle: Text(
              vm.selectedTarget == null
                  ? 'None selected'
                  : vm.selectedTarget!.commonName ??
                        vm.selectedTarget!.catalogId,
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push(AppRouter.libraryTargets),
          ),
          ListTile(
            leading: const Icon(Icons.place_outlined),
            title: const Text('Sites'),
            subtitle: Text(
              site == null
                  ? '${vm.sites.length} saved · no active site'
                  : '${vm.sites.length} saved · active: $site',
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push(AppRouter.librarySites),
          ),
        ],
      ),
    );
  }
}
