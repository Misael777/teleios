import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/domain/entities/praxis_entry.dart';
import '../../../shared/providers.dart';
import '../data/drift_praxis_repository.dart';
import '../domain/praxis.dart';
import '../domain/repositories.dart';
import '../domain/save_praxis.dart';

final praxisRepositoryProvider = Provider<PraxisRepository>(
  (ref) => DriftPraxisRepository(ref.watch(appDatabaseProvider)),
);

final praxisCatalogProvider = Provider<PraxisCatalogRepository>(
  (ref) => DriftPraxisCatalogRepository(ref.watch(appDatabaseProvider)),
);

final savePraxisProvider = Provider(
  (ref) => SavePraxis(
    praxis: ref.watch(praxisRepositoryProvider),
    topics: ref.watch(topicRepositoryProvider),
    attachments: ref.watch(attachmentRepositoryProvider),
    store: ref.watch(attachmentStoreProvider),
    transaction: ref.watch(appDatabaseProvider),
  ),
);

final deletePraxisProvider = Provider(
  (ref) => DeletePraxis(
    praxis: ref.watch(praxisRepositoryProvider),
    attachments: ref.watch(attachmentRepositoryProvider),
    store: ref.watch(attachmentStoreProvider),
    transaction: ref.watch(appDatabaseProvider),
  ),
);

final praxisFilterProvider = NotifierProvider<PraxisFilterNotifier, FilterType?>(PraxisFilterNotifier.new);

class PraxisFilterNotifier extends Notifier<FilterType?> {
  @override
  FilterType? build() => null;

  void set(FilterType? value) => state = value;
}

final praxisListProvider = StreamProvider<List<PraxisRecord>>(
  (ref) => ref.watch(praxisRepositoryProvider).watch(PraxisFilter(filter: ref.watch(praxisFilterProvider))),
);

final praxisByIdProvider = StreamProvider.family<PraxisRecord?, String>(
  (ref, id) => ref.watch(praxisRepositoryProvider).watchById(id),
);

final emotionsProvider = StreamProvider<List<CatalogEntry>>((ref) => ref.watch(praxisCatalogProvider).watchEmotions());

final triggersProvider = StreamProvider<List<CatalogEntry>>((ref) => ref.watch(praxisCatalogProvider).watchTriggers());
