import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';

import '../../../core/config/feature_scope.dart';
import '../../../domain/models/iana_time_context.dart';
import '../../../domain/models/location_profile.dart';
import '../../shared/coordinate_input.dart';
import '../../shared/site_form_input.dart';
import '../../viewmodels/site_viewmodel.dart';
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
class SiteEditorScreen extends StatefulWidget {
  const SiteEditorScreen({super.key, this.args = const SiteEditorArgs()});

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
    text: _original == null ? '' : _trim(_original.elevation),
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

  static String _coordinate(double? value) => value?.toStringAsFixed(5) ?? '';

  static String _trim(double value) =>
      value == value.roundToDouble() ? value.toInt().toString() : '$value';

  bool get _isNew => _original == null;

  @override
  void initState() {
    super.initState();
    if (_isNew) _prefillDeviceZone();
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

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final siteVm = context.read<SiteViewModel>();
    final LocationProfile site;
    try {
      site = LocationProfile.userEdit(
        original: _original,
        name: _name.text.trim(),
        latitude: CoordinateInput.parse(_latitude.text)!,
        longitude: CoordinateInput.parse(_longitude.text)!,
        elevation: CoordinateInput.parse(_elevation.text)!,
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
    await siteVm.saveSite(site);
    if (mounted) context.pop();
  }

  @override
  Widget build(BuildContext context) {
    const numberKeyboard = TextInputType.numberWithOptions(
      signed: true,
      decimal: true,
    );
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
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                onPressed: _pickOnMap,
                icon: const Icon(Icons.map_outlined),
                label: const Text('Pick on map'),
              ),
            ),
            TextFormField(
              controller: _elevation,
              decoration: const InputDecoration(
                labelText: 'Elevation (m)',
                helperText: 'Metres above sea level',
              ),
              keyboardType: numberKeyboard,
              validator: SiteFormInput.validateElevation,
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
            if (FeatureScope.lightPollutionContext) ..._skyDarknessFields(),
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

  /// Bortle and SQM with their source (TASK 7.3), hidden with the rest of
  /// the light-pollution context until TASK 7.4 (PD-06). Hidden values are
  /// kept unchanged on save.
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
