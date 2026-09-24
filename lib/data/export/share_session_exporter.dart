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
    final stamp = now.toIso8601String().substring(0, 16).replaceAll(':', '');
    final dir = await getTemporaryDirectory();
    final file = File(p.join(dir.path, 'astroplan-sessions-$stamp.json'));
    await file.writeAsString(json);
    await SharePlus.instance.share(
      ShareParams(
        files: [XFile(file.path, mimeType: 'application/json')],
        text: summary(sessions),
      ),
    );
  }

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
