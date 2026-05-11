# Anti-Patterns Catalog

Things I've shipped, regretted, and learned from. Or that I caught in someone else's PR and added here so we don't do it again. Each entry has the symptom, the reason it's wrong, and the fix.

Use this as a self-audit before output, or as a review checklist when looking at existing UI.

(A handful of these were genuinely me. I left them in because I'd rather the team learn from real mistakes than abstract "best practices".)

> **Read this** before submitting work, when refactoring existing MK-DS code, or when something looks "off".

---

## A. Token violations

### A1 — Hardcoded color

❌ **Bad**
```css
.my-banner {
  background: #F2F4F7;
  color: #101828;
  border: 1px solid #EAECF0;
}
```

✅ **Good**
```css
.my-banner {
  background: var(--bg-tertiary);
  color: var(--text-primary);
  border: 1px solid var(--border-primary);
}
```

**Why** — Hardcoded colors break dark mode (#F2F4F7 stays light in dark UI), break theme changes, and drift from the registered palette over time.

---

### A2 — Off-token spacing

❌ **Bad**
```css
.my-card { padding: 18px; gap: 14px; }
```

✅ **Good**
```css
.my-card { padding: var(--space-4); gap: var(--space-3); }
/* If 18px was intentional, surface it: "The design used 18px; closest token is 16px (--space-4). Use that, or do we need a new token?" */
```

**Why** — 18px and 14px aren't in the spacing scale. Allowing arbitrary values defeats the rhythm system.

---

### A3 — Primitive where semantic exists

❌ **Bad**
```css
.my-text { color: var(--gray-900); }   /* Won't swap in dark mode */
```

✅ **Good**
```css
.my-text { color: var(--text-primary); }
```

**Why** — Primitives are raw hex; semantics are mode-aware. Always prefer semantics when one applies.

---

### A4 — Tailwind utilities for design decisions

❌ **Bad**
```html
<div class="bg-blue-500 text-white p-4 rounded-lg">…</div>
```

✅ **Good**
```html
<div class="mk-card" style="background: var(--brand); color: white;">…</div>
<!-- OR use the right MK-DS component -->
```

**Why** — Tailwind color/spacing utilities bypass the token system entirely. They also lock you into Tailwind's scale (which doesn't match MK-DS's `--space-2h` half-step).

**Allowed**: layout utilities like `flex`, `grid`, `items-center`, `justify-between`. These are structural, not design tokens.

---

## B. Component fabrication

### B1 — Inventing a `mk-` class

❌ **Bad**
```html
<div class="mk-product-card">
  <img class="mk-product-card__image" src="…">
  <h3 class="mk-product-card__title">…</h3>
</div>
```

✅ **Good** — `product-card` isn't in the registry. Compose with what is:
```html
<div class="mk-card">
  <img class="mk-card__media" src="…">
  <div class="mk-card__header">
    <h3 class="mk-card__title">…</h3>
  </div>
</div>
```

…then surface the gap: *"I composed a product card from `mk-card`. If product cards become common, we should register `product-card` in the DS."*

**Why** — `mk-product-card` is a lie. The class doesn't exist in the stylesheet; it'll be unstyled or rely on adjacent rules that break later.

---

### B2 — Component variant that doesn't exist

❌ **Bad**
```html
<button class="mk-btn mk-btn--ghost">…</button>
<!-- "ghost" isn't a registered button variant -->
```

✅ **Good** — Use `tertiary` (the registered closest variant) or surface the gap.

**Why** — The CSS doesn't define `mk-btn--ghost`, so it'll inherit `mk-btn` base styles and look wrong. Always verify variant names against `get_component`.

---

## C. Semantic / a11y violations

### C1 — `<div onClick>` instead of `<button>`

❌ **Bad**
```html
<div class="mk-btn mk-btn--primary" onclick="doThing()">Submit</div>
```

✅ **Good**
```html
<button class="mk-btn mk-btn--primary" onclick="doThing()">Submit</button>
```

**Why** — `<div>` isn't focusable, isn't keyboard-activatable, isn't announced as a button by screen readers.

---

### C2 — Icon-only button with no accessible name

❌ **Bad**
```html
<button class="mk-btn mk-btn--icon">
  <svg>…</svg>
</button>
```

✅ **Good**
```html
<button class="mk-btn mk-btn--icon" aria-label="Close">
  <svg aria-hidden="true">…</svg>
</button>
```

**Why** — Screen readers announce "button" with no context. Users have no idea what it does.

---

### C3 — Input without label

❌ **Bad**
```html
<input class="mk-input" placeholder="Email" />
```

✅ **Good**
```html
<label for="email" class="mk-label">Email</label>
<input id="email" class="mk-input" />
```

Or:

```html
<input class="mk-input" aria-label="Email" placeholder="you@example.com" />
```

**Why** — Placeholders are not labels. They disappear on input and aren't reliably announced by all screen readers.

---

### C4 — Skipped heading level

❌ **Bad**
```html
<h1>Settings</h1>
<h3>Profile</h3>     <!-- Skipped h2 -->
```

✅ **Good**
```html
<h1>Settings</h1>
<h2>Profile</h2>
```

**Why** — Screen reader users navigate by headings. A skip breaks the outline.

---

### C5 — `outline: none` without replacement

❌ **Bad**
```css
.mk-input:focus { outline: none; }
```

✅ **Good**
```css
.mk-input:focus-visible {
  outline: 2px solid var(--brand);
  outline-offset: 2px;
}
/* OR rely on the MK-DS default focus ring — don't remove it */
```

**Why** — Removing focus visibility makes the UI unusable by keyboard.

---

## D. State management violations

### D1 — No loading state on async action

❌ **Bad**
```html
<button class="mk-btn mk-btn--primary" onclick="submit()">Save</button>
<!-- Button stays "Save" while network request is in flight; user clicks again, double-submits -->
```

✅ **Good**
```html
<button class="mk-btn mk-btn--primary"
        onclick="submit(this)"
        data-loading-text="Saving…">Save</button>

<script>
function submit(btn) {
  btn.disabled = true;
  btn.setAttribute('aria-busy', 'true');
  btn.classList.add('mk-btn--loading');
  // …
  // on completion:
  btn.disabled = false;
  btn.removeAttribute('aria-busy');
  btn.classList.remove('mk-btn--loading');
}
</script>
```

**Why** — Without explicit loading state, users double-click, refresh, or assume nothing happened.

---

### D2 — Errors that don't announce

❌ **Bad**
```html
<input class="mk-input mk-input--error" />
<p class="mk-field__error">Invalid email</p>
<!-- Visual error only; screen-reader users miss it -->
```

✅ **Good**
```html
<input class="mk-input mk-input--error"
       aria-invalid="true"
       aria-describedby="email-error" />
<p id="email-error" class="mk-field__error" role="alert">Invalid email</p>
```

---

### D3 — Modal that doesn't trap focus

❌ **Bad** — Modal opens; Tab key moves focus into the page behind. Worse, ESC doesn't close.

✅ **Good** — See `references/state-machines.md` §3 for the full pattern.

---

## E. Layout / composition violations

### E1 — Nested cards

❌ **Bad**
```html
<div class="mk-card">
  <div class="mk-card">…</div>
</div>
```

✅ **Good** — Use a single card with internal sections, or use a card next to non-card content.

**Why** — Visually noisy. Adds borders/shadows that compete. Almost always a sign that the structure is wrong.

---

### E2 — Inline styles for design tokens

❌ **Bad**
```html
<div style="padding: 16px; background: #FFFFFF;">…</div>
```

✅ **Good**
```html
<div class="mk-card">…</div>
<!-- OR if the token isn't covered by a class: -->
<div style="padding: var(--space-4); background: var(--bg-primary);">…</div>
```

**Why** — Inline styles with hardcoded values break dark mode and bypass the system. Inline styles *with tokens* are acceptable for one-off arrangements.

---

### E3 — Fixed widths instead of fluid

❌ **Bad**
```css
.my-form { width: 800px; }
```

✅ **Good**
```css
.my-form { width: 100%; max-width: 800px; }
```

**Why** — Breaks below 800px wide. Mobile users see horizontal scroll or worse.

---

## F. Performance / scale violations

### F1 — Animating layout properties

❌ **Bad**
```css
.my-drawer {
  transition: width var(--duration-slow) var(--easing-out);
}
```

✅ **Good**
```css
.my-drawer {
  transform: translateX(-100%);
  transition: transform var(--duration-slow) var(--easing-out);
}
.my-drawer--open { transform: translateX(0); }
```

**Why** — `width` triggers layout/reflow every frame. `transform` is GPU-accelerated.

---

### F2 — `will-change` on too many elements

❌ **Bad**
```css
.mk-card { will-change: transform, opacity; }
/* Applied to dozens of cards on the page */
```

✅ **Good** — Add `will-change` only when an animation is about to fire, and remove after.

**Why** — Each `will-change` element gets its own GPU layer; too many = memory blowup.

---

## G. Process violations

### G1 — Hand-writing component CSS instead of pulling from MCP

❌ **Bad** — User asks for a button; you write CSS for a button without calling `get_component`.

✅ **Good** — Always pull from the MCP. Hand-writing means you'll drift from the registered spec.

---

### G2 — Not surfacing gaps

❌ **Bad** — User asks for a "carousel"; you build one with `mk-image-gallery` styled differently and pretend it's a carousel.

✅ **Good**
> "MK-DS doesn't have a carousel component. Options:
> (a) Use `mk-image-gallery` (grid, no autoplay) — closest fit.
> (b) Build a one-off carousel with vanilla JS using DS tokens.
> (c) Add a `carousel` to the registry — needs a design review.
> Which do you want?"

---

### G3 — Implementing happy path only

❌ **Bad** — User asks for a list page; you build the list. There's no empty state, no loading state, no error state.

✅ **Good** — Always include:
- Loading (`skeleton`)
- Empty (`empty-state`)
- Error (`alert-banner`)
- Happy

…even if the user didn't ask. Or surface that you skipped them: *"I implemented the happy-path list. We should add empty/loading/error states before shipping — want me to do that now?"*

---

## H. MCP-specific violations

### H1 — Not calling `get_css_setup` on new projects

Symptom: tokens aren't defined, every component looks unstyled.

Fix: always call `get_css_setup` first in a new project.

---

### H2 — Calling `get_component` with a guessed name

❌ **Bad**
```
get_component(name: "fancy-card")
```

✅ **Good**
```
search(query: "card")
list_components(category: "Data Display")
get_component(name: "<actual-slug-from-results>")
```

---

### H3 — Pasting MCP output without adaptation

The MCP returns reference code, not final code. Always adapt:
- Wire to your project's data flow
- Replace placeholder content with real
- Add the imports/setup for your framework
- Verify props match your context

---

## MCP offline recovery

If the MCP server is unreachable:

1. **Tell the user** — *"The marianita-klix-ds MCP server isn't responding. I'll work from the static docs."*
2. **Read fallbacks**:
   - `CLAUDE.md` (project root) — full reference
   - `index.html` — visual catalogue
   - `tokens.json` — raw token data
   - `references/` (this skill's docs)
3. **Be more cautious** — without `get_component`, you can't verify a slug exists. Cross-check against `CLAUDE.md`'s component table.
4. **Suggest reconnecting** — *"Once the MCP is back, re-run the task; I may have approximated something the MCP would have given exactly."*

---

## Final self-check

Before output, scan your work and ask: would this pass a senior frontend review at a top-tier product team?

If you can't say yes with confidence, identify the weak spot and fix it. Don't ship work you'd be embarrassed to defend.
