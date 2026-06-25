# ReadMeAI v4.5 — Smart Setup Script (Windows PowerShell)
# Downloads .readmeAI and wires it into every AI tool automatically.
# Supports: Claude Code, Cursor (.mdc + legacy), Windsurf, Copilot,
#           Aider, Continue, Antigravity CLI (agy), Zed, Cline, Roo Code, Junie,
#           AGENTS.md universal standard.
#
# Usage:
#   irm https://raw.githubusercontent.com/Oscarr36/ReadMeAI/main/setup.ps1 | iex
#   .\setup.ps1 -All            # wire all AI tools
#   .\setup.ps1 -Detect         # pre-fill TECH STACK
#   .\setup.ps1 -Validate       # check sync with codebase
#   .\setup.ps1 -Update         # refresh TECH STACK
#   .\setup.ps1 -Sync           # auto-update context from last git commit (no cost)
#   .\setup.ps1 -Health         # score .readmeAI quality [0-100]
#   .\setup.ps1 -Lint           # list every unfilled field + actionable issues in .readmeAI
#   .\setup.ps1 -Upgrade        # upgrade to the latest ReadMeAI version
#   .\setup.ps1 -All -Detect

param([switch]$All, [switch]$Detect, [switch]$Validate, [switch]$Update, [switch]$Sync, [switch]$Health, [switch]$Trim, [switch]$Lint, [switch]$Upgrade, [string]$New = "")
if ($Update) { $Detect = $true }

$ESC = [char]27
# Enable ANSI/VT in Windows Console Host — falls back to plain text if unsupported.
# Colors are only assigned if VT enable succeeds; otherwise all color vars = ''.
try {
  if (-not ([System.Management.Automation.PSTypeName]'RMAConsole').Type) {
    Add-Type -TypeDefinition @'
using System; using System.Runtime.InteropServices;
public class RMAConsole {
    [DllImport("kernel32.dll")] public static extern IntPtr GetStdHandle(int n);
    [DllImport("kernel32.dll")] public static extern bool GetConsoleMode(IntPtr h, out uint m);
    [DllImport("kernel32.dll")] public static extern bool SetConsoleMode(IntPtr h, uint m);
}
'@
  }
  $h = [RMAConsole]::GetStdHandle(-11); [uint32]$mMode = 0
  [RMAConsole]::GetConsoleMode($h, [ref]$mMode) | Out-Null
  [RMAConsole]::SetConsoleMode($h, $mMode -bor [uint32]4) | Out-Null
  $G = "$ESC[32m"; $Gr = "$ESC[90m"; $B = "$ESC[1m"; $Y = "$ESC[33m"; $R = "$ESC[31m"; $Re = "$ESC[0m"
} catch {
  $G = ''; $Gr = ''; $B = ''; $Y = ''; $R = ''; $Re = ''
}

