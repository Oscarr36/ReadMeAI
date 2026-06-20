#!/usr/bin/env bash
# ReadMeAI v3.2 — Smart Setup Script
# Downloads .readmeAI and wires it into every AI tool automatically.
# Supports: Claude Code, Cursor (legacy + modern .mdc), Windsurf, GitHub Copilot,
#           Aider, Continue, Gemini CLI, and any tool that reads AGENTS.md.
#
# Usage:
#   curl -sSL https://raw.githubusercontent.com/Oscarr36/ReadMeAI/main/setup.sh | bash
#   bash setup.sh --all          # wire all AI tools
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
  echo ""; echo -e "${BOLD}ReadMeAI Validate${RESET}"
  echo -e "${GRAY}────────────────────────────────────${RESET}"
  ERRORS=0; WARNINGS=0

  [[ ! -f ".readmeAI" ]] && { echo -e "${RED}✗${RESET} .readmeAI not found"; exit 1; }
  echo -e "${GREEN}✓${RESET} .readmeAI exists"

  if grep -A3 "### Active objective" .readmeAI 2>/dev/null | grep -qE "^_|^-\s*—"; then
    echo -e "${YELLOW}⚠${RESET}  SESSION STATE blank — run first-time setup"
    ((WARNINGS++)) || true
  else
    echo -e "${GREEN}✓${RESET} SESSION STATE filled"
  fi

  declare -A TOOLS=(
    ["AGENTS.md (universal)"]="AGENTS.md"
    ["Claude Code"]=".claude/CLAUDE.md"
    ["Cursor (legacy)"]=".cursorrules"
    ["Cursor (.mdc)"]=".cursor/rules/readmeai.mdc"
    ["Windsurf"]=".windsurfrules"
    ["GitHub Copilot"]=".github/copilot-instructions.md"
    ["Gemini CLI"]="GEMINI.md"
  )
  for tool in "${!TOOLS[@]}"; do
    f="${TOOLS[$tool]}"
    [[ -f "$f" ]] && echo -e "${GREEN}✓${RESET} $tool → $f" \
      || echo -e "${GRAY}–${RESET}  $tool not wired ($f)"
  done

  echo ""
  [[ $ERRORS -gt 0 ]] && { echo -e "${RED}$ERRORS error(s).${RESET}"; exit 1; }
  [[ $WARNINGS -gt 0 ]] && echo -e "${YELLOW}$WARNINGS warning(s). Run: bash setup.sh --detect${RESET}" \
    || echo -e "${GREEN}All checks passed.${RESET}"
  exit 0
fi

echo ""; echo -e "${BOLD}ReadMeAI v3.2 Setup${RESET}"
echo -e "${GRAY}────────────────────────────────────${RESET}"

# ── 1. Download .readmeAI ─────────────────────────────────────────────────────
curl -sSL -o .readmeAI \
  https://raw.githubusercontent.com/Oscarr36/ReadMeAI/main/.readmeAI
echo -e "${GREEN}✓${RESET} .readmeAI downloaded"

CREATED=()

# ── 2. Integration content ────────────────────────────────────────────────────

# AGENTS.md — universal cross-tool standard (concise, ~200 words)
# Read by: Cursor, Windsurf, Copilot agent, Codex, Amp, Factory, Kilo, Zed, Warp, 30+ more
AGENTS_CONTENT='# ReadMeAI Agent Protocol

## Context
Read `.readmeAI` at the project root at the start of every session before responding.

## Session start
1. Read **QUICK REFERENCE** (top of `.readmeAI`) → load **SESSION STATE** → resume.
2. If SESSION STATE is blank → run the **FIRST-TIME SETUP** block at the bottom of `.readmeAI`.
3. Domain rules in `.readmeAI` override your training data. Always.

## Before writing code
- Run **CODE QUALITY checklist** from `.readmeAI` before every output
- Check **DOMAIN RULES** — these are the rules that cause bugs when unknown

## When the task involves auth / input / data
- Also read the optional **SECURITY** section in `.readmeAI`

## When making an architectural decision
- Read **DECISIONS LOG** in `.readmeAI` first — it may already be decided

## Session end (silent — no user prompt needed)
1. Overwrite **QUICK REFERENCE** and **SESSION STATE** with current snapshot
2. Append to **DECISIONS LOG** (append-only, never delete)
3. Update **SYMBOL INDEX** for new or renamed symbols

