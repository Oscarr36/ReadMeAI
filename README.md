<div align="center">

<img src="img/logo.png" alt="ReadMeAI" width="480" />

<br/><br/>

<p><strong>Your AI coding tool forgets everything between sessions.<br>This fixes it — permanently.</strong></p>

<p>One plain-text file · Auto-reads at session start · Auto-updates at session end<br>Works with every AI tool · Zero plugins · Zero APIs · Zero cloud</p>

<br/>

[![Stars](https://img.shields.io/github/stars/Oscarr36/ReadMeAI?style=for-the-badge&color=FFD700&labelColor=1a1a2e)](https://github.com/Oscarr36/ReadMeAI/stargazers)
[![Version](https://img.shields.io/badge/version-4.6-brightgreen?style=for-the-badge&labelColor=1a1a2e)](CHANGELOG.md)
[![License](https://img.shields.io/badge/MIT-license-4ecca8?style=for-the-badge&labelColor=1a1a2e)](LICENSE)
[![CI](https://img.shields.io/github/actions/workflow/status/Oscarr36/ReadMeAI/readmeai-validate.yml?style=for-the-badge&label=CI&labelColor=1a1a2e)](https://github.com/Oscarr36/ReadMeAI/actions)
[![PRs Welcome](https://img.shields.io/badge/PRs-welcome-orange?style=for-the-badge&labelColor=1a1a2e)](CONTRIBUTING.md)

<br/>

```bash
# macOS / Linux — one command, done
curl -sSL https://raw.githubusercontent.com/Oscarr36/ReadMeAI/main/setup.sh | bash

# Windows PowerShell
irm https://raw.githubusercontent.com/Oscarr36/ReadMeAI/main/setup.ps1 | iex
```

<br/>

<sub>Works with</sub><br/>
<img src="https://img.shields.io/badge/Claude_Code-black?style=flat-square" />
<img src="https://img.shields.io/badge/Cursor-black?style=flat-square" />
<img src="https://img.shields.io/badge/Windsurf-0A84FF?style=flat-square" />
<img src="https://img.shields.io/badge/GitHub_Copilot-238636?style=flat-square" />
<img src="https://img.shields.io/badge/Cline-7C3AED?style=flat-square" />
<img src="https://img.shields.io/badge/Roo_Code-7C3AED?style=flat-square" />
<img src="https://img.shields.io/badge/Aider-E34F26?style=flat-square" />
<img src="https://img.shields.io/badge/Continue-0066FF?style=flat-square" />
<img src="https://img.shields.io/badge/Zed-FF6B6B?style=flat-square" />
<img src="https://img.shields.io/badge/Junie-FD7014?style=flat-square" />
<img src="https://img.shields.io/badge/Antigravity_CLI-4A90D9?style=flat-square" />
<img src="https://img.shields.io/badge/Codex_CLI-10A37F?style=flat-square" />
<img src="https://img.shields.io/badge/OpenCode-gray?style=flat-square" />
<img src="https://img.shields.io/badge/+_any_AGENTS.md_tool-555?style=flat-square" />

</div>

---

## Demo

![ReadMeAI demo](img/demo.gif)

---

## The problem

> [!WARNING]
> Every AI session starts from zero. The AI has forgotten your architecture, your domain rules, the decision you made last Tuesday — and the bug it caused when ignored.

You open your AI coding tool. Session starts. And then:

| What the AI doesn't know | What you have to do |
|--------------------------|---------------------|
| What you built last week | Re-explain the whole codebase |
| The domain rule that causes bugs when ignored | Explain it again (and again) |
| The architecture decision from 3 sessions ago | Hope you remember it yourself |
| Where the project is going | Spend 10 minutes on context |

**This happens every single session. ReadMeAI ends it.**

---

## How it works

```
┌─────────────────────────────────────────────────────────────────┐
│  1. Run setup once                                              │
│     curl -sSL .../setup.sh | bash                               │
│     → Downloads .readmeAI template                              │
│     → Detects your AI tools and wires the right file for each   │
│     → Installs a git hook for autonomous sync                   │
├─────────────────────────────────────────────────────────────────┤
│  2. Fill it with your AI (one message)                          │
│     "Detect my stack, fill what you can, ask only what you      │
│      can't infer."                                              │
│     → AI scans the project, fills every section it can          │
│     → Asks you only for domain knowledge it can't see in code   │
├─────────────────────────────────────────────────────────────────┤
│  3. Every session after that                                    │
│     "Continue where we left off."                               │
│     → AI reads QUICK REFERENCE (5 lines, ~50 tokens)            │
│     → Resumes exactly where you stopped. No re-explanation.     │
└─────────────────────────────────────────────────────────────────┘
```

**Day 1 vs Day 2 in practice:**

```
Day 1 — new project
  You › "Build user auth with JWT"
  AI  › reads .readmeAI → knows stack, structure, conventions
        builds auth following your exact architecture
        updates SESSION STATE, DECISIONS LOG silently at end

Day 2 — new session, AI has forgotten everything
  You › "Continue where we left off"
  AI  › reads QUICK REFERENCE (5 lines) → reads SESSION STATE
        "Resuming: login done, writing the signup handler"
        → opens exactly the right file
        → continues without a single re-explanation
```

---

## What gets wired automatically

Run the setup script **once**. It detects every AI tool you have and creates the right integration file:

| File created | Read by | When loaded |
|---|---|---|
| `AGENTS.md` | Cursor · Windsurf · Copilot · Codex CLI · OpenCode · Kilo Code · Amp · 40+ tools | Every session |
| `.claude/CLAUDE.md` | Claude Code | Every session |
| `GEMINI.md` | Antigravity CLI (`agy`) | Every session |
| `.cursor/rules/*.mdc` | Cursor (3 scoped files) | JIT — only when relevant |
| `.cursorrules` | Cursor (legacy) | Every session |
| `.windsurfrules` | Windsurf | Every session |
| `.github/copilot-instructions.md` | GitHub Copilot | Every session |
| `.clinerules/readmeai.md` | Cline (58k⭐ VS Code extension) | Every session |
| `.roo/rules/readmeai.md` | Roo Code (Cline fork) | Every session |
| `.junie/guidelines.md` | Junie (JetBrains AI agent) | Every session |
| `.continue/rules/readmeai.md` | Continue | Every session |
| `.aider.conf.yml` | Aider | Every run |
| `.rules` | Zed (`@rules`) | On-demand |

> [!TIP]
> **Cursor gets 3 scoped `.mdc` files:** `readmeai-context.mdc` (always active), `readmeai-security.mdc` (auto-loads when you touch auth files), `readmeai-conventions.mdc` (on-demand). JIT loading means context budget only spent when relevant.

---

## What's inside `.readmeAI`

Lean by default (~300 lines). Every section earns its place:

| Section | Purpose | Value |
|---------|---------|-------|
| ⚡ **QUICK REFERENCE** | 5-line snapshot · hot restart in \<50 tokens | Resume any session instantly |
| ⚙️ **AI PROTOCOL** | When to read what · session start/end rules | AI behaves consistently |
| 📋 **PROJECT IDENTITY** | Stack · commands · repo | No more "what framework are we using?" |
| 🧠 **DOMAIN RULES** | Rules that cause bugs when unknown + Deprecated/Renamed table | The most valuable section |
| 🏗 **STRUCTURE MAP** | Annotated file tree | Replaces filesystem scanning |
| 🔍 **SYMBOL INDEX** | Key symbols with purpose — no line numbers | AI navigates without grepping |
| 📐 **CONVENTIONS** | Naming · git · comments | Enforced on every output |
| ✅ **CODE QUALITY** | Pre-output checklist + forbidden patterns | Mandatory gate before every response |
| 🎯 **SESSION STATE** | Objective · last action · next step · "do NOT touch" · branch | AI resumes exactly where you stopped |
| 📚 **DECISIONS LOG** | Architecture choices with rationale (append-only) | Never re-litigate old decisions |
| ✅ **PROGRESS** | In-progress · backlog · completed | Full project visibility |
| 🐛 **KNOWN ISSUES** | Bugs and tech debt | AI doesn't re-introduce known issues |
| ❌ **ERROR PATTERNS** | Confirmed AI mistakes: symptom → root cause → fix | Stops repeated mistakes |
| 🗒 **AI NOTES** | Gotchas and surprises `[!]` `[~]` `[?]` severity tags | Non-obvious knowledge that saves hours |

<details>
<summary><strong>Optional sections</strong> (uncomment when your project needs them)</summary>

| Section | When to enable |
|---------|---------------|
| 🔐 **SECURITY** | Auth model · token storage · forbidden patterns · role table | Any project with auth or user data |
| 🔌 **API CONTRACTS** | Endpoints · data models · environment variables | REST APIs, backend services |
| 🧪 **TESTING** | Coverage · test rules · naming conventions | Projects with test suites |
| ⚡ **PERFORMANCE** | Targets · N+1 rules · pagination rules | Performance-sensitive projects |
| 📦 **DEPENDENCIES** | Critical (version-locked) · banned packages | Long-running projects |
| 🔧 **ENVIRONMENT** | Setup sequence · common commands · env vars | Complex dev environments |

</details>

---

## Setup commands

```bash
# First time
curl -sSL https://raw.githubusercontent.com/Oscarr36/ReadMeAI/main/setup.sh | bash

# Options
bash setup.sh --all              # wire ALL AI tool integrations
bash setup.sh --detect           # pre-fill TECH STACK + AI NOTES from git history
bash setup.sh --all --detect     # everything at once (recommended)

# Maintenance
bash setup.sh --sync             # flag new files/symbols, patch QUICK REFERENCE from last commit
bash setup.sh --health           # score .readmeAI quality [0-100] across 5 dimensions
bash setup.sh --lint             # list every unfilled field + actionable issues
bash setup.sh --compact          # archive decisions + completed tasks >30 days → .readmeAI.archive
bash setup.sh --validate         # check all AI tool integrations are wired

# Updates
bash setup.sh --update           # refresh TECH STACK after adding dependencies
bash setup.sh --upgrade          # upgrade ReadMeAI to the latest version

# New projects
bash setup.sh --new="task manager with real-time collaboration"
# → AI reads the idea, recommends best-fit stack, scaffolds the structure
```

> [!NOTE]
> **Autonomous sync — no commands needed after setup.**
> A git `post-commit` hook runs automatically after every `git commit` in **any** editor — Cursor, Windsurf, Zed, VS Code, terminal. Claude Code users also get a Stop hook after every response.

**`--detect` does real work:**
- Reads `package.json` / `pyproject.toml` / `go.mod` / `Cargo.toml` / `Gemfile` / `composer.json` / `pubspec.yaml` / `mix.exs` / `pom.xml` / `build.gradle` / `*.csproj` — fills TECH STACK with real versions
- Scans **6 months of git history** for high-churn files → flags them in AI NOTES as fragile areas
- Greps source for `IMPORTANT:` / `WARNING:` / `HACK:` / `DO NOT` comments → surfaces them in AI NOTES

---

## After setup

**First-time setup (one message to your AI):**
```
"Detect my stack, fill what you can, ask me only for what you can't infer."
```

**Every session after:**
```
"Continue where we left off."
```

That's it. The AI reads `.readmeAI`, knows exactly where it is, and continues.

---

## ReadMeAI vs alternatives

| | **ReadMeAI** | claude-mem | mem0 |
|:--|:--:|:--:|:--:|
| AI tools supported | **All** (Cursor, Copilot, Windsurf, Aider…) | Claude Code only | Claude Code only |
| Setup | **`curl \| bash`** | npm + MCP | npm + API key |
| Storage | **Plain text file** | SQLite + vector DB | Cloud API |
| Dependencies | **None** | Node.js + Chroma | Node.js + internet |
| Domain rules (override AI) | ✅ | ❌ | ❌ |
| Git-friendly (diff, PR review) | ✅ | ❌ | ❌ |
| Team sharing (one file) | ✅ | ❌ | ❌ |
| Works offline | ✅ | ✅ | ❌ |
| Context budget | **~1.5k tokens active** | AI-compressed, variable | AI-compressed |

> [!IMPORTANT]
> **The key difference:** ReadMeAI is for what the AI *can't* figure out — domain rules, architectural decisions, business constraints. claude-mem captures what the AI *did*. Both are useful; they solve different problems.

---

## GitHub Actions

Setup generates `.github/workflows/readmeai-validate.yml`. On every push it checks:

- ✅ `.readmeAI` exists and is filled (not blank template)
- ✅ `AGENTS.md` is present for cross-tool compatibility
- ✅ DOMAIN RULES are not empty (highest-value section)
- ✅ QUICK REFERENCE is populated (enables hot restart)
- ✅ All AI tool integrations are wired
- ✅ File isn't bloated (>800 lines triggers a warning)

---

## Design principles

> **Domain rules beat everything.** A rule in `.readmeAI` overrides AI training data. Enforced explicitly in the AI PROTOCOL.

> **QUICK REFERENCE for hot restart.** 5-line table at the top. Resume any session in \<50 tokens without reading the full file.

> **Lean by default.** Optional sections excluded until you need them. No dead weight in your context window.

> **Append-only logs.** DECISIONS LOG and AI NOTES are never edited. History is permanent.

> **No stale line numbers.** SYMBOL INDEX uses name + file + purpose. Refactoring doesn't break it.

> **Git-aware.** `--detect` reads git history to find fragile files and surface important comments.

---

## Roadmap

<details>
<summary><strong>Show completed items</strong> (20 shipped)</summary>

- [x] AGENTS.md universal standard support
- [x] GEMINI.md — supports Antigravity CLI (`agy`), backward-compatible with Gemini CLI
- [x] Cursor `.mdc` scoped rules (JIT loading)
- [x] `--detect` with git history scanning + comment extraction
- [x] GitHub Actions sync validation
- [x] QUICK REFERENCE for hot restarts
- [x] Codex CLI (OpenAI) — reads AGENTS.md natively, no extra file needed
- [x] `--sync` — post-session context sync: flags new files, symbols, stale refs from git diff
- [x] `--health` — quality score [0-100] with actionable gaps across 5 dimensions
- [x] Zed editor support via `.rules` file
- [x] Git `post-commit` hook — autonomous sync in **any** editor after every commit
- [x] OpenCode + Kilo Code documented as supported via AGENTS.md
- [x] `setup.ps1` full Windows parity — `-Sync`, `-Health`, Antigravity CLI, Zed, autonomous hooks
- [x] Cline support — `.clinerules/readmeai.md` (VS Code extension, 58k⭐)
- [x] Roo Code support — `.roo/rules/readmeai.md` (widely deployed Cline fork)
- [x] Junie support — `.junie/guidelines.md` (JetBrains AI agent)
- [x] Template v3.9 — ERROR PATTERNS section, Deprecated/Renamed table, session "do NOT touch", branch state
- [x] `--upgrade` / `-Upgrade` — one-command update to latest version with version-behind notification
- [x] Enhanced `--detect` — 7 more stacks: Ruby/Rails, PHP/Laravel, Flutter/Dart, Kotlin/Gradle, Java/Maven, C#/.NET, Elixir/Phoenix
- [x] Enhanced `--sync` — symbol detection extended to 10 languages (+ Ruby, PHP, Kotlin, Java, C#, Elixir)
- [x] `--new="idea"` / `-New "idea"` — new project bootstrap: inject idea, AI recommends stack + scaffolds
- [x] `--lint` / `-Lint` — scan for unfilled placeholders, bloat, stale sync — precise issue list vs --health score
- [x] `--compact` / `-Compact` — archive DECISIONS LOG + completed tasks >30 days → `.readmeAI.archive`

</details>

**Coming next:**
- [ ] `readmeai` CLI — `npm install -g readmeai` / `pip install readmeai`
- [ ] VS Code extension — syntax highlighting + snippets for `.readmeAI`
- [ ] Template variants — SPA · REST API · fullstack monorepo · CLI tool

---

## Using ReadMeAI in your project?

Add this badge to your README:

```markdown
[![ReadMeAI](https://img.shields.io/badge/context-ReadMeAI-blueviolet?style=flat-square)](https://github.com/Oscarr36/ReadMeAI)
```

[![ReadMeAI](https://img.shields.io/badge/context-ReadMeAI-blueviolet?style=flat-square)](https://github.com/Oscarr36/ReadMeAI)

---

<div align="center">

<br/>

**If ReadMeAI saves you re-explanation time, [leave a star ⭐](https://github.com/Oscarr36/ReadMeAI/stargazers)**

It's the best way to help other developers find it.

<br/>

[MIT License](LICENSE) · [Contributing](CONTRIBUTING.md) · [Changelog](CHANGELOG.md) · [Issues](https://github.com/Oscarr36/ReadMeAI/issues)

</div>
