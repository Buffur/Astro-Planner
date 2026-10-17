# RA.D round 1 — identity decisions and transition plan

> **Status:** the owner's round-1 decisions (2026-10-17) and the preparation they ask for. **Nothing is
> implemented.** The app keeps its current identity — "Astro Planner",
> `io.github.chacha12.astroplanner`, the current icon and splash, the `Buffur/Astro-Planner`
> repository — until an implementation Task approved through RA.P changes it.
>
> **Records:** DECISIONS E.1, "RA.D — ID-1: the application name" and "RA.D — round 1 identity
> (ID-2 to ID-6)"; [decision sheet](RA_D_DECISION_SHEET.md).
>
> **Evidence:** [RA_R2D_IDENTITY.md](RA_R2D_IDENTITY.md) (screening, app id, logo, splash, licences);
> `S9.10_LOGO.md`; `S9.12_PROJECT_IDENTITY.md`.
>
> **Distribution amended, 2026-10-17 (GitHub-only; DECISIONS E.1):** read "the first Play upload" below as "the first public GitHub release": from then on Android accepts an update only with the same application id and signing key. The Play Console, listing, closed test and 512 px Play icon items are deferred; the policy URL, the backup-and-restore migration and the formal trademark search (now recommended, not a gate) stay documented.
>
> **This document feeds RA.P.** Its acceptance criteria are proposals for the implementation Tasks.
> They become binding only when RA.P freezes those Tasks.

## 1. Decisions

