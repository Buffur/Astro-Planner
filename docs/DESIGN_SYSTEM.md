# AstroPlan — Design System

> **S6.11, 2026-09-28:** §7a adds the stacking-gain graph.

> **S6.10, 2026-09-28:** §7a adds the change mark (`ChangeMark`); Budget details' summary uses the glossary's words.

> **S6.9, 2026-09-28:** §6.2 adds `AppMotion.highlight`; §9.1's capture-plan row is done.

> **S6.8, 2026-09-28:** §7 notes the examples' words (`ExampleText`).

> **S6.7, 2026-09-28:** §7a records the planner's five collapsible sections and the Bortle picker; §9's P6.4 rows are done.

> **Status:** living, built by Stage 5 (Design System Foundation; `refinement/POST_ROADMAP_PLAN.md`,
> "Stage 5 — frozen Task sequence"). It describes the **code as built**. Each Stage 5 Task adds its
> part; Stages 6–9 adopt it on the screens (see "Adoption", written by S5.9).
> **Updated:** 2026-09-27, S5.1 (foundation tokens: text roles, surfaces, type scale, spacing,
> radius; the gallery test), S5.2 (controls: buttons, fields, dialogs, sheets, menus, messages,
> icons; states and motion), S5.3 (words: `AppWords` and the retired-terms test), S5.4 (status
> tokens, the status block, the plan-state label), S5.5 (the collapsible section), S5.6 (the
> context line and the night picker), S5.7 (the detail-screen template), S5.8 (confirmation,
> feedback and destructive-action patterns, RD-09 = M + S1) and S5.9 (the adoption plan, §9, and
> rendered evidence). 2026-09-27, Stage 6 planning: §9's Stage 6 P-Tasks mapped to the frozen
> S6-Tasks (documentation only; the code is unchanged).
> **Code:** `lib/core/theme/` (`app_colors.dart`, `app_palette.dart`, `app_typography.dart`,
> `app_spacing.dart`, `app_radius.dart`, `app_motion.dart`, `app_button_styles.dart`,
> `app_theme.dart`).
> **Tests:** `test/core/theme/` (tokens) and `test/presentation/design_system/` (the gallery).

## 1. Principles

- **Answer first, then detail** (PRODUCT_DIRECTION §5.1–§5.2). The type scale and text roles exist
  so the answer reads first and supporting text recedes (08 §7: "nearly all text is white").
- **Clean, minimalist, information-dense, functional** (`.agents/rules/05-ui-design.md`), in the
  Notion-inspired direction, which is a direction and not a restriction (PRODUCT_DIRECTION §5.10).
- **Field use** (`IA_WIREFRAMES.md` §3): targets of at least 48 dp, 200 % text, red mode one tap
  away, red or black only in red mode.
- **Tokens only** (CLAUDE.md trap 12): `lib/presentation` never names a colour, sets text under
  12 sp or shrink-wraps a tap target (`presentation_style_rules_test.dart`). A new colour token
  goes into all three palettes.
- **Rules applied throughout the app, not screen by screen** (08 §27, "Design System"): tokens
  change through the theme; shared components are adopted by the Stage that redesigns a screen.

## 2. Colour

### 2.1 Text roles (`AppPalette`)

| Role | Use | Light | Dark | Field |
| --- | --- | --- | --- | --- |
| `textPrimary` | The answer, values, headings | `#37352F` | `#EBEBEA` | `#FF0000` |
| `textSecondary` | Labels, supporting text | `#5A5955` | `#A5A5A3` | `#AA0000` |
| `textTertiary` | Captions, metadata (zone captions, sources, ages) | `#6E6D69` | `#8F8F8D` | `#880000` |
| `textDisabled` | Inactive controls only | `#A3A29F` | `#6B6B69` | `#660000` |

- **Contrast (light, dark):** primary, secondary and tertiary are WCAG AA (at least 4.5:1) on the
  background, the surface and the raised surface. Worst cases: light 11.4, 6.5 and 4.8; dark 12.8,
  6.2 and 4.7.
- **The step:** each role's worst-case contrast is at least **1.3 times** the next role's, so the
  hierarchy is visible, not only the size. Disabled is below tertiary and exempt from AA (WCAG
  1.4.3 excludes inactive controls).
- **Field mode:** the roles step down in brightness (red only). Secondary and tertiary are below
  AA on purpose, for dark-adapted eyes (ARCHITECTURE B16); contrast is not asserted there.
- **The colour scheme follows the roles:** `onSurface` = primary (so default text is the primary
  role), `onSurfaceVariant` = secondary, and in light and dark `secondary` = secondary.
- **Emphasis also comes from size and weight** (§3): the lower roles pair with the smaller styles.
- Tested by `test/core/theme/design_tokens_test.dart`.

### 2.2 Surfaces

| Level | Token | Light | Dark | Field | Used by |
| --- | --- | --- | --- | --- | --- |
| Background | `scaffoldBackgroundColor` | `#FFFFFF` | `#191919` | `#000000` | Screens |
| Surface | `colorScheme.surface` | `#F7F7F5` | `#202020` | `#110000` | Cards, sections |
| Raised | `AppPalette.surfaceRaised` = `colorScheme.surfaceContainerHigh` | `#FFFFFF` | `#252525` | `#1A0000` | Dialogs, date pickers (Material reads `surfaceContainerHigh`) |
| Border | `AppPalette.border` | `#E9E9E7` | `#2F2F2F` | `#330000` | Card outlines, dividers |

