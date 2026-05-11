# Contributing

Glad you're here. Quick guide to working on MK-DS.

## What I'm looking for

- **Component additions** — if there's a common pattern that isn't in the registry, open an issue first to discuss. Adding to `mcp/registry.json` is straightforward; making sure the design is coherent with the rest of the DS takes a conversation.
- **Bug fixes** — yes please. Especially in the audit script, the MCP server, or any of the HTML pages.
- **Reference doc improvements** — typos, clarifications, additional anti-patterns from your own experience. The whole `.claude/skills/marianita-klix-ds/references/` is meant to grow.
- **Real-world example PRs** — if you build something with MK-DS and want it featured, that's great. We need more golden examples.

## What I'm not looking for

- Drive-by refactors of working code. If you want to restructure something significantly, open an issue first.
- New brand colors or "alternative themes". MK-DS is opinionated about its palette.
- Tooling additions that introduce a build step on the DS itself. The DS stays static.

## How to propose a change

1. Open an issue describing the problem or proposal. For small fixes (typos, obvious bugs) you can skip this.
2. Fork the repo, branch from `main`.
3. Make your change. Keep commits small and meaningful.
4. Run the audit script on any new/changed component code: `./.claude/skills/marianita-klix-ds/scripts/audit-output.sh <your-file>`
5. If you touched a `.html` doc page, verify both light and dark mode.
6. Open a PR with a clear description. Link the issue.

## Style guide for prose

- Voice: direct, slightly informal, opinionated where appropriate.
- Em dashes: use sparingly. Commas and parentheses are usually clearer.
- Markdown: ATX headings (`#`, `##`), fenced code blocks with language tags, tables where they help, prose where they don't.
- No emojis in technical docs.

## Code style

- HTML: semantic tags, lowercase, double-quoted attributes.
- CSS: lowercase, kebab-case class names with the `mk-` prefix, custom properties on `:root` and `html.dark` only.
- JS: ESM (`type: module`), no semicolons in MCP code (the server is intentionally permissive about this), 2-space indent.
- Bash: ShellCheck-clean ideally, but I don't run it in CI yet.

## Reviewing

I try to review within a few days. If I miss something, ping me. Expect questions about edge cases — I'd rather ask now than after merge.

## Code of conduct

Be decent. If you're not, I'll close the PR and walk away.

— Mariana
