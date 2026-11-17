<p align="center"><img src="docs/brand/icono.png" width="120" alt="TELEIOS"></p>

# TELEIOS 🏛️📊

> *"Sed, pues, vosotros perfectos, como vuestro Padre que está en los cielos es perfecto."* — Mateo 5:48

**TELEIOS** es una plataforma multiplataforma (**iOS, Android, Desktop, Web**) desarrollada en **Flutter**, diseñada para la **ingeniería espiritual, el análisis psicoteológico y la analítica cognitiva**. Bajo una arquitectura *Local-First*, permite estructurar estudios bíblicos con rigor teológico, registrar la praxis diaria mediante bitácoras emocionales, dictar oraciones por voz y mapear dinámicamente la estructura de la personalidad a través de un **Grafo de Fuerza Dirigida**.

A diferencia de las aplicaciones que dependen de costosos y lentos LLMs generativos, TELEIOS adopta el paradigma de **clasificación tipada estilo System One** (Choice / Score / Noul) ejecutado **en el dispositivo del usuario** — con **$0 de costo de infraestructura en IA** y sin que el contenido privado salga del teléfono.

---

## 🏛️ Sustento Teológico

| Módulo | Mandato Bíblico | Referencia |
|--------|-----------------|------------|
| **Bitácora de Praxis** | Autoexamen clínico y evaluación de caminos | Lamentaciones 3:40 · Hageo 1:5 |
| **Mapeo de la Cosmovisión** | Llevar cautivo todo razonamiento a la obediencia | 2 Corintios 10:5 · Romanos 12:2 |
| **Altar de Oración por Voz** | Derramar el corazón ante Dios en libertad | Salmos 62:8 · Efesios 6:18 |
| **Debugging Comunitario** | Conocer el estado del rebaño con diligencia | Proverbios 27:23 · Éxodo 18:21 |
| **Veracidad Estadística** | Ser hacedores, no solo oidores | Santiago 1:22 |
| **Ciencias Bíblicas** | Escudriñar cada día las Escrituras | Hechos 17:11 |

---

## 🧩 Los Cuatro Pilares

### 📖 Estudio — Ciencias Bíblicas
- Infraestructura teológica local (manuscritos, variantes, Strong) en **SQLite (Drift)** · texto base Reina-Valera 1909 (dominio público).
- Formulario cronológico estructurado (época, imperio, región) que alimenta una **línea de tiempo interactiva**.
- **4 dimensiones fijas:** Carácter de Dios · Contexto Histórico · Vida Práctica · Estructura del Pensamiento.
- **Sugeridor híbrido:** la IA propone tópicos; **el usuario valida, corrige o crea los suyos**.

### 📝 Bitácora — Praxis y Emociones
- Modelo clínico **A-B-C**: Circunstancia → Emoción (1-10) → Filtro Cognitivo → Acción + Paz.
- Filtros posibles: **Bíblico validado**, **Cosmovisión (por validar)**, **Impulso secular**.
- **Nodos de incubación:** conductas aprendidas pendientes de validación teológica.
- Registro de fallas con detección de **detonantes reales** (ira, orgullo, miedo).

### 🎙️ Altar — Oración por Voz
- Captura con **waveform animado** y Speech-to-Text local.
- Clasificación de intención (Agradecimiento / Petición / Lamentación).
- Los tópicos detectados se vinculan a la Bitácora como **puentes cognitivos**.

### 📊 Ejes — Dashboard de Personalidad y Comunidad
- **Grafo de Fuerza Dirigida** con física orbital y tensión de enlaces por nivel de paz.
- Gráficos clínicos: radar, dispersión, heatmap temporal, aluvión.
- **Vista Líder:** Treemap jerárquico anidado con regla estricta de **K-Anonimato (N ≥ 5)**.

---

## 🤖 Motor de IA: Clasificación tipada (estilo System One)

TELEIOS **no genera texto**; **clasifica estados cognitivos** mediante primitivas tipadas:

| Primitiva | Propósito |
|-----------|-----------|
| **Choice** | Selección de tópicos desde array predefinido, con confianza |
| **Score** | Evaluación de intensidad emocional, coherencia y paz (1-10) |
| **Noul** | Decisión binaria probabilística (alineación con fundamento) |

