# Motion System

Motion in MK-DS communicates state changes, draws the eye to changes, and provides spatial continuity. It's never decorative. (Or it shouldn't be. If it is, that's a bug, not a feature.)

Every animation has a purpose, a duration token, an easing token, and a reduced-motion fallback. If any of those is missing, the animation isn't done.

> Read this when adding transitions, page animations, micro-interactions, or auditing motion.

---

## 1. The four motion principles

1. **Purposeful** — every animation answers "what did just happen / what's about to happen?"
2. **Fast enough to disappear** — most micro-interactions live in 150–250ms. Anything > 400ms needs justification.
3. **Eased, never linear** — linear easing feels mechanical. Use `--easing-*` tokens.
4. **Respectful** — `prefers-reduced-motion` reduces or removes; never overrides the user.

---

## 2. Duration tokens

| Token | ms | Use for |
|-------|----|---------|
| `--duration-instant` | 75 | State swaps with no visible motion (active press, hover color) |
| `--duration-fast` | 150 | Micro-interactions (toggle thumb, tooltip in) |
| `--duration-base` | 200 | Default for most transitions (button hover, accordion expand) |
| `--duration-slow` | 300 | Modal open, drawer slide, longer reveals |
| `--duration-slower` | 500 | Page transitions, multi-step animations |

Anything > 500ms needs explicit reason (e.g., loading shimmer that loops indefinitely).

---

## 3. Easing tokens

| Token | Curve | Use for |
|-------|-------|---------|
| `--easing-linear` | `linear` | Loops (spinners, shimmers) only |
| `--easing-in` | `cubic-bezier(0.4, 0, 1, 1)` | Element leaving (exit) |
| `--easing-out` | `cubic-bezier(0, 0, 0.2, 1)` | Element entering (enter) |
| `--easing-in-out` | `cubic-bezier(0.4, 0, 0.2, 1)` | Element moving (state change in-place) |
| `--easing-bounce` | `cubic-bezier(0.34, 1.56, 0.64, 1)` | Playful entrances (sparingly) |

**Mental model**: things appearing use `--easing-out` (slow at the end, lands gently). Things disappearing use `--easing-in` (fast at the end, snaps away). Things changing in place use `--easing-in-out`.

---

## 4. Standard transitions (by intent)

### Hover

```css
.mk-btn {
  transition:
    background var(--duration-fast) var(--easing-out),
    border-color var(--duration-fast) var(--easing-out);
}
```

Hover transitions should never delay the *response* — only the *recovery*. Apply state instantly; ease the return.

### Toggle thumb

```css
.mk-toggle__thumb {
  transition: transform var(--duration-fast) var(--easing-in-out);
}
```

### Accordion expand/collapse

```css
.mk-accordion__panel {
  transition:
    max-height var(--duration-base) var(--easing-in-out),
    opacity var(--duration-base) var(--easing-out);
}
```

Note: animating `max-height` is the standard for unknown-height content. Use `height` if you can compute it.

### Modal open

```css
.mk-modal {
  opacity: 0;
  transform: translateY(8px) scale(0.98);
  transition:
    opacity var(--duration-slow) var(--easing-out),
    transform var(--duration-slow) var(--easing-out);
}
.mk-modal--open {
  opacity: 1;
  transform: translateY(0) scale(1);
}
```

### Drawer slide

```css
.mk-drawer {
  transform: translateX(100%);
  transition: transform var(--duration-slow) var(--easing-out);
}
.mk-drawer--open {
  transform: translateX(0);
}
```

### Toast entrance

```css
.mk-toast {
  transform: translateY(-100%);
  opacity: 0;
  transition:
    transform var(--duration-base) var(--easing-out),
    opacity var(--duration-base) var(--easing-out);
}
.mk-toast--visible {
  transform: translateY(0);
  opacity: 1;
}
```

---

## 5. Loading and skeleton

### Spinner

```css
.mk-spinner {
  animation: mk-spin 1s linear infinite;
}
@keyframes mk-spin {
  to { transform: rotate(360deg); }
}
```

Spinners use `linear` because they're continuous. Don't add easing to a continuous rotation.

### Skeleton shimmer

```css
.mk-skeleton {
  background: linear-gradient(
    90deg,
    var(--bg-tertiary) 0%,
    var(--bg-secondary) 50%,
    var(--bg-tertiary) 100%
  );
  background-size: 200% 100%;
  animation: mk-skeleton-shimmer 1.6s ease-in-out infinite;
}
@keyframes mk-skeleton-shimmer {
  0%   { background-position: 200% 0; }
  100% { background-position: -200% 0; }
}
```

