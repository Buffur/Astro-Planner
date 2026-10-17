# RA.R2d — Identity: name, app id, mark, splash, icons and animations

> Prepared 2026-10-17 for RA.R2, task R2d (`docs/refinement/prompts/RA_R2_RESEARCH_PLAN.md` §3).
> Covers findings RA-C01, RA-C02, RA-C03, RA-C04, RA-A09, part of RA-I04 (name) and K10
> (`research/RA_R1_PHASE_A_ASSESSMENT.md`). Documentation only. Nothing is decided: the name, app id and
> mark direction are chosen by the owner in RA.D, round 1. **Only the owner chooses the final mark (P9.4).**
> Labels: **FACT** — verified against a source listed in §9 (access date 2026-10-17);
> **INFERENCE** — the agent's conclusion; **UNKNOWN** — could not be established.

## 1. Method and limitations

**This is screening, not legal advice.** The absence of findings does not mean that a name is free to
register or use. OD-07 already requires a formal trademark search (by the owner or a lawyer) before
the first Google Play upload. This document does not replace it.

What was checked for each candidate (2026-10-17):

| Channel | How | Limitation |
| --- | --- | --- |
| Google Play | Search page `play.google.com/store/search?q=<name>&c=apps&hl=en`, read via WebFetch | Results are fuzzy and truncated at about 15 entries; results region is the US |
| Apple App Store | iTunes Search API, `itunes.apple.com/search?term=<name>&entity=software&country=us` | US storefront only; up to 6 entries |
| General web | WebSearch for the exact name, qualified with "app / software / astronomy" | A search engine, not a registry |
| GitHub | REST API `search/repositories?q=<name>+in:name` and `<name>+astro` | Substring matching produces noise |
| `.com` / `.app` domains | RDAP via `rdap.org`: HTTP 200 — a record exists (domain **registered**), 404 — no record | **A hint only**: "no record" ≠ "available to buy" (premium pricing, reservations) |
| Trademarks | Attempts to open WIPO Global Brand Database, EUIPO eSearch, USPTO Trademark Search | **Gap.** WIPO GBD requires passing a CAPTCHA (altcha), which the agent does not pass; USPTO tmsearch and EUIPO eSearch return only a JS shell (WebFetch cannot see results), and the USPTO JSON endpoint returned `MethodNotAllowed`. Instead of the registries — searches of aggregators (trademark.justia.com, trademarkia, uspto.report) via WebSearch. The Ukrainian registry (UKRNOIVI) was not checked |

Nice classes relevant to the product (INFERENCE): **9** (downloadable software, mobile apps) and **42**
(SaaS/software development). A match in another class (for example, 33 — wine) is a lower, but not zero, risk.

Risk rating (INFERENCE, qualitative):
- **low** — no exact matches in the stores, registries or niche;
- **medium** — a similar name in the niche or an exact one in an adjacent class, or weak distinctiveness;
- **high** — an exact or near-exact name in the astro niche or a strong brand in classes 9/42.

UA/RU check — sound and absence of inappropriate meanings, the agent's assessment (INFERENCE). The owner, as
a native speaker, must confirm it.

## 2. Name candidates and screening

The current name is the baseline. **Astro Planner**: in 2026 the US App Store saw "Astro Planner: Night Sky
Photo" (Daniel Vilela, 2026-03-12), "AstroPlanner" (Hayato Monma, 2026-10-12), "AstroPlan" (Martin
Wilcox, 2026-06-13) and "Free Sky Planner: DarkScout" (FACT, iTunes API). Added to this are the collisions
from Phase A: Paul Rodman's AstroPlanner (Mac/Windows), the web tool astro-planner.adfr.io, the
`astroplan` package, and from OD-07 — "Astro Planner" on Google Play (`com.astronomia.astro_planner`). **Risk
high.** Confirms RA-C01.

Fifteen candidates. All data — 2026-10-17.

