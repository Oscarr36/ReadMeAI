# ReadMeAI v3.2 — Smart Setup Script (Windows PowerShell)
# Downloads .readmeAI and wires it into every AI tool automatically.
# Supports: Claude Code, Cursor (.mdc + legacy), Windsurf, Copilot,
#           Aider, Continue, Gemini CLI, AGENTS.md universal standard.
#
# Usage:
#   irm https://raw.githubusercontent.com/Oscarr36/ReadMeAI/main/setup.ps1 | iex
#   .\setup.ps1 -All            # wire all AI tools
#   .\setup.ps1 -Detect         # pre-fill TECH STACK
#   .\setup.ps1 -Validate       # check sync with codebase
#   .\setup.ps1 -Update         # refresh TECH STACK
#   .\setup.ps1 -All -Detect

param([switch]$All, [switch]$Detect, [switch]$Validate, [switch]$Update)
if ($Update) { $Detect = $true }

$G = "`e[32m"; $Gr = "`e[90m"; $B = "`e[1m"; $Y = "`e[33m"; $R = "`e[31m"; $Re = "`e[0m"

# ── Validate mode ─────────────────────────────────────────────────────────────
if ($Validate) {
  Write-Host ""; Write-Host "${B}ReadMeAI Validate${Re}"; Write-Host "${Gr}────────────────────────────────────${Re}"
  if (-not (Test-Path ".readmeAI")) { Write-Host "${R}✗${Re} .readmeAI not found"; exit 1 }
  Write-Host "${G}✓${Re} .readmeAI exists"
  $content = Get-Content ".readmeAI" -Raw
  if ($content -notmatch "(?ms)### Active objective\s*\n[^_\-\n]") {
    Write-Host "${Y}⚠${Re}  SESSION STATE blank"
  } else { Write-Host "${G}✓${Re} SESSION STATE filled" }
  @{
    "AGENTS.md (universal)"  = "AGENTS.md"
    "GEMINI.md"              = "GEMINI.md"
    "Claude Code"            = ".claude\CLAUDE.md"
    "Cursor (.mdc)"          = ".cursor\rules\readmeai-context.mdc"
    "Cursor (legacy)"        = ".cursorrules"
    "Windsurf"               = ".windsurfrules"
    "GitHub Copilot"         = ".github\copilot-instructions.md"
  }.GetEnumerator() | ForEach-Object {
    if (Test-Path $_.Value) { Write-Host "${G}✓${Re} $($_.Key) → $($_.Value)" }
    else { Write-Host "${Gr}–${Re}  $($_.Key) not wired" }
  }
  exit 0
}

Write-Host ""; Write-Host "${B}ReadMeAI v3.2 Setup${Re}"; Write-Host "${Gr}────────────────────────────────────${Re}"

# ── 1. Download .readmeAI ─────────────────────────────────────────────────────
Invoke-WebRequest -Uri "https://raw.githubusercontent.com/Oscarr36/ReadMeAI/main/.readmeAI" -OutFile ".readmeAI"
Write-Host "${G}✓${Re} .readmeAI downloaded"

$Created = @()

# ── 2. Integration content ────────────────────────────────────────────────────
$AgentsContent = @'
# ReadMeAI Agent Protocol

## Context
Read `.readmeAI` at the project root at the start of every session before responding.

## Session start
1. Read **QUICK REFERENCE** (top of `.readmeAI`) → load **SESSION STATE** → resume.
2. If SESSION STATE blank → run **FIRST-TIME SETUP** block at bottom of `.readmeAI`.
3. Domain rules in `.readmeAI` override your training data. Always.

## Before writing code
- Run **CODE QUALITY checklist** from `.readmeAI` before every output
- Check **DOMAIN RULES** — these are the rules that cause bugs when unknown

## When task involves auth / input / data
- Read optional **SECURITY** section in `.readmeAI`

## Before architectural decisions
- Read **DECISIONS LOG** in `.readmeAI` first — may already be decided

