# Design System: Material Structure, Notion Soul

## 1. Visual Theme & Core Philosophy
The Debt Payoff Manager design system blends the robust, predictable architecture of **Material Design 3 (MD3)** with the warm, minimalist, and deeply focused aesthetic of **Notion**. 

- **MD3 Layouts & Tokens:** We use standard M3 components (FABs, Navigation Bars, Cards) and canonical M3 tokens (`$md-surface`, `$md-primary`).
- **Notion Aesthetics:** We paint these tokens with Notion's visual philosophy—warm neutrals, high-contrast near-blacks, tightly kerned typography, whisper-thin borders, and ultra-soft layered shadows.

## 2. Color Palette & Roles (The M3 x Notion Mapping)
We retain the MD3 token naming but map them to Notion-inspired hexadecimal values.

### Notion-Inspired Base Scale
- **Notion Black:** `rgba(0,0,0,0.95)` / `#000000F2` (Near-black for micro-warmth)
- **Warm White:** `#F6F5F4` (Subtle yellow-brown undertone background)
- **Warm Dark / Gray:** `#31302E`, `#615D59`, `#A39E98`

### Material Token Mappings
- **Primary (`$md-primary`)**: `#1B6B4A` (Forest Green - the main brand color, replacing Notion Blue)
- **On Primary (`$md-on-primary`)**: `#FFFFFF`
- **Surface (`$md-surface`)**: `#FFFFFF` (Pure white for cards and main backgrounds)
- **On Surface (`$md-on-surface`)**: `#000000F2` (Notion Black)
- **Surface Container Lowest (`$md-surface-container-lowest`)**: `#FFFFFF`
- **Surface Container Low (`$md-surface-container-low`)**: `#F6F5F4` (Warm White for gentle rhythm)
- **Outline Variant (`$md-outline-variant`)**: `rgba(0,0,0,0.1)` (Notion's Whisper Border)
- **Error Container (`$md-error-container`)**: `#FFD9D9` (Warm red tint)
- **On Error Container (`$md-on-error-container`)**: `#DD0000`

## 3. Typography Rules
We retain **Roboto** as the font-family for maximum native compatibility inside Flutter, but apply Notion-styled scaling and letter-spacing (tracking).

| Type Role (M3) | Size | Weight | Line Height | Letter Spacing | Notes |
|---|---|---|---|---|---|
| Display Large | 64px | 700 (Bold) | 1.00 | -2.125px | Maximum compression, tight headlines |
| Headline Large | 40px | 700 (Bold) | 1.20 | -1.0px | Section headers |
| Title Large | 22px | 700 (Bold) | 1.27 | -0.25px | Card titles, Item titles |
| Body Large | 16px | 400 (Regular) | 1.50 | 0px | Reading text |
| Body Medium / Nav | 14px | 500 (Medium) | 1.40 | 0.1px | Secondary labels, UI text |
| Label Small / Badge | 12px | 600 (Semibold)| 1.33 | +0.125px | Pill badges, tags |

### Principles
- **Compression at scale:** Like Notion, as headings get larger, the letter-spacing becomes more negative, creating dense, billboard-like headlines.
- **Warm scaling:** Line height tightens as size increases. 1.50 for readability at body sizes, compressing down to 1.00 for display headings.

## 4. Components & Elevation

### Borders & Depth (The Notion Shadow over M3 Elevation)
- **Level 0 (Flat):** Page backgrounds, text blocks. No border, no shadow.
- **Level 1 (Card / Container):** Standard MD3 borders use the "Whisper Border": `1px solid rgba(0,0,0,0.1)`. No shadow.
- **Level 2 (Soft Hover/Focus):** Multi-layer shadow stack (max opacity 0.04) `rgba(0,0,0,0.04) 0px 4px 18px, rgba(0,0,0,0.02) 0px 0.8px 3px...` Creates natural, ambient depth without artificial harsh lines.
- **Level 3 (Modal / FAB Focus):** Deep 5-layer stack (max opacity 0.05).

### Shapes & Corner Radius
We fully adopt MD3's shape tokens for structural friendliness, breaking slightly from Notion's strict sharpness:
- **Buttons / Inputs (`$radius-sm`/`$radius-md`):** 8px - 12px
- **Cards (`$radius-lg`/`$radius-xl`):** 16px - 24px (For Hero and Debt cards)
- **Pills / Status / FAB (`$radius-full`):** 9999px (Fully rounded)

### Buttons
- **Primary / Extended FAB:** Background `$md-primary` (#1B6B4A), Text `#FFFFFF`, Shape Pill (`$radius-full`).
- **Secondary / Ghost:** Transparent background, `$md-on-surface` text, hover/pressed states use `$md-surface-container-low`.
- **Badges:** Tinted backgrounds (`$md-surface-container-low` or light primary tint), bold positive letter spacing for legibility.

## 5. Layout & Interaction Rules
- **Alternating Rhythm:** Utilize `$md-surface` (White) and `$md-surface-container-low` (Warm White `#F6F5F4`) to distinguish adjacent content blocks without using hard dividers. This creates a breathing horizontal rhythm.
- **Micro-interactions:** Focus states must have a clear 2px outline for accessibility.
- **Whitespace Philosophy:** Generous vertical padding between sections (64-120px) to allow content to breathe, a classic Notion behavior applied over M3 structures.

## 6. Implementation Notes for UX Corridors
Based on product Phase Analysis, this hybrid design system gracefully handles missing MVP corridors:
- **Edit/Delete Debt:** Avoid entirely new screens. These interactions should use Bottom Sheets (`$md-surface` background, 24px top radiuses), emerging smoothly from the bottom, blending mobile-friendly M3 component paradigms with Notion's clean interior cards.
- **Trust & Cloud Sync (Level 1/2 Upgrades):** "Upgrade to Cloud Backup" should use centralized Modal Dialogs (Level 3 Deep Shadow, 16px radius) highlighting the local-first trust philosophy with warm vector illustrations, using Notion's generous whitespace to reduce visual clutter for sensitive user decisions.
