# Figma → MK-DS Workflow

Converting a Figma design into MK-DS code without losing fidelity *and* without leaking raw hex/px into the codebase. This is the workflow Dani (designer) and I landed on after the Q1 audit found 14 colors that had snuck into the codebase as "close enough" matches to Figma fills. They weren't.

> Read this when someone shares a Figma URL, attaches a screenshot, or asks to "implement this design".

---

## 1. The reflex to suppress

Figma exports look like:

```css
background: #1F12DE;
padding: 24px;
border-radius: 10px;
gap: 16px;
font: 600 14px/20px Inter;
```

Pasting that directly is the **#1 cause of design-system drift**. Every value above has a token. Your job is to translate, not transcribe.

---

## 2. The 5-step workflow

### Step 1 — Read the design via MCP

If the Figma MCP is available, call:

```
get_design_context(fileKey, nodeId)
```

This returns:
- React + Tailwind code (a reference, NOT final)
- A screenshot
- Code Connect mappings (if the design system is registered)
- Design tokens as CSS variables (if Tokens Studio is wired)

If only a screenshot is available, call:

```
get_screenshot(fileKey, nodeId)
```

…and read it visually.

### Step 2 — Identify the components

Before writing any code, list the MK-DS components visible in the design. For each:

1. Match by **shape and intent**, not pixel-by-pixel similarity.
2. Use the §6 intent matrix from `SKILL.md` if unsure.
3. Call `search(query: "<concept>")` if the match isn't obvious.

Output a **component manifest** before generating code:

> Identified components: `sidebar-nav`, `section-header`, `stat-card` (×4), `data-table`, `button` (primary), `badge` (success / warning).

### Step 3 — Map every Figma property to a token

Use this translation table. If a value falls between tokens, **round to the nearest token**, don't introduce a new value.

#### Spacing

| Figma `itemSpacing` / `padding` | MK-DS token |
|---------------------------------|-------------|
| 4 | `--space-1` |
| 6 | `--space-1h` |
| 8 | `--space-2` |
| 10 | `--space-2h` |
| 12 | `--space-3` |
| 14 | round to `--space-3` (12) or `--space-4` (16) — flag to user |
| 16 | `--space-4` |
| 18 | round to `--space-4` (16) — flag to user |
| 20 | `--space-5` |
| 24 | `--space-6` |
| 28 | round to `--space-6` (24) or `--space-8` (32) — flag to user |
| 32 | `--space-8` |
| 40+ | combine tokens (e.g., 40 = `--space-8` + `--space-2`) OR flag |

#### Radii

| Figma `cornerRadius` | MK-DS token |
|---------------------|-------------|
| 4 | `--radius-sm` |
| 8 | `--radius-md` |
| 10 | `--radius-lg` |
| 14 | `--radius-xl` |
| 9999 / 999 / fully rounded | `--radius-full` |
| Other | round to nearest, flag |

#### Colors