## Session end (silent)
1. Overwrite **QUICK REFERENCE** and **SESSION STATE**
2. Append to **DECISIONS LOG** (never delete)
3. Update **SYMBOL INDEX** for new/renamed symbols

---
*Context powered by [ReadMeAI v3.2](https://github.com/Oscarr36/ReadMeAI)*
'@

$ClaudeContent = @'

## ReadMeAI — Project Context System

**Every session:** Read `.readmeAI` at project root before responding. No exceptions.

**Hot restart** ("continue" / session resumes):
1. Read QUICK REFERENCE (top of `.readmeAI`) — 5 lines, ~50 tokens.
2. Read SESSION STATE section.
3. Resume from "Next immediate step" — no recap needed.

**First-time setup** (SESSION STATE blank):
Execute FIRST-TIME SETUP block at the bottom of `.readmeAI`. Fill every section.

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
'@

$CompactContent = @'
# ReadMeAI — Project Context System

Every session: read `.readmeAI` at project root before responding.

Hot restart: QUICK REFERENCE (top) → SESSION STATE → resume immediately.
First-time setup (blank SESSION STATE): FIRST-TIME SETUP block at bottom of `.readmeAI`.

Before code: CODE QUALITY checklist + DOMAIN RULES from `.readmeAI`.
Before auth/data: SECURITY optional section.
Before architecture: DECISIONS LOG first.

Session end (silent): update QUICK REFERENCE, SESSION STATE, append DECISIONS LOG, update SYMBOL INDEX.
'@

$MdcCore = @'
---
description: ReadMeAI core protocol — read .readmeAI at session start
alwaysApply: true
---

Read `.readmeAI` at the project root at the start of every session.

Hot restart: QUICK REFERENCE (top) → SESSION STATE → resume. No recap needed.
First-time setup (SESSION STATE blank): FIRST-TIME SETUP block at bottom of `.readmeAI`.

Before code: CODE QUALITY checklist + DOMAIN RULES from `.readmeAI`.
Session end (silent): update QUICK REFERENCE, SESSION STATE, append DECISIONS LOG.
'@

$MdcSecurity = @'
---
description: ReadMeAI security rules — loaded when touching auth, middleware, or data access
alwaysApply: false
globs: ["**/auth/**", "**/middleware/**", "**/security/**", "**/guards/**", "**/*.auth.*", "**/login*", "**/signup*", "**/password*", "**/token*", "**/session*", "**/permission*"]
---

Before writing this code, read the SECURITY section in `.readmeAI`.

Core rules:
- No raw SQL with user input — parameterized queries only
- No auth checks client-side only — server must validate every request
- No secrets in source code
- No verbose error messages to the client
- No passwords without bcrypt/argon2
- No predictable IDs for sensitive resources — use UUIDs
'@

$MdcConventions = @'
---
description: ReadMeAI coding conventions — naming, style, code structure
alwaysApply: false
---

Check CONVENTIONS and CODE QUALITY in `.readmeAI` for project-specific rules.

Universal rules:
- Functions: verb prefix (getUser, validateEmail, buildQuery)
- Booleans: is/has/can/should (isLoggedIn, hasPermission)
- Event handlers: handle/on (handleSubmit, onClose)
- Constants: SCREAMING_SNAKE_CASE
- No magic numbers or strings — extract to named constants
- No function longer than ~30 lines — extract helpers
- No nesting deeper than 3 levels — early returns
'@

# ── 3. Helper ─────────────────────────────────────────────────────────────────
function Write-Integration {
  param($File, $Label, $Content)
  $dir = Split-Path $File -Parent
  if ($dir -and $dir -ne ".") { New-Item -ItemType Directory -Force $dir | Out-Null }
  if ((Test-Path $File) -and (Select-String -Path $File -Pattern "ReadMeAI|readmeAI" -Quiet)) { return }
  Set-Content -Path $File -Value $Content -Encoding utf8
  $script:Created += "$Label → $File"
}

# ── 4. Wire AI tools ──────────────────────────────────────────────────────────
# AGENTS.md — universal standard (always create)
Write-Integration "AGENTS.md" "Universal (AGENTS.md)" $AgentsContent

# GEMINI.md
if ($All -or (Get-Command gemini -EA SilentlyContinue)) {
  Write-Integration "GEMINI.md" "Gemini CLI" $AgentsContent
}

# Claude Code
$claudeHome = Join-Path $env:USERPROFILE ".claude"
if ($All -or (Get-Command claude -EA SilentlyContinue) -or (Test-Path $claudeHome)) {
  Write-Integration ".claude\CLAUDE.md" "Claude Code" $ClaudeContent

  # Claude Code hooks — bash commands (Claude Code always runs hooks via bash)
  $hooksFile = ".claude\settings.json"
  if (-not (Test-Path $hooksFile)) {
    New-Item -ItemType Directory -Force ".claude" | Out-Null
    Set-Content -Path $hooksFile -Encoding utf8 -Value @'
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
            "command": "if [ -f '.readmeAI' ]; then rm -f .claude/.readmeai.active 2>/dev/null; COMMIT=$(git log -1 --format='%h %s' 2>/dev/null || echo 'no git'); echo \"$(date '+%Y-%m-%d %H:%M') | $COMMIT\" > .claude/.readmeai.session 2>/dev/null; echo ''; echo 'ReadMeAI: update QUICK REFERENCE + SESSION STATE before closing.'; fi"
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
'@
    $script:Created += "Claude Code hooks -> $hooksFile"
  }
}

# Cursor — modern .mdc files + legacy
if ($All -or (Get-Command cursor -EA SilentlyContinue) -or (Test-Path ".cursor")) {
  Write-Integration ".cursor\rules\readmeai-context.mdc"     "Cursor (core)"        $MdcCore
  Write-Integration ".cursor\rules\readmeai-security.mdc"    "Cursor (security)"    $MdcSecurity
  Write-Integration ".cursor\rules\readmeai-conventions.mdc" "Cursor (conventions)" $MdcConventions
  Write-Integration ".cursorrules" "Cursor (legacy)" $CompactContent
}

# Windsurf
if ($All -or (Get-Command windsurf -EA SilentlyContinue) -or (Test-Path ".windsurf")) {
  Write-Integration ".windsurfrules" "Windsurf" $CompactContent
}

# GitHub Copilot
$hasCopilot = (Get-Command gh -EA SilentlyContinue) -and ((gh extension list 2>$null) -match "copilot")
if ($All -or $hasCopilot) {
  Write-Integration ".github\copilot-instructions.md" "GitHub Copilot" $ClaudeContent
}

# Aider
if ($All -or (Get-Command aider -EA SilentlyContinue)) {
  $f = ".aider.conf.yml"
  if (-not ((Test-Path $f) -and (Select-String -Path $f -Pattern "readmeAI" -Quiet))) {
    Add-Content $f "read:`n  - .readmeAI" -Encoding utf8
    $Created += "Aider → $f"
  }
}

# Continue
$continueHome = Join-Path $env:USERPROFILE ".continue"
if ($All -or (Test-Path $continueHome) -or (Test-Path ".continue")) {
  Write-Integration ".continue\rules\readmeai.md" "Continue" $CompactContent
}

# ── 5. Stack detection ────────────────────────────────────────────────────────
if ($Detect) {
  Write-Host ""; Write-Host "${B}Detecting stack...${Re}"
  $stackLines = @(); $today = (Get-Date -Format "yyyy-MM-dd")

  if (Test-Path "package.json") {
    $pkg = Get-Content "package.json" -Raw
    $runtime = "Node.js"; $fw = ""; $db = ""; $testFw = ""; $buildFw = ""
    if ($pkg -match '"express"')       { $fw = "Express" }
    if ($pkg -match '"@nestjs/core"')  { $fw = "NestJS" }
    if ($pkg -match '"next"')          { $fw = "Next.js" }
    if ($pkg -match '"nuxt"')          { $fw = "Nuxt" }
    if ($pkg -match '"react"' -and !$fw)  { $fw = "React" }
    if ($pkg -match '"vue"' -and !$fw)    { $fw = "Vue" }
    if ($pkg -match '"svelte"' -and !$fw) { $fw = "Svelte" }
    if ($pkg -match '"mongoose"')      { $db = "MongoDB" }
    if ($pkg -match '"prisma"')        { $db = "Prisma" }
    if ($pkg -match '"pg"' -and !$db)  { $db = "PostgreSQL" }
    if ($pkg -match '"redis"')         { $db += if ($db) { " + Redis" } else { "Redis" } }
    if ($pkg -match '"jest"')          { $testFw = "Jest" }
    if ($pkg -match '"vitest"')        { $testFw = "Vitest" }
    if ($pkg -match '"typescript"')    { $runtime = "Node.js + TypeScript" }
    if ($pkg -match '"vite"')          { $buildFw = "Vite" }
    $nodeVer = (node -v 2>$null) -replace '^v',''
    if (!$nodeVer) { $nodeVer = "—" }
    $stackLines += "| Runtime | $runtime | $nodeVer | — |"
    if ($fw)      { $stackLines += "| Framework | $fw | — | — |" }
    if ($db)      { $stackLines += "| Database | $db | — | — |" }
    if ($testFw)  { $stackLines += "| Test runner | $testFw | — | — |" }
    if ($buildFw) { $stackLines += "| Build tool | $buildFw | — | — |" }
  }
  if ((Test-Path "requirements.txt") -or (Test-Path "pyproject.toml")) {
    $reqs = (Get-Content requirements*.txt, pyproject.toml -EA SilentlyContinue) -join "`n"
    $pyFw = if ($reqs -match "django") {"Django"} elseif ($reqs -match "fastapi") {"FastAPI"} elseif ($reqs -match "flask") {"Flask"} else {""}
    $pyVer = (python --version 2>$null) -replace "Python ",""
    $stackLines += "| Runtime | Python | $pyVer | — |"
    if ($pyFw) { $stackLines += "| Framework | $pyFw | — | — |" }
  }
  if (Test-Path "go.mod")      { $stackLines += "| Runtime | Go | — | — |" }
  if (Test-Path "Cargo.toml")  { $stackLines += "| Runtime | Rust | — | — |" }
  if ((Test-Path "Dockerfile") -or (Test-Path "docker-compose.yml")) {
    $stackLines += "| Container | Docker | — | docker-compose.yml |"
  }

  if ($stackLines.Count -gt 0) {
    $existing = Get-Content ".readmeAI" -Raw
    if ($existing -notmatch "## 🛠 TECH STACK") {
      $section = "`n`n## 🛠 TECH STACK`n_Auto-detected $today_`n`n| Layer | Technology | Version | Notes |`n|-------|-----------|---------|-------|`n" + ($stackLines -join "`n")
      Add-Content ".readmeAI" $section -Encoding utf8
      Write-Host "${G}✓${Re} Stack pre-filled ($($stackLines.Count) layers)"
    } else {
      Write-Host "${Gr}–${Re}  TECH STACK exists (use -Update to refresh)"
    }
  } else { Write-Host "${Y}⚠${Re}  No stack detected." }
}

# ── 6. Summary ────────────────────────────────────────────────────────────────
Write-Host ""
if ($Created.Count -gt 0) {
  Write-Host "${B}AI integrations wired:${Re}"
  foreach ($item in $Created) { Write-Host "  ${G}✓${Re} $item" }
}
Write-Host ""
Write-Host "${B}Next step:${Re} tell your AI → ${G}""Detect my stack, fill what you can.""${Re}"
if ($Detect) { Write-Host "  ${Gr}Or: ${G}""Read .readmeAI and continue.""${Re}${Gr}${Re}" }
Write-Host ""
Write-Host "${Gr}Flags: -All · -Detect · -Validate · -Update${Re}"
Write-Host ""