| # | Name | Meaning; UA/RU | Google Play | App Store (US) | Web / TM aggregators | GitHub (in:name) | `.com` / `.app` | Risk |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| 1 | **AltArc** | altitude arc — exactly what the mark draws; «Альтарк», neutral | No exact matches; nearby "Altar…" (prayer apps), Arc Search | No exact matches; "Altar", "Altar Live" | No mentions; ALTARC not found in aggregators | 54 (noise: CentOS/AltArch), with "astro" — 0 | taken / no record | **low–medium**: visually close to "Altar"; "Alt" reads as a key or "alternative" |
| 2 | **Astrarc** | astro + arc; «Астрарк» | No exact matches; results are astrology "Astra…" apps | No exact matches | No mentions; not found in aggregators | 0 | taken / no record | **low**; positioning downside — proximity to astrology "Astra" |
| 3 | **Arcwindow** | arc + imaging window; «Арк-віндоу», somewhat long | No exact matches | No exact matches (Arc Search) | Only the Arc browser in results | 2 | taken / no record | **low**; weak point — "Arc" as The Browser Company's browser brand (class 9), "window" — association with Windows |
| 4 | **Culmina** | Lat. "summit"; culmination — the star at the top of the arc; «Кульміна / Кульмина» understandable | Nothing with "Culmin" | No exact matches; "Culminate Life" (church) | **Culmina Family Estate Winery** (Canada, wine, class 33); CULMINA not found in aggregators (probable winery registration — UNKNOWN) | 1,096 (noise "culminating"), with "astro" — 1 educational | taken / taken | **low–medium**: different class, but both domains are taken |
| 5 | Lightframe | light frame — a calibration term | "Light Frame Journal", "Lightframer Pro", "Framelight" | "Lightframer Pro" (film, sun path) | Mac app LightFrame (Corner-A); USPTO LIGHTFRAME (USG, "dead"); LITEFRAME (lighting) | 80 (EnderMo/LightFrame, 72★) | taken / taken | **high** |
| 6 | Nightframe | night frame | "Night Frames: Photo Effect" | **"Nightframe" (2026-04-03)** — "astrophotography workflow tool": session planning per setup, capture and calibration log | npm `nightframe` (MIT, web framework) | 28 | taken / no record | **high**: direct competitor in the niche |
| 7 | Night Window | night imaging window; descriptive | No exact matches (screen dimmers) | No exact matches | Nearby in the niche: **SkyWindow** (iOS, Dung Le, astrophotography planner), **Nightwatch** (macOS, open source, "clear window") | 7 | taken / taken | **medium**: a descriptive name is weakly protectable, similar names in the niche |
| 8 | PhotonPlan | photon collection plan; «Фотон План» | No exact matches (Photon Camera, Photon file share) | No exact matches (Photon Calc, Photone) | The niche is occupied by **PhotoPills** — a "photo planner" with a similar sound; TM **PHOTON** (Exit Games, US serial 86318032, software) | 1 | no record / no record | **medium**. Additionally (INFERENCE): the name pulls towards a "photon budget", which conflicts with the CLAUDE.md rule not to present √N as absolute SNR |
| 9 | Skyhours | sky hours | No exact matches | No exact matches | TM **SKYHOUR** (SKYHOUR, LDA, US serial 79223733, flight-hours software) | 3 | taken / taken | **medium–high**: almost the same word in class 9 |
| 10 | Skyslot | sky slot | **All results are casinos and slot machines** | No exact matches | Web results for "sky slot" — gambling pages | 3 | taken / taken | **medium** legally, **high** reputationally: association with gambling, "polluted" search |
| 11 | StackPlan | stack plan | No exact matches | No exact matches | **StackPlanner** (Springbord, real-estate SaaS); "stack plan" is a real-estate term | 7 | taken / taken | **medium**; besides, stacking is processing, not the product's core |
| 12 | Starwindow | star + window | No exact matches | No exact matches | Nearby in the niche — SkyWindow (iOS) | 5 | taken / taken | **medium** |
| 13 | Subframe | subframe | No exact matches | No exact matches | **Subframe** — visual UI editor (SaaS, class 9/42); automotive part | 77 (SubframeApp/subframe, 440★) | taken / taken | **high** |
| 14 | Lightbucket | "light bucket" — slang for a large telescope | No exact matches | No exact matches | **LightBucket** — NINA plugin and site app.lightbucket.co; remote observatory **LightBuckets** | 6, incl. `LightbucketAstro/lightbucket-astro-planner` | taken / no record | **high**: name taken in the same astro niche |
| 15 | Noctarc | noct(urnal) + arc; «Ноктарк» | No exact matches (Noccarc CRM, Noctra) | No exact matches ("Noctar Wallet", crypto) | **Noctar** — per a directory description, an astronomy observation planning app (single source, serchen.com) | 4 (noctarch…) | no record / no record | **medium**: one letter away from an astro app |

