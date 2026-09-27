// S5.8 (ADR-019 §3; RD-09 = M + S1): the shared patterns for confirming,
// reporting and deleting. Every way out of a prompt is tested; a
// confirmation cannot be dismissed into a delete; the undo message reports
// exactly one outcome; a swipe is a shortcut to the visible Delete and the
// row springs back; all of it is red or black in field mode by the theme
// alone.

import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:astroplan/core/theme/app_theme.dart';
import 'package:astroplan/presentation/shared/confirmation_patterns.dart';
import 'package:astroplan/presentation/shared/delete_patterns.dart';
import 'package:astroplan/presentation/shared/failure_feedback.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

/// A host page; returns its context.
Future<BuildContext> _host(
  WidgetTester tester, {
  ThemeData? theme,
  Widget? body,
}) async {
  late BuildContext context;
  await tester.pumpWidget(
    RepaintBoundary(
      key: const Key('shot'),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: theme ?? AppTheme.light,
        home: Scaffold(
          body: Builder(
            builder: (c) {
              context = c;
              return body ?? const SizedBox.expand();
            },
          ),
        ),
      ),
    ),
  );
  return context;
}

Future<int> _colouredPixels(WidgetTester tester) async {
  final boundary = tester.renderObject<RenderRepaintBoundary>(
    find.byKey(const Key('shot')),
  );
  final bytes = (await tester.runAsync(() async {
    final image = await boundary.toImage();
    final data = await image.toByteData(format: ui.ImageByteFormat.rawRgba);
    image.dispose();
    return data!;
  }))!;
  return _count(bytes);
}

int _count(ByteData bytes) {
  var n = 0;
  for (var i = 0; i < bytes.lengthInBytes; i += 4) {
    if (bytes.getUint8(i + 1) != 0 || bytes.getUint8(i + 2) != 0) n++;
  }
  return n;
}