Cards are flat: no elevation, a 1 px border, the small radius.

**Selected container** (light): `colorScheme.secondaryContainer` = the border grey `#E9E9E7` with
`onSecondaryContainer` = primary text, for selected segments and the navigation bar's indicator.
Material would derive it from `secondary`, and black on the darker secondary is only 2.99:1 (the
route sweep caught it on Settings' segmented control). Dark keeps Material's derivation (black on
`#A5A5A3`, AA). Tested: text on the selected container is AA in light and dark.

### 2.3 Control border and error (S5.2)

| Token | Light | Dark | Field | Rule |
| --- | --- | --- | --- | --- |
| `AppPalette.controlBorder` = `colorScheme.outline` | `#8F8E8A` | `#6F6F6D` | `#880000` | A control's boundary (a field's line, an outlined button). At least 3:1 on every surface in light and dark (WCAG 1.4.11). In field mode brighter than a card border, so controls stay visible (UX-39) |
| `colorScheme.outlineVariant` | `#E9E9E7` | `#2F2F2F` | `#330000` | Decorative outlines (chips), as the card border |
| `colorScheme.error` / `onError` | `#B00020` / white | `#F28B82` / `#191919` | `#FF0000` / black | AA as text on every surface, and text on it is AA |

- **Why `outline` is set:** Material falls back to `onBackground` for `outline` and
  `outlineVariant`, so every field's underline and every chip border was black in light and white
  in dark. That was the prominent underline of 08 §6.
- **`FitText`'s neutral** ("needs input") was drawn in `outline`. It is now the secondary text
  role, so it stays AA with the quieter outline (`fit_status_test.dart` asserts AA).

### 2.4 Other tokens

`AppPalette` also holds the night-event, Moon, chart and Bortle colours (TASK 12.4) and `caution`
(S1.9).

### 2.5 Status and state tokens (S5.4)

| Token | Light | Dark | Field | Used for |
| --- | --- | --- | --- | --- |
| `statusFits` | `#37352F` | `#EBEBEA` | `#FF0000` | Fits |
| `statusTight` | `#9A5B00` | `#FFB74D` | `#FF0000` | Tight: a caution, at least as prominent as Fits (S1.9) |
| `statusDoesNotFit` | `#B00020` | `#F28B82` | `#FF0000` | Doesn't fit |
| `statusNoWindow` | `#B00020` | `#F28B82` | `#FF0000` | No window (a real night with none) |
| `statusNeutral` | `#5A5955` | `#A5A5A3` | `#AA0000` | Needs a target / a block: a missing input is not a verdict (UX-15(2)) |
| `stateUnsaved` | `#9A5B00` | `#FFB74D` | `#FF0000` | Not saved, Saved · changed |
| `stateSettled` | `#37352F` | `#EBEBEA` | `#FF0000` | Saved, Tracking, Completed |
| `stateQuiet` | `#5A5955` | `#A5A5A3` | `#AA0000` | Partly, Not done, Old log |

- **Values unchanged:** they are the colours `FitText.color` already drew. It now reads these
  tokens, so every screen keeps its look.
- **Contrast:** every token is AA as text on every surface in light and dark.
- **Field mode:** everything is red, so the word carries the difference.
- **Plan-state tones are tones, not verdicts.** Unsaved work draws attention; nothing is coloured
  good or bad (the ADR-012/ADR-013 spirit).

## 3. Type scale (`AppTypography.scale`)

