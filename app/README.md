# TELEIOS — app Flutter

Ver el [README principal](../README.md), [ARCHITECTURE](../ARCHITECTURE.md) y el [plan](../PLAN-DE-TRABAJO.md).

## Comandos

| Tarea | Comando |
|-------|---------|
| Ejecutar (dev) | `flutter run --dart-define-from-file=config/dev.json` |
| Tests | `flutter test` |
| Análisis | `flutter analyze` |
| Regenerar Drift | `dart run build_runner build` |
| Regenerar Biblia | `python tool/build_bible_db.py` |

## Notas

- La base privada se cifra con SQLite3MultipleCiphers (`hooks.user_defines.sqlite3.source: sqlite3mc` en `pubspec.yaml`). No agregues `sqlite3_flutter_libs` ni `sqlcipher_flutter_libs`: chocarían con esa librería.
- En Web los módulos privados no arrancan a propósito (ver `docs/ANALISIS-TECNICO.md`, I5).
- Texto bíblico: Reina-Valera 1909, dominio público ([eBible.org](https://ebible.org/details.php?id=spaRV1909)).