---
*Context powered by [ReadMeAI v3.2](https://github.com/Oscarr36/ReadMeAI)*
'

# Claude Code — task-aware with memory system integration
CLAUDE_CONTENT='
## ReadMeAI — Project Context System

**Every session:** Read `.readmeAI` at project root before responding. No exceptions.

**Hot restart** ("continue" / session resumes):
1. Read QUICK REFERENCE (top of `.readmeAI`) — 5 lines, ~50 tokens.
2. Read SESSION STATE section.
3. Resume from "Next immediate step" — no recap needed.

**First-time setup** (SESSION STATE blank):
Execute FIRST-TIME SETUP block at the bottom of `.readmeAI`. Fill every section. Ask only what cannot be inferred. Never repeat.

**Before writing any code:**
- Run CODE QUALITY checklist from `.readmeAI`
- Check DOMAIN RULES — these override your training

**Before touching auth / input / data:**
- Read the optional SECURITY section in `.readmeAI`

**Before an architectural decision:**
- Read DECISIONS LOG in `.readmeAI` — may already be decided

**Session end (silent):**
1. Overwrite QUICK REFERENCE and SESSION STATE
2. Append to DECISIONS LOG
3. Update SYMBOL INDEX for new/renamed symbols
'

# Windsurf / Continue / Copilot — compact version
COMPACT_CONTENT='# ReadMeAI — Project Context System

Every session: read `.readmeAI` at project root before responding.

Hot restart: QUICK REFERENCE (top) → SESSION STATE → resume immediately.
First-time setup (blank SESSION STATE): execute FIRST-TIME SETUP block at bottom of `.readmeAI`.

Before code: CODE QUALITY checklist + DOMAIN RULES from `.readmeAI`.
Before auth/data: SECURITY optional section.
Before architecture decisions: DECISIONS LOG first.

Session end (silent): update QUICK REFERENCE, SESSION STATE, append DECISIONS LOG, update SYMBOL INDEX.
'

# Cursor — modern .mdc format with scoped activation (JIT loading)
MDC_CORE='---
description: ReadMeAI core protocol — read .readmeAI at session start
alwaysApply: true
---

Read `.readmeAI` at the project root at the start of every session.

Hot restart: QUICK REFERENCE (top) → SESSION STATE → resume. No recap needed.
First-time setup (SESSION STATE blank): run FIRST-TIME SETUP block at bottom of `.readmeAI`.

Before code: CODE QUALITY checklist + DOMAIN RULES from `.readmeAI`.
Session end (silent): update QUICK REFERENCE, SESSION STATE, append DECISIONS LOG.
'

MDC_SECURITY='---
description: ReadMeAI security rules — loaded when touching auth, middleware, or data access
alwaysApply: false
globs: ["**/auth/**", "**/middleware/**", "**/security/**", "**/guards/**", "**/*.auth.*", "**/login*", "**/signup*", "**/password*", "**/token*", "**/session*", "**/permission*"]
---

Before writing this code, read the SECURITY section in `.readmeAI`.

Core rules (always apply regardless of .readmeAI content):
- No raw SQL with user input — parameterized queries only
- No auth checks client-side only — server must validate every protected request
- No secrets or credentials in source code
- No verbose error messages to the client
- No passwords stored without bcrypt/argon2
- No predictable IDs for sensitive resources — use UUIDs
'

MDC_CONVENTIONS='---
description: ReadMeAI coding conventions — activate when asked about naming, style, or code structure
alwaysApply: false
---

Check CONVENTIONS and CODE QUALITY sections in `.readmeAI` for project-specific rules.

Universal rules:
- Functions: verb prefix (getUser, validateEmail, buildQuery)
- Booleans: is/has/can/should prefix (isLoggedIn, hasPermission)
- Event handlers: handle/on prefix (handleSubmit, onClose)
- Constants: SCREAMING_SNAKE_CASE
- No magic numbers or strings — extract to named constants
- No function longer than ~30 lines — extract helpers
- No nesting deeper than 3 levels — use early returns
'

# ── 3. Helper ─────────────────────────────────────────────────────────────────
write_integration() {
  local file="$1" label="$2" content="$3" dir
  dir="$(dirname "$file")"
  [[ "$dir" != "." ]] && mkdir -p "$dir"
  if [[ -f "$file" ]] && grep -q "ReadMeAI\|readmeAI" "$file" 2>/dev/null; then return; fi
  printf '%s' "$content" > "$file"
  CREATED+=("$label → $file")
}

# ── 4. Wire AI tools ──────────────────────────────────────────────────────────

# AGENTS.md — universal standard (always create — 60k+ repos use it)
write_integration "AGENTS.md" "Universal (AGENTS.md)" "$AGENTS_CONTENT"

# GEMINI.md — Gemini CLI
if $ALL || command -v gemini &>/dev/null; then
  write_integration "GEMINI.md" "Gemini CLI" "$AGENTS_CONTENT"
fi

# Claude Code
if $ALL || command -v claude &>/dev/null || [[ -d "$HOME/.claude" ]]; then
  write_integration ".claude/CLAUDE.md" "Claude Code" "$CLAUDE_CONTENT"
fi

# Cursor — modern .mdc files (preferred) + legacy .cursorrules fallback
if $ALL || command -v cursor &>/dev/null || [[ -d ".cursor" ]]; then
  write_integration ".cursor/rules/readmeai-context.mdc"     "Cursor (core)"        "$MDC_CORE"
  write_integration ".cursor/rules/readmeai-security.mdc"    "Cursor (security)"    "$MDC_SECURITY"
  write_integration ".cursor/rules/readmeai-conventions.mdc" "Cursor (conventions)" "$MDC_CONVENTIONS"
  # Legacy fallback for older Cursor versions
  write_integration ".cursorrules" "Cursor (legacy)" "$COMPACT_CONTENT"
fi

# Windsurf
if $ALL || command -v windsurf &>/dev/null || [[ -d ".windsurf" ]]; then
  write_integration ".windsurfrules" "Windsurf" "$COMPACT_CONTENT"
fi

# GitHub Copilot
if $ALL || (command -v gh &>/dev/null && gh extension list 2>/dev/null | grep -q copilot); then
  write_integration ".github/copilot-instructions.md" "GitHub Copilot" "$CLAUDE_CONTENT"
fi

# Aider
if $ALL || command -v aider &>/dev/null; then
  if [[ ! -f ".aider.conf.yml" ]] || ! grep -q "readmeAI" ".aider.conf.yml" 2>/dev/null; then
    printf 'read:\n  - .readmeAI\n' >> .aider.conf.yml
    CREATED+=("Aider → .aider.conf.yml")
  fi
fi

# Continue
if $ALL || [[ -d "$HOME/.continue" ]] || [[ -d ".continue" ]]; then
  write_integration ".continue/rules/readmeai.md" "Continue" "$COMPACT_CONTENT"
fi

# ── 5. Stack detection ────────────────────────────────────────────────────────
if $DETECT; then
  echo ""; echo -e "${BOLD}Detecting stack...${RESET}"
  STACK_LINES=(); TODAY=$(date '+%Y-%m-%d')

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
    grep -q '"mongoose"'      <<< "$PKG" && db="MongoDB"
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
  [[ -f "go.mod"       ]] && STACK_LINES+=("| Runtime | Go | $(go version 2>/dev/null | awk '{print $3}' | tr -d go || echo —) | — |")
  [[ -f "Cargo.toml"   ]] && STACK_LINES+=("| Runtime | Rust | $(rustc --version 2>/dev/null | awk '{print $2}' || echo —) | — |")
  [[ -f "Gemfile"      ]] && STACK_LINES+=("| Runtime | Ruby | $(ruby -v 2>/dev/null | awk '{print $2}' || echo —) | — |")
  [[ -f "composer.json"]] && STACK_LINES+=("| Runtime | PHP | $(php -v 2>/dev/null | head -1 | awk '{print $2}' || echo —) | — |")
  { [[ -f "Dockerfile" ]] || [[ -f "docker-compose.yml" ]]; } && \
    STACK_LINES+=("| Container | Docker | — | docker-compose.yml |")

  if [[ ${#STACK_LINES[@]} -gt 0 ]]; then
    if $UPDATE && grep -q "## 🛠 TECH STACK" .readmeAI; then
      sed -i '/## 🛠 TECH STACK/,/^---/{/^---/!d}' .readmeAI 2>/dev/null || true
    fi
    if ! grep -q "## 🛠 TECH STACK" .readmeAI; then
      { printf '\n\n## 🛠 TECH STACK\n_Auto-detected %s_\n\n| Layer | Technology | Version | Notes |\n|-------|-----------|---------|-------|\n'; \
        printf '%s\n' "${STACK_LINES[@]}"; } >> .readmeAI
      echo -e "${GREEN}✓${RESET} Stack pre-filled (${#STACK_LINES[@]} layers)"
    else
      echo -e "${GRAY}–${RESET}  TECH STACK exists (use --update to refresh)"
    fi
  else
    echo -e "${YELLOW}⚠${RESET}  No stack detected. Fill manually."
  fi
fi

# ── 6. Add to .gitignore ──────────────────────────────────────────────────────
# Ensure .readmeAI is NOT ignored (some projects have catch-all rules)
if [[ -f ".gitignore" ]] && grep -q "^\.readmeAI$" .gitignore 2>/dev/null; then
  sed -i '/^\.readmeAI$/d' .gitignore
  echo -e "${GREEN}✓${RESET} Removed .readmeAI from .gitignore"
fi

# ── 7. Summary ────────────────────────────────────────────────────────────────
echo ""
if [[ ${#CREATED[@]} -gt 0 ]]; then
  echo -e "${BOLD}AI integrations wired:${RESET}"
  for item in "${CREATED[@]}"; do echo -e "  ${GREEN}✓${RESET} $item"; done
fi

echo ""
echo -e "${BOLD}Next step:${RESET} tell your AI → ${GREEN}\"Detect my stack, fill what you can.\"${RESET}"
$DETECT && echo -e "  ${GRAY}Or: ${GREEN}\"Read .readmeAI and continue.\"${RESET}${GRAY}${RESET}"
echo ""
echo -e "${GRAY}Commands:  --all · --detect · --validate · --update${RESET}"
echo ""
