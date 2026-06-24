# Changelog

All notable changes to ReadMeAI will be documented here.

Format: [Semantic Versioning](https://semver.org). Types: `Added`, `Changed`, `Deprecated`, `Removed`, `Fixed`.

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
