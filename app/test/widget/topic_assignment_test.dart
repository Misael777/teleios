import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:teleios/core/theme/app_theme.dart';
import 'package:teleios/features/estudio/domain/devotional.dart';
import 'package:teleios/features/estudio/presentation/widgets/topic_assignment_section.dart';
import 'package:teleios/infrastructure/ai/topic_suggester.dart';
import 'package:teleios/shared/domain/entities/dimension.dart';

void main() {
  const suggestion = TopicSuggestion(
    name: 'Paciencia',
    dimensionId: Dimension.vidaPractica,
    confidence: 0.8,
    reasons: ['paciencia', 'esperar'],
    source: SuggestionSource.lexicon,
  );
  const chosen = TopicDraft(name: 'Soberanía', dimensionId: Dimension.caracterDios);

  Future<(List<String>, List<String>, List<String>)> pump(WidgetTester tester) async {
    final accepted = <String>[];
    final dismissed = <String>[];
    final removed = <String>[];
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(),
        home: Scaffold(
          body: SingleChildScrollView(
            child: TopicAssignmentSection(
              selected: const [chosen],
              suggestions: const [suggestion],
              userTopics: const [],
              onAdd: (_) {},
              onRemove: (d) => removed.add(d.name),
              onMove: (_, _) {},
              onAccept: (s) => accepted.add(s.name),
              onDismiss: (s) => dismissed.add(s.name),
            ),
          ),
        ),
      ),
    );
    return (accepted, dismissed, removed);
  }

  testWidgets('muestra las 4 dimensiones con sus tópicos y sugerencias', (tester) async {
    await pump(tester);
    for (final d in Dimension.all) {
      expect(find.text(d.name), findsOneWidget);
    }
    expect(find.text('Soberanía'), findsOneWidget);
    expect(find.text('Paciencia'), findsOneWidget);
    expect(find.byIcon(Icons.auto_awesome), findsOneWidget);
  });

  testWidgets('tocar una sugerencia la acepta; la X la descarta', (tester) async {
    final (accepted, dismissed, _) = await pump(tester);
    await tester.tap(find.text('Paciencia'));
    expect(accepted, ['Paciencia']);

    await tester.tap(find.byTooltip('Descartar sugerencia'));
    expect(dismissed, ['Paciencia']);
  });

  testWidgets('quitar un tópico elegido', (tester) async {
    final (_, _, removed) = await pump(tester);
    await tester.tap(find.byTooltip('Quitar'));
    expect(removed, ['Soberanía']);
  });
}
