# S13.2 — device checks of the Culmina identity (2026-10-17)

> **Environment:** the owner's Xiaomi 14T Pro (model 2407FPN8EG, Android 16), over USB, 2026-10-17,
> 14:10–14:35 local time. Test packages only (`.s2check` debug builds from detached worktrees), never
> the owner's apps. **Builds:** old id `io.github.chacha12.astroplanner.s2check` from `d42f053` (label
> "Astro Planner", schema v25); new id `io.github.buffur.culmina.s2check` from `b29ec34` (label
> "Culmina", schema v25); both `aapt2 dump badging` checked.

## Results (`RA_D_IDENTITY_TRANSITION.md` §3)

| Criterion | Check | Result |
| --- | --- | --- |
| 3. Metadata import works with the renamed channel | New-id app → Library → Rigs → "Add from a photo": a 100 MB DNG from the phone's camera (read in place: exposure and ISO with their tags shown) and a HEIC (exposure from the HEIF Exif item); "New rig from this file" → Save → the rig appears in the list and in the database (rigs 1 → 2) | **PASS** (M1, M4 on the new id) |
| 4. Backup and restore across ids | Old-id app seeded through its UI: a site (name, coordinates, elevation 180 m, its zone), the example rig, M42 from the catalog (aliases), a saved plan with three blocks, the darkness limit changed to −15°. Settings → Back up now created the `.astroplan` file; the share sheet was **cancelled** (nothing was sent to any app or person); the file was copied from the test app's own cache to `Download/` and picked in the new-id app: Settings → Restore → confirm → restart | **PASS**: all 9 tables equal row for row (`astro_targets` 164, `target_aliases` 257, `location_profiles` 1, `optical_rigs` 1, `camera_modules` 1, `devices` 1, `session_logs` 1, `capture_blocks` 3, `session_events` 0), `user_version` 25 on both sides; the darkness limit (−15°) and minimum altitude restored; Tonight shows the saved plan for M42 at the site |
| TD-093 on the device | The restore confirmation | **PASS**: "Made Oct 17, 2026, 14:17 (device zone, UTC+03:00) by Culmina 1.0.0, with 1 sessions." |
| 8. `.s2check` re-derived | `io.github.buffur.culmina.s2check` installs beside the other apps | **PASS** |

**Not covered on the device:** the seed had no recorded result and no legacy run (criterion 4.1 lists
both); their round trip is covered on the host (`backup_restore_test.dart`), and the archive carries no
application id (new host test, S13.2).

## Owner apps (unchanged)

`lastUpdateTime` before and after: `io.github.chacha12.astroplanner` 2026-09-30 11:48:37;
`com.astroplan.astroplan` 2026-09-24 14:24:35. `io.github.buffur.culmina` (a **debug** build installed
at 14:09:45 by the owner's own Android Studio `flutter run` from the main tree, not by this check) was
not touched. Afterwards both `.s2check` packages were uninstalled, the copied backup removed from
`Download/`, and the worktrees deleted.

## Observations (follow-ups, not blockers)

- **Debug build under the release id:** the IDE's debug install of `io.github.buffur.culmina` is signed
  with the debug key. The signed release APK (S17.6) cannot update it (signature mismatch); uninstall it
  before installing a release build. Recorded for S17.5/S17.6.
- **The restore confirmation names the current app, not the backup's:** a backup made by Astro Planner
  reads "by Culmina 1.0.0" (the header has no app name); and "1 sessions" is not singular. TD-105.
- **Two adb versions:** SuperDisplay's adb 1.0.40 and the SDK's 1.0.41 restart each other's server;
  close SuperDisplay before device runs.
