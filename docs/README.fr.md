<div align="center">

<img src="../Icon.png" alt="ReadMeAI" width="200" />

<h1>ReadMeAI</h1>

<p><strong>Un fichier de contexte IA auto-mis à jour qui maintient chaque session parfaitement orientée — sans réexplications, sans dérive de contexte, sans structure chaotique.</strong></p>

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](../LICENSE)
[![Version](https://img.shields.io/badge/version-2.3-brightgreen.svg)](../.readmeAI)
[![PRs Welcome](https://img.shields.io/badge/PRs-welcome-orange.svg)](../CONTRIBUTING.md)
[![AI Ready](https://img.shields.io/badge/AI-ready-purple.svg)](../.readmeAI)

**Langues :** [English](../README.md) · [Español](README.es.md) · [Português](README.pt.md) · [Français](README.fr.md)

**Compatible avec :** Claude · ChatGPT · GitHub Copilot · Gemini · Cursor · tout assistant IA

---

### ↓ Téléchargez-le en une seule commande

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

## Le problème

Vous démarrez un projet avec un assistant IA. Ça se passe bien. Vous fermez la session.

**Le lendemain :** l'IA n'a aucune idée de ce que vous avez construit, des décisions que vous avez prises, des conventions établies ou de l'endroit où vous vous étiez arrêté. Vous passez 10 minutes à tout réexpliquer. Le CSS se retrouve dans les templates HTML. La logique métier fuit dans les gestionnaires de routes. Les valeurs de config sont hardcodées. Le projet devient un chaos.

L'IA est puissante. **Le problème, c'est le contexte — il se réinitialise.**

---

## La solution

Déposez un fichier `.readmeAI` à la racine de n'importe quel projet. Un seul fichier que l'IA lit entièrement avant de faire quoi que ce soit, et qu'elle met à jour silencieusement à la fin de chaque session.

| Sans ReadMeAI | Avec ReadMeAI |
|--------------|--------------|
| Réexpliquer l'architecture à chaque session | L'IA charge le contexte complet en secondes |
| L'IA invente sa propre structure | Règles de dossiers imposées, à chaque fois |
| Nommage et style incohérents | Conventions verrouillées et appliquées |
| Décisions et historique perdus | Journal des décisions croît automatiquement |
| « Où en étions-nous ? » | L'IA reprend depuis l'exact dernier pas |
| L'IA lit chaque fichier pour trouver des choses | Index de symboles → saut direct vers fichier:ligne |

---

## Ce que contient le template

Le fichier `.readmeAI` est organisé en **23 sections**, chacune maintenue automatiquement par l'IA :

```
⚙️  AI PROTOCOL          — règles de session, efficacité des tokens, quality gate
🧭  PROJECT CONTEXT       — but, objectifs, contraintes, règles métier
📋  PROJECT IDENTITY      — nom, version, phase, type, repo
🛠  TECH STACK            — chaque couche avec ses versions
🏗  STRUCTURE MAP         — arborescence annotée (remplace le scan du filesystem)
🔍  SYMBOL INDEX          — chaque fonction/classe clé à son fichier:ligne exact
📐  CONVENTIONS           — nommage de fichiers, CSS, JS, git, politique de commentaires
✅  CODE QUALITY          — checklist pré-livraison, sémantique de noms, patterns interdits
🔌  API & DATA CONTRACTS  — endpoints, APIs externes, modèles de données, vars d'environnement
🔐  SECURITY              — modèle d'auth, données sensibles, surface d'attaque
⚡  PERFORMANCE           — SLAs, goulots d'étranglement, stratégie de cache, règles BD
🧪  TESTING STRATEGY      — carte de couverture, règles de mocks, fixtures, exigences CI
🚨  ERROR HANDLING        — modèle de propagation, format de réponse, règles de log
📦  DEPENDENCIES          — packages critiques, conflits, politique de mise à jour
🎯  CURRENT SESSION STATE — snapshot en direct : objectif, dernière action, prochain pas
📚  DECISIONS LOG         — chaque décision architecturale avec son raisonnement
🐛  KNOWN ISSUES          — bugs, contournements, dette technique
✅  PROGRESS              — terminé, en cours, backlog
🔗  CROSS-PROJECT REFS    — liens vers les projets frères
🔧  ENVIRONMENT           — outils, séquence de setup, commandes courantes
🗒  AI NOTES              — bloc-notes libre pour observations non évidentes
📜  CHANGE LOG            — historique session par session
```

---

## Comment ça fonctionne

```
Session 1 :
  Vous → « Lis le .readmeAI et construisons un système d'auth »
  IA   → lit le fichier, charge contexte, structure, conventions, règles de sécurité
  IA   → construit l'auth en suivant exactement l'architecture définie
  IA   → met à jour change log, progression, état de session — silencieusement

Session 2 (quelques jours plus tard) :
  Vous → « Lis le .readmeAI et continue »
  IA   → contexte complet restauré instantanément
  IA   → ouvre le fichier auth directement à la bonne ligne (index de symboles)
  IA   → continue sans aucune réexplication
```

> Le fichier grandit avec le projet. Plus il y a de sessions, plus le contexte est riche.

---

## Structure imposée

L'IA impose une stricte séparation des responsabilités. Chaque répertoire a des règles explicites sur ce qu'il **possède** et ce qu'il **ne doit pas contenir** :

```
project/
├── .readmeAI               ← Contexte IA. Ne jamais déplacer. Ne jamais supprimer.
├── config/                 ← Toute la config. Jamais dans src/.
├── src/
│   ├── controllers/        ← Logique métier uniquement. Pas de queries BD.
│   ├── models/             ← Schémas de données + queries. Pas d'HTTP.
│   ├── views/              ← Templates. Pas de styles ni logique inline.
│   ├── routes/             ← Définitions de routes uniquement. Délèguent aux controllers.
│   ├── middleware/         ← Auth, validation, logging.
│   └── services/           ← APIs externes, utilitaires partagés.
├── public/
│   ├── css/                ← Toutes les feuilles de style. Jamais dans views.
│   ├── js/                 ← Côté client uniquement. Jamais mélangé avec le serveur.
│   └── assets/
└── tests/
    ├── unit/               ← Miroir de la structure src/.
    └── integration/
```

Tout fichier placé en dehors de cette structure est signalé immédiatement.

---

## Qualité de code intégrée

Chaque livraison de code est vérifiée contre une checklist intégrée avant d'être présentée :

- Responsabilité unique par fonction
- Pas d'imbrication plus profonde que 3 niveaux
- Pas de valeurs hardcodées — toujours des constantes ou de la config
- Sémantique de nommage imposée (fonctions = verbes, booléens = `is/has/can`, etc.)
- Patterns interdits bloqués : `eval`, SQL concaténé, catch vides, secrets dans le code
- Règle de cohérence : si un pattern existe dans le codebase, il est répliqué exactement

---

## Efficacité des tokens

Le **Symbol Index** est la fonctionnalité centrale d'économie de tokens. Au lieu de scanner le projet à chaque session, l'IA enregistre chaque symbole clé à son `fichier:ligne` exact :

```
Besoin de modifier le flux de login ?
→ Cherchez « login » dans le Symbol Index
→ Lisez uniquement src/auth/login.js:23-67
→ Terminé. Pas de glob. Pas de scan.
```

Après le premier setup, l'IA ne relit jamais le projet en entier.

---

## Démarrage rapide

**1. Copiez le template à la racine de votre projet**
```bash
curl -o .readmeAI https://raw.githubusercontent.com/Oscarr36/ReadMeAI/main/.readmeAI
```

**2. Demandez à votre IA de le configurer** *(une seule fois)*
> « Lis le fichier `.readmeAI`. Scanne le projet, remplis tout ce que tu peux inférer, puis demande-moi seulement ce que tu ne peux pas déterminer. »

**3. Commencez à construire**
> « Lis le `.readmeAI` et faisons [tâche]. »

**4. Reprenez à tout moment**
> « Lis le `.readmeAI` et continue là où on s'est arrêtés. »

L'IA met à jour le fichier silencieusement à la fin de chaque session. Vous n'avez jamais besoin de le demander.

---

## Prompts recommandés

```
Premier setup :
« Lis le fichier .readmeAI à la racine du projet. Scanne le projet,
remplis toutes les sections que tu peux inférer, puis demande-moi
seulement ce que tu ne peux pas déterminer du code. »

Chaque session suivante :
« Lis le .readmeAI et continue là où on s'est arrêtés. »

Tâche spécifique :
« Lis le .readmeAI puis [tâche]. Suis l'architecture,
les conventions et les règles de qualité définies dans le fichier. »
```

---

## Espaces de travail multi-projets

Chaque projet a son propre `.readmeAI`. Référencez-les croisés et l'IA les lira tous avant de répondre aux questions couvrant plusieurs projets :

```markdown
## 🔗 RÉFÉRENCES CROISÉES
| Alias  | Emplacement   | Relation                        |
|--------|---------------|---------------------------------|
| api    | ../my-api     | Backend de ce frontend          |
| shared | ../shared-lib | Composants + utilitaires communs|
```

---

## Principes de conception

| Principe | Ce que ça signifie |
|----------|-------------------|
| **Un fichier, contexte complet** | Pas de docs éparpillés, pas de wikis, pas de Notion. Un fichier que l'IA trouve toujours. |
| **Ajouter, ne pas écraser** | L'historique est permanent. Le fichier ne fait que grandir. |
| **Structure avant le code** | Les conventions définies dès le départ. C'est l'IA qui les impose, pas vous. |
| **La réalité prime** | Le code contredit le fichier ? Mettez le fichier à jour. Le codebase est toujours la source de vérité. |
| **Dépendance humaine zéro** | Une IA froide lisant ce fichier seule doit pouvoir continuer sans poser une seule question. |
| **Efficacité des tokens** | Symbol Index + Structure Map remplacent entièrement le scan du filesystem. |

---

## Feuille de route

- [ ] CLI `readmeia init` — scaffold d'un projet avec la structure complète en une commande
- [ ] Extension VS Code — coloration syntaxique et snippets pour `.readmeAI`
- [ ] Variantes de template — SPA, REST API, monorepo fullstack, outil CLI
- [ ] Mode workspace — lire plusieurs fichiers `.readmeAI` en une session IA
- [ ] Script de validation — vérifie que la structure du projet correspond à la spec

---

## Contribuer

C'est une spécification ouverte. Si vous l'utilisez et l'améliorez, ouvrez une PR.

Lisez [CONTRIBUTING.md](../CONTRIBUTING.md) pour les directives.

---

<div align="center">

[MIT](../LICENSE) — utilisez-le, forkez-le, adaptez-le.

</div>
