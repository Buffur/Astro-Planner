/// The app's words (S5.3; RD-14, ADR-019 §10): one name per concept, as the
/// owner's glossary sets them (`docs/refinement/research/
/// S4.R5_LIBRARY_AND_VOCABULARY.md` §5). Screens use these instead of
/// writing a term themselves, like `QuantityText` for numbers.
/// `test/presentation/shared/retired_terms_test.dart` keeps the retired
/// terms out of `lib/presentation`. Words only; no formatting of values.
abstract final class AppWords {
  // A camera plus lens or telescope (ADR-011's flat profile).
  static const rig = 'Rig';
  static const rigs = 'Rigs';
  static const addRig = 'Add rig';
  static const chooseRig = 'Choose a rig';

  // What the user makes and saves in the planner.
  static const plan = 'Plan';
  static const newPlan = 'New plan';
  static const savePlan = 'Save plan';
  static const yourPlan = 'Your plan';
  static const copyToAnotherNight = 'Copy to another night';

  /// The tab holding saved plans and their results.
  static const logbook = 'Logbook';

  /// A plan's night ("Night of Fri 14 Nov" where needed; the date comes
  /// from `NightTimeFormatter`).
  static const night = 'Night';
  static const nightOf = 'Night of';

  // The capture blocks.
  static const capturePlan = 'Capture plan';
  static const block = 'block';

  // A plan's state (RD-05); the stored statuses stay internal.
  static const notSaved = 'Not saved';
  static const saved = 'Saved';
  static const savedChanged = 'Saved · changed';

  // A plan's result (RG-04).
  static const tracking = 'Tracking';
  static const completed = 'Completed';
  static const partly = 'Partly';
  static const notDone = 'Not done';
  static const oldLog = 'Old log';

  // Recording the outcome and the optional live mode (RG-04).
  static const recordResult = 'Record result';
  static const editResult = 'Edit result';
  static const trackLive = 'Track live';
  static const trackLiveOptional = 'Track live (optional)';
  static const completedAsPlanned = 'Completed as planned';

  /// Tonight's line after a saved night (ADR-019 §4).
  static String howDidItGo(String target) =>
      'Last night: $target. How did it go?';

  // The verdict (RD-06): the status headline's first word.
  static const fits = 'Fits';
  static const tight = 'Tight';
  static const doesNotFit = "Doesn't fit";
  static const noWindow = 'No window';
  static const needsTarget = 'Needs a target';
  static const needsBlock = 'Needs a block';

  /// The status headline: "Fits: 2 h 05 min needed of 4 h 20 min usable".
  /// [needed] and [usable] come already formatted (`QuantityText`).
  static String headline(String verdict, String needed, String usable) =>
      '$verdict: $needed needed of $usable usable';

  // The dark period and the windows (the user's darkness limit goes with
  // the times, never in the name).
  static const dark = 'Dark';
  static const darknessLimit = 'Darkness limit';
  static const imagingWindow = 'Imaging window';

  // The standard twilight names: only on the Night & Moon detail.
  static const civilDusk = 'Civil dusk';
  static const nauticalDusk = 'Nautical dusk';
  static const astronomicalDusk = 'Astronomical dusk';
  static const civilDawn = 'Civil dawn';
  static const nauticalDawn = 'Nautical dawn';
  static const astronomicalDawn = 'Astronomical dawn';

  // The capture budget (ADR-009's lines; RD-14's names).
  static const integration = 'Integration';
  static const imagingTime = 'Imaging time';
  static const timeNeeded = 'Time needed';
  static const totalTime = 'Total time';
  static const budgetDetails = 'Budget details';

  /// √N versus one frame, relative only (SI-003); never "SNR".
  static const relativeStackingGain =
      'Relative stacking gain (√N vs one frame)';

  // Places, reusable things and history.
  static const site = 'Site';
  static const library = 'Library';
  static const progressByTarget = 'Progress by target';

  // Files and names.
  static const exportAsFile = 'Export as file';
  static const exportAllAsFile = 'Export all as file';
  static const nameOptional = 'Name (optional)';
}
