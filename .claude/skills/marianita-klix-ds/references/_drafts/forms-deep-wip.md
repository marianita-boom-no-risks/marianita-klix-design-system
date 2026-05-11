# Forms — Deep Dive (WIP)

> Status: rough draft, not linked from SKILL.md yet. Don't load this in production tasks; it's incomplete.
> — M, 2026-05-04

This is going to be the long-form forms doc. The recipes file (Recipe 1) covers the auth-form basics, but forms have a *lot* more going on once you get into:

- Multi-step / wizard forms (some of which is in `state-machines.md` §8 already)
- ~~Optimistic UI updates~~ (moved to performance.md when I write it)
- Async validation with debounce
- Field-level vs form-level error patterns
- ~~Server-driven forms (JSON schema → render)~~ (out of scope for v2)
- File uploads
- Conditional fields ("show X only if Y is checked")
- Saving drafts / auto-save

## Outline (rough)

1. The state machine — link to `state-machines.md` §10, expand here for forms specifically
2. Validation strategies
   - Sync validation (per-field on blur)
   - Async validation (with debounce — settled on 400ms after some testing, feels right)
   - Form-level validation (cross-field, e.g., "password and confirm must match")
3. Error display patterns
   - Inline error per field
   - ~~Top-of-form summary~~ wait, did I cover this in a11y-playbook? Need to check before duplicating.
4. Submit states
   - idle → submitting → success / error
   - What to disable while submitting
   - Where to focus on success / error
5. ~~Optimistic updates~~ — pushed to later
6. ~~Server-driven forms~~ — explicitly out of scope
7. File uploads
   - Multi-file
   - Drag-drop
   - Progress
   - Cancel
8. Conditional fields
   - "Show shipping address if billing differs"
   - Animating reveal — link to motion.md
9. Saving drafts
   - localStorage strategy
   - Server-side draft API (if applicable)

## Open questions

- Should I document the "save and continue later" pattern here or in recipes? It's narrow enough to be a recipe but specific enough to feel like a forms-deep thing.
- Async validation with multiple in-flight requests — do I document the "ignore stale" pattern? Probably yes.
- ~~React Hook Form integration~~ — maybe. The skill is framework-agnostic so this would be a sidebar at most.

## Notes from when I tried writing this last week

The hard part of "deep" forms doc is that every project does forms slightly differently. The DS components are consistent, but the *form flow* is usually project-specific. I keep wanting to write rules but they end up being suggestions.

Maybe the right structure is:
- "Here are the components and their state contracts" (objective)
- "Here are common form flows with examples" (recipe-flavored)
- "Here are the patterns and anti-patterns" (opinionated)

Three sections. Will draft once I have a couple more hours.

---

## ~~Things to delete from this draft before publishing~~

- This "Open questions" section
- The "Notes from when I tried" section
- ~~This last-stage "delete" reminder list~~ (kept for now, ironic)

---

## TODO

- [ ] Finish §2 (validation strategies)
- [ ] Get screenshots for §3 (errors)
- [ ] Decide on conditional-fields approach
- [ ] Link from SKILL.md §0 once done
- [ ] Update CHANGELOG when shipping
