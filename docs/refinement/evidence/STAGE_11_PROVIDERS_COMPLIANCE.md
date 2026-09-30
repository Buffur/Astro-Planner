# Stage 11 — Live providers and compliance (S11.4)

> **Date:** 2026-09-30 (host clock; UTC times given where they matter). **Commit:** `9668a13`
> (working tree clean apart from documentation). **Scope:** the rows of `STAGE_11_MATRIX.md` whose
> Task is S11.4 — G6, N10, O1–O9, Q2 — per `POST_ROADMAP_PLAN.md` "S11.4 — Live providers and
> compliance". Evidence only: no code changed. `COMPLIANCE.md` re-checked, its stamp refreshed and
> three statements corrected (§5). Toolchain for the dependency listing: Flutter 3.47.4 / Dart
> 3.13.3 (`C:\tools\flutter-3.47.4`, the CI's pinned version); `pubspec.lock` unchanged.

## 1. Environment and its limit

- **Emulator:** the S11.3 AVD (`sdk_gphone64_x86_64`, API 36), with the S11.3 release build installed
  (`versionName 1.0.0`, `versionCode 4001`, `targetSdk 36`).
- **TLS interception on this machine.** The host runs an antivirus that intercepts HTTPS with its own
  root certificate, which Android does not trust. Observed on the emulator, 2026-09-30:
  - the OS's own connectivity probe: `NetworkMonitor … PROBE_HTTPS https://www.google.com/generate_204
    Probe failed … SSLHandshakeException: … Trust anchor for certification path not found`;
  - the app, on opening the map picker: `I flutter : HandshakeException: Handshake error in client
    (OS Error: CERTIFICATE_VERIFY_FAILED: unable to get local issuer certificate)` (one per tile);
  - Tonight's weather row: "No forecast. Offline or the service did not answer."
  No certificate or security setting was changed (not allowed). **So no live provider answer can be
  observed from the emulator on this machine**; the emulator rows are UNVERIFIED here and carried to
  the owner's phone (S11.6).
- **Chrome on the emulator** opens its first-run screen (Google's terms) on every link; accepting
  those terms needs the owner's permission, so it was not done and no linked page was rendered. The
  intent each link sends is visible in `ActivityTaskManager` (Android redacts the path and query, so
  only the scheme and host are observable).
- **Emulator clock** reads Fri 2 Oct 2026 02:19 GMT while the host is Wed 30 Sep 07:35 UTC (≈ 1 d 19 h
  ahead) — see S11P-07.
- **Host requests.** From the host (`curl.exe`, which trusts the Windows store) one request each
  mirrored exactly what the app sends: same endpoint, parameters and `User-Agent`
  (`Astro Planner/1.0.0 (+https://chacha12.github.io/astro-planner/; io.github.chacha12.astroplanner)`,
  `AppIdentity.userAgent`). Nominatim: one request; OSM: one tile. This is host evidence of the
  request contract, not of the app's runtime.

## 2. Per-row results

| Row | Result | Evidence | Level reached |
| --- | --- | --- | --- |
| **G6** About's links from the emulator | **UNVERIFIED** (partial) — carried to S11.6 | Emulator: each About link sends a `VIEW` intent from the app (uid 10230) to Chrome with the intended host: `www.reddit.com`, `github.com` (author), `github.com` (OpenNGC), `www.openstreetmap.org`, `open-meteo.com`, `lightpollutionmap.app`, `chacha12.github.io` (privacy policy), `github.com` (source); 02:20–02:23 emulator time. Pages not rendered (Chrome first-run not accepted; TLS interception). Host (07:33 UTC): `reddit.com/user/Buffur/`, `github.com/Buffur`, `github.com/mattiaverga/OpenNGC`, `openstreetmap.org/copyright`, `open-meteo.com`, `lightpollutionmap.app` → 200; **project `chacha12.github.io/astro-planner/`, privacy `…/privacy/` and source `github.com/chacha12/astro-planner` → 404** (TD-088, RD-01 → OWNER, N7) | Intent host RUNTIME (emulator); page load HOST only |
| **N10** Target API and 16 KB re-checked against Play | **PASS** | §7: new apps and updates must target API 36 from 31 Aug 2026 (extension to 1 Nov 2026); the build targets 36 (merged release manifest `targetSdkVersion="36"`, `RELEASE.md`). 16 KB: apps with native code must support 16 KB pages (Play Console technical quality requirements); updates that don't cannot be released from 1 Feb 2027 (Android Developers). The app ships native libraries (`libflutter.so`, `libapp.so`, `libsqlite3.so`, `libdartjni.so`, `libdatastore_shared_counter.so`), all 16 KB aligned per N3 (`tool/check_bundle.dart`, S11.3). `RELEASE.md`'s statement stands | DOCUMENTED (cited, dated) |
| **O1** Open-Meteo live from the emulator | **UNVERIFIED** — carried to S11.6 | Emulator: "No forecast. Offline or the service did not answer." (TLS). Host: `GET https://api.open-meteo.com/v1/forecast?latitude=46.05&longitude=14.5&hourly=cloud_cover,…,visibility&models=best_match&timeformat=unixtime&start_hour=2026-09-30T17:00&end_hour=2026-10-01T04:00` with the app's UA → **200**, `application/json`, 0.29 s; body has `hourly.time` as integers (unix) and every variable the parser reads, 12 hours; `hourly_units` km/h, °C, m, % — the units the parser assumes. Code: UA header (`open_meteo_weather_repository.dart`), cache reused under 3 h (`NightWeatherService`, `WeatherFreshness.agingAfter`); attribution on the weather card (`weather_forecast_widget.dart`) and About (observed on the emulator: "Weather data by Open-Meteo.com (CC BY 4.0)") | HOST (contract) + CODE; runtime not reached |
| **O2** Nominatim live | **UNVERIFIED** — carried to S11.6; one FOLLOW-UP (S11P-01) | Emulator: not reachable (TLS). Host: `GET https://nominatim.openstreetmap.org/reverse?lat=46.05&lon=14.5&format=jsonv2&zoom=10&accept-language=en` with the app's UA → **200**, JSON, 0.44 s, `x-nominatim-server` present, no block. **The answer's `address` holds `municipality` ("Ljubljana") and `country` only**; the app reads `city ?? town ?? village ?? county ?? state`, so this point would get **no name** (S11P-01). Code and host tests: off by default and nothing sent while off (`OptInReverseGeocoder`; `place_name_lookup_test.dart` "off: a chosen position is never sent"); ≤ 1 request/s, serialized (`nominatim_reverse_geocoder_test.dart`); rounded to 0.01°; never for a saved site or the default position (`SiteViewModel.refreshPlaceName`, `_reverseGeocode` callers); attribution with each name | HOST (contract) + CODE/TEST; runtime not reached |
| **O3** OSM tiles live | **UNVERIFIED** (partial) — carried to S11.6 | Emulator: the map picker shows the attribution "flutter_map \| © OpenStreetMap contributors" (bottom left); tiles stay grey — each tile request fails with `CERTIFICATE_VERIFY_FAILED`, which also shows the app requests only the visible tiles (a handful, at open). Host: `GET https://tile.openstreetmap.org/5/15/10.png` (the picker's initial view) with the app's UA → **200**, `image/png`, 29 627 bytes, `cache-control: max-age=519624, stale-while-revalidate=604800`. Code: `TileLayer` with `NetworkTileProvider(headers: {'User-Agent': AppIdentity.userAgent})` (flutter_map adds its own UA only when none is set, `tile_layer.dart` l. 279–284); flutter_map 8.3.2's built-in cache is on by default and follows the server's caching headers; no offline or bulk download anywhere in `lib/` | Attribution RUNTIME (emulator); tiles HOST + CODE |
| **O4** Light-pollution link | **UNVERIFIED** (partial) — carried to S11.6 | Emulator: About's link sends a `VIEW` intent to `https://lightpollutionmap.app/…` in the browser (path redacted by Android); the coordinate link from a site was not observed with its query. Host: `https://lightpollutionmap.app/?lat=46.0500&lng=14.5000&zoom=10` → 200; the site's `llms.txt` (read 2026-09-30) still documents `?lat={latitude}&lng={longitude}&zoom={2-18}` — the format `LightPollutionMapLink.at` builds (4 decimals, zoom clamped 2–18; `light_pollution_map_link_test.dart`). Code: only `launchUrl(…, externalApplication)` in `sky_darkness_widget.dart` and `site_editor_screen.dart`; no request to the site | Intent host RUNTIME (emulator); link format HOST + CODE |
| **O5** Providers' terms re-checked, dated in `COMPLIANCE.md` | **PASS** | §6: Open-Meteo terms, OSM tile policy, Nominatim policy and lightpollutionmap.app's `llms.txt` read 2026-09-30; no change that affects the app. `COMPLIANCE.md`'s stamp and table header dated 2026-09-30 | DOCUMENTED (cited, dated) |
| **O6** AC7 dependency and licence audit | **PARTIAL** — Dart packages PASS; S11P-03, S11P-04 | §3: 114 runtime Dart packages (`flutter pub deps --no-dev`), each `LICENSE` from the pub cache: MIT 29, BSD-3 73, Apache-2.0 4, BSD-2 1, MPL-2.0 3 (Linux-only `dbus`, `geoclue`, `gsettings`), Flutter SDK 4 — all permissive or weak-copyleft and compatible with GPL-3.0. Every one of the 110 pub packages appears in the release APK's `NOTICES.Z` (the licence page); the 4 SDK ones are covered by Flutter's own notices. **Not on the licence page:** the Android libraries the plugins add (AndroidX, Kotlin coroutines — Apache-2.0; Google Play services location 21.2.0 — proprietary), S11P-04; Play services and GPL-3.0, S11P-03 | CODE VERIFIED |
| **O7** AC7 secrets and HTTPS | **PASS** | §4: no key, token, password or private key in tracked files; no signing file tracked or present; `key.properties`, `*.jks`, `*.keystore` gitignored (`git check-ignore`); every URL the app calls or opens is `https://`; no cleartext opt-in (no `usesCleartextTraffic`, no network security config) and `targetSdk 36` (cleartext blocked by default) | CODE VERIFIED |
| **O8** `COMPLIANCE.md` and the privacy policy against the code | **PASS** after three corrections to `COMPLIANCE.md`; one FOLLOW-UP on the policy's wording (S11P-05) | §5 | CODE VERIFIED |
| **O9** Policy published, contact filled in, URL opens | **NOT MET** — OWNER ACTION (S11P-02) | `https://chacha12.github.io/astro-planner/privacy/` → 404 (host, 07:33 UTC); `docs/privacy/index.md` still has `<CONTACT EMAIL>` | HOST |
| **Q2** Play's closed-testing rules | **PASS** | §7: personal accounts created after 13 Nov 2023 need a closed test with ≥ 12 testers opted in continuously for ≥ 14 days, then apply for production access (review usually ≤ 7 days) | DOCUMENTED (cited, dated) |

## 3. Dependency licences (O6)

Method: `flutter pub deps --no-dev --style=list` (Flutter 3.47.4), then each package's `LICENSE` in
`%LOCALAPPDATA%\Pub\Cache\hosted\pub.dev\<pkg>-<version>\`, classified by its text (MIT grant, BSD
clauses, Apache 2.0, MPL 2.0); then the release APK's `assets/flutter_assets/NOTICES.Z`
(`app-x86_64-release.apk`, built 2026-09-30 10:18 for S11.3) checked for each package name.

| Licence | GPL-3.0 | Packages (version) |
| --- | --- | --- |
| MIT (29) | Compatible | provider 6.1.5+1, drift 2.35.0, geolocator 14.0.3, file_picker 13.1.0, archive 4.3.0, android_file_picker 2.0.0, dart_earcut 1.2.0, equatable 2.1.0, file_picker_darwin 2.1.2, file_picker_linux 2.0.0, file_picker_platform_interface 4.0.0, file_picker_web 4.0.0, geolocator_android 5.0.3, geolocator_apple 2.3.14, geolocator_linux 0.2.6, geolocator_platform_interface 4.3.0, geolocator_web 4.1.4, geolocator_windows 0.2.5, mgrs_dart 3.0.0, nested 1.0.0, petitparser 7.0.2, posix 6.5.2, proj4dart 3.0.0, sqlite3 3.5.2, uuid 4.6.0, windows_file_picker 2.0.0, wkt_parser 2.0.0, xml 7.0.1, yaml 3.1.4 |
| BSD-3-Clause (73) | Compatible | go_router 18.0.1, path_provider 2.1.6, path 1.9.1, http 1.6.0, share_plus 13.3.0, url_launcher 6.3.2, shared_preferences 2.5.5, flutter_map 8.3.2, args 2.7.0, async 2.13.1, characters 1.4.1, code_assets 1.2.1, collection 1.19.1, convert 3.1.2, cross_file 0.3.5+5, crypto 3.0.7, cupertino_ui 1.1.0, dart_polylabel2 1.0.0, ffi 2.2.0, ffi_leak_tracker 0.1.2, file 7.0.1, fixnum 1.1.1, glob 2.2.0, hooks 2.0.2, http_parser 4.1.2, intl 0.20.3, jni 1.0.3, jni_flutter 1.0.3, jni_util 1.0.0, logging 1.3.0, material_ui 1.3.0, meta 1.18.3, mime 2.1.0, native_toolchain_c 0.19.2, objective_c 9.5.0, package_config 3.0.0, package_info_plus 10.2.1, package_info_plus_platform_interface 4.1.0, path_provider_android 2.3.1, path_provider_foundation 2.6.0, path_provider_linux 2.2.2, path_provider_platform_interface 2.1.3, path_provider_windows 2.3.0, platform 3.2.0, plugin_platform_interface 2.1.8, pub_semver 2.2.1, record_use 0.6.0, share_plus_platform_interface 7.2.0, shared_preferences_android 2.4.28, shared_preferences_foundation 2.5.7, shared_preferences_linux 2.4.1, shared_preferences_platform_interface 2.4.2, shared_preferences_web 2.4.3, shared_preferences_windows 2.4.1, simple_sparse_list 0.1.4, source_span 1.10.2, stack_trace 1.12.2, stream_channel 2.1.4, string_scanner 1.4.1, term_glyph 1.2.2, typed_data 1.4.0, unicode 1.1.9, url_launcher_android 6.3.33, url_launcher_ios 6.4.2, url_launcher_linux 3.2.3, url_launcher_macos 3.2.6, url_launcher_platform_interface 2.3.2, url_launcher_web 2.4.3, url_launcher_windows 3.1.6, vector_math 2.4.0, web 1.1.1, win32 6.4.0, xdg_directories 1.1.0 |
| Apache-2.0 (4) | Compatible (GPL-3.0 only, not GPL-2.0) | latlong2 0.10.1, flutter_timezone 5.1.0, clock 1.1.3, material_color_utilities 0.13.0 |
| BSD-2-Clause (1) | Compatible | timezone 0.11.1 (its bundled IANA data is public domain) |
| MPL-2.0 (3) | Compatible (MPL 2.0 §3.3, secondary licence; the Exhibit B text matched is the licence's own template) | dbus 0.7.15, geoclue 0.1.1, gsettings 0.2.8 — reached only through `geolocator_linux`, i.e. Linux desktop |
| Flutter SDK (4) | Compatible (BSD-3; the engine's notices ship in `NOTICES.Z`) | flutter, flutter_localizations, flutter_web_plugins, sky_engine |

Native code shipped: `libsqlite3.so` (built by `sqlite3`'s build hook from SQLite, public domain),
`libflutter.so`, `libapp.so`, `libdartjni.so`, `libdatastore_shared_counter.so` (AndroidX DataStore).

**Android (Gradle) libraries added by plugins, not on the licence page:** AndroidX (≈ 35 artefacts:
core, browser, datastore, preference, lifecycle, …) and `kotlinx` coroutines — Apache-2.0; **Google
Play services** `play-services-location` 21.2.0 with `-base`, `-basement`, `-tasks`
(`geolocator_android`'s `build.gradle`; present in the APK as `play-services-*.properties`) —
proprietary (Android SDK licence terms). See S11P-03, S11P-04.

No analytics, crash-reporting or advertising package is in the graph.

## 4. HTTPS and secrets (O7)

**Every URL in `lib/`** (grep for `http://` and `https://`, plus `Uri.https`):

| URL | Use | Scheme |
| --- | --- | --- |
| `api.open-meteo.com/v1/forecast` (`Uri.https`) | Request | HTTPS |
| `nominatim.openstreetmap.org/reverse` (`Uri.https`) | Request (opt-in) | HTTPS |
| `tile.openstreetmap.org/{z}/{x}/{y}.png` | Request (map picker) | HTTPS |
| `lightpollutionmap.app/?lat=…&lng=…&zoom=…` and `lightpollutionmap.app/` | Opened in the browser | HTTPS |
| `open-meteo.com/`, `www.openstreetmap.org/copyright`, `github.com/mattiaverga/OpenNGC`, `www.reddit.com/user/Buffur/`, `github.com/Buffur` | Opened in the browser | HTTPS |
| `AppIdentity.projectUrl`, `privacyPolicyUrl`, `sourceUrl` (`chacha12.github.io/astro-planner/…`, `github.com/chacha12/astro-planner`) | Opened in the browser; the project URL is also the contact in the user agent | HTTPS (404 today, TD-088) |

Only `http://` in shipped content: `http://leda.univ-lyon1.fr` inside `OPENNGC_NOTICE.txt`, displayed
as text on About (not a link, never requested). iOS plist DOCTYPE URLs are not requests.

**Android:** `AndroidManifest.xml` (main and the merged release manifest of 2026-09-30) has no
`usesCleartextTraffic` and no `networkSecurityConfig`; `targetSdkVersion 36`, so cleartext is refused by
default (API 28+). Merged release permissions: `ACCESS_FINE_LOCATION`, `ACCESS_COARSE_LOCATION`,
`INTERNET`, and the app's own `DYNAMIC_RECEIVER_NOT_EXPORTED_PERMISSION` (AndroidX). `<queries>`
allows `VIEW` of `https` only.

**Secrets:** `git grep` over the 815 tracked files for key/token/password/private-key words and for
provider key shapes (`AKIA…`, `AIza…`, `gh?_…`, `xox?-…`, `sk-…`, `BEGIN … PRIVATE KEY`): no match
other than the words in comments, the signing-config property names read from `key.properties` in
`android/app/build.gradle.kts`, and `LICENSE`. `git ls-files` lists no `.jks`, `.keystore`, `.p12`,
`.pem`, `.pfx`, `key.properties`, `google-services.json`, `.env` or `local.properties`. No such file
exists in the worktree (`android/key.properties` absent — not opened). `git check-ignore`:
`key.properties` and `**/*.jks` (android/.gitignore l. 12, 14), `*.keystore` (.gitignore l. 51).
Open-Meteo is used keyless (free tier); no API key exists.

## 5. `COMPLIANCE.md` and `docs/privacy/index.md` against the code (O8)

| Flow or claim | Code | `COMPLIANCE.md` | Privacy policy |
| --- | --- | --- | --- |
| Weather → Open-Meteo | The active site's, or a chosen unsaved position's (map pick, GPS fix), latitude and longitude **unrounded** (`'$latitude'`), the night's start and end hour, the variables, `best_match`; never for the default position (`sessionNight` is null there). One request per site and night, reused under 3 h; again when older, on Refresh, or on resume when outdated | **Corrected:** said "a site's coordinates" and "At most one request per night shown" | "when a site is set … the site's latitude and longitude, and the night's hours" — true for sites; a chosen unsaved position is not named (S11P-05) |
| Tiles → OSM | Only while the map picker is open; the visible tiles; UA set; cached by flutter_map per headers | Accurate | Accurate |
| Place names → Nominatim | Only with the setting on (off by default), position rounded to 0.01° (≈ 1.1 km), ≤ 1/s, never for a saved site or the default position | Accurate | Accurate ("rounded to about 1 km") |
| Light-pollution map | Browser only, on tap, coordinates to 4 decimals in the link | Accurate | Accurate |
| User agent | `Astro Planner/1.0.0 (+https://chacha12.github.io/astro-planner/; io.github.chacha12.astroplanner)` on all three services | Accurate (its contact URL is 404, TD-088) | Accurate |
| No analytics, ads, crash reporting, account | None in the dependency graph or code | Accurate | Accurate |
| Permissions | Fine, coarse location, internet; no background, storage, camera, contacts, notification (merged release manifest) | Accurate | Accurate |
| Location permission only on "use current position" | `SiteViewModel.useCurrentLocation`, the picker's "Current Location" button and the site editor's "Use current position" | Accurate | Accurate |
| Backups hold settings (S8.9) | `BackupPreferences` | n/a | Accurate (updated 29 Sep) |
| "Add from a photo" | Header read on device, nothing sent | Accurate | Accurate |
| HTTPS only | §4 | Accurate | Accurate |
| Licence page | Lists the Dart packages only | **Corrected:** implied every dependency | n/a |

Corrections made to `COMPLIANCE.md` (factual only, no policy change): (1) the Open-Meteo cadence;
(2) the Data Safety draft's position sent for the weather (includes a chosen, unsaved position,
unrounded); (3) the licence page lists the Dart packages, not the Android libraries. Plus the new
re-check stamp and the terms table dated 2026-09-30. The privacy policy was not edited (it is the
owner's to publish).

## 6. Providers' terms, re-read 2026-09-30 (O5)

| Service | Page (read 2026-09-30) | What it says now | Change since 2026-09-24 that matters |
| --- | --- | --- | --- |
| Open-Meteo | <https://open-meteo.com/en/terms> (no revision date shown) | Non-commercial: "private or non-profit websites or apps that do not have subscriptions or advertising"; 600/min, 5 000/h, 10 000/day (~300 000/month); data CC BY 4.0; IP in server logs deleted after 90 days | None |
| OSM tiles | <https://operations.osmfoundation.org/policies/tiles/> (no date shown) | Visible attribution, not hidden; a clear, unique, stable User-Agent naming the app (contact recommended); a library's generic default UA is blocked; honour caching headers or cache ≥ 7 days; never send `no-cache`; no bulk, prefetch or offline use; access may be withdrawn | Wording now explicit about library default UAs and the 7-day minimum; the app complies (own UA; flutter_map's cache follows headers) |
| Nominatim | <https://operations.osmfoundation.org/policies/nominatim/> (no date shown) | ≤ 1 request/s; identifying UA or Referer; cache results; attribution; no autocomplete, systematic or grid queries; switchable without a software update; no heavy commercial use | None (the switchability gap stays TD-031) |
| lightpollutionmap.app | <https://lightpollutionmap.app/llms.txt> | Coordinate link `?lat=…&lng=…&zoom=2–18`, "a shareable utility link"; maintained by the Stargazing Hub Team | None |

## 7. Google Play's current rules (N10, Q2)

All read 2026-09-30 on Google's pages.

| Rule | Current text (short) | Source |
| --- | --- | --- |
| Closed testing, new personal accounts | Personal accounts "created after November 13, 2023" must run a closed test with "a minimum of 12 testers who have been opted in continuously for at least 14 days"; testers who opt out before 14 days do not count; then apply for production access on the Dashboard and answer questions; review "usually takes seven days or less"; internal testing optional | Play Console Help, "App testing requirements for new personal developer accounts", <https://support.google.com/googleplay/android-developer/answer/14151465?hl=en> |
| Target API level | From 31 August 2026 new apps and app updates must target Android 16 (API 36); existing apps must target API 35 to stay available to new users on newer Android; an extension to 1 November 2026 may be requested | Play Console Help, "Target API level requirements for Google Play apps", <https://support.google.com/googleplay/android-developer/answer/11926878?hl=en> |
| 16 KB page size | "Apps that contain native code must support devices with 16 KB memory page sizes" (mobile, in force; Wear OS from 15 Sep 2026, TV from 1 Aug 2026) | Play Console Help, "Play Console technical quality requirements", <https://support.google.com/googleplay/android-developer/answer/17492799?hl=en> |
| 16 KB page size (enforcement) | Apps targeting API 35+ must support 16 KB pages on 64-bit devices; "Starting February 1, 2027, if your app updates don't support 16 KB memory page sizes, you won't be able to release these updates"; check with the bundle explorer or `bundletool dump config` | Android Developers, "Support 16 KB page sizes" (last updated 16 Sep 2026), <https://developer.android.com/guide/practices/page-sizes> |

The app: `targetSdk 36` (Flutter 3.47.4 default; merged manifest), native libraries 16 KB aligned
(N3). If the owner's Play account is a personal account created after 13 Nov 2023, TASK 16.4 needs
12 testers for 14 continuous days before production.

## 8. Findings

| ID | Class | Finding |
| --- | --- | --- |
| S11P-01 | FOLLOW-UP | Nominatim's `jsonv2` answer at `zoom=10` for 46.05, 14.5 has `address: {municipality: "Ljubljana", country}`; `NominatimReverseGeocoder` reads only `city`, `town`, `village`, `county`, `state`, so such a point gets no place name. Degrades to coordinates (optional, off-by-default feature; no wrong data). Suggest reading `municipality` (and similar keys) or `name`, with a test from a real response shape [S]. For `TECH_DEBT.md` |
| S11P-02 | OWNER ACTION | The project, privacy-policy and source URLs answer 404 (2026-09-30, 07:33 UTC), and `docs/privacy/index.md` still has `<CONTACT EMAIL>`: O9 and `COMPLIANCE.md` "Before an upload" 1–2 unmet; the user agent's contact URL is dead. Known: TD-088, waits for RD-01 (N7). Mandatory before an upload (D11-2) |
| S11P-03 | OWNER ACTION | `geolocator_android` ships Google Play services location 21.2.0 (proprietary) in the GPL-3.0 app. The owner, as copyright holder, can distribute it; others redistributing a build, and stores such as F-Droid, may not treat it as GPL-clean. Owner to decide: accept and state it (e.g. a linking exception or a note in `COMPLIANCE.md`), or use the platform location manager instead (geolocator's `forceLocationManager` / an Android-only setting — a code change) |
| S11P-04 | FOLLOW-UP | The in-app licence page lists the Dart packages only; the Android libraries (AndroidX, Kotlin coroutines — Apache-2.0, whose notice terms apply; Play services) are not listed. Add their notices (`LicenseRegistry.addLicense`, or a Gradle licence plugin) [S]. `COMPLIANCE.md`'s sentence corrected meanwhile |
| S11P-05 | FOLLOW-UP | The privacy policy says Open-Meteo receives "the site's latitude and longitude" "when a site is set"; the app also sends a chosen position that is not a saved site (map pick, GPS fix), unrounded. Reword to "a site or a position you choose" at the next policy edit (owner publishes it; a new effective date) [S]. `COMPLIANCE.md`'s Data Safety draft corrected |
| S11P-06 | DEFERRED (to S11.6, the owner's phone) | O1–O4 and G6's page loads cannot be observed on this machine's emulator: its TLS is intercepted by the host antivirus (the OS probe and the app both fail certificate checks) and Chrome's first run needs its terms accepted. Host contract evidence and the intent hosts are recorded above; the runtime rows need the phone |
| S11P-07 | FOLLOW-UP | The emulator's clock reads 2 Oct 2026 02:19 GMT against the host's 30 Sep 07:35 UTC — probably left from S11.3's night or lifecycle runs; S11.3 said changed settings are restored. Set it back (automatic time) before the next emulator run, or evidence dated from the emulator will be off |

No BLOCKER: nothing here is a V4 A–C defect of the work under Stage 11 (no plain-HTTP call, no leaked
secret, no data-flow the documents deny; S11P-02 is the known owner-gated TD-088).
