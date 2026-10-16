import 'package:flutter/material.dart';

import '../../core/theme/app_motion.dart';

/// The one way to show a message (S9.8, TD-081): every `SnackBar` goes
/// through [AppMessages.showMessage], which passes the app's message motion,
/// the normal slide ([AppMotion.medium]), or none when the platform asks for
/// less motion. Flutter shortens a message's entrance only under accessible
/// navigation, not under reduced motion, so the style is passed explicitly.
/// Because every message passes the same style, the messenger's animation
/// controller changes only when that platform setting changes.
/// `test/presentation/shared/app_messages_test.dart` keeps `showSnackBar`
/// out of the rest of `lib/presentation`.
extension AppMessages on ScaffoldMessengerState {
  ScaffoldFeatureController<SnackBar, SnackBarClosedReason> showMessage(
    SnackBar bar,
  ) {
    // The messenger outlives the screen that asked (an Undo, a failed
    // write reported later), so the setting is read from the messenger.
    final d = mounted
        ? AppMotion.duration(context, AppMotion.medium)
        : AppMotion.medium;
    return showSnackBar(
      bar,
      snackBarAnimationStyle: AnimationStyle(duration: d, reverseDuration: d),
    );
  }
}
