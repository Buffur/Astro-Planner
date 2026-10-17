# RA.R2a — Market and user expectations (landscape)

> **Status:** research, step R2a of the approved RA.R2 (`prompts/RA_R2_RESEARCH_PLAN.md` §3).
> Contains no decisions; the options in §5 are input for R2e and RA.D.
> **Access date for all sources:** 2026-10-17.
> **Baseline:** Phase A findings — `research/RA_R1_PHASE_A_ASSESSMENT.md` (RA-A01…RA-H03, K4, K14).
> The code was not re-audited.
> **Labels:** **[F]** FACT — visible in the primary source (official website, documentation, store
> listing, published review). **[D]** DESCRIBED — marketing, a third-party retelling, or a search
> result without access to the page. **[I]** INFERENCE — a conclusion by the author of this document.
> References of the form [n] point to §6.

## 1. Method and limitations

**Method.**
- Official websites and documentation: Telescopius (developer forum), Astrospheric, Clear Outside,
  PhotoPills User Guide, Stellarium Labs, SkySafari, AstroPlanner (iLanga), Deep-Sky Planner,
  SkyTools, N.I.N.A. documentation, ZWO ASIAIR manuals (PDF).
- Google Play listings were read in full (title, rating, review count, installs, description,
  visible reviews). App Store listings — via the iTunes Search/Lookup API. Recent App Store reviews —
  via the public RSS feed (`itunes.apple.com/us/rss/customerreviews/...`). Reviews were counted by
  hand per theme.
- User discussions: the Telescopius forum (2025 feature requests) and the AstroBin forum (threads
  on logbooks and on a poll about multi-night data).
- The package `com.twtapp` from the owner's reference was identified via its Google Play listing and
  the developer's website (§2, note 1).

**Limitations and gaps (recorded, not hidden).**
- **Reddit** (r/astrophotography, r/AskAstrophotography) is **unavailable**. The search tool
  rejects the reddit.com domain, and a direct request to the JSON API returned 403. The report
  contains no claims from Reddit.
- **Cloudy Nights** is behind Cloudflare: 403 via WebFetch and curl. Only search results for
  threads are available [41]. Everything taken from them is labelled [D] and treated as secondary.
- **telescopius.com** pages are an SPA and return an empty page without JavaScript. Telescopius
  features were confirmed via the App Store listing [1] and the developer's forum replies [2]–[5].
- **photopills.com/articles** returns 403. The User Guide was read via curl [14].
- SkySafari prices were taken from the website page [20]. The payment model (one-time purchase or
  subscription) is not stated there.
- Full Google Play review texts are unavailable: Play shows 3 reviews. Play-based review themes
  therefore rest on small samples and are marked as anecdotes.
- App Store review counts are based on the most recent 30–50 RSS entries. This is not a
  representative sample of the whole base but a "recent slice".
- Third-party AI search summaries (for example, about DarkScout and Telescopius) were used only as
  pointers to the primary source. Where the primary source did not open, the claim is labelled [D].

## 2. "Product × task" matrix

Abbreviations: "—" means the function is absent in the source; "n/a" means no data was found.
**Capture** — planning of the shoot and integration. **SNR/exposure** — SNR or exposure calculator.
**Storage** — estimate of storage space.

