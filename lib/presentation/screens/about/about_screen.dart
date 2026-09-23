import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;

/// Data sources, attribution and licences (TASK 8.2). The target catalog is
/// an adapted subset of OpenNGC (CC BY-SA 4.0), whose notice is shown in
/// full; the other external data the app uses is credited too.
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
            builder: (context, snapshot) => SelectableText(
              snapshot.data ??
                  (snapshot.hasError
                      ? 'Target catalog: adapted from OpenNGC by Mattia '
                            'Verga, CC BY-SA 4.0.'
                      : ''),
              style: theme.textTheme.bodySmall,
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
          const Text('Weather: Open-Meteo (open-meteo.com).'),
          const SizedBox(height: 8),
          const Text(
            'Light-pollution map: lightpollutionmap.info (opened in your '
            'browser; nothing is fetched by the app).',
          ),
          const SizedBox(height: 24),
          OutlinedButton(
            onPressed: () =>
                showLicensePage(context: context, applicationName: 'AstroPlan'),
            child: const Text('Open-source licences'),
          ),
        ],
      ),
    );
  }
}
