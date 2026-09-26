import 'package:flutter/foundation.dart';

import '../../domain/equipment_import/equipment_candidate.dart';
import '../../domain/equipment_import/equipment_matcher.dart';
import '../../domain/metadata/capture_file_access.dart';
import '../../domain/metadata/capture_metadata.dart';
import '../../domain/metadata/capture_metadata_reader.dart';
import '../../domain/metadata/metadata_source.dart';
import '../../domain/models/equipment_profile.dart';
import '../../domain/models/spec_provenance.dart';
import '../../domain/repositories/equipment_repository.dart';
import '../shared/equipment_draft.dart';

/// The metadata import (F-45; ADR-017 §10, ADR-018 §2): the user picks one
/// capture file, sees the metadata contract read from it, and the equipment
/// it proposes matched against the saved rigs (S3.6). Nothing is stored
/// here: a rig is written only by the editor's Save.
class MetadataImportViewModel extends ChangeNotifier {
  MetadataImportViewModel(this._files, this._equipment);

  final CaptureFileAccess _files;
  final EquipmentRepository _equipment;
  bool _busy = false;
  String? _fileName;
  MetadataReading? _reading;
  EquipmentCandidate? _candidate;
  EquipmentMatch? _match;

  /// Conflicts where the user chose the file's value, per rig (ADR-018 §6:
  /// keeping the saved value is the default), each with the saved value the
  /// choice was made against. A choice whose saved value has changed since
  /// is withdrawn (S3.V1): it never replaces a newer edit.
  final Map<int, Map<EquipmentSpec, Object>> _taken = {};

  bool get busy => _busy;

  /// The name of the file last read, when the provider gave one.
  String? get fileName => _fileName;

  /// The last reading, or null before the first file.
  MetadataReading? get reading => _reading;

  /// The equipment the last readable file proposes; null otherwise.
  EquipmentCandidate? get candidate => _candidate;

  /// [candidate] against the saved rigs; null until matched.
  EquipmentMatch? get match => _match;

  /// Picks a file and reads it. A cancel changes nothing. A failure to open
  /// the picker, or to read the saved rigs, is thrown (the screen reports
  /// it); a file that cannot be opened or read becomes a
  /// [MetadataUnreadable] reading.
  Future<void> pickAndRead() async {
    _busy = true;
    notifyListeners();
    try {
      final file = await _files.pick();
      if (file == null) return;
      _fileName = file.name;
      final (reading, length) = await _readFile(file);
      _reading = reading;
      _candidate = switch (reading) {
        final MetadataRead read => EquipmentCandidate.fromReading(
          read,
          fileLengthBytes: length,
        ),
        _ => null,
      };
      _match = null;
      _taken.clear();
      await refreshMatch();
    } finally {
      _busy = false;
      notifyListeners();
    }
  }

  /// Matches [candidate] against the saved rigs as they are now (S3.V1):
  /// whenever the review is shown, before a rig is opened from it, and after
  /// a save. Choices made against values that have since changed, or on rigs
  /// that are gone, are withdrawn.
  Future<void> refreshMatch() async {
    final candidate = _candidate;
    if (candidate == null) return;
    final match = EquipmentMatcher.match(
      candidate,
      await _equipment.getAllEquipment(),
    );
    _match = match;
    _taken.removeWhere((id, choices) {
      final rig = match.rigs.where((r) => r.rig.id == id).firstOrNull;
      if (rig == null) return true;
      choices.removeWhere((spec, savedThen) {
        final c = rig.conflicts.where((c) => c.spec == spec).firstOrNull;
        return c == null || !_sameValue(c.saved, savedThen);
      });
      return choices.isEmpty;
    });
    notifyListeners();
  }

  /// The match for rig [rigId] against the saved rigs as they are now, or
  /// null when it no longer relates to the file (changed or deleted).
  Future<RigMatch?> currentMatchFor(int rigId) async {
    await refreshMatch();
    return _match?.rigs.where((r) => r.rig.id == rigId).firstOrNull;
  }

  static bool _sameValue(Object a, Object b) => a is List && b is List
      ? a.length == b.length &&
            [for (var i = 0; i < a.length; i++) a[i] == b[i]].every((s) => s)
      : a == b;

  /// Whether the user chose the file's value for [spec] on [rig].
  bool takesImported(EquipmentProfile rig, EquipmentSpec spec) =>
      _taken[rig.id]?.containsKey(spec) ?? false;

  void setTakesImported(EquipmentProfile rig, EquipmentSpec spec, bool take) {
    final conflict = _match?.rigs
        .where((r) => r.rig.id == rig.id)
        .firstOrNull
        ?.conflicts
        .where((c) => c.spec == spec)
        .firstOrNull;
    final choices = _taken.putIfAbsent(rig.id, () => {});
    if (take && conflict != null) {
      choices[spec] = conflict.saved;
    } else {
      choices.remove(spec);
    }
    notifyListeners();
  }

  /// A new rig from the file, optionally with a saved rig's camera specs
  /// (ADR-018 §6, "same camera, other optics").
  EquipmentDraft newRigDraft({EquipmentProfile? cameraFrom}) =>
      EquipmentDraft.fromCandidate(_candidate!, cameraFrom: cameraFrom);

  /// The matched rig for editing, with the file's values the user chose,
  /// and the file's value for any spec the rig does not know (the RAW size,
  /// ADR-018 §6): shown with its origin, never replacing a saved value.
  EquipmentDraft rigDraft(RigMatch m) => EquipmentDraft.forRig(m.rig, {
    for (final c in m.conflicts)
      if (takesImported(m.rig, c.spec))
        c.spec: (value: c.imported, provenance: c.importedProvenance),
    for (final spec in m.fillable) spec: ?_fillValue(spec),
  });

  ({Object value, SpecProvenance provenance})? _fillValue(EquipmentSpec s) =>
      switch ((s, _candidate?.averageRawFileSizeMB)) {
        (
          EquipmentSpec.rawFileSize,
          ProposedField(:final value, :final source, :final confidence),
        ) =>
          (value: value, provenance: SpecProvenance(source, confidence)),
        _ => null,
      };

  /// The reading and the file's length (S3.8: a DNG's length is its RAW
  /// size; the file itself is never read whole).
  static Future<(MetadataReading, int?)> _readFile(CaptureFile file) async {
    final MetadataSource source;
    try {
      source = await file.open();
    } on MetadataReadException catch (e) {
      return (MetadataUnreadable.fromReadFailure(e), null);
    }
    try {
      return (await CaptureMetadataReader.read(source), source.length);
    } finally {
      await source.close();
    }
  }
}
