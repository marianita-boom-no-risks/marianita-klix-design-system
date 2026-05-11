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
./install.sh
```

`install.sh` installs the MCP dependencies and symlinks the skill into `~/.claude/skills/`. Run `./install.sh --check` to see status; `./install.sh --uninstall` to remove the symlink later.

Then wire the MCP into your AI client (the install script prints the JSON snippet at the end).

Open Claude Code in any project and ask:

> "Build me a settings page using MK-DS."

Claude activates the skill, calls `get_css_setup`, then `get_page_template`, then `get_component` per slug, then composes the output using only registered components and tokens.

## What the skill does (1-paragraph version)

`SKILL.md` is a router. It looks at what you're asking for, loads the relevant reference docs (state machines, a11y playbook, Figma workflow, dark mode, motion, anti-patterns, migration, recipes, worked examples), and tells Claude: here's the order of operations, here are the hard rules, here's the bar for "done". It exists because giving Claude a giant rulebook didn't work as well as giving it a small router plus on-demand context.

See `.claude/skills/marianita-klix-ds/CHANGELOG.md` for what changed in each version.

## How is this different from shadcn / Mantine / Radix?

Fair question. Quick comparison:

| | MK-DS | shadcn/ui | Mantine | Radix |
|---|---|---|---|---|
| **Distribution** | Static HTML + Tailwind CDN | Copy-paste components via CLI | npm package | npm package |
| **Framework** | Output in HTML / React / Vue / Svelte (via MCP) | React (Tailwind) | React | React (headless) |
| **Build step** | None | Yours | Yours | Yours |
| **MCP / AI integration** | Built-in (this is the whole point) | Recent (`shadcn` MCP) | None | None |
| **Claude skill bundled** | Yes | No | No | No |
| **Tokens** | CSS custom properties, Tokens Studio compatible | Tailwind config + CSS vars | JS theme object | None (BYO) |
| **Dark mode** | Semantic tokens auto-swap on `html.dark` | Tailwind dark class | `MantineProvider` | BYO |
| **Style** | Opinionated palette, fixed `--brand` | Neutral by default | Neutral by default | Unstyled |
| **Accessibility** | WCAG 2.1 AA per-component playbook | Built on Radix primitives | Yes | Headless primitives, you wire ARIA |

**Pick MK-DS when:**
- You want AI assistants (Claude, Cursor, Windsurf) to build UI that's automatically token-correct, prefix-correct, and a11y-correct
- You don't want a build step on the design system itself
- You like opinionated palettes (you don't want to make every color decision)

**Pick shadcn when:**
- You want full control over each component's source (it lives in your repo)
- You're React + Tailwind exclusively
- You're fine making design decisions yourself

**Pick Mantine when:**
- You want a batteries-included React component library
- You like hooks-based component composition

**Pick Radix when:**
- You want unstyled, accessibility-correct primitives and you'll bring your own styles

There's overlap. MK-DS is the choice when "AI assistants build UI with this DS" is a primary use case, not an afterthought.

## Architecture

```
┌─────────────────────────────────────────────────────────────┐
│  AI Client (Claude Code / Cursor / Windsurf / …)           │
└──────────────────────┬──────────────────────────────────────┘
                       │ activates skill on UI tasks
                       ▼
┌─────────────────────────────────────────────────────────────┐
│  Claude Skill (.claude/skills/marianita-klix-ds/)          │
│  - SKILL.md (router, hard rules, workflow)                 │
│  - references/ (state machines, a11y, Figma, dark mode, …) │
│  - examples/ (golden references)                            │
│  - scripts/audit-output.sh (validator)                      │
└──────────────────────┬──────────────────────────────────────┘
                       │ calls MCP tools in workflow order
                       ▼
┌─────────────────────────────────────────────────────────────┐
│  MCP Server (mcp/index.js, stdio)                          │
│  - get_css_setup / list_components / search                │
│  - get_component / get_tokens / get_guidelines             │
│  - get_page_template                                        │
└──────────────────────┬──────────────────────────────────────┘
                       │ reads
                       ▼
┌─────────────────────────────────────────────────────────────┐
│  Registry (mcp/registry.json)                              │
│  - 61 components + variants/props/a11y                     │
│  - All design tokens                                        │
│  - Guidelines + page templates                              │
└─────────────────────────────────────────────────────────────┘
                       │
                       ▼
┌─────────────────────────────────────────────────────────────┐
│  Static HTML Docs (index.html, playground.html, …)         │
│  - Visual reference, copy-paste components                 │
│  - tokens.json for Figma import via Tokens Studio          │
└─────────────────────────────────────────────────────────────┘
```

The registry is the source of truth. The MCP exposes it programmatically. The skill teaches Claude how to use the MCP. The static HTML pages are documentation for humans. Everything stays in sync because everything reads from the same registry.

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
