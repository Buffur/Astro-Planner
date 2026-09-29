import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../navigation/app_router.dart';
import '../../shared/app_words.dart';
import '../../viewmodels/site_viewmodel.dart';

/// The Library tab (ADR-015): rigs, targets and sites, managed here (S9.1,
/// RD-07, D9-1): nothing here changes the plan, so the tiles describe the
/// Library, not the plan. Progress by target lives in the Logbook (S8.5).
class LibraryScreen extends StatelessWidget {
  const LibraryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final siteVm = context.watch<SiteViewModel>();
    final site = siteVm.activeSite?.name;
    return Scaffold(
      appBar: AppBar(title: const Text(AppWords.library)),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.camera_alt_outlined),
            title: const Text(AppWords.rigs),
            subtitle: const Text(
              'Your cameras with their lenses or telescopes',
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push(AppRouter.libraryRigs),
          ),
          ListTile(
            leading: const Icon(Icons.auto_awesome_outlined),
            title: const Text(AppWords.targets),
            subtitle: const Text('The catalog and the targets you added'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push(AppRouter.libraryTargets),
          ),
          ListTile(
            leading: const Icon(Icons.place_outlined),
            title: const Text(AppWords.sites),
            subtitle: Text(
              site == null
                  ? '${siteVm.sites.length} saved · no active site'
                  : '${siteVm.sites.length} saved · active: $site',
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push(AppRouter.librarySites),
          ),
          // Progress moved to the Logbook (S8.5; RD-07, ADR-019 §8).
        ],
      ),
    );
  }
}
