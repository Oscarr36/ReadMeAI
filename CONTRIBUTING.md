# Contributing to ReadMeAI

ReadMeAI is an open specification. The core artifact is the `.readmeAI` template — contributions that improve how it guides AI assistants are the most valuable kind.

---

## What you can contribute

### 1. Improve the template
The `.readmeAI` file is the heart of the project. Good contributions:
- Add a missing section that improves AI context (explain *why* it helps)
- Clarify ambiguous AI protocol rules
- Fix a convention that causes real problems in practice
- Remove sections that add noise without value

**Rule:** Keep the `AI PROTOCOL` section intact and at the top. If you add a section, document why it exists. If you remove one, explain what problem it caused.

### 2. Add or improve a translation
READMEs live in `docs/README.[lang].md`. To add a new language:
- Copy `README.md` to `docs/README.[ISO-639-1-code].md`
- Translate fully — partial translations are worse than none
- Add the language link to all existing READMEs (main and all translations)
- Keep code blocks, file paths, and technical terms in English

### 3. Report a real-world problem
If you used ReadMeAI and the AI did something unexpected or broke the structure, open an issue. Include:
- Which AI assistant you used
- What you told it
- What it did wrong
- What the `.readmeAI` looked like at the time

This is how the protocol gets better.

### 4. Add a template variant
The base template targets a generic web app. Variants for specific stacks (Next.js, Django, Laravel, etc.) go in `templates/`. Each variant must:
- Extend the base template, not replace it
- Keep all base sections
- Only add stack-specific conventions and structure

---

## What not to contribute

- Cosmetic changes to the README without functional improvement
- Translations that are machine-translated without human review
- New sections without a clear explanation of why they help the AI
- Changes that break backward compatibility with existing `.readmeAI` files

---

## Process

1. **Open an issue first** for anything beyond a typo fix. Describe what you want to change and why.
2. **Fork and branch** — use `feature/short-description` or `fix/short-description`.
3. **One change per PR** — don't mix template changes with translation updates.
4. **Test it** — if you're changing the AI protocol, try it with at least one AI assistant and describe the result in the PR.

---

## Adding a translation

```bash
# Fork the repo, then:
git checkout -b feature/readme-de   # replace 'de' with your language code

# Copy and translate
cp README.md docs/README.de.md
# ... translate the file ...

# Add the language link to all READMEs
# In README.md and all docs/README.*.md files, add your language to the line:
# **Languages:** [English](README.md) · ... · [Deutsch](docs/README.de.md)
```

---

## Code of Conduct

This project follows the [Contributor Covenant](CODE_OF_CONDUCT.md). By participating, you agree to uphold it.

---

## Questions

Open a [Discussion](../../discussions) — not an issue — for questions about usage, ideas, or anything that isn't a bug or contribution.
