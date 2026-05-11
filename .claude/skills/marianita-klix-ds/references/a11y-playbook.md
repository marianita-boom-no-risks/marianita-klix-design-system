# Accessibility Playbook

WCAG 2.1 AA is the floor, not the ceiling. This playbook collects per-component patterns, keyboard maps, focus management strategies, and live-region rules that get us reliably above that floor.

I keep finding myself looking up the same ARIA patterns over and over (especially combobox and tabs), so I dumped them all in one place. Feel free to extend — if you find a gap, add it.

> Read this when the task involves accessibility, screen-reader support, keyboard navigation, focus management, or you're auditing existing UI for compliance.

---

## 1. The 7 cross-cutting concerns

Independent of component, every MK-DS UI must satisfy:

| Concern | Requirement |
|---------|-------------|
| **Contrast** | 4.5:1 body text, 3:1 large text (≥18px or ≥14px bold) and UI controls |
| **Keyboard reachability** | Every interactive element reachable by Tab, in visual order |
| **Focus visibility** | `:focus-visible` ring (4px, `--brand`) on every interactive element |
| **Semantic structure** | Single `<h1>`; no skipped heading levels; landmarks (`<header>`, `<nav>`, `<main>`, `<footer>`) |
| **Forms** | Every input has a `<label>` (or `aria-label`); errors linked via `aria-describedby` |
| **Live regions** | Async updates announced via `aria-live` |
| **Reduced motion** | All transitions > 150ms respect `prefers-reduced-motion` |

---

## 2. Skip link (every page)

Add as the first focusable element:

```html
<a href="#main" class="mk-skip-link">Skip to content</a>
…
<main id="main" tabindex="-1">…</main>
```

CSS for `.mk-skip-link`:
- Visually hidden until focused (`position: absolute; top: -40px;`)
- On `:focus`, animate to `top: var(--space-2)` with z-index above all
- Background `--bg-primary`, text `--brand`, border, shadow

---

## 3. Landmark structure

Required per page:

```html
<a class="mk-skip-link" href="#main">Skip to content</a>

<header>                       <!-- Page header (logo, search, user menu) -->
  <nav aria-label="Primary">…</nav>
</header>

<main id="main" tabindex="-1">
  …
</main>

<footer>…</footer>
```

- `<nav>` always has `aria-label` ("Primary", "Secondary", "Footer", "Breadcrumb")
- `<aside>` for complementary content with its own context
- `<section>` requires an accessible name (`aria-label` or `aria-labelledby`)

---

## 4. Focus management — the rules

### When focus moves automatically

- **Modal open** → first focusable inside modal
- **Modal close** → trigger element
- **Drawer open** → first focusable inside drawer
- **Toast appears** → does **not** steal focus (announced via `aria-live`)
- **Page navigation** (SPA) → focus the new `<main>` (with `tabindex="-1"`)
- **Form submit success** → next logical element (e.g., success message or next page)
- **Error appears in form** → first invalid field

### Focus trap (modals, drawers)

Implementation pattern:

```js
function trapFocus(container) {
  const focusable = container.querySelectorAll(
    'a, button, input, select, textarea, [tabindex]:not([tabindex="-1"])'
  );
  const first = focusable[0];
  const last = focusable[focusable.length - 1];

  container.addEventListener('keydown', e => {
    if (e.key !== 'Tab') return;
    if (e.shiftKey && document.activeElement === first) {
      e.preventDefault();
      last.focus();
    } else if (!e.shiftKey && document.activeElement === last) {
      e.preventDefault();
      first.focus();
    }
  });

  first.focus();
}
```

### Common bug: focus lost

When a focused element is removed from the DOM (e.g., a dropdown item that disappears on selection), focus jumps to `<body>`. Always:

1. Move focus to a sensible location *before* removing the element
2. OR ensure the removal triggers a focus event you handle

---

## 5. Keyboard maps per pattern

### Tabs

| Key | Behavior |
|-----|----------|
| Tab | Enter/leave tablist (focuses selected tab) |
| ← / → | Move between tabs |
| Home / End | First / last tab |
| Enter / Space | Activate (if `aria-activation="manual"`) |

### Dropdown / Menu

| Key | Behavior |
|-----|----------|
| ↓ | Open menu OR move to next item |
| ↑ | Move to previous item |
| Home / End | First / last item |
| `<letter>` | Jump to next matching item |
| Enter | Select |
| ESC | Close, return focus to trigger |

