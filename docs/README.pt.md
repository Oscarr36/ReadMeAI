<div align="center">

<img src="../img/Icon.png" alt="ReadMeAI" width="260" />

# ReadMeAI

**As ferramentas de IA para código são cegas ao contexto. Isso resolve.**

Um arquivo. Lê a si mesmo no início da sessão. Atualiza a si mesmo no final. Funciona com qualquer ferramenta de IA.

[![GitHub Stars](https://img.shields.io/github/stars/Oscarr36/ReadMeAI?style=social)](https://github.com/Oscarr36/ReadMeAI/stargazers)
[![Version](https://img.shields.io/badge/version-3.3-brightgreen.svg)](../.readmeAI)
[![AGENTS.md](https://img.shields.io/badge/AGENTS.md-compatible-blue)](../AGENTS.md)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](../LICENSE)

**Idiomas:** [English](../README.md) · [Español](README.es.md) · Português · [Français](README.fr.md)

**Compatível com:** Claude Code · Cursor · Windsurf · GitHub Copilot · Gemini CLI · Aider · Continue · qualquer ferramenta que leia AGENTS.md

</div>

---

```bash
# macOS / Linux
curl -sSL https://raw.githubusercontent.com/Oscarr36/ReadMeAI/main/setup.sh | bash

# Windows PowerShell
irm https://raw.githubusercontent.com/Oscarr36/ReadMeAI/main/setup.ps1 | iex
```

Só isso. O script baixa `.readmeAI`, escaneia seu projeto e conecta o arquivo certo para cada ferramenta de IA detectada.

---

## O problema

Você abre sua ferramenta de IA. A sessão começa. A IA esqueceu tudo.

**Ela não sabe:**
- O que você construiu na semana passada
- A regra de domínio que causa um bug sutil quando ignorada
- A decisão arquitetural que você tomou três sessões atrás e por quê
- Para onde o código está indo e onde está agora

Você explica de novo. 8 mensagens. 10 minutos. A mesma conversa de sempre.

**Isso acontece em cada sessão.**

---

## A solução

`.readmeAI` é um arquivo de contexto de projeto estruturado que:

1. **Lê automaticamente no início da sessão** — sem prompt, sem lembrete, antes da IA digitar qualquer coisa
2. **Captura o que o código não diz** — regras de domínio, armadilhas, decisões arquiteturais, trabalho em andamento
3. **Atualiza silenciosamente no final** — estado da sessão, decisões, índice de símbolos
4. **Funciona com todas as ferramentas de IA** — gera AGENTS.md, CLAUDE.md, .cursorrules, .windsurfrules, GEMINI.md e mais

**O resultado:** "Continue de onde paramos" realmente funciona. Sempre.

---

## O que é conectado automaticamente

| Arquivo criado | Lido por | Custo em tokens |
|----------------|----------|----------------|
| `AGENTS.md` | Cursor, Windsurf, Copilot agent, 30+ ferramentas | uma vez por sessão |
| `GEMINI.md` | Gemini CLI | uma vez por sessão |
| `.claude/CLAUDE.md` | Claude Code | uma vez por sessão |
| `.cursor/rules/*.mdc` | Cursor (moderno, com escopo) | JIT — só quando relevante |
| `.cursorrules` | Cursor (legacy) | uma vez por sessão |
| `.windsurfrules` | Windsurf | uma vez por sessão |
| `.github/copilot-instructions.md` | GitHub Copilot | uma vez por sessão |
| `.aider.conf.yml` | Aider | cada execução |
| `.continue/rules/readmeai.md` | Continue | uma vez por sessão |

---

## O que há dentro do `.readmeAI`

```
⚡  QUICK REFERENCE   — 5 linhas. Reinício rápido em <50 tokens.
⚙️  AI PROTOCOL       — quando ler o quê, regras de início/fim de sessão
📋  PROJECT IDENTITY  — stack, comandos, repo
🧠  DOMAIN RULES      — regras que causam bugs quando ignoradas (maior valor)
🏗  STRUCTURE MAP     — árvore de arquivos anotada
🔍  SYMBOL INDEX      — símbolos-chave com propósito
📐  CONVENTIONS       — nomenclatura, git, comentários
✅  CODE QUALITY      — checklist pré-output + padrões proibidos
🎯  SESSION STATE     — ponto de reinício: objetivo, última ação, próximo passo
📚  DECISIONS LOG     — decisões arquiteturais (só adiciona, nunca apaga)
✅  PROGRESS          — em andamento, backlog, concluído
🐛  KNOWN ISSUES      — bugs e dívida técnica
🗒  AI NOTES          — armadilhas [!] · gotchas [~] · perguntas abertas [?]
```

---

## Comandos de setup

```bash
bash setup.sh                # baixa .readmeAI + detecta ferramentas de IA
bash setup.sh --all          # conecta TODAS as integrações
bash setup.sh --detect       # escaneia projeto e pré-preenche TECH STACK do git
bash setup.sh --validate     # verifica se .readmeAI está sincronizado
bash setup.sh --update       # atualiza TECH STACK ao adicionar dependências
bash setup.sh --all --detect # tudo de uma vez
```

---

## Depois do setup

**Primeira vez:**
> *"Detecte meu stack, preencha o que puder, pergunte só o que não puder inferir."*

**Em cada sessão depois:**
> *"Continue de onde paramos."*

---

## ReadMeAI vs alternativas

| | ReadMeAI | claude-mem | mem0 |
|--|--|--|--|
| **Ferramentas de IA** | Todas (Cursor, Copilot, Windsurf, Gemini...) | Só Claude Code | Só Claude Code |
| **Setup** | `curl ... \| bash` | npm install + MCP | npm install + API key |
| **Armazenamento** | Texto simples | SQLite + vector DB | Cloud API |
| **Dependências** | Nenhuma | Node.js + Chroma | Node.js + internet |
| **Regras de domínio** | Sim — você escreve regras que substituem a IA | Não | Não |
| **Git-friendly** | Sim — commit, diff, revisão em PRs | Não (binário) | Não (cloud) |
| **Compartilhar em equipe** | Sim — um arquivo para toda a equipe | Não (por usuário) | Não |
| **Funciona offline** | Sim | Sim | Não |

---

## Roadmap

- [x] Suporte ao padrão universal AGENTS.md
- [x] GEMINI.md (Gemini CLI)
- [x] Regras .mdc com escopo para Cursor (carregamento JIT)
- [x] `--detect` com escaneamento de histórico git
- [x] Validação com GitHub Actions
- [x] QUICK REFERENCE para reinícios rápidos
- [x] Hooks de ciclo de vida do Claude Code
- [ ] CLI `readmeai` (npm/pip install)
- [ ] Extensão VS Code
- [ ] Variantes de template — SPA · REST API · monorepo · CLI

---

<div align="center">

Se o ReadMeAI economiza seu tempo, **[deixe uma estrela ⭐](https://github.com/Oscarr36/ReadMeAI/stargazers)**

[Licença MIT](../LICENSE) — use, fork, adapte.

</div>