| Product | Capture / integration | SNR / exposure | Storage | Weather | Moon | Onboarding | Home | Records / lists | Platform | Price |
|---|---|---|---|---|---|---|---|---|---|---|
| **Telescopius** [1]–[5] | Targets for the telescope, frame simulator, mosaics [F 1]; "Imaging Opportunities" as a planning aid (what it computes is not described) [F 5] | — | — | Weather page — only per a retelling [D] | n/a | Account; sign-in complaints — 4 of 8 recent App Store reviews [F 42] | "Targets for your telescope" block [F 2] | Target lists with notes; **no** session logbook, the developer acknowledges this [F 2][F 3][F 4] | Web, iOS, Android | Free; Patreon and ads [F 1][D 6] |
| **Astrospheric** [7]–[9] | — | — | — | Hourly grid for 84 h: clouds, transparency (with smoke), seeing, wind, T, dew point; Pro adds a model ensemble [F 7][F 8] | Moon Details card (phase, altitude, illumination, age, next phase); rise and set lines on the hourly grid [F 7] | n/a | Forecast for a location [F 7] | Favourite locations: 5 free, unlimited in Pro [F 7] | Web, iOS, Android | Freemium, Pro subscription; ads in free [F 8] |
| **Clear Outside** [10]–[12] | — | — | — | 7 days hourly: cloud cover low/mid/high/total, then ordinary weather; "no cartoonish graphics" [F 10][F 11] | Rise and set, phase; twilight and darkness periods [F 10] | Forecast for the current location automatically [F 10] | Forecast for a location [F 10] | Favourite locations [F 10] | iOS (new version 12.2025), Android (Play update — 05.2015), web [F 11][F 12] | Free [F 10] |
| **PhotoPills** [13]–[15] | Planner (map and time) for the Sun, Moon and Milky Way; saved Plans, "5 upcoming plans" widget [F 13][F 14] | Spot Stars, Long Exposure, Star Trails, Timelapse calculators [F 13][F 14] | — | — | Moon Calendar, rise and set, supermoons [F 13] | Guide: enable widgets, "set a goal", "pain → pill" [F 14] | Three menus: Pills, My Stuff, Academy [F 14] | Plans and POIs, backup, sync (iOS only) [F 14] | iOS, Android | One-time purchase ($10.99 on iOS) [F 44] |
| **Stellarium Mobile** [16][17] | Plus: observability and transit-time tools [F 16] | — | — | — | In the sky view [I] | Sky map straight away ("point your phone") [F 17] | Sky map [F 17] | n/a | iOS, Android; 10M+ installs, 4.8★ [F 17] | Freemium (Plus is an in-app purchase) [F 17] |
| **Sky Tonight** [18][19] | Visible Tonight, Time Machine [F 18] | — | — | Stargazing Index (Moon, light pollution, visibility) [F 18] | Calendar of phases and events [F 18] | n/a | Sky map and bottom navigation [F 18] | n/a | iOS, Android; 5M+, 4.7★ [F 18] | Freemium, subscription or lifetime purchase; ads [F 18][F 19] |
| **SkySafari 8** [20][21] | Multiple fields of view, Event Finder, "Tonight at a Glance" [F 20] | — | — | Premium: Observing Conditions (windows, seeing index) [F 21] | Sun/Moon block in Tonight at a Glance [F 20] | n/a | Tonight at a Glance [F 20] | Lists, notes, equipment, sessions via LiveSky [F 20] | iOS, Android | Basic, Plus, Pro + Premium [F 20] |
| **AstroPlanner** (iLanga, P. Rodman) [22] | Object lists, visibility within a session, sensor field of view [F 22] | — | — | Present in the menu, details not disclosed [F 22] | n/a | A user writes: "intimidating at first" [F 36] | — | Observation log within sessions, equipment manager, custom fields [F 22][F 36] | macOS, Windows | Shareware, about $50 according to a user [F 22][D 36] |
| **DarkScout** (iOS) [23] | Tonight go/no-go, plan up to 14 nights, location comparison [F 23] | — | — | Cloud maps for 72 h and for 12 h; **Astro Score** and hourly decisions [F 23] | "Moon conditions" [F 23] | Starts with Tonight for the current location; PRO is shown in onboarding [F 23] | Tonight [F 23] | Saved locations, community events [F 23] | iOS 26+ | Everything free since 10.2026 (previously PRO) [F 23] |
| **Stargazing Hub** (`com.twtapp`) [24]–[26] | Viewfinder and mosaics, calculators [F 24] | Calculators for night photography and guiding [F 24] | — | **0–100 % index** with thresholds; model tabs (Clear Sky Chart, hourly based on ECMWF, 15-day OpenWeather) [F 25] | Phase, rise and set; **"moonless night" periods** below the index [F 25] | n/a | Index, then forecast tabs [F 25] | n/a | Android, iOS, WeChat; 10K+, 4.5★ (242) [F 24] | Freemium, ads and subscription [F 24] |
| **N.I.N.A.** (plan model) [27]–[29] | Rows: Total #, Time, Type (LIGHT/DARK/FLAT/BIAS), Filter, Binning, Dither every N, Gain, Offset; **a new row inherits the previous one**; **Estimated Finish Time** including download time [F 27] | — | — | — | — | — | — | Sets of sequences per target [F 27] | Windows (control) | Free (open source) [I] |
| **ZWO ASIAIR** (plan model) [30][31] | Autorun: sequences, "Group by Slot", Plan mode for multiple targets; calibration is recommended to be included in the plan [F 30][F 31] | — | **"Estimated size"** together with "Estimated time", to "check the feasibility" [F 30] | — | — | — | — | — | Device and app | Bundled with the hardware |
| **Scope Nights** (iOS) [32] | — | — | — | "Smart stargazing ratings", custom thresholds (Moon, wind, humidity, T), up to 7 nights and 7 locations [F 32] | Phase, rise and set [F 32] | n/a | Best locations today (badge) [F 32] | Favourite locations [F 32] | iOS | Paid ($6.99) [F 44] |
| **Deep-Sky Planner 9** [33] | Observing Plans [F 33] | — | — | n/a | n/a | — | — | Observation log, exchange via OpenAstronomyLog, backup [F 33] | Windows (+ Mobile) | Paid [F 33] |
| **SkyTools** [34] | Planner for the equipment and conditions [D 34] | **Models "detector signal-to-noise"** [D 34] | n/a | n/a | n/a | — | — | Logbook and projects, per a user review [F 36] | Desktop | Paid [I] |
| **AstroPlan (iOS, Project 2022 Ltd)** [40] | Ranked targets for the night, calendar [F 40] | — | — | Dashboard: cloud cover, wind, darkness; Open-Meteo [F 40] | Phase on the dashboard [F 40] | No account [F 40] | "Home dashboard" [F 40] | Rigs with FOV (Pro) [F 40] | iOS | Freemium, AI chat [F 40] |

**Note 1 — `com.twtapp`.** The listing `play.google.com/store/apps/details?id=com.twtapp` is
**"Stargazing Hub: Astro Guide"**, developer KnockDream Technology. Play shows 4.5★ from 242
reviews, 10K+ installs, "Contains ads", in-app purchases, updated 16.10.2026 [F 24]. The
developer's website (Fuzhou Knock Dream Technology, Chinese 天文通, "Tianwentong") gives the address
twtapp.com [F 26]. The Stargazing Index guide describes three kinds of forecast below the index:
- the "Clear Sky Chart" (晴天钟) by Dr. Ye Quanzhi: updated 4 times a day, 3 h step, cloud cover,
  seeing, transparency;
- an hourly forecast based on ECMWF;
- a 15-day forecast from OpenWeather, which is not part of the index [F 25].

The tabs in the owner's screenshot are ICON / 7Timer / 15 Days / Climate / Clear Outside. That
"7Timer" corresponds to the Clear Sky Chart (the author of 7Timer! is the same Ye Quanzhi), and that
ICON, Climate and Clear Outside appeared in an app version newer than the guide, is **[I]**. No such
tabs appear in open sources.

