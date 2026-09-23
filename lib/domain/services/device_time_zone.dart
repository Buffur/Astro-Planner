/// Source of the device's IANA time zone id (TASK 7.3).
///
/// Used **only** to pre-fill the site editor's zone picker (ADR-007 §6: the
/// device zone is never used in a computation). The platform call lives in
/// an implementation, so ViewModels and tests never depend on it.
abstract class DeviceTimeZone {
  /// The device's IANA zone id (e.g. `Europe/Ljubljana`), or null when the
  /// platform cannot report one. Never throws.
  Future<String?> zoneId();
}
