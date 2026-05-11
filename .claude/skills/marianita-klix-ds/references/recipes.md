# MK-DS Composition Recipes

Composition patterns I keep ending up with. Each recipe is the rough MCP tool sequence plus the component slugs that make it up. Some of these I extracted from real projects; others I built explicitly for the DS docs because they kept coming up.

> Read this when your task involves more than 2 components or matches one of the named patterns below. Single-component tasks don't need this file.

— Mariana

## How to use

Each recipe is structured as:

1. **Pattern** — what you're building
2. **When** — signals that this is the right recipe
3. **Tool sequence** — exact MCP calls in order
4. **Composition** — how the components nest
5. **Tokens used** — spacing/typography conventions specific to the pattern
6. **A11y notes** — pattern-specific accessibility requirements

---

## Recipe 1 — Auth form (login / signup / forgot password)

**When:** "Build a login page", "signup form", "auth UI", "password reset"

**Tool sequence:**
```
get_page_template(template: "login")
get_component(name: "input")
get_component(name: "button")
get_component(name: "checkbox")
get_component(name: "alert-banner")   # for error states
```

**Composition (login):**
```
<form>
  <header>                       → Section header w/ logo, title, subtitle
  <fieldset>                     → Email input
  <fieldset>                     → Password input + show/hide toggle
  <row>                          → "Remember me" checkbox + "Forgot?" link
  <button --primary --md>        → Submit
  <divider with "or" label>
  <button --secondary --md>      → SSO / alternative auth
  <footer link>                  → "Don't have an account? Sign up"
</form>
```

**Tokens:**
- Form max-width: 400px
- Gap between fieldsets: `var(--space-4)`
- Gap between title and form: `var(--space-6)`
- Page vertical padding: `var(--space-8)`

**A11y:**
- Email input: `type="email"`, `autocomplete="email"`
- Password: `autocomplete="current-password"` (login) or `"new-password"` (signup)
- Error banner appears in DOM (not just on form fields) for screen readers
- Submit button reflects state: idle → "Sign in", loading → "Signing in…" with `aria-busy`

---

## Recipe 2 — Dashboard with KPIs

**When:** "Build a dashboard", "analytics page", "overview screen", "metrics view"

**Tool sequence:**
```
get_page_template(template: "dashboard")
get_component(name: "sidebar-nav")
get_component(name: "stat-card")
get_component(name: "data-table")
get_component(name: "card")
get_component(name: "badge")
```

**Composition:**
```
<layout>
  <sidebar-nav>                  → Primary navigation, collapsible
  <main>
    <section-header>             → Page title + filter controls + primary CTA
    <grid columns="4">           → 4 × stat-card (top KPIs)
    <grid columns="2">           → 2 × card (chart placeholders)
    <card>
      <data-table>               → Recent activity / records
    </card>
  </main>
</layout>
```

**Tokens:**
- Sidebar width: 240px (collapsed: 64px)
- Main padding: `var(--space-6)`
- KPI grid gap: `var(--space-4)`
- Section gap: `var(--space-8)`

**A11y:**
- Sidebar is `<nav aria-label="Primary">`
- Skip-link to `<main>` at top of body
- Each stat-card includes screen-reader text for trend direction ("up 12% vs last month")
- Data-table has `<caption>` (visually hidden if needed)

---

## Recipe 3 — Settings page (tabbed)

**When:** "Build a settings page", "account preferences", "profile settings"

**Tool sequence:**
```
get_page_template(template: "settings")
get_component(name: "tabs")
get_component(name: "input")
get_component(name: "toggle")
get_component(name: "select")
get_component(name: "button")
get_component(name: "avatar")
```

**Composition:**
```
<page>
  <section-header>               → "Settings" + breadcrumbs
  <tabs>                         → Profile · Account · Notifications · Billing · Security
    <tab-panel>
      <card>
        <section>                → Group: "Personal info"
          <avatar + upload>
          <input>                → Name, email, etc.
        <section>                → Group: "Preferences"
          <toggle>               → Email notifications, dark mode, etc.
        <footer-actions>         → Cancel + Save
      </card>
    </tab-panel>
  </tabs>
</page>
```

**Tokens:**
- Card padding: `var(--space-6)`
- Section gap inside card: `var(--space-6)`
- Form row gap: `var(--space-4)`
- Footer actions: right-aligned, gap `var(--space-3)`

