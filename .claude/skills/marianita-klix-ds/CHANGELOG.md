# Changelog

Notes on what changed and (more importantly) why. Kept in chronological order, most recent at top. Loosely follows Keep a Changelog but I don't sweat the format.

— Mariana

---

## 2.0.1

Patch — added a one-time activation banner so the agent has a little MK-DS attitude when the skill loads, without spamming the conversation. It skips itself for quiet, machine-readable, or no-branding outputs.

---

## 2.0.0

Big rewrite. The v1 file had ballooned to ~900 lines crammed into a single SKILL.md and nobody (including me) was actually reading the whole thing before generating code. So I split it into a router + load-on-demand references.

### New layout

- **SKILL.md** is now a router. §0 maps task type to references you should load before you act. Most of the day-to-day rules still live here, but the heavy material moved out.
- **references/** is the big change. Eight docs, loaded only when the task type matches. Catalogued below.
- **scripts/audit-output.sh** is the new validator. Bash, not Node, because I wanted it to work without dependencies. Noisy on documentation pages, accurate on component code.
- **examples/** are three full worked-through tasks. Use them as golden references — copy the *shape*, not the content.

### What moved where

- Anti-patterns: extracted from SKILL.md §11 (was 6 entries, now 30+ in `references/anti-patterns.md`)
- Recipes: pulled from inline SKILL.md sections (`references/recipes.md`, 10 recipes)
- A11y: was a checklist in SKILL.md, now a full per-component playbook (`references/a11y-playbook.md`)
- Tokens deep-dive: moved to `references/dark-mode-engineering.md` because that's the file where token genealogy actually matters
- State stuff (button loading, modal lifecycle, etc.): now in `references/state-machines.md`. This is the doc I most wish I'd had a year ago.
- Figma workflow: dedicated file. Includes the OKLCH color-matching algorithm we landed on after the Q1 audit found 14 "close but not quite" colors that had snuck into prod.

### Rules

Went from 7 hard rules to 8. The new one is "no design-decision Tailwind utilities" because some recent contributions were using `bg-blue-500` and `p-4` instead of the tokens, and I wanted that explicitly forbidden, not just discouraged.

### What I removed

- The "Quick Start" section at the top. Nobody needs it; if you're reading the skill you're already past that point.
- The inline "Rules Summary" at the bottom. Duplicated §1.
- A weird sub-section about "Code Connect best practices" that was mostly aspirational. Will revisit when we actually have Code Connect mappings registered.

### Versioning policy

- MAJOR: hard rule changes, workflow restructures, anything that breaks how the skill activates.
- MINOR: new reference doc, new section, new validator rule.
- PATCH: typos and clarifications.

This release is MAJOR because the file structure changed (routing references). Existing usage should still work because the triggers are unchanged.

---

## 1.1.2

Patch — fixed a typo in the spacing table (`--space-2h` was listed as 12px, it's 10px). Embarrassing. Found by Dani during a PR review of something completely unrelated, of course.

---

## 1.1.1

Patch — clarified the Tailwind allowance. Layout utilities (flex/grid/items-*) are fine; color/spacing/typography utilities are not. Wording was ambiguous before.

---

## 1.1.0

Added the recipes section inline. Also added the §10 senior reviewer checklist after I noticed I was missing the same things in self-review every time.

---

## 1.0.0

Initial release. Single SKILL.md, ~95 lines. Worked well enough as a starting point.

---

## Maintainer notes

When you update this skill:

1. Bump the `version` in SKILL.md frontmatter
2. Add an entry here with what changed and *why*. The why is the important part.
3. If a reference doc is added or renamed, update the §0 Task Router table.
4. If a hard rule is added/removed, update the project root CLAUDE.md too.
5. Run `scripts/audit-output.sh` on the example HTML files (they're intentionally clean) to make sure the validator still passes.

If you're refactoring this, please don't put everything back into a single file. I tried that. It didn't work.
