/// The external light-pollution map, opened at a position (TASK 7.4, PD-05
/// option A; since S7.5 lightpollutionmap.app, RG-09 = M2). The app only
/// links to it; nothing is fetched or scraped. The user reads the value
/// there and enters it as Bortle or SQM (option B). Only the coordinates in
/// the URL leave the device, sent by the browser when the user taps.
abstract final class LightPollutionMapLink {
  /// The map centred on [latitude]/[longitude] (WGS-84 decimal degrees), in
  /// the site's documented link format: `?lat=…&lng=…&zoom=2..18`.
  static Uri at(double latitude, double longitude, {int zoom = 10}) =>
      Uri.parse(
        'https://lightpollutionmap.app/'
        '?lat=${latitude.toStringAsFixed(4)}'
        '&lng=${longitude.toStringAsFixed(4)}'
        '&zoom=${zoom.clamp(2, 18)}',
      );
}
