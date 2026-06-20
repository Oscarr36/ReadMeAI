#!/usr/bin/env bash
# ReadMeAI v2.5 — Smart Setup Script
# Detects your AI tools and wires .readmeAI into each one automatically.
# Usage: curl -sSL https://raw.githubusercontent.com/Oscarr36/ReadMeAI/main/setup.sh | bash
#        or: bash setup.sh --all   (create all integrations regardless of detection)

set -euo pipefail

GREEN='\033[0;32m'; GRAY='\033[0;90m'; BOLD='\033[1m'; RESET='\033[0m'

ALL=false
for arg in "$@"; do [[ "$arg" == "--all" ]] && ALL=true; done

echo ""
echo -e "${BOLD}ReadMeAI Setup${RESET}"
echo -e "${GRAY}─────────────────────────────${RESET}"

# ── Download .readmeAI ────────────────────────────────────────────────────────
curl -sSL -o .readmeAI \
  https://raw.githubusercontent.com/Oscarr36/ReadMeAI/main/.readmeAI
echo -e "${GREEN}✓${RESET} .readmeAI downloaded"

CREATED=()

# ── Helper ────────────────────────────────────────────────────────────────────
write_integration() {
  local file="$1" dir content="$3"
  dir="$(dirname "$file")"
  [[ "$dir" != "." ]] && mkdir -p "$dir"
  # Append only if the ReadMeAI block isn't already there
  if [[ -f "$file" ]] && grep -q "ReadMeAI" "$file" 2>/dev/null; then
    return
  fi
  printf '%s\n' "$content" >> "$file"
  CREATED+=("$2 → $file")
}

CLAUSE="\
## ReadMeAI — mandatory context
At the start of every session, immediately read \`.readmeAI\` in the \
project root before responding to the user. Do not wait to be asked. \
This is your first and only mandatory initialization step."

RULE_CLAUSE="\
# ReadMeAI — mandatory context
At the start of every session, read \`.readmeAI\` in the project root \
before responding. This is mandatory — do not skip, do not ask the user."

# ── Claude Code ───────────────────────────────────────────────────────────────
if $ALL || command -v claude &>/dev/null || [[ -d "$HOME/.claude" ]]; then
  write_integration ".claude/CLAUDE.md" "Claude Code" "
$CLAUSE
"
fi

# ── Cursor ────────────────────────────────────────────────────────────────────
if $ALL || command -v cursor &>/dev/null || [[ -d ".cursor" ]]; then
  write_integration ".cursorrules" "Cursor" "$RULE_CLAUSE"
fi

# ── Windsurf ──────────────────────────────────────────────────────────────────
if $ALL || command -v windsurf &>/dev/null || [[ -d ".windsurf" ]]; then
  write_integration ".windsurfrules" "Windsurf" "$RULE_CLAUSE"
fi

# ── GitHub Copilot ────────────────────────────────────────────────────────────
if $ALL || (command -v gh &>/dev/null && gh extension list 2>/dev/null | grep -q copilot); then
  write_integration ".github/copilot-instructions.md" "GitHub Copilot" "
$CLAUSE
"
fi

# ── Aider ─────────────────────────────────────────────────────────────────────
if $ALL || command -v aider &>/dev/null; then
  if [[ ! -f ".aider.conf.yml" ]] || ! grep -q "readmeAI" ".aider.conf.yml" 2>/dev/null; then
    printf 'read:\n  - .readmeAI\n' >> .aider.conf.yml
    CREATED+=("Aider → .aider.conf.yml")
  fi
fi

# ── Continue ──────────────────────────────────────────────────────────────────
if $ALL || [[ -d "$HOME/.continue" ]] || [[ -d ".continue" ]]; then
  write_integration ".continue/rules/readmeai.md" "Continue" "$RULE_CLAUSE"
fi

# ── Summary ───────────────────────────────────────────────────────────────────
echo ""
if [[ ${#CREATED[@]} -gt 0 ]]; then
  echo -e "${BOLD}AI integrations wired:${RESET}"
  for item in "${CREATED[@]}"; do
    echo -e "  ${GREEN}✓${RESET} $item"
  done
else
  echo -e "${GRAY}No AI tools auto-detected. Run with --all to create all integrations:${RESET}"
  echo -e "  ${GRAY}bash setup.sh --all${RESET}"
fi

echo ""
echo -e "${BOLD}Next step:${RESET} tell your AI: ${GREEN}\"Detect my stack, fill what you can.\"${RESET}"
echo ""
