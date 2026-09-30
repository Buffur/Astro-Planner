# Stage 11 — emulator runs (S11.3)

> RUNTIME VERIFIED (emulator) evidence for `STAGE_11_MATRIX.md`'s EMULATOR rows (D11-1: never device
> evidence). Recorded 2026-09-30 on the development machine.

## Environment

- **Emulator:** AVD `Medium_Phone_API_36.1`, Android 16 (API 36), `sdk_gphone64_x86_64`, Google Play
  image (a user build, no root), 1080 × 2400 at 420 dpi, TalkBack installed.
- **Builds:** the release x86_64 APK (`flutter build apk --release --split-per-abi`; debug-signed, as
  every release build on this machine; application code as at `43523bb`, unchanged to `1af00be`),
  and a debug x86_64 split APK (same key and version code) where `run-as` was needed (F13, F16).
- **Driving:** `adb` and `uiautomator` (the app's semantics as Android sees them), screenshots
  reviewed; the clock and zone set with `cmd alarm set-time` / `set-timezone` (automatic time off),
  airplane mode with `cmd connectivity`, location with `cmd location` and `pm grant/revoke`, storage
  filled with `fallocate`/`dd`, dark mode with `cmd uimode`, rotation with `settings put system
  user_rotation`, Auto Backup with `bmgr`. Every setting was restored afterwards except the clock
  (automatic time is off on this emulator; it holds no owner data).

## Results

| Row | Result |
| --- | --- |
| L1 | PASS 2026-09-30 release x86_64 (app code 43523bb/HEAD 1af00be): airplane mode, fresh install -> first-run page; Skip; typed site Dark Site 46.05/14.51 GMT; Tonight night times, Moon; planner M31 + seeded rig + example plan: chart, windows, fit, +393 frames; Weather detail: "Couldn't load weather. Offline..." with Retry; Retry stays on the message, process alive. |
| J5 | PASS: airplane mode with data: Save plan (Saved), Tonight "Fits: 1 h 48 min needed of 8 h 55 min usable", Logbook lists it under Past, Record result -> Completed as planned -> Save result: Completed, 1 h 40 min of 1 h 40 min; Back up now -> share sheet with astroplan-backup-2026-09-30-0615.astroplan; map picker shows no tiles, attribution, no crash; weather "No forecast. Offline..." |
| F15 | PASS: entry Share -> system sheet "Sharing text" with identity, night (GMT), site name, rig, result, integration, per block; no notes, no coordinates. Export as file -> astroplan-entry-2026-09-30-0618.json (local time). Observation: after Completed as planned the entry shows "Darks 0 of 20 / Flats 0 of 20" (results record light counts only, I-1). |
| L2 | PASS: Use current position -> system dialog; Don't allow -> "Astro Planner uses your position only to compute night times..." (site unchanged); denied again -> "Location permission is blocked ... Allow it in the app settings" + Open settings -> the app's App info page; permission granted + location off -> "Location services are turned off on this device" + Open settings -> system Location page. Active site stayed Dark Site. Note: the button reads "Open settings" in both cases (TEST_PLAN says "Open location settings"). |
| L3 | PASS (data) with a FOLLOW-UP: "Don't keep activities" ON: Fill tonight's window (L x 493, Tight 8 h 54 min), Red field mode on, Home, reopen from recents -> the planner as left, field mode on, the edited plan. Then Home + adb shell am kill (pid 12491 gone), reopen from recents -> new pid; plan (M31, night Sep 29, edited block, Tight), site and field mode restored, but the app opens on Tonight, not the planner: the route is not restored after process death (no state restoration; one tap back). Setting restored afterwards. |
| L4 | PASS: clock 2026-09-30 19:00 GMT (cmd alarm set-time; auto_time off): the never-saved copy followed to the night of Sep 30; Save plan -> Saved; Home; clock 22:00 (during the night); am kill; clock 2026-10-01 07:00 (after dawn 03:21); reopen: Tonight "Last night: Andromeda Galaxy. How did it go?", the planner on a Not saved copy, Logbook: the Sep 30 plan Saved with Record result under Past, the Sep 29 entry Completed. Kill again and reopen: the same (no second copy or entry visible). |
| L6 | PASS (first part): device zone changed to America/New_York (cmd alarm set-timezone) after the night: the result form keeps "Night: Wed, Sep 30"; the entry and Tonight still say "Times in site zone GMT, GMT, UTC+00:00" with window 6:26 PM - 3:21 AM (+1). Second part (a site without a zone) not reachable in the UI: every new site gets a zone (TASK 7.3); host-tested. |
| L5 | PASS: auto-rotate off, user_rotation 1 and 3: the planner lays out in landscape, content scrolls, nothing cut off; the site editor with typed "Hill Top" and a latitude keeps both through landscape and back (Back then asks "Unsaved changes: Cancel / Discard / Save"); the result form with Partly and 300 typed keeps both through landscape and system dark mode on/off (cmd uimode night). Field mode toggling covered in L3 (planner) and Tonight. |
| L8 | PASS with notes: storage filled (fallocate + dd, 0 bytes free): a planner edit shows the banner "Your latest changes couldn't be saved on this device..."; Back up now -> "Couldn't back up: the app's data on this device could not be read or written. Please try again."; Save result (Not done, Clouds) -> "Couldn't save the result. Please try again.", the choice kept; no crash. Fill files deleted: Save result works (Not done listed), the next edit (a block added) saves and the banner clears. Notes: one Save plan on the full disk succeeded (SQLite had room in its file; Android also frees caches); after that successful Save the autosave banner stayed until the next successful edit. |
| B6 | PASS: device zone America/Los_Angeles, clock 2026-10-01 18:30 PDT; a site "Los Angeles" 34.05/-118.25 (zone defaulted to the device zone): Tonight "Night: Thu, Oct 1", sunset 6:38 PM, dark 8:03 PM - 5:28 AM (+1), "Times in site zone America/Los_Angeles, PDT, UTC-07:00". The part "a site without a zone" is not reachable in the UI (every new site gets a zone). |
| G7 | PASS (partly): launcher icon (arc and star) on the home screen; "Astro Planner" in recents and App info; package io.github.chacha12.astroplanner, versionName 1.0.0, versionCode 4001, targetSdk 36; cold start 1.5 s (am start -W). The splash was too short to capture; not separately observed. |
| N2 | PASS: the whole S11.3 session ran on the release x86_64 APK (debug-signed): first run, site, planner, Save plan, results, Logbook, Share, Export, backup. |
| F13 | PASS (debug x86_64 build over the release, same key; data kept): entry named "First light", Moon gate on, sites Dark Site and Los Angeles, results Completed/Partly/Not done and one Saved; Back up now -> astroplan-backup-2026-10-02-0136.astroplan (format_version 2, schema 25, 5 sessions, preferences.json); copied to Download; uninstall; reinstall (first-run page, no data); Restore: a copy with schema 26 in both header and database -> "This backup was made by a newer version of Astro Planner. Update the app first."; the real backup -> preview -> Restore at next start; after a restart every entry (with the name), both sites, the active site Los Angeles and the Moon gate are back. |
| F14 | PASS (release x86_64): bmgr enable, local transport (com.android.localtransport), autorestore on; bmgr backupnow with the app in the background: Success (~227 KB; a force-stopped app is "not allowed", a debug build exceeds the quota with its 118 MB JIT kernel); uninstall, install: the app starts with every entry, the sites and the active site restored. |
| N3 | PASS (as designed): flutter build appbundle --release (64.8 MiB) at 1af00be app code; tool/check_bundle.dart: all 15 native libraries ok (16 KB or 64 KB aligned); FAIL signer CN=Android Debug (expected until the owner's upload key). |
| F16 | PASS (debug x86_64, a database file placed with run-as): user_version 26 -> "Your data needs a newer version ... (data version 26) ... Nothing has been changed." with no reset; the file byte-identical afterwards. user_version 7 -> "Your data can't be upgraded ... (data version 7) ... the old file is kept" -> Start with fresh data -> "Start with fresh data?" -> Start fresh: astroplan.sqlite.v7.bak kept (8,192 bytes), the app restarts on fresh seeded data (no site). Method: the "older build over a newer database" case is reproduced as a database newer than the installed build. |
| L9 | PASS: integration_test/core_loop_test.dart on the emulator through flutter drive --no-dds (debug), both tests (00:49), after 1af00be (test text input registered; the view override host-only). |

## Findings

- **S11F-01 — BLOCKER (V4 A):** with the Logbook tab already opened, Save plan in the planner does not add the new saved plan to the Logbook list (Tonight already offers "Last night: ... How did it go?" for it); it appears only after an app restart. SessionsViewModel.revision is bumped for rename/result/delete (S8.6) but not for Save plan; the shell keeps the Logbook tab alive. Data not lost. The Stage 11 check "Save plan → result →
  Logbook works" fails on this path (matrix group F). → corrective Task **S11.C1**.
- **S11F-02 — FOLLOW-UP:** the restore confirmation reads "Made device zone, UTC+00:00 by Astro Planner 1.0.0, with 5 sessions." The backup's date and time are missing: backup_section.dart builds "Made ${NightTimeFormatter.deviceZoneCaption(p.createdAtUtc)}", and deviceZoneCaption returns only the zone label. Present since TASK 14.4 (a847f87). Wording only; the restore works.
- **Observations (FOLLOW-UP, not blocking):**
  - L3: after a process death the app reopens on Tonight, not on the screen that was open (no route
    restoration); every datum is restored;
  - L8: after a Save plan that succeeded on the full disk, the autosave failure banner stayed until the
    next successful edit;
  - F15: after "Completed as planned" the entry lists "Darks 0 of 20" and "Flats 0 of 20": results
    record light counts only (Stage 8, I-1), which reads oddly;
  - L2: `TEST_PLAN.md` calls the location-services button "Open location settings"; the app says
    "Open settings" (it opens the Location page);
  - J5: the map picker is titled "Select Location" (not the glossary's wording).

## Re-check after S11.C1

- **S11F-01 fixed (2026-09-30):** the release x86_64 APK with S11.C1 on the emulator: the Logbook opened
  ("Nothing saved yet"), then Tonight → the planner → M31, the seeded rig → Save plan → back → the
  Logbook tab: "Upcoming · Andromeda Galaxy · Thu, Oct 1 · Saved" at once, no restart.