void main() {
  group('the unsaved-changes prompt', () {
    for (final (key, expected) in [
      ('unsaved.save', UnsavedChoice.save),
      ('unsaved.discard', UnsavedChoice.discard),
      ('unsaved.cancel', UnsavedChoice.cancel),
    ]) {
      testWidgets('$key answers ${expected.name}', (tester) async {
        final context = await _host(tester);
        final answer = askUnsavedChanges(context, plan: 'M42 · Fri, Nov 13');
        await tester.pumpAndSettle();
        expect(find.text('Unsaved changes'), findsOneWidget);
        expect(
          find.text('"M42 · Fri, Nov 13" has changes that are not saved.'),
          findsOneWidget,
        );
        await tester.tap(find.byKey(Key(key)));
        await tester.pumpAndSettle();
        expect(await answer, expected);
      });
    }

    testWidgets('a tap outside is Cancel; Discard is destructive', (
      tester,
    ) async {
      final context = await _host(tester);
      final answer = askUnsavedChanges(context, plan: 'M42');
      await tester.pumpAndSettle();
      final discard = tester.widget<TextButton>(
        find.byKey(const Key('unsaved.discard')),
      );
      expect(
        discard.style!.foregroundColor!.resolve({}),
        AppTheme.light.colorScheme.error,
      );
      await tester.tapAt(const Offset(5, 5));
      await tester.pumpAndSettle();
      expect(await answer, UnsavedChoice.cancel);
    });
  });

  group('the destructive confirmation', () {
    Future<Future<bool>> open(WidgetTester tester) async {
      final context = await _host(tester);
      final answer = confirmDestructive(
        context,
        title: 'Delete rig "Refractor 400"?',
        message: 'Plans that use it keep their saved values.',
      );
      await tester.pumpAndSettle();
      return answer;
    }

    testWidgets('Delete confirms', (tester) async {
      final answer = await open(tester);
      expect(find.text('Delete rig "Refractor 400"?'), findsOneWidget);
      await tester.tap(find.byKey(const Key('confirm.action')));
      await tester.pumpAndSettle();
      expect(await answer, isTrue);
    });

    testWidgets('Cancel, a tap outside and back all keep the item', (
      tester,
    ) async {
      var answer = await open(tester);
      await tester.tap(find.byKey(const Key('confirm.cancel')));
      await tester.pumpAndSettle();
      expect(await answer, isFalse);

      answer = await open(tester);
      await tester.tapAt(const Offset(5, 5));
      await tester.pumpAndSettle();
      expect(await answer, isFalse);

      answer = await open(tester);
      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      expect(await answer, isFalse);
    });
  });

  group('the undo message', () {
    testWidgets('Undo reports undone, once, and never commits', (tester) async {
      final context = await _host(tester);
      final calls = <String>[];
      final result = showUndo(
        context,
        message: 'Block deleted',
        onUndo: () => calls.add('undo'),
        onCommit: () => calls.add('commit'),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Undo'));
      await tester.pumpAndSettle();
      expect(await result, isTrue);
      expect(calls, ['undo']);
    });

    testWidgets('left alone it commits, once, when it times out', (
      tester,
    ) async {
      final context = await _host(tester);
      final calls = <String>[];
      final result = showUndo(
        context,
        message: 'Block deleted',
        onUndo: () => calls.add('undo'),
        onCommit: () => calls.add('commit'),
      );
      await tester.pumpAndSettle();
      await tester.pump(const Duration(seconds: 7));
      await tester.pumpAndSettle();
      expect(await result, isFalse);
      expect(calls, ['commit']);
    });

    testWidgets('replaced by another message or removed, it commits', (
      tester,
    ) async {
      final context = await _host(tester);
      final calls = <String>[];
      final first = showUndo(
        context,
        message: 'Block deleted',
        onUndo: () => calls.add('undo 1'),
        onCommit: () => calls.add('commit 1'),
      );
      await tester.pumpAndSettle();
      final second = showUndo(
        context,
        message: 'Block deleted',
        onUndo: () => calls.add('undo 2'),
        onCommit: () => calls.add('commit 2'),
      );
      await tester.pumpAndSettle();
      ScaffoldMessenger.of(context).removeCurrentSnackBar();
      await tester.pumpAndSettle();
      expect([await first, await second], [false, false]);
      expect(calls, ['commit 1', 'commit 2']);
    });
  });

  testWidgets('showDone names what happened', (tester) async {
    final context = await _host(tester);
    showDone(context, 'New plan started');
    await tester.pumpAndSettle();
    expect(find.text('New plan started'), findsOneWidget);
    showDone(context, 'Plan saved'); // replaces the previous one
    await tester.pumpAndSettle();
    expect(find.text('Plan saved'), findsOneWidget);
    expect(find.text('New plan started'), findsNothing);
  });

  group('swipe and the visible Delete (S1)', () {
    testWidgets('a swipe calls the same handler and the row springs back', (
      tester,
    ) async {
      final deletes = <String>[];
      await _host(
        tester,
        body: ListView(
          children: [
            SwipeToDelete(
              itemKey: const ValueKey('rig_3'),
              onDelete: () => deletes.add('swipe'),
              child: ListTile(
                title: const Text('Refractor 400'),
                trailing: DeleteButton(
                  tooltip: 'Delete rig',
                  onPressed: () => deletes.add('button'),
                ),
              ),
            ),
          ],
        ),
      );
      await tester.drag(find.text('Refractor 400'), const Offset(-500, 0));
      await tester.pumpAndSettle();
      expect(deletes, ['swipe']);
      expect(find.text('Refractor 400'), findsOneWidget); // not dismissed
      expect(
        tester.getTopLeft(find.text('Refractor 400')).dx,
        lessThan(100), // back in place, not slid away
      );

      await tester.tap(find.byTooltip('Delete rig'));
      expect(deletes, ['swipe', 'button']);
    });
  });

  testWidgets('field mode: the prompt, the confirmation, the undo and the '
      'done messages are red or black by the theme alone', (tester) async {
    final context = await _host(tester, theme: AppTheme.fieldTheme);
    askUnsavedChanges(context, plan: 'M42');
    await tester.pumpAndSettle();
    expect(await _colouredPixels(tester), 0, reason: 'prompt');
    await tester.tap(find.byKey(const Key('unsaved.cancel')));
    await tester.pumpAndSettle();

    confirmDestructive(context, title: 'Delete rig?', message: 'Kept.');
    await tester.pumpAndSettle();
    expect(await _colouredPixels(tester), 0, reason: 'confirmation');
    await tester.tap(find.byKey(const Key('confirm.cancel')));
    await tester.pumpAndSettle();

    showUndo(context, message: 'Block deleted', onUndo: () {});
    await tester.pumpAndSettle();
    expect(await _colouredPixels(tester), 0, reason: 'undo');

    showDone(context, 'Plan saved');
    await tester.pumpAndSettle();
    expect(await _colouredPixels(tester), 0, reason: 'done');
  });
}
