---
name: Forest Focus System
colors:
  surface: '#eaffee'
  surface-dim: '#cbdfcf'
  surface-bright: '#eaffee'
  surface-container-lowest: '#ffffff'
  surface-container-low: '#e4f9e8'
  surface-container: '#dff3e2'
  surface-container-high: '#d9eddd'
  surface-container-highest: '#d3e8d7'
  on-surface: '#0e1f15'
  on-surface-variant: '#3f4941'
  inverse-surface: '#233429'
  inverse-on-surface: '#e2f6e5'
  outline: '#6f7a71'
  outline-variant: '#bfc9bf'
  surface-tint: '#1a6c43'
  primary: '#005a34'
  on-primary: '#ffffff'
  primary-container: '#24734a'
  on-primary-container: '#a6f5c2'
  inverse-primary: '#89d7a6'
  secondary: '#984800'
  on-secondary: '#ffffff'
  secondary-container: '#ff964e'
  on-secondary-container: '#6e3200'
  tertiary: '#465047'
  on-tertiary: '#ffffff'
  tertiary-container: '#5e685f'
  on-tertiary-container: '#dce7db'
  error: '#ba1a1a'
  on-error: '#ffffff'
  error-container: '#ffdad6'
  on-error-container: '#93000a'
  primary-fixed: '#a5f4c0'
  primary-fixed-dim: '#89d7a6'
  on-primary-fixed: '#002110'
  on-primary-fixed-variant: '#00522f'
  secondary-fixed: '#ffdbc8'
  secondary-fixed-dim: '#ffb689'
  on-secondary-fixed: '#311300'
  on-secondary-fixed-variant: '#743500'
  tertiary-fixed: '#dbe5d9'
  tertiary-fixed-dim: '#bfc9be'
  on-tertiary-fixed: '#151e16'
  on-tertiary-fixed-variant: '#404941'
  background: '#eaffee'
  on-background: '#0e1f15'
  surface-variant: '#d3e8d7'
typography:
  headline-xl:
    fontFamily: Inter
    fontSize: 32px
    fontWeight: '700'
    lineHeight: 40px
    letterSpacing: -0.02em
  headline-lg:
    fontFamily: Inter
    fontSize: 26px
    fontWeight: '700'
    lineHeight: 34px
    letterSpacing: -0.015em
  headline-md:
    fontFamily: Inter
    fontSize: 20px
    fontWeight: '600'
    lineHeight: 28px
    letterSpacing: -0.01em
  headline-sm:
    fontFamily: Inter
    fontSize: 18px
    fontWeight: '600'
    lineHeight: 24px
  body-lg:
    fontFamily: Inter
    fontSize: 16px
    fontWeight: '500'
    lineHeight: 24px
    letterSpacing: -0.005em
  body-md:
    fontFamily: Inter
    fontSize: 14px
    fontWeight: '400'
    lineHeight: 20px
  body-sm:
    fontFamily: Inter
    fontSize: 13px
    fontWeight: '400'
    lineHeight: 18px
  label-lg:
    fontFamily: Inter
    fontSize: 14px
    fontWeight: '600'
    lineHeight: 20px
  label-md:
    fontFamily: Inter
    fontSize: 12px
    fontWeight: '600'
    lineHeight: 16px
    letterSpacing: 0.02em
  label-sm:
    fontFamily: Inter
    fontSize: 11px
    fontWeight: '500'
    lineHeight: 14px
    letterSpacing: 0.03em
rounded:
  sm: 0.25rem
  DEFAULT: 0.5rem
  md: 0.75rem
  lg: 1rem
  xl: 1.5rem
  full: 9999px
spacing:
  gutter: 0.75rem
  gutter-tablet: 1rem
  gutter-desktop: 1.5rem
  margin: 1rem
  margin-tablet: 1.5rem
  margin-desktop: 2rem
  space-xs: 0.25rem
  space-sm: 0.5rem
  space-md: 0.75rem
  space-lg: 1rem
  space-xl: 1.5rem
---

## Brand & Style

