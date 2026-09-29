// Site editor field validation (TASK 7.3). S7.5 (RG-08 = E2): elevation is
// optional; the light-pollution map opens at the typed coordinates only.

import 'package:astroplan/presentation/shared/site_form_input.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('name is required', () {
    expect(SiteFormInput.validateName('Backyard'), isNull);
    expect(SiteFormInput.validateName('   '), isNotNull);
    expect(SiteFormInput.validateName(null), isNotNull);
  });

  test('elevation is optional (empty = unknown), in metres, -500..9000', () {
    expect(SiteFormInput.validateElevation('295'), isNull);
    expect(SiteFormInput.validateElevation('-430'), isNull);
    expect(SiteFormInput.validateElevation(''), isNull);
    expect(SiteFormInput.validateElevation('  '), isNull);
    expect(SiteFormInput.validateElevation('high'), isNotNull);
    expect(SiteFormInput.validateElevation('9001'), isNotNull);
  });

  test('SQM is optional (empty = unknown), 15..23', () {
    expect(SiteFormInput.validateSqm(''), isNull);
    expect(SiteFormInput.validateSqm('21,2'), isNull);
    expect(SiteFormInput.validateSqm('14.9'), isNotNull);
    expect(SiteFormInput.validateSqm('dark'), isNotNull);
  });

  test('the map link: only for valid typed coordinates', () {
    expect(
      SiteFormInput.mapLink('46.05', '14,51').toString(),
      'https://lightpollutionmap.app/?lat=46.0500&lng=14.5100&zoom=10',
    );
    expect(SiteFormInput.mapLink('', '14.51'), isNull);
    expect(SiteFormInput.mapLink('95', '14.51'), isNull);
    expect(SiteFormInput.mapLink('46.05', '200'), isNull);
  });

  test('optional text trims to null', () {
    expect(SiteFormInput.optionalText('  '), isNull);
    expect(SiteFormInput.optionalText(' Gate code 12 '), 'Gate code 12');
  });
}
