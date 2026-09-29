import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import '../../../core/utils/astro_math.dart';
import '../../viewmodels/library_viewmodels.dart';
import '../../../domain/models/astro_target.dart';
import '../../../domain/models/target_types.dart';
import '../../navigation/app_router.dart';
import '../../shared/app_words.dart';
import '../../shared/confirmation_patterns.dart';
import '../../shared/delete_patterns.dart';
import '../../shared/failure_feedback.dart';
import '../../shared/list_mode.dart';
import '../../shared/target_form_input.dart';
import '../../shared/unsaved_plan_prompt.dart';
import '../../viewmodels/plan_lifecycle_viewmodel.dart';
import '../../viewmodels/session_plan_viewmodel.dart';
import '../../../core/theme/app_palette.dart';
import '../../../core/theme/app_spacing.dart';

/// The targets (ADR-015; S9.1, D9-1): managed in the Library, where "Plan
/// this target" starts a new plan; chosen for the plan from
/// `/select/target`. Deleting confirms (RD-09 = M + S1).
class TargetSelectionScreen extends StatefulWidget {
  const TargetSelectionScreen({super.key, this.mode = ListMode.choose});

  final ListMode mode;

  @override
  State<TargetSelectionScreen> createState() => _TargetSelectionScreenState();
}

class _TargetSelectionScreenState extends State<TargetSelectionScreen> {
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  // In-memory list avoids FutureBuilder flicker on every add/edit/delete.
  List<AstroTarget> _targets = [];
  bool _initialLoading = true;
  Object? _loadError;

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
    final targets = context.read<TargetsViewModel>();
    try {
      final results = await targets.search(_searchQuery);
      if (mounted) {
        setState(() {
          _targets = results;
          _loadError = null;
          _initialLoading = false;
        });
      }
    } catch (e) {
      // TASK 15.1: an unreadable list says so instead of looking empty.
      if (mounted) {
        setState(() {
          _loadError = e;
          _initialLoading = false;
        });
      }
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

  static String _name(AstroTarget t) => t.commonName ?? t.catalogId;

  /// Deletes [target] after the shared confirmation (a stored record,
  /// RD-09); saved plans keep what they recorded (ADR-014 §4).
  Future<bool> _delete(AstroTarget target) async {
    final sure = await confirmDestructive(
      context,
      title: 'Delete this target?',
      message:
          '"${_name(target)}" is deleted from your targets. Saved plans keep '
          "what they recorded. This can't be undone.",
    );
    if (!sure || !mounted) return false;
    final deleted = await runWithFeedback(
      context,
      'delete the target',
      () => context.read<TargetsViewModel>().delete(target.id),
    );
    if (!mounted) return deleted;
    if (deleted) showDone(context, 'Target deleted');
    await _loadTargets();
    // TD-028: clear the planner's selection if this was it.
    if (mounted) {
      await context.read<SessionPlanViewModel>().refreshSelectedTarget();
    }
    return deleted;
  }

  /// "Plan this target" (S9.1, D9-1): a new plan with [target], after the
  /// leave guard (U1), then the planner.
  Future<void> _planThis(AstroTarget target) async {
    final leaving = await askBeforeLeavingPlan(context);
    if (leaving == null || !mounted) return;
    final lifecycle = context.read<PlanLifecycleViewModel>();
    final plan = context.read<SessionPlanViewModel>();
    final started = await runWithFeedback(
      context,
      'start a new plan',
      () async {
        await lifecycle.newSession(discard: leaving == LeavingPlan.discard);
        await plan.setTarget(target);
      },
    );
    if (started && mounted) {
      showDone(context, 'New plan for ${_name(target)}');
      context.push(AppRouter.session());
    }
  }

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
              title: Text(isEdit ? AppWords.editTarget : AppWords.addTarget),
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
                          labelText: 'Name *',
                          hintText: 'e.g. Andromeda Galaxy',
                        ),
                        validator: (v) =>
                            v == null || v.trim().isEmpty ? 'Required' : null,
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        initialValue: selectedType,
                        decoration: const InputDecoration(
                          labelText: 'Object type',
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
                          labelText: 'Right ascension (J2000) *',
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
                if (existing != null)
                  DeleteButton(
                    key: const Key('targetEditor.delete'),
                    tooltip: 'Delete target',
                    onPressed: () async {
                      if (await _delete(existing) && context.mounted) {
                        Navigator.of(context).pop();
                      }
                    },
                  ),
                if (existing != null && widget.mode == ListMode.manage)
                  TextButton(
                    key: const Key('targetEditor.plan'),
                    onPressed: () {
                      Navigator.of(context).pop();
                      _planThis(existing);
                    },
                    child: const Text(AppWords.planThisTarget),
                  ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
                // S9.2: Save is the primary button, as in the rig editor.
                FilledButton(
                  onPressed: () async {
                    if (!formKey.currentState!.validate()) return;
                    final name = nameCtrl.text.trim();
                    if (name.isEmpty) return;
                    final targets = context.read<TargetsViewModel>();
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
                    final saved = await runWithFeedback(
                      context,
                      'save the target',
                      () =>
                          isEdit ? targets.update(target) : targets.add(target),
                    );
                    if (saved && context.mounted) {
                      // S9.8 (D9-5): a save says so.
                      showDone(context, 'Target saved');
                      Navigator.of(context).pop();
                    }
                  },
                  child: const Text(AppWords.save),
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
      await context.read<SessionPlanViewModel>().refreshSelectedTarget();
    }
  }

  @override
  Widget build(BuildContext context) {
    final planVm = context.watch<SessionPlanViewModel>();
    final choosing = widget.mode == ListMode.choose;

    return Scaffold(
      appBar: AppBar(
        title: Text(choosing ? AppWords.chooseTarget : AppWords.targets),
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
          : _loadError != null
          ? LoadFailureView(
              action: 'load the targets',
              error: _loadError!,
              onRetry: _loadTargets,
            )
          : _targets.isEmpty
          ? Center(
              child: Text(
                _searchQuery.isEmpty
                    ? 'No targets found.'
                    : 'No results for "$_searchQuery".',
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(AppSpacing.md),
              itemCount: _targets.length,
              itemBuilder: (context, index) {
                final target = _targets[index];
                // Only when choosing: the Library describes the targets,
                // not the plan (S9.1).
                final isSelected =
                    choosing && target.id == planVm.selectedTarget?.id;

                final card = Card(
                  margin: const EdgeInsets.only(bottom: AppSpacing.sm),
                  shape: RoundedRectangleBorder(
                    side: BorderSide(
                      color: isSelected
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context).colorScheme.primary.withAlpha(0),
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
                    trailing: choosing
                        ? Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit_outlined, size: 20),
                                tooltip: 'Edit target',
                                onPressed: () =>
                                    _showTargetDialog(existing: target),
                              ),
                              if (isSelected)
                                Icon(
                                  Icons.check_circle,
                                  color: AppPalette.of(context).selected,
                                ),
                            ],
                          )
                        : const Icon(Icons.chevron_right),
                    onTap: choosing
                        ? () {
                            planVm.setTarget(target);
                            context.pop();
                          }
                        : () => _showTargetDialog(existing: target),
                  ),
                );

                return SwipeToDelete(
                  itemKey: ValueKey('target_${target.id}'),
                  onDelete: () => _delete(target),
                  child: card,
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        tooltip: AppWords.addTarget,
        onPressed: () => _showTargetDialog(),
        child: const Icon(Icons.add),
      ),
    );
  }
}
