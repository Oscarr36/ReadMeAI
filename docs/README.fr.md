<div align="center">

<img src="../img/Icon.png" alt="ReadMeAI" width="260" />

# ReadMeAI

**Les outils de codage IA sont aveugles au contexte. Ceci corrige ça.**

Un fichier. Se lit lui-même au démarrage de session. Se met à jour à la fin. Fonctionne avec tous les outils IA.

[![GitHub Stars](https://img.shields.io/github/stars/Oscarr36/ReadMeAI?style=social)](https://github.com/Oscarr36/ReadMeAI/stargazers)
[![Version](https://img.shields.io/badge/version-3.3-brightgreen.svg)](../.readmeAI)
[![AGENTS.md](https://img.shields.io/badge/AGENTS.md-compatible-blue)](../AGENTS.md)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](../LICENSE)

**Langues :** [English](../README.md) · [Español](README.es.md) · [Português](README.pt.md) · Français

**Compatible avec :** Claude Code · Cursor · Windsurf · GitHub Copilot · Gemini CLI · Aider · Continue · tout outil qui lit AGENTS.md

</div>

---

```bash
# macOS / Linux
curl -sSL https://raw.githubusercontent.com/Oscarr36/ReadMeAI/main/setup.sh | bash

# Windows PowerShell
irm https://raw.githubusercontent.com/Oscarr36/ReadMeAI/main/setup.ps1 | iex
```

C'est tout. Le script télécharge `.readmeAI`, analyse votre projet et connecte le bon fichier pour chaque outil IA détecté.

---

## Le problème

Vous ouvrez votre outil de codage IA. La session démarre. L'IA a tout oublié.

**Elle ne sait pas :**
- Ce que vous avez construit la semaine dernière
- La règle métier qui cause un bug subtil quand elle est ignorée
- La décision architecturale prise trois sessions plus tôt et pourquoi
- Où va le code et où il en est maintenant

Vous expliquez à nouveau. 8 messages. 10 minutes. La même conversation qu'avant.

**Ça arrive à chaque session.**

---

## La solution

`.readmeAI` est un fichier de contexte de projet structuré qui :

1. **Se lit automatiquement au démarrage** — sans prompt, sans rappel, avant que l'IA écrive quoi que ce soit
2. **Capture ce que le code ne dit pas** — règles métier, pièges, décisions architecturales, travail en cours
3. **Se met à jour silencieusement à la fin** — état de session, décisions, index des symboles
4. **Fonctionne avec tous les outils IA** — génère AGENTS.md, CLAUDE.md, .cursorrules, .windsurfrules, GEMINI.md et plus

**Le résultat :** "Continuez où nous en étions" fonctionne vraiment. À chaque fois.

---

## Ce qui est connecté automatiquement

| Fichier créé | Lu par | Coût en tokens |
|--------------|--------|----------------|
| `AGENTS.md` | Cursor, Windsurf, Copilot agent, 30+ outils | une fois par session |
| `GEMINI.md` | Gemini CLI | une fois par session |
| `.claude/CLAUDE.md` | Claude Code | une fois par session |
| `.cursor/rules/*.mdc` | Cursor (moderne, avec scope) | JIT — seulement si pertinent |
| `.cursorrules` | Cursor (legacy) | une fois par session |
| `.windsurfrules` | Windsurf | une fois par session |
| `.github/copilot-instructions.md` | GitHub Copilot | une fois par session |
| `.aider.conf.yml` | Aider | à chaque exécution |
| `.continue/rules/readmeai.md` | Continue | une fois par session |

---

## Ce qu'il y a dans `.readmeAI`

```
⚡  QUICK REFERENCE   — 5 lignes. Reprise à chaud en <50 tokens.
⚙️  AI PROTOCOL       — quand lire quoi, règles de début/fin de session
📋  PROJECT IDENTITY  — stack, commandes, dépôt
🧠  DOMAIN RULES      — règles qui causent des bugs quand ignorées (valeur maximale)
🏗  STRUCTURE MAP     — arborescence annotée — remplace le scan du système de fichiers
🔍  SYMBOL INDEX      — symboles clés avec leur rôle
📐  CONVENTIONS       — nommage, git, commentaires
✅  CODE QUALITY      — checklist pré-output + motifs interdits
🎯  SESSION STATE     — point de reprise : objectif, dernière action, prochaine étape
📚  DECISIONS LOG     — décisions architecturales (ajout uniquement, jamais supprimé)
✅  PROGRESS          — en cours, backlog, terminé
🐛  KNOWN ISSUES      — bugs et dette technique
🗒  AI NOTES          — pièges [!] · gotchas [~] · questions ouvertes [?]
```

---

## Commandes de setup

```bash
bash setup.sh                # télécharge .readmeAI + détecte les outils IA
bash setup.sh --all          # connecte TOUTES les intégrations
bash setup.sh --detect       # scanne le projet et pré-remplit TECH STACK depuis git
bash setup.sh --validate     # vérifie que .readmeAI est synchronisé
bash setup.sh --update       # rafraîchit TECH STACK après ajout de dépendances
bash setup.sh --all --detect # tout d'un coup
```

---

## Après le setup

**Première fois :**
> *"Détecte mon stack, remplis ce que tu peux, demande-moi seulement ce que tu ne peux pas inférer."*

**Chaque session après :**
> *"Continuez où nous en étions."*

---

## ReadMeAI vs alternatives

| | ReadMeAI | claude-mem | mem0 |
|--|--|--|--|
| **Outils IA** | Tous (Cursor, Copilot, Windsurf, Gemini...) | Claude Code seulement | Claude Code seulement |
| **Setup** | `curl ... \| bash` | npm install + MCP | npm install + clé API |
| **Stockage** | Texte simple | SQLite + vector DB | API Cloud |
| **Dépendances** | Aucune | Node.js + Chroma | Node.js + internet |
| **Règles métier** | Oui — vous écrivez des règles qui remplacent l'IA | Non | Non |
| **Git-friendly** | Oui — commit, diff, revue en PR | Non (binaire) | Non (cloud) |
| **Partage en équipe** | Oui — un fichier pour toute l'équipe | Non (par utilisateur) | Non |
| **Fonctionne hors ligne** | Oui | Oui | Non |

---

## Roadmap

- [x] Support du standard universel AGENTS.md
- [x] GEMINI.md (Gemini CLI)
- [x] Règles .mdc avec scope pour Cursor (chargement JIT)
- [x] `--detect` avec scan de l'historique git
- [x] Validation avec GitHub Actions
- [x] QUICK REFERENCE pour reprises à chaud
- [x] Hooks de cycle de vie Claude Code
- [ ] CLI `readmeai` (npm/pip install)
- [ ] Extension VS Code
- [ ] Variantes de template — SPA · REST API · monorepo · CLI

---

<div align="center">

Si ReadMeAI vous fait gagner du temps, **[laissez une étoile ⭐](https://github.com/Oscarr36/ReadMeAI/stargazers)**

[Licence MIT](../LICENSE) — utilisez-le, forkez-le, adaptez-le.

</div>
