# S13.1 round 5 — R3 Ice star: centring correction, splash animation, assessment

> **APPROVED 2026-10-17 (owner):** `R3-final` (orbit centred) is the final Culmina mark and the animation concept is accepted (DECISIONS E.1, "S13.1 — the final Culmina mark approved: R3-final").
>
> **Status:** 2026-10-17. The owner chose **R3 Ice star** (round 4) and noted by eye that it is not
> centred; asked for a re-check, a splash-animation concept and a final assessment. **The corrected
> artwork (`R3-final-*`) awaits the owner's confirmation** before DECISIONS E.1 records it as the
> approved mark (S13.1 acceptance 4; P9.4). Nothing in the app changed.

## Files

- `R3-final-colour.svg`, `R3-final-monochrome.svg`: R3 with the orbit centred on the canvas.
- `r3-final-sheet.html` / `.png`: the centring comparison (three placements, with the mask and orbit
  guides), the animation storyboard (0–720 ms) and a looping live preview (in the HTML).
- `R3-splash-avd-draft.xml`: a **draft** AnimatedVectorDrawable for S13.3 (well-formed XML; not in
  the app, not run on a device).

## 1. Centring — the owner was right

Round 4 placed the **ink centroid** on the optical centre (54, 53), which moved the orbit to
(55.64, 51.62): 1.6 units right and 2.4 up. In a round (or near-round) launcher mask the eye compares
the orbit with the mask edge, so a 2.9-unit offset between two near-concentric circles reads as
"off-centre". The star, by contrast, is read as a satellite of the ring, not as weight to balance.
The centroid rule (P5 in `research/S13.1_LOGO_PRINCIPLES.md`) suits marks without a dominant circle;
for this mark the dominant circle must be concentric with the mask ("correct by eye", the same source).

| Placement | Orbit centre | Extent (of 33) | Verdict |
| --- | --- | --- | --- |
| Round 4: ink centroid | (55.64, 51.62) | 32.6 | Visibly off-centre in round masks |
| **Orbit centred** | **(54, 54)** | **30.0** | **Recommended:** ring concentric with every mask; the star extends to the upper right inside the safe zone |
| Bounding box centred | (53.27, 54) | 29.4 | Close to the recommended one; the 0.7-unit leftward shift is again visible against a round mask |

## 2. Splash animation concept (ID-6 = S2)

**Android 12+ (platform splash; no new package):** `windowSplashScreenAnimatedIcon` = an
AnimatedVectorDrawable of the R3 foreground on the navy icon background.

| Time | Element | Change | Interpolator |
| --- | --- | --- | --- |
| 0–450 ms | Outer orbit | `trimPathEnd` 0 → 1: the orbit is drawn from its upper end round to the opening | fast-out-slow-in |
| 120–520 ms | Inner orbit | `trimPathEnd` 0 → 1 | fast-out-slow-in |
| 420–720 ms | Ice star | scale 0.4 → 1, rotation −45° → 0°, fill alpha 0 → 1 (first 120 ms) | overshoot (scale), fast-out-slow-in |

- **Meaning:** the orbit is traced and the star arrives at its place, the culmination; it ends in the
  static icon, so the launcher icon and the splash agree.
- **Platform limits** (Android Developers, Splash screens, accessed 2026-10-17,
  <https://developer.android.com/develop/ui/views/launch/splash-screen>): an AVD; recommended at most
  1,000 ms; a start delay of at most 166 ms (here 0); with an icon background the icon must fit a
  160 dp circle in 240 dp (the mark spans about 60 of 108 units, about 133 dp: fits); the splash is
  dismissed at the app's first frame, so the animation **never delays startup** — on a fast start it
  may be cut short, which is why the full mark is formed by about 500 ms.
- **Reduced motion:** with the system's animator scale at 0 the AVD shows its end state (the static
  icon) — expected behaviour, **to verify on the phone** in S13.3.
- **Before Android 12:** the static icon on navy (`launch_background.xml`), as today.
- **Flutter continuation (only while startup really loads; S13.3 acceptance 3):** the same static mark
  in the same position instead of the bare progress indicator; while loading continues, the star
  breathes softly (opacity 1 → 0.6 → 1, about 1.6 s; `AppMotion` tokens, built-in `AnimationController`);
  no deterministic progress; static when `MediaQuery.disableAnimations` is set; replaced by content as
  soon as data is ready.
- **Measure in S13.3:** cold start before and after on the phone (logcat "Displayed").

## 3. Assessment of R3 (orbit-centred)

| Criterion | Result |
| --- | --- |
| One core idea (P1, P2) | Yes: the C of Culmina as an orbit, the star at its culmination point |
| Distinctive | Good: avoids the generic crescent-and-star and the arc-and-horizon clichés; not a copy of Siril's or Stellarium's marks while sharing their calm, technical tone |
| Android adaptive icon (P3) | Mark ≈ 60 of 108 units (≈ 60 dp), inside the 66 dp safe zone and above the 48 dp minimum; one-colour layer; no shadows |
| Small sizes (P8) | 48 and 32 px clear; at 24 px the inner orbit becomes faint; at 16 px the mark reads as "C + star" only — acceptable |
| Contrast on navy `#0B1230` | Orbit `#E6EBF7` 15.4:1; ice star `#8CCBFF` 10.6:1; inner orbit `#7F8DC0` 5.7:1 (above 3:1 for graphics) |
| Themed icon | Works: shape only, nothing depends on colour |
| With the name | Pairs well with a light, wide-tracked "Culmina" wordmark |
| Animation | Natural: draw the orbit, place the star; under 1 s; ends on the icon |
| Risks | The inner orbit is the weakest detail at launcher sizes (a later option: drop it below 32 px in the legacy PNGs); the ice blue depends on the display — the star must stay legible in the themed (monochrome) mode, which it does |

**Verdict:** a sound, finished mark once the orbit is centred. Recommended for approval as the final
Culmina mark in its orbit-centred form (`R3-final-*`).
