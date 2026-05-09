<div align="center">

<img src="../img/Icon.png" alt="ReadMeAI" width="200" />

<h1>ReadMeAI</h1>

<p><strong>Um arquivo de contexto IA auto-atualizável que mantém cada sessão completamente orientada — sem reexplicações, sem deriva de contexto, sem estruturas bagunçadas.</strong></p>

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](../LICENSE)
[![Version](https://img.shields.io/badge/version-2.3-brightgreen.svg)](../.readmeAI)
[![PRs Welcome](https://img.shields.io/badge/PRs-welcome-orange.svg)](../CONTRIBUTING.md)
[![AI Ready](https://img.shields.io/badge/AI-ready-purple.svg)](../.readmeAI)

**Idiomas:** [English](../README.md) · [Español](README.es.md) · [Português](README.pt.md) · [Français](README.fr.md)

**Compatível com:** Claude · ChatGPT · GitHub Copilot · Gemini · Cursor · qualquer assistente IA

---

### ↓ Baixe em um único comando

```bash
# bash / mac / linux
curl -o .readmeAI https://raw.githubusercontent.com/Oscarr36/ReadMeAI/main/.readmeAI
```

```powershell
# PowerShell / Windows
Invoke-WebRequest -Uri "https://raw.githubusercontent.com/Oscarr36/ReadMeAI/main/.readmeAI" -OutFile ".readmeAI"
```

</div>

---

## O problema

Você começa um projeto com um assistente de IA. Vai bem. Fecha a sessão.

**No dia seguinte:** a IA não tem ideia do que você construiu, quais decisões tomou, quais convenções acordou ou onde parou. Você perde 10 minutos reexplicando tudo. CSS acaba dentro dos templates HTML. Lógica de negócio vaza para os manipuladores de rotas. Configurações são hardcoded. O projeto vira uma bagunça.

A IA é poderosa. **O problema é o contexto — ele se reseta.**

---

## A solução

Coloque um arquivo `.readmeAI` na raiz de qualquer projeto. Um único arquivo que a IA lê completamente antes de fazer qualquer coisa, e atualiza silenciosamente ao final de cada sessão.

| Sem ReadMeAI | Com ReadMeAI |
|-------------|-------------|
| Reexplicar a arquitetura toda sessão | IA carrega contexto completo em segundos |
| IA inventa sua própria estrutura | Regras de pastas impostas, sempre |
| Nomenclatura e estilo inconsistentes | Convenções bloqueadas e aplicadas |
| Decisões e histórico perdidos | Registro de decisões cresce automaticamente |
| "Onde paramos?" | IA retoma do exato último passo |
| IA lê cada arquivo para encontrar coisas | Índice de símbolos → salto direto para arquivo:linha |

---

## O que há dentro do template

O arquivo `.readmeAI` é organizado em **23 seções**, cada uma mantida automaticamente pela IA:

```
⚙️  AI PROTOCOL          — regras de sessão, eficiência de tokens, quality gate
🧭  PROJECT CONTEXT       — propósito, objetivos, restrições, regras de domínio
📋  PROJECT IDENTITY      — nome, versão, fase, tipo, repo
🛠  TECH STACK            — cada camada com versões
🏗  STRUCTURE MAP         — árvore de arquivos anotada (substitui o scan do filesystem)
🔍  SYMBOL INDEX          — cada função/classe-chave em arquivo:linha exato
📐  CONVENTIONS           — nomes de arquivo, CSS, JS, git, política de comentários
✅  CODE QUALITY          — checklist pré-entrega, semântica de nomes, padrões proibidos
🔌  API & DATA CONTRACTS  — endpoints, APIs externas, modelos de dados, vars de ambiente
🔐  SECURITY              — modelo de auth, dados sensíveis, superfície de ataque
⚡  PERFORMANCE           — SLAs, gargalos, estratégia de cache, regras de BD
🧪  TESTING STRATEGY      — mapa de cobertura, regras de mocks, fixtures, requisitos de CI
🚨  ERROR HANDLING        — modelo de propagação, formato de resposta, regras de log
📦  DEPENDENCIES          — pacotes críticos, conflitos, política de atualização
🎯  CURRENT SESSION STATE — snapshot ao vivo: objetivo, última ação, próximo passo
📚  DECISIONS LOG         — cada decisão arquitetural com seu raciocínio
🐛  KNOWN ISSUES          — bugs, workarounds, dívida técnica
✅  PROGRESS              — concluído, em andamento, backlog
🔗  CROSS-PROJECT REFS    — links para projetos irmãos
🔧  ENVIRONMENT           — ferramentas, sequência de setup, comandos comuns
🗒  AI NOTES              — bloco de notas livre para observações não óbvias
📜  CHANGE LOG            — histórico sessão a sessão
```

---

## Como funciona

```
Sessão 1:
  Você → "Leia o .readmeAI e vamos construir um sistema de auth"
  IA   → lê o arquivo, carrega contexto, estrutura, convenções, regras de segurança
  IA   → constrói a auth seguindo exatamente a arquitetura definida
  IA   → atualiza change log, progresso, estado da sessão — silenciosamente

Sessão 2 (dias depois):
  Você → "Leia o .readmeAI e continue"
  IA   → contexto completo restaurado instantaneamente
  IA   → abre o arquivo de auth diretamente na linha certa (índice de símbolos)
  IA   → continua sem nenhuma reexplicação
```

> O arquivo cresce com o projeto. Quanto mais sessões, mais rico o contexto.

---

## Estrutura imposta

A IA impõe estrita separação de responsabilidades. Cada diretório tem regras explícitas do que ele **possui** e o que **não deve conter**:

```
project/
├── .readmeAI               ← Contexto IA. Nunca mover. Nunca deletar.
├── config/                 ← Toda config. Nunca em src/.
├── src/
│   ├── controllers/        ← Apenas lógica de negócio. Sem queries no BD.
│   ├── models/             ← Schemas de dados + queries. Sem HTTP.
│   ├── views/              ← Templates. Sem estilos ou lógica inline.
│   ├── routes/             ← Apenas definição de rotas. Delegam para controllers.
│   ├── middleware/         ← Auth, validação, logging.
│   └── services/           ← APIs externas, utilitários compartilhados.
├── public/
│   ├── css/                ← Todos os estilos. Nunca em views.
│   ├── js/                 ← Apenas cliente. Nunca misturado com servidor.
│   └── assets/
└── tests/
    ├── unit/               ← Espelha a estrutura de src/.
    └── integration/
```

Qualquer arquivo colocado fora dessa estrutura é sinalizado imediatamente.

---

## Qualidade de código embutida

Cada entrega de código é verificada contra um checklist embutido antes de ser mostrada:

- Responsabilidade única por função
- Sem aninhamento mais profundo que 3 níveis
- Sem valores hardcoded — sempre constantes ou config
- Semântica de nomes imposta (funções = verbos, booleanos = `is/has/can`, etc.)
- Padrões proibidos bloqueados: `eval`, SQL concatenado, catch vazio, segredos no código
- Regra de consistência: se um padrão existe no codebase, ele é replicado exatamente

---

## Eficiência de tokens

O **Symbol Index** é o recurso central de economia de tokens. Em vez de escanear o projeto a cada sessão, a IA registra cada símbolo-chave em seu `arquivo:linha` exato:

```
Precisa modificar o fluxo de login?
→ Procure "login" no Symbol Index
→ Leia apenas src/auth/login.js:23-67
→ Pronto. Sem glob. Sem scan.
```

Após o primeiro setup, a IA nunca relê o projeto inteiro.

---

## Início rápido

**1. Copie o template para a raiz do seu projeto**
```bash
curl -o .readmeAI https://raw.githubusercontent.com/Oscarr36/ReadMeAI/main/.readmeAI
```

**2. Peça à sua IA para configurar** *(apenas uma vez)*
> "Leia o arquivo `.readmeAI`. Escaneie o projeto, preencha tudo que conseguir inferir, e então me pergunte apenas o que não conseguir determinar."

**3. Comece a construir**
> "Leia o `.readmeAI` e vamos [tarefa]."

**4. Retome a qualquer momento**
> "Leia o `.readmeAI` e continue de onde paramos."

A IA atualiza o arquivo silenciosamente ao final de cada sessão. Você nunca precisa pedir.

---

## Prompts recomendados

```
Primeiro setup:
"Leia o arquivo .readmeAI na raiz do projeto. Escaneie o projeto,
preencha todas as seções que conseguir inferir, e então me pergunte
apenas o que não conseguir determinar pelo código."

Cada sessão posterior:
"Leia o .readmeAI e continue de onde paramos."

Tarefa específica:
"Leia o .readmeAI e então [tarefa]. Siga a arquitetura,
convenções e regras de qualidade definidas no arquivo."
```

---

## Espaços de trabalho multi-projeto

Cada projeto tem seu próprio `.readmeAI`. Referencie-os cruzadamente e a IA os lerá todos antes de responder perguntas que abrangem múltiplos projetos:

```markdown
## 🔗 REFERÊNCIAS CRUZADAS
| Alias  | Localização   | Relacionamento                  |
|--------|---------------|---------------------------------|
| api    | ../my-api     | Backend deste frontend          |
| shared | ../shared-lib | Componentes + utilitários comuns|
```

---

## Princípios de design

| Princípio | O que significa |
|-----------|----------------|
| **Um arquivo, contexto completo** | Sem docs espalhados, sem wikis, sem Notion. Um arquivo que a IA sempre encontra. |
| **Adicionar, não sobrescrever** | O histórico é permanente. O arquivo só cresce. |
| **Estrutura antes do código** | Convenções definidas desde o início. A IA as impõe, não você. |
| **Realidade sobre documentação** | Código contradiz o arquivo? Atualize o arquivo. O codebase é sempre a fonte da verdade. |
| **Dependência humana zero** | Uma IA fria lendo este arquivo sozinha deve continuar sem fazer uma única pergunta. |
| **Eficiência de tokens** | Symbol Index + Structure Map substituem completamente o scan do filesystem. |

---

## Roadmap

- [ ] CLI `readmeia init` — scaffold de um projeto com a estrutura completa em um comando
- [ ] Extensão VS Code — highlight de sintaxe e snippets para `.readmeAI`
- [ ] Variantes de template — SPA, REST API, monorepo fullstack, CLI tool
- [ ] Modo workspace — ler múltiplos arquivos `.readmeAI` em uma sessão IA
- [ ] Script de validação — verifica se a estrutura do projeto corresponde à spec

---

## Contribuindo

Esta é uma especificação aberta. Se você a usa e a melhora, abra um PR.

Leia [CONTRIBUTING.md](../CONTRIBUTING.md) para as diretrizes.

---

<div align="center">

[MIT](../LICENSE) — use, fork, adapte.

</div>
