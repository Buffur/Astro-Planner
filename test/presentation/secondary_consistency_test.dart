// S9.9 (Stage 9, "final visual consistency"): the secondary screens use the
// Stage 5 text roles and spacing tokens, not ad hoc styles. The planner and
// Tonight are Stage 6's and are not listed.

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// The secondary screens S9.9 covers.
const secondaryScreens = [
  'lib/presentation/screens/library/library_screen.dart',
  'lib/presentation/screens/equipment/equipment_selection_screen.dart',
  'lib/presentation/screens/target/target_selection_screen.dart',
  'lib/presentation/screens/sites/sites_screen.dart',
  'lib/presentation/screens/sites/site_editor_screen.dart',
  'lib/presentation/screens/about/about_screen.dart',
  'lib/presentation/screens/settings/settings_screen.dart',
  'lib/presentation/screens/settings/backup_section.dart',
  'lib/presentation/screens/details/night_moon_screen.dart',
  'lib/presentation/screens/details/weather_detail_screen.dart',
  'lib/presentation/widgets/sky_darkness_widget.dart',
  'lib/presentation/widgets/weather_forecast_widget.dart',
  'lib/presentation/screens/execution/results_screen.dart',
];

final _insets = RegExp(r'EdgeInsets\.\w+\([^()]*\)');
final _token = RegExp(r'AppSpacing\.\w+( [/*+-] (AppSpacing\.\w+|\d+))*');

/// The ad hoc styles in [source]: a `TextStyle(...)` built by hand, or an
/// `EdgeInsets` with a number that is not a spacing token.
List<String> adHocStyles(String source) => [
  for (final (i, line) in source.split('\n').indexed)
    if (!line.trimLeft().startsWith('//') && line.contains('TextStyle('))
      'line ${i + 1}: TextStyle(…)',
  for (final m in _insets.allMatches(source))
    if (RegExp(r'[1-9]').hasMatch(m.group(0)!.replaceAll(_token, '')))
      m.group(0)!,
];

void main() {
  test('the secondary screens use the text roles and spacing tokens', () {
    final problems = {
      for (final path in secondaryScreens)
        if (adHocStyles(File(path).readAsStringSync()) case final found
            when found.isNotEmpty)
          path: found,
    };
    expect(problems, isEmpty);
  });

  test('the check sees what it forbids, and allows the tokens', () {
    expect(
      adHocStyles('style: const TextStyle(fontWeight: FontWeight.bold)'),
      hasLength(1),
    );
    expect(adHocStyles('padding: const EdgeInsets.all(16)'), hasLength(1));
    expect(
      adHocStyles('padding: const EdgeInsets.only(bottom: 88)'),
      hasLength(1),
    );
    expect(
      adHocStyles('padding: const EdgeInsets.all(AppSpacing.md)'),
      isEmpty,
    );
    expect(
      adHocStyles('EdgeInsets.symmetric(vertical: AppSpacing.xs / 2)'),
      isEmpty,
    );
    expect(adHocStyles('EdgeInsets.fromLTRB(AppSpacing.md, 0, 0, 0)'), isEmpty);
    expect(adHocStyles('// a comment with TextStyle( in it'), isEmpty);
  });
}