# ── Version check helper ──────────────────────────────────────────────────────
function Invoke-VersionCheck {
  if (-not (Test-Path ".readmeAI")) { return }
  $localVer = (Select-String -Path ".readmeAI" -Pattern "READMEAI v[\d.]+" -EA SilentlyContinue |
    Select-Object -First 1).Matches.Value -replace "READMEAI ",""
  if (-not $localVer) { return }
  try {
    $remoteRaw = Invoke-WebRequest -Uri "https://raw.githubusercontent.com/Oscarr36/ReadMeAI/main/.readmeAI" `
      -TimeoutSec 3 -UseBasicParsing -EA Stop
    $remoteVer = ([regex]::Match($remoteRaw.Content, "READMEAI v[\d.]+")).Value -replace "READMEAI ",""
  } catch { return }
  if ($remoteVer -and $remoteVer -ne $localVer) {
    Write-Host ""; Write-Host "${Y}⬆  ReadMeAI $remoteVer available (you have $localVer)${Re}"
    Write-Host "   ${Gr}→ Upgrade: .\setup.ps1 -Upgrade${Re}"
  }
}

# ── Upgrade mode ──────────────────────────────────────────────────────────────
if ($Upgrade) {
  Write-Host ""; Write-Host "${B}ReadMeAI Upgrade${Re}"; Write-Host "${Gr}────────────────────────────────────${Re}"
  $localVer = "unknown"
  if (Test-Path ".readmeAI") {
    $verMatch = Select-String -Path ".readmeAI" -Pattern "READMEAI v[\d.]+" -EA SilentlyContinue | Select-Object -First 1
    if ($verMatch) { $localVer = $verMatch.Matches.Value -replace "READMEAI ","" }
  }
  Write-Host "Current: ${B}$localVer${Re}"
  Write-Host "Fetching latest setup from GitHub..."
  $setupUrl = "https://raw.githubusercontent.com/Oscarr36/ReadMeAI/main/setup.ps1"
  Invoke-Expression (Invoke-WebRequest -Uri $setupUrl -UseBasicParsing).Content
  exit 0
}

# ── Sync mode — auto-update context from last git commit (no API, no cost) ───
if ($Sync) {
  Write-Host ""; Write-Host "${B}ReadMeAI Sync${Re}"; Write-Host "${Gr}────────────────────────────────────${Re}"
  if (-not (Test-Path ".readmeAI")) { Write-Host "${R}✗${Re} .readmeAI not found. Run: .\setup.ps1"; exit 1 }
  $gitDir = git rev-parse --git-dir 2>$null
  if (-not $gitDir) { Write-Host "${R}✗${Re} Not a git repository"; exit 1 }

  $updated = 0; $content = Get-Content ".readmeAI" -Raw

  # 1. Changed files in last commit
  $changed = git diff HEAD~1 HEAD --name-status 2>$null
  $newFiles = @(); $delFiles = @()
  $changed | ForEach-Object {
    if ($_ -match '^A\t(.+)') { $newFiles += $Matches[1] }
    elseif ($_ -match '^D\t(.+)') { $delFiles += $Matches[1] }
  }

  # 2. New files not in .readmeAI
  foreach ($f in $newFiles) {
    if ($f -and $content -notmatch [regex]::Escape($f)) {
      Write-Host "${Y}+${Re} New file not in STRUCTURE MAP: ${B}$f${Re}"
      Write-Host "   ${Gr}→ Add a one-line description in STRUCTURE MAP${Re}"
      $updated++
    }
  }

  # 3. Deleted files still referenced
  foreach ($f in $delFiles) {
    if ($f -and $content -match [regex]::Escape($f)) {
      Write-Host "${R}✗${Re} Deleted file still in .readmeAI: ${B}$f${Re}"
      Write-Host "   ${Gr}→ Remove from STRUCTURE MAP / SYMBOL INDEX${Re}"
      $updated++
    }
  }

  # 4. Auto-patch QUICK REFERENCE Last action
  $lastMsg  = git log -1 --format='%s'  2>$null
  $lastDate = (git log -1 --format='%ci' 2>$null) -replace ' .*',''
  if ($lastMsg -and $lastDate) {
    $lines = Get-Content ".readmeAI"
    $patched = $false
    $lines = $lines | ForEach-Object {
      if ($_ -match '\*\*Last action\*\*') { $patched = $true; "| **Last action** | $lastDate — $lastMsg |" }
      else { $_ }
    }
    if ($patched) {
      Set-Content ".readmeAI" $lines -Encoding utf8
      Write-Host "${G}✓${Re} QUICK REFERENCE → Last action: $lastMsg"
      $updated++
    }
  }

  $lineCount = (Get-Content ".readmeAI").Count
  $tokens    = [int]((Get-Item ".readmeAI").Length / 4)
  Write-Host ""; Write-Host "${Gr}Context: $lineCount lines · ~$tokens tokens${Re}"; Write-Host ""
  if ($updated -gt 0) { Write-Host "${Y}${B}$updated item(s) need attention${Re} — update .readmeAI then commit." }
  else { Write-Host "${G}Context is in sync with the codebase.${Re}" }
  Invoke-VersionCheck
  exit 0
}

# ── Health mode — quality score [0-100] across 5 dimensions ──────────────────
if ($Health) {
  Write-Host ""; Write-Host "${B}ReadMeAI Health Check${Re}"; Write-Host "${Gr}────────────────────────────────────${Re}"
  if (-not (Test-Path ".readmeAI")) { Write-Host "${R}✗${Re} .readmeAI not found"; exit 1 }
  $score = 0; $content = Get-Content ".readmeAI" -Raw
  $lineCount = (Get-Content ".readmeAI").Count; $tokens = [int]((Get-Item ".readmeAI").Length / 4)

  # 1. Size (20pts)
  if     ($lineCount -lt 80)   { Write-Host "${R}✗${Re}  [0/20]  Size: $lineCount lines — too sparse" }
  elseif ($lineCount -gt 800)  { Write-Host "${R}✗${Re}  [5/20]  Size: $lineCount lines — too bloated. Run: -Trim"; $score += 5 }
  elseif ($lineCount -gt 500)  { Write-Host "${Y}⚠${Re}  [12/20] Size: $lineCount lines (~$tokens tokens) — heavy"; $score += 12 }
  else                         { Write-Host "${G}✓${Re}  [20/20] Size: $lineCount lines (~$tokens tokens)"; $score += 20 }

  # 2. QUICK REFERENCE (20pts) — scoped to just that section
  $qrMatch = [regex]::Match($content, '(?s)## .* QUICK REFERENCE.*?(?=\n---)')
  $qrSection = if ($qrMatch.Success) { $qrMatch.Value } else { "" }
  $qrRows = ([regex]::Matches($qrSection, '(?m)^\| \*\*[A-Z]')).Count
  $qrFilled = $qrRows -gt 0 -and $qrSection -notmatch '\| — \|'
  if     ($qrFilled)     { Write-Host "${G}✓${Re}  [20/20] QUICK REFERENCE: filled — hot restart ready"; $score += 20 }
  elseif ($qrRows -gt 0) { Write-Host "${Y}⚠${Re}  [10/20] QUICK REFERENCE: table exists but all values are — (blank)"; $score += 10 }
  else                   { Write-Host "${R}✗${Re}  [0/20]  QUICK REFERENCE: empty — AI restarts cold every session" }

  # 3. DOMAIN RULES (20pts) — scoped to just that section
  $drMatch = [regex]::Match($content, '(?s)## .* DOMAIN RULES.*?(?=\n---)')
  $drSection = if ($drMatch.Success) { $drMatch.Value } else { "" }
  $dr = ([regex]::Matches($drSection, '(?m)^- (?!—)')).Count
  if     ($dr -ge 5) { Write-Host "${G}✓${Re}  [20/20] DOMAIN RULES: $dr rules"; $score += 20 }
  elseif ($dr -ge 2) { Write-Host "${Y}⚠${Re}  [12/20] DOMAIN RULES: $dr rules — add more"; $score += 12 }
  elseif ($dr -eq 1) { Write-Host "${Y}⚠${Re}  [6/20]  DOMAIN RULES: 1 rule — bare minimum"; $score += 6 }
  else               { Write-Host "${R}✗${Re}  [0/20]  DOMAIN RULES: empty — most valuable section" }

  # 4. SESSION STATE (20pts)
  if ($content -notmatch "One sentence: what are we building") {
    Write-Host "${G}✓${Re}  [20/20] SESSION STATE: filled"; $score += 20
  } else { Write-Host "${Y}⚠${Re}  [0/20]  SESSION STATE: empty — AI starts cold every session" }

  # 5. SYMBOL INDEX (20pts) — scoped to just that section, exclude placeholder rows
  $siMatch = [regex]::Match($content, '(?s)## .* SYMBOL INDEX.*?(?=\n---)')
  $siSection = if ($siMatch.Success) { $siMatch.Value } else { "" }
  $si = ([regex]::Matches($siSection, '(?m)^\| [a-zA-Z`][^\|]*\| [^\|]+\| (?!—)[^\|]+\|')).Count
  if     ($si -ge 5) { Write-Host "${G}✓${Re}  [20/20] SYMBOL INDEX: $si entries"; $score += 20 }
  elseif ($si -ge 2) { Write-Host "${Y}⚠${Re}  [10/20] SYMBOL INDEX: $si entries — add more"; $score += 10 }
  else               { Write-Host "${R}✗${Re}  [0/20]  SYMBOL INDEX: empty" }

  Write-Host ""
  $filled = [int]($score / 5)
  $bar = ([string]"█" * $filled) + ([string]"░" * (20 - $filled))
  Write-Host "${B}Health: [$bar] $score/100${Re}"
  if     ($score -ge 90) { Write-Host "${G}Excellent — your .readmeAI is fully operational.${Re}" }
  elseif ($score -ge 70) { Write-Host "${G}Good — a couple sections need attention.${Re}" }
  elseif ($score -ge 50) { Write-Host "${Y}Fair — key sections missing. AI is partially blind.${Re}" }
  else                   { Write-Host "${R}Critical — tell your AI: 'Fill .readmeAI, ask only for what you can't infer.'${Re}" }
  Invoke-VersionCheck
  exit 0
}

