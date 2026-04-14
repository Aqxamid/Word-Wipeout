# Design System Specification: High-End Wordplay Editorial

## 1. Overview & Creative North Star
**Creative North Star: "The Ethereal Lexicon"**
This design system moves away from the "boxy" nature of traditional word games. Instead of rigid grids and heavy outlines, we embrace an editorial layout that feels like a premium digital publication. The aesthetic is defined by **intentional breathability**, **tonal layering**, and **fluid geometry**. By utilizing `ROUND_FULL` for nearly all containers, we create an organic, approachable environment that reduces cognitive load, allowing the typography (the "words") to become the visual hero.

The system breaks the "template" look through:
*   **Asymmetric Breathing Room:** Large, intentional gaps in margins to guide the eye.
*   **Floating Composition:** Elements appear to hover in a calibrated light space.
*   **Tactile Softness:** Every interaction feels cushioned and premium.

---

## 2. Colors: Tonal Architecture
We reject the use of harsh separators. This system operates on a "No-Line" philosophy.

### Core Palette
*   **Primary (`#0058be`):** Our "Intellectual Blue." Used for high-priority actions and success states. 
*   **Surface / Background (`#f7f9fb`):** A sophisticated, cool-tinted white that reduces eye strain compared to pure `#FFFFFF`.
*   **Tertiary (`#924700`):** An "Ochre Accent" used sparingly for high-value game moments (e.g., Rare words, streaks).

### The "No-Line" Rule
**Strict Mandate:** Prohibit 1px solid borders for sectioning. 
Boundaries must be defined solely through background color shifts. To separate a game board from a menu, place a `surface-container-low` object onto a `surface` background. The contrast in tone provides all the structure the eye needs without the "visual noise" of a line.

### Surface Hierarchy & Nesting
Treat the UI as a series of stacked, fine-milled paper sheets.
*   **Level 0 (Base):** `surface` (`#f7f9fb`) — The infinite canvas.
*   **Level 1 (Sections):** `surface-container-low` (`#f2f4f6`) — Subtle grouping.
*   **Level 2 (Interactive Cards):** `surface-container-lowest` (`#ffffff`) — Pure white to "pop" against the tinted background.
*   **Level 3 (Floating Overlays):** `surface-bright` with 80% opacity and Backdrop Blur.

### The "Glass & Gradient" Rule
To inject "soul" into the minimalist aesthetic:
*   **CTAs:** Use a subtle linear gradient from `primary` (`#0058be`) to `primary-container` (`#2170e4`) at a 135° angle.
*   **Floating HUDs:** Use glassmorphism (Backdrop blur: 12px) on elements using `surface_container_lowest` at 70% opacity to maintain an airy, modern feel.

---

## 3. Typography: Editorial Authority
We use **Plus Jakarta Sans** for its geometric clarity and contemporary "ink traps" which feel premium at any scale.

| Level | Token | Size | Weight | Intent |
| :--- | :--- | :--- | :--- | :--- |
| **Display** | `display-lg` | 3.5rem | 800 | Game-over scores / Hero numbers. |
| **Headline**| `headline-md`| 1.75rem| 700 | Section headers (On-Surface: `#191c1e`). |
| **Title**   | `title-md`   | 1.125rem| 600 | Card titles / Word definitions. |
| **Body**    | `body-lg`    | 1rem    | 400 | Instructional text (On-Surface-Variant: `#424754`). |
| **Label**   | `label-md`   | 0.75rem | 700 | All-caps metadata / Micro-copy. |

**The Typography Philosophy:** Use high-contrast scaling. A `display-lg` score should sit near a `body-sm` label to create a sophisticated, "magazine-style" hierarchy that feels intentional rather than default.

---

## 4. Elevation & Depth: Tonal Layering
Traditional drop shadows are too "heavy" for this system. We use **Ambient Depth**.

*   **The Layering Principle:** Place a `surface-container-lowest` (#FFFFFF) card on a `surface-container` (#eceef0) background. This creates a natural "lift" through color theory alone.
*   **Ambient Shadows:** For floating elements (like a letter tile being dragged), use:
    *   *Shadow:* `0px 12px 32px`
    *   *Color:* `on-surface` (`#191c1e`) at **4% opacity**. It should feel like a soft glow of light, not a shadow.
*   **The "Ghost Border" Fallback:** If a letter tile requires a container on a white background, use the `outline-variant` token at **15% opacity**. Never use a 100% opaque border.

---

## 5. Components

### Buttons & Interaction
*   **Primary Button:** `ROUND_FULL`. Gradient fill (`primary` to `primary-container`). White text. No border. High-diffuse shadow on hover.
*   **Secondary/Soft Button:** `ROUND_FULL`. Fill: `secondary-fixed-dim` (`#c4c7ca`). Text: `on-secondary-fixed`.
*   **Game Tiles:** `ROUND_FULL` (Full circles). Fill: `surface-container-lowest`. Typography: `headline-sm`. Ensure a subtle `primary` inner-shadow (2px) when a tile is selected to imply it has been "pressed" into the surface.

### Input Fields
*   **Styling:** Forgo the box. Use a `surface-container-high` rounded pill.
*   **State:** On focus, the pill doesn't gain a border; instead, it transitions to `surface-container-lowest` with a soft ambient shadow.

### Cards & Lists
*   **The Divider Prohibition:** Lists must never use horizontal lines. Separate list items using `12px` of vertical white space or by alternating background tints between `surface` and `surface-container-low`.

### Word Trays
*   **Composition:** Floating at the bottom of the viewport using Glassmorphism. A blurred `surface-container-lowest` (80% alpha) with `9999px` corner radius.

---

## 6. Do's and Don'ts

### Do
*   **Do** use extreme whitespace. If a screen feels "empty," it’s likely working.
*   **Do** use `ROUND_FULL` for everything from the smallest chip to the largest modal.
*   **Do** rely on `Plus Jakarta Sans` weight variants (Bold vs Regular) rather than color to show hierarchy.

### Don't
*   **Don't** use pure black (#000000). Use `on-surface` (#191c1e) for all deep tones.
*   **Don't** use 1px solid borders. They clutter the editorial "Ethereal" feel.
*   **Don't** use standard Material Design "Drop Shadows." Stick to Tonal Layering or 4% opacity Ambient Shadows.
*   **Don't** cram elements. If a word game board is tight, reduce the tile size rather than the margins.