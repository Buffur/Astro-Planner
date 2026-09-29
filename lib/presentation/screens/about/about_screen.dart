import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:url_launcher/url_launcher.dart';

import '../../../core/config/app_identity.dart';
import '../../../core/theme/app_spacing.dart';

/// About: the author, the data sources and their attribution, privacy and
/// the licence (TASK 8.2, TASK 16.3; S9.5, 08 §23, D9-4). The author comes
/// first and apart from third-party credit; every source is a link, worded
/// as its terms ask (`docs/COMPLIANCE.md`). The target catalog is an adapted
/// subset of OpenNGC (CC BY-SA 4.0), whose notice is shown in full. The
/// source-code, project and policy links stay as they are until RD-01.
class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key, this.loadNotice});

  static const String noticeAsset = 'assets/catalog/OPENNGC_NOTICE.txt';

  /// The author's public handle and profiles (the owner's, 08 §23).
  static const String author = 'Buffur';
  static const String authorReddit = 'https://www.reddit.com/user/Buffur/';
  static const String authorGitHub = 'https://github.com/Buffur';

  /// Loads the OpenNGC notice; defaults to the bundled asset.
  final Future<String> Function()? loadNotice;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final heading = theme.textTheme.titleMedium;
    const gap = SizedBox(height: AppSpacing.sm);
    const divider = Divider(height: AppSpacing.xl);
    return Scaffold(
      appBar: AppBar(title: const Text('About & data sources')),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.md),
        children: [
          // S9.5 (08 §23): the author, prominent and first.
          Card(
            key: const Key('about.author'),
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppIdentity.appName,
                    style: theme.textTheme.headlineSmall,
                  ),
                  Text(
                    'Version ${AppIdentity.version}',
                    key: const Key('about.version'),
                    style: theme.textTheme.bodySmall,
                  ),
                  gap,
                  Text('Made by $author', style: theme.textTheme.titleMedium),
                  gap,
                  Wrap(
                    spacing: AppSpacing.sm,
                    runSpacing: AppSpacing.sm,
                    children: [
                      FilledButton.icon(
                        key: const Key('about.reddit'),
                        onPressed: () => _open(authorReddit),
                        icon: const Icon(Icons.forum_outlined),
                        label: const Text('Reddit: u/$author'),
                      ),
                      OutlinedButton.icon(
                        key: const Key('about.github'),
                        onPressed: () => _open(authorGitHub),
                        icon: const Icon(Icons.code),
                        label: const Text('GitHub: $author'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          divider,
          Text('Data sources', style: heading),
          gap,
          Text('Target catalog', style: theme.textTheme.titleSmall),
          gap,
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
          const _Source(
            key: Key('about.openngc'),
            text: 'OpenNGC, by Mattia Verga, CC BY-SA 4.0.',
            label: 'OpenNGC on GitHub',
            url: 'https://github.com/mattiaverga/OpenNGC',
          ),
          const _Source(
            key: Key('about.osm'),
            text:
                'Map tiles and place names: © OpenStreetMap contributors, via '
                'the OpenStreetMap tile servers and Nominatim.',
            label: 'openstreetmap.org/copyright',
            url: 'https://www.openstreetmap.org/copyright',
          ),
          const _Source(
            key: Key('about.openMeteo'),
            text:
                'Weather data by Open-Meteo.com (CC BY 4.0). The model used is '
                'shown with each forecast.',
            label: 'open-meteo.com',
            url: 'https://open-meteo.com/',
          ),
          const _Source(
            key: Key('about.lightPollution'),
            text:
                'Light-pollution map: lightpollutionmap.app, opened in your '
                'browser; nothing is fetched by the app.',
            label: 'lightpollutionmap.app',
            url: 'https://lightpollutionmap.app/',
          ),
          divider,
          Text('Privacy', style: heading),
          gap,
          const Text(
            'No account, no ads, no analytics and no tracking. Your sites, '
            'rigs, plans and sessions stay on this device. The app sends a '
            'position only to fetch the weather (Open-Meteo), to show map '
            'tiles (OpenStreetMap) and — if you switch it on in Settings — '
            'to look up a place name (Nominatim). Location permission is '
            'asked only when you choose "use current position".',
            key: Key('about.privacy'),
          ),
          const _LinkButton(
            key: Key('about.privacyPolicy'),
            label: 'Privacy policy',
            url: AppIdentity.privacyPolicyUrl,
          ),
          divider,
          Text('Licence', style: heading),
          gap,
          Text(
            '${AppIdentity.appName} ${AppIdentity.version} is free software '
            'under the GNU General Public License v3.0 (GPL-3.0). You may '
            'use, study, share and change it under that licence.',
            key: const Key('about.licence'),
          ),
          const _LinkButton(
            key: Key('about.source'),
            label: 'Source code',
            url: AppIdentity.sourceUrl,
          ),
          const SizedBox(height: AppSpacing.lg),
          OutlinedButton(
            onPressed: () => showLicensePage(
              context: context,
              applicationName: AppIdentity.appName,
              applicationVersion: AppIdentity.version,
            ),
            child: const Text('Open-source licences'),
          ),
        ],
      ),
    );
  }
}

Future<void> _open(String url) =>
    launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);

/// One data source: its credit, then its link (S9.5).
class _Source extends StatelessWidget {
  const _Source({
    super.key,
    required this.text,
    required this.label,
    required this.url,
  });

  final String text;
  final String label;
  final String url;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: AppSpacing.sm),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(text),
        _LinkButton(label: label, url: url),
      ],
    ),
  );
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
      onPressed: () => _open(url),
      icon: const Icon(Icons.open_in_new),
      label: Text(label),
    ),
  );
}
