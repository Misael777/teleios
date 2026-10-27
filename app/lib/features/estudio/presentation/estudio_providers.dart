import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/domain/entities/passage_ref.dart';
import '../../../shared/domain/entities/topic.dart';
import '../../../shared/providers.dart';
import '../domain/devotional.dart';
import '../domain/repositories.dart';

final devotionalFilterProvider = NotifierProvider<DevotionalFilterNotifier, DevotionalFilter>(
  DevotionalFilterNotifier.new,
);

class DevotionalFilterNotifier extends Notifier<DevotionalFilter> {
  @override
  DevotionalFilter build() => const DevotionalFilter();

  void setDimension(String? id) => state = DevotionalFilter(dimensionId: id, bookCode: state.bookCode);

  void setBook(String? code) => state = DevotionalFilter(dimensionId: state.dimensionId, bookCode: code);

  void clear() => state = const DevotionalFilter();
}

final filteredDevotionalsProvider = StreamProvider<List<DevotionalEntry>>(
  (ref) => ref.watch(devotionalRepositoryProvider).watch(ref.watch(devotionalFilterProvider)),
);

final allDevotionalsProvider = StreamProvider<List<DevotionalEntry>>(
  (ref) => ref.watch(devotionalRepositoryProvider).watch(),
);

final devotionalByIdProvider = StreamProvider.family<DevotionalEntry?, String>(
  (ref, id) => ref.watch(devotionalRepositoryProvider).watchById(id),
);

final passageTextProvider = FutureProvider.family<List<BibleVerse>, PassageRef>(
  (ref, passage) => ref.watch(bibleRepositoryProvider).passage(passage),
);

final topicsByStatusProvider = StreamProvider.family<List<Topic>, TopicStatus>(
  (ref, status) => ref.watch(topicRepositoryProvider).watchAll(statuses: {status}),
);
