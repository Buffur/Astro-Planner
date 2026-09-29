import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../core/diagnostics/app_log.dart';
import '../../core/time/clock.dart';
import '../../domain/models/calendar_date.dart';
import '../../domain/models/iana_time_context.dart';
import '../../domain/models/location_profile.dart';
import '../../domain/models/session_night.dart';
import '../../domain/models/site_time_context.dart';
import '../../domain/models/sky_darkness.dart';
import '../../domain/repositories/location_repository.dart';
import '../../domain/repositories/planner_state_repository.dart';
import '../../domain/services/device_time_zone.dart';
import '../../domain/services/location_service.dart';
import '../../domain/services/reverse_geocoder.dart';
import '../../domain/services/session_night_resolver.dart';

/// Where the user is observing from (TASKs 7.1–7.4; split out of the
/// planner ViewModel in TASK 12.3): saved sites, the active one, or a
/// transient position (a map pick or GPS fix — never written into a saved
/// site), its zone, place name and sky darkness.
class SiteViewModel extends ChangeNotifier {
  SiteViewModel({
    required this._locationRepository,
    required this._stateRepository,
    required this._locationService,
    required this._reverseGeocoder,
    required this._deviceTimeZone,
    required this._clock,
  });

  final LocationRepository _locationRepository;
  final PlannerStateRepository _stateRepository;
  final LocationService _locationService;
  final ReverseGeocoder _reverseGeocoder;
  final DeviceTimeZone _deviceTimeZone;
  final Clock _clock;

  /// True until a position is resolved: [latitude]/[longitude] are then a
  /// hard-coded default (London) that must never drive a night (SI-008).
  bool _usingDefaultLocation = true;
  double _latitude = 51.5072;
  double _longitude = -0.1276;
  LocationProfile? _activeSite;
  List<LocationProfile> _sites = const [];
  int? _bortleClass;
  String? _locationName;
  String? _locationNameAttribution;

  bool get isDefaultLocation => _usingDefaultLocation;
  double get latitude => _latitude;
  double get longitude => _longitude;

  /// The active saved site; null when the position is transient.
  LocationProfile? get activeSite => _activeSite;

  /// All saved sites, in insertion order (TASK 7.3).
  List<LocationProfile> get sites => List.unmodifiable(_sites);

  /// Bortle class of the active site (or entered for a transient position),
  /// null when unknown (SI-007).
  int? get bortleClass => _bortleClass;

  /// The site's name, or the place name of a transient position (null
  /// while unknown).
  String? get locationName => _activeSite?.name ?? _locationName;

  /// The attribution the place-name source requires; null with no name.
  String? get locationNameAttribution =>
      _activeSite == null ? _locationNameAttribution : null;

  /// Sky darkness as known here (TASK 7.4): the active site's Bortle/SQM
  /// with sources, a Bortle class entered for a transient position (not
  /// saved), or unknown — never a default.
  SkyDarkness get skyDarkness {
    final site = _activeSite;
    if (site != null) return SkyDarkness.fromSite(site);
    final bortle = _bortleClass;
    if (bortle == null) return SkyDarkness.unknown;
    return SkyDarkness(
      bortleClass: bortle,
      bortleSource: 'user',
      isSaved: false,
    );
  }

  /// The site's time context: its IANA zone when known (TASK 7.1),
  /// otherwise mean solar time (ADR-007 §6). Never the device zone.
  SiteTimeContext get timeContext =>
      IanaTimeContext.tryCreate(_activeSite?.timeZoneId) ??
      MeanSolarTimeContext(_longitude);

  /// The IANA zone times are shown in, or null for the device zone.
  String? get displayZoneId {
    final ctx = timeContext;
    return ctx is IanaTimeContext ? ctx.id : null;
  }

  /// The night of [picked] here (null = tonight), per ADR-007: never from a
  /// date's Y/M/D. Without a site, at the default position (S1.4).
  SessionNight nightAt(CalendarDate? picked) => SessionNightResolver.resolve(
    picked,
    _clock.nowUtc(),
    latitude: _latitude,
    longitude: _longitude,
    timeContext: timeContext,
  );

  /// Today's UTC date from the injected clock (provenance stamps).
  CalendarDate get today => CalendarDate.fromDateTimeFields(_clock.nowUtc());

  /// The device's IANA zone, to pre-fill the site editor only (ADR-007 §6).
  Future<String?> deviceZoneId() => _deviceTimeZone.zoneId();

  /// Restores the active site or the transient position. Startup never
  /// asks for GPS (owner decision, TASK 7.3).
  Future<void> load() async {
    final activeId = await _stateRepository.getActiveLocationId();
    if (activeId != null) {
      final site = await _locationRepository.getLocationById(activeId);
      if (site != null) _apply(site);
    } else {
      final transient = await _stateRepository.getTransientPosition();
      if (transient != null) {
        _latitude = transient.latitude;
        _longitude = transient.longitude;
        _usingDefaultLocation = false;
      }
    }
    _sites = await _locationRepository.getLocations();
    if (_activeSite == null && !_usingDefaultLocation) {
      unawaited(_reverseGeocode(_latitude, _longitude));
    }
    notifyListeners();
  }

