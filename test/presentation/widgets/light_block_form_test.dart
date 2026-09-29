// S7.2b (ADR-020 §3–§5; RG-11 = C1, B1, P2): a light block asks only for
// what applies to the rig's camera class: ISO for phones and cameras, gain
// for astro cameras, the choice for Unknown; binning only for astro cameras
// and Unknown. A value the class does not show is kept as recorded and
// named; nothing is converted between ISO and gain. A new light block
// starts from the plan's last light block, marked as a proposal and stored
// only on Add.

import 'package:astroplan/domain/models/camera_class.dart';
import 'package:astroplan/domain/models/capture_block.dart';
import 'package:astroplan/presentation/widgets/capture_plan/capture_block_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

CaptureBlock _light({
  double exposure = 120,
  int count = 30,
  int binning = 1,
  CaptureGain gain = CaptureGain.none,
}) => CaptureBlock(
  frameType: FrameType.light,
  filterName: 'L',
  exposureTimeSeconds: exposure,
  frameCount: count,
  binning: binning,
  gain: gain,
);

void main() {
  test('the rule per class', () {
    expect(
      {for (final c in CameraClass.values) c: c.lightSensitivity},
      {
        CameraClass.phone: LightSensitivity.iso,
        CameraClass.dslrMirrorless: LightSensitivity.iso,
        CameraClass.astroColour: LightSensitivity.gain,
        CameraClass.astroMono: LightSensitivity.gain,
        CameraClass.unknown: LightSensitivity.either,
      },
    );
    expect(
      [
        for (final c in CameraClass.values)
          if (c.offersLightBinning) c,
      ],
      [CameraClass.astroColour, CameraClass.astroMono, CameraClass.unknown],
    );
  });

  /// Opens the dialog; [result] receives what it returns.
  Future<void> open(
    WidgetTester tester,
    List<CaptureBlock?> result, {
    CaptureBlock? initial,
    CaptureBlock? proposal,
    CameraClass cameraClass = CameraClass.unknown,
    double textScale = 2,
  }) async {
    tester.view.physicalSize = const Size(412, 915);
    tester.view.devicePixelRatio = 1;
    tester.platformDispatcher.textScaleFactorTestValue = textScale;
    addTearDown(tester.view.reset);
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => TextButton(
              onPressed: () async => result.add(
                await showCaptureBlockDialog(
                  context,
                  initial: initial,
                  proposal: proposal,
                  cameraClass: cameraClass,
                ),
              ),
              child: const Text('open'),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
  }

  String? label(WidgetTester tester) => tester
      .widget<TextField>(
        find.descendant(
          of: find.byKey(const Key('blockDialog.gainValue')),
          matching: find.byType(TextField),
        ),
      )
      .decoration
      ?.labelText;

  Future<void> submit(WidgetTester tester) async {
    await tester.ensureVisible(find.byKey(const Key('blockDialog.submit')));
    await tester.tap(find.byKey(const Key('blockDialog.submit')));
    await tester.pumpAndSettle();
  }

  for (final (cls, iso) in [
    (CameraClass.phone, true),
    (CameraClass.dslrMirrorless, true),
    (CameraClass.astroColour, false),
    (CameraClass.astroMono, false),
  ]) {
    testWidgets('${cls.name}: one ${iso ? 'ISO' : 'gain'} field, '
        '${iso ? 'no' : 'with'} binning, at 200 % text', (tester) async {
      await open(tester, [], cameraClass: cls);
      expect(find.byKey(const Key('blockDialog.gainKind')), findsNothing);
      expect(
        label(tester),
        iso ? 'ISO (for your records)' : 'Gain (for your records)',
      );
      expect(
        find.byKey(const Key('blockDialog.binning')),
        iso ? findsNothing : findsOneWidget,
      );
      expect(find.textContaining('sensitivity'), findsNothing);
      expect(tester.takeException(), isNull, reason: 'no overflow');
    });
  }

  testWidgets('Unknown keeps the choice of ISO or gain, and binning', (
    tester,
  ) async {
    await open(tester, []);
    expect(find.byKey(const Key('blockDialog.gainKind')), findsOneWidget);
    expect(find.byKey(const Key('blockDialog.binning')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('a phone rig keeps a recorded gain and binning it does not '
      'show, names them, and never converts the gain', (tester) async {
    final result = <CaptureBlock?>[];
    final block = _light(binning: 2, gain: CaptureGain.gain(100));
    await open(tester, result, initial: block, cameraClass: CameraClass.phone);
    expect(find.byKey(const Key('blockDialog.binning')), findsNothing);
    final field = find.descendant(
      of: find.byKey(const Key('blockDialog.gainValue')),
      matching: find.byType(EditableText),
    );
    expect(
      tester.widget<EditableText>(field).controller.text,
      '',
      reason: 'a gain is never shown as an ISO',
    );
    expect(
      find.text('Also recorded: 2 × 2 binning, gain 100 (kept as it was).'),
      findsOneWidget,
    );
    await submit(tester);
    expect(result.single!.binning, 2);
    expect(result.single!.gain, CaptureGain.gain(100));
  });

  testWidgets('an ISO typed on a camera rig replaces the recorded value; '
      'clearing its own ISO records none', (tester) async {
    final result = <CaptureBlock?>[];
    await open(
      tester,
      result,
      initial: _light(gain: CaptureGain.gain(100)),
      cameraClass: CameraClass.dslrMirrorless,
    );
    await tester.enterText(
      find.byKey(const Key('blockDialog.gainValue')),
      '800',
    );
    await submit(tester);
    expect(result.single!.gain, CaptureGain.iso(800));

    final cleared = <CaptureBlock?>[];
    await open(
      tester,
      cleared,
      initial: _light(gain: CaptureGain.iso(1600)),
      cameraClass: CameraClass.dslrMirrorless,
    );
    await tester.enterText(find.byKey(const Key('blockDialog.gainValue')), '');
    await submit(tester);
    expect(cleared.single!.gain, CaptureGain.none);
  });

  testWidgets('a new light block starts from the last light block, marked '
      'as a proposal; the count is the user\'s', (tester) async {
    final result = <CaptureBlock?>[];
    await open(
      tester,
      result,
      cameraClass: CameraClass.astroMono,
      proposal: _light(
        exposure: 300,
        count: 12,
        binning: 2,
        gain: CaptureGain.gain(100),
      ),
    );
    expect(find.byKey(const Key('blockDialog.proposal')), findsOneWidget);
    String textOf(String labelText) => tester
        .widget<EditableText>(
          find.descendant(
            of: find.widgetWithText(TextFormField, labelText),
            matching: find.byType(EditableText),
          ),
        )
        .controller
        .text;
    expect(textOf('Exposure (seconds)'), '300');
    expect(textOf('Frame Count'), '');
    expect(textOf('Gain (for your records)'), '100');
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Frame Count'),
      '20',
    );
    await submit(tester);
    final b = result.single!;
    expect(
      (b.exposureTimeSeconds, b.frameCount, b.binning, b.gain),
      (300.0, 20, 2, CaptureGain.gain(100)),
    );
  });

  testWidgets('a proposal is stored only on Add: Cancel returns nothing', (
    tester,
  ) async {
    final result = <CaptureBlock?>[];
    await open(tester, result, proposal: _light(exposure: 60));
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(result.single, isNull);
  });

  testWidgets('a proposal from another kind is not converted: a camera '
      'rig\'s ISO field stays empty for a gain', (tester) async {
    await open(
      tester,
      [],
      cameraClass: CameraClass.phone,
      proposal: _light(gain: CaptureGain.gain(100)),
    );
    expect(
      tester
          .widget<EditableText>(
            find.descendant(
              of: find.byKey(const Key('blockDialog.gainValue')),
              matching: find.byType(EditableText),
            ),
          )
          .controller
          .text,
      '',
    );
  });

  testWidgets('editing a block shows no proposal', (tester) async {
    await open(tester, [], initial: _light(), proposal: _light(exposure: 300));
    expect(find.byKey(const Key('blockDialog.proposal')), findsNothing);
  });
}
