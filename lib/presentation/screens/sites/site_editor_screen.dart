import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/config/feature_scope.dart';
import '../../../core/diagnostics/app_log.dart';
import '../../../domain/models/iana_time_context.dart';
import '../../../domain/models/location_profile.dart';
import '../../../domain/services/location_service.dart';
import '../../shared/collapsible_section.dart';
import '../../shared/confirmation_patterns.dart';
import '../../shared/coordinate_input.dart';
import '../../shared/location_feedback.dart';
import '../../shared/site_form_input.dart';
import '../../viewmodels/disclosure_viewmodel.dart';
import '../../viewmodels/site_viewmodel.dart';
import '../../shared/failure_feedback.dart';
import 'zone_picker_dialog.dart';
import '../../navigation/app_router.dart';

/// What the site editor starts from: an existing [site] to edit, or a new
/// site pre-filled with [latitude]/[longitude]/[name] (e.g. "save the
/// current position as a site").
class SiteEditorArgs {
  const SiteEditorArgs({this.site, this.latitude, this.longitude, this.name});

  final LocationProfile? site;
  final double? latitude;
  final double? longitude;
  final String? name;
}

/// Creates or edits a saved site (TASK 7.3). Saving is the explicit user
/// action that writes a site; a new site becomes the active one.
///
/// S7.5 (RG-08 = E2, RG-09 = S3/M2, UX-21): coordinates come from typing,
/// the map or "Use current position" (GPS only on that tap; the fix only
/// fills the form until Save); elevation is optional and unknown when
/// empty; Bortle and SQM sit in a collapsed "Sky darkness (optional)"
/// section with the map link at the typed coordinates; leaving with
/// changes asks Cancel · Discard · Save.
class SiteEditorScreen extends StatefulWidget {
  const SiteEditorScreen({super.key, this.args = const SiteEditorArgs()});

  /// The sky-darkness section's remembered state (DisclosureViewModel).
  static const skyDarknessSection = 'sites.skyDarkness';

  final SiteEditorArgs args;

  @override
  State<SiteEditorScreen> createState() => _SiteEditorScreenState();
}

class _SiteEditorScreenState extends State<SiteEditorScreen> {
  final _formKey = GlobalKey<FormState>();
  late final LocationProfile? _original = widget.args.site;
  late final _name = TextEditingController(
    text: _original?.name ?? widget.args.name,
  );
  late final _latitude = TextEditingController(
    text: _coordinate(_original?.latitude ?? widget.args.latitude),
  );
  late final _longitude = TextEditingController(
    text: _coordinate(_original?.longitude ?? widget.args.longitude),
  );
  late final _elevation = TextEditingController(
    text: _original?.elevation == null ? '' : _trim(_original!.elevation!),
  );
  late final _sqm = TextEditingController(
    text: _original?.sqm == null ? '' : _trim(_original!.sqm!),
  );
  late final _notes = TextEditingController(text: _original?.notes);

  late String? _zoneId = _original?.timeZoneId;
  late int? _bortle = _original?.bortleClass;

  /// True once the zone came from the device, for the caption.
  bool _zoneFromDevice = false;
  bool _zoneTouched = false;
  bool _saving = false;
  bool _locating = false;

  /// Set once the user chose Discard or the site is saved: the page may go.
  bool _leaving = false;

  /// The form as it opened, to tell whether anything was changed (UX-21).
  late final Object _opened = _values();

  Object _values() => (
    _name.text,
    _latitude.text,
    _longitude.text,
    _elevation.text,
    _sqm.text,
    _notes.text,
    _bortle,
    _zoneTouched,
  );

  bool get _changed => _values() != _opened;

  static String _coordinate(double? value) => value?.toStringAsFixed(5) ?? '';

  static String _trim(double value) =>
      value == value.roundToDouble() ? value.toInt().toString() : '$value';

  bool get _isNew => _original == null;

  @override
  void initState() {
    super.initState();
    _opened; // the state before any edit
    if (_isNew) _prefillDeviceZone();
    // The sky-darkness summary and the map link follow the typing.
    for (final c in [_latitude, _longitude, _sqm]) {
      c.addListener(_refresh);
    }
  }

  void _refresh() {
    if (mounted) setState(() {});
  }

  /// A new site's zone defaults to the device zone (owner decision, TASK
  /// 7.3) — only as a pre-filled choice the user can change.
  Future<void> _prefillDeviceZone() async {
    final zone = await context.read<SiteViewModel>().deviceZoneId();
    if (!mounted || _zoneTouched) return;
    if (IanaTimeContext.tryCreate(zone) == null) return;
    setState(() {
      _zoneId = zone;
      _zoneFromDevice = true;
    });
  }