This design system delivers a calm, high-efficiency personal productivity experience tailored for mobile task and schedule management. It balances grounded discipline with psychological ease: avoiding cognitive overload and anxiety often induced by hyper-dense productivity tools.

### Brand Personality & Emotional Impact
- **Organic Precision:** Combines natural, grounding green tones with crisp, structured layouts.
- **Cognitive Clarity:** Removes ambient noise through deliberate white space, calm contrast, and intuitive visual cues.
- **Quiet Encouragement:** Celebrates task completion subtly through clean micro-interactions rather than aggressive gamification.

### Visual Aesthetic: Minimal Flat & Architectural Clean
- **Flat Surface Hierarchy:** Relies on clear surface layering (`#F5F7F3` background against pure white cards) and crisp 1px neutral borders rather than dynamic drop shadows or gradients.
- **Intentional Accents:** Deep Forest Green acts as the anchor of accomplishment and primary action; Warm Orange is strictly reserved for live, real-time states ("Now", urgent timeline markers).
- **One-Handed Mobile First:** Primary action zones, bottom navigation, and critical task controls sit naturally within thumb reach, strictly enforcing minimum 44px tap targets.

## Colors

The palette uses low-fatigue natural shades paired with high-contrast functional highlights.

### Functional Roles
- **Primary (`#24734A` / Forest Green):** Master CTAs, active selection states, completed task strikes, and system success notifications. Conveys balance, focus, and momentum.
- **Secondary (`#F28C45` / Active Orange):** High-priority focus markers, active timeline tickers ("Now"), pending task alarms, and temporal highlights. Used sparingly to avoid alarmist fatigue.
- **Tertiary (`#788278` / Muted Olive Gray):** Timestamps, structural meta text, inactive icons, and secondary metadata badges.
- **Neutral Foreground (`#24352A` / Deep Forest Slate):** Primary typographic content, headings, and key task descriptions. Softer than pure black `#000000` to eliminate visual harshness on OLED and high-resolution mobile displays.
- **Base Canvas (`#F5F7F3` / Pale Warm Sage):** Soft, soothing backdrop providing high contrast against surface containers without eye strain.
- **Surface Container (`#FFFFFF` / Pure White):** Clean task cards, bottom sheets, sticky modals, and elevated segmented pickers.
- **Border Neutral (`#E2E7DF` / Soft Neutral Border):** 1px structural outlines separating distinct list groups and cards without visual weight.

## Typography

This system uses a precise geometric sans-serif (Inter) optimized for legible data scanning, short cognitive sweeps, and precise tabular time tracking.

### Rules of Usage
- **Numerals & Timestamps:** Always apply tabular figures (`font-variant-numeric: tabular-nums`) to timeline milestones, duration counters, and calendar dates to avoid layout jitter during time-tracking updates.
- **Task Titles:** Default to `body-lg` with `fontWeight: 500`. Completed tasks switch to `fontWeight: 400`, color `#788278`, and line-through text decoration.
- **Time Indicators:** Use `label-md` in uppercase for status markers ("NOW", "DONE", "UPCOMING") with slight letter-spacing (+0.02em) to maintain clarity inside compact tags.

## Layout & Spacing

The layout is built around mobile-first thumb ergonomics, single-column content streams, and strict touch accessibility.

### Spatial Flow
- **Grid Architecture:** 4-column fluid mobile grid spanning a standard viewport with 16px screen margins (`margin`). On larger screens (tablet/foldables), the layout centers within a max-width container (480px for mobile flows, 768px for tablet split views).
- **Vertical Rhythm:** 4px baseline sub-grid. Internal task rows use 12px vertical padding (`space-md`) and 16px horizontal padding (`space-lg`) to reliably achieve the mandatory minimum 44px touch height target.
- **Thumb Zone Compliance:** Primary interactive elements (Add Task FAB, Filter Sheet Triggers, Bottom Bar) remain fixed inside the bottom 35% of the mobile screen canvas.

## Elevation & Depth

