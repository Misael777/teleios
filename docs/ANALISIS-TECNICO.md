# 🔍 Análisis Técnico Full-Stack — TELEIOS

> Revisión del repositorio al **27-oct-2026**. Estado real: el repo contiene solo documentación (`README.md`, `ARCHITECTURE.md`, `PLAN-DE-TRABAJO.md`, `conversacion.md`). **No existe aún código Flutter.**
>
> Este documento resume (1) la idea del producto, (2) los problemas encontrados en el diseño original y cómo se corrigieron, y (3) las decisiones técnicas que fundamentan el [plan de sprints](../PLAN-DE-TRABAJO.md).

---

## 1. La idea, destilada

TELEIOS es un **diario espiritual analítico** con dos ejes:

1. **Teoría** — estudio bíblico estructurado (devocionales con tópicos clasificados en 4 dimensiones fijas + contexto histórico que alimenta una línea de tiempo).
2. **Práctica** — bitácora A-B-C (circunstancia → emoción → filtro → acción/paz) y oraciones por voz.

El valor diferencial está en **correlacionar ambos ejes a través de tópicos compartidos**: "¿estudiar *Paciencia* se refleja en mi coherencia y paz cuando me pasa algo?". La IA **sugiere**, el usuario **decide** (metacognición, no automatización).

Encima de eso, una **capa comunitaria opcional**: devocionales públicos, y un dashboard de líder que navega una jerarquía de subgrupos usando **solo métricas numéricas agregadas** (nunca el contenido privado).

**Restricción transversal:** costo de operación lo más cercano a $0.

---

## 2. Hallazgos y correcciones

### 🔴 Críticos (cambian la arquitectura)

| # | Hallazgo | Por qué importa | Corrección aplicada |
|---|----------|-----------------|---------------------|
| C1 | **"LocalJev / Open-Jev on-device" no existe.** Jev (TypeSafe AI) es real, pero se lanzó el 15-sep-2026 como **API en la nube, de pago** (≈ $0.042 / M tokens de entrada). No hay versión local verificable. | Rompe dos promesas del README: "$0 en IA" y "privacidad absoluta". Mandar texto de bitácoras/oraciones a una API externa viola la zona 🔴 del propio modelo de privacidad. | Se mantiene el **contrato** `Choice / Score / Noul` (es buen diseño), pero los proveedores se reordenan: **(0)** heurística léxica local, **(1)** embeddings on-device vía ONNX, **(2)** Ollama en desktop, **(3)** Jev solo *opt-in* y solo para contenido **público**. Ver ADR-002. |
| C2 | **Isar está sin mantenimiento** (el autor original lo dejó; solo hay forks comunitarios `isar_plus`, `isar_db` con salud dudosa). Isar 3 tampoco soporta Web. | Elegir la base de datos de la zona privada es la decisión más difícil de revertir del proyecto. | **Drift (SQLite)** + cifrado con **SQLite3MultipleCiphers** (soportado nativamente desde drift 2.32). SQL real, migraciones versionadas, consultas analíticas (GROUP BY, ventanas) que el dashboard necesita, y soporte Web vía WASM. Ver ADR-001. |
| C3 | **El K-anonimato "N ≥ 5, promediar al padre" es vulnerable a ataques por diferencia.** Si un padre tiene hijos A(12), B(9) y C(3), el líder ve Padre y A y B → puede despejar C. | Un líder podría inferir el estado de una célula de 3 personas — justo lo que se quería evitar. | **Supresión complementaria**: si un hijo queda suprimido, se suprime también el siguiente hermano más pequeño (o el padre no se muestra si el residuo < 5). Además, umbral sobre **miembros distintos que reportaron en el período**, no sobre miembros inscritos. Toda agregación vía RPC `SECURITY DEFINER`; las tablas crudas sin acceso de lectura. |
| C4 | **Traducciones bíblicas con copyright.** El backlog menciona RVR60, LBLA, NVI. Todas tienen derechos (SBU, Lockman, Biblica). | Publicar la app con esos textos sin licencia = retiro de la tienda. | Texto base en **dominio público: Reina-Valera 1909** (+ Strong, que es de dominio público). Otras versiones solo vía API con licencia (p. ej. API.Bible, con sus términos) y nunca empaquetadas. |
| C5 | **"Speech-to-Text local" no es local por defecto.** El paquete `speech_to_text` usa el reconocedor del sistema: en Android puede ir a servidores de Google, en Web (Chrome) **siempre** va a la nube. | Las oraciones son el dato más íntimo de la app. | Forzar reconocimiento on-device (`onDevice: true` en Android 13+, `requiresOnDeviceRecognition` en iOS) y mostrar al usuario si el dispositivo no lo soporta. Alternativa 100% offline: `whisper.cpp` (modelo `base`/`small`) en sprint posterior. Grabación por voz **deshabilitada en Web**. |

