# Dark Mode Engineering

Dark mode isn't "invert the colors". It's a parallel token universe that has to satisfy the same contrast, hierarchy, and brand expression as light mode, with different physical constraints (emitted light, eye fatigue, OLED power consumption).

I wrote this file after the v1.2 launch where we shipped a primary CTA that failed AA contrast in dark mode for two weeks before anyone noticed. The bug was that I'd used `--gray-900` for the button background instead of `--bg-primary`. Primitives don't swap. The button stayed black on a black surface. Beautiful, completely invisible.

So: this file exists. Read it when fixing, auditing, or implementing dark mode.

---

## 1. The MK-DS dark-mode model

MK-DS uses a **single-toggle** model: adding `dark` to the `<html>` class swaps all *semantic* tokens. *Primitive* tokens (e.g. `--gray-700`) don't move — they're the building blocks.

```css
:root {
  /* Light defaults */
  --bg-primary:     #FFFFFF;
  --bg-secondary:   #F9FAFB;
  --bg-tertiary:    #F2F4F7;
  --text-primary:   #101828;
  --text-secondary: #667085;
  --border-primary: #EAECF0;
}

html.dark {
  --bg-primary:     #0C111D;
  --bg-secondary:   #161B26;
  --bg-tertiary:    #1F242F;
  --text-primary:   #F5F5F6;
  --text-secondary: #94969C;
  --border-primary: #333741;
}
```

**Rule**: if your component code uses `var(--bg-primary)`, dark mode is free. If it uses `var(--gray-50)` (primitive), you must add a `html.dark .your-component { background: var(--gray-900); }` override.

---

## 2. Token genealogy — what swaps, what doesn't

