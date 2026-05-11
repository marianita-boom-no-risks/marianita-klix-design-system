#!/usr/bin/env bash
# audit-output.sh — MK-DS compliance auditor
# author: mariana
#
# Quick(ish) audit for the kinds of mistakes I keep catching in PR review.
# Bash because I wanted zero dependencies. A "real" version would parse CSS
# with a proper tool, but then this script would have a build step and that
# defeats the point.
#
# Catches:
#   - Hardcoded hex colors (outside :root and html.dark blocks)
#   - Off-token px values (anything not in the standard scale)
#   - Tailwind color/spacing utilities (forbidden for design decisions)
#   - <div onclick=...> patterns
#   - Icon-only buttons without aria-label
#   - outline: none without a :focus-visible replacement
#
# Doesn't catch (yet):
#   - Skipped heading levels (would need a proper HTML parser)
#   - Inputs without labels (same)
#   - Invented mk-* classes (needs registry.json lookup, on the todo list)
#
# Usage:
#   ./audit-output.sh <file>     audit one file
#   ./audit-output.sh <dir>      audit a directory recursively
#   ./audit-output.sh            audit current dir
#
# Exit codes:
#   0  clean
#   1  violations found
#   2  bad input
#
# Known false positives:
#   - Documentation pages (like index.html in this repo) that show tokens'
#     hex values literally. Audit them with grep | grep -v "doc-token" or skip.
#   - CSS-in-JS template literals (regex isn't context-aware).

set -euo pipefail

# ── Colors for output ─────────────────────────────────────────
if [[ -t 1 ]]; then
  RED=$'\033[0;31m'
  YEL=$'\033[0;33m'
  GRN=$'\033[0;32m'
  CYA=$'\033[0;36m'
  BLD=$'\033[1m'
  RST=$'\033[0m'
else
  RED= YEL= GRN= CYA= BLD= RST=
fi

# ── Arg parsing ───────────────────────────────────────────────
TARGET="${1:-.}"
if [[ ! -e "$TARGET" ]]; then
  echo "${RED}Error:${RST} '$TARGET' does not exist." >&2
  exit 2
fi

# ── File collection ───────────────────────────────────────────
if [[ -d "$TARGET" ]]; then
  FILES=$(find "$TARGET" -type f \( -name "*.html" -o -name "*.css" -o -name "*.js" -o -name "*.jsx" -o -name "*.tsx" -o -name "*.vue" -o -name "*.svelte" \) -not -path '*/node_modules/*' -not -path '*/.git/*')
else
  FILES="$TARGET"
fi

if [[ -z "$FILES" ]]; then
  echo "${YEL}No files to audit.${RST}"
  exit 0
fi

FILE_COUNT=$(echo "$FILES" | wc -l | tr -d ' ')
echo "${BLD}MK-DS Audit${RST} — scanning $FILE_COUNT file(s)"
echo ""

TOTAL_VIOLATIONS=0

# ── Helper: report a finding ──────────────────────────────────
report() {
  local severity="$1"
  local rule="$2"
  local file="$3"
  local line="$4"
  local snippet="$5"
  local fix="$6"

  case "$severity" in
    ERROR)   COLOR="$RED" ;;
    WARN)    COLOR="$YEL" ;;
    INFO)    COLOR="$CYA" ;;
    *)       COLOR="$RST" ;;
  esac

  echo "${COLOR}[$severity]${RST} ${BLD}$rule${RST}"
  echo "  ${file}:${line}"
  echo "    > $snippet"
  echo "    → fix: $fix"
  echo ""
  TOTAL_VIOLATIONS=$((TOTAL_VIOLATIONS + 1))
}

# ── Rule 1: Hardcoded hex colors ──────────────────────────────
# Allow hex inside :root { ... } and html.dark { ... } blocks (token definitions)
echo "${CYA}▸${RST} Rule 1: Hardcoded hex colors outside token files"
for f in $FILES; do
  # Skip token files
  case "$f" in
    *tokens.json|*globals.css) continue ;;
  esac

  # Find hex codes; exclude lines that are clearly inside CSS variable definitions
  while IFS=: read -r line content; do
    # Skip if line is a CSS variable definition (-- in the line)
    if echo "$content" | grep -qE '^\s*--[a-z]'; then continue; fi
    # Skip if line is inside a comment
    if echo "$content" | grep -qE '^\s*(\*|//|<!--)'; then continue; fi

    snippet=$(echo "$content" | sed 's/^[[:space:]]*//' | cut -c1-80)
    report ERROR "A1: Hardcoded color" "$f" "$line" "$snippet" \
      "Replace with var(--bg-primary), var(--text-primary), var(--brand), etc."
  done < <(grep -nE '#[0-9a-fA-F]{3}([0-9a-fA-F]{3})?\b' "$f" 2>/dev/null | head -10 || true)
done

