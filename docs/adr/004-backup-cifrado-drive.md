# ADR-004 — Backup cifrado en Google Drive del usuario

- **Estado:** Aceptado · 2026-10-27 · **Revisado** 2026-10-27 (implementación del Sprint 9)

## Contexto
Los datos privados viven solo en el teléfono. Se necesita respaldo gratuito, sin que el proveedor pueda leer el contenido, restaurable en otro dispositivo.

## Decisión (implementada)

**Contenido.** Exportación **lógica** (JSON de todas las tablas + adjuntos descifrados) en un ZIP — no el archivo SQLite.
> *Cambio respecto al diseño inicial (`VACUUM INTO`):* el archivo SQLite está cifrado con la llave del dispositivo; exportar datos lógicos hace el backup independiente de esa llave y permite restaurar en versiones de esquema posteriores.

**Formato `.teleios`.** `TELEIOSBK | versión | largo cabecera | cabecera JSON | AES-256-GCM(cuerpo)`; la cabecera va autenticada como AAD (no se puede alterar sin detectarlo).

**Llaves.** Una **llave de datos** aleatoria (256 bits) cifra el contenido y viaja envuelta dos veces en la cabecera:
- con una llave derivada de la **contraseña** (Argon2id m=19 MiB, t=2, p=1 — OWASP; calculada en otro isolate);
- con una llave derivada del **código de recuperación** (256 bits aleatorios en Base32, 13 grupos de 4; HKDF-SHA256).
> *Cambio:* código Base32 en vez de 24 palabras (mismo nivel de seguridad, sin depender de una lista de palabras).

El material de llaves se guarda en el almacén seguro del sistema para respaldar sin pedir la contraseña cada vez. Cambiar la contraseña re-envuelve la llave de datos sin re-cifrar nada.

**Destinos.**
- **Archivo**: hoja de compartir (móvil) o "Guardar como" (escritorio).
- **Google Drive** `appDataFolder` (scope `drive.appdata`, conserva 5). Requiere credenciales OAuth propias: [`GOOGLE-DRIVE-SETUP.md`](../GOOGLE-DRIVE-SETUP.md).

**Automático.** Semanal, al abrir o volver a la app (no `workmanager`): multiplataforma y sin permisos de segundo plano.
> *Cambio:* se evita una tarea en segundo plano; si la app no se abre en una semana, el respaldo ocurre en la siguiente apertura.

**Restauración.** Verifica la versión de esquema (rechaza backups más nuevos), descifra, reemplaza todo en una transacción y conserva el material de llaves para los respaldos siguientes. Una contraseña incorrecta no modifica nada.

**Adjuntos.** Las fotos se guardan cifradas en disco (AES-GCM con llave derivada de la de la base) y se re-cifran con la llave del nuevo dispositivo al restaurar.

## Consecuencias
- ✅ $0; Google guarda un archivo que no puede leer.
- ✅ Verificado por test: respaldo → borrar → restaurar produce datos idénticos; restauración "en otro dispositivo" solo con el código.
- ⚠️ Contraseña + código perdidos = respaldo irrecuperable (se advierte; el código se muestra una sola vez y exige confirmar que se guardó).
- ⚠️ Drive requiere configurar OAuth y, para el público, la verificación de la pantalla de consentimiento.
