# Component State Machines

Every interactive component is implicitly a state machine. I find that treating it explicitly (instead of "default plus a few modifiers") catches a class of bugs that "vibes-based" implementations always miss: impossible states, transitions you forgot, focus traps that leak when the trigger element gets removed, race conditions in async submit flows.

This doc enumerates the state machine for each interactive component: the CSS classes per state, the keyboard and pointer transitions, the ARIA attributes that need to stay in sync.

This is the doc I most wish I'd had a year ago. Building it forced me to actually answer questions like "what's the toast state when it's queued but no slot is available", which I'd been hand-waving in implementation.

> Read this when building loading buttons, modal lifecycles, toast queues, async forms, or anything where state correctness matters more than visual fidelity.

---

## 1. Button

### States

```
idle ──hover──> hover ──mousedown──> pressed ──mouseup──> hover
  │                                                          
  ├──focus──> focused                                         
  │                                                          
  ├──disabled set──> disabled (terminal until disabled unset)
  │                                                          
  └──aria-busy set──> loading ──complete──> idle
```

### CSS classes per state

| State | Class | Notes |
|-------|-------|-------|
| Idle | `mk-btn mk-btn--<variant> mk-btn--<size>` | Base |
| Hover | (CSS `:hover` selector) | No class needed |
| Pressed | (CSS `:active`) | No class needed |
| Focused | (CSS `:focus-visible`) | Standard MK-DS focus ring |
| Disabled | `[disabled]` attribute or `aria-disabled="true"` | Don't use opacity alone |
| Loading | `mk-btn--loading` + `aria-busy="true"` | Show spinner; keep text or replace |

### Rules

- **`disabled` vs `aria-disabled`**: use the native `disabled` attribute when the button truly can't be clicked. Use `aria-disabled="true"` (and intercept click) when you want screen-readers to know it's disabled but allow focus (e.g., to explain *why*).
- **Loading** state must preserve width — measure idle width, pin it during load, restore on completion. Otherwise the page jumps.
- **Pressed** state should provide visible feedback within 100ms (CSS `:active` handles this).
- **Async actions** must transition idle → loading → (success | error) → idle. Skipping intermediate states = silent failure.

### Anti-patterns

- ❌ Button toggles between two states using only color (no label change) → users with color blindness miss it.
- ❌ `opacity: 0.5` as the only disabled signal → fails contrast.
- ❌ Loading state replaces button with spinner that loses click target.

---

## 2. Toggle

### States

```
off ──click/space──> on
on  ──click/space──> off
(focused in either state)
```

### ARIA

```html
<button class="mk-toggle"
        role="switch"
        aria-checked="false"
        aria-labelledby="toggle-label-id">
  <span class="mk-toggle__thumb"></span>
</button>
<span id="toggle-label-id">Email notifications</span>
```

### Rules

- `aria-checked` is the source of truth. Update it on every toggle.
- The toggle MUST be reachable by `Tab`. `Space` toggles it.
- The label MUST be associated via `aria-labelledby` or wrap the toggle inside a `<label>`.
- Don't use `<input type="checkbox">` styled as a toggle — `role="switch"` is semantically distinct from `checkbox`.

---

## 3. Modal / Dialog

### Lifecycle

```
closed ──open()──> opening ──animation end──> open
open   ──ESC/backdrop/close button──> closing ──animation end──> closed
```

### Rules during `open`

1. **Body scroll locked**: `document.body.style.overflow = 'hidden'`.
2. **Focus trapped**: First focusable element receives focus on open; Tab cycles within modal.
3. **Initial focus**:
   - Form modal: first input
   - Confirmation: Cancel button (not destructive Confirm)
   - Info modal: close button
4. **ESC closes** (unless destructive confirmation, where ESC = cancel)
5. **Backdrop click closes** (configurable)
6. **`aria-hidden="true"` on background content** so screen-readers ignore it
7. **Focus returns to trigger** on close

### CSS classes

| State | Class on `<dialog>` |
|-------|---------------------|
| Closed | (element absent from DOM, or `display: none`) |
| Opening | `mk-modal mk-modal--opening` |
| Open | `mk-modal mk-modal--open` |
| Closing | `mk-modal mk-modal--closing` |

### Animation

- Opening: 200ms `--easing-out`
- Closing: 150ms `--easing-in`
- Disable both under `prefers-reduced-motion`

---

## 4. Toast

### Single toast lifecycle

```
queued ──slot available──> entering ──animation end──> visible
visible ──timer expires / dismiss──> leaving ──animation end──> removed
```

### Queue behavior

- Max simultaneous toasts: 3 (configurable)
- Beyond max → new toasts wait in queue
- Toast positions: top-right (default), top-center, bottom-right, bottom-center
- **Pause timer on hover/focus** — users with motor delays need this

### Variants

| Variant | When |
|---------|------|
| `mk-toast--info` | Neutral confirmations |
| `mk-toast--success` | Action completed |
| `mk-toast--warning` | User attention needed, non-blocking |
| `mk-toast--error` | Action failed |

### ARIA

```html
<div class="mk-toast-region" aria-live="polite" aria-atomic="false">
  <!-- toasts inserted here -->
</div>
```

- **`aria-live="polite"`** for info/success/warning
- **`aria-live="assertive"`** for error (interrupts screen-reader)
- **`role="alert"`** on each toast for screen-reader announcement

