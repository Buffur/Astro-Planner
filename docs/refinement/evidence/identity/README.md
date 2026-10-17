# S13.1 — Culmina logo sketches and review sheet

> **Status:** 2026-10-17, proposals for the owner's review (`POST_ROADMAP_PLAN.md` S13.1;
> `research/RA_D_IDENTITY_TRANSITION.md` §5 steps 1–4). **Not approved artwork:** the agent never picks
> the mark (P9.4); the owner's choice is recorded in DECISIONS E.1 before S13.3 uses it. Nothing in
> the app changed.

## Files

- `V1`–`V4` `-amber.svg` / `-red.svg`: the adaptive foreground on night navy `#0B1230`, 108-unit
  canvas, in the proposed amber accent `#FFB547` and the current red `#FF4D3D` for comparison.
- `V1`–`V4` `-monochrome.svg`: the separate themed-icon layer (one colour; the system tints it).
- `review-sheet.html` and its render `review-sheet.png` (headless Chrome, 1400 px wide): per variant
  and accent, the launcher's visible 72 dp under circle, squircle and rounded-square masks; the
  launcher at 48 and 24 px; the themed monochrome icon on a light and a dark wallpaper; the
  Android 12+ splash (foreground on navy, half scale of 288 dp); the mark beside the name "Culmina"
  on dark and light. The 512 px Play icon is deferred (store distribution).

## The A + C hybrid (ID-5)

From A: the horizon, the target's altitude arc and the star at culmination. From C: **one stroke
system** (6 units; 7.5 in V4) with round caps, legibility at small sizes, and a working monochrome
layer. The imaging window is set off from the arc by **gaps** (stroke + 3.5 units between segment
ends), so it stays visible when the themed icon removes colour; nothing depends on colour alone.

| Variant | Idea | Safe-zone extent (of 33) |
| --- | --- | --- |
| V1 | The star sits in a gap at the apex: culmination is part of the arc; the window is split around it | 32.4 |
| V2 | The star rests just above the apex; the window is one segment | 33.0 |
| V3 | The arc rises out of a split horizon (no line under the arc) | 32.8 |
| V4 | Compact and bold: 7.5-unit strokes, shorter horizon, larger star; the strongest at 24 px | 32.5 |

Geometry: the arc is a cubic Bézier shaped like a half sine (the altitude curve over the night);
the window covers about the middle 45–55 % of it. The safe-zone extent is the largest distance from
the canvas centre (54, 54) of any stroke point plus half its width, or any star point; every variant
fits the 66 dp safe zone (radius 33).

## For the owner

Pick a variant and an accent, or ask for a round of changes (any shape with any colour). After the
approval: DECISIONS E.1 records it (S13.1 acceptance 4), and S13.3 redraws it in
`ic_launcher_foreground.xml`, `tool/make_launcher_icons.py` and a new monochrome drawable (trap 20),
and animates it for the splash (ID-6).
