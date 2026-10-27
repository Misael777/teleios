# ADR-001 — Base de datos local: Drift (SQLite) cifrado

- **Estado:** Aceptado · 2026-10-27
- **Reemplaza:** Isar (propuesta original)

## Contexto
La zona privada guarda años de diario personal. La base local debe estar mantenida, soportar migraciones de esquema, cifrado y consultas analíticas (agrupaciones por tópico, ventanas de tiempo). Isar fue abandonado por su autor y solo sobrevive en forks comunitarios; Isar 3 no soporta Web.

## Decisión
Usar **Drift** sobre SQLite con **SQLite3MultipleCiphers** (soportado por drift ≥ 2.32). La llave de 256 bits se genera en el primer arranque y se guarda en Keychain/Keystore vía `flutter_secure_storage`. No incluir `sqlite3_flutter_libs` junto al proveedor cifrado (conflicto de símbolos).

## Consecuencias
- ✅ SQL real, FTS5 para búsqueda bíblica, migraciones testeables, ecosistema estable.
- ✅ Formato de archivo estándar → backup simple con `VACUUM INTO`.
- ⚠️ Más verboso que un ORM de objetos; se mitiga con DAOs generados.
