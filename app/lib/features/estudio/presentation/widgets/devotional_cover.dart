import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/brand.dart';
import '../../../../core/theme/teleios_logo.dart';
import '../../../../core/utils/formatters.dart';
import '../../domain/devotional.dart';
import '../estudio_providers.dart';

/// Portada de un devocional: marca, título del estudio y versículo lema, como una página de título.
class DevotionalCover extends ConsumerWidget {
  const DevotionalCover({super.key, required this.entry});

  final DevotionalEntry entry;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final keyVerse = entry.keyVerse ?? entry.passage;
    final verses = ref.watch(passageTextProvider(keyVerse));
    final title = entry.title;
    return Container(
      key: const Key('devotional-cover'),
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Brand.gold.withValues(alpha: 0.35)),
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Brand.midnightHigh, Brand.midnight],
        ),
      ),
      child: Column(
        children: [
          const TeleiosMark(size: 52),
          const SizedBox(height: 8),
          const GoldText('ΤΕΛΕΙΟΣ', style: TextStyle(fontFamily: Brand.fontGreek, fontSize: 13, letterSpacing: 7)),
          const SizedBox(height: 22),
          Text(
            title ?? entry.passage.label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: Brand.fontScripture,
              fontWeight: FontWeight.w600,
              fontSize: 30,
              height: 1.15,
              color: Brand.cream,
            ),
          ),
          if (title != null) ...[
            const SizedBox(height: 8),
            Text(
              entry.passage.label.toUpperCase(),
              textAlign: TextAlign.center,
              style: const TextStyle(fontFamily: Brand.fontUi, fontSize: 12, letterSpacing: 2.5, color: Brand.gold),
            ),
          ],
          const SizedBox(height: 22),
          Container(width: 48, height: 1, color: Brand.gold.withValues(alpha: 0.6)),
          const SizedBox(height: 18),
          verses.when(
            loading: () => const SizedBox(height: 24),
            error: (_, _) => const SizedBox.shrink(),
            data: (list) {
              final text = list.where((v) => v.text.isNotEmpty).map((v) => v.text).join(' ');
              if (text.isEmpty) return const SizedBox.shrink();
              return Column(
                children: [
                  Text(
                    '«$text»',
                    textAlign: TextAlign.center,
                    maxLines: 8,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontFamily: Brand.fontScripture,
                      fontStyle: FontStyle.italic,
                      fontSize: 18,
                      height: 1.45,
                      color: Brand.cream.withValues(alpha: 0.88),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '— ${keyVerse.label}',
                    style: const TextStyle(
                      fontFamily: Brand.fontUi,
                      fontSize: 12,
                      letterSpacing: 1.5,
                      color: Brand.gold,
                    ),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 22),
          Text(
            Formatters.date(entry.date),
            style: TextStyle(fontFamily: Brand.fontUi, fontSize: 12, color: Brand.cream.withValues(alpha: 0.55)),
          ),
        ],
      ),
    );
  }
}
