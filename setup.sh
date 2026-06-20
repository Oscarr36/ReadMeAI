#!/usr/bin/env bash
# ReadMeAI v3.0 — Smart Setup Script
# Downloads .readmeAI, wires AI tool integrations, optionally pre-fills stack.
#
# Usage:
#   curl -sSL https://raw.githubusercontent.com/Oscarr36/ReadMeAI/main/setup.sh | bash
#   bash setup.sh --all          # create all AI tool integrations
#   bash setup.sh --detect       # also scan project and pre-fill stack in .readmeAI
#   bash setup.sh --all --detect # both

set -euo pipefail

GREEN='\033[0;32m'; GRAY='\033[0;90m'; BOLD='\033[1m'; YELLOW='\033[0;33m'; RESET='\033[0m'

ALL=false; DETECT=false
for arg in "$@"; do
  [[ "$arg" == "--all"    ]] && ALL=true
  [[ "$arg" == "--detect" ]] && DETECT=true
done

echo ""
echo -e "${BOLD}ReadMeAI v3.0 Setup${RESET}"
echo -e "${GRAY}────────────────────────────────────${RESET}"

# ── 1. Download .readmeAI ─────────────────────────────────────────────────────
curl -sSL -o .readmeAI \
  https://raw.githubusercontent.com/Oscarr36/ReadMeAI/main/.readmeAI
echo -e "${GREEN}✓${RESET} .readmeAI downloaded"

CREATED=()

# ── 2. Helper ─────────────────────────────────────────────────────────────────
write_integration() {
  local file="$1" label="$2" content="$3" dir
  dir="$(dirname "$file")"
  [[ "$dir" != "." ]] && mkdir -p "$dir"
  if [[ -f "$file" ]] && grep -q "ReadMeAI" "$file" 2>/dev/null; then return; fi
  printf '%s\n' "$content" >> "$file"
  CREATED+=("$label → $file")
}