**Note 2 — name collision (input for R2d, no conclusion).** Found:
- the iOS app **"AstroPlan"** (Project 2022 Ltd, released 13.06.2026) [F 40];
- **"Astro Planner: DarkScout"** — DarkScout's former name in search results [D 23];
- the desktop **AstroPlanner** (iLanga) [F 22];
- an "Astro Planner" web tool on the AstroBin forum [D 41].

## 3. User review themes

"Source" — an independent venue (product, thread, forum). "n" — the number of reviews or posts in the
examined slice. Themes supported by fewer than 2 independent sources are marked **anecdote**.

| # | Theme | Support | Strength |
|---|---|---|---|
| T1 | **Multi-night per-target totals and a session logbook.** Users want to see how much has been captured per target, and currently track it in spreadsheets | AstroBin logbook thread (page 1 of 3, 52 replies): 4 keep a spreadsheet, 3 more plan to start; the rest — paper (2), Access (1), Apple Notes (1), SkyTools (1), AstroPlanner (1), AstroBin as a logbook (1). Fields: target, date, frame count, frame length, session total, filters, mosaic panel, calibration sets, rotation angle, weather [F 36]. AstroBin poll: 45 votes, 71 % enter each night separately, 27 % combine into one date; the author complains that entering 12+ nights is "too much of a pain" [F 37]. Three independent requests on the Telescopius forum in 2025 (logbook, Imaging Tracker, tracking what has been captured); the developer confirms the feature does not exist [F 2][F 3][F 4]. A self-hosted Nova DSO Tracker exists (projects, integration total, import of ASIAIR and N.I.N.A. logs) [F 39] | **Recurring**: ≥4 independent sources |
| T2 | **When the forecast provider fails, the app becomes useless** | Scope Nights: about 20 of 40 recent reviews — "forecast unavailable", errors, "abandoned" [F 32]. Astrospheric: 4 of 40 — "network error", stopped working, no data in Hawaii, cannot get past the location-permission screen [F 9]. Per a search retelling, 7Timer ASTRO is marked "deprecated" in one data catalogue [D] | **Recurring**: 2 products, ≥24 reviews |
| T3 | **Cloud forecast accuracy is not trusted; data is cross-checked across several sources** | Astrospheric: 4 reviews against the accuracy, about 6 for [F 9]. The Stargazing Hub guide itself advises combining models [F 25]. Cloudy Nights (secondary): consensus "no app is reliable everywhere", cross-checking with Windy and satellite [D 41]. The Astrospheric Pro strategy is a model ensemble [F 7] | **Recurring**: 3 sources (one secondary) |
| T4 | **At-a-glance readability versus clutter and cryptic icons** | Praise for Clear Outside as "no cartoonish pictures, organised" — 2 of 3 visible Play reviews [F 11]. Scope Nights: "quick glance" — 3 reviews [F 32]. Astrospheric: "too hard to look at… cryptic icons", "gripe — layout and UI" — 2 [F 9]. Astroweather (7Timer client): "no legend, unclear", "grey and blue lines" — 2 of 3 [F 35]. Sky Tonight: "cluttered" — 1 [F 19] | **Recurring**: 5 products, ≥10 reviews |
| T5 | **Steep learning curve of powerful planners** | PhotoPills: 5 of 30 recent reviews ("steep learning curve", "confusing", "difficult to learn"); 4 others praise the tutorial videos [F 15]. AstroPlanner: "intimidating at first" [F 36]. PhotoPills itself builds its entry around "set a goal" and "pain → pill" [F 14] | **Recurring**: 2 products |
| T6 | **Account and sign-in as a barrier** | Telescopius: 4 of 8 recent reviews — cannot sign in, "loses your lists" [F 42]. Astrospheric: "paid, but cannot restore Pro" — 1 [F 9]. Positive contrast: AstroPlan (iOS) advertises "No account required" [F 40] | **Recurring**: 2 products |
| T7 | **Aversion to subscriptions, preference for a one-time purchase** | Astrospheric: 2 on the App Store and 1 on Play [F 9][F 8]. Sky Tonight: "glad of the lifetime option" — 1 [F 18]. PhotoPills: "paying a second time when changing device" — 2 [F 13][F 15] | **Recurring**: 3 products (not applicable to AstroPlan: free, GPL) |
| T8 | **"All in one" is valued** | Stargazing Hub: "replaces about 5 separate apps" — 2 of 3 visible reviews [F 24]. Astrospheric: "All In One", "everything I need in one place" — 2 [F 9]. Sky Tonight: "Complete! all in one place" — 1 [F 19] | **Recurring**, but in favour of all-in-one apps. In conflict with K4 — see §4 RA-A |
| T9 | **Custom thresholds and display settings** | Astrospheric: smoke cannot be fully disabled in transparency — 1 [F 9]. Clear Outside: "no settings anywhere", default location is England — 1 [F 11]. Astroweather: "zero customization" — 1 [F 35]. Scope Nights sells "custom thresholds" [F 32]; DarkScout — "choose your own thresholds" for alerts [F 23] | **Recurring** (3 complaints, 2 products with the feature), but each complaint is an anecdote |
| T10 | Widgets | Astrospheric: "Please add widgets" — 1 [F 9]. PhotoPills: widgets are the first step of the guide, including the "5 upcoming plans" widget [F 14] | **Anecdote** in reviews; the feature exists in 1 product |
| T11 | Calibration in the plan breaks or is forgotten | ASIAIR: a user writes that bias frames were not captured in Autorun (per a search retelling) [D]. The ZWO manual recommends including darks, flats and bias in the plan [F 31]. In AstroBin logbooks calibration is recorded next to the session [F 36] | **Anecdote**, with one primary-source recommendation |
| T12 | Request for "integration time" and "how much needs to be captured" | AstroBin: a request for an app for "dithering and total integration time needed" — 0 replies [F 45]. A Telescopius user refers to a thread about finding targets "that allow collecting enough subframes" [F 2]. Search also names SkyPlanner and a web "Astro Planner" with an integration estimate [D 41] | **Anecdote / weak**: few direct reviews |