INFERENCE on the market: in 2026 the "astrophotography planner" niche is filling up quickly with iOS apps
named from the words *astro / sky / night / window / frame / plan*. Descriptive compound names built from these
words will almost certainly collide with something. Coined words carrying "our" semantics (arc,
culmination) are distinguishable.

## 3. Shortlist

Selected: candidates with low or low–medium risk, a link to the "altitude arc — window — star" mark and
acceptable sound in EN, UA and RU. **The order is not a recommendation**: the owner chooses.

| Name | Why it is on the list | What the owner should check before upload |
| --- | --- | --- |
| **Culmina** | The name and the mark tell one story: the star culminating at the top of the arc; the word is understandable in EN/UA/RU | The winery's registrations (class 33) in WIPO GBD and EUIPO; domains are taken — GitHub Pages remains for the privacy policy |
| **AltArc** | Literally "altitude arc" — the central idea of the mark and the planner | Visual confusion with "Altar" in results; `.app` has no record |
| **Astrarc** | A coined word, no matches found in any channel | Association with astrology ("Astra…" in Play results) — a positioning question, not a legal one |
| **Arcwindow** | Describes the arc and the imaging window, few collisions | Proximity to the Arc browser brand in class 9; length and sound in UA/RU |

Reserve (medium risk): **Noctarc** (both domains without a record, but "Noctar" is nearby), **PhotonPlan** (both
domains without a record, but PHOTON and PhotoPills are nearby).

Store title form (FACT: Google Play title limit — 30 characters): name plus descriptor,
for example "Culmina: Astrophoto Planner" (27 characters) or "AltArc — Astrophoto Planner". The descriptor
is descriptive text, not part of the brand (INFERENCE).

Unchanged under any name (trap 20): the `.astroplan` extension, `"app": "AstroPlan"` in the
export manifest and the Dart package `astroplan` — these are formats and internals. INFERENCE: the internal
"AstroPlan" now coincides with the iOS app "AstroPlan" (2026). The user sees it only in the
backup file extension; whether to change the format is a separate question, unrelated to the brand.

## 4. App id

**State (FACT, code as of 2026-10-17):** `io.github.chacha12.astroplanner` is used:
- in `android/app/build.gradle.kts` (`namespace` and `applicationId`);
- in the Kotlin package `android/app/src/main/kotlin/io/github/chacha12/astroplanner/` (`MainActivity.kt`,
  `MetadataDocumentChannel.kt`, `MetadataSequentialReader.kt`) and in the test
  `android/app/src/test/kotlin/io/github/chacha12/astroplanner/MetadataSequentialReaderTest.kt`;
- in the MethodChannel name `io.github.chacha12.astroplanner/metadata_document` — on the Kotlin side and in
  `lib/data/metadata/android_capture_file_access.dart`;
- in `AppIdentity.packageName` (`lib/core/config/app_identity.dart`);
- in `test/core/config/app_identity_test.dart`.

The `projectUrl`, `sourceUrl` and `privacyPolicyUrl` URLs (and through them `userAgent`) point to `chacha12`
and currently return 404 (TD-088, S9.12).

**Platform rules (FACT, developer.android.com/build/configure-app-module):**
- Once published, the application ID cannot be changed: Play would treat a new id as a different app.
- `namespace` and `applicationId` are technically independent, but keeping them identical is recommended.

Nothing has been uploaded to Google Play yet, so changing the id now is one Task; after the first upload it means a new
store listing.

**Options (linked to RD-01):**

| Option | id | RD-01 | Pros | Cons |
| --- | --- | --- | --- | --- |
| **I-1. Keep the id** | `io.github.chacha12.astroplanner` | any (B′ or C) | Zero code changes | The id is visible in the Play listing URL (`details?id=…`) and permanently contains "astroplanner" and "chacha12" — the old name and an account which, per S9.12, the owner does not use publicly |
| **I-2. New id under Buffur** | `io.github.buffur.<newname>`, for example `io.github.buffur.culmina` | B | The id matches the name and a domain the owner actually controls (`buffur.github.io` with Pages enabled); closes TD-088 together with the links | One code Task (below); data on the owner's phone (below) |
| **I-3. New name under chacha12** | `io.github.chacha12.<newname>` | C | The name in the id matches the brand | Requires creating and maintaining `chacha12/…` with GitHub Pages; per S9.12 this is not the owner's public account |

