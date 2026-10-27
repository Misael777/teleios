# ADR-004 — Backup cifrado en Google Drive del usuario

- **Estado:** Aceptado · 2026-10-27

## Contexto
Los datos privados viven solo en el teléfono. Se necesita respaldo gratuito, sin que el proveedor pueda leer el contenido, restaurable en otro dispositivo.

## Decisión
- Snapshot con `VACUUM INTO` + adjuntos + `manifest.json` → zip.
- Cifrado **AES-256-GCM**; llave derivada con **Argon2id** de una *passphrase de backup* elegida por el usuario (independiente de la llave del Keystore, para poder restaurar en otro equipo). Código de recuperación de 24 palabras.
- Destinos: **Google Drive `appDataFolder`** (scope `drive.appdata`, rotación de 5 copias) o **archivo** vía hoja de compartir (iCloud/Files/correo).
- Automático semanal con Wi-Fi.

## Consecuencias
- ✅ $0, usa los 15 GB del usuario; Google guarda un blob ilegible.
- ⚠️ Passphrase + código de recuperación perdidos = datos irrecuperables. Se advierte claramente.
- ⚠️ Verificar clasificación del scope y proceso de verificación OAuth antes del release público.
