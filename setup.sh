#!/usr/bin/env bash
# ReadMeAI v3.1 — Smart Setup Script
# Downloads .readmeAI and wires it into every AI tool automatically.
#
# Usage:
#   curl -sSL https://raw.githubusercontent.com/Oscarr36/ReadMeAI/main/setup.sh | bash
#   bash setup.sh --all          # create integrations for ALL AI tools
#   bash setup.sh --detect       # pre-fill TECH STACK by scanning the project
#   bash setup.sh --validate     # check .readmeAI is in sync with the codebase
#   bash setup.sh --update       # re-scan and update TECH STACK section
#   bash setup.sh --all --detect # everything at once

set -euo pipefail

GREEN='\033[0;32m'; GRAY='\033[0;90m'; BOLD='\033[1m'
YELLOW='\033[0;33m'; RED='\033[0;31m'; RESET='\033[0m'

ALL=false; DETECT=false; VALIDATE=false; UPDATE=false
for arg in "$@"; do
  case "$arg" in
    --all)      ALL=true ;;
    --detect)   DETECT=true ;;
    --validate) VALIDATE=true ;;
    --update)   DETECT=true; UPDATE=true ;;
  esac
done

# ── Validate mode ─────────────────────────────────────────────────────────────
if $VALIDATE; then
  echo ""
  echo -e "${BOLD}ReadMeAI Validate${RESET}"
  echo -e "${GRAY}────────────────────────────────────${RESET}"
  ERRORS=0; WARNINGS=0

  if [[ ! -f ".readmeAI" ]]; then
    echo -e "${RED}✗${RESET} .readmeAI not found in current directory"
    exit 1
  fi
  echo -e "${GREEN}✓${RESET} .readmeAI exists"

  if grep -q "SESSION STATE" .readmeAI; then
    if grep -A5 "## 🎯 SESSION STATE" .readmeAI | grep -q "Active objective"; then
      NEXT=$(grep -A3 "### Active objective" .readmeAI | tail -1 | xargs)
      if [[ "$NEXT" == "—" ]] || [[ -z "$NEXT" ]]; then
        echo -e "${YELLOW}⚠${RESET}  SESSION STATE is blank — first-time setup not completed yet"
        ((WARNINGS++)) || true
      else
        echo -e "${GREEN}✓${RESET} SESSION STATE is filled"
      fi
    fi
  fi

  # Check integration files
  [[ -f ".claude/CLAUDE.md" ]]                   && echo -e "${GREEN}✓${RESET} Claude Code → .claude/CLAUDE.md" \
    || echo -e "${GRAY}–${RESET}  Claude Code not wired (run: bash setup.sh)"
  [[ -f ".cursorrules" ]]                         && echo -e "${GREEN}✓${RESET} Cursor → .cursorrules" \
    || echo -e "${GRAY}–${RESET}  Cursor not wired"
  [[ -f ".windsurfrules" ]]                       && echo -e "${GREEN}✓${RESET} Windsurf → .windsurfrules" \
    || echo -e "${GRAY}–${RESET}  Windsurf not wired"
  [[ -f ".github/copilot-instructions.md" ]]      && echo -e "${GREEN}✓${RESET} GitHub Copilot → .github/copilot-instructions.md" \
    || echo -e "${GRAY}–${RESET}  Copilot not wired"
  [[ -f ".aider.conf.yml" ]]                      && echo -e "${GREEN}✓${RESET} Aider → .aider.conf.yml" \
    || echo -e "${GRAY}–${RESET}  Aider not wired"

  # Check stack consistency with package.json
  if [[ -f "package.json" ]] && grep -q "TECH STACK" .readmeAI 2>/dev/null; then
    echo -e "${GREEN}✓${RESET} TECH STACK section present"
  fi

  echo ""
  if [[ $ERRORS -eq 0 && $WARNINGS -eq 0 ]]; then
    echo -e "${GREEN}All checks passed.${RESET}"
  elif [[ $ERRORS -eq 0 ]]; then
    echo -e "${YELLOW}$WARNINGS warning(s). Run: bash setup.sh --detect to fix.${RESET}"
  else
    echo -e "${RED}$ERRORS error(s) found.${RESET}"
    exit 1
  fi
  exit 0
