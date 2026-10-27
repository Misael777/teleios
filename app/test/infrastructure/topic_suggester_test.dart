import 'package:flutter_test/flutter_test.dart';
import 'package:teleios/infrastructure/ai/lexical_classifier.dart';
import 'package:teleios/infrastructure/ai/lexicon_es.dart';
import 'package:teleios/infrastructure/ai/topic_suggester.dart';
import 'package:teleios/shared/domain/entities/dimension.dart';
import 'package:teleios/shared/domain/entities/topic.dart';

Topic userTopic(String name, String dim, {TopicStatus status = TopicStatus.validado, String? id}) => Topic(
  id: id ?? name,
  name: name,
  dimensionId: dim,
  status: status,
  origin: TopicOrigin.usuario,
  createdAt: DateTime(2026),
  updatedAt: DateTime(2026),
);

void main() {
  const suggester = TopicSuggester();
  const galatas =
      'Hoy leí Gálatas 5. El fruto del Espíritu es amor, gozo, paz, paciencia. '
      'Me cuesta tener paciencia con mis hijos cuando no obedecen; quiero aprender dominio propio. '
      'Pablo escribía a iglesias presionadas por los que querían volver a estar bajo la ley.';

  List<String> names(List<TopicSuggestion> s, [String? dim]) =>
      s.where((x) => dim == null || x.dimensionId == dim).map((x) => x.name).toList();

  test('el léxico no tiene tópicos repetidos por dimensión', () {
    final keys = LexiconEs.topics.map((t) => '${t.dimensionId}/${t.name}').toList();
    expect(keys.toSet(), hasLength(keys.length));
  });

  test('sugiere tópicos razonables en varias dimensiones para Gálatas 5', () {
    final s = suggester.suggest(text: galatas);
    expect(names(s, Dimension.vidaPractica), containsAll(['Paciencia', 'Dominio propio']));
    expect(names(s, Dimension.estructuraPensamiento), contains('Fruto del Espíritu'));
    expect(names(s, Dimension.contextoHistorico), contains('Cartas paulinas'));
  });

  test('cada sugerencia explica por qué', () {
    final paciencia = suggester.suggest(text: galatas).firstWhere((s) => s.name == 'Paciencia');
    expect(paciencia.reasons, contains('paciencia'));
    expect(paciencia.confidence, greaterThan(0.4));
  });

  test('máximo N sugerencias por dimensión, ordenadas por confianza', () {
    final s = suggester.suggest(text: galatas, perDimension: 2);
    for (final d in Dimension.all) {
      final inDim = s.where((x) => x.dimensionId == d.id).toList();
      expect(inDim.length, lessThanOrEqualTo(2));
      for (var i = 1; i < inDim.length; i++) {
        expect(inDim[i - 1].confidence, greaterThanOrEqualTo(inDim[i].confidence));
      }
    }
  });

  test('prioriza y enlaza los tópicos propios del usuario', () {
    final mine = userTopic('Crianza con gracia', Dimension.vidaPractica, id: 'mine-1');
    final s = suggester.suggest(text: 'Hoy practiqué la crianza con gracia', userTopics: [mine]);
    final hit = s.firstWhere((x) => x.name == 'Crianza con gracia');
    expect(hit.existingTopicId, 'mine-1');
    expect(hit.source, SuggestionSource.myTopics);
  });

  test('una sugerencia del léxico se enlaza al tópico existente con el mismo nombre', () {
    final mine = userTopic('paciencia', Dimension.vidaPractica, id: 'p1');
    final hit = suggester.suggest(text: galatas, userTopics: [mine]).firstWhere((x) => x.existingTopicId == 'p1');
    expect(hit.dimensionId, Dimension.vidaPractica);
  });

  test('no sugiere tópicos refutados', () {
    final refuted = userTopic('Ojo por ojo', Dimension.vidaPractica, status: TopicStatus.refutado);
    final s = suggester.suggest(text: 'pensé en ojo por ojo', userTopics: [refuted], bookHistory: [refuted]);
    expect(names(s), isNot(contains('Ojo por ojo')));
  });

  test('usa el historial del libro como señal débil', () {
    final s = suggester.suggest(
      text: 'texto sin palabras clave',
      bookHistory: [userTopic('Justificación por la fe', Dimension.estructuraPensamiento)],
      bookName: 'Romanos',
    );
    expect(s.single.reasons.single, 'usado antes en Romanos');
    expect(s.single.confidence, TopicSuggester.historyConfidence);
  });

  test('respeta exclusiones (ya elegidos o descartados)', () {
    final first = suggester.suggest(text: galatas);
    final paciencia = first.firstWhere((s) => s.name == 'Paciencia');
    final again = suggester.suggest(text: galatas, exclude: {paciencia.key});
    expect(names(again), isNot(contains('Paciencia')));
  });

  test('texto vacío no sugiere nada', () => expect(suggester.suggest(text: ''), isEmpty));

  group('LexicalClassifier.choose', () {
    const classifier = LexicalClassifier();

    test('elige la intención con más evidencia', () async {
      final r = await classifier.choose(
        context: 'Señor, gracias por tu provisión, te agradezco por mi familia',
        options: ['Petición', 'Gratitud', 'Lamentación'],
      );
      expect(r.option, 'Gratitud');
      expect(r.reasons, isNotEmpty);
    });

    test('sin evidencia devuelve null y confianza 0', () async {
      final r = await classifier.choose(context: 'xyz', options: ['Gratitud']);
      expect(r.option, isNull);
      expect(r.confidence, 0);
    });

    test('es on-device', () => expect(classifier.isOnDevice, isTrue));
  });
}
