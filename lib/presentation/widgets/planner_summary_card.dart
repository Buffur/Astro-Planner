import 'package:flutter/material.dart';
import '../shared/section_header.dart';
import '../shared/info_row.dart';

class PlannerSummaryCard extends StatelessWidget {
  final String title;
  final Map<String, String> data;
  final VoidCallback? onTap;

  const PlannerSummaryCard({super.key, required this.title, required this.data, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SectionHeader(title: title),
              const SizedBox(height: 12),
              ...data.entries.map((entry) => Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: InfoRow(label: entry.key, value: entry.value),
              )),
            ],
          ),
        ),
      ),
    );
  }
}
