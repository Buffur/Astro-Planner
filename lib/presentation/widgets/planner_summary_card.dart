import 'package:flutter/material.dart';

import '../shared/section_header.dart';
import '../shared/info_row.dart';

class PlannerSummaryCard extends StatelessWidget {
  final String title;
  final Map<String, String> data;
  final VoidCallback? onTap;

  /// Shown below the rows, outside the tappable area (S6.7: the rig's
  /// collapsible reference rows, which must not open the picker).
  final Widget? below;

  const PlannerSummaryCard({
    super.key,
    required this.title,
    required this.data,
    this.onTap,
    this.below,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      clipBehavior: below == null ? Clip.none : Clip.antiAlias,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SectionHeader(title: title),
                  const SizedBox(height: 12),
                  ...data.entries.map(
                    (entry) => Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: InfoRow(label: entry.key, value: entry.value),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (below != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: below,
            ),
        ],
      ),
    );
  }
}
