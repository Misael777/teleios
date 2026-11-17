# Conectar Google Drive (respaldo automático)

El respaldo **en archivo** funciona sin configurar nada. Para el respaldo **directo y automático en Google Drive** hay que crear credenciales OAuth propias (gratis). Son unos 15 minutos y se hace una sola vez.

> Mientras no lo configures, la app muestra "Esta compilación no tiene credenciales de Google" y el resto funciona igual.

## 1. Proyecto en Google Cloud

1. Entra a <https://console.cloud.google.com> con tu cuenta y crea un proyecto: `teleios`.
2. **APIs y servicios → Biblioteca** → busca **Google Drive API** → *Habilitar*.
3. **Pantalla de consentimiento de OAuth**:
   - Tipo: *Externo*. Nombre de la app: `TELEIOS`. Correo de soporte: el tuyo.
   - **Permisos (scopes)**: agrega solo `.../auth/drive.appdata` ("Ver, crear y eliminar sus propios datos de configuración en Google Drive").
   - **Usuarios de prueba**: agrega tu correo (mientras la app esté en modo "Prueba", solo esas cuentas pueden conectarse).

## 2. Credenciales

En **APIs y servicios → Credenciales → Crear credenciales → ID de cliente de OAuth**:

| Tipo | Datos | Para qué |
|------|-------|----------|
| **Aplicación web** | Nombre: `teleios-server` | Su *Client ID* es el `GOOGLE_SERVER_CLIENT_ID` (Android lo exige) |
| **Android** | Paquete: `com.teleios.teleios` · SHA-1 de tu llave de release | Autoriza a tu APK firmado |
| **iOS** (si publicas en iOS) | Bundle ID: `com.teleios.teleios` | Su *Client ID* es el `GOOGLE_IOS_CLIENT_ID` |

SHA-1 de la llave de release (creada por `build-release.bat`):

```bash
keytool -list -v -keystore app/android/keys/teleios-release.jks -alias teleios
```

La contraseña está en `app/android/key.properties`. Si también usarás builds debug en el teléfono, crea otra credencial Android con el SHA-1 de la llave debug (`%USERPROFILE%\.android\debug.keystore`, contraseña `android`).

## 3. Configurar la app

Edita `app/config/prod.json` (y `dev.json` si corresponde):

```json
{
  "APP_ENV": "prod",
  "GOOGLE_SERVER_CLIENT_ID": "1234567890-xxxx.apps.googleusercontent.com",
  "GOOGLE_IOS_CLIENT_ID": ""
}
```

Vuelve a generar con `build-release.bat`. En la app: **Ajustes → Respaldo cifrado → Conectar Google Drive**.

Estos IDs de cliente **no son secretos** (van dentro de cualquier app publicada), pero no hace falta subirlos al repo si prefieres no hacerlo.

## Qué ve Google

- Un archivo `teleios-backup-AAAAMMDD-HHMM.teleios` en una carpeta oculta de la app (no aparece en tu Drive ni la ven otras apps).
- Su contenido está cifrado con AES-256-GCM; la llave depende de tu contraseña de respaldo, que nunca sale del teléfono. **Google no puede leerlo.**
- Se conservan los 5 respaldos más recientes; los anteriores se borran.

## Publicación

Antes de abrir la app al público, Google revisa la pantalla de consentimiento. `drive.appdata` es un permiso de bajo riesgo, pero necesitarás una URL de política de privacidad (ver [`PRIVACIDAD.md`](./PRIVACIDAD.md), publicable con GitHub Pages).
