/// The external light-pollution map, opened at a position (TASK 7.4, PD-05
/// option A). The app only links to it; nothing is fetched or scraped. The
/// user reads the value there and enters it as Bortle or SQM (option B).
abstract final class LightPollutionMapLink {
  /// The map's view settings (base map, 2025 sky-brightness overlay,
  /// opacities), as the previous hard-coded link carried them.
  static const String _state =
      'eyJiYXNlbWFwIjoiTGF5ZXJCaW5nUm9hZCIsIm92ZXJsYXkiOiJzYl8yMDI1Iiwib3Zlcmxh'
      'eWNvbG9yIjpmYWxzZSwib3ZlcmxheW9wYWNpdHkiOiI2MCIsImZlYXR1cmVzb3BhY2l0eSI6'
      'Ijg1In0=';

  /// The map centred on [latitude]/[longitude] (decimal degrees, WGS-84).
  static Uri at(double latitude, double longitude, {double zoom = 10}) =>
      Uri.parse(
        'https://www.lightpollutionmap.info/#zoom=${zoom.toStringAsFixed(2)}'
        '&lat=${latitude.toStringAsFixed(4)}'
        '&lon=${longitude.toStringAsFixed(4)}'
        '&state=$_state',
      );
}
