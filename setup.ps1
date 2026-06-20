# ReadMeAI v3.0 — Smart Setup Script (Windows PowerShell)
# Downloads .readmeAI, wires AI tool integrations, optionally pre-fills stack.
#
# Usage:
#   irm https://raw.githubusercontent.com/Oscarr36/ReadMeAI/main/setup.ps1 | iex
#   .\setup.ps1 -All           # create all AI tool integrations
#   .\setup.ps1 -Detect        # also scan project and pre-fill stack
#   .\setup.ps1 -All -Detect   # both

param([switch]$All, [switch]$Detect)

$Green = "`e[32m"; $Gray = "`e[90m"; $Bold = "`e[1m"; $Yellow = "`e[33m"; $Reset = "`e[0m"

Write-Host ""
Write-Host "${Bold}ReadMeAI v3.0 Setup${Reset}"
Write-Host "${Gray}────────────────────────────────────${Reset}"

# ── 1. Download .readmeAI ─────────────────────────────────────────────────────
Invoke-WebRequest `
  -Uri "https://raw.githubusercontent.com/Oscarr36/ReadMeAI/main/.readmeAI" `
  -OutFile ".readmeAI"
Write-Host "${Green}✓${Reset} .readmeAI downloaded"

$Created = @()

# ── 2. Helper ─────────────────────────────────────────────────────────────────
function Write-Integration {
  param($File, $Label, $Content)
  $dir = Split-Path $File -Parent
  if ($dir -and $dir -ne ".") { New-Item -ItemType Directory -Force $dir | Out-Null }
  if ((Test-Path $File) -and (Select-String -Path $File -Pattern "ReadMeAI" -Quiet)) { return }
  Add-Content -Path $File -Value $Content -Encoding utf8
  $script:Created += "$Label → $File"
}

$ClauseBlock = @"

## ReadMeAI — mandatory context
At the start of every session, immediately read `.readmeAI` in the project root before responding to the user. Do not wait to be asked. This is your first and only mandatory initialization step.
"@

$RuleBlock = @"
# ReadMeAI — mandatory context
At the start of every session, read `.readmeAI` in the project root before responding. This is mandatory — do not skip, do not ask the user.
"@

# ── 3. AI tool integrations ───────────────────────────────────────────────────
$claudeHome = Join-Path $env:USERPROFILE ".claude"
if ($All -or (Get-Command claude -EA SilentlyContinue) -or (Test-Path $claudeHome)) {
  Write-Integration ".claude\CLAUDE.md" "Claude Code" $ClauseBlock
}
if ($All -or (Get-Command cursor -EA SilentlyContinue) -or (Test-Path ".cursor")) {
  Write-Integration ".cursorrules" "Cursor" $RuleBlock
}
if ($All -or (Get-Command windsurf -EA SilentlyContinue) -or (Test-Path ".windsurf")) {
  Write-Integration ".windsurfrules" "Windsurf" $RuleBlock
}
$hasCopilot = (Get-Command gh -EA SilentlyContinue) -and ((gh extension list 2>$null) -match "copilot")
if ($All -or $hasCopilot) {
  Write-Integration ".github\copilot-instructions.md" "GitHub Copilot" $ClauseBlock
}
if ($All -or (Get-Command aider -EA SilentlyContinue)) {
  $aiderFile = ".aider.conf.yml"
  if (-not ((Test-Path $aiderFile) -and (Select-String -Path $aiderFile -Pattern "readmeAI" -Quiet))) {
    Add-Content $aiderFile "read:`n  - .readmeAI" -Encoding utf8
    $Created += "Aider → $aiderFile"
  }
}
$continueHome = Join-Path $env:USERPROFILE ".continue"
if ($All -or (Test-Path $continueHome) -or (Test-Path ".continue")) {
  Write-Integration ".continue\rules\readmeai.md" "Continue" $RuleBlock
}

