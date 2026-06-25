# Changelog

All notable changes to ReadMeAI will be documented here.

Format: [Semantic Versioning](https://semver.org). Types: `Added`, `Changed`, `Deprecated`, `Removed`, `Fixed`.

---

## [4.0.0] — 2026-06-25

### Added
- **`--upgrade` flag** (`setup.sh`) — one command to upgrade to the latest ReadMeAI version. Downloads the latest `setup.sh` from GitHub and re-runs it with `--all`, updating `.readmeAI`, all integration files, and hooks.
- **`-Upgrade` flag** (`setup.ps1`) — Windows equivalent. Downloads the latest `setup.ps1` to a temp file and re-runs it with `-All`.
- **Version-behind notification** — `--sync` and `--health` (both bash and PowerShell) now fetch the remote version (3s timeout, no cost) and print an upgrade hint if a newer version is available: `⬆  ReadMeAI v4.0 available (you have v3.6) → Upgrade: bash setup.sh --upgrade`.
- `check_version()` helper function in `setup.sh` — reusable, called at end of `--sync` and `--health` modes.
- `Invoke-VersionCheck` function in `setup.ps1` — PowerShell equivalent.
- Usage comments updated in both files to document `--upgrade` / `-Upgrade`.

### Changed
- Version bumped to v4.0 in `setup.sh`, `setup.ps1`, `.readmeAI` header, `.readmeAI` footer, README badge.

---

## [3.9.0] — 2026-06-25

### Added
- **`❌ ERROR PATTERNS` section** (new) — table of confirmed AI mistakes with symptom → root cause → correct approach. Lives between KNOWN ISSUES and AI NOTES. Prevents the AI from repeating the same class of mistake across sessions.
- **`Deprecated / Renamed` subsection in DOMAIN RULES** — anti-hallucination anchors listing dead APIs/symbols alongside their replacements. Prevents the AI from reaching for removed functions.
- **`Do NOT touch this session` in SESSION STATE** — frozen areas (under migration, owned by another team member). AI stops and flags if asked to touch these.
- **`Branch / workspace` line in SESSION STATE** — branch name, uncommitted files, open PR. Recovers exact workspace state in one line on hot restart.
- **`Environment variables` table in optional ENVIRONMENT section** — exact var names, required/optional, example (non-secret). Prevents AI hallucination of wrong env var names.
- Version bumped to v3.9 in header, template footer, README badge

### Changed
- README: version badge updated to 3.9
- README: v3.9 improvements documented in Roadmap

---

## [3.8.0] — 2026-06-25

### Added
- **Cline support** — creates `.clinerules/readmeai.md`. Detected when `.clinerules/` directory exists or `-All` flag used. Cline is the most popular VS Code AI coding extension (58k GitHub stars).
- **Roo Code support** — creates `.roo/rules/readmeai.md`. Detected when `.roo/` directory exists or `-All` flag used. Roo Code is a widely-deployed Cline fork with mode-specific rules.
- **Junie support** — creates `.junie/guidelines.md`. Detected when `.junie/` directory exists or `-All` flag used. JetBrains AI agent used across IntelliJ, PyCharm, WebStorm, etc.
- `--validate` / `-Validate` maps updated: Cline, Roo Code, Junie added to tool checklist
- Header comments updated: both `setup.sh` and `setup.ps1` list new tools
- README "Works with" updated: Cline, Roo Code, Junie added
- README integration table: 3 new rows (`.clinerules/`, `.roo/rules/`, `.junie/`)
- Roadmap: Cline, Roo Code, Junie marked `[x]` complete
- Version bumped to v3.8

---

## [3.7.0] — 2026-06-25

### Added
- **`setup.ps1` full Windows parity** — PowerShell script now matches `setup.sh` feature-for-feature:
  - `-Sync` flag: reads last git commit, flags new/deleted files not in .readmeAI, auto-patches QUICK REFERENCE "Last action"
  - `-Health` flag: 5-dimension quality score [0-100] with progress bar and actionable advice
  - **Antigravity CLI** detection (`agy` binary, with `gemini` fallback) — installs `GEMINI.md`
  - **Zed editor** support — installs `.rules` file (read via `@rules` mention in Zed)
  - **Autonomous sync engine** — generates `.claude/readmeai-sync.sh` called automatically by Claude Code Stop hook
  - **Git `post-commit` hook** — installed when a git repo is detected; auto-patches QUICK REFERENCE in any editor
  - **Updated Claude Code Stop hook** — now calls `readmeai-sync.sh` instead of printing a manual reminder
  - **Updated UserPromptSubmit hook** — now shows context size (lines + token estimate) at session start
  - `-Validate` map updated: added Zed, renamed Gemini CLI → Antigravity CLI / Gemini
  - Flags summary updated: added `-Sync · -Health`
  - Version bumped to v3.7 in setup title and AGENTS.md footer

### Changed
- README Roadmap: `setup.ps1 full Windows parity` marked `[x]` complete

---

## [3.6.0] — 2026-06-25

### Added
- **Git `post-commit` hook** — installed automatically by `setup.sh` when a git repo is detected. Fires after every `git commit` in ANY editor (Cursor, Windsurf, Zed, VS Code, JetBrains, terminal). Calls `.claude/readmeai-sync.sh` if present, falls back to inline QUICK REFERENCE patch. Makes context sync truly autonomous — no editor-specific hook system needed.
- **OpenCode** (95K⭐, 2.5M devs/month) documented as supported via AGENTS.md
- **Kilo Code** documented as supported via AGENTS.md
- `.readmeAI` updated with actual project context (QUICK REFERENCE, SESSION STATE, DOMAIN RULES, STRUCTURE MAP, SYMBOL INDEX, DECISIONS LOG)

### Changed
- README "Works with" updated: OpenCode, Kilo Code added
- AGENTS.md table updated: 40+ tools (was 30+)
- Version bumped to v3.6

---

## [3.5.0] — 2026-06-25

### Added
- **Autonomous sync engine** (`.claude/readmeai-sync.sh`) — generated by setup and called automatically by the Claude Code Stop hook. Runs at session end with zero user action: auto-patches QUICK REFERENCE, flags new files/symbols/stale refs, logs session. No APIs, no cost.
- Session start hook now shows context size (lines + token estimate) alongside QUICK REFERENCE

### Changed
- Stop hook now calls `readmeai-sync.sh` instead of just printing a reminder
- `--sync` mode: fixed broken `sed` command (was using `|` as delimiter inside a pattern containing `|`)
- Detect section: fixed SC2183 ShellCheck warning (`printf` with array now uses a loop)
- Version bumped to v3.5

### Fixed
- ShellCheck CI: SC2183 in `--detect` git intelligence section (NOTES array printf)
- ShellCheck CI: sed delimiter collision in `--sync` QUICK REFERENCE patch

---

## [3.4.0] — 2026-06-25

### Added
- **`--sync`** — post-session context sync. Reads last git commit, flags new files not in STRUCTURE MAP, new symbols (functions/classes in JS/TS/Python/Go/Rust) not in SYMBOL INDEX, deleted files still referenced, and patches QUICK REFERENCE "Last action". No API calls, zero cost.
- **`--health`** — quality score [0-100] across 5 dimensions: file size, QUICK REFERENCE, DOMAIN RULES, SESSION STATE, SYMBOL INDEX. Progress bar + actionable advice per section.
- **Zed editor support** — creates `.rules` file (read via `@rules` in Zed agent). Detected by `zed` binary or `.zed/` directory.
- Stop hook now suggests running `--sync` at session end

### Changed
- Version bumped to v3.4 across setup.sh and AGENTS.md footer

---

## [3.3.0] — 2026-06-25

### Changed
- **Antigravity CLI support** — Gemini CLI was retired June 18 2026. Setup now detects `agy` (Antigravity) binary in addition to legacy `gemini`. GEMINI.md remains the correct file (Antigravity still reads it — no rename needed).
- Version bumped to v3.3 across setup.sh, AGENTS.md footer, and README
- README "Works with" updated: Gemini CLI → Antigravity CLI, added Codex CLI explicitly

### Added
- Codex CLI (OpenAI) documented as officially supported via AGENTS.md (no extra file needed)
- Zed editor added to Roadmap

---

## [1.0.0] — 2026-05-09

### Added
- `.readmeAI` v1.0 template with full AI protocol, architecture spec, conventions, progress tracking, cross-project references, and auto-incremental change log
- `README.md` in English with full documentation
- Translations: Spanish (`docs/README.es.md`), Portuguese (`docs/README.pt.md`), French (`docs/README.fr.md`)
- `CONTRIBUTING.md` with guidelines for template improvements and translations
- `CODE_OF_CONDUCT.md`
- `CHANGELOG.md`
- `.gitignore`
- GitHub issue templates: bug report, feature request, template improvement
- GitHub pull request template