## 4. By RA area

### RA-A — Product scope (Phase A: RA-A01, A02, A03, A04, A05, A06, A07, A08, A09; K4)

**What users expect.**
- A multi-night summary of "what has been captured per target" and a simple logbook. Today this is
  done with spreadsheets (T1) [F 36][F 37][F 2]–[F 4].
- A forecast that can be trusted, cross-checked across several sources (T3), and a clear
  presentation (T4).
- Some users want "all in one" (T8) [F 24][F 9]. This directly contradicts the owner's direction
  «не повторять погоду и положения объектов» [do not duplicate weather and object positions]
  (K4, RA-A06). The contradiction is recorded, but not resolved here.

**How the best do it.**
- The market is split by task [I]:
  - "when and where" — Clear Outside, Astrospheric, Scope Nights, DarkScout, Stargazing Hub
    [F 10][F 7][F 32][F 23][F 25];
  - "what and how in the frame" — Stellarium, Sky Tonight, SkySafari, Telescopius [F 17][F 18][F 20][F 1];
  - "how to capture", i.e. executing the plan at the telescope — N.I.N.A. and ASIAIR [F 27][F 30];
  - "what has been captured" — spreadsheets, AstroBin, desktop planners with a logbook (AstroPlanner,
    Deep-Sky Planner, SkyTools) [F 36][F 22][F 33].
- The model "capture plan → time estimate → storage estimate → feasibility check" exists, but
  inside control software and at the telescope. ASIAIR shows "Estimated time" and "Estimated size"
  to check feasibility [F 30]. N.I.N.A. shows "Estimated Finish Time" [F 27].
- The examined mobile planners (Telescopius, DarkScout, Sky Tonight, SkySafari, AstroPlan iOS) have
  no screen of the form "plan of frames × exposures → integration, storage, does it fit the night"
  [F 1][F 23][F 18][F 20][F 40] — **[I]** from their descriptions; absence of a feature is not
  proven by marketing text.
- Absolute SNR: of the products found, only SkyTools (desktop, paid) claims to model
  "detector signal-to-noise" [D 34]. No mobile equivalent was found [I].

**Where AstroPlan differs or duplicates.**
- AstroPlan's core (RA-A02 Capture Plan, RA-A04 storage, RA-A05 records) falls into an
  **underserved combination**: "plan before going out, without hardware control" plus "logbook and
  per-target summary" [I from T1 and the matrix]. ASIAIR and N.I.N.A. compute the same thing, but at
  execution time and with the hardware [F 30][F 27].
- Duplication: the detailed weather screen (RA-A06, RA-E02/E03) overlaps with Clear Outside and
  Astrospheric. "What can I image tonight?" (RA-D06) overlaps with Telescopius, Sky Tonight and
  DarkScout [F 1][F 18][F 23]. The specialised equivalents go deeper on these functions: model
  ensemble, seeing, FOV simulator [F 7][F 1] — [I].
- √N as a relative stacking gain (RA-A03) has no direct equivalent in mobile products [I]. The risk
  of misreading an "approximate SNR" remains for R2b.

**What it is sensible NOT to do.**
- Do not build a planetarium, an AR sky map or a framing simulator with mosaics. This is covered by
  apps with millions of installs (Stellarium 10M+, Sky Tonight 5M+) and Telescopius [F 17][F 18][F 1].
  Mosaics and the sky map are outside the approved scope anyway (CLAUDE.md).
- Do not build an own seeing and transparency model, a cloud-model ensemble or light-pollution maps:
  [F 7][F 25]; the link to lightpollutionmap is already decided (M2).
- Do not add community, ISS or AI chat: [F 23][F 10][F 40] — outside the product's task [I].
- Do not introduce a "black-box" Astro Score or a 0–100 % index (§4 RA-E): this is prohibited by
  CLAUDE.md and ADR-012, even though it is the norm among competitors [F 23][F 25][F 18][F 32].

### RA-B — Onboarding (Phase A: RA-B01…B06)

**What users expect.**
- An immediately useful screen with no barrier. An account is a frequent source of complaints
  (T6: Telescopius 4 of 8) [F 42].
- A crash on the location-permission screen makes the app unusable (Astrospheric,
  Lockdown mode — anecdote) [F 9].
- Complaints about complexity (T5) show that a powerful tool without an entry point drives users
  away [F 15].

**How the best do it.**
- DarkScout: "Start with Tonight at your current location: go/no-go guidance"; PRO is shown
  inside onboarding [F 23].
- Clear Outside: "Location search automatically provides a forecast for your location" — no
  wizard [F 11].
- Stellarium: value immediately — point the phone at the sky [F 17].
- PhotoPills: the first step it recommends is enabling widgets, then "set a goal", and it provides a
  "pain → the right tool" table [F 14]. This is entry through a task, not through data entry.
- AstroPlan (iOS) emphasises "No account required" [F 40].

**Where AstroPlan differs or duplicates.**
- AstroPlan already has no account and keeps data local. This matches best practice [I].
- Difference: Welcome is a separate screen with 3 optional steps (site, rig, target); RA-B04 and B05
  note verbose descriptions. Home is briefly visible before Welcome (RA-B01).
- The best equivalents do not ask for a rig or a target before the first value: DarkScout and Clear
  Outside start with the location [F 23][F 11] — [I].