CLAUDE_BLOCK="
## ReadMeAI — mandatory context
At the start of every session, immediately read \`.readmeAI\` in the \
project root before responding to the user. Do not wait to be asked. \
This is your first and only mandatory initialization step."

RULE_BLOCK="# ReadMeAI — mandatory context
At the start of every session, read \`.readmeAI\` in the project root \
before responding. This is mandatory — do not skip, do not ask the user."

# ── 3. AI tool integrations ───────────────────────────────────────────────────

# Claude Code
if $ALL || command -v claude &>/dev/null || [[ -d "$HOME/.claude" ]]; then
  write_integration ".claude/CLAUDE.md" "Claude Code" "$CLAUDE_BLOCK"
fi

# Cursor
if $ALL || command -v cursor &>/dev/null || [[ -d ".cursor" ]]; then
  write_integration ".cursorrules" "Cursor" "$RULE_BLOCK"
fi

# Windsurf
if $ALL || command -v windsurf &>/dev/null || [[ -d ".windsurf" ]]; then
  write_integration ".windsurfrules" "Windsurf" "$RULE_BLOCK"
fi

# GitHub Copilot
if $ALL || (command -v gh &>/dev/null && gh extension list 2>/dev/null | grep -q copilot); then
  write_integration ".github/copilot-instructions.md" "GitHub Copilot" "$CLAUDE_BLOCK"
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
  write_integration ".continue/rules/readmeai.md" "Continue" "$RULE_BLOCK"
fi

# ── 4. Stack detection (--detect) ────────────────────────────────────────────
if $DETECT; then
  echo ""
  echo -e "${BOLD}Detecting stack...${RESET}"

  STACK_LINES=()

  # Node / JS ecosystem
  if [[ -f "package.json" ]]; then
    PKG=$(cat package.json)
    runtime="Node.js"
    fw=""
    db=""
    test_fw=""
    build_fw=""

    grep -q '"express"'      <<< "$PKG" && fw="Express"
    grep -q '"@nestjs/core"' <<< "$PKG" && fw="NestJS"
    grep -q '"fastify"'      <<< "$PKG" && fw="Fastify"
    grep -q '"hono"'         <<< "$PKG" && fw="Hono"
    grep -q '"next"'         <<< "$PKG" && fw="Next.js"
    grep -q '"nuxt"'         <<< "$PKG" && fw="Nuxt"
    grep -q '"react"'        <<< "$PKG" && [[ -z "$fw" ]] && fw="React"
    grep -q '"vue"'          <<< "$PKG" && [[ -z "$fw" ]] && fw="Vue"
    grep -q '"svelte"'       <<< "$PKG" && [[ -z "$fw" ]] && fw="Svelte"
    grep -q '"@angular/core"'<<< "$PKG" && [[ -z "$fw" ]] && fw="Angular"

    grep -q '"mongoose"'     <<< "$PKG" && db="MongoDB (mongoose)"
    grep -q '"prisma"'       <<< "$PKG" && db="Prisma"
    grep -q '"pg"'           <<< "$PKG" && [[ -z "$db" ]] && db="PostgreSQL"
    grep -q '"mysql2"'       <<< "$PKG" && [[ -z "$db" ]] && db="MySQL"
    grep -q '"redis"'        <<< "$PKG" && db+=" + Redis"

    grep -q '"jest"'         <<< "$PKG" && test_fw="Jest"
    grep -q '"vitest"'       <<< "$PKG" && test_fw="Vitest"
    grep -q '"@playwright"'  <<< "$PKG" && test_fw+=" + Playwright"
    grep -q '"cypress"'      <<< "$PKG" && test_fw+=" + Cypress"

    grep -q '"typescript"'   <<< "$PKG" && runtime="Node.js + TypeScript"
    grep -q '"vite"'         <<< "$PKG" && build_fw="Vite"
    grep -q '"webpack"'      <<< "$PKG" && [[ -z "$build_fw" ]] && build_fw="Webpack"
    grep -q '"turbo"'        <<< "$PKG" && build_fw+=" (Turborepo)"

    node_ver=$(node -v 2>/dev/null | tr -d 'v' || echo "—")
    STACK_LINES+=("| Runtime | $runtime | $node_ver | — |")
    [[ -n "$fw" ]]       && STACK_LINES+=("| Framework | $fw | — | — |")
    [[ -n "$db" ]]       && STACK_LINES+=("| Database | $db | — | — |")
    [[ -n "$test_fw" ]]  && STACK_LINES+=("| Test runner | $test_fw | — | — |")
    [[ -n "$build_fw" ]] && STACK_LINES+=("| Build tool | $build_fw | — | — |")
  fi

  # Python ecosystem
  if [[ -f "requirements.txt" ]] || [[ -f "pyproject.toml" ]] || [[ -f "Pipfile" ]]; then
    REQS=$(cat requirements*.txt Pipfile pyproject.toml 2>/dev/null || true)
    py_fw=""
    grep -qi "django"   <<< "$REQS" && py_fw="Django"
    grep -qi "fastapi"  <<< "$REQS" && py_fw="FastAPI"
    grep -qi "flask"    <<< "$REQS" && [[ -z "$py_fw" ]] && py_fw="Flask"
    py_ver=$(python3 --version 2>/dev/null | awk '{print $2}' || echo "—")
    STACK_LINES+=("| Runtime | Python | $py_ver | — |")
    [[ -n "$py_fw" ]] && STACK_LINES+=("| Framework | $py_fw | — | — |")
  fi

  # Go
  if [[ -f "go.mod" ]]; then
    go_ver=$(go version 2>/dev/null | awk '{print $3}' | tr -d 'go' || echo "—")
    STACK_LINES+=("| Runtime | Go | $go_ver | — |")
  fi

  # Rust
  if [[ -f "Cargo.toml" ]]; then
    rust_ver=$(rustc --version 2>/dev/null | awk '{print $2}' || echo "—")
    STACK_LINES+=("| Runtime | Rust | $rust_ver | — |")
  fi

  # PHP/Laravel
  if [[ -f "composer.json" ]]; then
    php_ver=$(php -v 2>/dev/null | head -1 | awk '{print $2}' || echo "—")
    STACK_LINES+=("| Runtime | PHP | $php_ver | — |")
    grep -q "laravel" composer.json && STACK_LINES+=("| Framework | Laravel | — | — |")
  fi

  # Ruby/Rails
  if [[ -f "Gemfile" ]]; then
    ruby_ver=$(ruby -v 2>/dev/null | awk '{print $2}' || echo "—")
    STACK_LINES+=("| Runtime | Ruby | $ruby_ver | — |")
    grep -q "rails" Gemfile && STACK_LINES+=("| Framework | Rails | — | — |")
  fi

  # Docker
  [[ -f "Dockerfile" ]] || [[ -f "docker-compose.yml" ]] && \
    STACK_LINES+=("| Container | Docker | — | docker-compose.yml |")

  # Inject into .readmeAI TECH STACK table
  if [[ ${#STACK_LINES[@]} -gt 0 ]]; then
    STACK_BLOCK=$(printf '%s\n' "${STACK_LINES[@]}")
    # Replace the placeholder stack line in the table
    sed -i "s/| \*\*Stack\*\* | — .*/| **Stack** | $(echo "${STACK_LINES[0]}" | cut -d'|' -f3 | xargs) | — | — |/" .readmeAI 2>/dev/null || true

    # Append a TECH STACK section after PROJECT IDENTITY
    if ! grep -q "## 🛠 TECH STACK" .readmeAI; then
      cat >> .readmeAI << STACKEOF


## 🛠 TECH STACK
_Auto-detected by setup.sh on $(date '+%Y-%m-%d')_

| Layer | Technology | Version | Notes |
|-------|-----------|---------|-------|
$(printf '%s\n' "${STACK_LINES[@]}")
STACKEOF
      echo -e "${GREEN}✓${RESET} Stack pre-filled ($(echo ${#STACK_LINES[@]}) layers detected)"
    fi
  else
    echo -e "${YELLOW}⚠${RESET} No stack auto-detected. Fill TECH STACK manually."
  fi
fi

# ── 5. Summary ────────────────────────────────────────────────────────────────
echo ""
if [[ ${#CREATED[@]} -gt 0 ]]; then
  echo -e "${BOLD}AI integrations wired:${RESET}"
  for item in "${CREATED[@]}"; do
    echo -e "  ${GREEN}✓${RESET} $item"
  done
else
  echo -e "${GRAY}No AI tools auto-detected.${RESET}"
  echo -e "  Run ${BOLD}bash setup.sh --all${RESET} to create all integrations."
fi

echo ""
echo -e "${BOLD}Next step:${RESET} tell your AI → ${GREEN}\"Detect my stack, fill what you can.\"${RESET}"
if $DETECT; then
  echo -e "${GRAY}Stack was pre-filled. Tell your AI → ${GREEN}\"Read .readmeAI and continue.\"${RESET}${GRAY}${RESET}"
fi
echo ""