**Proveedores (en orden de preferencia):**
0. **Léxico + historial del usuario** — todas las plataformas, offline, explicable.
1. **Embeddings multilingües ONNX** on-device — descarga opcional.
2. **Ollama local** en Desktop (`http://localhost:11434`) — `llama3.2:3b` o `qwen2.5:7b`.
3. **Jev API** (TypeSafe AI, en la nube, de pago) — *opt-in* y solo para contenido comunitario público.

> El usuario siempre valida las sugerencias; los puntajes de intensidad, coherencia y paz los pone él. Ver [ADR-002](./docs/adr/002-estrategia-ia.md).

---

## 🔗 El Circuito de Correlación

```
   [ESTUDIO]            [PRAXIS]             [ORACIÓN]
   Devocional         Bitácora A-B-C       Voz transcrita
       │                    │                    │
       └──────────┬─────────┴──────────┬─────────┘
                  ▼                    ▼
       [TÓPICOS COMPARTIDOS] ───► [GRAFO DE PERSONALIDAD]
                  │                    │
                  ▼                    ▼
       [ÍNDICE DE EFECTIVIDAD]   [DASHBOARD DE EJES]
       (correlación estudio↔vida) (Personal + Comunitario)
```


---

## 💻 Tech Stack

| Capa | Tecnología |
|------|------------|
| **Framework** | Flutter (Multiplatform) |
| **Gestión de Estado** | `flutter_riverpod` |
| **Base de Datos Local** | Drift (SQLite) cifrado con SQLite3MultipleCiphers |
| **Backup Personal** | Google Drive `appDataFolder` (cifrado AES-256-GCM en cliente) |
| **Backend Comunitario** | Supabase Free (Auth, Postgres + RLS + `ltree`, Storage) |
| **Imágenes (overflow)** | Cloudflare R2 (10 GB gratis, egress $0) |
| **Grafo de Personalidad** | `graphview` |
| **Gráficos** | `fl_chart` + `CustomPainter` |
| **IA On-Device** | Léxico local · ONNX Runtime (embeddings) |
| **IA Desktop** | Ollama (opcional) |

---

## 🚀 Estado del Proyecto

✅ **Release 0.2 (Sprints 0-9)**: Estudio, Bitácora A-B-C, Altar por voz, Ejes (dashboards, grafo, aluvión) y respaldo cifrado. Todo local y cifrado; 151 tests en verde. Siguiente: comunidad con Supabase (Sprint 10). Consulta [`PLAN-DE-TRABAJO.md`](./PLAN-DE-TRABAJO.md) para el roadmap detallado y [`ARCHITECTURE.md`](./ARCHITECTURE.md) para la visión técnica y [`docs/ANALISIS-TECNICO.md`](./docs/ANALISIS-TECNICO.md) para el análisis y las decisiones.

---

## 📦 Instalación Rápida

```bash
git clone <url-del-repo> teleios
cd teleios/app
flutter pub get
flutter run -d windows --dart-define-from-file=config/dev.json   # o -d <android>

# Tests y análisis
flutter test
flutter analyze

# Si cambias tablas de Drift
dart run build_runner build

# Opcional (Desktop) — IA local con Ollama
# 1. Instalar Ollama: https://ollama.com
# 2. Descargar modelo optimizado
ollama run llama3.2:3b
# TELEIOS se conecta automáticamente a http://localhost:11434
```

## 🎨 Marca

Paleta, tipografías e íconos: [`docs/brand/BRAND.md`](./docs/brand/BRAND.md).

## 📤 Empaquetar ejecutables

Desde la raíz del repo, en Windows (resultado en `dist\`, ignorado por git):

| Script | Para qué | Genera |
|--------|----------|--------|
| `build-debug.bat` | Probar en tus equipos (requiere Visual Studio en la PC) | `.zip` Windows + `.apk` debug |
| `build-release.bat` | Instalar en cualquier PC / teléfono | `.zip` Windows portable + `.apk` firmado |

Opciones: `rapido` (omite análisis y tests) e `instalar` (instala el APK por USB con `adb`).

> 🔑 La primera ejecución de `build-release.bat` crea la llave de firma Android en `app\android\keys\` y `app\android\key.properties`. **Respáldalas fuera del repo**: sin ellas no se puede actualizar la app ya instalada.
>
> 🔢 Antes de cada nuevo release sube `version:` en `app/pubspec.yaml` (p. ej. `0.1.0+1` → `0.1.1+2`); Android exige que el número tras `+` aumente.
