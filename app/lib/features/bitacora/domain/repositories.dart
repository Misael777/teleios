import '../../../shared/domain/entities/praxis_entry.dart';
import '../../../shared/domain/entities/topic.dart';
import 'praxis.dart';

abstract interface class PraxisRepository {
  Stream<List<PraxisRecord>> watch([PraxisFilter filter = const PraxisFilter()]);

  Stream<PraxisRecord?> watchById(String id);

  Future<PraxisRecord?> getById(String id);

  /// Registros desde [since] (p. ej. para vincular una oración a la praxis reciente).
  Future<List<PraxisRecord>> since(DateTime since);

  /// Crea o actualiza el registro y reemplaza sus enlaces (emociones, detonantes, tópicos).
  Future<void> upsert(PraxisEntry entry);

  Future<void> delete(String id);

  /// Tópicos estudiados en devocionales desde [since]: se sugieren primero al registrar.
  Future<List<Topic>> recentlyStudiedTopics(DateTime since);
}

abstract interface class PraxisCatalogRepository {
  Stream<List<CatalogEntry>> watchEmotions();

  Stream<List<CatalogEntry>> watchTriggers();

  Future<CatalogEntry> addEmotion(String name, {String? parentId});

  Future<CatalogEntry> addTrigger(String name);
}

abstract interface class AttachmentRepository {
  Future<List<Attachment>> listFor(String ownerType, String ownerId);

  Future<List<Attachment>> all();

  Future<void> add(Attachment attachment);

  Future<void> remove(String id);
}