| ID | Decision (owner, 2026-10-17) | What it is not |
| --- | --- | --- |
| ID-1 | **Culmina**, pending formal trademark clearance before store publication; "Culmina: Astrophoto Planner" is a provisional store descriptor | Not a code rename |
| ID-2 | **B** — `Buffur` is the public GitHub and developer identity. Also given by the owner: profile `https://github.com/Buffur`, Reddit `https://www.reddit.com/user/Buffur/` (already the About screen's author links, `about_screen.dart:20-21`) | — |
| ID-3 | **I-2** — the intended Android application id is `io.github.buffur.culmina` | Not a change to the id now |
| ID-4 | The intended repository name is **`Buffur/Culmina`**; a URL transition plan (§4) comes before any rename | Not a rename now |
| ID-5 | **A provisional hybrid of directions A and C:** from A, the altitude arc, the horizon and the star at culmination; from C, consistent strokes, legibility at small sizes and a working monochrome layer | A design direction, **not approved artwork** (§5) |
| ID-6 | **S2** — a lightweight animated splash of the selected mark, lasting only as long as real initialization and honouring reduced motion | Not a splash change now |

## 2. Superseded decisions and dependencies

| Earlier decision or record | Effect of round 1 |
| --- | --- |
| **OD-07** (TASK 16.1): name "Astro Planner", id `io.github.chacha12.astroplanner` | Superseded as direction by ID-1 and ID-3. The shipped values stay until the implementation Task; the id stays changeable only until the first Play upload |
| **RD-01** (account `chacha12` or `Buffur`; deferred 2026-09-30) | **Decided: B (Buffur)** |
| **S9.12** (identity options; deferred) | Resolved by ID-2 to ID-4 |
| **S9.10 / P9.4** (logo; deferred 2026-09-30, "today's icon stays") | Direction chosen (ID-5). The final mark still needs the owner's approval of artwork (§5); P9.4's rule that an agent never picks the mark stands |
| **TD-088** (source and policy links return 404) | Direction decided (Buffur URLs, §4); the finding stays **open** until the URLs answer and `AppIdentity` points at them |
| **Trap 20** (`ENGINEERING_GUARDRAILS.md`; name and id described as "Astro Planner" / chacha12) | Describes the current state correctly; update it in the implementation Task, not before |

**Unchanged under every option** (trap 20, R2d §3): the `.astroplan` backup extension, the export
manifest's `"app": "AstroPlan"`, the backup header format `astroplan-backup`, and the Dart package
`astroplan`. These are file formats and internals.

**Dependencies:**
- ID-3 and ID-4 depend on ID-1 and ID-2.
- ID-6 depends on ID-5's approved artwork.
- The privacy-policy URL depends on ID-4.
- Everything must be final **before the first Play upload**: the id is permanent, and the policy URL
  goes into the store listing.

## 3. Application-id migration: proposed acceptance criteria

The change touches Android build configuration, platform code, the metadata channel and tests. Its V1
class is therefore **high-risk**: the full gate is required, plus the probes below.

**Code surfaces** (inventory, 2026-10-17):
- `android/app/build.gradle.kts`: `namespace`, `applicationId`;
- Kotlin package `android/app/src/main/kotlin/io/github/chacha12/astroplanner/`:
  - `MainActivity.kt`;
  - `MetadataDocumentChannel.kt`;
  - `MetadataSequentialReader.kt`;
- the test package `android/app/src/test/kotlin/io/github/chacha12/astroplanner/`;
- the MethodChannel name `io.github.chacha12.astroplanner/metadata_document`. It must change in Kotlin
  and `lib/data/metadata/android_capture_file_access.dart` **together**, or keep its old name in
  both;
- `AppIdentity` (`packageName`, `appName`, `projectUrl`, `privacyPolicyUrl`, `sourceUrl`,
  `userAgent`) and `android:label`;
- tests: `app_identity_test.dart`, and the tests that assert the name or the user agent (inventory
  them in the Task);
- documents: `COMPLIANCE.md`, `RELEASE.md`, `docs/privacy/index.md`, `README.md`, trap 20, and the
  Stage 11 device runbook (its `adb` commands name the old id and the `.s2check` suffix).

**Criteria:**
1. **One id everywhere.** One id across Gradle, the Kotlin package, `AppIdentity` and the manifest;
   `app_identity_test.dart` enforces it.
2. **No old id left behind.** A search for `chacha12` and `astroplanner` in `lib/`, `android/`,
   `test/`, `integration_test/` and `tool/` finds nothing, except records that name the old id on
   purpose (for example the migration note).
3. **Metadata import still works.** The renamed channel works on a device: "Add from a photo" with a
   DNG and with a JPEG or HEIC, as M1 and M4 recorded. This is a device check, because the host cannot
   prove the Kotlin channel.
4. **Backup and restore across ids (data preservation).** On a **test** package, never the owner's app:
   1. seed data with the old-id build: sites, rigs, targets with aliases, saved plans, a recorded
      result, a legacy run, preferences;
   2. back up to a file;
   3. install the new-id build alongside;
   4. restore from that file;
   5. verify: session, block, rig, site and target counts equal; a representative plan's snapshot,
      result and name equal; preferences restored;
   6. confirm the `astroplan-backup` format and schema checks accept the file
      (`backup_archive.dart:24, 76`).
   This needs a host test plus one device run.
5. **No silent data loss for the owner.**
   - The new id installs **beside** the old app with an empty database.
   - Android Auto Backup is per package and does **not** carry data over.
   - The release notes and the owner runbook state the path: back up in the old app → install the new
     app → Restore → check → the owner removes the old app by hand.
   - An agent never uninstalls or replaces the owner's app.
6. **Schema order.** The new-id build's schema is equal to or newer than the backup's; a newer
   backup is refused with the existing message (ADR-008 §2).
7. **The user agent's contact URL answers 200** before any build that sends requests to OSM,
   Nominatim or Open-Meteo is released (§4).
8. **The `.s2check` debug package** is re-derived from the new id (`io.github.buffur.culmina.s2check`)
   and the runbook updated.
9. **Verification:** the full gate on the final inputs; the device checks in items 3 and 4.
10. **Order:** the change lands **before** the first Play upload, the signing setup for the store
    listing, and the Stage 11 phone runs. Otherwise their evidence names the wrong id.

## 4. Repository and privacy-policy URL transition checklist

Intended targets:
- repository `https://github.com/Buffur/Culmina`;
- project site `https://buffur.github.io/Culmina/`;
- policy `https://buffur.github.io/Culmina/privacy/`.

Confirm the exact Pages URL after enabling it. Today both the current policy URL
(`chacha12.github.io/astro-planner/privacy/`) and `buffur.github.io/Astro-Planner/` answer **404**
(checked 2026-10-17).

The owner's actions are marked **(owner)**; the agent never renames, publishes or changes repository
settings.

1. **Before anything:** settle the final policy text, including the contact email (16.3, TD-099's
   wording). If PD-16, the 16-night forecast, is accepted in round 2, update the forecast wording as
   well.
2. **(owner) Rename the repository** `Buffur/Astro-Planner` → `Buffur/Culmina` in GitHub settings.
   - GitHub redirects git and web URLs, but **not GitHub Pages**.
   - Never create a new repository named `Astro-Planner` afterwards: it would break the redirects.
3. **(owner, optional)** Point the local `origin` at the new URL. It keeps working through the redirect
   otherwise.
4. **(owner) Enable GitHub Pages** for `Buffur/Culmina`, serving `docs/privacy/`, and publish the
   policy.
5. **Verify:** the policy URL and the project URL answer 200; `sourceUrl` answers 200.
6. **Implementation Task:** update `AppIdentity` (`projectUrl`, `privacyPolicyUrl`, `sourceUrl`; the
   user agent follows), `docs/privacy/index.md`, `COMPLIANCE.md` (Data Safety), `RELEASE.md` and
   `README.md`. Close TD-088 with the commit.
7. **Verify CI** on the renamed repository: one run, read from GitHub (CLAUDE.md: do not infer CI
   state). This is independent of TD-104's fix, which needs its own green run.
8. **(owner) Play Console:** enter the policy URL; it must be live before the closed test.
9. **Never** point a released build's user agent at a URL that answers 404: OSM and Nominatim ask for
   a working contact.

## 5. Logo: visual review step before final artwork

1. **Sketches** (an agent may draw them; they are proposals). Three or four variants of the A + C
   hybrid:
   - horizon, altitude arc, star at the apex;
   - one stroke system;
   - the window accent: **amber** as S9.10 proposed, and the current red for comparison — the colour
     is the owner's choice;
   - the mark centred in the 66 dp safe zone.
2. **Review sheet**, rendered for each variant:
   - the 108 dp adaptive icon under circle, squircle and rounded-square masks;
   - the launcher at 48 and 24 px;
   - the themed monochrome icon on light and dark wallpapers;
   - the 512 px Play icon (full square, no rounding or shadow);
   - the splash at 288 dp;
   - beside the name "Culmina".
3. **Owner review:** the owner picks one variant or asks for a round of changes. An agent never picks
   the final mark (P9.4).
4. **Owner approval of the final artwork** is recorded in DECISIONS E.1 before any asset replaces the
   current icon.
5. **Then the implementation Task:**
   - redraw in both `drawable/ic_launcher_foreground.xml` and `tool/make_launcher_icons.py` (trap
     20);
   - add a separate monochrome layer;
   - regenerate `assets/branding/icon_512.png`;
   - draw the splash's animated vector (ID-6);
   - check contrast on the icon background.

**ID-6 (S2) proposed criteria:**
- an AnimatedVectorDrawable in `windowSplashScreenAnimatedIcon` on Android 12+, at most 1,000 ms,
  with no start delay;
- before Android 12, the static icon;
- the Flutter continuation shows the mark only while startup is really loading, with no
  deterministic progress, static when animations are disabled, and no added work before the first
  frame;
- built with Flutter's own animation APIs and **no new package**;
- cold start measured on the phone before and after (logcat "Displayed").

## 6. Consistency with the release prerequisites

| Prerequisite | Relation to round 1 | Order |
| --- | --- | --- |
| TD-104 (CI red) | Independent | First (PD-22 ★, to be decided in round 2) |
| OD-07 formal trademark search for "Culmina" (classes 9, 42; WIPO GBD, EUIPO, USPTO) | Owner action; a failure reopens ID-1 and therefore ID-3 and ID-4 | **Before** the id change is implemented, to avoid a second id change |
| 16.2 upload key and signing | The upload key is not tied to the id, but the Play listing and Play App Signing are per application id | After the id change, before the first upload |
| 16.3 policy live with contact (Stage 11 O9) | Its URL is §4's target | After the repository rename and Pages |
| Stage 11 rows that name the id or the app (N5 the signed release installs; G6 About's pages; the runbook's `adb` commands; L10 the core loop) | Their device evidence must be collected on the final identity | S11.6 after the identity Task |
| Play closed test (≥ 12 testers, 14 days; Q2) | Runs on the final id and listing | Last |

**No conflict found** between the round-1 decisions and the release prerequisites. The one ordering
constraint is that the formal trademark search should come before the id change.
