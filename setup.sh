#!/usr/bin/env bash
# ReadMeAI v3.4 — Smart Setup Script
# Downloads .readmeAI and wires it into every AI tool automatically.
# Supports: Claude Code, Cursor (legacy + modern .mdc), Windsurf, GitHub Copilot,
#           Aider, Continue, Antigravity CLI (agy), Zed, and any tool that reads AGENTS.md.
#
# Usage:
#   curl -sSL https://raw.githubusercontent.com/Oscarr36/ReadMeAI/main/setup.sh | bash
#   bash setup.sh --all          # wire all AI tools
#   bash setup.sh --detect       # pre-fill TECH STACK by scanning the project
#   bash setup.sh --validate     # check .readmeAI is in sync with the codebase
#   bash setup.sh --update       # re-scan and update TECH STACK section
#   bash setup.sh --all --detect # everything at once
#   bash setup.sh --sync         # auto-update context from last git session (no cost, no API)
#   bash setup.sh --health       # score .readmeAI quality and find gaps

set -euo pipefail

GREEN='\033[0;32m'; GRAY='\033[0;90m'; BOLD='\033[1m'
YELLOW='\033[0;33m'; RED='\033[0;31m'; RESET='\033[0m'

ALL=false; DETECT=false; VALIDATE=false; UPDATE=false; TRIM=false; SYNC=false; HEALTH=false
for arg in "$@"; do
  case "$arg" in
    --all)      ALL=true ;;
    --detect)   DETECT=true ;;
    --validate) VALIDATE=true ;;
    --update)   DETECT=true; UPDATE=true ;;
    --trim)     TRIM=true ;;
    --sync)     SYNC=true ;;
    --health)   HEALTH=true ;;
  esac
done

# ── Trim mode ─────────────────────────────────────────────────────────────────
# Removes optional/setup comment blocks from .readmeAI once setup is done.
# Reduces file from ~300 lines to ~150-180 active lines — eliminates context debt.
if $TRIM; then
  echo ""; echo -e "${BOLD}ReadMeAI Trim${RESET}"
  echo -e "${GRAY}────────────────────────────────────${RESET}"
  [[ ! -f ".readmeAI" ]] && { echo -e "${RED}✗${RESET} .readmeAI not found"; exit 1; }

  BEFORE=$(wc -l < .readmeAI)

  # Check SESSION STATE is filled before trimming setup block
  SESSION_FILLED=false
  if ! grep -A3 "### Active objective" .readmeAI 2>/dev/null | grep -qE "^_|^-\s*—"; then
    SESSION_FILLED=true
  fi

  # Remove the big HTML comment block (optional sections + first-time setup)
  # The comment starts with <!-- OPTIONAL SECTIONS or <!-- FIRST-TIME SETUP
  python3 - ".readmeAI" "$SESSION_FILLED" << 'PYEOF'
import sys, re

path = sys.argv[1]
session_filled = sys.argv[2] == "True"

with open(path, encoding="utf-8") as f:
    content = f.read()

# Remove the optional sections + first-time setup comment block
# These are in one big HTML comment at the end
content = re.sub(
    r'<!--\s*[═\s]*\n\s*OPTIONAL SECTIONS.*?-->\s*$',
    '',
    content,
    flags=re.DOTALL
)

# If session is filled, also remove the first-time setup block if it's separate
if session_filled:
    content = re.sub(
        r'<!--\s*[═\s]*\n\s*FIRST-TIME SETUP.*?-->\s*',
        '',
        content,
        flags=re.DOTALL
    )

# Remove trailing whitespace and ensure clean ending
content = content.rstrip() + "\n"

with open(path, "w", encoding="utf-8") as f:
    f.write(content)

