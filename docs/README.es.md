<div align="center">

<img src="../img/Icon.png" alt="ReadMeAI" width="300" />


<p><strong>Un archivo de contexto IA auto-actualizable que mantiene cada sesión completamente orientada — sin reexplicaciones, sin deriva de contexto, sin estructuras caóticas.</strong></p>

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](../LICENSE)
[![Version](https://img.shields.io/badge/version-2.3-brightgreen.svg)](../.readmeAI)
[![PRs Welcome](https://img.shields.io/badge/PRs-welcome-orange.svg)](../CONTRIBUTING.md)
[![AI Ready](https://img.shields.io/badge/AI-ready-purple.svg)](../.readmeAI)

**Idiomas:** [English](../README.md) · [Español](README.es.md) · [Português](README.pt.md) · [Français](README.fr.md)

**Compatible con:** Claude · ChatGPT · GitHub Copilot · Gemini · Cursor · cualquier asistente IA

---

### ↓ Descárgalo en un comando

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

## El problema

Empiezas un proyecto con un asistente de IA. Va bien. Cierras la sesión.

**Al día siguiente:** la IA no tiene ni idea de lo que construiste, qué decisiones tomaste, qué convenciones acordaste ni dónde lo dejaste. Pierdes 10 minutos reexplicando todo. El CSS acaba dentro de las plantillas HTML. La lógica de negocio se filtra a los manejadores de rutas. La configuración está hardcodeada. El proyecto se convierte en un caos.

La IA es poderosa. **El problema es el contexto — se resetea.**

---

## La solución

Deja un archivo `.readmeAI` en la raíz de cualquier proyecto. Un solo archivo que la IA lee completamente antes de hacer nada, y actualiza en silencio al final de cada sesión.

| Sin ReadMeAI | Con ReadMeAI |
|-------------|-------------|
| Reexplicar la arquitectura cada sesión | La IA carga el contexto completo en segundos |
| La IA inventa su propia estructura | Reglas de carpetas impuestas, siempre |
| Nombrado y estilo inconsistentes | Convenciones bloqueadas y aplicadas |
| Decisiones e historial perdidos | El registro de decisiones crece automáticamente |
| "¿Dónde lo dejamos?" | La IA retoma desde el último paso exacto |
| La IA lee cada archivo para encontrar cosas | Índice de símbolos → salto directo a archivo:línea |

---

## Qué contiene la plantilla

El archivo `.readmeAI` se organiza en **23 secciones**, cada una mantenida automáticamente por la IA:

```
⚙️  AI PROTOCOL          — reglas de sesión, eficiencia de tokens, quality gate
🧭  PROJECT CONTEXT       — propósito, objetivos, restricciones, reglas de dominio
📋  PROJECT IDENTITY      — nombre, versión, fase, tipo, repo
🛠  TECH STACK            — cada capa con versiones
🏗  STRUCTURE MAP         — árbol de archivos anotado (reemplaza el escaneo del filesystem)
🔍  SYMBOL INDEX          — cada función/clase clave en su archivo:línea exacto
📐  CONVENTIONS           — nombres de archivo, CSS, JS, git, política de comentarios
✅  CODE QUALITY          — checklist pre-entrega, semántica de nombres, patrones prohibidos
🔌  API & DATA CONTRACTS  — endpoints, APIs externas, modelos de datos, vars de entorno
🔐  SECURITY              — modelo de auth, datos sensibles, superficie de ataque
⚡  PERFORMANCE           — SLAs, cuellos de botella, estrategia de caché, reglas de BD
🧪  TESTING STRATEGY      — mapa de cobertura, reglas de mocks, fixtures, requisitos CI
🚨  ERROR HANDLING        — modelo de propagación, formato de respuesta, reglas de log
📦  DEPENDENCIES          — paquetes críticos, conflictos, política de actualización
🎯  CURRENT SESSION STATE — snapshot en vivo: objetivo, última acción, próximo paso
📚  DECISIONS LOG         — cada decisión arquitectónica con su razonamiento
🐛  KNOWN ISSUES          — bugs, workarounds, deuda técnica
✅  PROGRESS              — completado, en curso, backlog
🔗  CROSS-PROJECT REFS    — enlaces a proyectos hermanos
🔧  ENVIRONMENT           — herramientas, secuencia de setup, comandos comunes
🗒  AI NOTES              — bloc de notas libre para observaciones no obvias
📜  CHANGE LOG            — historial sesión a sesión
```

---

## Cómo funciona

```
Sesión 1:
  Tú → "Lee el .readmeAI y construyamos un sistema de auth"
  IA  → lee el archivo, carga contexto, estructura, convenciones, reglas de seguridad
  IA  → construye la auth siguiendo exactamente la arquitectura definida
  IA  → actualiza el change log, progreso, estado de sesión — en silencio

Sesión 2 (días después):
  Tú → "Lee el .readmeAI y continúa"
  IA  → contexto completo restaurado al instante
  IA  → abre el archivo de auth directamente en la línea correcta (índice de símbolos)
  IA  → continúa sin ninguna reexplicación
```

> El archivo crece con el proyecto. Cuantas más sesiones, más rico el contexto.

---

## Estructura impuesta

La IA impone una estricta separación de responsabilidades. Cada directorio tiene reglas explícitas de qué **posee** y qué **no debe contener**:

```
project/
├── .readmeAI               ← Contexto IA. No mover. No borrar.
├── config/                 ← Toda la config. Nunca en src/.
├── src/
│   ├── controllers/        ← Solo lógica de negocio. Sin queries a BD.
│   ├── models/             ← Schemas de datos + queries. Sin HTTP.
│   ├── views/              ← Plantillas. Sin estilos ni lógica inline.
│   ├── routes/             ← Solo definición de rutas. Delegan a controllers.
│   ├── middleware/         ← Auth, validación, logging.
│   └── services/           ← APIs externas, utilidades compartidas.
├── public/
│   ├── css/                ← Todos los estilos. Nunca en views.
│   ├── js/                 ← Solo cliente. Nunca mezclado con servidor.
│   └── assets/
└── tests/
    ├── unit/               ← Espeja la estructura de src/.
    └── integration/
```

Cualquier archivo colocado fuera de esta estructura se señala inmediatamente.

---

## Calidad de código integrada

Cada entrega de código se verifica contra un checklist integrado antes de ser mostrada:

- Una sola responsabilidad por función
- Sin anidamiento más profundo de 3 niveles
- Sin valores hardcodeados — siempre constantes o config
- Semántica de nombres impuesta (funciones = verbos, booleanos = `is/has/can`, etc.)
- Patrones prohibidos bloqueados: `eval`, SQL concatenado, catch vacíos, secretos en código
- Regla de consistencia: si un patrón existe en el codebase, se replica exactamente

---

## Eficiencia de tokens

El **Symbol Index** es la función clave de ahorro de tokens. En lugar de escanear el proyecto cada sesión, la IA registra cada símbolo clave en su `archivo:línea` exacto:

```
¿Necesitas modificar el flujo de login?
→ Busca "login" en el Symbol Index
→ Lee src/auth/login.js:23-67 únicamente
→ Hecho. Sin glob. Sin escaneo.
```

Después del primer setup, la IA nunca vuelve a leer el proyecto entero.

---

## Inicio rápido

**1. Copia la plantilla a la raíz de tu proyecto**
```bash
curl -o .readmeAI https://raw.githubusercontent.com/Oscarr36/ReadMeAI/main/.readmeAI
```

**2. Dile a tu IA que la configure** *(una sola vez)*
> "Lee el archivo `.readmeAI`. Escanea el proyecto, rellena todo lo que puedas inferir, y luego pregúntame solo por lo que no puedas determinar."

**3. Empieza a construir**
> "Lee el `.readmeAI` y hagamos [tarea]."

**4. Retoma en cualquier momento**
> "Lee el `.readmeAI` y continúa donde lo dejamos."

La IA actualiza el archivo en silencio al final de cada sesión. Nunca tienes que pedírselo.

---

## Prompts recomendados

```
Primer setup:
"Lee el archivo .readmeAI en la raíz del proyecto. Escanea el
proyecto, rellena todas las secciones que puedas inferir, y luego
pregúntame solo lo que no puedas determinar del código."

Cada sesión posterior:
"Lee el .readmeAI y continúa donde lo dejamos."

Tarea específica:
"Lee el .readmeAI y luego [tarea]. Sigue la arquitectura,
convenciones y reglas de calidad definidas en el archivo."
```

---

## Espacios de trabajo multi-proyecto

Cada proyecto tiene su propio `.readmeAI`. Referencialos cruzados y la IA los leerá todos antes de responder preguntas que abarcan varios proyectos:

```markdown
## 🔗 REFERENCIAS CRUZADAS
| Alias  | Ubicación     | Relación                        |
|--------|---------------|---------------------------------|
| api    | ../my-api     | Backend de este frontend        |
| shared | ../shared-lib | Componentes + utilidades comunes|
```

---

## Principios de diseño

| Principio | Qué significa |
|-----------|--------------|
| **Un archivo, contexto completo** | Sin documentos dispersos, sin wikis, sin Notion. Un archivo que la IA siempre encuentra. |
| **Añadir, no sobreescribir** | El historial es permanente. El archivo solo crece. |
| **Estructura antes que código** | Convenciones definidas desde el inicio. La IA las impone, no tú. |
| **La realidad sobre la documentación** | ¿El código contradice el archivo? Actualiza el archivo. El codebase es siempre la fuente de verdad. |
| **Dependencia humana cero** | Una IA fría leyendo este archivo sola debe poder continuar sin hacer una sola pregunta. |
| **Eficiencia de tokens** | El Symbol Index + Structure Map reemplazan por completo el escaneo del filesystem. |

---

## Hoja de ruta

- [ ] CLI `readmeia init` — scaffoldea un proyecto con la estructura completa en un comando
- [ ] Extensión VS Code — resaltado de sintaxis y snippets para `.readmeAI`
- [ ] Variantes de plantilla — SPA, REST API, monorepo fullstack, CLI tool
- [ ] Modo workspace — leer múltiples archivos `.readmeAI` en una sesión IA
- [ ] Script de validación — comprueba que la estructura del proyecto coincide con la spec

---

## Contribuir

Esta es una especificación abierta. Si la usas y la mejoras, abre una PR.

Lee [CONTRIBUTING.md](../CONTRIBUTING.md) para las directrices.

---

<div align="center">

[MIT](../LICENSE) — úsalo, fórkalo, adáptalo.

</div>
