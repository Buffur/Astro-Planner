import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:url_launcher/url_launcher.dart';

import '../../../core/config/app_identity.dart';

/// Data sources, attribution and licences (TASK 8.2). The target catalog is
/// an adapted subset of OpenNGC (CC BY-SA 4.0), whose notice is shown in
/// full; the other external data the app uses is credited too. Since TASK
/// 16.3 also the app's licence (GPL-3.0) with its source, and privacy.
class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key, this.loadNotice});

  static const String noticeAsset = 'assets/catalog/OPENNGC_NOTICE.txt';

  /// Loads the OpenNGC notice; defaults to the bundled asset.
  final Future<String> Function()? loadNotice;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('About & data sources')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('Target catalog', style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),
          FutureBuilder<String>(
            future: (loadNotice ?? () => rootBundle.loadString(noticeAsset))(),
            // TASK 15.3: selectable text is a long-press target (48 px).
            builder: (context, snapshot) => ConstrainedBox(
              constraints: const BoxConstraints(minHeight: 48),
              child: SelectableText(
                snapshot.data ??
                    (snapshot.hasError
                        ? 'Target catalog: adapted from OpenNGC by Mattia '
                              'Verga, CC BY-SA 4.0.'
                        : ''),
                style: theme.textTheme.bodySmall,
              ),
            ),
          ),
          const Divider(height: 32),
          Text('Other data', style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),
          const Text(
            'Map tiles and place names: © OpenStreetMap contributors '
            '(openstreetmap.org/copyright), via the OpenStreetMap tile '
            'servers and Nominatim.',
          ),
          const SizedBox(height: 8),
          const Text(
            'Weather data by Open-Meteo.com (open-meteo.com), CC BY 4.0. '
            'The model used is shown with each forecast.',
          ),
          const SizedBox(height: 8),
          const Text(
            'Light-pollution map: lightpollutionmap.app (opened in your '
            'browser; nothing is fetched by the app).',
          ),
          const Divider(height: 32),
          Text('Privacy', style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),
          const Text(
            'No account, no ads, no analytics and no tracking. Your sites, '
            'rigs, plans and sessions stay on this device. The app sends a '
            'position only to fetch the weather (Open-Meteo), to show map '
            'tiles (OpenStreetMap) and — if you switch it on in Settings — '
            'to look up a place name (Nominatim). Location permission is '
            'asked only when you choose "use current position".',
            key: Key('about.privacy'),
          ),
          _LinkButton(
            key: const Key('about.privacyPolicy'),
            label: 'Privacy policy',
            url: AppIdentity.privacyPolicyUrl,
          ),
          const Divider(height: 32),
          Text('Licence', style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),
          Text(
            '${AppIdentity.appName} ${AppIdentity.version} is free software '
            'under the GNU General Public License v3.0 (GPL-3.0). You may '
            'use, study, share and change it under that licence.',
            key: const Key('about.licence'),
          ),
          _LinkButton(
            key: const Key('about.source'),
            label: 'Source code',
            url: AppIdentity.sourceUrl,
          ),
          const SizedBox(height: 24),
          OutlinedButton(
            onPressed: () => showLicensePage(
              context: context,
              applicationName: AppIdentity.appName,
            ),
            child: const Text('Open-source licences'),
          ),
        ],
      ),
    );
  }
}

/// Opens [url] in the browser (TASK 16.3).
class _LinkButton extends StatelessWidget {
  const _LinkButton({super.key, required this.label, required this.url});

  final String label;
  final String url;

  @override
  Widget build(BuildContext context) => Align(
    alignment: Alignment.centerLeft,
    child: TextButton.icon(
      onPressed: () =>
          launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication),
      icon: const Icon(Icons.open_in_new),
      label: Text(label),
    ),
  );
}
