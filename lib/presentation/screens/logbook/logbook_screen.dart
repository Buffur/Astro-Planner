import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import '../../../domain/models/session_log.dart';
import '../../../domain/repositories/logbook_repository.dart';

class LogbookScreen extends StatefulWidget {
  const LogbookScreen({super.key});

  @override
  State<LogbookScreen> createState() => _LogbookScreenState();
}

class _LogbookScreenState extends State<LogbookScreen> {
  late Future<List<SessionLog>> _logsFuture;

  @override
  void initState() {
    super.initState();
    _refreshLogs();
  }

  void _refreshLogs() {
    final repo = context.read<LogbookRepository>();
    setState(() {
      _logsFuture = repo.getAllLogs();
    });
  }

  void _showEditDialog(BuildContext context, SessionLog log) {
    final actualFramesCtrl = TextEditingController(text: log.actualLightFrames?.toString() ?? '');
    final notesCtrl = TextEditingController(text: log.environmentalNotes ?? '');

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Session'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: actualFramesCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Actual Frames'),
              ),
              TextField(
                controller: notesCtrl,
                decoration: const InputDecoration(labelText: 'Notes'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                final updated = SessionLog(
                  id: log.id,
                  targetName: log.targetName,
                  equipmentName: log.equipmentName,
                  sessionDate: log.sessionDate,
                  plannedLightFrames: log.plannedLightFrames,
                  actualLightFrames: int.tryParse(actualFramesCtrl.text),
                  environmentalNotes: notesCtrl.text,
                  rejectedFrames: log.rejectedFrames,
                  processingNotes: log.processingNotes,
                );
                await context.read<LogbookRepository>().updateLog(updated);
                if (context.mounted) Navigator.of(context).pop();
                _refreshLogs();
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Logbook'),
      ),
      body: FutureBuilder<List<SessionLog>>(
        future: _logsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No sessions saved yet.'));
          }

          final logs = snapshot.data!;
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: logs.length,
            itemBuilder: (context, index) {
              final log = logs[index];
              return Dismissible(
                key: ValueKey(log.id),
                direction: DismissDirection.endToStart,
                background: Container(
                  color: Colors.red,
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 20),
                  child: const Icon(Icons.delete, color: Colors.white),
                ),
                onDismissed: (_) async {
                  await context.read<LogbookRepository>().deleteLog(log.id);
                  _refreshLogs();
                },
                child: Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16.0),
                    title: Text(
                      '${log.sessionDate.toLocal().toString().split(' ')[0]} - ${log.targetName}',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 8),
                        Text('Equipment: ${log.equipmentName}'),
                        Text('Planned Frames: ${log.plannedLightFrames}'),
                        if (log.actualLightFrames != null)
                          Text('Actual Frames: ${log.actualLightFrames}'),
                      ],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () {
                            _showEditDialog(context, log);
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.share),
                          onPressed: () {
                            SharePlus.instance.share(ShareParams(text: log.toShareableText()));
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