print("ok")
PYEOF

  AFTER=$(wc -l < .readmeAI)
  SAVED=$((BEFORE - AFTER))
  echo -e "${GREEN}✓${RESET} Trimmed ${SAVED} lines (${BEFORE} → ${AFTER})"
  echo -e "${GRAY}  Optional sections are still available in the template at github.com/Oscarr36/ReadMeAI${RESET}"
  echo -e "${GRAY}  To restore: bash setup.sh (re-downloads the full template)${RESET}"
  echo ""
  exit 0
fi

# ── Sync mode ─────────────────────────────────────────────────────────────────
# Reads git diff from the last session and auto-patches STRUCTURE MAP,
# SYMBOL INDEX, and QUICK REFERENCE. No API calls, no cost — pure git + grep.
if $SYNC; then
  echo ""; echo -e "${BOLD}ReadMeAI Sync${RESET}"
  echo -e "${GRAY}────────────────────────────────────${RESET}"
  [[ ! -f ".readmeAI" ]] && { echo -e "${RED}✗${RESET} .readmeAI not found. Run: bash setup.sh"; exit 1; }
  git rev-parse --git-dir &>/dev/null || { echo -e "${RED}✗${RESET} Not a git repository"; exit 1; }

  UPDATED=0; TODAY=$(date '+%Y-%m-%d')

  # 1. Files changed in last commit
  CHANGED=$(git diff HEAD~1 HEAD --name-status 2>/dev/null || \
            git diff --cached --name-status 2>/dev/null || true)

  NEW_FILES=(); MOD_FILES=(); DEL_FILES=()
  while IFS=$'\t' read -r status file _; do
    [[ -z "$status" || -z "$file" ]] && continue
    case "$status" in
      A) NEW_FILES+=("$file") ;;
      M) MOD_FILES+=("$file") ;;
      D) DEL_FILES+=("$file") ;;
    esac
  done <<< "$CHANGED"

  # 2. New files → flag missing from STRUCTURE MAP
  for f in "${NEW_FILES[@]}"; do
    [[ -z "$f" ]] && continue
    if ! grep -qF "$f" .readmeAI 2>/dev/null; then
      echo -e "${YELLOW}+${RESET} New file not in STRUCTURE MAP: ${BOLD}$f${RESET}"
      echo -e "   ${GRAY}→ Add a one-line description in your STRUCTURE MAP section${RESET}"
      ((UPDATED++)) || true
    fi
  done

  # 3. New symbols in added/modified files → suggest SYMBOL INDEX additions
  SYMBOL_HITS=0
  for f in "${NEW_FILES[@]}" "${MOD_FILES[@]}"; do
    [[ -f "$f" ]] || continue
    ext="${f##*.}"
    SYMS=()
    case "$ext" in
      js|ts|jsx|tsx|mjs|cjs)
        while IFS= read -r line; do
          name=$(echo "$line" | grep -oE "(function|const|let|var|class|async function) ([a-zA-Z_][a-zA-Z0-9_]*)" | awk '{print $NF}' | head -1)
          [[ -n "$name" ]] && SYMS+=("$name")
        done < <(grep -E "^(export )?(default )?(async )?function [a-zA-Z]|^(export )?(const|let|var) [a-zA-Z]+ = (async )?\(|^(export )?class [A-Z]" "$f" 2>/dev/null | head -8)
        ;;
      py)
        while IFS= read -r line; do
          name=$(echo "$line" | grep -oE "(def|class) ([a-zA-Z_][a-zA-Z0-9_]*)" | awk '{print $NF}' | head -1)
          [[ -n "$name" ]] && SYMS+=("$name")
        done < <(grep -E "^(async )?def [a-zA-Z_]|^class [A-Z]" "$f" 2>/dev/null | head -8)
        ;;
      go)
        while IFS= read -r line; do
          name=$(echo "$line" | grep -oE "func [A-Za-z_][A-Za-z0-9_]*" | awk '{print $2}' | head -1)
          [[ -n "$name" ]] && SYMS+=("$name")
        done < <(grep -E "^func [A-Z]" "$f" 2>/dev/null | head -8)
        ;;
      rs)
        while IFS= read -r line; do
          name=$(echo "$line" | grep -oE "(fn|struct|impl|trait) ([a-zA-Z_][a-zA-Z0-9_]*)" | awk '{print $NF}' | head -1)
          [[ -n "$name" ]] && SYMS+=("$name")
        done < <(grep -E "^pub (fn|struct|impl|trait) [A-Z]" "$f" 2>/dev/null | head -8)
        ;;
    esac
    for sym in "${SYMS[@]}"; do
      if ! grep -qF "$sym" .readmeAI 2>/dev/null; then
        echo -e "${YELLOW}+${RESET} New symbol not in SYMBOL INDEX: ${BOLD}$sym${RESET} (${GRAY}$f${RESET})"
        ((SYMBOL_HITS++)) || true
        ((UPDATED++)) || true
      fi
    done
  done
  [[ $SYMBOL_HITS -gt 0 ]] && echo -e "   ${GRAY}→ Add these to SYMBOL INDEX with a one-line purpose description${RESET}"

  # 4. Deleted files still referenced in .readmeAI → stale reference warning
  for f in "${DEL_FILES[@]}"; do
    [[ -z "$f" ]] && continue
    if grep -qF "$f" .readmeAI 2>/dev/null; then
      echo -e "${RED}✗${RESET} Deleted file still in .readmeAI: ${BOLD}$f${RESET}"
      echo -e "   ${GRAY}→ Remove or update its entry in STRUCTURE MAP / SYMBOL INDEX${RESET}"
      ((UPDATED++)) || true
    fi
  done

  # 5. Update QUICK REFERENCE "Last action" with latest commit message
  LAST_COMMIT=$(git log -1 --format="%s" 2>/dev/null || true)
  LAST_DATE=$(git log -1 --format="%ci" 2>/dev/null | cut -d' ' -f1 || true)
  if [[ -n "$LAST_COMMIT" ]]; then
    # Patch "| Last action |" row in QUICK REFERENCE table
    if grep -q "| Last action" .readmeAI 2>/dev/null; then
      sed -i "s|| Last action |.*||| Last action | $LAST_DATE — $LAST_COMMIT ||" .readmeAI 2>/dev/null || true
      echo -e "${GREEN}✓${RESET} QUICK REFERENCE → Last action: $LAST_COMMIT"
    fi
  fi

  # 6. Token budget estimate
  LINES=$(wc -l < .readmeAI)
  TOKENS=$(( $(wc -c < .readmeAI) / 4 ))
  echo ""
  echo -e "${GRAY}Context budget: ${LINES} lines · ~${TOKENS} tokens${RESET}"

  echo ""
  if [[ $UPDATED -gt 0 ]]; then
    echo -e "${BOLD}${YELLOW}$UPDATED item(s) need attention${RESET} — update .readmeAI then commit it alongside your code."
  else
    echo -e "${GREEN}Context is in sync with the codebase.${RESET}"
  fi
  echo -e "${GRAY}Run after each coding session: bash setup.sh --sync${RESET}"
  exit 0
