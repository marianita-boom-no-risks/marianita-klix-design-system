# Migration Guide — Legacy UI → MK-DS

How to port existing UI (Bootstrap, Tailwind, custom CSS, whatever) into MK-DS without losing functionality, regressing UX, or introducing inconsistency.

I wrote this after migrating two larger projects from Bootstrap and one from Tailwind. The process is roughly the same in all cases; the gotchas vary.

> Read this when the task is "convert this to MK-DS", "use the design system here", or "refactor this UI to match the brand".

---

## 1. Migration philosophy

Migration is not rewriting. It's **substituting equivalents** while preserving behavior. The output should be functionally identical but adhere to the DS contract.

Three rules:

1. **Inventory before substituting.** Know what you have before you change it.
2. **One-to-one mapping over creative replacement.** Find the equivalent component; don't redesign while migrating.
3. **Surface gaps explicitly.** If something doesn't map cleanly, stop and ask.

---

## 2. The 6-step process

### Step 1 — Inventory

For the file/page being migrated, list:

- Every interactive element (button, input, etc.) by current class
- Every container (card-like, section-like) with its current styling
- Every color, spacing, and font-size value in use
- Every state shown (default, hover, focus, disabled, loading, error, empty)

Example inventory:

| Element | Current class | Current values |
|---------|--------------|----------------|
| Submit button | `.btn .btn-primary` | bg #007BFF, padding 8px 16px, radius 4px |
| Form input | `.form-control` | border #CED4DA, padding 6px 12px |
| Card | `.card .shadow-sm` | bg white, padding 24px, radius 8px |
| Title | `<h2>` no class | font 24px, weight 700 |

### Step 2 — Map to MK-DS

Per inventory row, identify the MK-DS equivalent:

| Current | MK-DS |
|---------|-------|
| `.btn .btn-primary` (Bootstrap) | `mk-btn mk-btn--primary mk-btn--md` |
| `.btn .btn-secondary` | `mk-btn mk-btn--secondary mk-btn--md` |
| `.btn .btn-danger` | `mk-btn mk-btn--destructive mk-btn--md` |
| `.btn .btn-link` | `mk-btn mk-btn--tertiary` (or just an `<a>`) |
| `.btn-sm` modifier | `mk-btn--sm` |
| `.btn-lg` modifier | `mk-btn--lg` |
| `.form-control` | `mk-input` |
| `.form-control.is-invalid` | `mk-input mk-input--error` |
| `.form-check-input` | `mk-checkbox` |
| `.card` | `mk-card` |
| `.card-header` | `mk-card__header` |
| `.card-body` | `mk-card__body` |
| `.card-footer` | `mk-card__footer` |
| `.badge` | `mk-badge` (+ variant) |
| `.alert .alert-warning` | `mk-alert-banner mk-alert-banner--warning` |
| `.modal` (Bootstrap) | `mk-modal` (different markup — see component spec) |
| `.dropdown` | `mk-dropdown` |
| `.nav .nav-tabs` | `mk-tabs` |
| `.breadcrumb` | `mk-breadcrumbs` |
| `.pagination` | `mk-pagination` |
| `.spinner-border` | `mk-spinner` |
| `.progress` | `mk-progress` |
| `.table` | `mk-table` (or `mk-data-table` for sortable) |

For Tailwind:

