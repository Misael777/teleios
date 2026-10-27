import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../features/estudio/data/drift_devotional_repository.dart';
import '../features/estudio/domain/repositories.dart';
import '../features/estudio/domain/save_devotional.dart';
import '../infrastructure/ai/topic_suggester.dart';
import 'data/database/app_database.dart';
import 'data/repositories/drift_topic_repository.dart';
import 'domain/entities/topic.dart';
import 'domain/repositories/topic_repository.dart';
import 'domain/usecases/topic_usecases.dart';

// ─── Infraestructura (inyectada en main) ───────────────────────────────────

final appDatabaseProvider = Provider<AppDatabase>((ref) => throw UnimplementedError('Se inyecta en main()'));

final bibleRepositoryProvider = Provider<BibleRepository>((ref) => throw UnimplementedError('Se inyecta en main()'));

// ─── Repositorios ──────────────────────────────────────────────────────────

final topicRepositoryProvider = Provider<TopicRepository>(
  (ref) => DriftTopicRepository(ref.watch(appDatabaseProvider)),
);

final devotionalRepositoryProvider = Provider<DevotionalRepository>(
  (ref) => DriftDevotionalRepository(ref.watch(appDatabaseProvider)),
);

// ─── Casos de uso ──────────────────────────────────────────────────────────

final createTopicProvider = Provider((ref) => CreateTopic(ref.watch(topicRepositoryProvider)));

final createIncubationTopicProvider = Provider((ref) => CreateIncubationTopic(ref.watch(createTopicProvider)));

final validateTopicProvider = Provider((ref) => ValidateTopic(ref.watch(topicRepositoryProvider)));

final refuteTopicProvider = Provider((ref) => RefuteTopic(ref.watch(topicRepositoryProvider)));

final reopenTopicProvider = Provider((ref) => ReopenTopic(ref.watch(topicRepositoryProvider)));

final saveDevotionalProvider = Provider(
  (ref) => SaveDevotional(
    devotionals: ref.watch(devotionalRepositoryProvider),
    topics: ref.watch(topicRepositoryProvider),
    transaction: ref.watch(appDatabaseProvider),
  ),
);

final topicSuggesterProvider = Provider((ref) => const TopicSuggester());

// ─── Lecturas reactivas ────────────────────────────────────────────────────

final allTopicsProvider = StreamProvider<List<Topic>>((ref) => ref.watch(topicRepositoryProvider).watchAll());