fi

echo ""
echo -e "${BOLD}ReadMeAI v3.1 Setup${RESET}"
echo -e "${GRAY}────────────────────────────────────${RESET}"

# ── 1. Download .readmeAI ─────────────────────────────────────────────────────
curl -sSL -o .readmeAI \
  https://raw.githubusercontent.com/Oscarr36/ReadMeAI/main/.readmeAI
echo -e "${GREEN}✓${RESET} .readmeAI downloaded"

CREATED=()

# ── 2. Smart integration file content ────────────────────────────────────────
# These are task-aware, not just "read .readmeAI"

CLAUDE_CONTENT='
## ReadMeAI — Project Context System

**Every session:** Read `.readmeAI` at the start before responding. No exceptions.

**Hot restart** ("continue where we left off"):
1. Read `.readmeAI` QUICK REFERENCE table first (top of file).
2. Read SESSION STATE section.
3. Resume from "Next immediate step" — no recap needed.

**First-time setup** (SESSION STATE is blank):
Run the FIRST-TIME SETUP block at the bottom of `.readmeAI`. Fill every section. Ask only what cannot be inferred.

**Before writing any code:**
- Run the CODE QUALITY checklist from `.readmeAI`
- Check DOMAIN RULES — these override your training

**Before touching auth / input / data:**
- Read the optional SECURITY section in `.readmeAI`

**Before an architectural decision:**
- Read DECISIONS LOG in `.readmeAI` — it may already be decided

**Session end (silent, no user prompt):**
1. Overwrite QUICK REFERENCE and SESSION STATE
2. Append to DECISIONS LOG
3. Update SYMBOL INDEX for new/renamed symbols
'

CURSOR_CONTENT='# ReadMeAI — Project Context System

Every session: read `.readmeAI` at the start before responding.

Hot restart ("continue" / resuming work):
  → Read QUICK REFERENCE table (top of .readmeAI) then SESSION STATE. Resume immediately.

First-time setup (SESSION STATE blank):
  → Execute FIRST-TIME SETUP block at the bottom of .readmeAI.

Before writing code: run CODE QUALITY checklist and check DOMAIN RULES in .readmeAI.
Before auth/input/data: also read the SECURITY optional section.
Before architectural decisions: read DECISIONS LOG first.

Session end (silent):
  → Update QUICK REFERENCE, SESSION STATE, DECISIONS LOG, SYMBOL INDEX.
'

COPILOT_CONTENT='
## ReadMeAI — Project Context System

**Every session:** Read `.readmeAI` at the project root before responding.

**Hot restart:** Read QUICK REFERENCE (top of file) → SESSION STATE → resume.

**First-time setup** (SESSION STATE blank): run FIRST-TIME SETUP block at bottom of `.readmeAI`.

**Before writing code:** run CODE QUALITY checklist from `.readmeAI` and check DOMAIN RULES.

**Session end:** update QUICK REFERENCE, SESSION STATE, append to DECISIONS LOG.
'

# ── 3. Helper ─────────────────────────────────────────────────────────────────
write_integration() {
  local file="$1" label="$2" content="$3" dir
  dir="$(dirname "$file")"
  [[ "$dir" != "." ]] && mkdir -p "$dir"
  if [[ -f "$file" ]] && grep -q "ReadMeAI" "$file" 2>/dev/null; then return; fi
  printf '%s\n' "$content" >> "$file"
  CREATED+=("$label → $file")
}

# ── 4. Wire AI tools ──────────────────────────────────────────────────────────
if $ALL || command -v claude &>/dev/null || [[ -d "$HOME/.claude" ]]; then
  write_integration ".claude/CLAUDE.md" "Claude Code" "$CLAUDE_CONTENT"
fi
if $ALL || command -v cursor &>/dev/null || [[ -d ".cursor" ]]; then
  write_integration ".cursorrules" "Cursor" "$CURSOR_CONTENT"
fi
if $ALL || command -v windsurf &>/dev/null || [[ -d ".windsurf" ]]; then
  write_integration ".windsurfrules" "Windsurf" "$CURSOR_CONTENT"