# ── Rule 2: Off-token px (outside borders and tokens.json) ───
echo "${CYA}▸${RST} Rule 2: Off-token px values"
ALLOWED_PX_REGEX='1px|2px|4px|6px|8px|10px|12px|14px|16px|20px|24px|32px|40px|48px|64px'
for f in $FILES; do
  case "$f" in
    *tokens.json|*globals.css) continue ;;
  esac

  while IFS=: read -r line content; do
    # Skip variable definitions
    if echo "$content" | grep -qE '^\s*--[a-z]'; then continue; fi
    # Skip commented lines
    if echo "$content" | grep -qE '^\s*(\*|//|<!--)'; then continue; fi
    # Skip if the px value is in the allowed list
    px_value=$(echo "$content" | grep -oE '[0-9]+px' | head -1)
    if echo "$px_value" | grep -qE "^($ALLOWED_PX_REGEX)$"; then continue; fi

    snippet=$(echo "$content" | sed 's/^[[:space:]]*//' | cut -c1-80)
    report WARN "A2: Off-token spacing" "$f" "$line" "$snippet" \
      "Use --space-*, --radius-*, or --text-* tokens."
  done < <(grep -nE '[^a-zA-Z0-9-][0-9]+px' "$f" 2>/dev/null | head -10 || true)
done

# ── Rule 3: Tailwind color/spacing utilities ──────────────────
echo "${CYA}▸${RST} Rule 3: Tailwind color/spacing utilities (forbidden for design decisions)"
for f in $FILES; do
  case "$f" in *.css|*.json) continue ;; esac

  while IFS=: read -r line content; do
    # Skip if it's a comment
    if echo "$content" | grep -qE '^\s*(\*|//|<!--)'; then continue; fi

    util=$(echo "$content" | grep -oE '(bg|text|border)-(red|blue|green|yellow|gray|indigo|pink|purple|amber|emerald|rose|sky|cyan|violet)-[0-9]{2,3}' | head -1)
    if [[ -z "$util" ]]; then continue; fi

    snippet=$(echo "$content" | sed 's/^[[:space:]]*//' | cut -c1-80)
    report ERROR "A4: Tailwind color utility" "$f" "$line" "$snippet" \
      "Use mk- component classes or inline style with var(--brand)/var(--text-primary)/etc."
  done < <(grep -nE '(bg|text|border)-(red|blue|green|yellow|gray|indigo|pink|purple|amber|emerald|rose|sky|cyan|violet)-[0-9]{2,3}' "$f" 2>/dev/null | head -10 || true)
done

# ── Rule 4: <div onClick> patterns ────────────────────────────
echo "${CYA}▸${RST} Rule 4: <div> with onclick / onClick"
for f in $FILES; do
  case "$f" in *.css|*.json) continue ;; esac

  while IFS=: read -r line content; do
    snippet=$(echo "$content" | sed 's/^[[:space:]]*//' | cut -c1-80)
    report ERROR "C1: <div onClick>" "$f" "$line" "$snippet" \
      "Replace with <button> (semantic, focusable, keyboard-activatable)."
  done < <(grep -nEi '<div[^>]+on[Cc]lick' "$f" 2>/dev/null | head -10 || true)
done

# ── Rule 5: <svg> button without aria-label or accessible text ──
echo "${CYA}▸${RST} Rule 5: Icon-only buttons without accessible name"
for f in $FILES; do
  case "$f" in *.css|*.json) continue ;; esac

  # Match <button ...> directly followed by <svg ... and a closing tag with no text content
  # Conservative regex: button containing only <svg ... />... with no aria-label attribute
  while IFS=: read -r line content; do
    if echo "$content" | grep -qE 'aria-label'; then continue; fi

    snippet=$(echo "$content" | sed 's/^[[:space:]]*//' | cut -c1-80)
    report ERROR "C2: Icon button missing aria-label" "$f" "$line" "$snippet" \
      'Add aria-label="<purpose>" to the <button>, and aria-hidden="true" to the <svg>.'
  done < <(grep -nE '<button[^>]*>[[:space:]]*<svg' "$f" 2>/dev/null | head -10 || true)
done

# ── Rule 6: outline: none without focus-visible replacement ───
echo "${CYA}▸${RST} Rule 6: outline: none without :focus-visible replacement"
for f in $FILES; do
  case "$f" in *.json) continue ;; esac

  while IFS=: read -r line content; do
    if echo "$content" | grep -qE 'focus-visible'; then continue; fi

    snippet=$(echo "$content" | sed 's/^[[:space:]]*//' | cut -c1-80)
    report ERROR "C5: outline: none without replacement" "$f" "$line" "$snippet" \
      "Provide a custom :focus-visible style with visible ring (--brand, 2-4px)."
  done < <(grep -nE 'outline\s*:\s*none' "$f" 2>/dev/null | head -10 || true)
done

# ── Rule 7: Invented mk- classes ──────────────────────────────
# TODO(mariana): cross-reference against mcp/registry.json. Skipping for now;
# would need to extract the class list from the JSON and grep negatively.
# This is high-value but I haven't gotten to it. Manual review for now.
echo "${CYA}▸${RST} Rule 7: Invented mk- classes (manual review)"
echo "  ${YEL}skipped — verify all mk- classes exist in mcp/registry.json by hand${RST}"
echo ""

# ── Summary ───────────────────────────────────────────────────
echo "─────────────────────────────────────────────"
if [[ $TOTAL_VIOLATIONS -eq 0 ]]; then
  echo "${GRN}✓ No violations found.${RST}"
  exit 0
else
  echo "${RED}✗ Found $TOTAL_VIOLATIONS violation(s).${RST}"
  echo ""
  echo "Resolve each above. Re-run when fixed:"
  echo "  $0 $TARGET"
  exit 1
fi
