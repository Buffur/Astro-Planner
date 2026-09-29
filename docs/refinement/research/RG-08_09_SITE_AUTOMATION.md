# RG-08 and RG-09 — Site Automation: Elevation, Sky Darkness and the Map Link (S7.R4)

> **Status:** research, documentation only. Written 2026-09-29 at `main` @ `cdb6c0d` by the S7.R4
> session (`refinement/POST_ROADMAP_PLAN.md`, "Stage 7 — frozen Task sequence", S7.R4). No
> application code, test, asset or dependency changed, and no data was downloaded.
>
> **Nothing is decided here.** Section 8 lists the owner's questions for RG-08 and RG-09. The answers go
> into DECISIONS E.1 and complete S7.5.

Evidence labels as in `research/RG-11_CAPTURE_PARAMETERS.md`: **[verified]** the repository;
**[primary]** read today (2026-09-29) from the provider or the platform's documentation;
**[secondary]**; **[unverified]**; **[unknown]**. Conclusions are tagged **FACT**, **OWNER
PREFERENCE** or **IMPLEMENTATION OPTION**.

## 1. The questions

- **RG-08:** should elevation be retrieved automatically (source, accuracy, licence, privacy), made
  optional, or dropped from the form, given that no calculation uses it?
- **RG-09:** can Bortle or SQM be obtained reliably (a dataset or an API; the uncertainty of any
  conversion)? Does SQM need to be a user field at all? Should the external map link move to
  lightpollutionmap.app?

## 2. What the app has today [verified]

| Field | Stored | Required | Read by a calculation | Shown |
| --- | --- | --- | --- | --- |
| Name | `locations.name` | yes | no | everywhere |
| Latitude, longitude | `locations` | yes | every astronomy calculation | editor, context line |
| Elevation (m) | `locations.elevation`, `REAL NOT NULL` | **yes** (the editor refuses to save without it; −500 to 9,000 m) | **no**; copied into the plan snapshot only | editor |
| Bortle (1–9) | with source `user` and a date | no | **no** (the sky warning was replaced by annotations, ADR-013) | editor, the sky-darkness row and detail, the session detail, the snapshot |
| SQM (15–23 mag/arcsec²) | with source `user` and a date | no | **no** | as Bortle |
| Notes | text | no | no | editor |

- **Coordinates** come from typing, "Pick on map", or "Use current position" (GPS on tap, transient)
  on the Sites screen; the editor itself offers typing and the map.
- **The name** comes from typing, or from the opt-in Nominatim lookup when a position is saved as a
  site (PD-12).
- **The forecast request** (`OpenMeteoWeatherRepository`) sends the site's latitude and longitude to
  Open-Meteo and **no elevation**; the response's own `elevation` field is not read.
- **The map link** (`LightPollutionMapLink`) opens `lightpollutionmap.info` at the position, from the
  sky-darkness row; About names the site. Only the link leaves the app, when the user taps it.
- **PD-05** (2026-09-23): Bortle and SQM are manual or unknown; a dataset (C) or a licensed API (D) is
  deferred until its licence, size and conversion uncertainty are evaluated; no Bortle↔SQM conversion
  without a cited source.

## 3. Elevation (RG-08)

### 3.1 Sources

| Source | What it gives | Accuracy | Licence and terms | What leaves the device | Offline |
| --- | --- | --- | --- | --- | --- |
| **The device's GPS** | `getAltitude()`: metres **above the WGS 84 ellipsoid**; `getMslAltitudeMeters()`: above mean sea level, only where `hasMslAltitude()` [primary: Android `Location`; the MSL value exists since API 34 [secondary]] | Vertical GPS error is typically larger than horizontal [unverified figure]; the ellipsoid-to-sea-level difference (the geoid) reaches tens of metres [unverified figure] | Platform API | Nothing | Works offline, but only at the device's current position, not a site picked on the map |
| **Open-Meteo, already in the forecast response** | "The elevation from a 90 meter digital elevation model", used for statistical downscaling [primary: Open-Meteo forecast docs] | A 90 m grid value: a terrain average, not the observer's spot | Open-Meteo's terms and attribution, already met for the forecast (CC BY 4.0, About); Copernicus attribution for DEM data [primary: Open-Meteo elevation docs] | Nothing new: the coordinates are already sent for the forecast | Only when a forecast for those coordinates has been fetched |
| **Open-Meteo Elevation API** (`/v1/elevation`) | "the terrain elevation" for coordinates; "based on the Copernicus DEM 2021 release GLO-90 with 90 meters resolution" [primary] | As above | "All users of Open-Meteo data must provide a clear attribution to the Copernicus program as well as a reference to Open-Meteo" [primary] | The site's coordinates, to a provider that already receives them | Needs a network; must fail without blocking Save |
| **A bundled elevation model** | — | — | Copernicus GLO-90 is openly licensed [unverified terms] | Nothing | Size: a global 90 m model is many gigabytes [unverified]; impractical on a phone |

