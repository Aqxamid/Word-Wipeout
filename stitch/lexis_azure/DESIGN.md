# Design System Specification: The Tactile Ethereal

## 1. Overview & Creative North Star
The Creative North Star for this design system is **"The Digital Curator."** 

We are moving away from the "boxy" and rigid structures of traditional word games. Instead, we are building an environment that feels like a premium, physical object—think of a high-end glass architectural model or a boutique editorial magazine. The goal is to create a "Zen-like" focus where the UI disappears, leaving only the player and the puzzle. We achieve this through **Intentional Asymmetry**, where layout elements are slightly offset to create a sense of motion, and **Tonal Depth**, which replaces harsh structural lines with soft shifts in light.

---

## 2. Colors & Surface Philosophy
This system utilizes a sophisticated palette that prioritizes depth over boundaries. 

### The "No-Line" Rule
**Explicit Instruction:** Designers are prohibited from using 1px solid borders for sectioning. Structural definition must be achieved solely through background color shifts or subtle tonal transitions. For example, a `surface-container-low` component should sit on a `surface` background to define its shape.

### Surface Hierarchy & Nesting
Treat the UI as a series of physical layers. Use the following tiers to define importance:
- **Surface (0b1326):** The base canvas.
- **Surface-Container-Lowest (060e20):** Used for recessed areas, like the "tray" under a game keyboard.
- **Surface-Container (171f33):** The primary interactive layer.
- **Surface-Container-Highest (2d3449):** For elevated modals or active game tiles.

### The "Glass & Gradient" Rule
To elevate the experience, use **Glassmorphism** for floating elements (e.g., the Pause menu or tooltips). Apply a semi-transparent `surface-variant` with a `backdrop-blur` of 12px–20px. 
**Signature Textures:** Main CTAs must use a subtle linear gradient from `primary` (#a4c9ff) to `primary_container` (#60a5fa) at a 135° angle. This adds "visual soul" and prevents the buttons from looking like flat, templated assets.

---

## 3. Typography: Editorial Clarity
We use **Plus Jakarta Sans** for its geometric yet approachable character.

- **Display (L/M/S):** Used for score celebrations and game-over states. These should feel authoritative and cinematic.
- **Headline (L/M/S):** Used for menu titles. Apply a negative letter-spacing of `-0.02em` to create a "tight" editorial look.
- **Title (L/M/S):** The primary weight for game tiles. Tile letters should be `title-lg` or `headline-sm` to ensure maximum legibility during fast-paced play.
- **Body & Labels:** Reserved for instructions and meta-data.

**Hierarchy Note:** Always pair a `display-sm` headline with `label-md` uppercase sub-text to create high-contrast, professional-grade typography scaling.

---

## 4. Elevation & Depth
Depth in this system is organic, not artificial.

- **The Layering Principle:** Stack `surface-container` tiers. Place a `surface-container-lowest` card inside a `surface-container-high` section to create a "carved out" effect.
- **Ambient Shadows:** For "floating" elements like active tiles being dragged, use an extra-diffused shadow. 
  - *Specs:* `Y: 20px, Blur: 40px, Spread: -5px`.
  - *Color:* Use the `on-surface` color at 6% opacity. Never use pure black.
- **The "Ghost Border" Fallback:** If a border is essential for accessibility, use the `outline_variant` token at **15% opacity**. High-contrast, 100% opaque borders are strictly forbidden.

---

## 5. Components

### The Game Grid (Tiles)
- **Geometry:** Use the `md` (1.5rem) corner radius. 
- **States:** 
  - *Empty:* `surface-container-lowest` with a "Ghost Border."
  - *Filled:* `surface-container-highest` with `on-surface` text.
  - *Correct:* `tertiary` (#fabd34) with `on-tertiary` text.
- **Interaction:** On hover, tiles should scale to 1.05x with a subtle `surface-bright` glow.

### Interactive Keyboard
- **Base:** Each key uses `surface-container-low`.
- **Active State:** On press, the key shifts to `primary` with a 2px vertical "press" animation (mimicking a mechanical switch).
- **Spacing:** Forbid dividers; use `0.5rem` of negative space to define key boundaries.

### Large Mode Cards
- **Layout:** Use intentional asymmetry. Place the title in the top-left (`headline-md`) and the play count in the bottom-right (`label-sm`).
- **Visuals:** Use a background "glow" using a blurred `primary_container` circle (opacity 10%) behind the card content to provide depth.

### Action Buttons
- **Primary:** Gradient-filled (Primary to Primary-Container). Corner radius: `full`.
- **Tertiary:** No background. Use `title-sm` with an underline that only appears on hover.

---

## 6. Do’s and Don’ts

### Do
- **Do** use `surface-dim` for inactive or "locked" game modes to create a clear visual hierarchy of progress.
- **Do** utilize `plusJakartaSans` at various weights (Bold for titles, Medium for body) to create a sense of importance without changing color.
- **Do** allow elements to overlap (e.g., a game tile slightly overlapping a card edge) to break the "grid-lock" feel.

### Don’t
- **Don't** use 1px dividers. Use a `1.5rem` vertical spacing gap or a tonal shift instead.
- **Don't** use sharp corners. Every interactive element must have at least an `sm` (0.5rem) radius to maintain the "soft minimalism" aesthetic.
- **Don't** use pure black for shadows. Always tint the shadow with the background navy (`on-surface` at low opacity).
- **Don't** clutter the screen. If a piece of information isn't vital to the current game state, hide it behind a "Glass" drawer.