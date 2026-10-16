import 'package:flutter/material.dart';

import '../../../domain/models/iana_time_context.dart';

/// The user's choice in [showZonePicker]: an IANA zone id, or null for
/// "unknown".
typedef ZoneChoice = ({String? zoneId});

/// A searchable list of the IANA zones the bundled database knows, plus
/// "Unknown" (TASK 7.3). Returns null when dismissed.
Future<ZoneChoice?> showZonePicker(BuildContext context, {String? current}) {
  return showDialog<ZoneChoice>(
    context: context,
    builder: (_) => _ZonePickerDialog(current: current),
  );
}

class _ZonePickerDialog extends StatefulWidget {
  const _ZonePickerDialog({this.current});

  final String? current;

  @override
  State<_ZonePickerDialog> createState() => _ZonePickerDialogState();
}

class _ZonePickerDialogState extends State<_ZonePickerDialog> {
  final List<String> _all = IanaTimeContext.knownZoneIds();
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final needle = _query.trim().toLowerCase().replaceAll(' ', '_');
    final zones = needle.isEmpty
        ? _all
        : _all.where((z) => z.toLowerCase().contains(needle)).toList();
    return AlertDialog(
      title: const Text('Time zone'),
      contentPadding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      content: SizedBox(
        width: double.maxFinite,
        height: 420,
        child: Column(
          children: [
            TextField(
              autofocus: true,
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.search),
                hintText: 'Search, e.g. Ljubljana',
              ),
              onChanged: (value) => setState(() => _query = value),
            ),
            ListTile(
              title: const Text('Unknown'),
              subtitle: const Text('Night uses mean solar time'),
              selected: widget.current == null,
              // S11.C2 (S11H-03): the current choice is marked by more than
              // colour (red on red in field mode).
              trailing: widget.current == null ? const Icon(Icons.check) : null,
              onTap: () => Navigator.of(context).pop((zoneId: null)),
            ),
            const Divider(height: 1),
            Expanded(
              child: ListView.builder(
                itemCount: zones.length,
                itemBuilder: (context, index) {
                  final zone = zones[index];
                  return ListTile(
                    dense: true,
                    title: Text(zone),
                    selected: zone == widget.current,
                    trailing: zone == widget.current
                        ? const Icon(Icons.check)
                        : null,
                    onTap: () => Navigator.of(context).pop((zoneId: zone)),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
      ],
    );
  }
}
