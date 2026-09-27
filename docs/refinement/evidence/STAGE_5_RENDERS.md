# Stage 5 — rendered design system (S5.9)

> **What:** host-rendered images of the design system as built by S5.1–S5.8, for the owner's
> optional, non-blocking visual review (plan, "Stage 5 — frozen Task sequence", S5.9).
> **Made by:** `test/presentation/design_system/render_gallery_test.dart`, opt-in and outside the
> quality gate (skipped there). Command, from the repository root:
> `ASTROPLAN_RENDER_GALLERY=docs/refinement/evidence/stage5 flutter test --no-pub test/presentation/design_system/render_gallery_test.dart`.
> **Rendered:** 2026-09-27, from the code of S5.8 (`99e60af`) plus S5.9's test-only split of the
> gallery content (`gallery_entries.dart`), on the host (Windows, Flutter 3.47.4).
> **Evidence level:** host renders at a device pixel ratio of 1, 412 logical px wide. They are **not
> device evidence**: an Android phone draws the same widgets, but its font hinting, pixel density
> and system bars differ.

## What each image shows

| Image | Theme | Text | Content |
| --- | --- | --- | --- |
| `stage5/gallery_light_100.png`, `gallery_light_200.png` | Light | 100 %, 200 % | The whole gallery (below) |
| `stage5/gallery_dark_100.png`, `gallery_dark_200.png` | Dark | 100 %, 200 % | The whole gallery |
| `stage5/gallery_field_100.png`, `gallery_field_200.png` | Field (red), through the app's red filter | 100 %, 200 % | The whole gallery |
| `stage5/detail_{light,dark,field}.png` | Each | 100 % | The sample Night & Moon page on `DetailScaffold`, on a 412 × 915 phone screen |
| `stage5/confirm_{light,dark,field}.png` | Each | 100 % | The same page with `confirmDestructive` open ('Delete rig "Refractor 400"?') |
| `stage5/undo_{light,dark,field}.png` | Each | 100 % | The same page with the `showUndo` message ("Block deleted · Undo") |

**The gallery, top to bottom:**
1. the text roles on the background, a card (the surface) and the raised surface (S5.1);
2. every button role, enabled and disabled; the destructive role; an icon button (S5.2);
3. text fields: focused, with a helper, filled, in error, disabled, filled with a prefix (S5.2);
4. a divider, a list row and a menu button (S5.2);
5. the status block in each state, and every plan-state label (S5.4);
6. a collapsible section closed and one open (S5.5);
7. the context line with a zoned site, a site without a zone, and no site (S5.6);
8. a deletable row with its visible Delete (S5.8).

## How to read them

- **Sample content:** the texts are samples ("Fits: 2 h 05 min …", "Refractor 400"), not
  calculated values. The first samples, and a few others, repeat one sentence on purpose, to show a
  role or a state rather than a real plan.
- **Fonts:** Roboto and the Material icons are loaded from the SDK, so text looks as on Android. A
  style that names no font family would still draw the test font's blocks; none appears in these
  images.
- **Field mode:** the images go through `AppTheme.fieldFilter`, as the app does. Tests also check
  that the dialogs, messages and date picker are red or black *without* the filter (S5.6, S5.8).
- **The evening date** reads "Fri, Nov 13" (`NightTimeFormatter`). The glossary's "Fri 14 Nov"
  order is left to the Stage that adopts the context line (`DESIGN_SYSTEM.md` §7a).

## What the review can change

These are token and component choices (`DESIGN_SYSTEM.md`): colours, weights, radius, spacing, the
field underline, the button looks. Changing one is a small change to `lib/core/theme/` or to one
shared component, re-checked by the gallery test. Nothing here decides a screen's structure; that
is Stage 6's.
