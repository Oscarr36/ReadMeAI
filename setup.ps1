# ReadMeAI v2.5 — Smart Setup Script (Windows PowerShell)
# Detects your AI tools and wires .readmeAI into each one automatically.
# Usage: irm https://raw.githubusercontent.com/Oscarr36/ReadMeAI/main/setup.ps1 | iex
#        or: .\setup.ps1 -All   (create all integrations regardless of detection)

param([switch]$All)

$Green  = "`e[32m"; $Gray = "`e[90m"; $Bold = "`e[1m"; $Reset = "`e[0m"

Write-Host ""
Write-Host "${Bold}ReadMeAI Setup${Reset}"
Write-Host "${Gray}─────────────────────────────${Reset}"

# ── Download .readmeAI ────────────────────────────────────────────────────────
Invoke-WebRequest `
  -Uri "https://raw.githubusercontent.com/Oscarr36/ReadMeAI/main/.readmeAI" `
  -OutFile ".readmeAI"
Write-Host "${Green}✓${Reset} .readmeAI downloaded"

$Created = @()

# ── Helper ────────────────────────────────────────────────────────────────────
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

# ── Claude Code ───────────────────────────────────────────────────────────────
$claudeHome = Join-Path $env:USERPROFILE ".claude"
if ($All -or (Get-Command claude -ErrorAction SilentlyContinue) -or (Test-Path $claudeHome)) {
  Write-Integration ".claude\CLAUDE.md" "Claude Code" $ClauseBlock
}

# ── Cursor ────────────────────────────────────────────────────────────────────
if ($All -or (Get-Command cursor -ErrorAction SilentlyContinue) -or (Test-Path ".cursor")) {
  Write-Integration ".cursorrules" "Cursor" $RuleBlock
}

# ── Windsurf ──────────────────────────────────────────────────────────────────
if ($All -or (Get-Command windsurf -ErrorAction SilentlyContinue) -or (Test-Path ".windsurf")) {
  Write-Integration ".windsurfrules" "Windsurf" $RuleBlock
}

# ── GitHub Copilot ────────────────────────────────────────────────────────────
$hasCopilot = $false
if (Get-Command gh -ErrorAction SilentlyContinue) {
  $hasCopilot = (gh extension list 2>$null) -match "copilot"
}
if ($All -or $hasCopilot) {
  Write-Integration ".github\copilot-instructions.md" "GitHub Copilot" $ClauseBlock
}

# ── Aider ─────────────────────────────────────────────────────────────────────
if ($All -or (Get-Command aider -ErrorAction SilentlyContinue)) {
  $aiderFile = ".aider.conf.yml"
  $alreadySet = (Test-Path $aiderFile) -and (Select-String -Path $aiderFile -Pattern "readmeAI" -Quiet)
  if (-not $alreadySet) {
    Add-Content $aiderFile "read:`n  - .readmeAI" -Encoding utf8
    $Created += "Aider → $aiderFile"
  }
}

# ── Continue ──────────────────────────────────────────────────────────────────
$continueHome = Join-Path $env:USERPROFILE ".continue"
if ($All -or (Test-Path $continueHome) -or (Test-Path ".continue")) {
  Write-Integration ".continue\rules\readmeai.md" "Continue" $RuleBlock
}

# ── Summary ───────────────────────────────────────────────────────────────────
Write-Host ""
if ($Created.Count -gt 0) {
  Write-Host "${Bold}AI integrations wired:${Reset}"
  foreach ($item in $Created) {
    Write-Host "  ${Green}✓${Reset} $item"
  }
} else {
  Write-Host "${Gray}No AI tools auto-detected. Run with -All to create all integrations:${Reset}"
  Write-Host "  ${Gray}.\setup.ps1 -All${Reset}"
}

Write-Host ""
Write-Host "${Bold}Next step:${Reset} tell your AI: ${Green}""Detect my stack, fill what you can.""${Reset}"
Write-Host ""
