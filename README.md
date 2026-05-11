# Marianita Klix Design System

A complete UI kit with **61 components**, design tokens, multi-framework support (HTML / React / Vue / Svelte), an **MCP server** so AI assistants can build with it directly, and a **Claude skill** that teaches Claude how to use the MCP correctly.

No build tools. Static HTML + Tailwind CDN + Inter font. Drop-in ready.

## What's inside

```
.
├── *.html                # Interactive documentation (index, playground, icons, etc.)
├── tokens.json           # Tokens Studio v2 format (Figma → code)
├── mcp/                  # MCP server (Node, stdio) — 7 tools
├── .claude/
│   ├── settings.json     # MCP wiring for Claude Code
│   └── skills/
│       └── marianita-klix-ds/
│           └── SKILL.md  # Claude skill that drives the MCP
├── CLAUDE.md             # Rules for any AI assistant working in this repo
└── docs/                 # Internal specs and plans
```

## Three ways to use it

### 1. As a static design system

Open `index.html` in a browser. Copy/paste components into your project. Import `tokens.json` into Figma via Tokens Studio.

### 2. As an MCP server (any AI client)

Connects Claude Code, Cursor, Windsurf, Zed, or any stdio-MCP client to the design system, exposing 7 tools that return tokens, component code, page templates, and guidelines.

```bash
cd mcp
npm install
```

Then wire it into your client. For Claude Code, `.claude/settings.json` already points to the absolute path of `mcp/index.js` — adjust if you cloned elsewhere.

### 3. As a Claude skill + MCP combo (recommended)

The included Claude skill at `.claude/skills/marianita-klix-ds/SKILL.md` teaches Claude **when and how** to call the MCP tools, in what order, and what rules to enforce. Activated automatically on UI tasks within this DS.

To install for Claude Code globally, symlink (or copy) the skill into your skills directory:

```bash
# Option A — symlink so updates here are reflected automatically
ln -s "$(pwd)/.claude/skills/marianita-klix-ds" ~/.claude/skills/marianita-klix-ds

# Option B — copy
cp -R .claude/skills/marianita-klix-ds ~/.claude/skills/
```

Project-local Claude Code sessions will pick up the skill from the repo's `.claude/skills/` automatically.

## MCP tools at a glance

| Tool | What it returns |
|------|------------------|
| `get_css_setup` | Full base CSS for a new project (tokens + dark mode + base styles) |
| `list_components` | All 61 components, grouped by category |
| `search` | Fuzzy search across components, tokens, guidelines |
| `get_component` | Component spec + code in HTML / React / Vue / Svelte |
| `get_tokens` | Tokens in CSS / SCSS / JSON / Tailwind format |
| `get_guidelines` | Authoritative usage rules per topic |
| `get_page_template` | Pre-built page composition (dashboard, settings, login, …) |

See [`mcp/README.md`](mcp/README.md) for the full tool reference and example prompts.

## Quick start (Claude Code)

```bash
git clone https://github.com/marianita-boom-no-risks/marianita-klix-design-system.git
cd marianita-klix-design-system
cd mcp && npm install && cd ..
```

Open the directory in Claude Code. The MCP server is wired via `.claude/settings.json`, and the skill is auto-discovered from `.claude/skills/`. Ask:

> "Build me a settings page with the Marianita Klix Design System"

Claude will activate the skill, call `get_css_setup`, then `get_page_template`, then `get_component` for each piece — outputting code that uses only registered components and tokens.

## Design principles

1. **No invented values.** Every color, spacing, radius, and shadow is a token.
2. **Dark mode is first-class.** Toggle `html.dark` — semantic tokens swap automatically.
3. **`mk-` prefix everywhere.** No bare class names. No Tailwind utility classes for design decisions.
4. **Accessibility is mandatory.** 4.5:1 contrast minimum, semantic HTML, visible focus rings, `prefers-reduced-motion` respected.
5. **No build step.** It must work on a static host with one HTML file.

## License

MIT.