### 3.2 Use
- **FACT:** no AstroPlan calculation reads elevation. The Sun and Moon events use a standard horizon;
  the target altitudes are airless (ADR-010); the horizon gate is reserved with no data (ADR-013).
  Open-Meteo downscales with its own model elevation, not the site's.
- **FACT:** a guessed elevation (0 m, or a DEM value presented as the observer's) would be a
  fabricated value if stored without its source (`PRODUCT_DIRECTION.md` §7).
- **FACT:** its only current role is a record of the site, copied into snapshots.

### 3.3 Options
- **E2 — optional:** elevation becomes nullable and Unknown by default; existing values are kept
  exactly (a migration that adds nullability; ADR-011 §6's rule). It stays editable in the form,
  without prominence (the plan's rule), and a snapshot records null when unknown.
- **E1 — a proposal from Open-Meteo:** "Fill in from terrain data" beside the field, on the user's tap:
  the elevation endpoint for the typed coordinates, shown as "≈ N m (terrain model, 90 m grid;
  Copernicus DEM via Open-Meteo)", applied only by the user and stored with its source; offline, the
  button says it needs a connection and the form still saves. A new call to an existing provider:
  privacy and compliance documents in the same change (trap 22).
- **E1b — from the device's GPS**, when the user takes the position from GPS: the MSL altitude where the
  device provides it, never the ellipsoid height shown as elevation; otherwise nothing.
- **E3 — out of the form:** no field, stored values kept.

**Recommend E2** (FACT: the value feeds nothing, so requiring it is friction without purpose — UX-21;
an honest Unknown costs nothing). **E1** is a reasonable convenience if the owner wants the record
filled (OWNER PREFERENCE), with its source shown, because the provider and the data sent are already in
use. **E1b is not recommended:** it applies only at the device's position and its datum differs by
device and Android version. **E3** loses a record some users keep (not recommended).

## 4. Bortle and SQM (RG-09)

### 4.1 What they are
- **SQM** is a measured sky brightness at the zenith, in mag/arcsec² (a Sky Quality Meter reading).
  **Bortle** is a nine-class visual scale published by John E. Bortle in Sky & Telescope (February
  2001) [secondary: Wikipedia]. Tables relating the two exist, but "this conversion is approximate"
  [secondary]; no primary source defines one. PD-05's rule stands: no conversion.

### 4.2 Sources for an automatic value

| Source | What it gives | Licence and terms | Size, epoch | Direct or derived | Verdict |
| --- | --- | --- | --- | --- | --- |
| **The 2016 World Atlas of Artificial Night Sky Brightness** (Falchi et al.) | Simulated zenith radiance (mcd/m²) of **artificial** sky brightness on a 30″ grid, from VIIRS 2014 data through a radiative-transfer model [primary: Science Advances paper; GFZ dataset page, through a search result] | **CC BY-NC 4.0** since 2019 [primary: GFZ, through a search result] | A 2.9 GB GeoTIFF; data from about 2014 | Modelled artificial brightness; SQM needs the natural background added and a unit conversion; Bortle a further, approximate step | Not suitable: non-commercial terms need RG-12's review against GPL-3.0; too large to bundle; ten years old |
| **lightpollutionmap.app** | Modelled sky brightness and "Bortle values [that] are a quantitative interpretation derived from modeled SQM … shown with decimal precision", from VIIRS 2025 (2026 provisional) [primary: its About & Data page] | No API and no data-reuse terms found; embedding and sharing are offered [primary] | — | Derived, and "should not be treated as a live field measurement" [primary] | No data source for the app; a link target only |
| **lightpollutionmap.info** (today's link) | Several map layers [primary: its help page, not read in detail] | Terms for reuse not read [unknown] | — | Modelled | A link target only |
| **Satellite radiance** (VIIRS night lights) | Upward radiance, not sky brightness [secondary] | Public data [unverified] | Large | Needs a sky-brightness model to mean anything | Not suitable without a model and a cited method |

- **FACT:** no source was found that gives Bortle or SQM for a coordinate reliably, under terms that
  fit the app, at a size a phone can hold, and as a measurement rather than a model. **Bortle and SQM
  stay manual or unknown** (the prompt's rule: "if no acceptable source exists").
- **FACT:** the map is still useful: it lets the user read a modelled value and type it, and the app
  stores it with source `user` (PD-05 A + B).

### 4.3 Does SQM stay?
- **FACT:** SQM is a measurement some users own a meter for; it is more precise than a Bortle class,
  and no calculation needs either. Removing it would delete a valid record (`PRODUCT_DIRECTION.md` §7).
- **Options:** S1 — both optional as today, side by side; **S3 — both optional, under one collapsed
  "Sky darkness (optional)" section** of the site form (one level of disclosure), unknown by default;
  S4 — SQM kept and shown where stored, but no longer asked.
- **Recommend S3** (FACT: neither feeds a calculation, and 08 §6 shows most users do not know either;
  S3 keeps both reachable without asking every user; a stored value shows its source and date).
  Next to it, "Look it up on the light-pollution map" opens the map at the site (an IMPLEMENTATION
  OPTION reusing the link; nothing is fetched).

## 5. The map link (RG-09)

- **lightpollutionmap.app** is maintained by "The Stargazing Hub Team" and documents a coordinate link:
  `https://lightpollutionmap.app/?lat={latitude}&lng={longitude}&zoom={2-18}` in "WGS84 decimal
  degrees", which opens "the normal interactive map and location-details panel" [primary: its
  `llms.txt` and About & Data page]. It models sky brightness from VIIRS 2025.
- **lightpollutionmap.info** is today's target; its link format is the one the app builds now
  [verified].
- **What leaves the device:** in both cases the coordinates in the URL, sent by the user's browser
  when the user taps the link; nothing otherwise. The privacy policy already describes the link
  [verified: `docs/privacy/index.md` lists providers; the link's entry to be re-checked in S7.5].
- **Options:** M1 — keep .info; **M2 — switch to .app** (the owner's request, 08 §13); M3 — offer both.
- **Recommend M2** (FACT: its coordinate link is documented, its data is newer, and it is the owner's
  stated preference). About's source line changes with it.

## 6. The other site fields
- **Coordinates:** typed, the map, or "Use current position" (S7.5 adds it to the editor; GPS only on
  the user's tap; a fix is transient until Save). Already decided by the plan; no question.
- **Name:** typed, or the opt-in lookup (PD-12); never a required network step. No change.
- **Notes:** kept, optional (08 §6 asked whether they are needed; they are a user's record and cost
  nothing when empty).

## 7. The classification (the prompt's classes)

| Field | Obtained reliably | Proposable with provenance | Manual and optional | Unknown by default |
| --- | --- | --- | --- | --- |
| Coordinates | GPS on tap; the map | — | typing | — (required) |
| Name | — | the opt-in lookup | typing | — (required) |
| Elevation | — | Open-Meteo's terrain model (E1), if adopted | yes (E2) | yes (E2) |
| Bortle | — | — (no acceptable source) | yes | yes |
| SQM | — | — (no acceptable source) | yes | yes |
| Notes | — | — | yes | empty |

## 8. The owner's questions (RG-08, RG-09)

1. **Elevation:** E2 (optional, Unknown by default; recommended), and also E1 (a "Fill in from terrain
   data" button using Open-Meteo, shown with its source), or E3 (out of the form)?
2. **Bortle and SQM:** S3 (both optional, in one collapsed "Sky darkness (optional)" section, with a
   link to look them up on the map; recommended), S1 (as today) or S4 (SQM no longer asked)?
3. **The map link:** M2 (lightpollutionmap.app; recommended), M1 (keep .info) or M3 (both)?

Not asked (facts): no Bortle or SQM source is acceptable today, so no automatic value; no Bortle↔SQM
conversion; coordinates, name and notes as in §6.

## 9. What becomes frozen after the decision

In DECISIONS E.1 and S7.5: elevation's rule (and E1's provider, text and privacy entry if chosen); the
sky-darkness section's form; the map link's target and URL; the About and privacy wording.

## Sources (read 2026-09-29)

**Primary**
- Open-Meteo, Elevation API: https://open-meteo.com/en/docs/elevation-api
- Open-Meteo, forecast API (the `elevation` parameter and field): https://open-meteo.com/en/docs
- Android, `Location` (`getAltitude`, `getMslAltitudeMeters`):
  https://developer.android.com/reference/android/location/Location (through a search result and the
  Microsoft Learn mirror)
- Falchi et al. 2016, "The new world atlas of artificial night sky brightness", Science Advances:
  https://www.science.org/doi/10.1126/sciadv.1600377; GFZ dataset page (licence CC BY-NC 4.0, 2.9 GB,
  30″ grid), through a search result
- lightpollutionmap.app, About & Data and link format: https://lightpollutionmap.app/about-data/,
  https://lightpollutionmap.app/llms.txt

**Secondary**
- Bortle scale (history; approximate relation to SQM): https://en.wikipedia.org/wiki/Bortle_scale
- DarkSky International, night sky quality survey guide:
  https://darksky.org/resources/guides-and-how-tos/how-to-conduct-a-night-sky-quality-survey/