- AstroPlan's rig-dependent value (integration, storage) requires at least a camera class.
  Therefore "starting with the location only" may postpone the product's core [I].

**What it is sensible NOT to do.**
- Do not introduce an account or sign-in [F 42].
- Do not make onboarding that cannot be skipped; do not put a paywall in onboarding (DarkScout
  removed PRO from onboarding when it moved to everything free [F 23]) — [I].

### RA-D — Home (Phase A: RA-D01…D06)

**What users expect.**
- A quick answer to "is tonight worth it" and "what about my plan": T4, praise for "quick glance" and
  "at a glance" [F 32][F 11].
- Widgets as an extension of Home outside the app (T10, anecdote) [F 9][F 14].

**How the best do it.**
- DarkScout: Home = "Tonight", go/no-go and conditions [F 23].
- SkySafari: "Tonight at a Glance" — Sun and Moon, events of the month, best DSOs of the evening [F 20].
- AstroPlan iOS: "Home dashboard with moon, Bortle, cloud, wind, and darkness" plus ranked
  targets [F 40].
- Stargazing Hub: index at the top, below it forecast tabs, moonless windows, AQI, light pollution [F 25].
- PhotoPills: Home is a tools menu; upcoming plans are moved into the "5 upcoming plans" widget [F 14].

**Where AstroPlan differs or duplicates.**
- AstroPlan's Home places the plan above the night card (ADR-019 §6, S6.16 order); weather is
  condensed to cloud cover (RA-D03).
- The owner wants weather at the top, then the entry into the planner (RA-D03, D05). None of the
  "planners" among the equivalents puts its own capture plan on Home [I]. The closest example is
  PhotoPills with "upcoming plans" in a widget [F 14].
- The "New plan" button at the bottom (RA-D04) has no equivalent. In PhotoPills a new plan is
  created from the Planner (Load/Save) [F 14] — [I].
- The "Site · night" context as the first block (RA-D02) repeats what weather equivalents show as
  the location header [F 10][F 7] — [I].

**What it is sensible NOT to do.**
- Do not turn Home into a weather dashboard on the level of Astrospheric [F 7].
- Do not put a single-number "night rating" on Home (ADR-012) — [I].

### RA-E — Weather and Moon (Phase A: RA-E01…E06, D03)

**What users expect.**
- Cloud cover first, broken down by layer (Clear Outside, "emphasis on cloud cover") [F 10].
- For part of the audience — seeing and transparency, including smoke [F 7][F 25]. There is a
  request for more detail on seeing and the jet stream (anecdote) [F 9].
- Model cross-checking (T3) and honesty about data unavailability (T2).
- A clear legend and colours: for Astroweather — a complaint about the missing key (anecdote) and a
  request for "green to red" [F 35].
- Moon: phase, illumination, rise and set — everyone has them [F 10][F 7][F 13]. "Moonless
  windows" — in Stargazing Hub [F 25]. A phase calendar — in Sky Tonight and PhotoPills [F 18][F 13].

**How the best do it.**
- **Weather.**
  - Clear Outside: 7 days hourly, 4 cloud-cover rows, then ordinary weather "without cutesy
    graphics" [F 10].
  - Astrospheric: hourly grid for 84 h, cloud layers, transparency (with smoke) and seeing, wind,
    temperature, dew point, Sun and Moon lines on the grid; model ensemble in Pro [F 7][F 8].
  - Stargazing Hub: 0–100 % index with thresholds (<40 % — very poor, ≥85 % — excellent; ≥70 % is
    recommended), 3-day horizon, model tabs, 15 days outside the index [F 25].
  - DarkScout: Astro Score and hourly decisions that account for precipitation [F 23].
  - Scope Nights: ratings with user-defined thresholds [F 32].
- **Coverage.** Per search results, Astrospheric's RDPS model covers Canada, the US and part of
  Mexico [D 43]. This supports the review "No data available in Hawaii" [F 9].
- **Moon.**
  - Astrospheric: a separate card (phase, altitude, illumination, age, next phase) [F 7].
  - Clear Outside: rise, set and phase next to the darkness periods [F 10].
  - Stargazing Hub: "Moonless Night" directly below the index [F 25].

**Where AstroPlan differs or duplicates.**
- AstroPlan shows 11 hourly Open-Meteo variables without seeing and transparency (RA-E02/E03).
  Freshness and "no forecast" states already exist (RA-E05, ADR-012).
- Rejecting a rating and "good/bad" colouring is a deliberate difference from DarkScout, Stargazing
  Hub, Scope Nights and Sky Tonight [F 23][F 25][F 32][F 18]. The T4 reviews show that clarity and a
  legend are valued, not necessarily a rating [I].
- The Moon in AstroPlan is "MoonDuringDark" without a phase name and without a calendar (RA-E01).
  The equivalents always show the phase and percentage [F 7][F 10]. Windows of "dark without the Moon"
  are shown explicitly by Stargazing Hub [F 25].
- The forecast saved in the plan snapshot is not shown anywhere (RA-E06). No "forecast ↔ record"
  link was found among the equivalents [I].

**What it is sensible NOT to do.**
- Do not chase a model ensemble and an own seeing model (Astrospheric is a specialised product with
  its own models) [F 7].
- Do not build weather that breaks the app without its provider (T2) [F 32]. AstroPlan's offline core
  is an advantage; it is worth keeping [I].
- Do not introduce a numeric index (ADR-012).
- Seeing and transparency sources (7Timer and others), their licences and failures are the subject
  of R2c, not R2a.

### RA-F — Planner and Capture Plan (Phase A: RA-F01…F11)

**What users expect.**
- To know in advance how many subframes can realistically be collected for a target [F 2] and the
  multi-night total per target (T1).