---

## 5. Input — async validation flow

### States

```
empty ──user types──> typing
typing ──blur or debounce────> validating (if async)
validating ──response──> valid | invalid
valid ──user types──> typing
invalid ──user types──> typing  (clear error immediately on edit)
```

### CSS classes

| State | Class |
|-------|-------|
| Default | `mk-input` |
| Focused | (CSS `:focus-visible`) |
| Valid | `mk-input mk-input--valid` (optional — green border) |
| Invalid | `mk-input mk-input--error` |
| Disabled | `[disabled]` |
| Read-only | `[readonly]` |

### ARIA

```html
<div class="mk-field">
  <label for="email" class="mk-label">Email</label>
  <input id="email" class="mk-input mk-input--error"
         aria-invalid="true"
         aria-describedby="email-error" />
  <p id="email-error" class="mk-field__error">Please enter a valid email.</p>
</div>
```

- Error message MUST be linked via `aria-describedby`
- `aria-invalid="true"` ONLY when an error is currently shown
- Clear `aria-invalid` and error message as soon as the user starts editing

---

## 6. Dropdown / Combobox

### States

```
closed ──click/down-arrow──> open
open   ──ESC/click-outside/select──> closed
open + typing (combobox) ──filter────> open with filtered list
```

### Keyboard map

| Key | Behavior |
|-----|----------|
| `↓` | Open (if closed) OR move to next item |
| `↑` | Move to previous item |
| `Home` | First item |
| `End` | Last item |
| `Enter` | Select current item |
| `ESC` | Close, return focus to trigger |
| `Tab` | Close, move focus to next page element |
| `<letter>` | Jump to next item starting with that letter (in select mode) |

### ARIA

```html
<button class="mk-dropdown__trigger"
        aria-haspopup="listbox"
        aria-expanded="false"
        aria-controls="menu-id">
  Select an option
</button>
<ul id="menu-id" class="mk-dropdown__menu" role="listbox" hidden>
  <li role="option" aria-selected="false">Option 1</li>
</ul>
```

`aria-expanded` MUST toggle to `"true"` when open.

---

## 7. Tabs

### States per tab

```
unselected ──click/keyboard──> selected
selected (in panel)
disabled (terminal)
```

### Keyboard map

| Key | Behavior |
|-----|----------|
| `Tab` | Move into tablist (focuses selected tab) |
| `←` / `→` | Move between tabs (Roving tabindex) |
| `Home` | First tab |
| `End` | Last tab |
| `Enter` / `Space` | Activate focused tab (if `aria-activation="manual"`) |

### ARIA

```html
<div class="mk-tabs">
  <div role="tablist" aria-label="Settings sections">
    <button role="tab"
            aria-selected="true"
            aria-controls="panel-1"
            id="tab-1"
            tabindex="0">Profile</button>
    <button role="tab"
            aria-selected="false"
            aria-controls="panel-2"
            id="tab-2"
            tabindex="-1">Account</button>
  </div>
  <div role="tabpanel" id="panel-1" aria-labelledby="tab-1">…</div>
  <div role="tabpanel" id="panel-2" aria-labelledby="tab-2" hidden>…</div>
</div>
```

**Roving tabindex** — only the selected tab is `tabindex="0"`; others are `tabindex="-1"`.

---

## 8. Stepper / Wizard

### States per step

```
upcoming (not yet reached)
current  ──complete──> completed ──user clicks back──> current
completed ──user clicks──> current (revisit)
error    (validation failed)
```

### Rules

- User can revisit `completed` steps (data persists)
- User CANNOT skip ahead to `upcoming` steps
- `error` state on a step that was previously `completed` (e.g., async submit fails) must surface visibly
- The current step has `aria-current="step"`

---

## 9. Accordion

### States per panel

```
collapsed ──click trigger──> expanding ──animation end──> expanded
expanded  ──click trigger──> collapsing ──animation end──> collapsed
```

### Rules

- Single-expand mode vs multi-expand mode is a config — default to multi-expand
- Trigger is `<button aria-expanded="false">`
- Panel has `role="region"` and `aria-labelledby` pointing to trigger
- Use `<details>`/`<summary>` if no animation needed (free a11y)

---

## 10. Form (whole-form state machine)

### States

```
pristine ──user edits──> dirty
dirty    ──submit──> validating ──pass──> submitting ──response──> success | error
validating ──fail──> dirty (errors shown)
submitting ──network error──> error
success  ──new edit──> dirty
error    ──new edit──> dirty (errors clear progressively)
```

### Rules

- **Submit button is disabled in `validating` and `submitting`** (or shows loading state)
- **Validation runs on blur** (per field) AND on submit (full form)
- **Errors appear at the field level AND in a summary at the top** for screen-readers
- **Successful submit** clears the form OR navigates away (don't leave the user in an ambiguous state)
- **Network errors** preserve the user's input (never wipe a form on error)

---

## Mental model

Every interactive component is a finite state machine. If your code can't answer:
- What states exist?
- What transitions are valid?
- What's the ARIA attribute for each state?
- What keyboard input triggers each transition?

…then the component is incomplete. Re-read the relevant section above before shipping.

For the cross-cutting concerns (focus management, ARIA live regions, keyboard order), see `references/a11y-playbook.md`.
