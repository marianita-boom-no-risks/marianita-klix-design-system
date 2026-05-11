# Marianita Klix Design System

A UI kit I (Mariana K.) built and use across my projects. 61 components, design tokens, multi-framework code generation (HTML, React, Vue, Svelte), an MCP server so AI assistants can pull from it directly, and a Claude skill that drives the MCP correctly.

No build step. Static HTML + Tailwind from a CDN + Inter from Google Fonts. Drop into any project.

## What's in here

```
.
├── *.html                # Interactive documentation pages
├── tokens.json           # Tokens Studio v2 format (Figma import)
├── mcp/                  # The MCP server (Node, stdio) — 7 tools
├── .claude/
│   ├── settings.json     # Pre-wired for Claude Code
│   └── skills/
│       └── marianita-klix-ds/
│           └── SKILL.md  # The skill — see CHANGELOG for what it does
├── CLAUDE.md             # Rules I want any AI assistant to follow
└── docs/                 # Internal specs and plans
```

## Three ways to use it

### 1. As a static design system

Open `index.html` in a browser. Copy/paste components. Import `tokens.json` into Figma via Tokens Studio. Done.

### 2. As an MCP server

If you're using Claude Code, Cursor, Windsurf, Zed, or any stdio-MCP client, point it at `mcp/index.js`. The server exposes 7 tools that return tokens, component code in your framework, page templates, and guidelines.

```bash
cd mcp
npm install
```

For Claude Code, the `.claude/settings.json` already points to the absolute path. Adjust if you cloned somewhere else.

### 3. As a Claude skill + MCP combo (this is the good one)

The skill at `.claude/skills/marianita-klix-ds/SKILL.md` teaches Claude how and when to call the MCP tools, what order to use them in, and what rules to enforce. It activates automatically on UI tasks once installed.

To make the skill available across all your Claude Code projects:

```bash
# Symlink (recommended — picks up updates here)
ln -s "$(pwd)/.claude/skills/marianita-klix-ds" ~/.claude/skills/marianita-klix-ds

# Or copy if you'd rather have a frozen snapshot
cp -R .claude/skills/marianita-klix-ds ~/.claude/skills/
```

If you open this repo directly in Claude Code, the project-local `.claude/skills/` is picked up automatically. No symlink needed.

## MCP tools, at a glance

| Tool | What it gives you |
|------|-------------------|
| `get_css_setup` | Full base CSS for a new project. Tokens, dark mode, base styles. |
| `list_components` | All 61 components, grouped by category. |
| `search` | Fuzzy search across components, tokens, guidelines. |
| `get_component` | Component spec + code in HTML / React / Vue / Svelte. |
| `get_tokens` | Tokens in CSS / SCSS / JSON / Tailwind. |
| `get_guidelines` | Usage rules per topic (spacing, a11y, dark mode, etc.). |
| `get_page_template` | Pre-built page composition (dashboard, settings, login, etc.). |

Full reference and example prompts: [`mcp/README.md`](mcp/README.md).

## Quick start with Claude Code

```bash
git clone https://github.com/marianita-boom-no-risks/marianita-klix-design-system.git
cd marianita-klix-design-system
cd mcp && npm install && cd ..
```

Open in Claude Code. Ask something like:

> "Build me a settings page using MK-DS."

Claude activates the skill, calls `get_css_setup`, then `get_page_template`, then `get_component` per slug, then composes the output using only registered components and tokens.

## What the skill does (1-paragraph version)

`SKILL.md` is a router. It looks at what you're asking for, loads the relevant reference docs (state machines, a11y playbook, Figma workflow, dark mode, motion, anti-patterns, migration, recipes, worked examples), and tells Claude: here's the order of operations, here are the hard rules, here's the bar for "done". It exists because giving Claude a giant rulebook didn't work as well as giving it a small router plus on-demand context.

See `.claude/skills/marianita-klix-ds/CHANGELOG.md` for what changed in each version.

## Design principles

These are the things I refuse to compromise on:

1. **No invented values.** Every color, spacing, radius, shadow is a token. No exceptions.
2. **Dark mode is first-class.** Toggle `html.dark`, semantic tokens auto-swap. Don't paint yourself into corners with primitives.
3. **`mk-` prefix everywhere.** No bare class names. No Tailwind utilities for design decisions.
4. **Accessibility is mandatory.** WCAG 2.1 AA at minimum. Semantic HTML, visible focus, keyboard reachable, `prefers-reduced-motion` respected.
5. **No build step on the DS itself.** It has to work on a static host with one HTML file. If your app needs a build step, that's fine, but the DS doesn't.

## License

MIT. Use it, fork it, rip it apart. If you find a bug or want a component added, the registry lives at `mcp/registry.json` and I welcome PRs.

— Mariana