  void _apply(LocationProfile site) {
    _activeSite = site;
    _latitude = site.latitude;
    _longitude = site.longitude;
    _bortleClass = site.bortleClass;
    _usingDefaultLocation = false;
  }

  /// Makes the saved site [id] active (persisted across restarts). Does
  /// nothing if no such site exists.
  Future<void> selectSite(int id) async {
    final site = await _locationRepository.getLocationById(id);
    if (site == null) return;
    _apply(site);
    await _stateRepository.setActiveLocationId(site.id);
    notifyListeners();
  }

  /// Saves an explicit user edit of a site (TASK 7.3): `id == 0` inserts a
  /// new site, which becomes active; an edit of the active site applies at
  /// once. Returns the site's id.
  Future<int> saveSite(LocationProfile site) async {
    final int id;
    if (site.id == 0) {
      id = await _locationRepository.insertLocation(site);
    } else {
      id = site.id;
      await _locationRepository.updateLocation(site);
    }
    _sites = await _locationRepository.getLocations();
    if (site.id == 0 || _activeSite?.id == id) {
      await selectSite(id);
    } else {
      notifyListeners();
    }
    return id;
  }

  /// Deletes the saved site [id]. If it was active, its coordinates stay as
  /// the transient position without its zone and sky darkness (owner
  /// decision, TASK 7.3).
  Future<void> deleteSite(int id) async {
    await _locationRepository.deleteLocation(id);
    _sites = await _locationRepository.getLocations();
    final active = _activeSite;
    if (active != null && active.id == id) {
      _activeSite = null;
      _bortleClass = null;
      _locationName = null;
      _locationNameAttribution = null;
      await _stateRepository.clearActiveLocationId();
      await _stateRepository.setTransientPosition(_latitude, _longitude);
      unawaited(_reverseGeocode(_latitude, _longitude));
    }
    notifyListeners();
  }

  /// Sets a **transient** position (TASK 7.1): remembered across restarts,
  /// never written into a saved site; deselects the active site.
  Future<void> setLocation(double lat, double lon) async {
    _latitude = lat;
    _longitude = lon;
    _usingDefaultLocation = false;
    _activeSite = null;
    _bortleClass = null;
    _locationName = null;
    _locationNameAttribution = null;
    await _stateRepository.clearActiveLocationId();
    await _stateRepository.setTransientPosition(lat, lon);
    notifyListeners();
    unawaited(_reverseGeocode(lat, lon));
  }

  /// An explicit user edit of the Bortle class (null = unknown): stored on
  /// the active site with source `user` and today's date, or held in memory
  /// for a transient position.
  Future<void> setBortleClass(int? bortle) async {
    _bortleClass = bortle;
    final site = _activeSite;
    if (site != null) _activeSite = site.withUserBortle(bortle, today);
    notifyListeners();
    if (site != null) await _locationRepository.updateLocation(_activeSite!);
  }

  /// The device position, without using it (the picker previews it).
  Future<LocationResult> locateDevice() =>
      _locationService.getCurrentLocation();

  /// Makes the device position the transient position; on
  /// [LocationUnavailable] nothing changes and the result says why.
  Future<LocationResult> useCurrentLocation() async {
    final result = await locateDevice();
    if (result is LocationFound) {
      await setLocation(result.location.latitude, result.location.longitude);
    }
    return result;
  }

  Future<bool> openLocationSettings() =>
      _locationService.openLocationSettings();

  Future<bool> openAppSettings() => _locationService.openAppSettings();

  /// Place name for the position (TASK 7.2), best-effort; an answer for a
  /// position the user has left is ignored.
  /// Looks the chosen unsaved position's name up again (TASK 16.3); a saved
  /// site shows its own name, and the default position is never looked up.
  void refreshPlaceName() {
    if (_activeSite != null || isDefaultLocation) return;
    unawaited(_reverseGeocode(_latitude, _longitude));
  }

  Future<void> _reverseGeocode(double lat, double lon) async {
    final result = await _reverseGeocoder.placeNameFor(lat, lon);
    if (lat != _latitude || lon != _longitude) return;
    switch (result) {
      case PlaceNameFound(:final name, :final attribution):
        _locationName = name;
        _locationNameAttribution = attribution;
      case PlaceNameNotFound():
        _locationName = null;
        _locationNameAttribution = null;
      case ReverseGeocodeFailed(:final reason):
        _locationName = null;
        _locationNameAttribution = null;
        AppLog.warning('location', 'Reverse geocoding failed: $reason');
    }
    notifyListeners();
  }
}