Every theme uses one scale; sizes are sp (scaled by the user's text size). Letter spacing stays
Material's.

| Style | Size / line | Weight | Role |
| --- | --- | --- | --- |
| `displaySmall` … `displayLarge` | 36/44 … 57/64 | 400 | Rare; large numbers |
| `headlineSmall` … `headlineLarge` | 24/32 … 32/40 | 400 | Rare |
| `titleLarge` | 20/28 | **600** | Screen-level headings |
| `titleMedium` | 16/24 | **600** | Section and card headings; the answer |
| `titleSmall` | 14/20 | **600** | Group headings |
| `bodyLarge` | 16/24 | 400 | Prominent body text |
| `bodyMedium` | 14/20 | 400 | Body text, values, labels |
| `bodySmall` | 12/16 | 400 | Captions, metadata (usually `textTertiary`) |
| `labelLarge` | 14/20 | 500 | Buttons |
| `labelMedium` / `labelSmall` | 12/16 | 500 | Chips, small labels (never under 12) |

- Titles are heavier than Material's defaults (500 or 400) so headings carry the hierarchy.
- The app bar's title is 18/600 (`AppTheme`, TASK 12.4).
- Tested: every style in every theme has the scale's size, line height and weight, and none is
  under 12 sp.

## 4. Spacing and radius

| `AppSpacing` | px | Use |
| --- | --- | --- |
| `xs` | 4 | A label and its value |
| `sm` | 8 | Rows within a section |
| `md` | 16 | A screen's side padding; a card's inner padding |
| `lg` | 24 | Between sections |
| `xl`, `xxl` | 32, 48 | Large separations; 48 is also the minimum tap target |

| `AppRadius` | px | Use |
| --- | --- | --- |
| `small` | 6 | Cards, sections, text fields, buttons |
| `large` | 12 | Dialogs, bottom sheets, a swiped row's background |
| `pill` | 999 | Pills and chips |

## 5. The gallery

`test/presentation/design_system/design_system_gallery_test.dart` renders every token sample and
shared component in the light, dark and field themes at 100 % and 200 % text on a 412 px view. It
audits them like the route sweep (`accessibility_test.dart`): no layout exception, 48 px tap
targets, a label on everything tappable, and AA text contrast in light and dark. A sanity case
proves the audit catches a faint text and an unlabelled button. It also covers what the route
sweep cannot see: components no route uses yet, and dialogs. Each Stage 5 Task adds its components
to it.

## 6. Controls (S5.2)

All set through component themes in `AppTheme._withControls`, from the tokens only, so every
existing control follows them without a screen edit. A widget's own `styleFrom` (a size, a padding)
still merges over them.

### 6.1 Buttons: one hierarchy

| Role | Widget | Look | Use |
| --- | --- | --- | --- |
| **Primary** | `FilledButton` | Filled with `colorScheme.primary`, `onPrimary` text | The screen's one main action (the planner's **Save plan**, ADR-019 §6) |
| **Secondary** | `OutlinedButton` | Transparent, `textPrimary` text, a 1 px `controlBorder` | Other actions beside it |
| **Tertiary** | `TextButton` | `textPrimary` text only | Low-weight actions; Cancel in dialogs |
| **Destructive** | `FilledButton` or `TextButton` with `AppButtonStyles.destructive` / `destructiveText` | `error` fill, or `error` text | A delete or discard (S5.8's patterns) |
| **Icon** | `IconButton` with a `tooltip` | `onSurfaceVariant` icon | Toolbar actions; the tooltip is its label |

- **All buttons:** at least 48 dp tall (filled, outlined and elevated draw 48; text and icon buttons
  keep Material's padded 48 dp tap target). Small radius, `labelLarge` text.
- **Disabled:** `textDisabled` text on transparent (secondary, tertiary), or Material's disabled
  fill (primary). WCAG exempts disabled controls from contrast.
- **`ElevatedButton`** has no elevation in this flat design. It is themed as the secondary role on
  the surface fill. New code uses `OutlinedButton`; the elevated ones are replaced as their screens
  are redesigned (S5.9's adoption list). Since S6.2 the planner's Save plan is the filled
  primary button, alone in its bottom bar, and Start is Track live in ⋮ (UX-34).

### 6.2 States and motion

- **Pressed:** a 16 % overlay of the foreground (`AppTheme.pressedOverlay`); Material's is 10 %.
  This answers 08 §8's weak "+" feedback. Focused 12 %, hovered 8 %.
- **Motion (`AppMotion`):** `highlight` 1500 ms for the fading mark on what an edit changed (S6.9, a
  capture block's row; none with reduced motion); `short` 150 ms for a state change in place, `medium` 250 ms for content
  appearing or collapsing, one curve (`easeOutCubic`).
  `AppMotion.duration(context, …)` returns zero when the platform asks for less motion
  (`disableAnimations`). Every Stage 5 component animates through it. Subtle only
  (`.agents/rules/05-ui-design.md`).
- **Never give `AnimatedSize` a zero duration:** it throws a layout assertion (S5.5's
  reduced-motion test found it). With reduced motion, leave the `AnimatedSize` out, as
  `CollapsibleSection` does.

### 6.3 Text fields

- **A quiet underline (08 §6):**
  - the enabled line is 1 px in `controlBorder` (Material reads `colorScheme.outline`);
  - focus draws it 2 px in `primary`; an error in `error`.

  The field's geometry is unchanged, so no field's text room shrank (TD-069's fit test passes).
- **Label** `textSecondary`; the floating label is `primary` when focused and `error` on an error.
  **Hint** and **helper** are `textTertiary`, **error** text is `error`, and prefix and suffix icons
  are `textSecondary`: all AA. A `filled` field uses the surface colour.
- A field that sets its own border keeps it. The target search, for example, is a filled box with
  no line.

### 6.4 Dialogs, sheets, menus, messages, dividers

- **Dialogs:** the raised surface, a 1 px border, the large radius. The title is `titleLarge` in
  `textPrimary`; the content is `bodyMedium` in `textSecondary`.
- **Bottom sheets:** the raised surface, top corners large.
- **Popup and dropdown menus:** the raised surface, a 1 px border, the small radius; items
  `bodyMedium` in `textPrimary`.
- **Messages (snackbars):** light and dark invert: `textPrimary` background, background-coloured
  text and action, AA. Field mode keeps its dim message (a `#330000` background with red text),
  never a bright red block.
- **Dividers:** 1 px in `border` (TASK 12.4).

### 6.5 Icons

- **Material icons, 24 dp** (the theme's default), outlined where a variant exists. An icon-only
  button always has a `tooltip`.
- **One icon per common action:**
  - add `Icons.add`;
  - edit `Icons.edit_outlined`;
  - delete `Icons.delete_outline`;
  - reorder `Icons.drag_indicator`;
  - more `Icons.more_vert`;
  - info `Icons.info_outline`;
  - expand `Icons.expand_more` / collapse `Icons.expand_less`;
  - open a detail `Icons.chevron_right`.
- The capture plan's current `drag_handle` and red delete icon (08 §14) change when Stage 6 adopts
  this set.

## 7. Words (S5.3)

- **One name per concept** (RD-14; ADR-019 §10). The owner's glossary
  (`refinement/research/S4.R5_LIBRARY_AND_VOCABULARY.md` §5) is normative, and
  `lib/presentation/shared/app_words.dart` (`AppWords`) holds its words once, as `QuantityText`
  holds number formats:
  - Rig;
  - Plan: New plan, Save plan, Your plan, Copy to another night;
  - Logbook; Night;
  - Capture plan and block;
  - the plan states (Not saved · Saved · Saved · changed) and the results (Tracking · Completed ·
    Partly · Not done · Old log);
  - Record result, Edit result, Track live (optional), Completed as planned;
  - the verdict words and the headline ("Fits: … needed of … usable");
  - Dark, Darkness limit, Imaging window, and the twilight names (the Night & Moon detail only);
  - Integration, Imaging time, Time needed, Total time, Budget details;
  - Relative stacking gain (√N vs one frame), never "SNR";
  - Site, Library, Progress by target;
  - Export as file, Name (optional).
- **New strings use `AppWords`**; a screen never spells a glossary term itself.
  `app_words_test.dart` pins every word to the glossary, so changing one is changing the owner's
  glossary.
- **The retired terms**: "Equipment profile", "Session planner", "Draft", "Legacy", "True Night
  Window", "Astro Dusk/Dawn", "Window load", "Acquisition", "Session budget".
  - `retired_terms_test.dart` scans `lib/presentation`'s string literals for them (any case,
    plurals included). Imports, `Key` values, comments and identifiers are exempt.
  - It compares what it finds with an explicit **baseline**: 16 occurrences in 8 files at
    `38925dd`, listed in the test. A new occurrence fails. A baseline entry that no longer occurs
    also fails, so the baseline only shrinks.
  - Stages 6, 8 and 9 remove entries as they redesign their screens, and P9.2 empties it (S5.9
    maps each entry to its Stage).
  - It reads a line at a time, so a term split across two string literals is not seen.

**S6.8 (2026-09-28), the examples' words:** "Start from the example plan" is RD-04's own phrase;
"Example plan" (TASK 4.4) and "Example rig" name the shipped examples. They live in `ExampleText`
(`lib/presentation/shared/example_text.dart`), not in `AppWords`, which holds the owner's glossary;
the owner may move them there.

**S6.6 (2026-09-28), two status words outside `AppWords`:** the planner's status applies the
glossary's "Needs a …" pattern (Needs a target, Needs a block) to a missing site and a missing rig:
**"Needs a site"** and **"Needs a rig"** (`PlanStatus.needsSite`, `needsRig`). They are not added
to `AppWords`, which holds the owner's glossary; the owner may confirm them there.

## 7a. Components and patterns

### The status block (S5.4; `lib/presentation/shared/status_block.dart`)

The answer first (ADR-019 §6; addendum §3.1–§3.2).
- **The headline:** `titleMedium`, a semantic header, in the state's status colour. It uses the
  glossary's words:
  - with both durations known: "Fits: 2 h 5 min needed of 4 h 20 min usable" (likewise Tight and
    Doesn't fit);
  - with a duration unknown: the word alone. Unknown is never shown as zero;
  - otherwise: "No window", "Needs a target" (or the missing word the screen passes), "Needs a
    block".
- **Then:** the reason (`textSecondary`); optional key numbers as label (`textTertiary`) and value
  (`textPrimary`) pairs that wrap; an optional action slot (fill or trim).
- **Plain values in.** The state, durations and reason come from the fit analysis through the
  ViewModel; durations are formatted with `QuantityText`. It calculates nothing (trap 13).
- `StatusBlock.headline(...)` is pure and tested.

### The plan-state label (S5.4; `lib/presentation/shared/plan_state.dart`)

- **`PlanState`:** Not saved · Saved · Saved · changed · Tracking · Completed · Partly · Not done ·
  Old log (ADR-019 §3). The stored statuses stay internal; "Draft" is never shown.
- **The mapping:** `PlanState.from(status, savedBefore, legacy)` maps today's stored fields: a
  legacy row is an Old log; a `draft` is Not saved, or Saved · changed once saved before
  (`plannedAtUtc`); `planned` is Saved; `inProgress` is Tracking; `completed` is Completed;
  `abandoned` is Not done. Every combination is tested.
- **Partly** has a word and a tone, but no stored data expresses it until Stage 8's result form.
- **`PlanStateLabel`:** the word in its tone (`labelMedium`), in a quiet pill outlined in `border`.
  It wraps at 200 % text and is not tappable.

### The stacking-gain graph (S6.11; `widgets/capture_plan/stacking_gain_graph.dart`)

One compact graph under each (filter, exposure) group's √N line: `StackingGainCurve`'s points
(CALC-42) from one frame to twice the planned count, drawn in `chartTarget` over a `chartGrid`
baseline, the planned count marked with `chartNow`/`chartNowCentre` (the altitude chart's "now"
dot) and a guide line. 48 px high; the axis' ends are `Text` below it (`bodySmall`,
`textTertiary`) so they scale and wrap. The number stays in the line above; the section's title is
`AppWords.relativeStackingGain`. The text alternative gives the group's value and where the curve
ends. A `CustomPaint`: no chart dependency.

### The change mark (S6.10; `lib/presentation/shared/change_mark.dart`)

Cause and effect after an edit (P6.9's notes): `ChangeMark(value:, child:)` tints its child when
`value` (what the ViewModel already shows) changes, fading over `AppMotion.highlight`; never on the
first build, never with reduced motion; it keeps no calculation state. Adopted by the planner's
status and Budget details' summary. A capture block's row uses the same idea on the tile's own
colour (S6.9), since a `ListTile` must not sit on a coloured box.

### The collapsible section (S5.5; `lib/presentation/shared/collapsible_section.dart`)

Detail one tap away (ADR-019 §7; RD-06, RG-06: progressive disclosure, no modes).
- **The header:**
  - it is at least 48 dp and the whole row is tappable, with an `InkWell` ripple;
  - it shows the title (`titleSmall`, `textPrimary`), the **factual summary** (`bodyMedium`,
    `textSecondary`) and a chevron that turns (`AppMotion.short`);
  - the summary stays visible when the section is open.
- **The summary states facts, never a verdict** ("4 lines · 2 h 35 min total", not "looks
  good"). The verdict belongs to the status block. What each summary says is decided where it is
  adopted (Stage 6).
- **The content:** it opens below the header (`AnimatedSize`, `AppMotion.medium`; none with
  reduced motion). It is not built while closed.
- **Semantics:** one button node labelled "title, summary", with `expanded` true or false, the
  hint "Expand" or "Collapse", and a tap action (trap 17: `enabled` and `onTap` are set).
- **Remembered per `sectionKey`** (`DisclosureViewModel`, in `AppViewModels`; loaded before the
  first frame, like field mode):
  - closed by default, unless the caller passes `initiallyOpen`;
  - stored in `DisplayPreferencesRepository` (`section.<key>` in SharedPreferences);
  - a store that cannot be read or written is logged, and the section still opens and closes;
  - keys are stable names such as `planner.budgetDetails`: never rename one without a reason.
- **In the planner (S6.7):** five sections, their keys in `PlannerSections`
  (`lib/presentation/widgets/planner_sections.dart`):

  | Section | Summary (a fact) | Content |
  | --- | --- | --- |
  | Budget details | "Time needed 2 h 5 min · Total time 3 h" (S6.10: the glossary's words; marked when an edit changes it) | Every ADR-009 line in the glossary's words (Integration, Imaging time, Time needed, Calibration during and outside the window, Setup, Total time, Library calibration); the zone rule when the setup time is shown |
  | Relative stacking gain (√N vs one frame) | "Per filter and exposure, against one frame" | The √N explanation; the √N values stay visible below the section (SI-003) |
  | Assumptions | "Darkness limit −18° · minimum altitude 30° · margin 15 %" (the constraints that shape the window stay in view) | Every overhead and threshold, the placement rule, the link to Settings |
  | Specifications (the rig) | "400 mm · f/5.0 · Tracking: Guided" (the focal ratio's review flag stays in view) | Focal length, focal ratio, sensor, tracking. The values the plan uses and the capability warnings stay on the card |
  | Sky darkness | "Bortle 4 · SQM 21.30 mag/arcsec²", "Unknown", "not saved" | The Bortle picker, the values with source and date, the light-pollution map link |

  The accessibility sweep also audits the planner with every `PlannerSections.all` key open, so a
  new section's key joins that list.
- **The Bortle picker (S6.7):** the class's conventional colour is a swatch beside the text, which
  uses the text roles, at 48 dp. The old badge (white text on the class colour, 32 px high) failed
  the tap-target and contrast guidelines once the sweep could see it.

### The context line (S5.6; `lib/presentation/shared/context_line.dart`)

"Ljubljana ▾ · Fri, Nov 13 ▾": the one control that says which site and night a screen describes,
for Tonight and the planner (ADR-019 §5, §6; addendum §3.1–§3.2).
- **Two parts:** the site and the night, each its own button (at least 48 dp, `titleSmall` in
  `textPrimary`, a ▾ in `textSecondary`).
  - Screen readers hear "Site: Ljubljana" and "Night: Fri, Nov 13", with the hints "Choose a site"
    and "Choose a night".
  - The line wraps at 200 % text.
- **Callbacks only:** each part reports its tap. What choosing does (the site picker, or changing
  the current plan's night, UX-11) is decided where the line is adopted (P6.3, P6.6).
- **The zone rule, once** (trap 2), in `textTertiary` below the line:
  - "Times in site zone Europe/Ljubljana, CET, UTC+01:00";
  - when the site has no zone: "Times in device zone, UTC…" (`NightTimeFormatter.zoneCaption`).
- **No site:** the site part reads "No site set". There is no night part and no zone rule (no
  night without a site, ADR-007 §9).
- **The night is today's `NightTimeFormatter.eveningDate`** ("Fri, Nov 13"). The glossary's "Fri
  14 Nov" order is a formatter change for the Stage that adopts the line, not S5.6's.

**The night picker** (`pickNight`, same file): the date picker in the app's theme, from a year ago
to five years ahead as the planner's picker allows, titled "Choose a night". It returns the chosen
evening as a `CalendarDate`, or null when cancelled. Tested red or black in field mode **by its
theme alone**, without the app-wide red filter.

### The detail-screen template (S5.7; `lib/presentation/shared/detail_scaffold.dart`)

`DetailScaffold`: one layout for the detail screens, Night & Moon and Weather first (ADR-019 §9;
addendum §3.4–§3.5), top to bottom:
1. **The header:**
   - the title (`titleLarge`, a semantic header);
   - its context ("Fri, Nov 13 · Ljubljana", `bodyMedium` in `textSecondary`);
   - the zone rule, exactly once (`bodySmall` in `textTertiary`; `ContextLine.zoneRule`).

   All three wrap at 200 % text. So the title lives in the page header, not in the app bar, which
   keeps only back and the actions (an app bar's title cannot wrap).
2. **The summary**, on a card: facts, no score and no good or bad colour (ADR-012 for weather).
3. **The full content:** the sections, separated by dividers. A long section is a
   `CollapsibleSection`.

**Every time on the page is in the zone the header names; a section never repeats the zone
caption.** The gallery sweeps a sample Night & Moon page (not a route) in the three themes at
100 % and 200 % text. Stage 6 adds the real detail routes (`AppRouter` constants) to the route
sweep (trap 17).

### Confirmation, feedback and deleting (S5.8; RD-09 = M + S1, DECISIONS E.1)

**Which pattern for which action:**

| Action | Pattern |
| --- | --- |
| Replacing a plan with unsaved changes (New plan, Copy, Open; P6.1) | `askUnsavedChanges`: Save · Discard · Cancel |
| Deleting an edit inside a plan: a capture block | At once, with `showUndo` |
| Deleting a stored record: a rig, a target, a site, a Logbook entry | `confirmDestructive`, then delete |
| Abandon (a live run), Restore (a backup), resetting data | `confirmDestructive` with its own verb |
| Any action that succeeded: New plan, Copy, Open, Save | `showDone` ("New plan started", "Copied to …", "Plan saved") |
| Any action that failed | `runWithFeedback` (TASK 15.1) |

- **`askUnsavedChanges`** (`confirmation_patterns.dart`; addendum §3.3):
  - "Unsaved changes", '"M42 · Fri, Nov 13" has changes that are not saved.', then Cancel ·
    Discard · Save;
  - Discard is styled destructive;
  - back or a tap outside is Cancel;
  - it returns the choice only. Since S6.3 the planner's `askBeforeLeavingPlan`
    (`unsaved_plan_prompt.dart`) wraps it and does Save; the lifecycle does Discard (a never-saved
    plan deleted, a saved one reverted, S4-DEF-04 = R). The S1.6 guard is gone.
- **`confirmDestructive`** (same file):
  - the title names the item ('Delete rig "Refractor 400"?') and the message the consequence;
  - Cancel, then the destructive verb (`AppButtonStyles.destructiveText`);
  - it is true only when the verb is tapped: Cancel, back and a tap outside all keep the item. It
    replaces today's four differently worded delete dialogs as their screens adopt it.
- **`showUndo`** (`delete_patterns.dart`):
  - "Block deleted · Undo", shown after the edit is applied;
  - it reports **exactly one outcome**: `onUndo` when Undo is tapped, otherwise `onCommit` when
    the message closes (it timed out after 6 s, was swiped away or was replaced);
  - `persist: false` is required, because Flutter otherwise keeps any message with an action on
    screen until it is dismissed, and Undo would never commit (the time-out test found it);
  - the adopter restores exactly and tests its own restore.
- **`showDone`** (`failure_feedback.dart`, next to `runWithFeedback`): a short message naming what
  happened. It replaces the previous message.
- **The visible Delete, `DeleteButton`** (S1; UX-38): an icon button (`Icons.delete_outline`)
  whose tooltip is its label ("Delete rig"). Where it sits is decided at adoption: blocks in Stage
  6, the Logbook in Stage 8, the Library in Stage 9.
- **`SwipeToDelete`** (S1; 08 §20):
  - a swipe from the end calls the **same handler** as the visible Delete;
  - the row springs back at once, and is never left slid away behind a dialog. The handler then
    confirms or deletes with Undo, and the list drops the row when the item is really gone;
  - the background is the error colour with a delete icon, large radius.
- **Field mode:** the prompt, the confirmation and both messages are red or black by the theme
  alone (a pixel test without the app's red filter). The message is the dim field message, never a
  white flash.

## 8. Known gaps, for adoption

What S5.1 and S5.2 changed app-wide, and what they leave to the Stages that redesign screens:
- **Changed app-wide by the theme:**
  - default text is the primary role (light `#37352F` instead of black; dark `#EBEBEA` instead of
    white);
  - light secondary text is darker (`#5A5955`, AA; `#787774` was below AA: 4.48:1 on white and
    4.17:1 on the surface);
  - titles are heavier;
  - dialogs and date pickers sit on the raised surface;
  - in light, selected segments and the navigation indicator are a light grey with primary text
    (they were the secondary grey with black text);
  - (S5.2) field underlines and chip borders are the quiet control border instead of black or
    white; buttons share one shape, 48 dp primary and secondary heights, and a stronger pressed
    overlay; elevated buttons are flat and outlined;
  - (S5.2) dialogs are bordered with a smaller title; messages invert in light and dark;
  - (S5.2) dark mode's error colour is `#F28B82` (Material's `#CF6679` was 4.26:1 on the raised
    surface), so "Doesn't fit" and error text are lighter red in dark;
  - (S5.2) the planner's "needs input" status reads in the secondary text colour, as before
    neutral;
  - (S5.2) in field mode, outlined buttons and field lines are `#880000` instead of `#660000`
    (UX-39).
- **Left for adoption:**
  - screens still colour values with `colorScheme.primary` and labels with `colorScheme.secondary`
    (e.g. `InfoRow`), and pick sizes per widget (10 `fontSize` and 34 `fontWeight` overrides);
  - `AppPalette.muted` (Material grey) is below AA as text in light: text should use
    `textTertiary`, and `muted` stays for icons and empty-state glyphs until adopted;
  - radius literals (for example a swiped row's 12) move to `AppRadius` when their screen is
    redesigned;
  - (S5.2) the 7 `ElevatedButton`s become `OutlinedButton` or `FilledButton` by role, and the
    planner's Save plan becomes primary (P6.3);
  - (S5.2) icons follow §6.5 as their screens are redesigned;
  - (S5.8) the existing delete paths (a capture block at once without undo; swipe-only rigs,
    targets and Logbook entries behind a lingering dialog; a site's dialog) keep their behaviour
    until they adopt §7a's patterns (Stages 6, 8, 9). The S1.6 guard and the silent New and
    Duplicate were replaced by S6.2 and S6.3;
  - (S5.4) the planner, Tonight and the Logbook still show their own status texts ("Draft",
    "Planned, unsaved changes", "In progress", "Abandoned", "Legacy log", "Fit tonight: …"). They
    adopt `StatusBlock` and `PlanStateLabel` in P6.1, P6.3, P6.6 and P8.5.

## 9. Adoption (S5.9)

Stage 5 changed no screen's structure or wording. The theme (§2–§6) already applies everywhere; the
words, components and patterns below are adopted by the Stage that redesigns each screen. The
P-IDs are the provisional Tasks of Stages 6, 8 and 9 (`refinement/POST_ROADMAP_PLAN.md`). Each
Stage's own planning freezes them, and may move an item between its Tasks; it may not drop one
without saying where it went.

**Stage 6, frozen 2026-09-27** (`refinement/POST_ROADMAP_PLAN.md`, "Stage 6 — frozen Task
sequence"): P6.1 → S6.2 (the app bar, `PlanStateLabel`, `showDone`, `pickNight`) and S6.3
(`askUnsavedChanges`); P6.2 → S6.8; P6.3 → S6.6; P6.4 → S6.7; P6.5 → S6.5; P6.6 → S6.13 (with
TD-073's site prompt); "the Stage 6 capture-plan work" (P6.8) → S6.9. P6.9–P6.11 → S6.10–S6.12. No
item was dropped. Where the tables below say P6.x, read the S-Task.

### 9.1 By screen

| Screen or widget (today) | Adopts | P-Task | Retired terms it removes from S5.3's baseline |
| --- | --- | --- | --- |
| The planner's app bar (`home_screen.dart`: "Session planner", "+", Duplicate) | `PlanStateLabel` in the title (target · night · state); `askUnsavedChanges` instead of the S1.6 guard; `showDone` after New plan, Copy, Open and Save; `pickNight` for Copy to another night; `AppWords` (New plan, Copy to another night) | P6.1 (**S6.2 and S6.3 done**). The identity is a strip under the app bar, which wraps | Session planner (removed by S6.2) |
| The planner's body (`home_screen.dart`: empty state, "Session Date", sections, bottom bar) | `StatusBlock` first; `ContextLine` + `pickNight` instead of the "Session Date" row; text roles and the type scale instead of explicit styles; the button hierarchy (Save plan filled, the `ElevatedButton`s gone) | P6.3 (**S6.6 done**: `PlanStatus`; the context line; no empty state; `InfoRow` text roles) | Equipment profile (the empty state; **removed by S6.6**) |
| Budget summary and assumptions (`capture_budget_summary.dart`, `capture_assumptions_panel.dart`), rig rows, sky-darkness detail | `CollapsibleSection` (Budget details, Assumptions instead of its `ExpansionTile`, the rig's rows, sky detail) with factual summaries; `AppWords` budget names | P6.4 (**S6.7 done**: `PlannerSections`, see §7a) | Acquisition, Session budget (budget summary; **removed by S6.7**) |
| Sky darkness and weather detail (`sky_darkness_widget.dart`, `weather_forecast_widget.dart`) | `DetailScaffold` for Night & Moon and Weather; the twilight names from `AppWords`, on the Night & Moon detail only | P6.5 (**S6.5 done**: `/night`, `/weather`) | Astro Dusk, Astro Dawn, True Night Window (with TD-051; **removed by S6.5**) |
| Tonight (`tonight_home_screen.dart`: site card, night rows, plan card, actions) | `ContextLine` instead of the site card; `StatusBlock` and `PlanStateLabel` in "Your plan"; rows to the P6.5 details; `showDone` for New plan | P6.6 | Draft (Tonight's status) |
| The capture plan (`capture_plan_widget.dart`, `capture_block_dialog.dart`) | `showUndo` for a deleted block (RD-09 M; restore tested there); `DeleteButton`; `SwipeToDelete` if block rows swipe; the §6.5 icons (reorder, delete); the dialog's Save as the primary button | Stage 6 capture-plan work (the Stage 6 table's "Capture Plan" row; RD-09) (**S6.9 done**: `DeleteButton` + `showUndo` with an exact restore; `drag_indicator`; `FilledButton` Save; rows through `BlockText`; the change mark on `AppMotion.highlight`. The rows do not swipe, so no `SwipeToDelete`) | — |
| The result form and the live tracker (`results_screen.dart`, `execution_screen.dart`) | `confirmDestructive` for Abandon; `showDone` after Save result; `PlanStateLabel` | P8.2, P8.4 | — |
| The Logbook and an entry (`logbook_screen.dart`, `session_detail_screen.dart`) | `PlanStateLabel` instead of `sessionStatusLabel`; `SwipeToDelete` + `DeleteButton` + `confirmDestructive` instead of the swipe-only `Dismissible`; `AppWords` (Logbook, Export as file, Old log, the budget names); `DetailScaffold` where an entry fits it | P8.5 | Legacy (×3), Draft, Window load, Session budget |
| The Library lists (`equipment_selection_screen.dart`, `target_selection_screen.dart`, `sites_screen.dart`) | `SwipeToDelete` + `DeleteButton` + `confirmDestructive` (one wording instead of four); the button hierarchy; `AppWords` (Rig, Add rig) | P9.1 | Equipment profile (the empty rig list) |
| The rig editor and the other editors (`equipment_editor.dart`, site and target forms) | The field look is already themed (§6.3); `AppWords` titles and labels; the dialog's Save as the primary button | P9.2 (with Stage 7 when it reworks the forms) | Equipment profile (the editor's title) |
| Settings and About (`settings_screen.dart`, `backup_section.dart`, `about_screen.dart`) | `confirmDestructive` for Restore; text roles; `CollapsibleSection` where RG-13 keeps advanced settings | Stage 9 (Settings, after RG-13) and P9.2 | — |
| Messages with an action (`location_feedback.dart`, `start_session.dart`; TD-073) | A decision per message: keep until dismissed, or `persist: false` | P6.6 (the site prompt), P8.4 (Track live replaces Start) | — |
| Shared rows (`info_row.dart`, `planner_summary_card.dart`) | Text roles instead of `colorScheme.primary`/`secondary` for values and labels | With the screens that show them (P6.3, P6.4) | — |
| Deletion animations everywhere (08 §20) | `AppMotion` and `SwipeToDelete`; nothing else animates | Stage 9 ("deletion interactions and animations") | — |

### 9.2 By component: at least one adopter each

| Part (S5.x) | Adopted by |
| --- | --- |
| Text roles, type scale, surfaces, spacing, radius (S5.1) | Every redesigned screen: P6.3, P6.4, P6.5, P6.6, P8.5, P9.1, P9.2 |
| Button hierarchy, `AppButtonStyles`, field look, dialogs, messages, icons, `AppMotion` (S5.2) | P6.3 (Save plan primary), Stage 6 capture plan (icons), P9.1, P9.2; `AppMotion` through every component, Stage 9 animations |
| `AppWords` and the retired-terms baseline (S5.3) | P6.1, P6.3, P6.4, P6.5, P6.6, P8.5, P9.1, P9.2 (the last empties the baseline) |
| Status tokens, `StatusBlock` (S5.4) | P6.3 (the planner's status), P6.6 (Tonight's plan card) |
| `PlanState`, `PlanStateLabel` (S5.4) | P6.1 (the app bar), P6.6, P8.2, P8.5 |
| `CollapsibleSection`, `DisclosureViewModel` (S5.5) | P6.4, P6.5 |
| `ContextLine`, `pickNight` (S5.6) | P6.3, P6.6 (`ContextLine`); P6.1 (`pickNight` for Copy) |
| `DetailScaffold` (S5.7) | P6.5 (Night & Moon, Weather); their routes join the accessibility sweep |
| `askUnsavedChanges`, `showDone` (S5.8) | P6.1 (New plan, Copy, Open, Save); `showDone` also P6.6, P8.2 |
| `confirmDestructive` (S5.8) | P8.4 (Abandon), P8.5 (Logbook entries), P9.1 (rigs, targets, sites), Stage 9 Settings (Restore) |
| `showUndo`, `DeleteButton`, `SwipeToDelete` (S5.8) | Stage 6 capture plan (`showUndo`, `DeleteButton`); P8.5 and P9.1 (`SwipeToDelete`, `DeleteButton`) |

### 9.3 The retired-terms baseline, by Stage

| Baseline entry (`retired_terms_test.dart`) | Removed by |
| --- | --- |
| `home_screen.dart`: Session planner | P6.1 (**removed by S6.2**) |
| `home_screen.dart`: Equipment profile | P6.3 (**removed by S6.6**) |
| `capture_budget_summary.dart`: Acquisition, Session budget | P6.4 (**removed by S6.7**) |
| `sky_darkness_widget.dart`: Astro Dusk, Astro Dawn, True Night Window | P6.5 (**removed by S6.5**) |
| `tonight_home_screen.dart`: Draft | P6.6 |
| `logbook_screen.dart`: Legacy (2), Draft | P8.5 |
| `session_detail_screen.dart`: Legacy, Window load, Session budget | P8.5 |
| `equipment_selection_screen.dart`: Equipment profile | P9.1 |
| `equipment_editor.dart`: Equipment profile | P9.2 (or Stage 7 if it reworks the rig form first) |

After P9.2 the baseline is empty (S5.3; ADR-019 §10).

### 9.4 Rendered evidence

Host-rendered images of the gallery and the sample detail page, for the owner's review (optional,
non-blocking): `refinement/evidence/stage5/` and
[`refinement/evidence/STAGE_5_RENDERS.md`](refinement/evidence/STAGE_5_RENDERS.md). They are made
by the opt-in `test/presentation/design_system/render_gallery_test.dart`
(`ASTROPLAN_RENDER_GALLERY`), which stays outside the gate. Host renders only: they are not device
evidence.