### 🟠 Importantes

| # | Hallazgo | Corrección |
|---|----------|-----------|
| I1 | **Supabase Free pausa el proyecto tras 7 días sin actividad.** En una beta con pocos usuarios pasará. | Workflow de GitHub Actions que hace un `select` liviano cada 3 días (keep-alive). |
| I2 | **Cambio de Supabase (30-oct-2026):** los proyectos requieren `GRANT` explícitos en Postgres para que PostgREST exponga tablas. | Todas las migraciones SQL incluyen `GRANT` explícitos + RLS desde el día 1. |
| I3 | **"Índice de Efectividad Teológica" se presenta como causa-efecto.** Son autoevaluaciones correlacionadas, con confusores (estado de ánimo, sesgo de deseabilidad). | Se renombra la narrativa a **correlación** en UI. Mostrar n, intervalo y no mostrar tendencias con n < 8 registros. Usar Spearman (datos ordinales 1-10), no Pearson. IET normalizado a 0-1: `Σ(coh·paz)/(100·n)`. |
| I4 | **Datos de categoría especial.** Creencias religiosas + estado emocional = datos sensibles (GDPR art. 9; también en leyes latinoamericanas de protección de datos). | Consentimiento explícito en onboarding, política de privacidad, botón "exportar/borrar mis datos", la palabra "clínico" se elimina de la UI (la app **no es** una herramienta de salud mental; disclaimer). |
| I5 | **La zona privada en Web** (navegador) es débil: el almacenamiento puede borrarse y el cifrado en WASM es menos robusto. | Web = solo capa **comunitaria + dashboard de líder**. Los módulos privados corren en Android / iOS / Desktop. |
| I6 | **Alcance del MVP 1 demasiado grande** para 14-16 semanas a tiempo parcial (4 módulos + IA + grafo + multiusuario + K-anonimato). | Dividido en **Release 0.1 Personal** (sin backend) → **0.2 Backup** → **0.3 Comunidad** → **0.4 Líder**. Cada release es usable por sí sola. |
| I7 | **Sin sincronización entre dispositivos** para la zona privada. | Aceptado como decisión: en el MVP la "sincronización" es **backup/restore cifrado a Google Drive**. Sync en vivo E2E queda en backlog. |
| I8 | `syncfusion_flutter_treemap` requiere licencia (Community gratis solo si ingresos < $1M y ≤ 5 devs). | Aceptable para el proyecto; documentar. Alternativa: treemap propio con `CustomPainter` (algoritmo squarified, ~200 líneas). |

### 🟡 Documentación (ya corregido en este commit)

- `ARCHITECTURE.md`: bloques de código y tablas sin cerrar (el árbol de carpetas, las clases Dart y las tablas se renderizaban rotas). Reescrito.
- `README.md`: el diagrama "Circuito de Correlación" estaba fuera de bloque de código; el enlace a `PLAN-DE-TRABAJO.md` no coincidía con el archivo `.MD` (GitHub es sensible a mayúsculas → enlace roto). Archivo renombrado.
- `README.md` decía "MVP 1 en desarrollo activo" e instrucciones de instalación de un repo que no existe → ajustado a "fase de diseño".
- Se agregó `docs/adr/` con las decisiones de arquitectura.

---

## 3. Arquitectura propuesta (resumen)

