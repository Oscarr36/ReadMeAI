<div align="center">

<img src="../img/Icon.png" alt="ReadMeAI" width="260" />

# ReadMeAI

**Las herramientas de IA para código son ciegas al contexto. Esto lo soluciona.**

Un archivo. Se lee solo al iniciar sesión. Se actualiza solo al terminarla. Funciona con cualquier herramienta IA.

[![GitHub Stars](https://img.shields.io/github/stars/Oscarr36/ReadMeAI?style=social)](https://github.com/Oscarr36/ReadMeAI/stargazers)
[![Version](https://img.shields.io/badge/version-3.3-brightgreen.svg)](../.readmeAI)
[![AGENTS.md](https://img.shields.io/badge/AGENTS.md-compatible-blue)](../AGENTS.md)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](../LICENSE)

**Idiomas:** [English](../README.md) · Español · [Português](README.pt.md) · [Français](README.fr.md)

**Compatible con:** Claude Code · Cursor · Windsurf · GitHub Copilot · Gemini CLI · Aider · Continue · cualquier herramienta que lea AGENTS.md

</div>

---

```bash
# macOS / Linux
curl -sSL https://raw.githubusercontent.com/Oscarr36/ReadMeAI/main/setup.sh | bash

# Windows PowerShell
irm https://raw.githubusercontent.com/Oscarr36/ReadMeAI/main/setup.ps1 | iex
```

Eso es todo. El script descarga `.readmeAI`, escanea tu proyecto y conecta el archivo correcto para cada herramienta IA que detecta.

---

## El problema

Abres tu herramienta IA. Empieza la sesión. La IA lo ha olvidado todo.

**No sabe:**
- Qué construiste la semana pasada
- La regla de dominio que causa un bug sutil si se ignora
- La decisión arquitectónica que tomaste hace tres sesiones y por qué
- Hacia dónde va el código y dónde está ahora mismo

Lo explicas de nuevo. 8 mensajes. 10 minutos. La misma conversación de siempre.

**Ocurre en cada sesión.**

---

## La solución

`.readmeAI` es un archivo de contexto de proyecto estructurado que:

1. **Se lee automáticamente al iniciar sesión** — sin prompt, sin recordatorio, antes de que la IA escriba nada
2. **Captura lo que el código no dice** — reglas de dominio, trampas, decisiones arquitectónicas, trabajo en curso
3. **Se actualiza en silencio al terminar** — estado de sesión, decisiones, índice de símbolos
4. **Funciona con todas las herramientas IA** — genera AGENTS.md, CLAUDE.md, .cursorrules, .windsurfrules, GEMINI.md y más

**El resultado:** "Continúa donde lo dejamos" funciona de verdad. Siempre.

---

## Qué se conecta automáticamente

| Archivo creado | Lo lee | Coste en tokens |
|----------------|--------|----------------|
| `AGENTS.md` | Cursor, Windsurf, Copilot agent, Codex, 30+ herramientas | una vez por sesión |
| `GEMINI.md` | Gemini CLI | una vez por sesión |
| `.claude/CLAUDE.md` | Claude Code | una vez por sesión |
| `.cursor/rules/*.mdc` | Cursor (moderno, con scope) | JIT — solo cuando es relevante |
| `.cursorrules` | Cursor (legacy) | una vez por sesión |
| `.windsurfrules` | Windsurf | una vez por sesión |
| `.github/copilot-instructions.md` | GitHub Copilot | una vez por sesión |
| `.aider.conf.yml` | Aider | cada ejecución |
| `.continue/rules/readmeai.md` | Continue | una vez por sesión |

**Claude Code obtiene hooks de ciclo de vida** — inyección automática de QUICK REFERENCE al iniciar sesión, snapshot de sesión al cerrar, aviso si editas un archivo no registrado en el STRUCTURE MAP.

---

## Qué hay dentro de `.readmeAI`

```
⚡  QUICK REFERENCE   — 5 líneas. Reinicio en caliente en <50 tokens.
⚙️  AI PROTOCOL       — cuándo leer qué, reglas de inicio/fin de sesión
📋  PROJECT IDENTITY  — stack, comandos, repo
🧠  DOMAIN RULES      — reglas que causan bugs cuando se ignoran (máximo valor)
🏗  STRUCTURE MAP     — árbol de archivos anotado
🔍  SYMBOL INDEX      — símbolos clave con propósito
📐  CONVENTIONS       — nomenclatura, git, comentarios
✅  CODE QUALITY      — checklist pre-output + patrones prohibidos
🎯  SESSION STATE     — punto de reinicio: objetivo, última acción, siguiente paso
📚  DECISIONS LOG     — decisiones arquitectónicas (solo se añade, nunca se borra)
✅  PROGRESS          — en curso, backlog, completado
🐛  KNOWN ISSUES      — bugs y deuda técnica
🗒  AI NOTES          — trampas [!] · gotchas [~] · preguntas abiertas [?]
```

**Secciones opcionales** (descomenta cuando las necesites):
`🔐 SECURITY` · `🔌 API CONTRACTS` · `🧪 TESTING` · `⚡ PERFORMANCE` · `📦 DEPENDENCIES` · `🔧 ENVIRONMENT`

---

## Comandos de setup

```bash
bash setup.sh                # descarga .readmeAI + detecta herramientas IA
bash setup.sh --all          # conecta TODAS las integraciones
bash setup.sh --detect       # escanea proyecto y pre-rellena TECH STACK desde git
bash setup.sh --validate     # comprueba que .readmeAI está sincronizado
bash setup.sh --update       # refresca TECH STACK al añadir dependencias
bash setup.sh --all --detect # todo a la vez
```

---

## Después del setup

**Primera vez:**
> *"Detecta mi stack, rellena lo que puedas, pregúntame solo lo que no puedas inferir."*

**Cada sesión después:**
> *"Continúa donde lo dejamos."*

---

## ReadMeAI vs alternativas

| | ReadMeAI | claude-mem | mem0 |
|--|--|--|--|
| **Herramientas IA** | Todas (Cursor, Copilot, Windsurf, Gemini...) | Solo Claude Code | Solo Claude Code |
| **Setup** | `curl ... \| bash` | npm install + MCP | npm install + API key |
| **Almacenamiento** | Texto plano | SQLite + vector DB | Cloud API |
| **Dependencias** | Ninguna | Node.js + Chroma | Node.js + internet |
| **Reglas de dominio** | Sí — tú escribes reglas que anulan a la IA | No | No |
| **Git-friendly** | Sí — commit, diff, revisión en PR | No (binario) | No (cloud) |
| **Compartir en equipo** | Sí — un archivo para todo el equipo | No (por usuario) | No |
| **Funciona offline** | Sí | Sí | No |

**La diferencia clave:** ReadMeAI captura lo que la IA *no puede* inferir — reglas de dominio, decisiones arquitectónicas, restricciones de negocio. claude-mem captura lo que la IA *hizo*. Son complementarios.

---

## Roadmap

- [x] Soporte estándar universal AGENTS.md
- [x] GEMINI.md (Gemini CLI)
- [x] Reglas .mdc con scope para Cursor (carga JIT)
- [x] `--detect` con escaneo de historial git
- [x] Validación con GitHub Actions
- [x] QUICK REFERENCE para reinicios en caliente
- [x] Hooks de ciclo de vida de Claude Code
- [ ] CLI `readmeai` (npm/pip install)
- [ ] Extensión VS Code
- [ ] Variantes de plantilla — SPA · REST API · monorepo · CLI

---

<div align="center">

Si ReadMeAI te ahorra tiempo, **[deja una estrella ⭐](https://github.com/Oscarr36/ReadMeAI/stargazers)**

[Licencia MIT](../LICENSE) — úsalo, fórkalo, adáptalo.

</div>
