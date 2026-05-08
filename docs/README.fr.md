<div align="center">

# ReadMeIA

**Un fichier de contexte IA auto-mis à jour pour le développement structuré d'applications web.**

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](../LICENSE)
[![Version](https://img.shields.io/badge/version-1.0.0-green.svg)](../.readmeIA)
[![PRs Welcome](https://img.shields.io/badge/PRs-welcome-brightgreen.svg)](../CONTRIBUTING.md)

**Langues :** [English](../README.md) · [Español](README.es.md) · [Português](README.pt.md) · [Français](README.fr.md)

</div>

---

Arrêtez de perdre le contexte entre les sessions IA. Arrêtez de lutter contre des structures de projets désordonnées. ReadMeIA est un seul fichier — `.readmeIA` — qui vit à la racine de votre projet et garde votre assistant IA parfaitement orienté, à tout moment.

---

## Le problème

Vous démarrez un projet avec un assistant IA. Ça se passe bien. Vous fermez la session.

Le lendemain : l'IA n'a aucune idée de ce que vous avez construit, des décisions que vous avez prises, des conventions que vous avez établies ou de l'endroit où vous vous étiez arrêté. Vous passez 10 minutes à tout réexpliquer. L'IA met du CSS dans les templates HTML. La logique métier se retrouve dans les gestionnaires de routes. Les valeurs de configuration sont codées en dur. Le projet devient un chaos.

L'IA est puissante. Le problème, c'est le contexte — il se réinitialise.

---

## La solution

Un fichier `.readmeIA` à la racine de chaque projet. Un seul fichier que l'IA lit complètement avant de faire quoi que ce soit, et qu'elle met à jour après chaque session. Il contient :

- **Identité du projet** — nom, version, phase actuelle, stack technique
- **Architecture** — la structure de dossiers imposée avec les règles de ce qui va où
- **Conventions** — nommage des fichiers, méthodologie CSS, style JS, format git
- **Contexte actuel** — ce sur quoi on travaille maintenant, dernière décision prise, blocages
- **Journal de progression** — jalons complétés et tâches actives
- **Historique des changements** — enregistrement auto-incrémental de ce que l'IA a fait à chaque session
- **Références croisées** — liens vers les projets frères que l'IA doit également lire

---

## Comment ça fonctionne

```
Session 1 :
  Vous → "Lis le .readmeIA et construisons un système d'authentification"
  IA   → lit le fichier, comprend la stack, la structure, les conventions
  IA   → construit l'auth en suivant exactement l'architecture du fichier
  IA   → ajoute au journal des changements, met à jour la progression et le contexte

Session 2 (quelques jours plus tard) :
  Vous → "Lis le .readmeIA et continue"
  IA   → contexte complet restauré instantanément
  IA   → sait ce qui a été construit, ce qui suit, quelles décisions ont été prises
  IA   → continue sans réexplication
```

Le fichier grandit avec le projet. Plus vous l'utilisez, plus il contient de contexte.

---

## Architecture imposée

ReadMeIA impose une structure inspirée du MVC pour les applications web, avec une stricte séparation des responsabilités :

```
project/
├── .readmeIA               ← Fichier de contexte IA (ce système)
├── README.md
├── config/                 ← Toute la config ici. Jamais dans src/.
├── src/
│   ├── controllers/        ← Logique métier
│   ├── models/             ← Données + interaction avec la BD
│   ├── views/              ← Templates et pages
│   ├── routes/             ← Définitions de routes uniquement, pas de logique
│   ├── middleware/
│   └── services/           ← APIs externes, utilitaires partagés
├── public/
│   ├── css/                ← Toutes les feuilles de style. Jamais dans views.
│   ├── js/                 ← Tous les scripts client. Jamais mélangés avec le serveur.
│   └── assets/
└── tests/
    ├── unit/
    └── integration/
```

L'IA a pour instruction de signaler tout écart par rapport à cette structure et de suggérer des corrections.

---

## Démarrage rapide

**1. Copiez le template `.readmeIA` à la racine de votre projet**

```bash
curl -o .readmeIA https://raw.githubusercontent.com/Oscarr36/ReadMeIA/main/.readmeIA
```

**2. Remplissez la section PROJECT IDENTITY**

Ouvrez le fichier et mettez à jour :
- Nom, version, phase, type
- Description de ce que fait le projet
- Tableau du stack technique

**3. Démarrez votre première session**

Dites à votre IA :
> « Lis le fichier `.readmeIA` à la racine du projet. Ce fichier définit notre architecture, nos conventions et notre état actuel. Suis-le strictement. Après chaque réponse qui change le projet, mets à jour le fichier. »

**4. Terminez les sessions avec une mise à jour**

> « Mets à jour le `.readmeIA` avec ce qu'on a fait aujourd'hui. »

**5. Reprenez à tout moment**

> « Lis le `.readmeIA` et continue là où on s'est arrêtés. »

---

## Règles de mise à jour de l'IA

Le fichier `.readmeIA` contient un protocole intégré qui instruit l'IA :

- Lire le fichier complet avant de répondre
- Détecter la langue de la session et réécrire les sections pertinentes si elle change
- Ne jamais supprimer l'historique — seulement ajouter
- Mettre à jour le contexte actuel après chaque changement significatif
- Signaler les fichiers créés en dehors de la structure définie
- Maintenir le tableau du stack technique à jour avec les versions réelles

---

## Espaces de travail multi-projets

Si vous travaillez sur plusieurs projets connexes (ex. : app frontend + API backend + bibliothèque partagée), chacun a son propre `.readmeIA`. Vous pouvez les croiser :

```markdown
## 🔗 RÉFÉRENCES CROISÉES
| Alias  | Emplacement     | Relation                            |
|--------|-----------------|-------------------------------------|
| api    | ../my-api       | Backend de ce frontend              |
| shared | ../shared-lib   | Composants et utilitaires partagés  |
```

L'IA lit tous les fichiers `.readmeIA` référencés avant de répondre aux questions couvrant plusieurs projets.

---

## Principes de conception

**1. Un fichier, contexte complet.**
Pas de docs éparpillés, pas de pages wiki, pas de bases de données Notion. Un fichier que l'IA peut toujours trouver.

**2. Ajouter, ne pas écraser.**
L'historique n'est jamais supprimé. Le fichier grandit avec le projet.

**3. Structure avant le code.**
Les conventions sont définies dès le départ. C'est l'IA qui les impose, pas vous.

**4. Agnostique à la langue.**
L'IA détecte la langue de l'utilisateur et écrit le fichier dans cette langue. Français, anglais, espagnol — elle vous suit.

**5. La réalité prime sur la documentation.**
Si le code contredit le fichier, mettez à jour le fichier pour correspondre au code. La source de vérité est toujours le code.

---

## Feuille de route

- [ ] CLI `readmeia init` — scaffolde un projet avec la structure complète en une commande
- [ ] Extension VS Code — coloration syntaxique et snippets pour `.readmeIA`
- [ ] Variantes de template — SPA, REST API, monorepo fullstack
- [ ] Mode workspace — lire plusieurs fichiers `.readmeIA` en une session IA
- [ ] Script de validation — vérifie que la structure du projet correspond à la spécification

---

## Contribuer

C'est une spécification ouverte. Si vous l'utilisez et l'améliorez, ouvrez une PR avec vos modifications au template.

Lisez [CONTRIBUTING.md](../CONTRIBUTING.md) pour les directives.

---

## Licence

[MIT](../LICENSE) — utilisez-le, forkez-le, adaptez-le.
