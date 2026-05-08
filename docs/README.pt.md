<div align="center">

# ReadMeIA

**Um arquivo de contexto AI auto-atualizável para o desenvolvimento estruturado de aplicações web.**

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](../LICENSE)
[![Version](https://img.shields.io/badge/version-1.0.0-green.svg)](../.readmeIA)
[![PRs Welcome](https://img.shields.io/badge/PRs-welcome-brightgreen.svg)](../CONTRIBUTING.md)

**Idiomas:** [English](../README.md) · [Español](README.es.md) · [Português](README.pt.md) · [Français](README.fr.md)

</div>

---

Pare de perder o contexto entre sessões de IA. Pare de lutar contra estruturas de projetos desorganizadas. ReadMeIA é um único arquivo — `.readmeIA` — que vive na raiz do seu projeto e mantém o seu assistente de IA completamente orientado, sempre.

---

## O problema

Você começa um projeto com um assistente de IA. Vai bem. Fecha a sessão.

No dia seguinte: a IA não tem ideia do que você construiu, quais decisões tomou, quais convenções acordou ou onde parou. Você perde 10 minutos reexplicando tudo. A IA coloca CSS dentro dos templates HTML. A lógica de negócio acaba nos manipuladores de rotas. Valores de configuração são hardcoded. O projeto vira uma bagunça.

A IA é poderosa. O problema é o contexto — ele se reseta.

---

## A solução

Um arquivo `.readmeIA` na raiz de cada projeto. Um único arquivo que a IA lê completamente antes de fazer qualquer coisa, e atualiza após cada sessão. Ele contém:

- **Identidade do projeto** — nome, versão, fase atual, tech stack
- **Arquitetura** — a estrutura de pastas imposta com regras do que vai onde
- **Convenções** — nomenclatura de arquivos, metodologia CSS, estilo JS, formato do git
- **Contexto atual** — no que está se trabalhando agora, última decisão tomada, bloqueios
- **Registro de progresso** — marcos concluídos e tarefas ativas
- **Histórico de mudanças** — registro auto-incremental do que a IA fez em cada sessão
- **Referências cruzadas** — links para projetos irmãos que a IA também deve ler

---

## Como funciona

```
Sessão 1:
  Você → "Leia o .readmeIA e vamos construir um sistema de autenticação"
  IA   → lê o arquivo, entende o stack, estrutura, convenções
  IA   → constrói a auth seguindo exatamente a arquitetura do arquivo
  IA   → adiciona ao registro de mudanças, atualiza progresso, atualiza contexto

Sessão 2 (dias depois):
  Você → "Leia o .readmeIA e continue"
  IA   → contexto completo restaurado instantaneamente
  IA   → sabe o que foi construído, o que vem a seguir, quais decisões foram tomadas
  IA   → continua sem necessidade de reexplicação
```

O arquivo cresce com o projeto. Quanto mais você usa, mais contexto ele contém.

---

## Arquitetura imposta

ReadMeIA impõe uma estrutura inspirada em MVC para aplicações web, com estrita separação de responsabilidades:

```
project/
├── .readmeIA               ← Arquivo de contexto IA (este sistema)
├── README.md
├── config/                 ← Toda configuração aqui. Nunca em src/.
├── src/
│   ├── controllers/        ← Lógica de negócio
│   ├── models/             ← Dados + interação com o BD
│   ├── views/              ← Templates e páginas
│   ├── routes/             ← Apenas definição de rotas, sem lógica
│   ├── middleware/
│   └── services/           ← APIs externas, utilitários compartilhados
├── public/
│   ├── css/                ← Todos os estilos. Nunca em views.
│   ├── js/                 ← Todos os scripts do cliente. Nunca misturados com o servidor.
│   └── assets/
└── tests/
    ├── unit/
    └── integration/
```

A IA tem instruções para sinalizar qualquer desvio desta estrutura e sugerir correções.

---

## Início rápido

**1. Copie o template `.readmeIA` para a raiz do seu projeto**

```bash
curl -o .readmeIA https://raw.githubusercontent.com/Oscarr36/ReadMeIA/main/.readmeIA
```

**2. Preencha a seção PROJECT IDENTITY**

Abra o arquivo e atualize:
- Nome, versão, fase, tipo
- Descrição do que o projeto faz
- Tabela do tech stack

**3. Inicie sua primeira sessão**

Diga ao seu assistente de IA:
> "Leia o arquivo `.readmeIA` na raiz do projeto. Esse arquivo define nossa arquitetura, convenções e estado atual. Siga-o estritamente. Após cada resposta que mude o projeto, atualize o arquivo."

**4. Termine as sessões com uma atualização**

> "Atualize o `.readmeIA` com o que fizemos hoje."

**5. Retome a qualquer momento**

> "Leia o `.readmeIA` e continue de onde paramos."

---

## Regras de atualização da IA

O arquivo `.readmeIA` contém um protocolo embutido que instrui a IA:

- Ler o arquivo completo antes de responder
- Detectar o idioma da sessão e reescrever seções relevantes se mudar
- Nunca deletar histórico — apenas adicionar
- Atualizar o contexto atual após cada mudança significativa
- Sinalizar arquivos criados fora da estrutura definida
- Manter a tabela de tech stack atualizada com versões reais

---

## Espaços de trabalho multi-projeto

Se você estiver trabalhando em vários projetos relacionados (ex.: app frontend + API backend + biblioteca compartilhada), cada um tem seu próprio `.readmeIA`. Você pode cruzá-los:

```markdown
## 🔗 REFERÊNCIAS CRUZADAS
| Alias  | Localização     | Relacionamento                      |
|--------|-----------------|-------------------------------------|
| api    | ../my-api       | Backend deste frontend              |
| shared | ../shared-lib   | Componentes e utilitários compartilhados |
```

A IA lê todos os arquivos `.readmeIA` referenciados antes de responder perguntas que abrangem vários projetos.

---

## Princípios de design

**1. Um arquivo, contexto completo.**
Sem documentos espalhados, sem páginas de wiki, sem bancos de dados no Notion. Um arquivo que a IA sempre pode encontrar.

**2. Adicionar, não sobrescrever.**
O histórico nunca é deletado. O arquivo cresce com o projeto.

**3. Estrutura antes do código.**
As convenções são definidas desde o início. A IA as impõe, não você.

**4. Agnóstico ao idioma.**
A IA detecta o idioma do usuário e escreve o arquivo nesse idioma. Português, inglês, espanhol — ela te segue.

**5. A realidade sobre a documentação.**
Se o código contradiz o arquivo, atualize o arquivo para corresponder ao código. A fonte de verdade é sempre o código.

---

## Roadmap

- [ ] CLI `readmeia init` — scaffold de um projeto com a estrutura completa em um comando
- [ ] Extensão VS Code — highlight de sintaxe e snippets para `.readmeIA`
- [ ] Variantes de template — SPA, REST API, monorepo fullstack
- [ ] Modo workspace — ler múltiplos arquivos `.readmeIA` em uma sessão IA
- [ ] Script de validação — verifica se a estrutura do projeto corresponde à especificação

---

## Contribuindo

Esta é uma especificação aberta. Se você a usa e a melhora, abra um PR com suas alterações no template.

Leia [CONTRIBUTING.md](../CONTRIBUTING.md) para as diretrizes.

---

## Licença

[MIT](../LICENSE) — use, fork, adapte.
