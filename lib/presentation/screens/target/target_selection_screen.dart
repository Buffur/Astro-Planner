import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import '../../../core/utils/astro_math.dart';
import '../../../domain/repositories/target_repository.dart';
import '../../../domain/models/astro_target.dart';
import '../../../domain/models/target_types.dart';
import '../../shared/target_form_input.dart';
import '../../viewmodels/planner_viewmodel.dart';

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

  /// Types the editor offers: fixed-coordinate types only (ADR-010 §3),
  /// plus an existing target's own moving type so an edit never retypes it
  /// silently.
  List<String> _typeChoices(AstroTarget? existing) => [
    ...TargetTypes.selectable,
    if (existing != null && !TargetTypes.selectable.contains(existing.type))
      existing.type,
  ];

  Future<void> _showTargetDialog({AstroTarget? existing}) async {
    final nameCtrl = TextEditingController(
      text: existing?.commonName ?? existing?.catalogId ?? '',
    );
    final raCtrl = TextEditingController(
      text: existing != null
          ? AstroMath.formatRightAscension(existing.rightAscension)
          : '',
    );
    final decCtrl = TextEditingController(
      text: existing != null
          ? AstroMath.formatDeclination(existing.declination)
          : '',
    );
    final sizeCtrl = TextEditingController(
      text: existing?.angularSizeArcmin?.toString() ?? '',
    );
    final magCtrl = TextEditingController(
      text: existing?.magnitude?.toString() ?? '',
    );
    // The fields show rounded values (0.1 s, 1″); an untouched field keeps
    // the stored value exactly, so a rename never shifts the coordinates or
    // their provenance.
    final raShown = raCtrl.text;
    final decShown = decCtrl.text;
    final types = _typeChoices(existing);
    String selectedType = existing?.type ?? types.first;
    final isEdit = existing != null;
    final formKey = GlobalKey<FormState>();

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text(isEdit ? 'Edit Target' : 'Add Custom Target'),
              content: SingleChildScrollView(
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (isEdit)
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text('Catalog ID: ${existing.catalogId}'),
                        ),
                      TextFormField(
                        controller: nameCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Target Name *',
                          hintText: 'e.g. Andromeda Galaxy',
                        ),
                        validator: (v) =>
                            v == null || v.trim().isEmpty ? 'Required' : null,
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        initialValue: selectedType,
                        decoration: const InputDecoration(
                          labelText: 'Object Type',
                        ),
                        items: types
                            .map(
                              (t) => DropdownMenuItem(value: t, child: Text(t)),
                            )
                            .toList(),
                        onChanged: (val) {
                          if (val != null) {
                            setDialogState(() => selectedType = val);
                          }
                        },
                      ),
                      if (TargetTypes.isMoving(selectedType))
                        const Padding(
                          padding: EdgeInsets.only(top: 8),
                          child: Text(TargetTypes.movingWarning),
                        ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: raCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Right Ascension (J2000) *',
                          hintText: '05h35m17s, 5:35:17 or 5.588 h',
                        ),
                        validator: TargetFormInput.validateRightAscension,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: decCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Declination (J2000) *',
                          hintText: '−05°23′28″, -5:23:28 or -5.39',
                        ),
                        validator: TargetFormInput.validateDeclination,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: sizeCtrl,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        decoration: const InputDecoration(
                          labelText: 'Apparent size (arcmin)',
                          hintText: 'Optional',
                        ),
                        validator: TargetFormInput.validateAngularSize,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: magCtrl,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                          signed: true,
                        ),
                        decoration: const InputDecoration(
                          labelText: 'Magnitude',
                          hintText: 'Optional',
                        ),
                        validator: TargetFormInput.validateMagnitude,
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (!formKey.currentState!.validate()) return;
                    final name = nameCtrl.text.trim();
                    if (name.isEmpty) return;
                    final repo = context.read<TargetRepository>();
                    final target = AstroTarget.userEdit(
                      original: existing,
                      name: name,
                      type: selectedType,
                      rightAscension: existing != null && raCtrl.text == raShown
                          ? existing.rightAscension
                          : AstroMath.parseRightAscension(raCtrl.text)!,
                      declination: existing != null && decCtrl.text == decShown
                          ? existing.declination
                          : AstroMath.parseDeclination(decCtrl.text)!,
                      angularSizeArcmin: TargetFormInput.optionalNumber(
                        sizeCtrl.text,
                      ),
                      magnitude: TargetFormInput.optionalNumber(magCtrl.text),
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
    // TD-028: pick up an edit to the currently selected target instead of
    // leaving the planner showing stale field values. A no-op unless the
    // edited target is the selected one.
    if (mounted) {
      await context.read<PlannerViewModel>().refreshSelectedTarget();
    }
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
                fillColor: Theme.of(context)
                    .colorScheme
                    .surfaceContainerHighest,
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
              child: Text(
                _searchQuery.isEmpty
                    ? 'No targets found.'
                    : 'No results for "$_searchQuery".',
              ),
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
                    subtitle: Text(
                      TargetTypes.isMoving(target.type)
                          ? '${target.type} · ${TargetTypes.movingWarning}'
                          : target.type,
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit_outlined, size: 20),
                          tooltip: 'Edit',
                          onPressed: () => _showTargetDialog(existing: target),
                        ),
                        if (isSelected)
                          const Icon(Icons.check_circle, color: Colors.blue),
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
                  onDismissed: (direction) async {
                    await repo.deleteTarget(target.id);
                    // Remove instantly from in-memory list — no flicker.
                    setState(
                      () => _targets.removeWhere((t) => t.id == target.id),
                    );
                    // TD-028: clear the planner's selection if this was it,
                    // instead of leaving a reference to a deleted target.
                    await planner.refreshSelectedTarget();
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