### Modal

| Key | Behavior |
|-----|----------|
| Tab / Shift+Tab | Cycle within modal |
| ESC | Close (unless destructive confirmation) |

### Tree view

| Key | Behavior |
|-----|----------|
| ↓ / ↑ | Next / previous visible node |
| → | Expand collapsed node OR go to first child if expanded |
| ← | Collapse expanded node OR go to parent if collapsed |
| Home / End | First / last visible node |
| Enter | Activate node |

### Combobox

| Key | Behavior |
|-----|----------|
| ↓ | Open listbox |
| Type | Filter (autocomplete) |
| ↓ / ↑ in listbox | Navigate filtered options |
| Enter | Select |
| ESC | Close, restore input value OR clear |

---

## 6. Live regions — when and how

Use `aria-live` for content that updates without user navigation.

| Politeness | Use case |
|-----------|----------|
| `polite` | Toast, save confirmation, search results, async list updates |
| `assertive` | Errors, validation failures, time-sensitive alerts |
| `off` (default) | Static content |

Rules:

- Define the region **before** populating it: `<div aria-live="polite"></div>` in DOM, then inject content into it.
- Don't make `<main>` live — that's noise.
- For status messages, prefer `role="status"` (implies `aria-live="polite"`) or `role="alert"` (implies `aria-live="assertive"`).

```html
<!-- Toast region -->
<div class="mk-toast-region" aria-live="polite" aria-atomic="false">
  <!-- toasts inserted here -->
</div>

<!-- Form error summary -->
<div role="alert" class="mk-alert-banner mk-alert-banner--error">
  Please fix 2 errors before submitting.
</div>
```

---

## 7. Forms — the complete pattern

```html
<form novalidate>
  <!-- Error summary (top, appears on submit attempt with errors) -->
  <div role="alert" class="mk-alert-banner mk-alert-banner--error" hidden>
    <h2>Please fix the following:</h2>
    <ul>
      <li><a href="#email-field">Email is invalid</a></li>
    </ul>
  </div>

  <!-- Field -->
  <div class="mk-field">
    <label for="email" class="mk-label">
      Email address
      <span class="mk-label__required" aria-hidden="true">*</span>
    </label>
    <input id="email"
           type="email"
           class="mk-input"
           required
           autocomplete="email"
           aria-required="true"
           aria-invalid="false"
           aria-describedby="email-help" />
    <p id="email-help" class="mk-field__help">We'll never share your email.</p>
  </div>

  <!-- Submit -->
  <button type="submit" class="mk-btn mk-btn--primary">Sign in</button>
</form>
```

### Validation rules

