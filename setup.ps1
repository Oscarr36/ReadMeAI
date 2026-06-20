# ReadMeAI v3.1 — Smart Setup Script (Windows PowerShell)
# Downloads .readmeAI and wires it into every AI tool automatically.
#
# Usage:
#   irm https://raw.githubusercontent.com/Oscarr36/ReadMeAI/main/setup.ps1 | iex
#   .\setup.ps1 -All            # create integrations for ALL AI tools
#   .\setup.ps1 -Detect         # pre-fill TECH STACK by scanning the project
#   .\setup.ps1 -Validate       # check .readmeAI is in sync with the codebase
#   .\setup.ps1 -Update         # re-scan and update TECH STACK section
#   .\setup.ps1 -All -Detect    # everything at once

param([switch]$All, [switch]$Detect, [switch]$Validate, [switch]$Update)

$Green = "`e[32m"; $Gray = "`e[90m"; $Bold = "`e[1m"
$Yellow = "`e[33m"; $Red = "`e[31m"; $Reset = "`e[0m"

if ($Update) { $Detect = $true }

# ── Validate mode ─────────────────────────────────────────────────────────────
if ($Validate) {
  Write-Host ""; Write-Host "${Bold}ReadMeAI Validate${Reset}"
  Write-Host "${Gray}────────────────────────────────────${Reset}"
  $errors = 0; $warnings = 0

  if (-not (Test-Path ".readmeAI")) {
    Write-Host "${Red}✗${Reset} .readmeAI not found"; exit 1
  }
  Write-Host "${Green}✓${Reset} .readmeAI exists"

  $content = Get-Content ".readmeAI" -Raw
  if ($content -match "SESSION STATE") {
    if ($content -notmatch "(?ms)### Active objective\s*\n[^—\n]") {
      Write-Host "${Yellow}⚠${Reset}  SESSION STATE blank — run first-time setup"
      $warnings++
    } else { Write-Host "${Green}✓${Reset} SESSION STATE filled" }
  }

  @{
    "Claude Code"     = ".claude\CLAUDE.md"
    "Cursor"          = ".cursorrules"
    "Windsurf"        = ".windsurfrules"
    "GitHub Copilot"  = ".github\copilot-instructions.md"
  }.GetEnumerator() | ForEach-Object {
    if (Test-Path $_.Value) { Write-Host "${Green}✓${Reset} $($_.Key) → $($_.Value)" }
    else { Write-Host "${Gray}–${Reset}  $($_.Key) not wired" }
  }

  Write-Host ""
  if ($errors -eq 0 -and $warnings -eq 0) { Write-Host "${Green}All checks passed.${Reset}" }
  elseif ($errors -eq 0) { Write-Host "${Yellow}$warnings warning(s). Run: .\setup.ps1 -Detect to fix.${Reset}" }
  else { Write-Host "${Red}$errors error(s).${Reset}"; exit 1 }
  exit 0
}

Write-Host ""; Write-Host "${Bold}ReadMeAI v3.1 Setup${Reset}"
Write-Host "${Gray}────────────────────────────────────${Reset}"

# ── 1. Download .readmeAI ─────────────────────────────────────────────────────
Invoke-WebRequest `
  -Uri "https://raw.githubusercontent.com/Oscarr36/ReadMeAI/main/.readmeAI" `
  -OutFile ".readmeAI"
Write-Host "${Green}✓${Reset} .readmeAI downloaded"

$Created = @()

# ── 2. Smart integration content ─────────────────────────────────────────────
$ClaudeContent = @'

## ReadMeAI — Project Context System

**Every session:** Read `.readmeAI` at the start before responding. No exceptions.

**Hot restart** ("continue where we left off"):
1. Read `.readmeAI` QUICK REFERENCE table first (top of file).
2. Read SESSION STATE section.
3. Resume from "Next immediate step" — no recap needed.

**First-time setup** (SESSION STATE is blank):
Run the FIRST-TIME SETUP block at the bottom of `.readmeAI`. Fill every section.

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
'@

$RuleContent = @'
# ReadMeAI — Project Context System

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
'@

# ── 3. Helper ─────────────────────────────────────────────────────────────────
function Write-Integration {
  param($File, $Label, $Content)
  $dir = Split-Path $File -Parent
  if ($dir -and $dir -ne ".") { New-Item -ItemType Directory -Force $dir | Out-Null }
  if ((Test-Path $File) -and (Select-String -Path $File -Pattern "ReadMeAI" -Quiet)) { return }
  Add-Content -Path $File -Value $Content -Encoding utf8
  $script:Created += "$Label → $File"
}