# ── Lint mode ─────────────────────────────────────────────────────────────────
# Finds every unfilled placeholder + actionable issues. Different from -Health
# (which scores quality) — lint gives a precise list of exactly what to fix.
if ($Lint) {
  Write-Host ""; Write-Host "${B}ReadMeAI Lint${Re}"; Write-Host "${Gr}────────────────────────────────────${Re}"
  if (-not (Test-Path ".readmeAI")) { Write-Host "${R}✗${Re} .readmeAI not found"; exit 1 }

  $issues  = 0
  $content = Get-Content ".readmeAI" -Raw
  $lines   = Get-Content ".readmeAI"

  # 1. Unfilled placeholder rows — pattern: | **Field** | — |
  $blanks = $lines | Where-Object { $_ -match '^\| \*\*[^|]+\*\* \| — \|' }
  foreach ($row in $blanks) {
    if ($row -match '\*\*([^*]+)\*\*') {
      Write-Host "  ${Y}●${Re} Unfilled: ${B}$($Matches[1])${Re}"
      $issues++
    }
  }
  if ($blanks.Count -gt 0) {
    Write-Host "    ${Gr}→ Tell your AI: 'Fill .readmeAI — ask only for what you can't infer'${Re}"
  }

  # 2. File bloat
  $lineCount = $lines.Count
  if     ($lineCount -gt 800) {
    Write-Host "  ${R}●${Re} File too large: ${B}$lineCount lines${Re} (>800 means AI stops reading). Run: -Trim"
    $issues++
  } elseif ($lineCount -gt 600) {
    Write-Host "  ${Y}●${Re} File heavy: ${B}$lineCount lines${Re} (>600). Consider pruning old DECISIONS LOG entries."
    $issues++
  }

  # 3. Stale sync — Last action date > 14 days ago
  $lastDateMatch = [regex]::Match($content, '\*\*Last action\*\*[^\n]*(\d{4}-\d{2}-\d{2})')
  if ($lastDateMatch.Success) {
    try {
      $lastDate = [datetime]::ParseExact($lastDateMatch.Groups[1].Value, 'yyyy-MM-dd', $null)
      $days = ([datetime]::Today - $lastDate).Days
      if ($days -gt 14) {
        Write-Host "  ${Y}●${Re} Context stale: last sync ${B}$days days ago${Re} ($($lastDateMatch.Groups[1].Value)). Run: -Sync"
        $issues++
      }
    } catch { }
  }

  Write-Host ""
  if ($issues -eq 0) { Write-Host "${G}✓ No issues — .readmeAI is clean.${Re}" }
  else { Write-Host "${Y}${B}$issues issue(s) found.${Re} Fix in .readmeAI then re-run: .\setup.ps1 -Lint" }
  Invoke-VersionCheck
  exit 0
}

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
    "AGENTS.md (universal)"    = "AGENTS.md"
    "Antigravity CLI / Gemini" = "GEMINI.md"
    "Claude Code"              = ".claude\CLAUDE.md"
    "Cursor (.mdc)"            = ".cursor\rules\readmeai-context.mdc"
    "Cursor (legacy)"          = ".cursorrules"
    "Windsurf"                 = ".windsurfrules"
    "GitHub Copilot"           = ".github\copilot-instructions.md"
    "Zed"                      = ".rules"
    "Cline"                    = ".clinerules\readmeai.md"
    "Roo Code"                 = ".roo\rules\readmeai.md"
    "Junie (JetBrains)"        = ".junie\guidelines.md"
    "Continue"                 = ".continue\rules\readmeai.md"
    "Aider"                    = ".aider.conf.yml"
  }.GetEnumerator() | ForEach-Object {
    if (Test-Path $_.Value) { Write-Host "${G}✓${Re} $($_.Key) → $($_.Value)" }
    else { Write-Host "${Gr}–${Re}  $($_.Key) not wired" }
  }
  exit 0
}

