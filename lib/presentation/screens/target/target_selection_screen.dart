import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../domain/repositories/target_repository.dart';
import '../../../domain/models/astro_target.dart';
import '../../viewmodels/planner_viewmodel.dart';

class TargetSelectionScreen extends StatefulWidget {
  const TargetSelectionScreen({super.key});

  @override
  State<TargetSelectionScreen> createState() => _TargetSelectionScreenState();
}

class _TargetSelectionScreenState extends State<TargetSelectionScreen> {
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final repo = context.read<TargetRepository>();
    final planner = context.watch<PlannerViewModel>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Target'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60.0),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search target (e.g., Andromeda)',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
          ),
        ),
      ),
      body: FutureBuilder<List<AstroTarget>>(
        future: repo.searchTargets(_searchQuery),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No targets found.'));
          }

          final targetList = snapshot.data!;
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: targetList.length,
            itemBuilder: (context, index) {
              final target = targetList[index];
              final isSelected = target.id == planner.selectedTarget?.id;

              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                shape: RoundedRectangleBorder(
                  side: BorderSide(
                    color: isSelected ? Theme.of(context).colorScheme.primary : Colors.transparent,
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  title: Text('${target.commonName} (${target.catalogId})', style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(target.type),
                  trailing: isSelected ? const Icon(Icons.check_circle, color: Colors.blue) : null,
                  onTap: () {
                    planner.setTarget(target);
                    context.pop();
                  },
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddTargetDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showAddTargetDialog(BuildContext context) {
    final catalogIdCtrl = TextEditingController();
    final commonNameCtrl = TextEditingController();
    final typeCtrl = TextEditingController(text: 'Custom Object');
    final raCtrl = TextEditingController();
    final decCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add Custom Target'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(controller: catalogIdCtrl, decoration: const InputDecoration(labelText: 'Catalog ID (e.g. C-1)')),
                TextField(controller: commonNameCtrl, decoration: const InputDecoration(labelText: 'Common Name')),
                TextField(controller: typeCtrl, decoration: const InputDecoration(labelText: 'Type')),
                TextField(controller: raCtrl, keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true), decoration: const InputDecoration(labelText: 'Right Ascension (Decimal Degrees)')),
                TextField(controller: decCtrl, keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true), decoration: const InputDecoration(labelText: 'Declination (Decimal Degrees)')),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () async {
                final target = AstroTarget(
                  id: 0,
                  catalogId: catalogIdCtrl.text,
                  commonName: commonNameCtrl.text.isEmpty ? null : commonNameCtrl.text,
                  type: typeCtrl.text,
                  rightAscension: double.tryParse(raCtrl.text) ?? 0.0,
                  declination: double.tryParse(decCtrl.text) ?? 0.0,
                );
                await context.read<TargetRepository>().insertTarget(target);
                if (context.mounted) {
                  Navigator.of(context).pop();
                  setState(() {}); // Refresh list
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }
}