# ── 4. Wire AI tools ──────────────────────────────────────────────────────────
$claudeHome = Join-Path $env:USERPROFILE ".claude"
if ($All -or (Get-Command claude -EA SilentlyContinue) -or (Test-Path $claudeHome)) {
  Write-Integration ".claude\CLAUDE.md" "Claude Code" $ClaudeContent
}
if ($All -or (Get-Command cursor -EA SilentlyContinue) -or (Test-Path ".cursor")) {
  Write-Integration ".cursorrules" "Cursor" $RuleContent
}
if ($All -or (Get-Command windsurf -EA SilentlyContinue) -or (Test-Path ".windsurf")) {
  Write-Integration ".windsurfrules" "Windsurf" $RuleContent
}
$hasCopilot = (Get-Command gh -EA SilentlyContinue) -and ((gh extension list 2>$null) -match "copilot")
if ($All -or $hasCopilot) {
  Write-Integration ".github\copilot-instructions.md" "GitHub Copilot" $ClaudeContent
}
if ($All -or (Get-Command aider -EA SilentlyContinue)) {
  $f = ".aider.conf.yml"
  if (-not ((Test-Path $f) -and (Select-String -Path $f -Pattern "readmeAI" -Quiet))) {
    Add-Content $f "read:`n  - .readmeAI" -Encoding utf8
    $Created += "Aider → $f"
  }
}
$continueHome = Join-Path $env:USERPROFILE ".continue"
if ($All -or (Test-Path $continueHome) -or (Test-Path ".continue")) {
  Write-Integration ".continue\rules\readmeai.md" "Continue" $RuleContent
}

# ── 5. Stack detection ────────────────────────────────────────────────────────
if ($Detect) {
  Write-Host ""; Write-Host "${Bold}Detecting stack...${Reset}"
  $stackLines = @()
  $today = (Get-Date -Format "yyyy-MM-dd")

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
    if ($pkg -match '"webpack"' -and !$buildFw) { $buildFw = "Webpack" }
    $nodeVer = (node -v 2>$null) -replace '^v',''
    if (!$nodeVer) { $nodeVer = "—" }
    $stackLines += "| Runtime | $runtime | $nodeVer | — |"
    if ($fw)      { $stackLines += "| Framework | $fw | — | — |" }
    if ($db)      { $stackLines += "| Database | $db | — | — |" }
    if ($testFw)  { $stackLines += "| Test runner | $testFw | — | — |" }
    if ($buildFw) { $stackLines += "| Build tool | $buildFw | — | — |" }
  }
  if ((Test-Path "requirements.txt") -or (Test-Path "pyproject.toml") -or (Test-Path "Pipfile")) {
    $reqs = (Get-Content requirements*.txt, pyproject.toml, Pipfile -EA SilentlyContinue) -join "`n"
    $pyFw = if ($reqs -match "django") {"Django"} elseif ($reqs -match "fastapi") {"FastAPI"} elseif ($reqs -match "flask") {"Flask"} else {""}
    $pyVer = (python --version 2>$null) -replace "Python ",""
    $stackLines += "| Runtime | Python | $pyVer | — |"
    if ($pyFw) { $stackLines += "| Framework | $pyFw | — | — |" }
  }
  if (Test-Path "go.mod")       { $stackLines += "| Runtime | Go | — | — |" }
  if (Test-Path "Cargo.toml")   { $stackLines += "| Runtime | Rust | — | — |" }
  if (Test-Path "Gemfile")      { $stackLines += "| Runtime | Ruby | — | — |" }
  if ((Test-Path "Dockerfile") -or (Test-Path "docker-compose.yml")) {
    $stackLines += "| Container | Docker | — | docker-compose.yml |"
  }

  if ($stackLines.Count -gt 0) {
    $existing = Get-Content ".readmeAI" -Raw
    if ($existing -notmatch "## 🛠 TECH STACK") {
      $section = "`n`n## 🛠 TECH STACK`n_Auto-detected by setup.ps1 on $today_`n`n| Layer | Technology | Version | Notes |`n|-------|-----------|---------|-------|`n" + ($stackLines -join "`n")
      Add-Content ".readmeAI" $section -Encoding utf8
      Write-Host "${Green}✓${Reset} Stack pre-filled ($($stackLines.Count) layers)"
    } else {
      Write-Host "${Gray}–${Reset}  TECH STACK already present (use -Update to refresh)"
    }
  } else {
    Write-Host "${Yellow}⚠${Reset}  No stack detected. Fill TECH STACK manually."
  }
}

# ── 6. Summary ────────────────────────────────────────────────────────────────
Write-Host ""
if ($Created.Count -gt 0) {
  Write-Host "${Bold}AI integrations wired:${Reset}"
  foreach ($item in $Created) { Write-Host "  ${Green}✓${Reset} $item" }
} elseif (-not $All) {
  Write-Host "${Gray}No AI tools detected. Run: .\setup.ps1 -All${Reset}"
}

Write-Host ""
Write-Host "${Bold}Next step:${Reset} tell your AI → ${Green}""Detect my stack, fill what you can.""${Reset}"
if ($Detect) { Write-Host "${Gray}Or: ${Green}""Read .readmeAI and continue.""${Reset}${Gray}${Reset}" }
Write-Host ""
Write-Host "${Gray}Other flags: -Validate · -Update · -All${Reset}"
Write-Host ""
