# Legal and compliance record (TASK 16.3, PD-12)

> Written 2026-09-24 for TASK 16.3. **Not legal advice** (out of scope by the roadmap):
> it records what the app does, what third-party terms said on the date checked, and the
> owner's decisions, so the owner can review them. Every terms check is date-stamped;
> re-check before each release.

## Owner decisions (2026-09-24)

- **Free, with no ads and no subscriptions.** Keeps the app within Open-Meteo's free,
  non-commercial tier. Any paid or ad-supported version needs Open-Meteo's commercial plan
  first (an API key held outside the code — ADR-012 §2, CLAUDE.md rule 15).
- **Licence: GPL-3.0** (the repository's `LICENSE`). The bundled OpenNGC-derived catalog
  is CC BY-SA 4.0, which Creative Commons declared one-way compatible with GPL-3.0; its
  notice ships in `assets/catalog/OPENNGC_NOTICE.txt` and on the About screen.
- **Privacy policy on GitHub Pages:** `docs/privacy/index.md`, to be served at
  <https://chacha12.github.io/astro-planner/privacy/> (the app links there).
- **Place-name lookups are opt-in** (Settings → "Look up place names", off by default).

## Third-party terms, checked 2026-09-24

| Service | Terms (checked 2026-09-24) | How the app complies |
| --- | --- | --- |
| **Open-Meteo** forecast API | Free for non-commercial use: apps "that do not have subscriptions or advertising"; data CC BY 4.0 (attribution); limits 600/min, 5 000/h, 10 000/day, 300 000/month; IP addresses logged 90 days. <https://open-meteo.com/en/terms> | Free, no ads (owner decision). At most one request per night shown, cached (3 h / 12 h freshness, ADR-012). Attribution "Weather data by Open-Meteo.com (CC BY 4.0)" on the weather card and the About screen. Requests carry the app's user agent (since S1.1, 2026-09-25). |
| **OpenStreetMap tiles** | Attribution on the map; a distinct, stable user agent naming the app, with a contact where possible; honour caching headers; no bulk or offline download; "best-effort", access can be withdrawn without notice. <https://operations.osmfoundation.org/policies/tiles/> | "© OpenStreetMap contributors" on the map (linking to the copyright page) and on the About screen; user agent `Astro Planner/<version> (+https://chacha12.github.io/astro-planner/; io.github.chacha12.astroplanner)`; tiles only for the visible map; no offline download. **Risk:** heavy use or a policy change can end access — the map picker is optional (typed coordinates always work). |
| **Nominatim** reverse geocoding | Max 1 request/s; identifying user agent; caching; attribution; no autocomplete, no systematic or periodic queries; apps must be able to switch service without a software update; heavy/commercial use not permitted. <https://operations.osmfoundation.org/policies/nominatim/> | Opt-in, off by default; ≤ 1 request/s; results cached per ~1 km; only on a user-chosen position; attribution with every place name. **Remaining gap:** a user who switches it on still uses the built-in endpoint — there is no remotely switchable endpoint; mitigated by the opt-in and by failures showing no name (the app never depends on it). Recorded in TD-031. |
| **OpenNGC** catalog | CC BY-SA 4.0 (attribution, share-alike). | Full notice bundled and shown (TASK 8.2). |
| **lightpollutionmap.info** | Opened in the browser only; the app fetches nothing from it. | — |

Dependency licences are shown by Flutter's licence page (About → Open-source licences),
generated from the packages' own `LICENSE` files.

## Google Play: Data Safety form (draft answers)

Answers for the owner to review in the Play Console (definitions change; read the
console's current help texts). Conservative where Play's definitions are unclear.

- **Does the app collect or share user data?** Yes — location only.
  - **Precise location** and **approximate location:** *collected* (sent off the device
    to Open-Meteo for the forecast; tile requests reveal the area viewed; Nominatim
    receives a rounded position only when the user switches it on) and *shared* with those
    third parties. Purpose: **App functionality**. Not used for ads, analytics or
    personalisation; not linked to the user's identity (no account). Collection is
    **required** for the weather feature (a site's coordinates are sent automatically when
    online); the GPS fix itself is optional.
  - Everything else — personal info, financial info, health, messages, photos and videos,
    audio, files, calendar, contacts, app activity, web browsing, app info and performance
    (no crash reporting), device or other IDs: **not collected**.
  - The IP address reaches every server the app contacts; Play's form does not list it
    as its own data type — the owner should confirm this against the console's current
    guidance.
- **Is all user data encrypted in transit?** Yes (HTTPS only).
- **Can users request deletion?** The developer holds no user data; everything is on the
  device and is deleted by clearing the app's data or uninstalling.
- **Account creation:** none. **Ads:** none. **Target audience:** not children.
- **Privacy policy URL:** <https://chacha12.github.io/astro-planner/privacy/>.

## Permissions and their rationale

The release manifest requests `ACCESS_FINE_LOCATION`, `ACCESS_COARSE_LOCATION` and
`INTERNET` (plus a non-exported receiver permission added by an AndroidX library). No
background location, no storage, camera, contacts or notification permission.

- Location is requested only when the user taps "use current position"; the first-run
  page says why before the system dialog ("asks for location permission only if you tap
  'Use current position'"), and every refusal is explained with alternatives (typed coordinates, the map)
  — `LocationFailureText` (TASK 7.2). No background access, so no Play background-location
  declaration is needed.

## Before an upload (owner)

1. Publish `docs/privacy/index.md` at the policy URL (GitHub Pages from the repository's
   `docs/` folder), with **`<CONTACT EMAIL>` replaced** by the contact address you want
   public; confirm the URL opens.
2. Make the source repository public at <https://github.com/chacha12/astro-planner> (the
   About screen links it; GPL-3.0 asks that the source be offered).
3. Fill in the Data Safety form from the draft above and the store listing's contact
   details (the OSM policy asks that the contact be published there too).
4. Re-check the three services' terms and update the dates above.
