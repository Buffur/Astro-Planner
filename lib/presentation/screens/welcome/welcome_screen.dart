import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../navigation/app_router.dart';
import '../../shared/failure_feedback.dart';
import '../../shared/location_feedback.dart';
import '../../viewmodels/session_plan_viewmodel.dart';
import '../../viewmodels/site_viewmodel.dart';
import '../../viewmodels/tonight_viewmodel.dart';
import '../../../core/config/app_identity.dart';

/// The first-run setup (TASK 12.5, owner decisions): site, rig and target,
/// each skippable, on one page above the tabs. The steps reuse the normal
/// pickers; Skip, Done and back all close it for good.
class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  static Future<void> _close(BuildContext context) async {
    // TASK 15.4: if it cannot be stored the page is offered again at the
    // next start; say so, and still close it now.
    await runWithFeedback(
      context,
      'remember that the setup is done',
      context.read<TonightViewModel>().finishFirstRun,
    );
    if (context.mounted) context.go(AppRouter.tonight);
  }

  @override
  Widget build(BuildContext context) {
    final siteVm = context.watch<SiteViewModel>();
    final planVm = context.watch<SessionPlanViewModel>();
    final theme = Theme.of(context);
    final target = planVm.selectedTarget;
    final rig = planVm.selectedEquipment;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _close(context);
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Welcome to ${AppIdentity.appName}'),
          automaticallyImplyLeading: false,
          actions: [
            TextButton(
              key: const Key('welcome.skip'),
              onPressed: () => _close(context),
              child: const Text('Skip'),
            ),
          ],
        ),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(
              'Three quick steps to plan tonight. Each one can be skipped '
              'and changed later.',
              style: theme.textTheme.bodyLarge,
            ),
            const SizedBox(height: 16),
            _Step(
              key: const Key('welcome.site'),
              number: 1,
              title: 'Your observing site',
              status: siteVm.isDefaultLocation
                  ? 'Not set'
                  : siteVm.locationName ?? 'Current position',
              explanation:
                  'Night times, the Moon and target altitudes are computed '
                  'for your site. ${AppIdentity.appName} asks for location permission '
                  'only if you tap "Use current position", and uses your '
                  'position on this device to compute the night. You can '
                  'enter a site by hand instead.',
              actions: [
                FilledButton.icon(
                  key: const Key('welcome.useCurrentPosition'),
                  onPressed: () =>
                      useCurrentPositionWithFeedback(context, siteVm),
                  icon: const Icon(Icons.my_location),
                  label: const Text('Use current position'),
                ),
                OutlinedButton.icon(
                  key: const Key('welcome.chooseSite'),
                  onPressed: () => context.push(AppRouter.selectSite),
                  icon: const Icon(Icons.place_outlined),
                  label: const Text('Choose or add a site'),
                ),
              ],
            ),
            _Step(
              key: const Key('welcome.rig'),
              number: 2,
              title: 'Your rig',
              status: rig?.name ?? 'Not chosen',
              explanation:
                  'Telescope or lens and camera: they set the field of view, '
                  'the pixel scale and the exposure guidance.',
              actions: [
                OutlinedButton.icon(
                  key: const Key('welcome.chooseRig'),
                  onPressed: () => context.push(AppRouter.selectRig),
                  icon: const Icon(Icons.camera_alt_outlined),
                  label: const Text('Choose a rig'),
                ),
              ],
            ),
            _Step(
              key: const Key('welcome.target'),
              number: 3,
              title: 'A target',
              status: target == null
                  ? 'Not chosen'
                  : target.commonName ?? target.catalogId,
              explanation:
                  'What you want to photograph. "What can I image tonight?" '
                  'on the Tonight tab suggests targets for your site.',
              actions: [
                OutlinedButton.icon(
                  key: const Key('welcome.chooseTarget'),
                  onPressed: () => context.push(AppRouter.selectTarget),
                  icon: const Icon(Icons.auto_awesome_outlined),
                  label: const Text('Choose a target'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            FilledButton(
              key: const Key('welcome.done'),
              onPressed: () => _close(context),
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(48),
              ),
              child: const Text('Done'),
            ),
          ],
        ),
      ),
    );
  }
}

class _Step extends StatelessWidget {
  const _Step({
    super.key,
    required this.number,
    required this.title,
    required this.status,
    required this.explanation,
    required this.actions,
  });

  final int number;
  final String title;
  final String status;
  final String explanation;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('$number. $title', style: theme.textTheme.titleMedium),
            Text(status, style: theme.textTheme.labelLarge),
            const SizedBox(height: 8),
            Text(explanation, style: theme.textTheme.bodyMedium),
            const SizedBox(height: 12),
            Wrap(spacing: 8, runSpacing: 8, children: actions),
          ],
        ),
      ),
    );
  }
}
