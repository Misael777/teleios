import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../infrastructure/stt/speech_service.dart';
import '../../../shared/providers.dart';
import '../data/drift_prayer_repository.dart';
import '../domain/prayer.dart';

final prayerRepositoryProvider = Provider<PrayerRepository>(
  (ref) => DriftPrayerRepository(ref.watch(appDatabaseProvider)),
);

final savePrayerProvider = Provider(
  (ref) => SavePrayer(
    prayers: ref.watch(prayerRepositoryProvider),
    topics: ref.watch(topicRepositoryProvider),
    transaction: ref.watch(appDatabaseProvider),
  ),
);

final speechServiceProvider = Provider<SpeechService>((ref) => DeviceSpeechService());

final prayerListProvider = StreamProvider<List<PrayerRecord>>((ref) => ref.watch(prayerRepositoryProvider).watch());

final prayerByIdProvider = StreamProvider.family<PrayerRecord?, String>(
  (ref, id) => ref.watch(prayerRepositoryProvider).watchById(id),
);
