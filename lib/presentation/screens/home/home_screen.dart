import 'package:flutter/material.dart';
import '../../../core/theme/app_spacing.dart';
import '../../shared/info_row.dart';
import '../../shared/section_header.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AstroPlan / Setup'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.md),
        children: [
          const Text(
            'Phase 3: Design System',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: AppSpacing.md),
          const Text(
            'This screen demonstrates the minimalist, Notion-inspired design system components.',
          ),
          SectionHeader(
            title: 'Equipment Profile',
            actionLabel: 'Edit',
            onAction: () {},
          ),
          const Card(
            child: Padding(
              padding: EdgeInsets.all(AppSpacing.md),
              child: Column(
                children: [
                  InfoRow(label: 'Camera', value: 'ZWO ASI2600MC Pro'),
                  Divider(),
                  InfoRow(label: 'Telescope', value: 'Askar FRA400'),
                  Divider(),
                  InfoRow(label: 'Mount', value: 'ZWO AM5'),
                ],
              ),
            ),
          ),
          const SectionHeader(
            title: 'Current Target',
          ),
          const Card(
            child: Padding(
              padding: EdgeInsets.all(AppSpacing.md),
              child: Column(
                children: [
                  InfoRow(label: 'Target Name', value: 'Orion Nebula (M42)'),
                  Divider(),
                  InfoRow(label: 'Right Ascension', value: '05h 35m 17s'),
                  Divider(),
                  InfoRow(label: 'Declination', value: '-05° 23\' 28"'),
                  Divider(),
                  InfoRow(label: 'Transit', value: '01:45 AM'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