| Token category | Light → Dark behavior |
|----------------|-----------------------|
| **Semantic (`--bg-*`, `--text-*`, `--border-*`)** | Swap automatically |
| **Brand (`--brand`, `--brand-hover`, `--brand-light`)** | Stay the same — brand identity is mode-independent |
| **State colors (`--success-*`, `--error-*`, `--warning-*`)** | Mostly stay; use lighter shades for backgrounds in dark mode |
| **Gray primitives (`--gray-*`)** | Don't swap — they're raw values |
| **Spacing / sizing / radii** | Mode-independent |
| **Shadows** | Mode-independent but visually subtler in dark (because backgrounds are darker — that's fine) |

---

## 3. The three failure patterns

### Pattern A: primitive used where semantic exists

```css
/* Wrong */
.my-card { background: var(--gray-50); }
/* In dark mode: gray-50 stays the same → tiny contrast against dark surface */

/* Right */
.my-card { background: var(--bg-secondary); }
/* Auto-swaps to #161B26 in dark mode */
```

### Pattern B: hardcoded color

```css
/* Wrong */
.my-banner { background: #F2F4F7; color: #101828; }

/* Right */
.my-banner {
  background: var(--bg-tertiary);
  color: var(--text-primary);
}
```

### Pattern C: brand-tinted background that doesn't translate

```css
/* Wrong — works in light, looks blown out in dark */
.my-highlight { background: rgba(31, 18, 222, 0.1); }

/* Right — use the variable that scales correctly */
.my-highlight { background: var(--brand-light); }
```

`--brand-light` is `rgba(31, 18, 222, 0.1)` in light and a slightly higher alpha (e.g., `rgba(31, 18, 222, 0.2)`) in dark to compensate for the darker background. The DS handles this internally.

---

## 4. Auditing existing UI for dark-mode safety

Run this mental audit per file:

1. **Grep for hex codes** (`#[0-9a-f]{3,6}`). Every hit is a violation unless it's inside a `--*-*` declaration in `:root` or `html.dark`.
2. **Grep for `--gray-*`, `--blue-*`, etc. (primitives)** outside of token files. Each one is suspicious — check if a semantic exists.
3. **Toggle `html.dark` in the browser** (or mentally) and verify:
   - Backgrounds are dark (`#0C111D` family), not light
   - Text is light (`#F5F5F6` family), not dark
   - Borders are visible but subtle (`#333741`)
   - Brand color is recognizable but not glaring
   - All state colors (success/error/warning) remain semantically clear

A useful grep:

```bash
# Find primitive grays in component code (should mostly be in :root only)
grep -rn 'var(--gray-' . | grep -v ':root' | grep -v 'html.dark'
```

---

## 5. Dark-mode color palette mathematics

For new contexts where the DS doesn't have a token (rare), follow these rules:

| Need | Light value | Dark value | Why |
|------|------------|-----------|-----|
| Background of "elevated" surface | white / #FFFFFF | slightly lighter than `--bg-primary` (e.g. `#161B26` for first elevation) | Elevation = lightness in dark mode (inverted intuition) |
| Subtle border / separator | `--gray-200` (#EAECF0) | `--gray-700` (#333741) | Just enough to define the edge |
| Disabled text | `--gray-400` (#98A2B3) | `--gray-500` (#667085) | Lower contrast but still legible |
| Code blocks | `--gray-50` background | `--gray-800` background | Differentiate from page surface |
| Brand-tinted alert | `--brand-light` (10% alpha) | `--brand-light` (20% alpha) | Compensate for darker base |

**Elevation is light, not dark, in dark mode.** Counter-intuitive but right: cards on dark backgrounds appear "above" by being a touch lighter, not darker.

---

## 6. Contrast verification

Required minimums in both modes:

| Pairing | Min ratio |
|---------|----------|
| Body text on background | 4.5:1 |
| Large text (≥18px or ≥14px bold) | 3:1 |
| UI controls (button borders, icons) | 3:1 |
| Focus ring against background | 3:1 |
| Brand on backgrounds (call-to-action) | 4.5:1 (treat as body text) |

Verified pairings (from `tokens.json`):

| Token pair | Light ratio | Dark ratio | Pass |
|-----------|------------|-----------|------|
| `--text-primary` on `--bg-primary` | 18.2:1 | 17.4:1 | ✓ AAA both |
| `--text-secondary` on `--bg-primary` | 4.7:1 | 5.6:1 | ✓ AA body both |
| `--text-primary` on `--bg-secondary` | 17.5:1 | 16.1:1 | ✓ AAA both |
| `--brand` on `--bg-primary` (light) | 9.2:1 | n/a | ✓ AAA |
| `--brand` on `--bg-primary` (dark) | n/a | 4.4:1 | ✗ — use `--brand` ONLY on light bg; for dark, use a lighter brand variant or invert to bg=brand text=white |

---

## 7. The `--brand` on dark backgrounds problem

`--brand` (#1F12DE) is a deep indigo. On dark backgrounds, contrast drops below 4.5:1.

**Solution 1: invert** — for primary CTAs in dark mode, use `background: var(--brand)` with white text (still passes), or fall back to a lighter brand variant.

**Solution 2: use brand sparingly in dark mode** — reserve `--brand` for accents (icons, focus rings, badges) where 3:1 suffices, and use white backgrounds for primary CTAs even in dark mode.

The DS handles this via the button variants:
- `mk-btn--primary` in light mode: `bg: --brand; color: white`
- `mk-btn--primary` in dark mode: same — passes because text is white on brand bg

Verify with: `get_component(name: "button", format: "html")` then `get_guidelines(topic: "dark_mode")`.

---

## 8. Images and media in dark mode

Three strategies:

1. **Logo / brand assets**: provide light + dark variants. Use `<picture>`:
   ```html
   <picture>
     <source srcset="logo-dark.svg" media="(prefers-color-scheme: dark)">
     <img src="logo-light.svg" alt="Brand">
   </picture>
   ```

2. **Illustrations**: dim slightly with CSS filter in dark mode (subtle):
   ```css
   html.dark .mk-illustration { filter: brightness(0.85) contrast(1.05); }
   ```

3. **Photos / user-uploaded images**: leave alone. Photos are mode-independent.

---

## 9. System preference vs explicit toggle

MK-DS supports both, but they're different:

```js
// Detect system preference
const systemDark = window.matchMedia('(prefers-color-scheme: dark)').matches;

// Apply
if (userPreference === 'dark' || (userPreference === 'system' && systemDark)) {
  document.documentElement.classList.add('dark');
} else {
  document.documentElement.classList.remove('dark');
}
```

Default to `system`. Save user override (light / dark / system) to `localStorage`. Apply before first render to avoid flash.

---

## 10. The dark-mode checklist

Before declaring dark-mode "done":

- [ ] Every color reference is a semantic token (or has an `html.dark` override)
- [ ] Toggling `html.dark` in the browser inspector swaps the entire UI without missed elements
- [ ] All text passes 4.5:1 contrast in dark mode
- [ ] Brand CTAs remain recognizable
- [ ] No "blown out" tints (alpha-blended backgrounds that look too bright in dark)
- [ ] Borders are visible but not harsh
- [ ] Images/illustrations look right (logos swap, illustrations dim if needed)
- [ ] User's system preference is the default
- [ ] User override persists across reloads
- [ ] No flash of incorrect theme on initial load

A common test: open the page in dark mode in an OLED display under low ambient light. If it feels glary, your contrasts are too high or your brightnesses are off.

---

## 11. Common dark-mode bugs and fixes

| Bug | Cause | Fix |
|-----|-------|-----|
| White flash on page load | Theme applied after first paint | Inline script in `<head>` that adds `dark` class before render |
| Some elements stay light | Hardcoded hex or primitive token | Replace with semantic token |
| Brand looks dull | Brand color was lightened too aggressively | Keep `--brand` constant; rely on inversion (white text on brand bg) |
| Borders disappear | Used `--gray-200` (light-only) | Use `--border-primary` semantic |
| Toast over dark backdrop has weird tint | Toast background uses primitive | Use semantic `--bg-primary` + slight elevation |
| Modal backdrop too dark | Hardcoded `rgba(0,0,0,0.5)` | Use DS modal backdrop variable |
| Form errors invisible | `--error-50` background on dark | Add `html.dark` override using darker `--error-*` shade |