1. **Validate on blur, not on every keystroke** (don't punish typing)
2. **Clear errors as soon as the user starts editing**
3. **On submit with errors**:
   - Show error summary at top (with anchor links to fields)
   - Move focus to summary
   - Mark each invalid field with `aria-invalid="true"` + error message linked via `aria-describedby`
4. **On successful submit**, replace form with success state OR navigate

### Autocomplete attributes (critical)

| Field | `autocomplete` value |
|-------|--------------------|
| Email | `email` |
| Password (login) | `current-password` |
| Password (signup/reset) | `new-password` |
| Name | `name` (or `given-name` / `family-name`) |
| Phone | `tel` |
| Street address | `street-address` |
| Postal code | `postal-code` |
| Card number | `cc-number` |
| Card expiry | `cc-exp` |
| One-time code (OTP/SMS) | `one-time-code` |

---

## 8. Icon-only buttons

Every icon-only button needs an accessible name:

```html
<!-- Option A: aria-label -->
<button class="mk-btn mk-btn--icon" aria-label="Close">
  <svg aria-hidden="true">…</svg>
</button>

<!-- Option B: visually hidden text -->
<button class="mk-btn mk-btn--icon">
  <svg aria-hidden="true">…</svg>
  <span class="mk-sr-only">Close</span>
</button>
```

The `<svg>` is always `aria-hidden="true"` because the button has the name.

`.mk-sr-only` (screen-reader-only) CSS:
```css
.mk-sr-only {
  position: absolute;
  width: 1px; height: 1px;
  padding: 0; margin: -1px;
  overflow: hidden;
  clip: rect(0, 0, 0, 0);
  white-space: nowrap;
  border: 0;
}
```

---

## 9. Color contrast checks

Run mental contrast checks against the MK-DS palette:

| Foreground | Background | Ratio | Pass |
|-----------|-----------|-------|------|
| `--text-primary` (#101828) | `--bg-primary` (#FFFFFF) | 18.2:1 | ✓ AAA |
| `--text-secondary` (#667085) | `--bg-primary` (#FFFFFF) | 4.7:1 | ✓ AA body |
| `--brand` (#1F12DE) | `--bg-primary` (#FFFFFF) | 9.2:1 | ✓ AAA |
| `--brand` (#1F12DE) | `--bg-primary` dark (#0C111D) | low | ✗ — use brand on light bg only |

For dark mode:
| Foreground | Background | Ratio | Pass |
|-----------|-----------|-------|------|
| `--text-primary` dark (#F5F5F6) | `--bg-primary` dark (#0C111D) | 17.4:1 | ✓ AAA |
| `--text-secondary` dark (#94969C) | `--bg-primary` dark (#0C111D) | 5.6:1 | ✓ AA body |

**When in doubt**, run [WebAIM Contrast Checker](https://webaim.org/resources/contrastchecker/) values against the hex values in `tokens.json`.

---

## 10. Touch targets

Per WCAG 2.5.5 (AAA, but MK-DS aims for it):

- All interactive elements must be **at least 44×44 CSS pixels**
- This includes the click target, not just the visible icon

For icon-only buttons that look 24px:
```css
.mk-btn--icon {
  width: 44px;
  height: 44px;
  /* OR use padding to reach 44px */
}
```

---

## 11. Reduced motion

```css
@media (prefers-reduced-motion: reduce) {
  *, *::before, *::after {
    animation-duration: 0.01ms !important;
    animation-iteration-count: 1 !important;
    transition-duration: 0.01ms !important;
    scroll-behavior: auto !important;
  }
}
```

Specific patterns that need extra care:
- **Auto-playing carousels** → must pause control
- **Parallax scrolling** → disable entirely
- **Page transitions** → instant replacement
- **Toast slide-in** → fade-in instead

See `references/motion.md` for the full motion system.

---

## 12. Per-component a11y quick reference

| Component | Critical ARIA | Keyboard |
|-----------|--------------|----------|
| `button` | (semantic) | Space/Enter activate |
| `toggle` | `role="switch"`, `aria-checked` | Space toggle |
| `checkbox` | `aria-checked` (or native) | Space toggle |
| `radio` group | `role="radiogroup"`, `aria-labelledby` | ↑↓←→ between radios |
| `select` (native) | `<label>` required | (browser default) |
| `dropdown` | `aria-haspopup`, `aria-expanded`, `aria-controls` | ↑↓ navigate, ESC close |
| `tabs` | `role="tab/tablist/tabpanel"`, `aria-selected`, `aria-controls` | ←→ between tabs |
| `accordion` | `aria-expanded` on trigger | Space/Enter toggle |
| `modal` | `role="dialog"`, `aria-labelledby`, `aria-modal="true"` | Tab trap, ESC close |
| `drawer` | Same as modal | Same as modal |
| `tooltip` | `role="tooltip"`, `aria-describedby` from trigger | Focus reveals, ESC hides |
| `popover` | `aria-haspopup="dialog"`, `aria-expanded` | ESC close |
| `toast` | `aria-live="polite"` or `role="alert"` | Dismissible by keyboard |
| `progress-bar` | `role="progressbar"`, `aria-valuenow/min/max` | — |
| `slider` | `role="slider"`, `aria-valuenow/min/max` | ←→ adjust |
| `data-table` | `<caption>`, `<th scope="col/row">`, `aria-sort` on sortable | (depends on extras) |
| `tree-view` | `role="tree/treeitem"`, `aria-expanded`, `aria-level` | ↑↓←→ navigate |
| `breadcrumbs` | `<nav aria-label="Breadcrumb">`, `aria-current="page"` on last | — |
| `pagination` | `<nav aria-label="Pagination">`, `aria-current="page"` on current | — |
| `stepper` | `aria-current="step"`, list semantics | — |
| `command-palette` | Combobox pattern (see §5) | ↑↓ navigate, Enter select |

---

## 13. Audit script

Run `scripts/audit-output.sh <file>` to catch common a11y violations automatically. It checks:

- Buttons without text or `aria-label`
- Images without `alt`
- Inputs without labels
- `<div onClick>` patterns
- Skipped heading levels
- `outline: none` without replacement
- Hardcoded colors that fail dark mode

The script is in this skill's `scripts/` directory.