```
┌──────────────────────── DISPOSITIVO (Android · iOS · Desktop) ────────────────────────┐
│                                                                                        │
│  Flutter UI ──► Riverpod ──► Use cases (Dart puro) ──► Repositorios                    │
│                                                         │                              │
│            ┌────────────────────────────────────────────┼──────────────────────┐       │
│            ▼                                            ▼                      ▼       │
│  🔴 Drift + SQLite3MultipleCiphers           📁 Adjuntos privados      🤖 IA local     │
│     (devocionales, praxis, oraciones,           (imágenes WebP          heurística +    │
│      tópicos, métricas)                          en app dir)            ONNX embeddings │
│     llave en Keychain/Keystore                                                          │
│            │                                                                            │
│            └──► Backup: snapshot + zip + AES-256-GCM (llave derivada Argon2id) ──┐      │
└──────────────────────────────────────────────────────────────────────────────────┼──────┘
                                                                                   │
          ┌────────────────────────────────────────┐                               ▼
          │  SUPABASE (Free)                        │                 ┌──────────────────────┐
          │  • Auth (Google / email)                │                 │ Google Drive personal │
          │  • Postgres + RLS + ltree (subgrupos)   │                 │ appDataFolder (oculto)│
          │  • RPC k-anónimas (SECURITY DEFINER)    │                 │ últimos 5 backups     │
          │  • Storage: imágenes públicas (≤1 GB)   │                 └──────────────────────┘
          └───────────────┬────────────────────────┘
                          │ overflow de imágenes
                          ▼
                 Cloudflare R2 (10 GB, egress $0)
```

### Zonas de datos

| Zona | Qué | Dónde | Sale del dispositivo |
|------|-----|-------|----------------------|
| 🔴 Privada cruda | Texto de bitácoras, emociones, oraciones, fotos privadas | Drift cifrado + carpeta privada | **Solo** dentro del backup cifrado con la passphrase del usuario (Google no puede leerlo) |
| 🟡 Privada derivada | Promedios semanales por tópico (coherencia, paz, n) | Drift | Sí, **sin texto**, asociado a subgrupo, solo si el usuario lo activa |
| 🟢 Comunitaria | Devocionales publicados, tópicos globales, votos, imágenes públicas | Supabase | Sí (es pública dentro de la comunidad) |

---

## 4. Opciones gratuitas evaluadas

### 4.1 Backend

| Opción | Free tier | Veredicto |
|--------|-----------|-----------|
| **Supabase** | 2 proyectos, 500 MB DB, 1 GB storage, 5 GB egress, 50k MAU; pausa tras 7 días inactivo | ✅ **Elegido.** Postgres real (RLS, `ltree`, funciones SQL) es justo lo que necesita la jerarquía de subgrupos y el k-anonimato. |
| Firebase | Firestore 1 GB, Storage requiere plan Blaze desde 2024 | ❌ Agregaciones jerárquicas en Firestore son costosas y torpes. |
| PocketBase self-hosted | Gratis pero necesitas servidor | ❌ Agrega operación de servidor. |

### 4.2 Imágenes en la nube (solo contenido comunitario)

| Opción | Free tier | Uso |
|--------|-----------|-----|
| **Supabase Storage** | ~1 GB, integrado con Auth/RLS | ✅ **Primario.** Con compresión cliente a WebP 1280px (~120-200 KB) caben ~5.000-8.000 imágenes. |
| **Cloudflare R2** | 10 GB-mes, 1M ops A, 10M ops B, **egress gratis** | ✅ **Plan B** cuando Supabase se acerque al 80%. API S3, se accede vía URL firmada generada por Edge Function. |
| Cloudinary | 25 créditos/mes | Opcional si se requieren transformaciones on-the-fly. No necesario. |

**Regla:** las imágenes **privadas** (adjuntas a una bitácora) **nunca** van a un bucket; viven en el teléfono y viajan solo dentro del backup cifrado.

### 4.3 Base de datos local

| Opción | Estado 2026 | Veredicto |
|--------|-------------|-----------|
| Isar | Original sin mantenimiento, forks comunitarios | ❌ Riesgo alto para datos de años de un usuario. |
| ObjectBox | Mantenido, rápido; cifrado solo en versión comercial | ⚠️ |
| Hive / Hive CE | Key-value, sin consultas relacionales | ❌ Las analíticas requieren JOINs/agrupaciones. |
| **Drift (SQLite)** | Activo, tipado, migraciones, cifrado vía SQLite3MultipleCiphers, Web vía WASM | ✅ **Elegido.** |

### 4.4 Backup en Google Drive

