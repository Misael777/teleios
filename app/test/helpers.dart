import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:teleios/shared/data/database/app_database.dart';

/// Base en memoria (sin cifrado) para tests de datos.
AppDatabase memoryDatabase() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  return AppDatabase(NativeDatabase.memory(setup: (db) => db.execute('PRAGMA foreign_keys = ON')));
}

/// Reloj controlable para casos de uso.
class FakeClock {
  FakeClock([DateTime? start]) : now = start ?? DateTime(2026, 10, 27, 9);

  DateTime now;

  DateTime call() => now;

  void advance(Duration d) => now = now.add(d);
}
