import 'package:flutter/material.dart';

import '../../core/theme/app_button_styles.dart';

/// What the user chose when unsaved changes would be left behind.
enum UnsavedChoice { save, discard, cancel }

/// The three-way prompt (S5.8; ADR-019 §3, addendum §3.3): "[plan] has
/// changes that are not saved." with Cancel · Discard · Save. Dismissing
/// it (back, a tap outside) is Cancel, so nothing is lost by accident.
/// What Save and Discard then do belongs to the caller (P6.1); this is the
/// prompt only. Discard is styled as destructive.
Future<UnsavedChoice> askUnsavedChanges(
  BuildContext context, {
  required String plan,
}) async {
  final choice = await showDialog<UnsavedChoice>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Unsaved changes'),
      content: Text('"$plan" has changes that are not saved.'),
      actions: [
        TextButton(
          key: const Key('unsaved.cancel'),
          onPressed: () => Navigator.pop(context, UnsavedChoice.cancel),
          child: const Text('Cancel'),
        ),
        TextButton(
          key: const Key('unsaved.discard'),
          style: AppButtonStyles.destructiveText(Theme.of(context).colorScheme),
          onPressed: () => Navigator.pop(context, UnsavedChoice.discard),
          child: const Text('Discard'),
        ),
        TextButton(
          key: const Key('unsaved.save'),
          onPressed: () => Navigator.pop(context, UnsavedChoice.save),
          child: const Text('Save'),
        ),
      ],
    ),
  );
  return choice ?? UnsavedChoice.cancel;
}

/// The one confirmation for a destructive action on something stored
/// (S5.8; RD-09 = M): deleting a rig, a target, a site or a Logbook entry,
/// Abandon, Restore. [title] names the item ("Delete rig "Refractor
/// 400"?"), [message] says the consequence ("Plans that use it keep their
/// saved values."), [action] is the verb on the destructive button
/// ("Delete"). True only when the user taps [action]: Cancel, back and a
/// tap outside all keep the item. Edits inside a plan use the undo message
/// instead (`showUndo`).
Future<bool> confirmDestructive(
  BuildContext context, {
  required String title,
  required String message,
  String action = 'Delete',
}) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(title),
      content: Text(message),
      actions: [
        TextButton(
          key: const Key('confirm.cancel'),
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Cancel'),
        ),
        TextButton(
          key: const Key('confirm.action'),
          style: AppButtonStyles.destructiveText(Theme.of(context).colorScheme),
          onPressed: () => Navigator.pop(context, true),
          child: Text(action),
        ),
      ],
    ),
  );
  return confirmed ?? false;
}