Scope of changes when changing the id (impact only, no implementation; trap 20):
1. Gradle: `namespace` and `applicationId`.
2. Moving the Kotlin files into the new package directory, the `package` line in each (main and test).
3. The MethodChannel name. It is internal and may stay old, but if changed it must be changed **simultaneously** in
   Kotlin and Dart, otherwise metadata import breaks.
4. `AppIdentity.packageName` / `projectUrl` / `sourceUrl` / `privacyPolicyUrl` / `userAgent` and, with a
   new name, `appName` and `android:label`.
5. `app_identity_test.dart` (it cross-checks Dart, Gradle, the manifest and `MainActivity`).
6. `docs/COMPLIANCE.md`, `docs/RELEASE.md`, `docs/privacy/index.md`.
7. Configuration of the `.s2check` debug package (a suffix to the id).

**Important consequence for data (INFERENCE from project memory; confirm with the owner):**
- The owner's phone has `io.github.chacha12.astroplanner` installed with real data.
- An app with a new id installs **alongside**, as a separate app, with an empty database.
- Migration is only through the app's backup and restore (`.astroplan`, TASK 14.4): back up in the
  old app, restore in the new one, then remove the old one manually.
- This is the owner's step; the agent does not delete or replace the owner's app.

GitHub (FACT, docs.github.com):
- Renaming a repository redirects everything **except the project's GitHub Pages site URL**.
- If the repository name `Buffur/Astro-Planner` is changed together with the name, the privacy policy URL
  on Pages changes. It must be chosen before the Play upload.
- A new repository must not be created with the old name: redirects would stop working.

## 5. Logo: directions

### 5.1 What has already been prepared (S9.10, 2026-09-29)

The owner's concept is preserved in all options: an altitude arc above the horizon, a marked imaging window,
a star at the apex. S9.10 found five execution defects:
1. the star hovers above the arc;
2. three different stroke weights;
3. the themed icon is a colour drawing recoloured into a single colour, and the window disappears in it;
4. the mark is shifted upwards;
5. the "error" red `#FF4D3D`.

Options (SVG in S9.10 §3):
- **A** — corrected original: star at the apex, one stroke system, mark lowered to the centre;
- **B** — window as the area under the arc (time), amber accent;
- **C** — minimal: no horizon, a thick arc with an amber window and a star; holds up best at
  24 px and in themed mode;
- **D** — today's mark, with only the star and the monochrome layer fixed.

### 5.2 How the directions map to the shortlist (INFERENCE; the choice is the owner's)

| Name | Natural directions | Why |
| --- | --- | --- |
| Culmina | **A** or **C** | The name means the moment of culmination; the star exactly at the top of the arc is a literal illustration of the name |
| AltArc | **C**; possibly a new **E** — monogram | The arc is the hero of the mark. E (an idea, not developed in S9.10): the arc and horizon form an "A" silhouette, the window is the crossbar |
| Astrarc | **C** with a more pronounced star | "Astr-" — star, "arc" — arc: both elements on equal terms |
| Arcwindow | **B** | The window as an area is the central meaning of the name |

Colour: S9.10 proposes moving away from error red to an amber accent (B/C). The app's red mode
(field mode) does not affect the launcher icon.

### 5.3 Platform constraints (FACT)

- **Adaptive icon (developer.android.com, icon_design_adaptive):**
  - all layers 108×108 dp; the outer 18 dp on each side are reserved for the mask and effects (the visible
    area is 72×72 dp);
  - the "safe zone" that an OEM mask never clips is **66×66 dp**; the logo is no smaller than 48×48 dp and no
    larger than 66×66 dp.
  - Clarification to the R2d brief: "72 dp" is the visible window, while the guaranteed zone is 66 dp. S9.10
    checked a circle of radius 33 around (54, 54), which is consistent with 66 dp.
- **Themed icon:**
  - since Android 13 (API 33) the system tints the `<monochrome>` layer with the wallpaper colour;
  - since Android 16 QPR 2 the system itself tints app icons that lack such a layer.
  - Currently `mipmap-anydpi-v26/ic_launcher.xml` uses the colour foreground as monochrome. The example in the
    documentation does this, but this mark needs a separate layer (S9.10 §4).