**A11y:**
- Tabs implement ARIA tabs pattern (arrow-key navigation between tabs)
- Form is `<form>` with explicit submit, not relying on button click only
- Each toggle has a paired `<label>` with descriptive text
- Save button shows confirmation (toast) on success

---

## Recipe 4 — Modal dialog (confirmation / form)

**When:** "Confirm action", "modal", "popup", "dialog"

**Tool sequence:**
```
get_component(name: "modal")
get_component(name: "button")
# If it's a form modal:
get_component(name: "input")
```

**Composition (confirmation):**
```
<modal>
  <header>                       → Title + close (×) button
  <body>                         → Message, optional icon
  <footer>                       → [Cancel] [Confirm/Destructive]
</modal>
```

**Composition (form modal):**
```
<modal size="md">
  <form>
    <header>                     → Title + close
    <body>                       → Inputs, grouped, with labels
    <footer>                     → [Cancel] [Submit]
  </form>
</modal>
```

**Tokens:**
- Modal width: sm=400px · md=560px · lg=720px
- Body padding: `var(--space-6)`
- Header/footer padding: `var(--space-4) var(--space-6)`
- Backdrop: `rgba(16, 24, 40, 0.6)` (use the DS modal CSS directly)

**A11y:**
- `<dialog>` element with `role="dialog"` and `aria-labelledby` pointing to title
- Focus traps inside modal while open
- ESC key closes; clicking backdrop closes (unless destructive)
- Focus returns to the trigger element on close
- For destructive confirmations, default focus on Cancel, not Confirm

---

## Recipe 5 — Empty state + first-run

**When:** "No data yet" view, "first-time user experience", "zero state"

**Tool sequence:**
```
get_component(name: "empty-state")
get_component(name: "button")
```

**Composition:**
```
<empty-state>
  <icon-illustration>            → Use DS icon at 64px, --text-secondary
  <h3>                          → "No projects yet" (or context-specific)
  <p>                           → One-sentence explanation
  <action-row>                  → [Primary CTA] [Secondary "Learn more"]
</empty-state>
```

**Tokens:**
- Container max-width: 480px
- Vertical centering in parent
- Gap between elements: `var(--space-3)` icon→title, `var(--space-2)` title→body, `var(--space-5)` body→actions

**A11y:**
- Decorative illustration: `aria-hidden="true"`
- Heading uses correct level for page context
- Primary CTA is `<button>` or `<a>` depending on whether it opens a flow or navigates

---

## Recipe 6 — Data table with toolbar

**When:** "List of records with filters and actions", "CRUD table", "users/orders/items list"

**Tool sequence:**
```
get_component(name: "data-table")
get_component(name: "input")        # search
get_component(name: "select")       # filter
get_component(name: "button")       # primary action + bulk actions
get_component(name: "pagination")
get_component(name: "badge")        # status cells
get_component(name: "dropdown")     # row actions
```

**Composition:**
```
<card>
  <toolbar>                      → [search input] [filter select] [filter select] [Primary CTA]
  <data-table>
    <thead>                      → Sortable headers, selection checkbox
    <tbody>                      → Rows, status badges in cells, row-action dropdown
  </data-table>
  <footer>                       → Pagination + selected-count + bulk actions
</card>
```

**Tokens:**
- Toolbar padding: `var(--space-4) var(--space-6)`
- Toolbar gap: `var(--space-3)`
- Table row min-height: 48px (md) or 56px (lg)
- Cell padding: `var(--space-3) var(--space-4)`

**A11y:**
- `<table>` with proper `<thead>`/`<tbody>` (no divs)
- Sort buttons in headers are `<button>` with `aria-sort`
- Row-action dropdowns are keyboard-navigable
- Selection checkboxes: header checkbox has `aria-label="Select all"`

---

## Recipe 7 — Stepper / wizard

**When:** "Multi-step form", "onboarding flow", "checkout"

**Tool sequence:**
```
get_component(name: "stepper")
get_component(name: "input")
get_component(name: "button")
```

**Composition:**
```
<page>
  <stepper>                      → Visual progress: step 2 of 4
  <card>
    <header>                     → Current step title + subtitle
    <body>                       → Form fields for this step
    <footer>                     → [Back] [Continue / Submit on last step]
  </card>
</page>
```

