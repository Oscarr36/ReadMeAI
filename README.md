<div align="center">

# ReadMeIA

**A self-updating AI context file for structured web application development.**

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![Version](https://img.shields.io/badge/version-1.0.0-green.svg)](.readmeIA)
[![PRs Welcome](https://img.shields.io/badge/PRs-welcome-brightgreen.svg)](CONTRIBUTING.md)

**Languages:** [English](README.md) · [Español](docs/README.es.md) · [Português](docs/README.pt.md) · [Français](docs/README.fr.md)

</div>

---

Stop losing context between AI sessions. Stop fighting messy project structures. ReadMeIA is a single file — `.readmeIA` — that lives at the root of your project and keeps your AI assistant fully oriented, every time.

---

## The problem

You start a project with an AI assistant. It goes well. You close the session.

Next day: the AI has no idea what you built, what decisions you made, what conventions you agreed on, or where you left off. You spend 10 minutes re-explaining everything. The AI puts CSS inside HTML templates. Business logic ends up in route handlers. Config values are hardcoded. The project turns into a mess.

The AI is powerful. The problem is context — it resets.

---

## The solution

A `.readmeIA` file at the root of every project. One file that the AI reads completely before doing anything, and updates after every session. It contains:

- **Project identity** — name, version, current phase, tech stack
- **Architecture** — the enforced folder structure with rules for what goes where
- **Conventions** — file naming, CSS methodology, JS style, git format
- **Current context** — what's being worked on right now, last decision made, blockers
- **Progress log** — completed milestones and active tasks
- **Change history** — auto-appended record of what the AI did each session
- **Cross-project references** — links to sibling projects the AI should also read

---

## How it works

```
Session 1:
  You → "Read the .readmeIA and let's build a user auth system"
  AI  → reads file, understands stack, structure, conventions
  AI  → builds auth following the exact architecture in the file
  AI  → appends to change log, updates progress, updates context

Session 2 (days later):
  You → "Read the .readmeIA and continue"
  AI  → full context instantly restored
  AI  → knows what was built, what's next, what decisions were made
  AI  → continues without re-explanation
```

The file grows with the project. The more you use it, the more context it holds.

---

## Architecture enforced

ReadMeIA enforces an MVC-inspired structure for web applications, with strict separation of concerns:

```
project/
├── .readmeIA               ← AI context file (this system)
├── README.md
├── config/                 ← All config here. Never in src/.
├── src/
│   ├── controllers/        ← Business logic
│   ├── models/             ← Data + DB interaction
│   ├── views/              ← Templates and pages
│   ├── routes/             ← Route definitions only, no logic
│   ├── middleware/
│   └── services/           ← External APIs, shared utilities
├── public/
│   ├── css/                ← All stylesheets. Never in views.
│   ├── js/                 ← All client scripts. Never mixed with server.
│   └── assets/
└── tests/
    ├── unit/
    └── integration/
```

The AI is instructed to flag any deviation from this structure and suggest corrections.

---

## Quickstart

**1. Copy the `.readmeIA` template to your project root**

```bash
curl -o .readmeIA https://raw.githubusercontent.com/YOUR_USERNAME/readmeia/main/.readmeIA
```

**2. Fill in the PROJECT IDENTITY section**

Open the file and update:
- Name, version, phase, type
- Description of what the project does
- Tech stack table

**3. Start your first session**

Tell your AI:
> "Read the `.readmeIA` file at the project root. That file defines our architecture, conventions, and current state. Follow it strictly. After each response that changes the project, update the file."

**4. End sessions with an update**

> "Update the `.readmeIA` with what we did today."

**5. Resume any time**

> "Read the `.readmeIA` and continue where we left off."

---

## AI update rules

The `.readmeIA` file contains an embedded protocol that instructs the AI:

- Read the full file before responding
- Detect the session language and rewrite relevant sections if it changes
- Never delete history — only append
- Update current context after every meaningful change
- Flag files created outside the defined structure
- Keep the tech stack table current with real versions

---

## Multi-project workspaces

If you're working on multiple related projects (e.g., a frontend app + backend API + shared library), each gets its own `.readmeIA`. You can cross-reference them:

```markdown
## 🔗 CROSS-PROJECT REFERENCES
| Alias  | Location        | Relationship                        |
|--------|-----------------|-------------------------------------|
| api    | ../my-api       | Backend for this frontend           |
| shared | ../shared-lib   | Shared components and utilities     |
```

The AI reads all referenced `.readmeIA` files before answering cross-project questions.

---

## Design principles

**1. One file, complete context.**
No scattered docs, no wiki pages, no Notion databases. One file the AI can always find.

**2. Append, don't overwrite.**
History is never deleted. The file grows as the project grows.

**3. Structure before code.**
Conventions are defined upfront. The AI enforces them, not you.

**4. Language-agnostic.**
The AI detects the user's language and writes the file in that language. Spanish, English, Portuguese — it follows you.

**5. Reality over documentation.**
If code contradicts the file, update the file to match the code. The source of truth is always the codebase.

---

## Roadmap

- [ ] `readmeia init` CLI — scaffold a project with the full structure in one command
- [ ] VS Code extension — syntax highlighting and snippets for `.readmeIA`
- [ ] Template variants — SPA, REST API, fullstack monorepo
- [ ] Workspace mode — read multiple `.readmeIA` files in one AI session
- [ ] Validation script — checks that the project structure matches the spec

---

## Contributing

This is an open specification. If you use it and improve it, open a PR with your changes to the template.

Read [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines.

---

## License

[MIT](LICENSE) — use it, fork it, adapt it.