- **Google Play icon (developer.android.com, icon-design-specifications):**
  - 512×512 px, 32-bit PNG, sRGB, no larger than 1024 KB, full square;
  - Play adds the corner rounding (about 30 %) and shadow itself — do not round the corners or add a shadow;
  - transparency is best avoided;
  - no ranking or promotional elements.
- **Trap 20:** the mark is redrawn simultaneously in `drawable/ic_launcher_foreground.xml` and in
  `tool/make_launcher_icons.py`, which generates the legacy PNGs and `assets/branding/icon_512.png`.

## 6. Splash and loading animation

### 6.1 Platform facts (developer.android.com, splash-screen and migrate)

- **Android 12+ builds the splash itself** — from the launcher icon and a solid `windowBackground`, even if
  the app has configured nothing. Currently `values-v31` and `values-night-v31` set a static
  foreground on `#0B1230`.
- **Splash icon dimensions:**
  - with an icon background — 240×240 dp, content within a 160 dp circle;
  - without a background — 288×288 dp, content within a 192 dp circle;
  - a third of the foreground is masked, as with an adaptive icon.
  - The app sets `windowSplashScreenIconBackgroundColor`, so the with-background rule applies.
- **Animated icon:**
  - format — AnimatedVectorDrawable (AVD);
  - recommended duration — **no more than 1,000 ms on phones**; delayed start — no more than
    166 ms; if app startup takes longer than 1,000 ms, the documentation advises a looping animation;
  - `windowSplashScreenAnimationDuration` is needed only for API 31–32 (on 13+ the duration is taken from the
    AVD) and does not change how long the splash is shown.
- **The splash is hidden as soon as the app has drawn its first frame.** It can be held via
  `OnPreDrawListener` — this delays the first frame, and P9.4 rules that out.
- **Branding image:** 200×80 dp, but the guidelines recommend not using it.
- **Before Android 12:** `core-splashscreen` backports the API 12 behaviour to API 23+. According to the androidx reference, the
  platform behaviour is reproduced **without AVD support**, i.e. on older versions the icon is static. The
  project does not have the library: before 12, `launch_background.xml` with a static PNG is shown.
- **Flutter (docs.flutter.dev, splash-screen):** the app may continue the splash's last frame in
  Flutter and disable the exit animation to avoid flicker. This is an option, not a recommendation.
- **Reduced motion (api.flutter.dev):** `MediaQueryData.disableAnimations` reflects the Android system
  setting "Remove animations". The project already has `AppMotion.duration(context, base)`: under
  reduced motion it returns 0.

### 6.2 Proposed form (INFERENCE; consistent with P9.4 and S9.10 §5)

1. **Android 12+ — an AVD of the chosen mark** in `windowSplashScreenAnimatedIcon`:
   - the arc "draws itself" from the horizon (trim path, about 400 ms), then the window appears (about
     150 ms) and the star (about 150 ms), ≤ 1,000 ms in total;
   - start without delay;
   - looping is not needed if cold start is shorter than one second. This is **UNKNOWN** — measure on the
     owner's phone in the implementation Task.
   - The splash disappears with Flutter's first frame, so the animation **never delays startup**.
   - With "Remove animations", the system animator with scale 0 is expected to show the final
     frame immediately (INFERENCE; verify on a device).
2. **Before Android 12:** a static icon, as now; do not add `core-splashscreen`, it does not provide the animation
   there anyway.
