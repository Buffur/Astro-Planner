import 'package:flutter/widgets.dart';

/// The motion scale (S5.2): short, subtle transitions only
/// (`.agents/rules/05-ui-design.md`). Every animated component asks
/// [duration] for its length, so the platform's reduced-motion setting
/// turns motion off. See `docs/DESIGN_SYSTEM.md`.
abstract final class AppMotion {
  /// A state change in place: a pressed control, a chevron turning.
  static const Duration short = Duration(milliseconds: 150);

  /// Content appearing or collapsing: a section opening, a row leaving.
  static const Duration medium = Duration(milliseconds: 250);

  /// The one curve: fast out, gentle in.
  static const Curve curve = Curves.easeOutCubic;

  /// [base], or zero when the user asked the platform for less motion.
  static Duration duration(BuildContext context, Duration base) =>
      MediaQuery.maybeDisableAnimationsOf(context) ?? false
      ? Duration.zero
      : base;
}
