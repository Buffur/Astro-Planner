import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../domain/repositories/target_repository.dart';
import '../../../domain/models/astro_target.dart';
import '../../viewmodels/planner_viewmodel.dart';

// Canonical list of astronomical object types used throughout the app.
const _kObjectTypes = [
  'Galaxy',
  'Nebula',
  'Globular Cluster',
  'Open Cluster',
  'Planet',
  'Moon',
  'Comet',
  'Asteroid',
  'Star',
  'Other',
];

class TargetSelectionScreen extends StatefulWidget {
  const TargetSelectionScreen({super.key});

  @override
  State<TargetSelectionScreen> createState() => _TargetSelectionScreenState();
}

class _TargetSelectionScreenState extends State<TargetSelectionScreen> {
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  // In-memory list avoids FutureBuilder flicker on every add/edit/delete.
  List<AstroTarget> _targets = [];
  bool _initialLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTargets();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadTargets() async {
    final repo = context.read<TargetRepository>();
    final results = await repo.searchTargets(_searchQuery);
    if (mounted) {
      setState(() {
        _targets = results;
        _initialLoading = false;
      });
    }
  }

  /// Displays name without duplicating it in parentheses when name == catalogId.
  String _targetLabel(AstroTarget target) {
    final name = target.commonName ?? target.catalogId;
    if (target.commonName != null && target.commonName != target.catalogId) {
      return '$name (${target.catalogId})';
    }
    return name;
  }

  void _onSearchChanged(String value) {
    setState(() => _searchQuery = value);
    _loadTargets();
  }

  Future<void> _showTargetDialog({AstroTarget? existing}) async {
    final nameCtrl = TextEditingController(
      text: existing?.commonName ?? existing?.catalogId ?? '',
    );
    final raCtrl = TextEditingController(
      text: (existing != null && existing.rightAscension != 0.0)
          ? existing.rightAscension.toString()
          : '',
    );
    final decCtrl = TextEditingController(
      text: (existing != null && existing.declination != 0.0)
          ? existing.declination.toString()
          : '',
    );
    String selectedType = existing?.type ?? _kObjectTypes.first;
    final isEdit = existing != null;

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text(isEdit ? 'Edit Target' : 'Add Custom Target'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: nameCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Target Name',
                        hintText: 'e.g. Andromeda Galaxy',
                      ),
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: selectedType,
                      decoration: const InputDecoration(labelText: 'Object Type'),
                      items: _kObjectTypes
                          .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                          .toList(),
                      onChanged: (val) {
                        if (val != null) setDialogState(() => selectedType = val);
                      },
                    ),
                    const SizedBox(height: 16),
                    ExpansionTile(
                      title: const Text(
                        'Advanced Settings (Optional)',
                        style: TextStyle(fontSize: 14),
                      ),
                      childrenPadding:
                          const EdgeInsets.only(left: 16, right: 16, bottom: 16),
                      tilePadding: EdgeInsets.zero,
                      children: [
                        TextField(
                          controller: raCtrl,
                          keyboardType: const TextInputType.numberWithOptions(
                              decimal: true, signed: true),
                          decoration: const InputDecoration(
                            labelText: 'Right Ascension (Degrees)',
                            hintText: '0.0',
                          ),
                        ),
                        TextField(
                          controller: decCtrl,
                          keyboardType: const TextInputType.numberWithOptions(
                              decimal: true, signed: true),
                          decoration: const InputDecoration(
                            labelText: 'Declination (Degrees)',
                            hintText: '0.0',
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    final name = nameCtrl.text.trim();
                    if (name.isEmpty) return;
                    final repo = context.read<TargetRepository>();
                    final target = AstroTarget(
                      id: existing?.id ?? 0,
                      catalogId: name,
                      commonName: name,
                      type: selectedType,
                      rightAscension: double.tryParse(raCtrl.text) ?? 0.0,
                      declination: double.tryParse(decCtrl.text) ?? 0.0,
                    );
                    if (isEdit) {
                      await repo.updateTarget(target);
                    } else {
                      await repo.insertTarget(target);
                    }
                    if (context.mounted) Navigator.of(context).pop();
                  },
                  child: Text(isEdit ? 'Save Changes' : 'Save'),
                ),
              ],
            );
          },
        );
      },
    );
    // Refresh list after dialog closes, regardless of whether user saved.
    _loadTargets();
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
                fillColor:
                    Theme.of(context).colorScheme.surfaceContainerHighest,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: _onSearchChanged,
            ),
          ),
        ),
      ),
      body: _initialLoading
          ? const Center(child: CircularProgressIndicator())
          : _targets.isEmpty
              ? Center(
                  child: Text(_searchQuery.isEmpty
                      ? 'No targets found.'
                      : 'No results for "$_searchQuery".'),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _targets.length,
                  itemBuilder: (context, index) {
                    final target = _targets[index];
                    final isSelected = target.id == planner.selectedTarget?.id;

                    final card = Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      shape: RoundedRectangleBorder(
                        side: BorderSide(
                          color: isSelected
                              ? Theme.of(context).colorScheme.primary
                              : Colors.transparent,
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ListTile(
                        title: Text(
                          _targetLabel(target),
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(target.type),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon:
                                  const Icon(Icons.edit_outlined, size: 20),
                              tooltip: 'Edit',
                              onPressed: () =>
                                  _showTargetDialog(existing: target),
                            ),
                            if (isSelected)
                              const Icon(Icons.check_circle,
                                  color: Colors.blue),
                          ],
                        ),
                        onTap: () {
                          planner.setTarget(target);
                          context.pop();
                        },
                      ),
                    );

                    return Dismissible(
                      key: ValueKey('target_${target.id}'),
                      direction: DismissDirection.endToStart,
                      background: Container(
                        decoration: BoxDecoration(
                          color: Colors.red.shade400,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 16),
                        margin: const EdgeInsets.only(bottom: 8),
                        child: const Icon(Icons.delete, color: Colors.white),
                      ),
                      confirmDismiss: (direction) async {
                        return await showDialog<bool>(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Delete Target?'),
                            content: Text(
                              'Are you sure you want to delete ${target.commonName ?? target.catalogId}?',
                            ),
                            actions: [
                              TextButton(
                                onPressed: () =>
                                    Navigator.pop(context, false),
                                child: const Text('Cancel'),
                              ),
                              TextButton(
                                onPressed: () =>
                                    Navigator.pop(context, true),
                                child: const Text('Delete'),
                              ),
                            ],
                          ),
                        );
                      },
                      onDismissed: (direction) async {
                        await repo.deleteTarget(target.id);
                        // Remove instantly from in-memory list вЂ” no flicker.
                        setState(() =>
                            _targets.removeWhere((t) => t.id == target.id));
                      },
                      child: card,
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showTargetDialog(),
        child: const Icon(Icons.add),
      ),
    );
  }
}