Visual hierarchy is maintained via flat tonal contrasts, structural borders, and controlled ambient diffusion rather than standard heavy drop shadows.

### Elevation Levels
- **Level 0 (Canvas Base):** `#F5F7F3`. Structural background behind all lists, scroll areas, and screen root views.
- **Level 1 (Card & Row Surfaces):** Pure White `#FFFFFF` backed by a 1px solid `#E2E7DF` border. Flat depth with no shadow to keep high list densities crisp.
- **Level 2 (Dropdowns & Popovers):** Pure White `#FFFFFF` with 1px `#E2E7DF` outline and a soft, grounded ambient shadow: `box-shadow: 0 4px 16px -2px rgba(36, 53, 42, 0.06)`.
- **Level 3 (Sticky Action Bars & Modals):** Pure White `#FFFFFF` pinned bottom sheet or floating action trigger with a warm ambient lift: `box-shadow: 0 -4px 20px 0 rgba(36, 53, 42, 0.08)`.

## Shapes

The interface features disciplined, organic curves that feel friendly without drifting into juvenile pill shapes.

### Corner Radius System
- **Compact Badges & Chips:** 8px radius (`rounded-md`).
- **Interactive Cards & Input Fields:** 12px to 14px radius (`rounded-lg`). Provides comfortable visual grouping without wasting inner corner margins.
- **Bottom Sheets & Modal Dialogs:** 20px top corner radius (`rounded-t-2xl`) for a soft, responsive sheet presentation.
- **Checkboxes & Status Rings:** Checkboxes feature a tailored 5px squircle corner radius to maintain a modern mechanical feel. Fully round circles (`50%`) are reserved strictly for time progress indicators and circular avatar markers.

## Components

### Checklist & Task Rows
- **Container:** Pure White `#FFFFFF` surface with 1px `#E2E7DF` outline, 12px corner radius, and 12px (`space-md`) vertical padding.
- **States:**
  - *Default:* `#24352A` title, `#788278` auxiliary metadata (time, category).
  - *Active / In-Progress:* Left accent border: 3px solid `#F28C45`. Status badge: `#F28C45` soft fill (10% opacity) with solid `#F28C45` text.
  - *Completed:* `#788278` strike-through text, background shifting to `#F5F7F3` (50% opacity), check icon filled with `#24734A`.

### Checkboxes
- **Metrics:** 22px × 22px square with 6px border radius, nested inside a minimum 44px tap container.
- **Default:** 1.5px solid outline `#788278` with transparent background.
- **Selected:** Solid `#24734A` background with crisp white checkmark glyph.

### Flat Action Buttons
- **Primary:** Solid `#24734A` background, white label, 12px border radius, 48px height. On press: `#1B5738`.
- **Secondary:** Surface `#FFFFFF`, 1px solid border `#E2E7DF`, label `#24352A`. On press: `#F5F7F3`.
- **Accent (Live Action):** Solid `#F28C45` background, white label. Used exclusively for "Start Focus" or "Resume" actions.

### Weekly Calendar Picker Chips
- **Geometry:** Vertical card layout (Day of week above, Date numeral below), 12px radius, minimum 48px width × 64px height.
- **Inactive:** Transparent background, `#788278` day label, `#24352A` date number.
- **Today (Unselected):** Dot indicator `#F28C45` under date.
- **Selected:** Solid `#24734A` fill, pure white text for both day and date.

### Progress Bar & Timeline Indicators
- **Track:** 6px height track, `#E2E7DF` background, 3px border radius.
- **Indicator Fill:** Solid `#24734A`. If a time limit is reached or live tracking is active, the active chunk shifts to `#F28C45`.
- **Timeline Connector:** 2px vertical stroke `#E2E7DF` linking sequential items. Active item features an animated pulsing node using `#F28C45`.

### Input Fields
- **Container:** 48px height, `#FFFFFF` background, 1px solid `#E2E7DF`, 12px radius.
- **States:** Focused state highlights border with 1.5px solid `#24734A` without adding a glowing drop shadow. Placeholder text rests in `#788278`.