| Tailwind | MK-DS |
|----------|-------|
| `bg-blue-500` | `mk-btn--primary` (if it's a button) or `style="background: var(--brand)"` |
| `bg-white` | `var(--bg-primary)` |
| `text-gray-900` | `var(--text-primary)` |
| `p-4` (16px) | `var(--space-4)` |
| `rounded-md` (6px) | `var(--radius-md)` (8px, close enough — flag if exact match matters) |
| `shadow-md` | `var(--shadow-md)` |
| `font-semibold` | `var(--font-semibold)` |

### Step 3 — Map every value to a token

For each color, spacing, radius, shadow, and font value in your inventory, find the nearest MK-DS token.

If the value falls between tokens (e.g., 18px when DS has 16px and 20px):
- Round to the nearest token
- Flag to user: *"Original used 18px padding; I used `var(--space-4)` (16px). If the exact 18px matters, we need a new token."*

If the value has no nearby token (e.g., a unique brand color):
- Stop and ask before fabricating

### Step 4 — Substitute, preserving behavior

Replace markup + classes, but keep:
- IDs
- Data attributes
- Event handlers
- ARIA attributes (verify they're still correct after substitution)
- Form field names and `autocomplete` values

### Step 5 — Verify states

For every element, verify that all original states still work:
- Default ✓
- Hover (✓ for buttons, links, cards if interactive)
- Focus (✓ for all interactive)
- Active / pressed
- Disabled
- Error (for form fields)
- Loading (for async actions)
- Empty (for lists)

If the original had a state and the substitution doesn't, surface the regression.

### Step 6 — Audit

Run the §7 pre-flight from `SKILL.md` and `scripts/audit-output.sh` on the migrated code.

---

## 3. Markup-level changes — common patterns

### Bootstrap card → MK-DS card

❌ Before
```html
<div class="card shadow-sm">
  <div class="card-header">
    <h5 class="card-title">Hello</h5>
  </div>
  <div class="card-body">
    <p class="card-text">Content</p>
  </div>
</div>
```

✅ After
```html
<div class="mk-card">
  <div class="mk-card__header">
    <h3 class="mk-card__title">Hello</h3>
  </div>
  <div class="mk-card__body">
    <p>Content</p>
  </div>
</div>
```

Note the `<h5>` → `<h3>` change. Bootstrap used `h5` for visual weight; MK-DS uses semantic heading levels and styles them via tokens.

---

### Bootstrap modal → MK-DS modal

Bootstrap modals nest divs; MK-DS uses `<dialog>`:

❌ Before
```html
<div class="modal fade" tabindex="-1">
  <div class="modal-dialog">
    <div class="modal-content">
      <div class="modal-header">…</div>
      <div class="modal-body">…</div>
      <div class="modal-footer">…</div>
    </div>
  </div>
</div>
```

✅ After
```html
<dialog class="mk-modal" aria-labelledby="modal-title">
  <header class="mk-modal__header">
    <h2 id="modal-title" class="mk-modal__title">…</h2>
    <button class="mk-modal__close" aria-label="Close">×</button>
  </header>
  <div class="mk-modal__body">…</div>
  <footer class="mk-modal__footer">…</footer>
</dialog>
```

Behavior change: `<dialog>` has built-in focus trapping and `showModal()` / `close()` APIs. Update your JS accordingly.

---

### Bootstrap form → MK-DS form

Bootstrap inputs nest label + input + help text differently:

❌ Before
```html
<div class="form-group">
  <label for="email">Email</label>
  <input id="email" class="form-control" />
  <small class="form-text text-muted">We'll never share it.</small>
</div>
```

✅ After
```html
<div class="mk-field">
  <label for="email" class="mk-label">Email</label>
  <input id="email" class="mk-input" aria-describedby="email-help" />
  <p id="email-help" class="mk-field__help">We'll never share it.</p>
</div>
```

Note `aria-describedby` is added during migration. It wasn't always present in Bootstrap defaults.

---

### Tailwind component → MK-DS component

Tailwind UI patterns often nest utility classes:

❌ Before
```html
<button class="bg-blue-500 hover:bg-blue-600 text-white font-semibold py-2 px-4 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-300">
  Submit
</button>
```

✅ After
```html
<button class="mk-btn mk-btn--primary mk-btn--md">
  Submit
</button>
```

All the visual properties move into the registered class.

---

## 4. Class-by-class migration table

Use this for find-and-replace across files. Verify each substitution preserves intent (don't blind-replace).

| Find | Replace |
|------|---------|
| `btn btn-primary` | `mk-btn mk-btn--primary mk-btn--md` |
| `btn btn-secondary` | `mk-btn mk-btn--secondary mk-btn--md` |
| `btn btn-danger` | `mk-btn mk-btn--destructive mk-btn--md` |
| `btn-sm` | `mk-btn--sm` |
| `btn-lg` | `mk-btn--lg` |
| `form-control` | `mk-input` |
| `form-check-input` | `mk-checkbox` |
| `form-select` | `mk-select` |
| `card` (Bootstrap) | `mk-card` |
| `card-header` | `mk-card__header` |
| `card-body` | `mk-card__body` |
| `card-footer` | `mk-card__footer` |
| `card-title` | `mk-card__title` |
| `badge` | `mk-badge` (verify variant!) |
| `alert alert-primary` | `mk-alert-banner mk-alert-banner--info` |
| `alert alert-success` | `mk-alert-banner mk-alert-banner--success` |
| `alert alert-warning` | `mk-alert-banner mk-alert-banner--warning` |
| `alert alert-danger` | `mk-alert-banner mk-alert-banner--error` |
| `table` (Bootstrap) | `mk-table` |
| `breadcrumb` | `mk-breadcrumbs` |
| `breadcrumb-item` | `mk-breadcrumbs__item` |
| `pagination` | `mk-pagination` |
| `page-item` | `mk-pagination__item` |
| `nav nav-tabs` | `mk-tabs` (markup may need restructuring) |
| `dropdown` | `mk-dropdown` (markup may need restructuring) |
| `tooltip` (Bootstrap) | `mk-tooltip` (initialization differs) |
| `popover` (Bootstrap) | `mk-popover` |
| `spinner-border` | `mk-spinner` |
| `progress` | `mk-progress` |
| `progress-bar` | `mk-progress__bar` |

---

## 5. JavaScript migration

If the legacy UI used Bootstrap's JS:

| Bootstrap JS | MK-DS equivalent |
|--------------|------------------|
| `new bootstrap.Modal(el).show()` | `dialogEl.showModal()` (native) or call MK-DS modal helper if present |
| `new bootstrap.Tooltip(el)` | MK-DS tooltips are CSS-only on `[data-tooltip]` (verify per project) |
| `new bootstrap.Toast(el).show()` | Append to `.mk-toast-region`; auto-dismiss via setTimeout |
| `$('.dropdown').dropdown()` | Native `<details>` or DS dropdown JS (see component) |
| `bootstrap.Tab.getInstance(el).show()` | DS tabs use ARIA pattern; toggle `aria-selected` and `hidden` on panels |

---

## 6. CSS file migration

If the project has a custom CSS file:

1. **Audit for tokens-in-disguise** — variables like `--my-blue` that are basically the brand color. Replace with `var(--brand)`.
2. **Move spacing values to tokens** — find every `padding`, `margin`, `gap` with a px value and replace with `--space-*`.
3. **Move font definitions** — replace local `--font-*` with the MK-DS equivalents.
4. **Delete dead overrides** — Bootstrap overrides often customize components MK-DS handles differently. Remove them; the MK-DS class takes over.

After migration, the project's custom CSS file should be small. If it's still hundreds of lines, you're probably preserving customizations that should be raised to the design team.

---

## 7. Surfacing gaps

Migration often reveals that the legacy UI did things the DS doesn't (yet) support. Don't fabricate; surface:

> **Migration gaps:**
> - The legacy UI has a "ghost button" variant (transparent bg, brand border). MK-DS has `tertiary` (no border) — close but not identical. Options:
>   - Use `tertiary` (most consistent)
>   - Register a `ghost` variant in the DS (requires design review)
> - The legacy modal has a "fullscreen on mobile" variant. MK-DS modal is fixed-size. Suggest registering `mk-modal--fullscreen`.
> - The legacy uses a custom font (Roboto) for some headings. MK-DS uses Inter exclusively. The migration unifies to Inter.

---

## 8. Verification — before declaring "done"

- [ ] Every legacy class replaced or removed
- [ ] Every legacy hex/px value tokenized
- [ ] All states still work (default, hover, focus, disabled, loading, error)
- [ ] Dark mode works (toggle and verify)
- [ ] Keyboard navigation intact
- [ ] No regression in feature behavior
- [ ] Gaps explicitly listed in the output
- [ ] §7 pre-flight from `SKILL.md` passes
- [ ] `scripts/audit-output.sh` passes