3. **Continuation in Flutter (at the owner's discretion):**
   - instead of the bare `CircularProgressIndicator` on Tonight (`tonight_home_screen.dart`, the
     `startupVm.isLoading` branch) — the same mark in the same position;
   - a quiet cyclic "pulse" of the window that **lasts exactly as long as the real
     loading**;
   - **no deterministic progress** (P9.4: do not simulate progress);
   - with `disableAnimations` — a static mark;
   - switch to content immediately once the data is ready; the animation does not hold the screen.
   - Implemented with built-in means: `AnimationController` and `CustomPainter` or `AnimatedBuilder`
     with `AppMotion` tokens. **No package is needed.**
4. **Startup budget:** no option adds work before the first frame. Check in the implementation
   Task: time to first frame on the device before and after the change (the "Displayed" metric in
   logcat) and rendering under reduced motion.

## 7. Icons and animation libraries

GPL-3.0 compatibility (FACT, FSF license list, gnu.org/licenses/license-list):
- Apache-2.0 "compatible with version 3 of the GNU GPL" (not with GPLv2);
- Expat (MIT), ISC and Modified BSD (BSD-3-Clause) are compatible with the GNU GPL;
- CC BY 4.0 "compatible with all versions of the GNU GPL", but the FSF does not recommend it for software;
- SIL OFL 1.1 — "free copyleft license for fonts", in the section on licences for other works. There is no
  separate FSF statement on OFL compatibility with the GPL.

An OFL font in a GPL app:
- OFL §2 (FACT, licence text in Font-Awesome/LICENSE.txt): the font may be bundled with any software,
  provided every copy includes the notice and the licence.
- GPLv3 §5 (FACT, the repository `LICENSE`): an "aggregate" — a compilation with separate and independent works — does not
  extend the GPL to those works.
- Conclusion (INFERENCE): an OFL icon font can ship in the APK as a **separate work under its own
  licence**, with the OFL text in the licences screen. The font then remains under the OFL and is not
  relicensed under the GPL. This is not legal advice.

Current state (FACT, `pubspec.yaml`): no animation packages or icon sets; Flutter's
built-in Material Icons are used.

| Set / package | Licence (upstream; pub.dev wrapper) | GPL-3.0 | Size and maintenance (pub.dev / GitHub API, 2026-10-17) |
| --- | --- | --- | --- |
| **Material Symbols** (google/material-design-icons); package `material_symbols_icons` 4.2960.0 | Apache-2.0; wrapper Apache-2.0 | Compatible (FSF) | Upstream active (push 2026-10-09). Package: 4,264 icons, variable fonts; icon tree shaking trims the font to the icons used, **except** with `Symbols.get()` (requires `--no-tree-shake-icons`). Flutter's built-in `Icons` are already present and add nothing |
| **Phosphor** (phosphor-icons/core); `phosphor_flutter` 2.1.0 | MIT; wrapper MIT | Compatible | Upstream push 2026-01; **wrapper not updated since 2024-05-10**, 55/160 pub points — maintenance risk (INFERENCE) |
| **Lucide** (lucide-icons/lucide); `lucide_icons_flutter` 4.0.0 | **ISC**; some icons from Feather — MIT (FACT, LICENSE); wrapper MIT | Compatible (ISC and MIT) | Upstream active (2026-10-16); wrapper updated 2026-10-16, 160/160 |
| **Tabler** (tabler/tabler-icons); `flutter_tabler_icons` 1.43.0 | MIT; wrapper MIT | Compatible | Upstream active (2026-10-15); wrapper not updated since 2024-09-28 |
| **Meteocons** (basmilius/meteocons) | MIT | Compatible | 475+ weather icons: animated SVG (SMIL), static SVG, Lottie JSON. Flutter needs `flutter_svg` (MIT, flutter.dev, 2.3.0) for static or `lottie` for animated. SMIL playback in `flutter_svg` is not confirmed — **UNKNOWN**, plan on static SVG or Lottie |
| **Weather Icons** (erikflowers/weather-icons); `weather_icons` 3.0.0 | Font — **SIL OFL 1.1**, code — MIT, documentation — CC BY 3.0 (FACT, README); wrapper MIT | Compatible as a separate font (see above, INFERENCE) | Upstream unchanged since 2023-03; wrapper — since 2021-07-08. **Abandoned** (INFERENCE) |
| **Font Awesome Free**; `font_awesome_flutter` 11.0.0 | Icons (SVG/JS) — **CC BY 4.0**, fonts — **SIL OFL 1.1** with Reserved Font Name "Font Awesome", code — MIT (FACT, LICENSE.txt); wrapper MIT | Compatible: CC BY 4.0 — per the FSF, the font — as a separate work under the OFL. Attribution required | Wrapper — Flutter Favorite, 2026-03-09; general-purpose icons, few astro and weather ones (INFERENCE) |
| **flutter_animate** 4.5.2 | BSD-3-Clause | Compatible | Pure Dart, Flutter Favorite; **last release 2024-11-25** — about two years without releases. The §6.2 task is solved by built-in APIs |
| **lottie** 3.6.1 (xvrh/lottie-flutter) | MIT | Compatible | A "Pure Dart" port of Lottie-android (FACT, README) — no native libraries; active (2026-09-18). Needed only for ready-made Lottie animations, for example Meteocons. APK size increase not measured — **UNKNOWN** |
| **rive** 0.14.11 + `rive_native` 0.1.11 | MIT (both) | Compatible | Depends on `rive_native`: **prebuilt native libraries are downloaded at build time** (FACT, README). So the native APK size grows per ABI (not measured — **UNKNOWN**), and the build depends on the network — one more input for reproducibility and CI (INFERENCE). Requires the Rive editor. Overkill for light mark animations |

Conclusions for the decision (INFERENCE):
- Licence-wise, all the listed options are compatible with GPL-3.0 provided the notices are kept. Font
  Awesome needs CC BY 4.0 attribution, OFL fonts need the OFL text in the licences screen (Flutter
  `LicenseRegistry`).
- A new package is a change to dependencies and the lockfile, i.e. **V1 high-risk class with the full gate**.
- A new icon set is justified only if Material Symbols lacks the needed metaphors — for example, weather and
  Moon phases. Then selectively, without replacing the whole icon system.

## 8. Options for RA.D, round 1

The owner decides every item. The agent makes no choice. The S9.10 and S9.12 recommendations are shown as options.

| # | Question | Options | Consequences |
| --- | --- | --- | --- |
| D1 | **Name** | N-a Culmina · N-b AltArc · N-c Astrarc · N-d Arcwindow · N-e reserve (Noctarc / PhotonPlan) · N-f keep "Astro Planner" (risk high, §2) · N-g the owner's own name (then the same §1 screening) | Any new name: `AppIdentity.appName`, manifest label, texts, store. Before upload — a formal TM search by the owner (OD-07): WIPO GBD, EUIPO, USPTO, optionally UKRNOIVI, classes 9 and 42 |
| D2 | **RD-01 — whose account** | B (Buffur) · B′ (Buffur links, chacha12 id) · C (chacha12) | Closes TD-088: source and policy links, user-agent, COMPLIANCE |
| D3 | **App id** | I-1 keep · I-2 `io.github.buffur.<name>` · I-3 `io.github.chacha12.<name>` | I-2/I-3: one Task (§4, trap 20), owner data migrated via backup. After the first upload — unchangeable forever |
| D4 | **Repository name and policy URL** | Keep `Astro-Planner` · rename to match the brand | Renaming changes the Pages URL; decide before publishing the policy |
| D5 | **Mark direction** | A · B · C · D (S9.10) · E (monogram, idea only) · a mix of shape and colour | After the choice — sketches for the name. The owner chooses the final mark (P9.4); then Task S9.10b (§6 S9.10) with the monochrome layer and the 512 px icon |
| D6 | **Splash and loading** | S0 static, as now · S1 AVD on Android 12+ (§6.2 item 1) · S2 = S1 + mark in Flutter during real loading (§6.2 item 3) · S3 = S2 on Lottie/Rive | S1/S2 — no new dependencies. S3 — a new dependency (full gate), size and network risk for Rive. P9.4 rules out fake progress and startup delay under any option |
| D7 | **Icons** | Material only (as now) · Material + a targeted set for weather and Moon (Meteocons static SVG via `flutter_svg`, or Tabler/Lucide) · replace the icon system | A new set — a dependency, attribution in the licences, contrast and semantics checks (a11y) |

Order (INFERENCE):
1. D1 → D2 → D3, decided together: the id and URL depend on the name.
2. Then D4.
3. Then D5: sketches for the chosen name.
4. D6 depends on D5.
5. D7 is independent and may move to round 2.

## 9. Sources (access date 2026-10-17)

Stores and web (name screening):
- Google Play, search for each candidate: `https://play.google.com/store/search?q=<name>&c=apps&hl=en` (for example, https://play.google.com/store/search?q=skyslot&c=apps&hl=en, https://play.google.com/store/search?q=lightframe&c=apps&hl=en); "astrophotography planner": https://play.google.com/store/search?q=astrophotography%20planner&c=apps&hl=en
- iTunes Search API: `https://itunes.apple.com/search?term=<name>&entity=software&country=us`; Nightframe: https://apps.apple.com/us/app/nightframe/id6761402286
- SkyWindow: https://apps.apple.com/app/id6761222663
- Nightwatch (macOS): https://alternativeto.net/software/nightwatch-app/about/
- Subframe: https://www.subframe.com/tips/bolt-alternatives ; GitHub SubframeApp/subframe
- LightFrame (Mac): https://www.mactech.com/2010/11/23/lightframe-gets-new-user-interface-rendering-engine ; Lightframer Pro: https://nofilmschool.com/lightframer-pro
- LIGHTFRAME / LITEFRAME: https://trademarkregistration.app/Trademark/Details/73019225 , https://trademark.justia.com/905/36/liteframe-90536175.html
- SKYHOUR (US serial 79223733): https://trademark.trademarkia.com/skyhour-79223733.html
- PHOTON (Exit Games, US serial 86318032): https://trademark.justia.com/owners/exit-games-gmbh-2876931
- StackPlanner: https://www.capterra.in/software/1091662/StackPlanner
- Culmina Family Estate Winery: https://winealign.com/wineries/326-culmina-family-estate-winery
- LightBucket / LightBuckets: https://app.astrobin.com/forum/topic/183947/feature-request-something-like-lightbucket , https://en.wikipedia.org/wiki/LightBuckets
- Noctar: https://www.serchen.com/company/noctar
- nightframe (npm): https://www.npmjs.com/package/nightframe
- Domains: RDAP via `https://rdap.org/domain/<name>.com` and `.app`; GitHub: `https://api.github.com/search/repositories?q=<name>+in:name`
- TM registries (inaccessible to the agent): https://branddb.wipo.int (CAPTCHA), https://tmsearch.uspto.gov (JS), https://euipo.europa.eu/eSearch/ (JS)

Platform:
- Adaptive icons: https://developer.android.com/develop/ui/views/launch/icon_design_adaptive
- Google Play icon: https://developer.android.com/distribute/google-play/resources/icon-design-specifications
- Splash screen: https://developer.android.com/develop/ui/views/launch/splash-screen ; migration: https://developer.android.com/develop/ui/views/launch/splash-screen/migrate
- androidx SplashScreen (AVD not supported before API 31): https://developer.android.com/reference/androidx/core/splashscreen/SplashScreen
- Application ID: https://developer.android.com/build/configure-app-module
- Play title limit (30 characters): https://support.google.com/googleplay/android-developer/answer/9898842
- Flutter splash: https://docs.flutter.dev/platform-integration/android/splash-screen
- `disableAnimations`: https://api.flutter.dev/flutter/widgets/MediaQueryData/disableAnimations.html
- Renaming a GitHub repository: https://docs.github.com/en/repositories/creating-and-managing-repositories/renaming-a-repository

Licences:
- FSF license list: https://www.gnu.org/licenses/license-list.en.html (Apache-2.0, Expat, ISC, Modified BSD, CC BY 4.0, SIL OFL)
- GPLv3 §5 "aggregate": `LICENSE` at the repository root
- Material Symbols: https://github.com/google/material-design-icons ; https://pub.dev/packages/material_symbols_icons
- Phosphor: https://github.com/phosphor-icons/core ; https://pub.dev/packages/phosphor_flutter
- Lucide: https://github.com/lucide-icons/lucide/blob/main/LICENSE ; https://pub.dev/packages/lucide_icons_flutter
- Tabler: https://github.com/tabler/tabler-icons ; https://pub.dev/packages/flutter_tabler_icons
- Meteocons: https://github.com/basmilius/meteocons ; `flutter_svg`: https://pub.dev/packages/flutter_svg
- Weather Icons: https://github.com/erikflowers/weather-icons ; https://pub.dev/packages/weather_icons
- Font Awesome Free: https://github.com/FortAwesome/Font-Awesome/blob/7.x/LICENSE.txt ; https://pub.dev/packages/font_awesome_flutter
- flutter_animate: https://pub.dev/packages/flutter_animate ; lottie: https://pub.dev/packages/lottie , https://github.com/xvrh/lottie-flutter ; rive: https://pub.dev/packages/rive , https://github.com/rive-app/rive-flutter , https://pub.dev/packages/rive_native
- pub.dev data (versions, dates, licence tags, scores): `https://pub.dev/api/packages/<name>` and `/score`

Internal: `research/S9.10_LOGO.md`, `research/S9.12_PROJECT_IDENTITY.md`, `research/S9.11_LICENCE.md`,
`DECISIONS.md` OD-07, `ENGINEERING_GUARDRAILS.md` traps 20–22, `research/RA_R1_PHASE_A_ASSESSMENT.md`.