fi

# ── Health mode ────────────────────────────────────────────────────────────────
# Scores your .readmeAI on 5 quality dimensions. No cost — pure file analysis.
if $HEALTH; then
  echo ""; echo -e "${BOLD}ReadMeAI Health Check${RESET}"
  echo -e "${GRAY}────────────────────────────────────${RESET}"
  [[ ! -f ".readmeAI" ]] && { echo -e "${RED}✗${RESET} .readmeAI not found"; exit 1; }

  SCORE=0; LINES=$(wc -l < .readmeAI); TOKENS=$(( $(wc -c < .readmeAI) / 4 ))

  # 1. Size (20pts) — ideal is 150-600 lines
  if [[ $LINES -lt 80 ]]; then
    echo -e "${RED}✗${RESET}  [0/20]  Size: $LINES lines — too sparse. Fill key sections."
  elif [[ $LINES -gt 800 ]]; then
    echo -e "${RED}✗${RESET}  [5/20]  Size: $LINES lines — too bloated (AI ignores past ~500). Run: --trim"
    ((SCORE+=5))
  elif [[ $LINES -gt 500 ]]; then
    echo -e "${YELLOW}⚠${RESET}  [12/20] Size: $LINES lines (~$TOKENS tokens) — a bit heavy. Consider --trim"
    ((SCORE+=12))
  else
    echo -e "${GREEN}✓${RESET}  [20/20] Size: $LINES lines (~$TOKENS tokens) — ideal"
    ((SCORE+=20))
  fi

  # 2. QUICK REFERENCE (20pts) — enables hot restart
  QR_ROWS=$(grep -A10 "QUICK REFERENCE" .readmeAI 2>/dev/null | grep -cE "^\|.+\|.+\|" || true)
  if [[ $QR_ROWS -ge 3 ]]; then
    echo -e "${GREEN}✓${RESET}  [20/20] QUICK REFERENCE: $QR_ROWS rows — hot restart ready"
    ((SCORE+=20))
  elif [[ $QR_ROWS -gt 0 ]]; then
    echo -e "${YELLOW}⚠${RESET}  [10/20] QUICK REFERENCE: $QR_ROWS row(s) — partially filled"
    ((SCORE+=10))
  else
    echo -e "${RED}✗${RESET}  [0/20]  QUICK REFERENCE: empty — AI restarts cold every session"
  fi

  # 3. DOMAIN RULES (20pts) — highest-value section
  DR=$(grep -A30 "DOMAIN RULES" .readmeAI 2>/dev/null | grep -cE "^- |^\* |^[0-9]+\." || true)
  if [[ $DR -ge 5 ]]; then
    echo -e "${GREEN}✓${RESET}  [20/20] DOMAIN RULES: $DR rules — AI will respect your project constraints"
    ((SCORE+=20))
  elif [[ $DR -ge 2 ]]; then
    echo -e "${YELLOW}⚠${RESET}  [12/20] DOMAIN RULES: $DR rule(s) — add more for full protection"
    ((SCORE+=12))
  elif [[ $DR -eq 1 ]]; then
    echo -e "${YELLOW}⚠${RESET}  [6/20]  DOMAIN RULES: $DR rule — bare minimum"
    ((SCORE+=6))
  else
    echo -e "${RED}✗${RESET}  [0/20]  DOMAIN RULES: empty — this is the most valuable section"
  fi

  # 4. SESSION STATE (20pts) — continuity between sessions
  if ! grep -A3 "Active objective" .readmeAI 2>/dev/null | grep -qE "^_|^\s*—\s*$|^\s*$"; then
    echo -e "${GREEN}✓${RESET}  [20/20] SESSION STATE: filled — AI can resume without re-explanation"
    ((SCORE+=20))
  else
    echo -e "${YELLOW}⚠${RESET}  [0/20]  SESSION STATE: empty — AI starts cold every session"
  fi

  # 5. SYMBOL INDEX (20pts) — prevents AI filesystem scanning
  SI=$(grep -A50 "SYMBOL INDEX" .readmeAI 2>/dev/null | grep -cE "^\| [a-zA-Z]" || true)
  if [[ $SI -ge 5 ]]; then
    echo -e "${GREEN}✓${RESET}  [20/20] SYMBOL INDEX: $SI entries — AI navigates without scanning files"
    ((SCORE+=20))
  elif [[ $SI -ge 2 ]]; then
    echo -e "${YELLOW}⚠${RESET}  [10/20] SYMBOL INDEX: $SI entries — add key symbols"
    ((SCORE+=10))
  else
    echo -e "${RED}✗${RESET}  [0/20]  SYMBOL INDEX: empty — AI will grep the whole codebase instead"
  fi

  # Result
  echo ""
  BAR=""
  FILLED=$(( SCORE / 5 ))
  for ((i=0; i<20; i++)); do [[ $i -lt $FILLED ]] && BAR+="█" || BAR+="░"; done
  echo -e "${BOLD}Health: [$BAR] $SCORE/100${RESET}"
  if   [[ $SCORE -ge 90 ]]; then echo -e "${GREEN}Excellent — your .readmeAI is fully operational.${RESET}"
  elif [[ $SCORE -ge 70 ]]; then echo -e "${GREEN}Good — a couple sections need attention.${RESET}"
  elif [[ $SCORE -ge 50 ]]; then echo -e "${YELLOW}Fair — key sections missing. AI is partially blind.${RESET}"
  elif [[ $SCORE -ge 30 ]]; then echo -e "${YELLOW}Poor — AI restarts cold and ignores your constraints.${RESET}"
  else echo -e "${RED}Critical — tell your AI: \"Fill .readmeAI, ask only for what you can't infer.\"${RESET}"
  fi
  echo -e "${GRAY}Fix: bash setup.sh --sync  (after coding)  |  bash setup.sh --validate${RESET}"
  exit 0
