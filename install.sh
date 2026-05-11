#!/usr/bin/env bash
# install.sh — set up MK-DS for use across all your Claude Code projects.
#
# What this does:
#   1. Installs MCP server dependencies (cd mcp && npm install)
#   2. Symlinks the Claude skill into ~/.claude/skills/
#   3. Tells you how to wire the MCP into your client of choice
#
# What this does NOT do:
#   - Add the MCP to your global Claude config. That's a decision and I'm
#     not going to make it for you. See the output for the JSON snippet.
#   - Install npm. You need that already.
#
# Usage:
#   ./install.sh             # full setup
#   ./install.sh --skill     # just symlink the skill
#   ./install.sh --mcp       # just install MCP deps
#   ./install.sh --check     # report current install status, change nothing
#   ./install.sh --uninstall # remove the symlink (leaves the repo intact)

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILL_SRC="${REPO_ROOT}/.claude/skills/marianita-klix-ds"
SKILL_DST="${HOME}/.claude/skills/marianita-klix-ds"
MCP_PATH="${REPO_ROOT}/mcp/index.js"

# ── Colors ────────────────────────────────────────────────────
if [[ -t 1 ]]; then
  RED=$'\033[0;31m'
  YEL=$'\033[0;33m'
  GRN=$'\033[0;32m'
  CYA=$'\033[0;36m'
  BLD=$'\033[1m'
  DIM=$'\033[2m'
  RST=$'\033[0m'
else
  RED= YEL= GRN= CYA= BLD= DIM= RST=
fi

log()  { printf "%s\n" "$*"; }
ok()   { printf "${GRN}✓${RST} %s\n" "$*"; }
warn() { printf "${YEL}!${RST} %s\n" "$*"; }
err()  { printf "${RED}✗${RST} %s\n" "$*" >&2; }
step() { printf "\n${CYA}${BLD}▸${RST} ${BLD}%s${RST}\n" "$*"; }

# ── Pre-flight ────────────────────────────────────────────────
check_prereqs() {
  if ! command -v node >/dev/null 2>&1; then
    err "node is not installed. Get it from https://nodejs.org/"
    exit 2
  fi
  if ! command -v npm >/dev/null 2>&1; then
    err "npm is not installed."
    exit 2
  fi
  local nver
  nver="$(node -v | sed 's/^v//;s/\..*//')"
  if [[ "$nver" -lt 18 ]]; then
    warn "Node $nver detected; this repo is tested on 20+. It may still work."
  fi
}

# ── Actions ───────────────────────────────────────────────────
install_mcp() {
  step "Installing MCP server dependencies"
  if [[ ! -f "${REPO_ROOT}/mcp/package.json" ]]; then
    err "Can't find mcp/package.json. Are you running this from the repo root?"
    exit 2
  fi
  (cd "${REPO_ROOT}/mcp" && npm install --silent)
  ok "MCP deps installed at ${REPO_ROOT}/mcp/node_modules"
}

install_skill() {
  step "Linking Claude skill"
  mkdir -p "${HOME}/.claude/skills"

  if [[ -L "$SKILL_DST" ]]; then
    local current
    current="$(readlink "$SKILL_DST")"
    if [[ "$current" == "$SKILL_SRC" ]]; then
      ok "Skill already linked to this repo (${DIM}${SKILL_DST}${RST})"
      return 0
    fi
    warn "Skill is linked to a different path: $current"
    warn "Replacing it with the one from this repo."
    rm "$SKILL_DST"
  elif [[ -e "$SKILL_DST" ]]; then
    err "Path exists and isn't a symlink: $SKILL_DST"
    err "Move or remove it manually, then re-run."
    exit 2
  fi

  ln -s "$SKILL_SRC" "$SKILL_DST"
  ok "Linked $SKILL_DST → $SKILL_SRC"
}

uninstall_skill() {
  step "Removing skill symlink"
  if [[ -L "$SKILL_DST" ]]; then
    rm "$SKILL_DST"
    ok "Removed $SKILL_DST"
  else
    warn "No symlink at $SKILL_DST. Nothing to do."
  fi
}

check_status() {
  step "Status check"
  if [[ -d "${REPO_ROOT}/mcp/node_modules" ]]; then
    ok "MCP deps: installed"
  else
    warn "MCP deps: not installed (run with --mcp or no flags)"
  fi
  if [[ -L "$SKILL_DST" ]]; then
    ok "Skill: linked → $(readlink "$SKILL_DST")"
  else
    warn "Skill: not linked (run with --skill or no flags)"
  fi
}

print_next_steps() {
  cat <<EOF

${BLD}Next steps — wire the MCP into your client:${RST}

${CYA}Claude Code (global):${RST}
  Edit ~/.claude.json and add:

  {
    "mcpServers": {
      "marianita-klix-ds": {
        "command": "node",
        "args": ["${MCP_PATH}"]
      }
    }
  }

  Or, for project-only, .claude/settings.json in your project.

${CYA}Cursor:${RST}
  Edit .cursor/mcp.json in your project and add the same block as above.
  (There's a template in this repo at .cursor/mcp.json you can copy.)

${CYA}Windsurf / Zed / any stdio-MCP client:${RST}
  Same shape: command "node", args [absolute path to mcp/index.js].

${BLD}Test it:${RST}
  Open Claude Code in any project, ask:
  ${DIM}"Build me a settings page using the Marianita Klix Design System."${RST}

  Claude should activate the skill and call MCP tools in order.

EOF
}

# ── Main ──────────────────────────────────────────────────────
case "${1:-}" in
  --skill)
    install_skill
    ;;
  --mcp)
    check_prereqs
    install_mcp
    ;;
  --check)
    check_status
    ;;
  --uninstall)
    uninstall_skill
    ;;
  --help|-h)
    sed -n '1,/^set -euo/p' "$0" | head -n -1
    ;;
  "")
    check_prereqs
    install_mcp
    install_skill
    print_next_steps
    ;;
  *)
    err "Unknown flag: $1"
    err "Run with --help for usage."
    exit 2
    ;;
esac