- Calibration is kept next to the lights [F 36][F 31].
- There are no direct, widespread reviews about an "integration calculator" (T12 — a weak theme).

**How the best do it (plan model).**
- **N.I.N.A., Sequence.** Rows contain Total #, Time, Type (BIAS/DARK/LIGHT/FLAT), Filter,
  Binning, Dither and Dither every #, Gain, Offset (only if the camera supports it) [F 27].
  - A new row is "defaulted to the previous one" [F 27].
  - "One after another" and "Loop" modes (filter alternation) [F 27].
  - "Estimated Finish Time" accounts for the number and length of frames plus download time [F 27].
  - Advanced sequencer: start, target and end containers; conditions such as "Loop Until Time"
    (for example, until nautical dawn); one dither per filter cycle [F 28][F 29].
- **ASIAIR.**
  - Autorun stores the target name, "Group by Slot", "Estimated time" and "Estimated size", which
    "help you check the feasibility" [F 30].
  - The Plus manual recommends including darks, flats, bias and lights in the plan [F 31].
  - Plan mode — several targets in a row [F 31].
- **PhotoPills.** Calculators (Spot Stars and others) are separate from the Planner; saved plans live
  in "My Stuff" [F 14].

**Where AstroPlan differs or duplicates.**
- AstroPlan's block model (type, filter, exposure × count, ISO/gain, binning, overheads, storage,
  fit within the night) structurally matches N.I.N.A. and ASIAIR. This confirms the chosen model
  (RA-A02, RA-F01) — [I].
- Match with the industry pattern: prefilling a new light block from the previous one (RA-F05,
  ADR-020 P2) is also done by N.I.N.A. [F 27]. This is not an argument for or against the owner's
  complaint, but a precedent.
- Inheriting calibration from the lights (RA-F08) matches ZWO's recommendation to keep calibration
  in the plan [F 31].
- A storage estimate (RA-A04) exists in ASIAIR [F 30]. No such estimate was found among mobile
  planners [I].
- Binning and ISO/Gain for the Unknown class (RA-F06): N.I.N.A. shows Gain and Offset only when the
  camera supports them [F 27]. The principle "show according to camera capabilities" is common — [I].
- Overheads and Assumptions (RA-F09, H02): N.I.N.A. takes download time from measurements
  [F 27]; AstroPlan takes it from settings. The AstroPlan user enters the assumptions themselves — [I].
- Example plan (RA-F04): no equivalent of "insert an example plan" was found [I].

**What it is sensible NOT to do.**
- Do not replicate a sequencer: conditions, triggers, autofocus, dither as a command, real-time
  altitude tracking. This is hardware control [F 28], and AstroPlan is not a controller (RA-F11).
- Do not promise absolute SNR without a SkyTools-level model [D 34]. The choice of option belongs to R2b.
- Whether to make "pro mode" WB or focus an input field is a question for R2b (RA-F07). Planner
  equivalents have no such fields [I].

### RA-G — Records, logbook and lists (Phase A: RA-G01…G05)

**What users expect.**
- Total integration per target across all nights; linking calibration sets to sessions; a "want to
  capture" list separate from "captured"; filtering by target or by filter [F 36].
- Simple multi-night tracking (AstroBin poll) [F 37].
- The ability to export data: spreadsheet, AstroBin [F 36][F 38].

**How the best do it.**
- In users' spreadsheets (AstroBin): two tabs, "sessions" and "future targets"; an auto-sum "Total
  Exposure / Integrated Exposure"; an equipment list as a reference [F 36].
- Telescopius: target lists with notes; an "Exclude objects on these lists" filter to hide what has
  already been captured. The developer gives the note limit as 300 in one place and 1000 characters
  in another [F 2][F 3][F 4].
- AstroPlanner and Deep-Sky Planner: sessions → observations, equipment manager; DSP has exchange via
  **OpenAstronomyLog** and backup [F 22][F 36][F 33].
- Nova DSO Tracker: "Projects" with statuses (In Progress / On Hold / Completed / Abandoned),
  auto-sum of integration, import of ASIAIR, PHD2 and N.I.N.A. logs [F 39].
- AstroBin accepts an acquisition CSV: date, filter (ID), number, duration, iso, binning, gain,
  sensorCooling, darks, flats, flatDarks, bias, bortle, meanSqm, meanFwhm, temperature [F 38].

**Where AstroPlan differs or duplicates.**
- The Logbook (Upcoming/Past, filters, Plan vs actual) and Progress by target (RA-G01) cover T1
  more closely than any examined mobile equivalent [I].
- Gaps relative to expectations:
  - single-record export and Copy are hidden in the detail screen (RA-G04);
  - there is no "AstroBin CSV" or OAL format — per Phase A there is an own export v2 [I];
  - in the Library, "Plan this target" is hidden (RA-G02); Telescopius has a direct path "from the
    list to planning" [F 4] — [I].

**What it is sensible NOT to do.**
- Do not build a community or gallery (AstroBin, Telescopius) [F 1].
- Do not replicate N.I.N.A. and ASIAIR log parsing in the first release. A separate tool exists
  [F 39]; this work requires a separate scope decision [I].

### RA-H — Settings (Phase A: RA-H01…H03)

**What users expect.**
- Units of measurement (PhotoPills: Settings > Units) [F 14].
- Custom "good night" thresholds (Scope Nights, DarkScout) [F 32][F 23].
- The ability to disable an unneeded data layer (smoke in Astrospheric — anecdote) [F 9].
- A default location (Clear Outside: "defaults to England", "no settings" — anecdote) [F 11].
- A dark or night mode: a red mode exists in Stellarium, Sky Tonight, DarkScout and
  Stargazing Hub [F 17][F 18][F 23][F 24].