Write-Host ""; Write-Host "${B}ReadMeAI v4.5 Setup${Re}"; Write-Host "${Gr}────────────────────────────────────${Re}"

# ── 1. Download .readmeAI (only if not already present) ──────────────────────
if (Test-Path ".readmeAI") {
  Write-Host "${Gr}–${Re}  .readmeAI already exists — preserved (run -Upgrade to refresh)"
} else {
  Invoke-WebRequest -Uri "https://raw.githubusercontent.com/Oscarr36/ReadMeAI/main/.readmeAI" -OutFile ".readmeAI" -UseBasicParsing
  Write-Host "${G}✓${Re} .readmeAI downloaded"
}

# ── -New: inject idea into PROJECT IDENTITY so AI bootstraps the project ──────
if ($New) {
  $content = Get-Content ".readmeAI" -Raw
  $content = $content -replace [regex]::Escape('| **Name** | — |'), "| **Name** | _$New_ |"
  Set-Content ".readmeAI" $content -Encoding utf8
  Write-Host "${G}✓${Re} Project idea saved → .readmeAI (PROJECT IDENTITY)"
  Write-Host ""
  Write-Host "${B}New project ready.${Re} Start your AI session and say:"
  Write-Host "  ${G}""Read .readmeAI and bootstrap the project.""${Re}"
  Write-Host "  ${Gr}The AI will recommend a stack and scaffold the structure.${Re}"
}

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
*Context powered by [ReadMeAI v4.5](https://github.com/Oscarr36/ReadMeAI)*
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

# GEMINI.md — Antigravity CLI (agy) — replacement for Gemini CLI (retired June 18 2026)
if ($All -or (Get-Command agy -EA SilentlyContinue) -or (Get-Command gemini -EA SilentlyContinue)) {
  Write-Integration "GEMINI.md" "Antigravity CLI / Gemini" $AgentsContent
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
            "command": "if [ -f '.readmeAI' ] && [ ! -f '.claude/.readmeai.active' ]; then touch .claude/.readmeai.active 2>/dev/null; LINES=$(wc -l < .readmeAI 2>/dev/null || echo 0); BYTES=$(wc -c < .readmeAI 2>/dev/null || echo 0); TOKENS=$(( BYTES / 4 )); printf '\\nReadMeAI context: %s lines ~%s tokens\\n' \"$LINES\" \"$TOKENS\"; awk '/## .* QUICK REFERENCE/{f=1} f && /^---$/{c++; if(c==2)exit} f{print}' .readmeAI | head -14; fi"
          }
        ]
      }
    ],
    "Stop": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "rm -f .claude/.readmeai.active 2>/dev/null; bash .claude/readmeai-sync.sh 2>/dev/null || true"
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
    $script:Created += "Claude Code hooks → $hooksFile"
  }

  # Generate readmeai-sync.sh — autonomous sync engine (called by Stop hook)
  $syncScript = ".claude\readmeai-sync.sh"
  if (-not (Test-Path $syncScript)) {
    $syncContent = @'
#!/usr/bin/env bash
# ReadMeAI Autonomous Sync Engine — runs automatically at session end via Stop hook.
# Also called by git post-commit hook. No API calls, no cost.
[[ -f '.readmeAI' ]] || exit 0

LINES=$(wc -l < .readmeAI 2>/dev/null || echo 0)
TOKENS=$(( $(wc -c < .readmeAI 2>/dev/null || echo 0) / 4 ))
printf '\nReadMeAI Sync — %s lines · ~%s tokens\n' "$LINES" "$TOKENS"

# 1. Auto-patch QUICK REFERENCE Last action from last git commit
if git rev-parse --git-dir &>/dev/null 2>&1; then
  LAST_COMMIT=$(git log -1 --format='%s' 2>/dev/null || true)
  LAST_DATE=$(git log -1 --format='%ci' 2>/dev/null | cut -d' ' -f1 || true)
  if [[ -n "$LAST_COMMIT" ]] && grep -q 'Last action' .readmeAI 2>/dev/null; then
    SAFE_MSG=$(printf '%s' "$LAST_COMMIT" | sed 's/[@&/\\]/\\&/g')
    sed -i "s@.*Last action.*@| **Last action** | $LAST_DATE — $SAFE_MSG |@" .readmeAI 2>/dev/null || true
    printf 'ReadMeAI ✓ QUICK REFERENCE auto-patched\n'
  fi

  # 2. Flag new files from last commit not in .readmeAI
  git diff HEAD~1 HEAD --name-status 2>/dev/null | while IFS=$'\t' read -r STATUS FILE; do
    [[ -z "$FILE" ]] && continue
    if [[ "$STATUS" == "A" ]] && ! grep -qF "$FILE" .readmeAI 2>/dev/null; then
      printf '+ New file not in STRUCTURE MAP: %s\n' "$FILE"
    elif [[ "$STATUS" == "D" ]] && grep -qF "$FILE" .readmeAI 2>/dev/null; then
      printf '✗ Deleted file still in .readmeAI: %s\n' "$FILE"
    fi
  done

  # 3. Flag new public symbols not in SYMBOL INDEX
  while IFS= read -r f; do
    [[ -f "$f" ]] || continue
    ext="${f##*.}"
    case "$ext" in
      js|ts|jsx|tsx|mjs)
        while IFS= read -r sym; do
          grep -qF "$sym" .readmeAI 2>/dev/null || printf '+ New symbol not in SYMBOL INDEX: %s (%s)\n' "$sym" "$f"
        done < <(grep -oE "(export (default )?(async )?function|export (const|let|class)) [a-zA-Z_][a-zA-Z0-9_]*" "$f" 2>/dev/null \
          | grep -oE "[a-zA-Z_][a-zA-Z0-9_]*$" | head -5 || true)
        ;;
      py)
        while IFS= read -r sym; do
          grep -qF "$sym" .readmeAI 2>/dev/null || printf '+ New symbol not in SYMBOL INDEX: %s (%s)\n' "$sym" "$f"
        done < <(grep -E "^(async )?def [a-zA-Z_]|^class [A-Z]" "$f" 2>/dev/null \
          | grep -oE "(def|class) [a-zA-Z_][a-zA-Z0-9_]*" | awk '{print $2}' | head -5 || true)
        ;;
      go)
        while IFS= read -r sym; do
          grep -qF "$sym" .readmeAI 2>/dev/null || printf '+ New symbol not in SYMBOL INDEX: %s (%s)\n' "$sym" "$f"
        done < <(grep -E "^func [A-Z]" "$f" 2>/dev/null \
          | grep -oE "func [A-Z][a-zA-Z0-9_]*" | awk '{print $2}' | head -5 || true)
        ;;
      rs)
        while IFS= read -r sym; do
          grep -qF "$sym" .readmeAI 2>/dev/null || printf '+ New symbol not in SYMBOL INDEX: %s (%s)\n' "$sym" "$f"
        done < <(grep -E "^pub (fn|struct|trait) [A-Z]" "$f" 2>/dev/null \
          | grep -oE "(fn|struct|trait) [A-Z][a-zA-Z0-9_]*" | awk '{print $2}' | head -5 || true)
        ;;
      rb)
        while IFS= read -r sym; do
          grep -qF "$sym" .readmeAI 2>/dev/null || printf '+ New symbol not in SYMBOL INDEX: %s (%s)\n' "$sym" "$f"
        done < <(grep -E "^(class|module) [A-Z]|^ {0,2}def [a-z]" "$f" 2>/dev/null \
          | grep -oE "(def|class|module) [A-Za-z_][A-Za-z0-9_]*" | awk '{print $2}' | head -5 || true)
        ;;
      php)
        while IFS= read -r sym; do
          grep -qF "$sym" .readmeAI 2>/dev/null || printf '+ New symbol not in SYMBOL INDEX: %s (%s)\n' "$sym" "$f"
        done < <(grep -E "^(class|interface|trait) [A-Z]|^ {0,4}(public |protected |static )*function [a-z]" "$f" 2>/dev/null \
          | grep -oE "(function|class|interface|trait) [A-Za-z_][A-Za-z0-9_]*" | awk '{print $2}' | head -5 || true)
        ;;
      kt|kts)
        while IFS= read -r sym; do
          grep -qF "$sym" .readmeAI 2>/dev/null || printf '+ New symbol not in SYMBOL INDEX: %s (%s)\n' "$sym" "$f"
        done < <(grep -E "^(class|object|interface|data class|fun) [A-Z]|^ {0,4}fun [a-z]" "$f" 2>/dev/null \
          | grep -oE "(fun|class|object|interface) [A-Za-z_][A-Za-z0-9_]*" | awk '{print $2}' | head -5 || true)
        ;;
      java)
        while IFS= read -r sym; do
          grep -qF "$sym" .readmeAI 2>/dev/null || printf '+ New symbol not in SYMBOL INDEX: %s (%s)\n' "$sym" "$f"
        done < <(grep -E "^(public|protected) (static )?(class|interface|enum|[A-Z])" "$f" 2>/dev/null \
          | grep -oE "[A-Za-z_][A-Za-z0-9_]*[[:space:]]*[({]" | grep -oE "^[A-Za-z_][A-Za-z0-9_]*" | head -5 || true)
        ;;
      cs)
        while IFS= read -r sym; do
          grep -qF "$sym" .readmeAI 2>/dev/null || printf '+ New symbol not in SYMBOL INDEX: %s (%s)\n' "$sym" "$f"
        done < <(grep -E "^ {0,4}(public|internal|protected) (static |abstract |sealed |partial )*(class|interface|record|struct|[A-Z])" "$f" 2>/dev/null \
          | grep -oE "(class|interface|record|struct|[A-Z][a-zA-Z0-9]*) [A-Za-z_][A-Za-z0-9_]*" | awk '{print $NF}' | head -5 || true)
        ;;
      ex|exs)
        while IFS= read -r sym; do
          grep -qF "$sym" .readmeAI 2>/dev/null || printf '+ New symbol not in SYMBOL INDEX: %s (%s)\n' "$sym" "$f"
        done < <(grep -E "^defmodule [A-Z]|^ {2}def [a-z]" "$f" 2>/dev/null \
          | grep -oE "(defmodule|def) [A-Za-z_.][A-Za-z0-9_.]*" | awk '{print $2}' | head -5 || true)
        ;;
    esac
  done < <(git diff HEAD~1 HEAD --name-only --diff-filter=AM 2>/dev/null | head -10 || true)
