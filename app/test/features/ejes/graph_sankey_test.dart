import 'package:flutter_test/flutter_test.dart';
import 'package:teleios/features/ejes/domain/analytics_data.dart';
import 'package:teleios/features/ejes/domain/personality_graph.dart';
import 'package:teleios/features/ejes/domain/sankey.dart';
import 'package:teleios/shared/domain/entities/dimension.dart';
import 'package:teleios/shared/domain/entities/praxis_entry.dart';
import 'package:teleios/shared/domain/entities/topic.dart';

Topic t(String id, String dim) => Topic(
  id: id,
  name: id,
  dimensionId: dim,
  status: TopicStatus.validado,
  origin: TopicOrigin.usuario,
  createdAt: DateTime(2026),
  updatedAt: DateTime(2026),
);

AnalyticsData sample() => AnalyticsData(
  studies: [
    StudyEvent(date: DateTime(2026, 10, 1), bookCode: 'GAL', topicIds: const ['pac', 'sob']),
  ],
  praxis: [
    PraxisEvent(
      date: DateTime(2026, 10, 2),
      topicIds: const ['pac'],
      emotionIds: const ['ira', 'frustracion'],
      triggerIds: const [],
      filter: FilterType.impulso,
      intensity: 9,
      peace: 2,
      coherence: 1,
    ),
    PraxisEvent(
      date: DateTime(2026, 10, 3),
      topicIds: const ['pac'],
      emotionIds: const ['paz'],
      triggerIds: const [],
      filter: FilterType.biblico,
      intensity: 4,
      peace: 9,
      coherence: 9,
    ),
  ],
  prayers: const [],
  topics: {'pac': t('pac', Dimension.vidaPractica), 'sob': t('sob', Dimension.caracterDios)},
  emotions: const {
    'ira': CatalogEntry(id: 'ira', name: 'Ira'),
    'frustracion': CatalogEntry(id: 'frustracion', name: 'Frustración', parentId: 'ira'),
    'paz': CatalogEntry(id: 'paz', name: 'Paz', parentId: 'alegria'),
    'alegria': CatalogEntry(id: 'alegria', name: 'Alegría'),
  },
  triggers: const {},
);

void main() {
  group('grafo de personalidad', () {
    test('dimensión → tópico → emoción, con paz promedio en la arista', () {
      final g = PersonalityGraphBuilder.build(sample());
      expect(g.nodes.where((n) => n.kind == NodeKind.dimension), hasLength(4));
      expect(g.nodes.where((n) => n.kind == NodeKind.topic).map((n) => n.id), unorderedEquals(['pac', 'sob']));
      final ira = g.nodes.firstWhere((n) => n.id == 'emo:ira');
      expect(ira.pulses, isTrue, reason: 'intensidad 9');
      final edge = g.edges.firstWhere((e) => e.from == 'pac' && e.to == 'emo:ira');
      expect(edge.avgPeace, 2);
      expect(g.edges.where((e) => e.from == 'dim:${Dimension.vidaPractica}' && e.to == 'pac'), hasLength(1));
    });

    test('filtrar dimensiones oculta sus tópicos', () {
      final g = PersonalityGraphBuilder.build(sample(), dimensions: {Dimension.caracterDios});
      expect(g.nodes.where((n) => n.kind == NodeKind.topic).map((n) => n.id), ['sob']);
      expect(g.nodes.where((n) => n.kind == NodeKind.emotion), isEmpty);
    });

    test('layout determinista, dentro de los límites y con dimensiones fijas', () {
      final g = PersonalityGraphBuilder.build(sample());
      final a = ForceLayout.compute(g, width: 800, height: 600, iterations: 120);
      final b = ForceLayout.compute(g, width: 800, height: 600, iterations: 120);
      expect(a, b);
      for (final p in a.values) {
        expect(p.x, inInclusiveRange(0, 800));
        expect(p.y, inInclusiveRange(0, 600));
      }
      expect(a['dim:${Dimension.caracterDios}'], (x: 400.0, y: 72.0));
      // Nodos distintos no se superponen.
      final pts = a.values.toList();
      for (var i = 0; i < pts.length; i++) {
        for (var j = i + 1; j < pts.length; j++) {
          expect((pts[i].x - pts[j].x).abs() + (pts[i].y - pts[j].y).abs(), greaterThan(5));
        }
      }
    });
  });

  group('aluvión', () {
    test('emoción primaria → filtro → banda de paz, conservando el flujo', () {
      final d = SankeyBuilder.build(sample(), height: 300);
      expect(d.total, 2, reason: 'dos registros');
      final ids = d.nodes.map((n) => n.id).toSet();
      expect(
        ids,
        containsAll(['e:ira', 'e:alegria', 'f:impulso', 'f:biblico', 'p:Paz baja (1-4)', 'p:Paz alta (8-10)']),
      );
      expect(ids.contains('e:frustracion'), isFalse, reason: 'se agrupa en su primaria (Ira)');
      for (final n in d.nodes.where((n) => n.stage == 1)) {
        final inV = d.links.where((l) => l.to == n.id).fold<double>(0, (a, l) => a + l.value);
        final outV = d.links.where((l) => l.from == n.id).fold<double>(0, (a, l) => a + l.value);
        expect(inV, closeTo(outV, 1e-9));
      }
    });

    test('los nodos de una etapa no se solapan y caben en la altura', () {
      final d = SankeyBuilder.build(sample(), height: 300);
      for (var s = 0; s < 3; s++) {
        final col = d.nodes.where((n) => n.stage == s).toList()..sort((a, b) => a.y0.compareTo(b.y0));
        for (var i = 1; i < col.length; i++) {
          expect(col[i].y0, greaterThanOrEqualTo(col[i - 1].y1));
        }
        expect(col.last.y1, lessThanOrEqualTo(300.0001));
      }
    });

    test('sin praxis no hay diagrama', () {
      expect(SankeyBuilder.build(AnalyticsData.empty).isEmpty, isTrue);
    });
  });
}
