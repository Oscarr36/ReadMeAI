<div align="center">

# ReadMeIA

**Un archivo de contexto AI auto-actualizable para el desarrollo estructurado de aplicaciones web.**

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](../LICENSE)
[![Version](https://img.shields.io/badge/version-1.0.0-green.svg)](../.readmeIA)
[![PRs Welcome](https://img.shields.io/badge/PRs-welcome-brightgreen.svg)](../CONTRIBUTING.md)

**Idiomas:** [English](../README.md) · [Español](README.es.md) · [Português](README.pt.md) · [Français](README.fr.md)

</div>

---

Deja de perder el contexto entre sesiones de IA. Deja de luchar contra estructuras de proyectos desordenadas. ReadMeIA es un único archivo — `.readmeIA` — que vive en la raíz de tu proyecto y mantiene a tu asistente de IA completamente orientado, en todo momento.

---

## El problema

Empiezas un proyecto con un asistente de IA. Va bien. Cierras la sesión.

Al día siguiente: la IA no tiene ni idea de lo que construiste, qué decisiones tomaste, qué convenciones acordaste ni dónde lo dejaste. Pierdes 10 minutos reexplicando todo. La IA pone CSS dentro de las plantillas HTML. La lógica de negocio acaba en los manejadores de rutas. Los valores de configuración están hardcodeados. El proyecto se convierte en un caos.

La IA es poderosa. El problema es el contexto — se resetea.

---

## La solución

Un archivo `.readmeIA` en la raíz de cada proyecto. Un solo archivo que la IA lee completamente antes de hacer nada, y actualiza después de cada sesión. Contiene:

- **Identidad del proyecto** — nombre, versión, fase actual, tech stack
- **Arquitectura** — la estructura de carpetas impuesta con reglas de qué va dónde
- **Convenciones** — nombrado de archivos, metodología CSS, estilo JS, formato de git
- **Contexto actual** — en qué se está trabajando ahora mismo, última decisión tomada, bloqueos
- **Registro de progreso** — hitos completados y tareas activas
- **Historial de cambios** — registro auto-incremental de lo que hizo la IA en cada sesión
- **Referencias cruzadas** — enlaces a proyectos hermanos que la IA también debe leer

---

## Cómo funciona

```
Sesión 1:
  Tú → "Lee el .readmeIA y construyamos un sistema de autenticación"
  IA  → lee el archivo, entiende el stack, la estructura, las convenciones
  IA  → construye la auth siguiendo exactamente la arquitectura del archivo
  IA  → añade al registro de cambios, actualiza el progreso, actualiza el contexto

Sesión 2 (días después):
  Tú → "Lee el .readmeIA y continúa"
  IA  → contexto completo restaurado al instante
  IA  → sabe qué se construyó, qué sigue, qué decisiones se tomaron
  IA  → continúa sin necesidad de reexplicar nada
```

El archivo crece con el proyecto. Cuanto más lo usas, más contexto contiene.

---

## Arquitectura impuesta

ReadMeIA impone una estructura inspirada en MVC para aplicaciones web, con estricta separación de responsabilidades:

```
project/
├── .readmeIA               ← Archivo de contexto IA (este sistema)
├── README.md
├── config/                 ← Toda la config aquí. Nunca en src/.
├── src/
│   ├── controllers/        ← Lógica de negocio
│   ├── models/             ← Datos + interacción con la BD
│   ├── views/              ← Plantillas y páginas
│   ├── routes/             ← Solo definición de rutas, sin lógica
│   ├── middleware/
│   └── services/           ← APIs externas, utilidades compartidas
├── public/
│   ├── css/                ← Todos los estilos. Nunca en views.
│   ├── js/                 ← Todos los scripts de cliente. Nunca mezclados con el servidor.
│   └── assets/
└── tests/
    ├── unit/
    └── integration/
```

La IA tiene instrucciones de señalar cualquier desviación de esta estructura y sugerir correcciones.

---

## Inicio rápido

**1. Copia la plantilla `.readmeIA` a la raíz de tu proyecto**

```bash
curl -o .readmeIA https://raw.githubusercontent.com/Oscarr36/ReadMeIA/main/.readmeIA
```

**2. Rellena la sección PROJECT IDENTITY**

Abre el archivo y actualiza:
- Nombre, versión, fase, tipo
- Descripción de lo que hace el proyecto
- Tabla del tech stack

**3. Inicia tu primera sesión**

Dile a tu IA:
> "Lee el archivo `.readmeIA` en la raíz del proyecto. Ese archivo define nuestra arquitectura, convenciones y estado actual. Síguelo estrictamente. Después de cada respuesta que cambie el proyecto, actualiza el archivo."

**4. Termina las sesiones con una actualización**

> "Actualiza el `.readmeIA` con lo que hicimos hoy."

**5. Retoma en cualquier momento**

> "Lee el `.readmeIA` y continúa donde lo dejamos."

---

## Reglas de actualización de la IA

El archivo `.readmeIA` contiene un protocolo embebido que instruye a la IA:

- Leer el archivo completo antes de responder
- Detectar el idioma de la sesión y reescribir las secciones relevantes si cambia
- Nunca borrar historial — solo añadir
- Actualizar el contexto actual después de cada cambio significativo
- Señalar archivos creados fuera de la estructura definida
- Mantener la tabla del tech stack actualizada con versiones reales

---

## Espacios de trabajo multi-proyecto

Si estás trabajando en varios proyectos relacionados (por ejemplo, una app frontend + API backend + librería compartida), cada uno tiene su propio `.readmeIA`. Puedes cruzarlos:

```markdown
## 🔗 REFERENCIAS CRUZADAS
| Alias  | Ubicación       | Relación                            |
|--------|-----------------|-------------------------------------|
| api    | ../my-api       | Backend de este frontend            |
| shared | ../shared-lib   | Componentes y utilidades compartidas|
```

La IA lee todos los archivos `.readmeIA` referenciados antes de responder preguntas que abarcan varios proyectos.

---

## Principios de diseño

**1. Un archivo, contexto completo.**
Sin documentos dispersos, sin páginas wiki, sin bases de datos en Notion. Un archivo que la IA siempre puede encontrar.

**2. Añadir, no sobreescribir.**
El historial nunca se borra. El archivo crece con el proyecto.

**3. Estructura antes que código.**
Las convenciones se definen desde el inicio. La IA las impone, no tú.

**4. Agnóstico al idioma.**
La IA detecta el idioma del usuario y escribe el archivo en ese idioma. Español, inglés, portugués — te sigue.

**5. La realidad sobre la documentación.**
Si el código contradice el archivo, actualiza el archivo para que coincida con el código. La fuente de verdad siempre es el código.

---

## Hoja de ruta

- [ ] CLI `readmeia init` — scaffoldea un proyecto con la estructura completa en un comando
- [ ] Extensión VS Code — resaltado de sintaxis y snippets para `.readmeIA`
- [ ] Variantes de plantilla — SPA, REST API, monorepo fullstack
- [ ] Modo workspace — leer múltiples archivos `.readmeIA` en una sesión IA
- [ ] Script de validación — comprueba que la estructura del proyecto coincide con la especificación

---

## Contribuir

Esta es una especificación abierta. Si la usas y la mejoras, abre una PR con tus cambios a la plantilla.

Lee [CONTRIBUTING.md](../CONTRIBUTING.md) para las directrices.

---

## Licencia

[MIT](../LICENSE) — úsalo, fórkalo, adáptalo.
