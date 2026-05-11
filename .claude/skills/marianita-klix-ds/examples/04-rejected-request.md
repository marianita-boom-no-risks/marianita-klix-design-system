# Worked Example 04 — When the answer is "no"

The other examples show what success looks like. This one shows what happens when the user asks for something MK-DS doesn't (and shouldn't) do. Saying no — and saying it well — is part of the skill.

---

## User request

> Build me a carousel component. Auto-rotating hero images, dots indicator below, swipe support on mobile, lazy-loaded images, and a fade transition between slides. Use MK-DS so it matches the rest of my site.

---

## Phase 1 — Routing

The request maps to "build a component". §0 router says: read `SKILL.md`, then `get_component` for the component.

But there's a complication. Before I call `get_component(name: "carousel")`, I should check whether `carousel` is in the registry. If not, I'm being asked to fabricate something, which §1.7 prohibits.

---

## Phase 2 — Discovery

```
search(query: "carousel")
```

Response: no matches.

```
search(query: "image slider")
search(query: "rotating images")
list_components(category: "Content")
list_components(category: "Layout")
```

Closest components I find:

- `image-gallery` — grid of images, lightbox on click, no autoplay
- `card` — could compose a "featured image" card but it's static

Neither is an auto-rotating carousel. There's no registered slug for what the user is asking for.

---

## Phase 3 — Surface the gap, don't fabricate

This is the moment. The wrong move is:

❌ "Sure, here's a carousel" *(then invents `mk-carousel` and writes CSS that doesn't exist in the DS)*

❌ "Let me use `mk-image-gallery` with some custom JS to make it auto-rotate" *(this is still mostly fabrication, and it confuses readers about what `image-gallery` does)*

❌ "Carousels aren't recommended for accessibility reasons, so I'll build a static grid instead" *(this is a lecture and assumes the user doesn't know the trade-offs)*

The right move is to surface the gap and offer real choices.

---

## Phase 4 — The response

> **The carousel isn't in MK-DS.** I checked: no `carousel` slug, no `slider`, nothing autorotating. The closest existing component is `image-gallery` (grid of images with lightbox), which probably isn't what you want.
>
> Here are your real options:
>
> **A. Use `image-gallery` instead.** Suitable if the hero needs to show multiple images but doesn't *have* to rotate. Static, accessible, performance-cheap. I can build this in a minute.
>
> **B. Build a one-off carousel using MK-DS primitives.** I can compose a custom component with:
>   - Layout via `<div>` with MK-DS spacing tokens
>   - Buttons (prev/next) using `mk-btn mk-btn--icon`
>   - Dots indicator using `mk-pills` or custom dots
>   - JS for the rotation
>
>   This is honest about being a one-off — I'd write the CSS using `var(--*)` tokens so it stays consistent. Not registered in the DS, so other parts of your team won't get the same component automatically.
>
> **C. Register a `carousel` in MK-DS.** This is the cleanest long-term answer if carousels are likely to appear elsewhere in your product. Requires a design pass (Dani would want to weigh in on what variants/sizes/states a carousel should have), then we add it to `mcp/registry.json` with proper a11y patterns. Could take a few days. Worth it if this is a recurring pattern.
>
> **One thing to flag regardless of which option you pick:** carousels are tricky for accessibility. WCAG 2.2.2 requires that auto-rotating content can be paused, stopped, or hidden by the user. If we build one (option B or C), it needs a visible pause control, keyboard navigation between slides, and respect for `prefers-reduced-motion` (which should disable autoplay entirely). Not blocking; just adding a few hours to the implementation.
>
> Which way do you want to go?

---

## Why this is the right shape

1. **Honest about the registry.** I didn't invent `mk-carousel`. The user can trust that anything I call `mk-something` actually exists.
2. **Real options, not a refusal.** "It's not in the DS" is half an answer. "It's not in the DS — here are three ways forward" is the full answer.
3. **Trade-offs surfaced upfront.** Option B is faster but creates a one-off. Option C is slower but properly registers the pattern. The user gets to make the call with the right information.
4. **A11y constraint flagged.** Not as a lecture. As a thing to know before committing to a path.
5. **No filler.** No "great question!", no "I'd be happy to help". Just the analysis and the options.

---

## What this looks like in different rejected requests

The same shape applies to:

- "Add a custom brand color." → "MK-DS has a fixed palette. Three options: use existing semantic tokens, register a new token via the theme-builder, or apply a one-off inline style with a comment marking the deviation."
- "Use Material UI for this page." → "Mixing MK-DS and MUI means two type systems and two color systems on the same page. Three options: rebuild this in MK-DS, isolate the MUI page with its own root, or migrate the whole project to one of them."
- "Make the button rotate forever." → "MK-DS has spinners for loading state. If you want decorative rotation, that's a request to register a new variant or to add a one-off. Loading rotation already exists at `mk-btn--loading`."

The pattern: name the constraint, offer 2-3 concrete options, surface non-obvious trade-offs, ask for the decision.

---

## What this is NOT

- ❌ A refusal masked as helpfulness ("I could build a carousel but won't")
- ❌ A lecture about why carousels are bad
- ❌ Fabricating a component and hoping no one notices
- ❌ Endless options without recommending one (if the situation has a clear best answer, say so)

---

## The senior reviewer take

A senior frontend lead reviewing this exchange would say: "Good. You didn't invent. You didn't lecture. You offered real choices and surfaced a real constraint. This is what disciplined design-system work looks like."

That's the bar. Disciplined design-system work.
