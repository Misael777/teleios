# TELEIOS 🏛️📊

> *"Sed, pues, vosotros perfectos, como vuestro Padre que está en los cielos es perfecto."* — Mateo 5:48

**TELEIOS** es una plataforma multiplataforma (**iOS, Android, Desktop, Web**) desarrollada en **Flutter**, diseñada para la **ingeniería espiritual, el análisis psicoteológico y la analítica cognitiva**. Bajo una arquitectura *Local-First*, permite estructurar estudios bíblicos con rigor teológico, registrar la praxis diaria mediante bitácoras emocionales, dictar oraciones por voz y mapear dinámicamente la estructura de la personalidad a través de un **Grafo de Fuerza Dirigida**.

A diferencia de las aplicaciones que dependen de costosos y lentos LLMs generativos, TELEIOS integra el paradigma de **Modelos System One (Jev / LocalJev)**, permitiendo clasificaciones tipadas, ultra rápidas y probabilísticas directamente en el dispositivo del usuario — garantizando **$0 de costo de infraestructura en IA** y **privacidad absoluta**.

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
- Infraestructura teológica local (manuscritos, variantes, Strong) en **Isar Database**.
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

## 🤖 Motor de IA: System One (Jev-Architecture)

TELEIOS **no genera texto**; **clasifica estados cognitivos** mediante primitivas tipadas:

| Primitiva | Propósito |
|-----------|-----------|
| **Choice** | Selección de tópicos desde array predefinido, con confianza |
| **Score** | Evaluación de intensidad emocional, coherencia y paz (1-10) |
| **Noul** | Decisión binaria probabilística (alineación con fundamento) |

**Estrategia multiplataforma:**
- **Desktop:** Ollama local (`http://localhost:11434`) — `llama3.2:3b` o `qwen2.5:7b`.
- **Mobile:** LocalJev / Open-Jev on-device vía `llama.cpp` + `dart:ffi` (GGUF Q4, < 1.5 GB RAM) · Ollama Bridge por Wi-Fi LAN.

---

## 🔗 El Circuito de Correlación
[ESTUDIO] [PRAXIS] [ORACIÓN]
Devocional Bitácora ABC Voz transcrita
│ │ │
└──────┬──────────────┴──────────┬───────────┘
▼ ▼
[TÓPICOS COMPARTIDOS] ───► [GRAFO DE PERSONALIDAD]
│ │
▼ ▼
[ÍNDICE DE EFECTIVIDAD] [DASHBOARD CLÍNICO]
(Causa y Efecto Teológico) (Personal + Comunitario)


---

## 💻 Tech Stack

| Capa | Tecnología |
|------|------------|
| **Framework** | Flutter (Multiplatform) |
| **Gestión de Estado** | `flutter_bloc` / `riverpod` |
| **Base de Datos Local** | Isar Database |
| **Backend Comunitario** | Supabase (Edge Functions + K-Anonimato) |
| **Grafo de Personalidad** | `graphview` |
| **Gráficos Clínicos** | `fl_chart` |
| **IA On-Device** | Jev / LocalJev · `llama.cpp` vía `dart:ffi` |
| **IA Desktop** | Ollama (`/v1/chat/completions`) |

---

## 🚀 Estado del Proyecto

MVP 1 en desarrollo activo. Consulta [`PLAN-DE-TRABAJO.md`](./PLAN-DE-TRABAJO.md) para el roadmap detallado y [`ARCHITECTURE.md`](./ARCHITECTURE.md) para la visión técnica.

---

## 📦 Instalación Rápida

```bash
git clone https://github.com/tu-usuario/teleios-system-one.git
cd teleios-system-one
flutter pub get
flutter run -d <dispositivo>

# 1. Instalar Ollama: https://ollama.com
# 2. Descargar modelo optimizado
ollama run llama3.2:3b
# TELEIOS se conecta automáticamente a http://localhost:11434