| Figma fill (hex) | MK-DS token | Notes |
|------------------|-------------|-------|
| `#1F12DE` | `var(--brand)` | Primary action |
| `#1a0fbc` | `var(--brand-hover)` | Hover state |
| `rgba(31, 18, 222, 0.1)` | `var(--brand-light)` | Brand tint |
| `#FFFFFF` | `var(--bg-primary)` | (auto-swaps in dark mode!) |
| `#F9FAFB` | `var(--bg-secondary)` | Auto-swaps |
| `#F2F4F7` | `var(--bg-tertiary)` | Auto-swaps |
| `#101828` | `var(--text-primary)` | Auto-swaps |
| `#667085` | `var(--text-secondary)` | Auto-swaps |
| `#EAECF0` | `var(--border-primary)` | Auto-swaps |
| Greens (#039855, #ECFDF3, …) | `var(--success-*)` scale |
| Reds (#D92D20, #FEE4E2, …) | `var(--error-*)` scale |
| Ambers (#DC6803, #FEF0C7, …) | `var(--warning-*)` scale |
| Blues (#1570EF, #EFF8FF, …) | `var(--blue-*)` scale |

For grays not in the semantic list, find the closest `--gray-*` primitive, but **prefer semantic if available**.

##### Color matching algorithm

When a Figma color doesn't match any token exactly:

1. Convert both to OKLCH for perceptual distance
2. If ΔE (perceptual distance) < 2 → use the token, you're within noise
3. If ΔE 2–5 → use the closest token, **flag to user** ("Figma used #X, I used `var(--token-Y)` which is perceptually within 3 ΔE")
4. If ΔE > 5 → stop and ask. The color is intentionally distinct.

#### Typography

Figma "Inter Semibold 14 / 20":

```css
/* Wrong (transcription) */
font-family: 'Inter';
font-weight: 600;
font-size: 14px;
line-height: 20px;

/* Right (tokenized) */
font-family: var(--font-family);
font-weight: var(--font-semibold);
font-size: var(--text-base);
line-height: var(--leading-base);
```

Use the pairings from `SKILL.md` §5 (Page H1, Card H3, Body, Small, Caption).

#### Shadows

Figma "Drop shadow: x=0, y=4, blur=8, spread=-2, #10182833 (color #101828 at 20%)":

→ `var(--shadow-md)`

Don't transcribe the raw shadow. Match by **visual weight intent** (subtle / floating / modal / hero).

---

## 3. Auto Layout → Flexbox/Grid

Figma's Auto Layout maps deterministically:

| Figma | CSS |
|-------|-----|
| Auto Layout HORIZONTAL | `display: flex; flex-direction: row;` |
| Auto Layout VERTICAL | `display: flex; flex-direction: column;` |
| `itemSpacing: N` | `gap: var(--space-N);` (after tokenizing N) |
| `padding: T R B L` | `padding: var(--space-T) var(--space-R) var(--space-B) var(--space-L);` |
| `alignItems: CENTER` | `align-items: center;` |
| `alignItems: SPACE_BETWEEN` | `justify-content: space-between;` |
| FILL sizing | `flex: 1;` or `width: 100%;` |
| HUG sizing | `width: fit-content;` (or omit) |
| FIXED sizing | `width: <px>;` — but check if this is intentional |

Grids in Figma:
- 12-column grid → `display: grid; grid-template-columns: repeat(12, 1fr);`
- Use `--space-*` tokens for the `gap`

---

## 4. Component identification — visual heuristics

| Visual pattern | MK-DS component |
|---------------|-----------------|
| Pill with text + colored bg | `badge` (small) or `pills` |
| Rounded rectangle, prominent text + value | `stat-card` |
| Vertical list of items with icon + label | `sidebar-nav` or `tree-view` |
| Horizontal row of equally-spaced items at top | `tabs` or `breadcrumbs` |
| Numbered/dotted horizontal progress | `stepper` |
| Centered overlay with backdrop | `modal` |
| Side-anchored panel sliding in | `drawer` |
| Small floating tooltip pointing to an element | `tooltip` |
| Larger floating popup with content/actions | `popover` |
| Vertical card with price + features list | `pricing-card` |
| Avatar circle + bold name + status badge | `avatar` (composition) |

---

## 5. Handling cases the design doesn't cover

Figma designs often skip:

| Missing | Default behavior |
|---------|-----------------|
| Hover states | Use the component's documented hover (don't invent) |
| Focus states | Use MK-DS focus ring (4px `--brand`) |
| Loading states | Use `mk-btn--loading`, `skeleton`, etc. |
| Empty states | Use `empty-state` component (always) |
| Error states | Use `alert-banner`, `mk-input--error`, etc. |
| Disabled states | Use the component's documented disabled |
| Mobile breakpoint | Build mobile-first or use container queries (see `references/recipes.md`) |
| Dark mode | Auto via semantic tokens (verify mentally) |
| Reduced motion | Wrap any animation accordingly |

Surface these in the output: *"The design didn't specify a loading state; I used `mk-btn--loading` with the standard spinner."*

---

## 6. Code Connect — when it exists

If `get_design_context` returns Code Connect mappings:

```json
{
  "componentName": "Button",
  "source": "./components/Button.tsx",
  "props": { "variant": "primary", "size": "md", "label": "Submit" }
}
```

…use the mapping **as-is**. Don't re-derive the component from the screenshot. Code Connect is the ground truth when present.

If the user's project doesn't have Code Connect mappings yet, suggest adding one for repeatedly-used components:

```
add_code_connect_map(nodeId, fileKey, source, componentName, label)
```

---

## 7. Output format for Figma tasks

When delivering Figma → code work, always include:

1. **Component manifest** (which MK-DS slugs you identified)
2. **Token translation table** for non-obvious mappings (one line per Figma value → token)
3. **Gaps surfaced** (states not in the design, colors that didn't match, sizes that rounded)
4. **The code** (in the project's framework format)
5. **Dark-mode reasoning**: which tokens auto-swap, what to verify visually

Example output preamble:

> **Manifest:** `sidebar-nav`, `section-header`, `stat-card` (×4), `data-table` with `badge`, `button` (primary)
>
> **Token translations:**
> - Figma `#FAFAFA` background → `var(--bg-secondary)` (semantic, dark-mode safe)
> - Figma `20px` padding → `var(--space-5)` (exact match)
> - Figma `14/20 Inter Medium` → `var(--text-base) / var(--leading-base) var(--font-family)` with `var(--font-medium)`
>
> **Gaps:** Design shows no loading state for the data table; I added the standard `skeleton` for rows during fetch.

---

## 8. Anti-patterns specific to Figma work

| Anti-pattern | Why bad | Fix |
|--------------|---------|-----|
| Copying hex codes from Figma into CSS | Bypasses tokens, breaks dark mode, drifts over time | Translate via §2 table |
| Matching Figma 1:1 even when it conflicts with DS rules | Inconsistency across the product | Push back: "Figma shows X, but DS guideline is Y. Want me to flag this to design?" |
| Implementing only the visible state | Missing hover/focus/loading/empty | See §5 |
| Pixel-perfect at the cost of responsiveness | Breaks below 768px | Always test mobile mentally |
| Skipping Code Connect when it exists | Re-deriving what's already mapped | Use `get_design_context` first |
| Inventing components to match a unique Figma piece | DS drift | Surface gap to user; don't fabricate |
