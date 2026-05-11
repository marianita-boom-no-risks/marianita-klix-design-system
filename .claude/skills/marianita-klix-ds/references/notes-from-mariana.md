# Field notes

Personal notes I keep while working with MK-DS. Less a reference doc and more a place where I dump things I've learned the hard way, opinions that haven't earned a place in the formal docs yet, and reminders to myself.

If you're not me, you can probably ignore this file. But it might be useful context if you're picking up where I left off.

— M.

---

## On `or-` → `mk-`

The CSS prefix used to be `or-`. Long story. We rebranded mid-2026 and I did a global rename. I think I caught all of them, but if you find a stray `or-something` class in the wild, that's a leftover and it should be `mk-something`.

The reason the prefix is two letters is that I wanted it short enough not to bloat HTML but distinct enough that it wouldn't accidentally collide with anything else (`btn`, `card`, etc.). Two letters felt right. Three is too many. One is too few.

## On the `mk-` prefix specifically

Honestly debated `klx-` for a hot minute. Glad I didn't. Two letters, easier to type, no consonant cluster.

## Why I split out `references/`

Earlier versions had everything in a single SKILL.md. I'd write a long file, ship it, then come back six weeks later and realize I (a) hadn't been reading half of it before generating code, and (b) was running out of context budget when the skill was big and the user's project was also big.

Splitting let me keep SKILL.md small (the part that always loads) and put the rest behind a router. Now SKILL.md is ~330 lines and the references only load when the task type matches.

Not perfect. There's still some duplication between SKILL.md §5 (tokens) and `dark-mode-engineering.md` §2 (token genealogy). I tell myself it's intentional repetition for the reader who only loads SKILL.md. We'll see.

## Anti-patterns I actually wrote myself

The "nested cards" example in `anti-patterns.md` §E1? That was me, in a settings page in late 2026. I had a card around a section, and inside that section another card around a sub-section. Looked terrible. PR comment was something like "what is happening here". Fixed it, then added it to the anti-pattern catalogue.

`<div onClick>` C1 was also me, in a button that needed a different border radius than the standard `mk-btn`. Should have just made a variant. Live and learn.

## On `aria-disabled` vs `disabled`

I keep getting this wrong, even after writing it down. Here's the thing I tell myself when reviewing my own code:

- If the user truly cannot click it (e.g., a submit button while a form is submitting), use the native `disabled` attribute.
- If the user *could* click it but you want to communicate "it's disabled, here's why", use `aria-disabled="true"` and intercept the click. Lets screen readers explain *why*.

Most of the time it's `disabled`. The `aria-disabled` pattern is for edge cases like "you can't submit yet because you haven't agreed to the terms — let me explain".

## On em dashes

I overuse them in writing. Trying to use parentheses and semicolons more. (See? Like this.)

## On TODO comments

I leave them in committed code as long as they have an owner and a rough timeframe. `// TODO(mariana): revisit after Q3` is fine. `// TODO: fix this` is not, because nobody is fixing that.

## On the `audit-output.sh` script

The script is bash because I wanted it to run anywhere without dependencies. I considered writing it in Node so it could parse CSS properly, but then I'd need `npm install` and a parser and suddenly the validator has its own bug surface. Bash with grep is dumber but more reliable.

Known false positives:
- Triggers on hex codes inside `<code>` blocks in documentation pages. Not a bug, but annoying.
- Doesn't understand CSS-in-JS template literals. If you're using styled-components or emotion, the audit is less useful.

I might rewrite this in Node eventually. Not soon.

## On the OKLCH color matching thing

The Figma workflow doc mentions matching colors via OKLCH ΔE distance. This was Dani's idea. Original problem: Figma exports raw hex, and we wanted to translate those to the nearest semantic or scale token, but "nearest" by RGB distance isn't perceptually accurate.

OKLCH ΔE gets us perceptual distance. We round to the nearest token if ΔE < 2 (within human-imperceptible range), flag to the user if ΔE is 2-5 ("close, but you should confirm"), and stop and ask if ΔE > 5.

This caught 14 close-but-not colors that had snuck into the codebase from earlier Figma → code conversions. Mostly background tints that were *almost* `--bg-secondary` but not quite. Fixing them was a satisfying afternoon.

## Things I haven't gotten around to writing

- A `references/forms-deep.md` with the full form-state machine, async validation, optimistic updates, etc. The forms recipe (Recipe 1) covers the basics but I want a deeper one.
- A `references/internationalization.md`. The DS handles RTL via `direction: rtl` on the root and most components respond correctly, but I haven't written it down.
- A `references/performance.md` with bundle size targets, CDN caching, etc. Will probably do this when we have actual scale problems.

## Opinions that aren't quite rules yet

- I think breadcrumbs are overused. If your nav structure is clear, the URL is meaningful, and the page has a good title, you probably don't need breadcrumbs. They take vertical space and they're rarely the way users navigate. Fight me on this one.
- The "spinner inside button" pattern is fine for short async actions (< 2s) but feels wrong for anything longer. For longer actions, use a progress bar or a transition to a "we're working on it" state.
- I don't love the `--text-xs` token. 10px is too small for almost anything. It's there for captions and overlines, but in practice I'd rather use `--text-sm` (12px) even for those. Considering deprecating in v3.

## Stuff that bit me

- Forgetting to set `tabindex="-1"` on `<main>` for SPAs. Screen reader users get confused when navigation doesn't move focus.
- Animating `max-height` on accordions and not realizing it tanks performance with long content. Better to compute the exact height in JS.
- Trusting that `prefers-reduced-motion` was being respected without checking. Some component transitions were missing the wrap. Fixed in 1.1.0.