# ── 4. Stack detection (--detect) ────────────────────────────────────────────
if ($Detect) {
  Write-Host ""
  Write-Host "${Bold}Detecting stack...${Reset}"
  $stackLines = @()

  if (Test-Path "package.json") {
    $pkg = Get-Content "package.json" -Raw
    $runtime = "Node.js"
    $fw = ""; $db = ""; $testFw = ""; $buildFw = ""

    if ($pkg -match '"express"')       { $fw = "Express" }
    if ($pkg -match '"@nestjs/core"')  { $fw = "NestJS" }
    if ($pkg -match '"next"')          { $fw = "Next.js" }
    if ($pkg -match '"nuxt"')          { $fw = "Nuxt" }
    if ($pkg -match '"react"' -and !$fw) { $fw = "React" }
    if ($pkg -match '"vue"' -and !$fw)   { $fw = "Vue" }
    if ($pkg -match '"svelte"' -and !$fw){ $fw = "Svelte" }
    if ($pkg -match '"mongoose"')      { $db = "MongoDB" }
    if ($pkg -match '"prisma"')        { $db = "Prisma" }
    if ($pkg -match '"pg"' -and !$db)  { $db = "PostgreSQL" }
    if ($pkg -match '"redis"')         { $db += " + Redis" }
    if ($pkg -match '"jest"')          { $testFw = "Jest" }
    if ($pkg -match '"vitest"')        { $testFw = "Vitest" }
    if ($pkg -match '"typescript"')    { $runtime = "Node.js + TypeScript" }
    if ($pkg -match '"vite"')          { $buildFw = "Vite" }

    $nodeVer = (node -v 2>$null) -replace '^v','' | Select-Object -First 1
    if (!$nodeVer) { $nodeVer = "—" }

    $stackLines += "| Runtime | $runtime | $nodeVer | — |"
    if ($fw)      { $stackLines += "| Framework | $fw | — | — |" }
    if ($db)      { $stackLines += "| Database | $db | — | — |" }
    if ($testFw)  { $stackLines += "| Test runner | $testFw | — | — |" }
    if ($buildFw) { $stackLines += "| Build tool | $buildFw | — | — |" }
  }

  if ((Test-Path "requirements.txt") -or (Test-Path "pyproject.toml") -or (Test-Path "Pipfile")) {
    $reqs = (Get-Content requirements*.txt, pyproject.toml, Pipfile -EA SilentlyContinue) -join "`n"
    $pyFw = ""
    if ($reqs -match "django")  { $pyFw = "Django" }
    if ($reqs -match "fastapi") { $pyFw = "FastAPI" }
    if ($reqs -match "flask" -and !$pyFw) { $pyFw = "Flask" }
    $pyVer = (python --version 2>$null) -replace "Python ",""
    $stackLines += "| Runtime | Python | $pyVer | — |"
    if ($pyFw) { $stackLines += "| Framework | $pyFw | — | — |" }
  }

  if (Test-Path "go.mod")      { $stackLines += "| Runtime | Go | — | — |" }
  if (Test-Path "Cargo.toml")  { $stackLines += "| Runtime | Rust | — | — |" }
  if (Test-Path "Gemfile")     { $stackLines += "| Runtime | Ruby | — | — |" }
  if ((Test-Path "Dockerfile") -or (Test-Path "docker-compose.yml")) {
    $stackLines += "| Container | Docker | — | docker-compose.yml |"
  }

  if ($stackLines.Count -gt 0) {
    $today = (Get-Date -Format "yyyy-MM-dd")
    $stackSection = @"


## 🛠 TECH STACK
_Auto-detected by setup.ps1 on $today_

| Layer | Technology | Version | Notes |
|-------|-----------|---------|-------|
$($stackLines -join "`n")
"@
    $existing = Get-Content ".readmeAI" -Raw
    if ($existing -notmatch "## 🛠 TECH STACK") {
      Add-Content ".readmeAI" $stackSection -Encoding utf8
      Write-Host "${Green}✓${Reset} Stack pre-filled ($($stackLines.Count) layers detected)"
    }
  } else {
    Write-Host "${Yellow}⚠${Reset} No stack auto-detected. Fill TECH STACK manually."
  }
}

# ── 5. Summary ────────────────────────────────────────────────────────────────
Write-Host ""
if ($Created.Count -gt 0) {
  Write-Host "${Bold}AI integrations wired:${Reset}"
  foreach ($item in $Created) { Write-Host "  ${Green}✓${Reset} $item" }
} else {
  Write-Host "${Gray}No AI tools auto-detected. Run with -All to create all integrations.${Reset}"
}

Write-Host ""
Write-Host "${Bold}Next step:${Reset} tell your AI → ${Green}""Detect my stack, fill what you can.""${Reset}"
if ($Detect) {
  Write-Host "${Gray}Stack was pre-filled. Tell your AI → ${Green}""Read .readmeAI and continue.""${Reset}${Gray}${Reset}"
}
Write-Host ""
