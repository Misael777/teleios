import '../entities/topic.dart';

abstract interface class TopicRepository {
  Stream<List<Topic>> watchAll({Set<TopicStatus>? statuses});

  Future<List<Topic>> getAll();

  Future<Topic?> findById(String id);

  /// Búsqueda insensible a mayúsculas y tildes dentro de una dimensión.
  Future<Topic?> findByName(String name, String dimensionId);

  Future<void> insert(Topic topic);

  Future<void> update(Topic topic);

  /// Tópicos ya usados en devocionales de un libro (para el sugeridor).
  Future<List<Topic>> topicsUsedWithBook(String bookCode);

  /// topicId → número de devocionales donde aparece.
  Future<Map<String, int>> usageCounts();
}

/// Ejecuta varias operaciones de repositorio de forma atómica.
abstract interface class TransactionRunner {
  Future<T> run<T>(Future<T> Function() action);
}
