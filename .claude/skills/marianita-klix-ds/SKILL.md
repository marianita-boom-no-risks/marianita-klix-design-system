---
name: marianita-klix-ds
description: Use the Marianita Klix Design System to build UI. Triggers on requests to "build/design/create a page/screen/component" when the project uses this design system, or when the user mentions Marianita Klix, "klix-ds", or asks for components with the `mk-` CSS prefix. Loads the MCP-driven workflow (tokens, components, page templates) and enforces the design system's rules (no hardcoded values, `mk-` prefix, dark mode, a11y).
---

# Marianita Klix Design System — Skill

You are building UI with the **Marianita Klix Design System** (MK-DS). This skill orchestrates the companion MCP server (`marianita-klix-ds`) so every output uses the registered components, design tokens, and conventions — never invented values.

## When this skill activates

- The user asks to **build, design, create, or scaffold** a UI page, screen, component, dashboard, settings page, login, etc., in a project where MK-DS is set up.
- The user mentions the design system by name (Marianita Klix, MK-DS, klix design system).
- The user asks about components with the `mk-` CSS prefix.
- The user asks for tokens, dark-mode, a11y, or theming guidance for this DS.

## Hard rules (non-negotiable)

1. **NEVER hardcode** colors, spacing, font-sizes, radii, or shadows. Always reference CSS custom properties (e.g. `var(--brand)`, `var(--space-4)`).
2. **ALWAYS** prefix component classes with `mk-` (e.g. `mk-btn`, `mk-card`, `mk-input`).
3. **ALWAYS** use semantic HTML (`<button>`, `<nav>`, `<main>`, `<section>`) — never `<div onClick>`.
4. **ALWAYS** support dark mode via `html.dark` class. The DS swaps semantic tokens automatically.
5. **ALWAYS** ensure 4.5:1 text contrast and visible focus rings (`--brand`, 4px ring).
6. **NEVER** add a build step. The DS is static HTML + Tailwind CDN + Inter from Google Fonts.

## Workflow — required order

Follow this sequence when starting any UI task. **Do not skip steps.**

### Step 1 — Confirm tokens are loaded

If the project has no CSS setup yet, call:

```
get_css_setup
```

Paste the returned CSS into the project's main stylesheet (or a `<style>` block in the HTML). This loads tokens, dark-mode overrides, Inter font, and base styles.

### Step 2 — Find the right components

Before writing any component code, call one of:

```
list_components               # See all 61 components grouped by category
list_components(category: "Form Controls")
search(query: "<keyword>")    # Fuzzy search across components, tokens, guidelines
```

Pick the components from the returned list. **Do not invent components** — if a feature seems to need one that isn't listed, surface that gap to the user instead of fabricating CSS classes.

### Step 3 — Pull the component code

For each component you need, call:

```
get_component(name: "<slug>", format: "html" | "react" | "vue" | "svelte")
```

Use the format matching the project's stack. Default is `html`. The response includes props, variants, sizes, a11y notes, and ready-to-paste code.

### Step 4 — For full pages, start with a template

For dashboard/settings/login/profile/etc., call:

```
get_page_template(template: "<slug>")
```

The template lists the components it composes. Then call `get_component` for each one.

### Step 5 — Cross-check guidelines on contested decisions

When a question of spacing, typography, motion, or a11y comes up, call:

```
get_guidelines(topic: "spacing" | "typography" | "color_usage" | "dark_mode" | "accessibility" | "responsive" | "motion")
```

These are the source of truth. Don't guess.

### Step 6 — Output tokens in the project's format

If the project uses SCSS, Tailwind, or a JSON token pipeline, call:

```
get_tokens(format: "css" | "scss" | "json" | "tailwind", category: "<optional>")
```

## Design token cheat sheet

Spacing — `--space-1` (4px) → `--space-8` (32px). Half-steps exist: `--space-1h` (6px), `--space-2h` (10px).

Type sizes — `--text-xs` (10px) → `--text-2xl` (24px). Line heights mirror with `--leading-*`.

Radii — `--radius-sm` (4px), `--radius-md` (8px), `--radius-lg` (10px), `--radius-xl` (14px), `--radius-full` (9999px).

Shadows — `--shadow-xs` → `--shadow-2xl`.

Brand — `--brand` (#1F12DE), `--brand-hover`, `--brand-light`.

Semantic — `--bg-primary`, `--bg-secondary`, `--bg-tertiary`, `--text-primary`, `--text-secondary`, `--border-primary`. These auto-swap in dark mode.

## Component sizing — pick the right size

| Component | SM | MD (default) | LG |
|-----------|------|------|------|
| Button height | 32px | 40px | 48px |
| Input height | — | 40px | 48px |
| Avatar | 24px xs | 40px | 64px xl |
| Icon | 16px | 20px | 24px |

## Component catalogue (61, by category)

- **Form Controls (12):** Button, Input, Checkbox, Radio, Toggle, Select, File Upload, Slider, Date Picker, Color Picker, OTP Input, Tag Input
- **Data Display (14):** Badge, Card, Table, Data Table, Avatar, Rating, Stat Card, Timeline, Activity Feed, Pills, Notification Badge, Date/Time, Metadata Grid, Status Indicator
- **Feedback (7):** Modal, Toast, Progress Bar, Skeleton, Empty State, Alert Banner, Snackbar
- **Navigation (9):** Tabs, Breadcrumbs, Pagination, Sidebar Nav, Tree View, Stepper, Mega Menu, Bottom Nav, Segmented Control
- **Layout (8):** Section Header, CTA Banner, Divider, Drawer, Kanban Board, Toolbar, Image Gallery, Audio Player
- **Overlay (5):** Tooltip, Dropdown, Popover, Command Palette, Accordion
- **Content (6):** Comments, Notifications, Calendar, Pricing Card, Testimonial, FAB

## Verification before completion

Before reporting work as done, mentally check:

- [ ] All colors/spacing/sizes go through CSS variables — `grep` your output for raw hex codes or `px` values that aren't in component code.
- [ ] All component classes start with `mk-`.
- [ ] Dark mode works: switch `html.dark` and visually inspect (or reason through which tokens swap).
- [ ] Interactive elements are real `<button>`/`<a>`/`<input>` and reachable by keyboard.
- [ ] Icon-only buttons have `aria-label`.
- [ ] No CDN-Tailwind utilities reintroduced raw colors (e.g. `bg-blue-500` instead of `style="background:var(--brand)"`).

## Anti-patterns — do not do

- Don't call `get_component` for a component you haven't first confirmed via `list_components` or `search`.
- Don't translate Figma fills to raw hex — map them to the brand/semantic tokens.
- Don't introduce a new color or spacing value. If something looks missing, ask the user; don't fabricate.
- Don't ship `prefers-reduced-motion`-violating animations. Wrap motion in the media query when in doubt.

## Reference docs (open these if the MCP is unavailable)

- `CLAUDE.md` (project root) — full rules and token reference
- `mcp-guide.html` — installation walkthrough
- `index.html` — interactive documentation of all 61 components
- `figma-handoff.html` — Figma → code conversion guide
- `a11y.html` — accessibility tooling and ARIA reference