fi

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
    ["Cursor (.mdc)"]=".cursor/rules/readmeai-context.mdc"
    ["Windsurf"]=".windsurfrules"
    ["GitHub Copilot"]=".github/copilot-instructions.md"
    ["Antigravity CLI / Gemini"]="GEMINI.md"
    ["Zed"]=".rules"
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

echo ""; echo -e "${BOLD}ReadMeAI v3.4 Setup${RESET}"
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
*Context powered by [ReadMeAI v3.4](https://github.com/Oscarr36/ReadMeAI)*
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

# GEMINI.md — Antigravity CLI (agy) — replacement for Gemini CLI (retired June 18 2026)
# Antigravity still reads GEMINI.md from the workspace root (no rename needed)
if $ALL || command -v agy &>/dev/null || command -v gemini &>/dev/null; then
  write_integration "GEMINI.md" "Antigravity CLI / Gemini" "$AGENTS_CONTENT"
fi

# Claude Code — CLAUDE.md + lifecycle hooks
if $ALL || command -v claude &>/dev/null || [[ -d "$HOME/.claude" ]]; then
  write_integration ".claude/CLAUDE.md" "Claude Code" "$CLAUDE_CONTENT"

  # Claude Code hooks — session-end reminder + pre-edit structure check
  HOOKS_FILE=".claude/settings.json"
  if [[ ! -f "$HOOKS_FILE" ]]; then
    mkdir -p .claude
    cat > "$HOOKS_FILE" << 'HOOKSEOF'
{
  "hooks": {
    "UserPromptSubmit": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "if [ -f '.readmeAI' ] && [ ! -f '.claude/.readmeai.active' ]; then touch .claude/.readmeai.active 2>/dev/null; awk '/## .* QUICK REFERENCE/{f=1} f && /^---$/{c++; if(c==2)exit} f{print}' .readmeAI | head -14; fi"
          }
        ]
      }
    ],
    "Stop": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "if [ -f '.readmeAI' ]; then rm -f .claude/.readmeai.active 2>/dev/null; COMMIT=$(git log -1 --format='%h %s' 2>/dev/null || echo 'no git'); echo \"$(date '+%Y-%m-%d %H:%M') | $COMMIT\" > .claude/.readmeai.session 2>/dev/null; echo ''; echo 'ReadMeAI: update QUICK REFERENCE + SESSION STATE before closing. Run: bash setup.sh --sync  (auto-checks what changed)'; fi"
          }
        ]
      }
    ],
    "PostToolUse": [
      {
        "matcher": "Write|Edit",
        "hooks": [
          {
            "type": "command",
            "command": "FILE=\"$TOOL_INPUT_PATH\"; [ -f '.readmeAI' ] && grep -q \"$FILE\" .readmeAI || echo \"ReadMeAI: '$FILE' not in STRUCTURE MAP — add it at session end.\""
          }
        ]
      }
    ]
  }
}
HOOKSEOF
    CREATED+=("Claude Code hooks → .claude/settings.json")
  fi
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