### Indeterminate progress

```css
.mk-progress--indeterminate .mk-progress__bar {
  width: 40%;
  animation: mk-progress-indeterminate 1.5s ease-in-out infinite;
}
@keyframes mk-progress-indeterminate {
  0%   { transform: translateX(-100%); }
  100% { transform: translateX(250%); }
}
```

---

## 6. Reduced motion — non-negotiable

Wrap every non-essential animation:

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

This blanket rule covers most cases. For animations that need a different reduced-motion fallback (not just "instant"):

```css
.mk-modal {
  transition: opacity var(--duration-slow) var(--easing-out);
}

@media (prefers-reduced-motion: reduce) {
  .mk-modal {
    transition: opacity var(--duration-fast) linear;
    /* Keep a tiny fade so the change is perceptible, but skip the transform */
    transform: none;
  }
}
```

### Things you MUST disable under reduced motion

- Auto-playing carousels
- Parallax scrolling
- Background videos
- Particle effects
- Animated illustrations
- Page transition slides
- Bouncy easings (`--easing-bounce`)

### Things you can KEEP under reduced motion

- Color transitions (subtle, no spatial motion)
- Opacity fades
- Instant state swaps (≤ 75ms)
- Loading indicators (essential for feedback)

---

## 7. Stagger and choreography

When multiple elements enter at once (e.g., a list of cards), stagger them:

```css
.mk-card {
  opacity: 0;
  transform: translateY(8px);
  animation: mk-card-enter var(--duration-base) var(--easing-out) forwards;
}
.mk-card:nth-child(1) { animation-delay: 0ms; }
.mk-card:nth-child(2) { animation-delay: 50ms; }
.mk-card:nth-child(3) { animation-delay: 100ms; }
.mk-card:nth-child(4) { animation-delay: 150ms; }
/* … */

@keyframes mk-card-enter {
  to {
    opacity: 1;
    transform: translateY(0);
  }
}
```

Stagger increments: 50ms is standard. Don't exceed 80ms between siblings or the cascade feels slow.

Stagger MUST be disabled under reduced motion:

```css
@media (prefers-reduced-motion: reduce) {
  .mk-card { animation: none; opacity: 1; transform: none; }
}
```

---

## 8. Scroll-driven animation

Use `IntersectionObserver`, not scroll event listeners:

```js
const observer = new IntersectionObserver(entries => {
  entries.forEach(entry => {
    if (entry.isIntersecting) {
      entry.target.classList.add('mk-revealed');
    }
  });
}, { threshold: 0.1 });

document.querySelectorAll('[data-reveal]').forEach(el => observer.observe(el));
```

```css
[data-reveal] {
  opacity: 0;
  transform: translateY(16px);
  transition:
    opacity var(--duration-slower) var(--easing-out),
    transform var(--duration-slower) var(--easing-out);
}
.mk-revealed {
  opacity: 1;
  transform: translateY(0);
}
@media (prefers-reduced-motion: reduce) {
  [data-reveal] { opacity: 1; transform: none; transition: none; }
}
```

For ScrollTrigger / scroll-linked animations, defer to GSAP (the `gsap-scrolltrigger` skill) — MK-DS does not include a scroll-animation runtime.

---

## 9. Anti-patterns

| Anti-pattern | Why bad | Fix |
|--------------|---------|-----|
| Linear easing on a non-loop animation | Mechanical, feels cheap | Use `--easing-out` for enter, `--easing-in` for exit |
| Animation > 500ms with no purpose | User waits for nothing | Drop to ≤ 300ms or remove |
| No reduced-motion fallback | Accessibility violation | Wrap in `@media (prefers-reduced-motion: reduce)` |
| Bounce easing on critical actions (delete, save) | Looks silly, undermines trust | Reserve `--easing-bounce` for playful, non-critical entrances |
| Animating layout properties (`width`, `height`, `top`) | Triggers reflow, jank | Animate `transform` and `opacity` instead |
| Forgetting to set `animation-fill-mode: forwards` | Element snaps back at end | Add `forwards` to keep end state |
| Hover transition delays the state, not the recovery | Feels sluggish | Apply state instantly, ease the return only |

---

## 10. Performance checklist

- [ ] Only `transform` and `opacity` are animated (no `width`/`height`/`top`/`left`)
- [ ] `will-change` used sparingly (only on elements about to animate)
- [ ] No `animation` running on `body` or layout roots
- [ ] Animations pause when off-screen (use IntersectionObserver to add/remove animation class)
- [ ] No more than 3 simultaneous large animations (modal + toast + page transition = too much)
- [ ] Heavy keyframes (filters, blurs) used sparingly