**How the best do it.**
- Settings are usually short: units, backup and sync, notifications [F 14].
- Complexity is moved into objects rather than global settings: thresholds go to the location or
  to the alert [F 23][F 32] — [I].

**Where AstroPlan differs or duplicates.**
- 17 rows, most of them overheads and imaging-window thresholds (RA-H01). The owner and Phase A
  note that some depend on the rig or mount (RA-H02). In execution-side equivalents these are
  properties of the profile or sequence: Gain and Offset in the row, download time is measured
  [F 27] — [I].
- There is no theme or unit selection (RA-H03). Among the equivalents, units are a standard
  setting [F 14].
- AstroPlan has a red mode (TASK 12.4, per project memory; not separately checked in Phase A).

**What it is sensible NOT to do.**
- Do not turn settings into a store of scientific assumptions the user does not understand (T5) —
  [I].

## 5. Implications for the decision package (options only, no decisions)

1. **Positioning (RA-A06, K4).**
   - Option A: "capture plan + logbook" as the core; weather and Moon as a short summary with a link
     to external apps.
   - Option B: keep the current amount of weather and candidates, but lower them in the hierarchy.
   - Option C: move towards "all in one" (T8).
   Argument for A — an unoccupied niche [I] and the owner's direct direction. Argument for C — the T8
   reviews. Risk of C — competing with products that have millions of installs [F 17][F 18].
2. **Weather on Home (RA-D03, E02).**
   - Option W1: cloud cover by layer and the darkness window in the style of Clear Outside, without a
     rating.
   - Option W2: the same plus a multi-night overview. A multi-night forecast exists in all weather
     equivalents [F 10][F 32][F 23].
   - Option W3: only a link or "Open in…".
   A 0–100 % index in the style of Stargazing Hub or DarkScout requires revisiting ADR-012. This is a
   separate question for the owner; per CLAUDE.md it is more likely closed.
3. **Moon (RA-E01).**
   - Option L1: phase, illumination percentage, rise and set (standard) [F 7][F 10].
   - Option L2: plus tonight's "moonless dark window" [F 25].
   - Option L3: plus a monthly calendar [F 18][F 13].
   The scientific part and the computation cost are in R2b and R2c.
4. **Onboarding (RA-B01…B06).**
   - Option O1: start directly on Home for the location, everything else on demand (DarkScout, Clear
     Outside) [F 23][F 11].
   - Option O2: the current 3 steps, but shorter and with a single button.
   - Option O3: entry through a "task", as in PhotoPills [F 14].
   In all options — no account (T6).
5. **Planner (RA-F05, F06, F09).** Industry precedents: inheriting the previous row
   [F 27]; fields according to camera capabilities [F 27]; time and storage estimates to check
   feasibility [F 30]; calibration in the plan [F 31]. Options for RA-F05: keep P2 (like N.I.N.A.),
   make the prefill visually "suggested", or remove it. The choice belongs to R2b and R2e.
6. **Records (RA-G01, G02, G04).**
   - Option R1: strengthen the "per-target total" and the calibration-to-session link (T1).
   - Option R2: add export in AstroBin CSV [F 38] or OpenAstronomyLog [F 33] format
     (reuse of a standard, RA-A09). Requires checking field correspondence and a decision on the
     export format (`docs/EXPORT_MANIFEST.md` is versioned).
   - Option R3: leave as is.
7. **Settings (RA-H02, H03).**
   - Option S1: move rig-dependent overheads into the rig or mount.
   - Option S2: add units and theme.
   - Option S3: keep window thresholds next to the site.
   Each changes the data model (input for R2b, R2e).
8. **What not to do (summary):** planetarium and AR; framing and mosaics; own seeing and
   model ensemble; light-pollution maps; community; AI chat; hardware control; index rating.
   Rationale — §4.
9. **Naming risk (for R2d, no conclusion):** collisions with "AstroPlan" (iOS, 2026), "AstroPlanner"
   (iLanga), "Astro Planner" (DarkScout, AstroBin) — §2, note 2.
10. **Evidence gap (K14):** review themes do not replace testing AstroPlan's own UX with real
    people. Reddit and Cloudy Nights were not read (§1).

## 6. Sources (access date for all: 2026-10-17)

