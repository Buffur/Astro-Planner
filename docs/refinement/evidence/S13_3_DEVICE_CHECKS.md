# S13.3 — launcher icon and animated splash: device checks (2026-10-17)

> **Environment:** the owner's Xiaomi 14T Pro (2407FPN8EG, Android 16), over USB, 2026-10-17. Test
> package `io.github.buffur.culmina.s2check`, **release** builds (R8 on; signed with the debug key,
> as no release key exists yet), built from a detached copy of the tree; never the owner's apps.
> "Before" = `31ff9bf` (the S13.2 icon and static splash); "after" = the S13.3 working tree.

## Cold start (acceptance 4)

`am start -W` `TotalTime`, equal to logcat's "Displayed" line (both recorded per run); the app
force-stopped 2 s before each run; one warm-up run discarded per series.

| Build | Runs (ms) | Median |
| --- | --- | --- |
| Before (`31ff9bf`), 3 series | 317, 299, 259, 275, 266, 255; 310, 265, 282, 308, 426, 281; 268, 271, 246, 272, 267 (one failed reading, adb restarted) | **272** (17 runs) |
| After, the 720 ms splash, 2 series | 323, 365, 336, 296, 292, 318; 312, 327, 280, 288, 295, 275; 311, 290, 317, 294, 317, 301 | 306 (18 runs) |
| **After, final (380 ms splash)** | 298, 281, 348, 283, 324, 275 | **290** (6 runs) |

Reading: the difference (about +20 to +35 ms) is within the run-to-run spread of the baseline (246–426
ms). Nothing was added before the first frame in Dart (the startup mark replaces the progress
indicator only while loading). The splash itself never extends startup: Android removes it at the
first frame.

## The splash as seen on the phone

`screenrecord` of a cold start, frames at 20 fps (`identity/s13_3_splash_frames.png`, cropped to the
centre; the second row shows the splash):

- **With the approved 720 ms timeline**, the system removed the splash at the app's first frame,
  about 300–350 ms after launch: only the orbit's drawing was ever visible, **the star never
  arrived**.
- **Implementation deviation, applied:** the same storyboard compressed to **380 ms** — outer orbit
  0–300 ms, inner orbit 60–320 ms, star 140–380 ms (fill fades in over 80 ms). On the phone the whole
  sequence now plays: the orbit draws, the star arrives at the opening, the full mark is held for a
  frame, then the app appears. Recorded in DECISIONS E.1 for the owner's confirmation.
- **Before Android 12:** the static legacy icon on navy (`launch_background.xml`), redrawn by
  `tool/make_launcher_icons.py` — not observable on this phone (Android 16): **UNVERIFIED on a device**.
- **Reduced motion:** with the system animator scale at 0 the AVD shows its end state (platform
  behaviour) — **UNVERIFIED on the device**: changing the phone's system animation setting was not
  done (an owner's setting); the owner can check it in Developer options.
- **The startup mark (Flutter):** on this phone startup completes before the loading view is drawn,
  so the mark was not observed on the device; it is covered by `startup_mark_test.dart`.

## Owner apps

Unchanged (`io.github.chacha12.astroplanner` 2026-09-30 11:48:37; `com.astroplan.astroplan`
2026-09-24 14:24:35; the owner's IDE build `io.github.buffur.culmina` not touched). The test package
`io.github.buffur.culmina.s2check` is left installed for the owner's look at the icon and splash;
uninstall it with `adb uninstall io.github.buffur.culmina.s2check` (or from the launcher) afterwards.