fi
if $ALL || (command -v gh &>/dev/null && gh extension list 2>/dev/null | grep -q copilot); then
  write_integration ".github/copilot-instructions.md" "GitHub Copilot" "$COPILOT_CONTENT"
fi
if $ALL || command -v aider &>/dev/null; then
  if [[ ! -f ".aider.conf.yml" ]] || ! grep -q "readmeAI" ".aider.conf.yml" 2>/dev/null; then
    printf 'read:\n  - .readmeAI\n' >> .aider.conf.yml
    CREATED+=("Aider → .aider.conf.yml")
  fi
fi
if $ALL || [[ -d "$HOME/.continue" ]] || [[ -d ".continue" ]]; then
  write_integration ".continue/rules/readmeai.md" "Continue" "$CURSOR_CONTENT"
fi

# ── 5. Stack detection ────────────────────────────────────────────────────────
if $DETECT; then
  echo ""
  echo -e "${BOLD}Detecting stack...${RESET}"
  STACK_LINES=()
  TODAY=$(date '+%Y-%m-%d')

  if [[ -f "package.json" ]]; then
    PKG=$(cat package.json)
    runtime="Node.js"; fw=""; db=""; test_fw=""; build_fw=""

    grep -q '"express"'       <<< "$PKG" && fw="Express"
    grep -q '"@nestjs/core"'  <<< "$PKG" && fw="NestJS"
    grep -q '"fastify"'       <<< "$PKG" && fw="Fastify"
    grep -q '"hono"'          <<< "$PKG" && fw="Hono"
    grep -q '"next"'          <<< "$PKG" && fw="Next.js"
    grep -q '"nuxt"'          <<< "$PKG" && fw="Nuxt"
    grep -q '"react"'         <<< "$PKG" && [[ -z "$fw" ]] && fw="React"
    grep -q '"vue"'           <<< "$PKG" && [[ -z "$fw" ]] && fw="Vue"
    grep -q '"svelte"'        <<< "$PKG" && [[ -z "$fw" ]] && fw="Svelte"
    grep -q '"@angular/core"' <<< "$PKG" && [[ -z "$fw" ]] && fw="Angular"
    grep -q '"mongoose"'      <<< "$PKG" && db="MongoDB (mongoose)"
    grep -q '"prisma"'        <<< "$PKG" && db="Prisma"
    grep -q '"pg"'            <<< "$PKG" && [[ -z "$db" ]] && db="PostgreSQL"
    grep -q '"mysql2"'        <<< "$PKG" && [[ -z "$db" ]] && db="MySQL"
    grep -q '"redis"'         <<< "$PKG" && db+="${db:+ + }Redis"
    grep -q '"jest"'          <<< "$PKG" && test_fw="Jest"
    grep -q '"vitest"'        <<< "$PKG" && test_fw="Vitest"
    grep -q '"@playwright"'   <<< "$PKG" && test_fw+="${test_fw:+ + }Playwright"
    grep -q '"cypress"'       <<< "$PKG" && test_fw+="${test_fw:+ + }Cypress"
    grep -q '"typescript"'    <<< "$PKG" && runtime="Node.js + TypeScript"
    grep -q '"vite"'          <<< "$PKG" && build_fw="Vite"
    grep -q '"webpack"'       <<< "$PKG" && [[ -z "$build_fw" ]] && build_fw="Webpack"
    grep -q '"turbo"'         <<< "$PKG" && build_fw+="${build_fw:+ }(Turborepo)"

    node_ver=$(node -v 2>/dev/null | tr -d 'v' || echo "—")
    STACK_LINES+=("| Runtime | $runtime | $node_ver | — |")
    [[ -n "$fw"      ]] && STACK_LINES+=("| Framework | $fw | — | — |")
    [[ -n "$db"      ]] && STACK_LINES+=("| Database | $db | — | — |")
    [[ -n "$test_fw" ]] && STACK_LINES+=("| Test runner | $test_fw | — | — |")
    [[ -n "$build_fw"]] && STACK_LINES+=("| Build tool | $build_fw | — | — |")
  fi
  if [[ -f "requirements.txt" ]] || [[ -f "pyproject.toml" ]] || [[ -f "Pipfile" ]]; then
    REQS=$(cat requirements*.txt Pipfile pyproject.toml 2>/dev/null || true)
    py_fw=""
    grep -qi "django"  <<< "$REQS" && py_fw="Django"
    grep -qi "fastapi" <<< "$REQS" && py_fw="FastAPI"
    grep -qi "flask"   <<< "$REQS" && [[ -z "$py_fw" ]] && py_fw="Flask"
    py_ver=$(python3 --version 2>/dev/null | awk '{print $2}' || echo "—")
    STACK_LINES+=("| Runtime | Python | $py_ver | — |")
    [[ -n "$py_fw" ]] && STACK_LINES+=("| Framework | $py_fw | — | — |")
  fi
  [[ -f "go.mod"      ]] && STACK_LINES+=("| Runtime | Go | $(go version 2>/dev/null | awk '{print $3}' | tr -d go || echo —) | — |")
  [[ -f "Cargo.toml"  ]] && STACK_LINES+=("| Runtime | Rust | $(rustc --version 2>/dev/null | awk '{print $2}' || echo —) | — |")
  [[ -f "Gemfile"     ]] && STACK_LINES+=("| Runtime | Ruby | $(ruby -v 2>/dev/null | awk '{print $2}' || echo —) | — |")
  [[ -f "composer.json"]] && STACK_LINES+=("| Runtime | PHP | $(php -v 2>/dev/null | head -1 | awk '{print $2}' || echo —) | — |")
  { [[ -f "Dockerfile" ]] || [[ -f "docker-compose.yml" ]]; } && \
    STACK_LINES+=("| Container | Docker | — | docker-compose.yml |")

  if [[ ${#STACK_LINES[@]} -gt 0 ]]; then
    # Remove existing TECH STACK section if updating
    if $UPDATE && grep -q "## 🛠 TECH STACK" .readmeAI; then
      sed -i '/## 🛠 TECH STACK/,/^---$/{/^---$/!d}' .readmeAI 2>/dev/null || true
    fi
    if ! grep -q "## 🛠 TECH STACK" .readmeAI; then
      {
        printf '\n\n## 🛠 TECH STACK\n'
        printf '_Auto-detected by setup.sh on %s_\n\n' "$TODAY"
        printf '| Layer | Technology | Version | Notes |\n'
        printf '|-------|-----------|---------|-------|\n'
        printf '%s\n' "${STACK_LINES[@]}"
      } >> .readmeAI
      echo -e "${GREEN}✓${RESET} Stack pre-filled (${#STACK_LINES[@]} layers)"
    else
      echo -e "${GRAY}–${RESET}  TECH STACK already present (use --update to refresh)"
    fi
  else
    echo -e "${YELLOW}⚠${RESET}  No stack detected. Fill TECH STACK manually."
  fi
fi

# ── 6. Summary ────────────────────────────────────────────────────────────────
echo ""
if [[ ${#CREATED[@]} -gt 0 ]]; then
  echo -e "${BOLD}AI integrations wired:${RESET}"
  for item in "${CREATED[@]}"; do echo -e "  ${GREEN}✓${RESET} $item"; done
else
  if ! ($ALL || command -v claude &>/dev/null || command -v cursor &>/dev/null || \
        command -v windsurf &>/dev/null || [[ -d "$HOME/.claude" ]]); then
    echo -e "${GRAY}No AI tools detected. Use --all to create all integrations:${RESET}"
    echo -e "  ${BOLD}bash setup.sh --all${RESET}"
  fi
fi

echo ""
echo -e "${BOLD}Next step:${RESET} tell your AI → ${GREEN}\"Detect my stack, fill what you can.\"${RESET}"
$DETECT && echo -e "${GRAY}Or, since stack was pre-filled: ${GREEN}\"Read .readmeAI and continue.\"${RESET}${GRAY}${RESET}"
echo ""
echo -e "${GRAY}Other commands:${RESET}"
echo -e "  ${GRAY}bash setup.sh --validate   check sync with codebase${RESET}"
echo -e "  ${GRAY}bash setup.sh --update     refresh TECH STACK${RESET}"
echo -e "  ${GRAY}bash setup.sh --all        wire all AI tools${RESET}"
echo ""
