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
  /// keeping the saved value is the default).
  final Map<int, Set<EquipmentSpec>> _taken = {};

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

  /// Matches [candidate] against the saved rigs again, after a rig was
  /// saved from this screen.
  Future<void> refreshMatch() async {
    final candidate = _candidate;
    if (candidate == null) return;
    _match = EquipmentMatcher.match(
      candidate,
      await _equipment.getAllEquipment(),
    );
    _taken.removeWhere((id, _) => !_match!.rigs.any((r) => r.rig.id == id));
    notifyListeners();
  }

  /// Whether the user chose the file's value for [spec] on [rig].
  bool takesImported(EquipmentProfile rig, EquipmentSpec spec) =>
      _taken[rig.id]?.contains(spec) ?? false;

  void setTakesImported(EquipmentProfile rig, EquipmentSpec spec, bool take) {
    final specs = _taken.putIfAbsent(rig.id, () => {});
    take ? specs.add(spec) : specs.remove(spec);
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