- **Scope:** `drive.appdata` (carpeta oculta de la app; el usuario no la ve en Drive y la app no ve el resto de su Drive). Verificar en Google Cloud Console la clasificación de scope y el proceso de verificación OAuth antes del release público.
- **Flujo:** `VACUUM INTO` (snapshot consistente) → zip con adjuntos → cifrar con AES-256-GCM, llave derivada con **Argon2id** de una *passphrase de backup* del usuario → subir → conservar los 5 más recientes.
- **Por qué passphrase propia:** si se usara la llave del Keystore, al cambiar de teléfono el backup sería irrecuperable. Con passphrase, se restaura en cualquier dispositivo. Se ofrece **código de recuperación** de 24 palabras al configurar.
- **Alternativa sin Google** (iOS / usuarios sin cuenta Google): exportar el mismo archivo cifrado con la hoja de compartir del sistema (iCloud Drive, Files, correo).
- **Costo:** $0 (usa los 15 GB del usuario).

### 4.5 IA (corregido)

| Nivel | Técnica | Dónde | Costo | Para qué |
|-------|---------|-------|-------|----------|
| 0 | Léxico de tópicos/emociones en español (sinónimos + stemming) + historial del usuario (frecuencia, co-ocurrencia) | Todas | $0 | Sugeridor de tópicos MVP. Explicable ("sugerido porque escribiste *esperar*, *calma*"). |
| 1 | Embeddings multilingües cuantizados (p. ej. `multilingual-e5-small` int8, ~40-120 MB, descarga opcional) vía `onnxruntime` | Android/iOS/Desktop | $0 | `Choice` semántico: similitud texto ↔ tópicos; intención de oración por prototipos. |
| 2 | Ollama local (`llama3.2:3b`, `qwen2.5:7b`) | Desktop | $0 | Clasificación más fina con salida JSON tipada. |
| 3 | Jev API (TypeSafe) | Online | Pago por uso | **Opt-in**, solo contenido 🟢 público (p. ej. clasificar devocionales comunitarios). Nunca bitácoras ni oraciones. |

`Score` (intensidad, coherencia, paz) **lo pone el usuario con sliders** — es parte del ejercicio de metacognición, no algo a automatizar.

### 4.6 Costos reales del proyecto

| Concepto | Costo |
|----------|-------|
| Supabase, R2, Drive, GitHub Actions (repo público ilimitado / privado 2.000 min/mes) | $0 |
| Codemagic (builds iOS sin Mac, 500 min/mes) | $0 |
| Google Play Console | **$25 único** |
| Apple Developer Program (solo si se publica en iOS) | **$99/año** |
| Dominio para política de privacidad | Opcional (~$10/año) — o GitHub Pages gratis |

---

## 5. Riesgos

| Riesgo | Prob. | Impacto | Mitigación |
|--------|-------|---------|------------|
| El usuario pierde la passphrase de backup | Media | Pérdida total de datos | Código de recuperación + recordatorio + export manual |
| Supabase cambia el free tier | Media | Medio | Esquema en migraciones SQL portables; Postgres estándar → migrable a Neon/self-host |
| Sobre-alcance / abandono por fatiga | **Alta** | Alto | Releases incrementales usables; el autor es el primer usuario desde el Sprint 4 |
| Re-identificación en dashboard de líder | Baja | **Muy alto** (confianza pastoral) | Supresión complementaria + tests de propiedad + auditoría de privacidad (Sprint 12) |
| STT on-device no disponible en teléfonos antiguos | Media | Bajo | Escritura manual siempre disponible; Whisper offline en backlog |
| Rechazo en App Store / Play por datos sensibles | Baja | Alto | Política de privacidad, data safety form honesto, borrado de cuenta in-app |

---

## Fuentes consultadas

- Jev / TypeSafe AI: [DigitalOcean — What is Jev](https://www.digitalocean.com/resources/articles/what-is-jev), [eesel.ai — TypeSafe Jev explicado](https://www.eesel.ai/es/blog/typesafe-jev), [The New Stack](https://thenewstack.io/typesafe-jev-system-one/)
- Isar forks: [isar_plus](https://pub.dev/documentation/isar_plus/latest/), [isar_db](https://pub.dev/packages/isar_db)
- Drift cifrado: [drift — Encryption](https://drift.simonbinder.eu/platforms/encryption)
- Supabase free tier 2026: [automationatlas.io](https://automationatlas.io/answers/supabase-free-tier-limits-2026/), [makerkit](https://makerkit.dev/blog/saas/supabase-pricing)
- Cloudflare R2: [Filebase — R2 pricing 2026](https://filebase.com/blog/cloudflare-r2-pricing-costs-savings-and-alternatives-in-2026/)

> Las cifras de free tier provienen de fuentes secundarias; verificar en las páginas oficiales de precios antes del Sprint 9.
