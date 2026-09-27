/// Corner radii (S5.1), in logical pixels. One scale for the whole app;
/// see `docs/DESIGN_SYSTEM.md`.
abstract final class AppRadius {
  /// Cards, sections, text fields and buttons.
  static const double small = 6;

  /// Dialogs, bottom sheets and a swiped row's background.
  static const double large = 12;

  /// Pills and chips.
  static const double pill = 999;
}
