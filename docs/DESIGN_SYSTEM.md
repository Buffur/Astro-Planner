# AstroPlan — Design System

> **Status:** living, built by Stage 5 (Design System Foundation; `refinement/POST_ROADMAP_PLAN.md`,
> "Stage 5 — frozen Task sequence"). It describes the **code as built**. Each Stage 5 Task adds its
> part; Stages 6–9 adopt it on the screens (see "Adoption", written by S5.9).
> **Updated:** 2026-09-27, S5.1 (foundation tokens: text roles, surfaces, type scale, spacing,
> radius; the gallery test), S5.2 (controls: buttons, fields, dialogs, sheets, menus, messages,
> icons; states and motion) and S5.3 (words: `AppWords` and the retired-terms test).
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
(S1.9). Status colours are S5.4's.

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
  are redesigned (S5.9's adoption list). Until then, the planner's "Save Session" is secondary
  beside a filled "Start", as UX-34 describes. Stage 6 (P6.3) makes Save plan primary and moves
  Start into ⋮.

### 6.2 States and motion

- **Pressed:** a 16 % overlay of the foreground (`AppTheme.pressedOverlay`); Material's is 10 %.
  This answers 08 §8's weak "+" feedback. Focused 12 %, hovered 8 %.
- **Motion (`AppMotion`):** `short` 150 ms for a state change in place, `medium` 250 ms for content
  appearing or collapsing, one curve (`easeOutCubic`).
  `AppMotion.duration(context, …)` returns zero when the platform asks for less motion
  (`disableAnimations`). Every Stage 5 component animates through it. Subtle only
  (`.agents/rules/05-ui-design.md`).

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

## 7a. Components and patterns

Added by S5.4–S5.7 (components) and S5.8 (confirmation, feedback and destructive actions, per
RD-09 = M + S1).

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
  - (S5.2) icons follow §6.5 as their screens are redesigned.

## 9. Adoption

Written by S5.9: which screen adopts which part, and in which Stage.
