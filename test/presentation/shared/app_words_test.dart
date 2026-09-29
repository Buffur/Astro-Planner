// S5.3 (RD-14): the app's words are the glossary's
// (docs/refinement/research/S4.R5_LIBRARY_AND_VOCABULARY.md §5; ADR-019
// §10), written once. A change here is a change to the owner's glossary.

import 'package:astroplan/presentation/shared/app_words.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('the words are the glossary\'s', () {
    const glossary = {
      AppWords.rig: 'Rig',
      AppWords.rigs: 'Rigs',
      AppWords.addRig: 'Add rig',
      AppWords.chooseRig: 'Choose a rig',
      AppWords.plan: 'Plan',
      AppWords.newPlan: 'New plan',
      AppWords.savePlan: 'Save plan',
      AppWords.yourPlan: 'Your plan',
      AppWords.copyToAnotherNight: 'Copy to another night',
      AppWords.logbook: 'Logbook',
      AppWords.night: 'Night',
      AppWords.nightOf: 'Night of',
      AppWords.capturePlan: 'Capture plan',
      AppWords.block: 'block',
      AppWords.notSaved: 'Not saved',
      AppWords.saved: 'Saved',
      AppWords.savedChanged: 'Saved · changed',
      AppWords.tracking: 'Tracking',
      AppWords.completed: 'Completed',
      AppWords.partly: 'Partly',
      AppWords.notDone: 'Not done',
      AppWords.oldLog: 'Old log',
      AppWords.recordResult: 'Record result',
      AppWords.editResult: 'Edit result',
      AppWords.completedAsPlanned: 'Completed as planned',
      AppWords.fits: 'Fits',
      AppWords.tight: 'Tight',
      AppWords.doesNotFit: "Doesn't fit",
      AppWords.noWindow: 'No window',
      AppWords.needsTarget: 'Needs a target',
      AppWords.needsBlock: 'Needs a block',
      AppWords.dark: 'Dark',
      AppWords.darknessLimit: 'Darkness limit',
      AppWords.imagingWindow: 'Imaging window',
      AppWords.civilDusk: 'Civil dusk',
      AppWords.nauticalDusk: 'Nautical dusk',
      AppWords.astronomicalDusk: 'Astronomical dusk',
      AppWords.civilDawn: 'Civil dawn',
      AppWords.nauticalDawn: 'Nautical dawn',
      AppWords.astronomicalDawn: 'Astronomical dawn',
      AppWords.integration: 'Integration',
      AppWords.imagingTime: 'Imaging time',
      AppWords.timeNeeded: 'Time needed',
      AppWords.totalTime: 'Total time',
      AppWords.budgetDetails: 'Budget details',
      AppWords.relativeStackingGain: 'Relative stacking gain (√N vs one frame)',
      AppWords.site: 'Site',
      AppWords.library: 'Library',
      AppWords.progressByTarget: 'Progress by target',
      AppWords.exportAsFile: 'Export as file',
      AppWords.exportAllAsFile: 'Export all as file',
      AppWords.nameOptional: 'Name (optional)',
    };
    glossary.forEach((word, expected) => expect(word, expected));
  });

  test('the headline and the evening line read as the glossary shows', () {
    expect(
      AppWords.headline(AppWords.fits, '2 h 5 min', '4 h 20 min'),
      'Fits: 2 h 5 min needed of 4 h 20 min usable',
    );
    expect(AppWords.howDidItGo('M42'), 'Last night: M42. How did it go?');
  });

  test('√N is never called SNR (SI-003)', () {
    expect(AppWords.relativeStackingGain.toLowerCase(), isNot(contains('snr')));
  });
}
