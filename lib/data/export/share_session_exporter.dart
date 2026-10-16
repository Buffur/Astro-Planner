import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../core/config/app_identity.dart';
import '../../core/time/clock.dart';
import '../../domain/services/session_exporter.dart';
import 'session_manifest_codec.dart';

/// Writes a manifest v2 file to the app's temporary folder and hands it to
/// the platform share sheet with a short text summary (TASK 14.3).
class ShareSessionExporter implements SessionExporter {
  ShareSessionExporter({this._clock = const SystemClock()});

  final Clock _clock;

  @override
  Future<void> share(List<ExportedSession> sessions) async {
    final now = _clock.nowUtc();
    final json = const JsonEncoder.withIndent('  ').convert(
      SessionManifestCodec.encode(
        sessions,
        exportedAtUtc: now,
        appVersion: AppIdentity.version,
      ),
    );
    final dir = await getTemporaryDirectory();
    final file = File(p.join(dir.path, fileName(sessions, now)));
    await file.writeAsString(json);
    await SharePlus.instance.share(
      ShareParams(
        files: [XFile(file.path, mimeType: 'application/json')],
        text: shareText(sessions, now),
      ),
    );
  }

  /// The file's name (S9.8), in the device's local date and time: the whole
  /// Logbook `astroplan-logbook-2026-09-29-2130.json`, one entry
  /// `astroplan-entry-2026-09-29-2130.json`.
  static String fileName(List<ExportedSession> sessions, DateTime nowUtc) =>
      'astroplan-${sessions.length == 1 ? 'entry' : 'logbook'}-'
      '${localFileStamp(nowUtc)}.json';

  /// "2026-09-29-2130": [utc] on the device's clock, sortable (S9.8).
  static String localFileStamp(DateTime utc) {
    final t = utc.toLocal();
    String two(int n) => n.toString().padLeft(2, '0');
    return '${t.year}-${two(t.month)}-${two(t.day)}-${two(t.hour)}${two(t.minute)}';
  }

  /// "2026-09-29-2130 (UTC+02:00)": the file's stamp with the device's
  /// offset, so a reader elsewhere knows its zone (S9.8, TD-091).
  static String localStampWithOffset(DateTime utc) {
    final offset = utc.toLocal().timeZoneOffset;
    final sign = offset.isNegative ? '−' : '+';
    final h = offset.inHours.abs().toString().padLeft(2, '0');
    final m = (offset.inMinutes.abs() % 60).toString().padLeft(2, '0');
    return '${localFileStamp(utc)} (UTC$sign$h:$m)';
  }

  /// The share sheet's text: the summary and when it was exported.
  static String shareText(List<ExportedSession> sessions, DateTime nowUtc) =>
      '${summary(sessions)} Exported ${localStampWithOffset(nowUtc)}.';

  /// "Astro Planner export: 3 sessions (M42, M31, …)".
  static String summary(List<ExportedSession> sessions) {
    final names = sessions.map((e) => e.session.record.targetName).toSet();
    final shown = names.take(3).join(', ');
    final more = names.length > 3 ? ', …' : '';
    final n = sessions.length;
    return '${AppIdentity.appName} export: $n ${n == 1 ? 'session' : 'sessions'} '
        '($shown$more). Manifest v${SessionManifestCodec.version}.';
  }
}