  @override
  void dispose() {
    for (final c in [_name, _latitude, _longitude, _elevation, _sqm, _notes]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _pickZone() async {
    final choice = await showZonePicker(context, current: _zoneId);
    if (choice == null || !mounted) return;
    setState(() {
      _zoneId = choice.zoneId;
      _zoneTouched = true;
      _zoneFromDevice = false;
    });
  }

  Future<void> _pickOnMap() async {
    final lat = CoordinateInput.parse(_latitude.text);
    final lon = CoordinateInput.parse(_longitude.text);
    final start = (lat != null && lon != null && lat.abs() <= 90)
        ? LatLng(lat, lon)
        : null;
    final point = await context.push<LatLng>(AppRouter.sitePick, extra: start);
    if (point == null || !mounted) return;
    setState(() {
      _latitude.text = _coordinate(point.latitude);
      _longitude.text = _coordinate(point.longitude);
    });
  }

  /// "Use current position" (S7.5): the device position fills the
  /// coordinates, asked for only on this tap; nothing is stored until Save
  /// (trap 2: a GPS fix is transient).
  Future<void> _useCurrentPosition() async {
    final siteVm = context.read<SiteViewModel>();
    setState(() => _locating = true);
    try {
      final result = await siteVm.locateDevice();
      if (!mounted) return;
      switch (result) {
        case LocationFound(:final location):
          _latitude.text = _coordinate(location.latitude);
          _longitude.text = _coordinate(location.longitude);
        case LocationUnavailable(:final reason):
          showLocationFailure(context, siteVm, reason);
      }
    } catch (e) {
      AppLog.error('location', 'Could not get the position', error: e);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(FailureText.message('get your position', e))),
        );
      }
    } finally {
      if (mounted) setState(() => _locating = false);
    }
  }

  Future<void> _openMap() async {
    final url = SiteFormInput.mapLink(_latitude.text, _longitude.text);
    if (url == null) return;
    try {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } catch (e) {
      AppLog.error('sites', 'Could not open the light-pollution map', error: e);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(FailureText.message('open the map', e))),
        );
      }
    }
  }

  /// Back with changes (UX-21, S5.8's prompt): Cancel stays, Discard leaves,
  /// Save saves and leaves when it succeeds.
  Future<void> _onBack() async {
    final label = _name.text.trim().isEmpty
        ? (_isNew ? 'New site' : _original!.name)
        : _name.text.trim();
    final choice = await askUnsavedChanges(context, plan: label);
    if (!mounted) return;
    switch (choice) {
      case UnsavedChoice.cancel:
        return;
      case UnsavedChoice.discard:
        setState(() => _leaving = true);
        context.pop();
      case UnsavedChoice.save:
        await _save();
    }
  }

  Future<void> _save() async {
    // A hidden (collapsed) SQM field is not validated by the form: open the
    // section so the message shows next to the value.
    if (SiteFormInput.validateSqm(_sqm.text) != null) {
      await context.read<DisclosureViewModel>().setOpen(
        SiteEditorScreen.skyDarknessSection,
        true,
      );
      await WidgetsBinding.instance.endOfFrame;
    }
    if (!mounted || !_formKey.currentState!.validate()) return;
    final siteVm = context.read<SiteViewModel>();
    final LocationProfile site;
    try {
      site = LocationProfile.userEdit(
        original: _original,
        name: _name.text.trim(),
        latitude: CoordinateInput.parse(_latitude.text)!,
        longitude: CoordinateInput.parse(_longitude.text)!,
        elevation: CoordinateInput.parse(_elevation.text),
        timeZoneId: _zoneId,
        notes: SiteFormInput.optionalText(_notes.text),
        bortleClass: _bortle,
        sqm: CoordinateInput.parse(_sqm.text),
        today: siteVm.today,
      );
    } on ArgumentError catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Invalid site: ${e.message}')));
      return;
    }
    setState(() => _saving = true);
    final saved = await runWithFeedback(
      context,
      'save the site',
      () => siteVm.saveSite(site),
    );
    if (!mounted) return;
    if (saved) {
      setState(() => _leaving = true);
      context.pop();
    } else {
      setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    const numberKeyboard = TextInputType.numberWithOptions(
      signed: true,
      decimal: true,
    );
    return PopScope(
      canPop: _leaving || !_changed,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _onBack();
      },
      child: _form(context, numberKeyboard),
    );
  }

  Widget _form(BuildContext context, TextInputType numberKeyboard) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isNew ? 'New site' : 'Edit site'),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            tooltip: 'Save site',
            onPressed: _saving ? null : _save,
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _name,
              decoration: const InputDecoration(labelText: 'Name'),
              textCapitalization: TextCapitalization.words,
              validator: SiteFormInput.validateName,
            ),
            TextFormField(
              controller: _latitude,
              decoration: const InputDecoration(
                labelText: 'Latitude (°)',
                helperText: 'Decimal degrees, north positive',
              ),
              keyboardType: numberKeyboard,
              validator: CoordinateInput.validateLatitude,
            ),
            TextFormField(
              controller: _longitude,
              decoration: const InputDecoration(
                labelText: 'Longitude (°)',
                helperText: 'Decimal degrees, east positive',
              ),
              keyboardType: numberKeyboard,
              validator: CoordinateInput.validateLongitude,
            ),
            Wrap(
              spacing: 8,
              children: [
                TextButton.icon(
                  key: const Key('siteEditor.useCurrentPosition'),
                  onPressed: _locating ? null : _useCurrentPosition,
                  icon: const Icon(Icons.my_location),
                  label: const Text('Use current position'),
                ),
                TextButton.icon(
                  onPressed: _pickOnMap,
                  icon: const Icon(Icons.map_outlined),
                  label: const Text('Pick on map'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.schedule),
              title: const Text('Time zone'),
              subtitle: Text(
                _zoneId == null
                    ? 'Unknown — night uses mean solar time'
                    : _zoneFromDevice
                    ? '$_zoneId (device zone)'
                    : _zoneId!,
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: _pickZone,
            ),
            // RG-08 = E2: optional, without prominence; empty is unknown.
            TextFormField(
              controller: _elevation,
              decoration: const InputDecoration(
                labelText: 'Elevation (m)',
                helperText:
                    'Optional · metres above sea level; empty is '
                    'unknown',
              ),
              keyboardType: numberKeyboard,
              validator: SiteFormInput.validateElevation,
            ),
            if (FeatureScope.lightPollutionContext) _skyDarknessSection(),
            TextFormField(
              controller: _notes,
              decoration: const InputDecoration(labelText: 'Notes'),
              maxLines: 3,
            ),
          ],
        ),
      ),
    );
  }

  /// Bortle and SQM (RG-09 = S3): one collapsed, remembered section whose
  /// summary states what is stored; each value with its source and date;
  /// the map at the typed coordinates. Unknown by default, no conversion.
  Widget _skyDarknessSection() {
    final sqm = CoordinateInput.parse(_sqm.text);
    final summary = [
      if (_bortle != null) 'Bortle $_bortle',
      if (sqm != null) 'SQM ${_sqm.text.trim()}',
    ];
    final link = SiteFormInput.mapLink(_latitude.text, _longitude.text);
    return CollapsibleSection(
      sectionKey: SiteEditorScreen.skyDarknessSection,
      title: 'Sky darkness (optional)',
      summary: summary.isEmpty ? 'Unknown' : summary.join(' · '),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ..._skyDarknessFields(),
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
              key: const Key('siteEditor.mapLink'),
              onPressed: link == null ? null : _openMap,
              icon: const Icon(Icons.open_in_new),
              label: const Text('Look it up on the light-pollution map'),
            ),
          ),
        ],
      ),
    );
  }

  /// Bortle and SQM with their source (TASK 7.3); a hidden value is kept
  /// unchanged on save.
  List<Widget> _skyDarknessFields() {
    final original = _original;
    String? sourceCaption(String? source, Object? date) => source == null
        ? null
        : 'Source: $source${date == null ? '' : ', $date'}';
    return [
      DropdownButtonFormField<int?>(
        initialValue: _bortle,
        decoration: InputDecoration(
          labelText: 'Bortle class',
          helperText: _bortle != null && _bortle == original?.bortleClass
              ? sourceCaption(
                  original?.bortleSource,
                  original?.bortleDate?.toIso8601String(),
                )
              : null,
        ),
        items: [
          const DropdownMenuItem(value: null, child: Text('Unknown')),
          for (var b = 1; b <= 9; b++)
            DropdownMenuItem(value: b, child: Text('Bortle $b')),
        ],
        onChanged: (value) => setState(() => _bortle = value),
      ),
      TextFormField(
        controller: _sqm,
        decoration: InputDecoration(
          labelText: 'SQM (mag/arcsec²)',
          helperText:
              sourceCaption(
                original?.sqmSource,
                original?.sqmDate?.toIso8601String(),
              ) ??
              'Empty = unknown',
        ),
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        validator: SiteFormInput.validateSqm,
      ),
    ];
  }
}