# Zed — uses .rules file in project root (or ~/.config/zed/rules on global)
# Zed's agent reads project-level .rules at session start (@rules mention)
if $ALL || command -v zed &>/dev/null || [[ -d ".zed" ]]; then
  write_integration ".rules" "Zed" "$COMPACT_CONTENT"
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
    [[ -n "$build_fw" ]] && STACK_LINES+=("| Build tool | $build_fw | — | — |")
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
  [[ -f "composer.json" ]] && STACK_LINES+=("| Runtime | PHP | $(php -v 2>/dev/null | head -1 | awk '{print $2}' || echo —) | — |")
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

# ── 6. Git-powered intelligence (--detect) ───────────────────────────────────
if $DETECT && git rev-parse --git-dir &>/dev/null; then
  AI_NOTES_LINES=(); TODAY=$(date '+%Y-%m-%d')

  # 6a. High-churn files → fragile areas → AI NOTES
  echo -e "${BOLD}Scanning git history...${RESET}"
  CHURN=$(git log --since="6 months ago" --name-only --format="" 2>/dev/null \
    | grep -v '^$' | sort | uniq -c | sort -rn | head -5 || true)
  if [[ -n "$CHURN" ]]; then
    while IFS= read -r line; do
      count=$(echo "$line" | awk '{print $1}')
      file=$(echo "$line" | awk '{print $2}')
      [[ -n "$file" && $count -gt 3 ]] && \
        AI_NOTES_LINES+=("$TODAY [~] — High-churn file ($count changes in 6mo): \`$file\` — review before modifying")
    done <<< "$CHURN"
  fi

  # 6b. Extract important in-code comments → AI NOTES
  IMPORTANT_COMMENTS=$(grep -r \
    -e "IMPORTANT:" -e "WARNING:" -e "HACK:" -e "FIXME:" -e "DO NOT" -e "NEVER" \
    --include="*.js" --include="*.ts" --include="*.py" --include="*.go" \
    --include="*.rs" --include="*.rb" --include="*.java" --include="*.php" \
    -l 2>/dev/null | head -5 || true)
  if [[ -n "$IMPORTANT_COMMENTS" ]]; then
    while IFS= read -r file; do
      MATCHES=$(grep -n "IMPORTANT:\|WARNING:\|HACK:\|FIXME:\|DO NOT\|NEVER" "$file" 2>/dev/null \
        | head -3 | sed "s|^|  $file:|" || true)
      [[ -n "$MATCHES" ]] && \
        AI_NOTES_LINES+=("$TODAY [!] — Critical comment found in \`$file\` — read before modifying:
$MATCHES")
    done <<< "$IMPORTANT_COMMENTS"
  fi

  # 6c. Detect commit convention from git log
  COMMIT_SAMPLE=$(git log --format="%s" -20 2>/dev/null | head -5 || true)
  if echo "$COMMIT_SAMPLE" | grep -qE "^(feat|fix|chore|refactor|docs|test)\("; then
    : # Conventional commits detected — already in CONVENTIONS
  fi

  # Append to AI NOTES section
  if [[ ${#AI_NOTES_LINES[@]} -gt 0 ]]; then
    # Insert before the closing comment block
    NOTES_BLOCK="\n"
    for note in "${AI_NOTES_LINES[@]}"; do
      NOTES_BLOCK+="\n$note\n"
    done
    # Append after "## 🗒 AI NOTES" section header placeholder
    if grep -q "_AI: write anything here" .readmeAI 2>/dev/null; then
      printf '\n%s\n' "${AI_NOTES_LINES[@]}" >> .readmeAI
      echo -e "${GREEN}✓${RESET} AI NOTES pre-populated from git history (${#AI_NOTES_LINES[@]} entries)"
    fi
  fi

  echo -e "${GREEN}✓${RESET} Git history scanned"
fi

# ── 7. Add to .gitignore ──────────────────────────────────────────────────────
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