**Tokens:**
- Stepper container max-width: 720px
- Step gap: handled by component
- Card padding: `var(--space-6)`
- Footer: space-between, [Back] left, [Continue] right

**A11y:**
- Stepper indicates current step with `aria-current="step"`
- Form persists state across steps (don't reset on Back)
- Continue button is the form's submit
- Last step's submit clearly says what it does ("Place order", not "Continue")

---

## Recipe 8 — Pricing page

**When:** "Pricing", "plans comparison", "tiers"

**Tool sequence:**
```
get_component(name: "pricing-card")
get_component(name: "badge")        # "Most popular"
get_component(name: "button")
```

**Composition:**
```
<section>
  <section-header>               → "Pricing" headline, supporting copy
  <toggle-billing>               → Monthly / Yearly toggle (optional)
  <grid columns="3 or 4">
    <pricing-card>               → Per tier: name, price, features list, CTA
    <pricing-card recommended>   → Add "Most popular" badge, --brand outline
    <pricing-card>
  </grid>
  <comparison-table>             → Optional feature matrix below
</section>
```

**Tokens:**
- Card gap: `var(--space-4)` (sm screens) → `var(--space-6)` (md+)
- Featured tier offset (visual): elevate with `--shadow-lg` and `--brand` border
- Price text: `--text-2xl` for amount, `--text-sm` for period ("/ month")

**A11y:**
- Each tier is `<article>` with heading
- "Most popular" badge has screen-reader text ("Recommended plan")
- CTA buttons clearly distinguish tiers ("Choose Starter", not generic "Get started")

---

## Recipe 9 — Notification / activity feed

**When:** "Activity feed", "recent updates", "notifications panel"

**Tool sequence:**
```
get_component(name: "activity-feed")
get_component(name: "avatar")
get_component(name: "badge")
get_component(name: "notifications")  # if it's a notification dropdown
```

**Composition:**
```
<card>
  <header>                       → "Recent activity" + filter dropdown
  <activity-feed>
    <activity-item>              → Avatar + actor + action + time + optional content
    <activity-item>              → ...
  </activity-feed>
  <footer>                       → "View all" link
</card>
```

**Tokens:**
- Item padding: `var(--space-3) var(--space-4)`
- Item gap (avatar↔content): `var(--space-3)`
- Timestamp: `--text-sm`, `--text-secondary`

**A11y:**
- Each item is a `<li>` inside `<ul>`
- Time uses `<time datetime="ISO">`
- Avatar `alt` is the actor's name (or empty if name is already in text)

---

## Recipe 10 — Search with command palette

**When:** "Universal search", "Cmd+K", "command launcher"

**Tool sequence:**
```
get_component(name: "command-palette")
```

**Composition:**
```
<command-palette>                → Modal-positioned, --shadow-2xl
  <search-input>                 → Auto-focused on open
  <results-group>                → "Pages" / "Actions" / "Recent"
    <result-item>                → Icon + label + shortcut hint
  </results-group>
  <footer>                       → Keyboard hint legend
</command-palette>
```

**Tokens:**
- Trigger: `Cmd/Ctrl+K`
- Width: 640px (md screens) or full-bleed (sm)
- Top offset: `var(--space-8)` from viewport top
- Result item height: 44px

**A11y:**
- Combobox pattern: `role="combobox"` on input, `role="listbox"` on results
- Arrow keys navigate results, Enter selects, ESC closes
- Active result has `aria-selected="true"` and visible highlight
- Screen-reader announces result count

---

## Cross-cutting: when a recipe doesn't fit

If the user's task doesn't match any recipe, build from the catalogue using these compositional defaults:

1. **Page shell:** `<main>` with `var(--space-6)` padding on md+, `var(--space-4)` on sm.
2. **Section grouping:** Wrap related content in `mk-card`, with `var(--space-6)` padding and `var(--space-6)` vertical gap between sections.
3. **Form layout:** Stack fields vertically with `var(--space-4)` gap; label above input.
4. **Action rows:** Right-align primary actions with `var(--space-3)` gap; place destructive actions on the left or use a confirmation modal.
5. **Empty content:** Always include an empty state, not just an absence of content.

When you reach for a primitive (`<div>` with custom styles) instead of a component, pause and call `search` once more. The catalogue covers ~95% of common patterns.
