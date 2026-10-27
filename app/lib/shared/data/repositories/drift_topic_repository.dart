import 'package:drift/drift.dart';

import '../../../core/utils/text_normalizer.dart';
import '../../domain/entities/passage_ref.dart';
import '../../domain/entities/topic.dart';
import '../../domain/repositories/topic_repository.dart';
import '../database/app_database.dart';

class DriftTopicRepository implements TopicRepository {
  DriftTopicRepository(this._db);

  final AppDatabase _db;

  @override
  Stream<List<Topic>> watchAll({Set<TopicStatus>? statuses}) {
    final query = _db.select(_db.topics)..orderBy([(t) => OrderingTerm.asc(t.nameKey)]);
    if (statuses != null) query.where((t) => t.status.isIn(statuses.map((s) => s.name)));
    return query.watch().map((rows) => rows.map(toTopic).toList());
  }

  @override
  Future<List<Topic>> getAll() async =>
      (await (_db.select(_db.topics)..orderBy([(t) => OrderingTerm.asc(t.nameKey)])).get()).map(toTopic).toList();

  @override
  Future<Topic?> findById(String id) async {
    final row = await (_db.select(_db.topics)..where((t) => t.id.equals(id))).getSingleOrNull();
    return row == null ? null : toTopic(row);
  }

  @override
  Future<Topic?> findByName(String name, String dimensionId) async {
    final row = await (_db.select(
      _db.topics,
    )..where((t) => t.nameKey.equals(TextNormalizer.key(name)) & t.dimensionId.equals(dimensionId))).getSingleOrNull();
    return row == null ? null : toTopic(row);
  }

  @override
  Future<void> insert(Topic topic) => _db.into(_db.topics).insert(_toCompanion(topic));

  @override
  Future<void> update(Topic topic) => _db.update(_db.topics).replace(_toCompanion(topic));

  @override
  Future<List<Topic>> topicsUsedWithBook(String bookCode) async {
    final query = _db.select(_db.topics).join([
      innerJoin(_db.devotionalTopics, _db.devotionalTopics.topicId.equalsExp(_db.topics.id)),
      innerJoin(_db.devotionals, _db.devotionals.id.equalsExp(_db.devotionalTopics.devotionalId)),
    ])..where(_db.devotionals.bookCode.equals(bookCode));
    final rows = await query.get();
    final byId = {for (final r in rows) r.readTable(_db.topics).id: r.readTable(_db.topics)};
    return byId.values.map(toTopic).toList();
  }

  @override
  Future<Map<String, int>> usageCounts() async {
    final count = _db.devotionalTopics.devotionalId.count();
    final query = _db.selectOnly(_db.devotionalTopics)
      ..addColumns([_db.devotionalTopics.topicId, count])
      ..groupBy([_db.devotionalTopics.topicId]);
    final rows = await query.get();
    return {for (final r in rows) r.read(_db.devotionalTopics.topicId)!: r.read(count) ?? 0};
  }

  static Topic toTopic(TopicRow row) => Topic(
    id: row.id,
    name: row.name,
    dimensionId: row.dimensionId,
    status: row.status,
    origin: row.origin,
    confidence: row.confidence,
    note: row.note,
    validationPassage: row.validationPassage == null ? null : PassageRef.decode(row.validationPassage!),
    createdAt: row.createdAt,
    updatedAt: row.updatedAt,
  );

  static TopicsCompanion _toCompanion(Topic t) => TopicsCompanion.insert(
    id: t.id,
    name: t.name,
    nameKey: TextNormalizer.key(t.name),
    dimensionId: t.dimensionId,
    status: t.status,
    origin: t.origin,
    confidence: Value(t.confidence),
    note: Value(t.note),
    validationPassage: Value(t.validationPassage?.encode()),
    createdAt: t.createdAt,
    updatedAt: t.updatedAt,
  );
}
