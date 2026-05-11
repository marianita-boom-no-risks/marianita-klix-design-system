# Marianita Klix Design System — MCP Server

Stdio-based MCP server that exposes the **Marianita Klix Design System** (61 components, design tokens, page templates, guidelines) to AI assistants. Think of it as the design-system equivalent of shadcn's MCP.

Pair it with the included **Claude skill** at `../.claude/skills/marianita-klix-ds/SKILL.md` for the smoothest experience — the skill teaches Claude when and in what order to call these tools.

## Install

```bash
npm install
```

That installs `@modelcontextprotocol/sdk`. The server has no other runtime deps.

## Wire it into a client

### Claude Code (project-local)

The repo's `.claude/settings.json` already points to `mcp/index.js`. Open the repo in Claude Code and it picks up automatically.

### Claude Code (global / any project)

`~/.claude.json`:

```json
{
  "mcpServers": {
    "marianita-klix-ds": {
      "command": "node",
      "args": ["/absolute/path/to/marianita-klix-design-system/mcp/index.js"]
    }
  }
}
```

### Cursor

`.cursor/mcp.json` in your project:

```json
{
  "mcpServers": {
    "marianita-klix-ds": {
      "command": "node",
      "args": ["/absolute/path/to/marianita-klix-design-system/mcp/index.js"]
    }
  }
}
```

### Windsurf / Zed / any stdio-MCP client

Same shape — `command: node`, `args: [absolute path to index.js]`.

## Tool reference

### `get_css_setup` — call this FIRST in any new project

Returns the complete CSS needed to bootstrap a project: token definitions, dark-mode overrides, base styles, scrollbar styling, and the Inter font import.

```
get_css_setup()
```

No arguments. Paste the result into your main CSS file.

### `list_components` — explore the catalogue

```
list_components()                          # all 61
list_components(category: "Form Controls") # filter by category
```

Categories: `Form Controls`, `Data Display`, `Feedback`, `Navigation`, `Layout`, `Overlay`, `Content`.

### `search` — fuzzy lookup

```
search(query: "button")
search(query: "spacing")
search(query: "dark mode")
```

Searches components (name, description, CSS classes, props), tokens, and guidelines. Tolerates typos.

### `get_component` — full component spec + code

```
get_component(name: "button")
get_component(name: "stat-card", format: "react")
get_component(name: "Toggle",    format: "vue")
get_component(name: "command-palette", format: "svelte")
```

Returns props, variants, sizes, CSS classes, usage guidelines, a11y notes, and ready-to-paste code in the requested format. Suggests near-matches if the name isn't found.

### `get_tokens` — design tokens in any format

```
get_tokens()                                       # full set, CSS
get_tokens(format: "scss")
get_tokens(format: "tailwind")
get_tokens(format: "json")
get_tokens(format: "css", category: "colors")
```

Categories: `colors`, `typography`, `spacing`, `borderRadius`, `shadows`, `dark`.

### `get_guidelines` — authoritative rules per topic

```
get_guidelines(topic: "spacing")
get_guidelines(topic: "accessibility")
get_guidelines(topic: "dark_mode")
```

Topics: `spacing`, `typography`, `color_usage`, `dark_mode`, `accessibility`, `responsive`, `motion`.

### `get_page_template` — composed page recipes

```
get_page_template(template: "dashboard")
get_page_template(template: "settings")
get_page_template(template: "login")
get_page_template(template: "profile")
```

Returns the template's description and the list of components it composes. Follow up with `get_component` for each one.

## Recommended workflow

1. **`get_css_setup`** — drop the base CSS into the project.
2. **`list_components`** or **`search`** — find what fits.
3. **`get_page_template`** — if building a full page, get the composition recipe first.
4. **`get_component`** — pull each component's code in your project's format.
5. **`get_guidelines`** — resolve any contested decision (spacing, a11y, motion).
6. **`get_tokens`** — export tokens to the project's pipeline if it needs them.

The Claude skill at `../.claude/skills/marianita-klix-ds/SKILL.md` encodes this workflow as instructions for the AI assistant.

## Example prompts

Once wired up, you can say:

- *"Build me a settings page using the Marianita Klix Design System."*
- *"Create a dashboard with stat cards and a sortable data table."*
- *"Show me the Toggle component in React with all variants."*
- *"What are the spacing tokens — give me both CSS and Tailwind."*
- *"Search for components related to navigation."*
- *"Give me the CSS setup so I can paste it into a fresh project."*
- *"Use the Marianita Klix DS to build a pricing page with three tiers."*

## Inventory

| Asset | Count |
|-------|-------|
| Components | 61 (across 7 categories) |
| Tokens — colors | 38 |
| Tokens — typography | 16 |
| Tokens — spacing | 9 |
| Tokens — radii | 5 |
| Tokens — shadows | 6 |
| Dark-mode overrides | 6 |
| Page templates | (see `get_page_template`) |
| Guidelines topics | 7 |

## License

MIT.
