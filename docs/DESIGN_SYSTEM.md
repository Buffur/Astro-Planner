# AstroPlan — Design System

> **Status:** living, built by Stage 5 (Design System Foundation; `refinement/POST_ROADMAP_PLAN.md`,
> "Stage 5 — frozen Task sequence"). It describes the **code as built**. Each Stage 5 Task adds its
> part; Stages 6–9 adopt it on the screens (see "Adoption", written by S5.9).
> **Updated:** 2026-09-27, S5.1 (foundation tokens: text roles, surfaces, type scale, spacing,
> radius; the gallery test).
> **Code:** `lib/core/theme/` (`app_colors.dart`, `app_palette.dart`, `app_typography.dart`,
> `app_spacing.dart`, `app_radius.dart`, `app_theme.dart`).
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

### 2.3 Other tokens

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

## 6. Controls, words, components and patterns

Added by S5.2 (controls), S5.3 (words), S5.4–S5.7 (components) and S5.8 (confirmation, feedback and
destructive actions, per RD-09 = M + S1).

## 7. Known gaps, for adoption

What S5.1 changed app-wide, and what it leaves to the Stages that redesign screens:
- **Changed app-wide by the theme:**
  - default text is the primary role (light `#37352F` instead of black; dark `#EBEBEA` instead of
    white);
  - light secondary text is darker (`#5A5955`, AA; `#787774` was below AA: 4.48:1 on white and
    4.17:1 on the surface);
  - titles are heavier;
  - dialogs and date pickers sit on the raised surface;
  - in light, selected segments and the navigation indicator are a light grey with primary text
    (they were the secondary grey with black text).
- **Left for adoption:**
  - screens still colour values with `colorScheme.primary` and labels with `colorScheme.secondary`
    (e.g. `InfoRow`), and pick sizes per widget (10 `fontSize` and 34 `fontWeight` overrides);
  - `AppPalette.muted` (Material grey) is below AA as text in light: text should use
    `textTertiary`, and `muted` stays for icons and empty-state glyphs until adopted;
  - radius literals (for example a swiped row's 12) move to `AppRadius` when their screen is
    redesigned.

## 8. Adoption

Written by S5.9: which screen adopts which part, and in which Stage.