1. Telescopius — App Store (description via the Lookup API): https://apps.apple.com/us/app/telescopius/id6479415751 ; https://itunes.apple.com/lookup?id=6479415751&country=us
2. Telescopius Forum, «I want to See Enhanced Planning Tools for Astrophotography Sessions» (07–08.2025): https://forum.telescopius.com/t/i-want-to-see-enhanced-planning-tools-for-astrophotography-sessions/1847
3. Telescopius Forum, «Imaging Tracker» (08.2025): https://forum.telescopius.com/t/imaging-tracker/1863
4. Telescopius Forum, «Catalog / Shooting tracking» (10.2025): https://forum.telescopius.com/t/catalog-shooting-tracking/1894
5. Telescopius Forum, «Imaging Opportunities» (08–11.2025): https://forum.telescopius.com/t/imaging-opportunities/1864
6. Telescopius developer's Patreon (only via search results, [D]): https://www.patreon.com/sebagr/about
7. Astrospheric — official website: https://www.astrospheric.com/ ; https://www.astrospheric.com/help
8. Astrospheric — Google Play: https://play.google.com/store/apps/details?id=com.astrospheric.dfior.astrospheric
9. Astrospheric — App Store reviews (RSS, most recent 50): https://itunes.apple.com/us/rss/customerreviews/page=1/id=1166046863/sortby=mostrecent/json
10. Clear Outside — app page: https://clearoutside.com/page/app/
11. Clear Outside — Google Play: https://play.google.com/store/apps/details?id=com.firstlightoptics.clearoutside
12. Clear Outside — App Store (Lookup and RSS): https://itunes.apple.com/lookup?id=6755946435&country=us ; https://itunes.apple.com/us/rss/customerreviews/page=1/id=6755946435/sortby=mostrecent/json
13. PhotoPills — Google Play: https://play.google.com/store/apps/details?id=com.photopills.android.photopills
14. PhotoPills User Guide: https://www.photopills.com/user-guide
15. PhotoPills — App Store reviews (RSS): https://itunes.apple.com/us/rss/customerreviews/page=1/id=596026805/sortby=mostrecent/json
16. Stellarium Mobile Plus — Stellarium Labs: https://stellarium-labs.com/stellarium-mobile-plus/
17. Stellarium — Google Play: https://play.google.com/store/apps/details?id=com.noctuasoftware.stellarium_free
18. Sky Tonight — Google Play: https://play.google.com/store/apps/details?id=com.vitotechnology.sky.tonight.map.star.walk
19. Sky Tonight — App Store reviews (RSS): https://itunes.apple.com/us/rss/customerreviews/page=1/id=1570594940/sortby=mostrecent/json
20. SkySafari — official website: https://skysafariastronomy.com/
21. SkySafari 8 Pro — Google Play: https://play.google.com/store/apps/details?id=com.simulationcurriculum.skysafari8pro
22. AstroPlanner (iLanga, Inc.): https://www.astroplanner.net/ ; https://www.astroplanner.net/about.html ; https://www.astroplanner.net/purchase.html (price not displayed — template not filled in)
23. DarkScout — App Store (description, version history): https://apps.apple.com/us/app/darkscout/id6760223860
24. Stargazing Hub: Astro Guide (`com.twtapp`) — Google Play: https://play.google.com/store/apps/details?id=com.twtapp ; App Store: https://itunes.apple.com/lookup?id=1478601599&country=us
25. Stargazing Hub — Stargazing Index guide (EN and CN): https://laysky.com/en/guide/miniapp/stargazing-index.html ; https://laysky.com/guide/miniapp/stargazing-index.html
26. Stargazing Hub / 天文通 — developer website: https://laysky.com/en/
27. N.I.N.A. Documentation — Sequence tab: https://nighttime-imaging.eu/docs/master/site/tabs/sequence/
28. N.I.N.A. Documentation — Advanced Sequencer: https://nighttime-imaging.eu/docs/master/site/sequencer/advanced/advanced/
29. N.I.N.A. Documentation — Simple to Advanced: https://nighttime-imaging.eu/docs/master/site/sequencer/advanced/simpletoadvanced
30. ZWO ASIAIR User Manual (section 4.9 Autorun): https://i.zwoastro.com/zwo-website/manuals/ZWO_ASIAIR_User_Manual.pdf
31. ZWO ASIAIR Plus User Manual V1.3 (sections 3.3.6–3.3.9): https://i.zwoastro.com/wp-content/uploads/2026/03/65dcf5cda6be810ffda56fcaed20a573.pdf
32. Scope Nights Astronomy Weather — App Store (Lookup and RSS): https://itunes.apple.com/lookup?id=540120977&country=us ; https://itunes.apple.com/us/rss/customerreviews/page=1/id=540120977/sortby=mostrecent/json
33. Deep-Sky Planner 9 (Knightware): https://www.knightware.biz/dsp/index.htm
34. SkyTools (Skyhound): https://skyhound.com/skytools.html
35. Astroweather (7Timer client) — Google Play: https://play.google.com/store/apps/details?id=cc.meowssage.astroweather
36. AstroBin Forum, «Do you keep a logbook of your imaging?» (03.2023, page 1 of 3): https://app.astrobin.com/forum/topic/66070
37. AstroBin Forum, «Poll: How do you enter all of your acquisition details when captured across multiple nights?» (10.2024): https://app.astrobin.com/forum/topic/143290
38. AstroBin — «Importing acquisitions from CSV»: https://welcome.astrobin.com/importing-acquisitions-from-csv
39. Nova DSO Tracker — Docker Hub: https://hub.docker.com/r/mrantonsg/nova-dso-tracker
40. AstroPlan (iOS, Project 2022 Ltd) — App Store: https://apps.apple.com/us/app/astroplan/id6774190371 ; https://itunes.apple.com/lookup?id=6774190371&country=us
41. Cloudy Nights — threads about weather apps (**unavailable**, 403 Cloudflare; only search results used, [D]): https://www.cloudynights.com/forums/topic/887387-how-reliable-are-weather-apps/ ; https://www.cloudynights.com/forums/topic/876926-reliable-cloud-forecast/ ; https://www.cloudynights.com/forums/topic/973095-weather-apps-for-observation/ ; https://www.cloudynights.com/forums/topic/873149-what-weather-app-would-you-recommend/ ; the "Astro Planner" web tool on AstroBin (did not open): https://app.astrobin.com/forum/topic/216286
42. Telescopius — App Store reviews (RSS, 8 items): https://itunes.apple.com/us/rss/customerreviews/page=1/id=6479415751/sortby=mostrecent/json
43. Astrospheric RDPS model coverage (per search results, [D]); on the Astrospheric website: "Forecast data provided by the Canadian Meteorological Centre": https://www.astrospheric.com/DynamicContent/astrospheric.php
44. iTunes Search API (prices, ratings, version dates): https://itunes.apple.com/search?term=photopills&entity=software&country=us (likewise for the other names)
45. AstroBin Forum, «Astrophotography App for dithering and integration time needed» (09.2024, 0 replies): https://app.astrobin.com/forum/topic/137614
