import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:go_router/go_router.dart';

import '../../../domain/models/calendar_date.dart';
import '../../../domain/models/session.dart';
import '../../viewmodels/library_viewmodels.dart';
import '../../shared/night_time_formatter.dart';
import '../../navigation/app_router.dart';
import '../../viewmodels/session_plan_viewmodel.dart';

/// Saved sessions (TASK 11.3, owner decision): every non-draft session —
/// planned, in progress, completed, abandoned — and the legacy logs, newest
/// first, each with its status. A saved plan edited since its last Save is
/// a draft again but stays listed as "unsaved changes" (owner, TASK 11.4).
class LogbookScreen extends StatefulWidget {
  const LogbookScreen({super.key});

  @override
  State<LogbookScreen> createState() => _LogbookScreenState();
}

class _LogbookScreenState extends State<LogbookScreen> {
  late Future<List<Session>> _sessionsFuture;

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  void _refresh() {
    final sessions = context.read<SessionsViewModel>();
    setState(() {
      _sessionsFuture = sessions.saved();
    });
  }

  static String statusLabel(Session s) {
    if (s.legacy) return 'Legacy log';
    return switch (s.status) {
      SessionStatus.draft =>
        s.plannedAtUtc != null ? 'Planned, unsaved changes' : 'Draft',
      SessionStatus.planned => 'Planned',
      SessionStatus.inProgress => 'In progress',
      SessionStatus.completed => 'Completed',
      SessionStatus.abandoned => 'Abandoned',
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sessions')),
      body: FutureBuilder<List<Session>>(
        future: _sessionsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No sessions saved yet.'));
          }

          final sessions = snapshot.data!;
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: sessions.length,
            itemBuilder: (context, index) {
              final session = sessions[index];
              final log = session.record;
              // The night key; a legacy instant maps to its device-local
              // calendar date, as it was shown before (ADR-007 §10).
              final evening =
                  session.eveningDate ??
                  CalendarDate.fromDateTimeFields(log.sessionDate.toLocal());
              return Dismissible(
                key: ValueKey(session.id),
                direction: DismissDirection.endToStart,
                background: Container(
                  color: Colors.red,
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 20),
                  child: const Icon(Icons.delete, color: Colors.white),
                ),
                confirmDismiss: (direction) async {
                  return await showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Delete Session?'),
                      content: Text(
                        'Are you sure you want to delete "${log.targetName}"?',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: const Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(context, true),
                          child: const Text('Delete'),
                        ),
                      ],
                    ),
                  );
                },
                onDismissed: (_) async {
                  await context.read<SessionsViewModel>().delete(session.id);
                  _refresh();
                },
                child: Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16.0),
                    onTap: () async {
                      // TASK 12.2: the planner opens above the tabs; a
                      // frozen session opens as a copy (TASK 11.4).
                      await context.read<SessionPlanViewModel>().openSession(
                        session,
                      );
                      if (context.mounted) {
                        context.push(AppRouter.session());
                      }
                    },
                    title: Text(
                      '${NightTimeFormatter.eveningDate(evening)} - ${log.targetName}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 8),
                        Text(
                          statusLabel(session),
                          key: Key('logbook.status.${session.id}'),
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        Text('Equipment: ${log.equipmentName}'),
                        Text('Planned Frames: ${log.plannedLightFrames}'),
                        if (log.actualLightFrames != null)
                          Text('Actual Frames: ${log.actualLightFrames}'),
                        if (log.rejectedFrames != null &&
                            log.rejectedFrames! > 0)
                          Text(
                            'Rejected Frames: ${log.rejectedFrames}',
                            style: const TextStyle(color: Colors.red),
                          ),
                      ],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.share),
                          onPressed: () {
                            SharePlus.instance.share(
                              ShareParams(text: log.toShareableText()),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
