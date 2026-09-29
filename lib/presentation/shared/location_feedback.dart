import 'package:flutter/material.dart';

import '../../core/diagnostics/app_log.dart';
import '../../domain/services/location_service.dart';
import '../viewmodels/site_viewmodel.dart';
import 'failure_feedback.dart';
import 'location_failure_text.dart';
import 'app_messages.dart';

/// Shows why the device position is unavailable, with "Open settings" when
/// a settings page fixes it (TASK 7.2).
void showLocationFailure(
  BuildContext context,
  SiteViewModel viewModel,
  LocationFailure reason,
) {
  final target = LocationFailureText.settingsTarget(reason);
  ScaffoldMessenger.of(context).showMessage(
    SnackBar(
      content: Text(LocationFailureText.message(reason)),
      // TD-073, decided in S6.13: a failure the user can fix in settings
      // stays until they act on it or close it; one without an action
      // times out.
      persist: target != null,
      showCloseIcon: target != null,
      duration: const Duration(seconds: 8),
      action: target == null
          ? null
          : SnackBarAction(
              label: 'Open settings',
              onPressed: () => switch (target) {
                LocationSettingsTarget.locationSettings =>
                  viewModel.openLocationSettings(),
                LocationSettingsTarget.appSettings =>
                  viewModel.openAppSettings(),
              },
            ),
    ),
  );
}

/// Makes the device position the transient current position (TASK 7.3
/// "use current position"), explaining a failure.
Future<void> useCurrentPositionWithFeedback(
  BuildContext context,
  SiteViewModel viewModel,
) async {
  try {
    final result = await viewModel.useCurrentLocation();
    if (result case LocationUnavailable(:final reason) when context.mounted) {
      showLocationFailure(context, viewModel, reason);
    }
  } catch (e) {
    AppLog.error('location', 'Could not get the position', error: e);
    if (context.mounted) {
      ScaffoldMessenger.of(context).showMessage(
        SnackBar(content: Text(FailureText.message('get your position', e))),
      );
    }
  }
}