fi

# 4. Log session timestamp
mkdir -p .claude
printf '%s | session end\n' "$(date '+%Y-%m-%d %H:%M')" >> .claude/.readmeai.log 2>/dev/null || true
'@
    New-Item -ItemType Directory -Force ".claude" | Out-Null
    # UTF-8 without BOM — bash rejects BOM in shebang line
    [System.IO.File]::WriteAllText((Resolve-Path ".claude" | Join-Path -ChildPath "readmeai-sync.sh"),
      $syncContent, (New-Object System.Text.UTF8Encoding $false))
    $script:Created += "ReadMeAI sync engine → $syncScript"
  }
}

# ── Git post-commit hook — autonomous sync in any editor ─────────────────────
$gitDir = git rev-parse --git-dir 2>$null
if ($gitDir) {
  $hookFile = Join-Path $gitDir "hooks\post-commit"
  $hookExists = (Test-Path $hookFile) -and (Select-String -Path $hookFile -Pattern "readmeai" -Quiet -EA SilentlyContinue)
  if (-not $hookExists) {
    $hookContent = @'
#!/usr/bin/env bash
# ReadMeAI — auto-sync context after every commit (works in any editor)
if [ -f '.claude/readmeai-sync.sh' ]; then
  bash .claude/readmeai-sync.sh 2>/dev/null || true
elif [ -f '.readmeAI' ] && command -v git &>/dev/null; then
  CMSG=$(git log -1 --format='%s' 2>/dev/null || true)
  CDATE=$(git log -1 --format='%ci' 2>/dev/null | cut -d' ' -f1 || true)
  if [ -n "$CMSG" ] && grep -q 'Last action' .readmeAI 2>/dev/null; then
    SAFE=$(printf '%s' "$CDATE — $CMSG" | sed 's/[@&/\\]/\\&/g')
    sed -i "s@.*Last action.*@| **Last action** | $SAFE |@" .readmeAI 2>/dev/null || true
    printf '\nReadMeAI ✓ QUICK REFERENCE auto-patched\n'
  fi
fi
'@
    # UTF-8 without BOM — bash rejects BOM in shebang line
    $utf8NoBom = New-Object System.Text.UTF8Encoding $false
    [System.IO.File]::WriteAllText($hookFile, $hookContent, $utf8NoBom)
    if (Get-Command chmod -EA SilentlyContinue) { chmod +x $hookFile 2>$null }
    $Created += "git post-commit hook → $hookFile"
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

# Zed — reads .rules via @rules mention
if ($All -or (Get-Command zed -EA SilentlyContinue) -or (Test-Path ".zed")) {
  Write-Integration ".rules" "Zed" $CompactContent
}

# Cline — VS Code extension (58k stars). Reads .clinerules/ directory.
if ($All -or (Test-Path ".clinerules")) {
  Write-Integration ".clinerules\readmeai.md" "Cline" $CompactContent
}

# Roo Code — Cline fork, widely deployed. Reads .roo/rules/ directory.
if ($All -or (Test-Path ".roo")) {
  Write-Integration ".roo\rules\readmeai.md" "Roo Code" $CompactContent
}

# Junie — JetBrains AI agent. Reads .junie/guidelines.md (also reads AGENTS.md).
if ($All -or (Test-Path ".junie")) {
  Write-Integration ".junie\guidelines.md" "Junie (JetBrains)" $CompactContent
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
  if (Test-Path "Gemfile") {
    $gemfileContent = Get-Content "Gemfile" -Raw -EA SilentlyContinue
    $rubyFw = if ($gemfileContent -match "gem ['""]rails['""]") { "Rails" } `
              elseif ($gemfileContent -match "sinatra") { "Sinatra" } `
              elseif ($gemfileContent -match "hanami")  { "Hanami"  } else { "" }
    $rubyVerRaw = ruby -v 2>$null; $rubyVer = if ($rubyVerRaw) { ($rubyVerRaw -split ' ')[1] } else { "—" }
    $stackLines += "| Runtime | Ruby | $rubyVer | Gemfile |"
    if ($rubyFw) { $stackLines += "| Framework | $rubyFw | — | — |" }
  }
  if (Test-Path "composer.json") {
    $compContent = Get-Content "composer.json" -Raw -EA SilentlyContinue
    $phpFw = if ($compContent -match "laravel/framework") { "Laravel" } `
             elseif ($compContent -match "symfony/symfony") { "Symfony" } `
             elseif ($compContent -match "slim/slim") { "Slim" } else { "" }
    $phpVerRaw = (php -v 2>$null | Select-Object -First 1); $phpVer = if ($phpVerRaw) { ($phpVerRaw -split ' ')[1] } else { "—" }
    $stackLines += "| Runtime | PHP | $phpVer | composer.json |"
    if ($phpFw) { $stackLines += "| Framework | $phpFw | — | — |" }
  }
  if (Test-Path "pubspec.yaml") {
    $stackLines += "| Runtime | Flutter / Dart | — | pubspec.yaml |"
  }
  if ((Test-Path "build.gradle") -or (Test-Path "build.gradle.kts")) {
    $stackLines += "| Runtime | Kotlin / Java | — | build.gradle |"
  }
  if (Test-Path "pom.xml") {
    $stackLines += "| Runtime | Java / Maven | — | pom.xml |"
  }
  if ((Test-Path "*.csproj") -or (Test-Path "*.sln")) {
    $dotnetVer = (dotnet --version 2>$null); if (-not $dotnetVer) { $dotnetVer = "—" }
    $stackLines += "| Runtime | C# / .NET | $dotnetVer | .csproj |"
  }
  if (Test-Path "mix.exs") {
    $stackLines += "| Runtime | Elixir | — | mix.exs |"
  }
  if ((Test-Path "Dockerfile") -or (Test-Path "docker-compose.yml")) {
    $stackLines += "| Container | Docker | — | docker-compose.yml |"
  }

  if ($stackLines.Count -gt 0) {
    $existing = Get-Content ".readmeAI" -Raw
    $hasStack = $existing -match "## 🛠 TECH STACK"
    if ($hasStack -and -not $Update) {
      Write-Host "${Gr}–${Re}  TECH STACK exists (run -Update to refresh)"
    } else {
      if ($hasStack) {
        # Remove old TECH STACK section before re-adding
        $lines = Get-Content ".readmeAI"
        $inSection = $false; $newLines = @()
        foreach ($line in $lines) {
          if ($line -match "## 🛠 TECH STACK")      { $inSection = $true; continue }
          if ($inSection -and $line -match "^---\s*$") { $inSection = $false; continue }
          if (-not $inSection) { $newLines += $line }
        }
        Set-Content ".readmeAI" $newLines -Encoding utf8
      }
      $section = "`n`n## 🛠 TECH STACK`n_Auto-detected $today_`n`n| Layer | Technology | Version | Notes |`n|-------|-----------|---------|-------|`n" + ($stackLines -join "`n")
      Add-Content ".readmeAI" $section -Encoding utf8
      $action = if ($hasStack) { "refreshed" } else { "pre-filled" }
      Write-Host "${G}✓${Re} Stack $action ($($stackLines.Count) layers)"
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
Write-Host "${Gr}Flags: -All · -Detect · -Validate · -Update · -Sync · -Health · -Upgrade${Re}"
Write-Host ""
