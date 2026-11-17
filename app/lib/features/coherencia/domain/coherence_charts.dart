import 'dart:math';

import '../../ejes/domain/analytics_service.dart';
import '../../ejes/domain/sankey.dart';
import 'belief.dart';
import 'coherence_data.dart';
import 'coherence_statistics.dart';

/// Mínimos de datos por gráfico (docs/PLAN-COHERENCIA.md §5). Debajo, "aún no hay suficientes datos".
abstract final class ChartMinimums {
  static const beliefMap = 1;
  static const alignmentPeace = 10;
  static const weeklyWeeks = 6;
  static const lagWeeks = 12;
  static const alluvium = 20;
  static const calibration = 50;
}

/// Tercil de coherencia canónica de la creencia (selector H3).
enum CoherenceTercile {
  todas('Todas'),
  baja('Baja'),
  media('Media'),
  alta('Alta');

  const CoherenceTercile(this.label);

  final String label;
}

// ─── Gráfico 3: mapa de creencias ───────────────────────────────────────────

class BeliefMapRow {
  const BeliefMapRow({required this.belief, required this.source, required this.counts, required this.peace});

  final Belief belief;

  /// Interpretación de origen: título del devocional, o "Nació de la vida".
  final String source;

  /// Alineación → nº de acciones confirmadas.
  final Map<ActionAlignment, int> counts;

  /// Alineación → paz media con IC (solo praxis).
  final Map<ActionAlignment, Estimate?> peace;

  int get total => counts.values.fold(0, (a, b) => a + b);
}

// ─── Gráfico 4: alineación vs paz ───────────────────────────────────────────

class AlignmentPeacePoint {
  const AlignmentPeacePoint(this.alignment, this.peace, this.beliefId, this.date);

  final double alignment;
  final int peace;
  final String beliefId;
  final DateTime date;
}

class AlignmentPeace {
  const AlignmentPeace({required this.points, required this.correlation, required this.meanByAlignment});

  final List<AlignmentPeacePoint> points;
  final Correlation? correlation;
  final Map<ActionAlignment, Estimate?> meanByAlignment;
}

// ─── Gráfico 5: serie semanal ───────────────────────────────────────────────

class WeeklyCoherencePoint {
  const WeeklyCoherencePoint(this.weekStart, this.alignment, this.peace, this.n);

  final DateTime weekStart;
  final Estimate? alignment;
  final Estimate? peace;
  final int n;
}

abstract final class CoherenceCharts {
  static BeliefMapRow _row(CoherenceDataset d, Belief b) {
    final counts = {for (final a in ActionAlignment.values) a: 0};
    final peaces = {for (final a in ActionAlignment.values) a: <int>[]};
    for (final l in d.confirmedLinks) {
      if (l.beliefId != b.id) continue;
      counts[l.alignment] = counts[l.alignment]! + 1;
      final p = d.actionOf(l)?.peace;
      if (p != null) peaces[l.alignment]!.add(p);
    }
    return BeliefMapRow(
      belief: b,
      source: b.devotionalId == null ? b.origin.label : (d.devotionalTitles[b.devotionalId] ?? 'Devocional sin título'),
      counts: counts,
      peace: {for (final a in ActionAlignment.values) a: Estimate.mean(peaces[a]!)},
    );
  }

  /// Gráfico 3: solo creencias confirmadas (§10.4), de la que más gobierna acciones a la que menos.
  static List<BeliefMapRow> beliefMap(CoherenceDataset d) => [
    for (final b in d.beliefs)
      if (b.isConfirmed && b.status != BeliefStatus.refutada) _row(d, b),
  ]..sort((a, b) => b.total.compareTo(a.total));

  /// Creencias del tercil pedido según su coherencia canónica (orden interno, nunca mostrado).
  static Set<String> beliefsInTercile(CoherenceDataset d, CoherenceTercile t) {
    final ids = [
      for (final b in d.beliefs)
        if (b.isConfirmed) b.id,
    ];
    if (t == CoherenceTercile.todas) return ids.toSet();
    ids.sort((a, b) => d.coherence[a]!.rankKey.compareTo(d.coherence[b]!.rankKey));
    final n = ids.length;
    final (from, to) = switch (t) {
      CoherenceTercile.baja => (0, (n / 3).ceil()),
      CoherenceTercile.media => ((n / 3).ceil(), (2 * n / 3).ceil()),
      _ => ((2 * n / 3).ceil(), n),
    };
    return ids.sublist(min(from, n), min(to, n)).toSet();
  }

  /// Gráfico 4.
  static AlignmentPeace alignmentPeace(CoherenceDataset d, {CoherenceTercile tercile = CoherenceTercile.todas}) {
    final allowed = beliefsInTercile(d, tercile);
    final points = [
      for (final x in d.confirmedPraxis)
        if (allowed.contains(x.link.beliefId))
          AlignmentPeacePoint(x.link.alignment.value.toDouble(), x.action.peace!, x.link.beliefId, x.action.date),
    ];
    return AlignmentPeace(
      points: points,
      correlation: CoherenceStatistics.spearman(
        [for (final p in points) p.alignment],
        [for (final p in points) p.peace.toDouble()],
        minN: ChartMinimums.alignmentPeace,
      ),
      meanByAlignment: {
        for (final a in ActionAlignment.values)
          a: Estimate.mean([
            for (final p in points)
              if (p.alignment == a.value) p.peace,
          ]),
      },
    );
  }

  /// Gráfico 5: A_w (alineación media) y paz media por semana, con IC. Semanas sin datos quedan en null
  /// para que la serie temporal (y el rezago del gráfico 6) respete el calendario.
  static List<WeeklyCoherencePoint> weekly(CoherenceDataset d) {
    final byWeek = <DateTime, List<({double a, int p})>>{};
    for (final x in d.confirmedPraxis) {
      byWeek.putIfAbsent(AnalyticsService.weekStart(x.action.date), () => []).add((
        a: x.link.alignment.value.toDouble(),
        p: x.action.peace!,
      ));
    }
    if (byWeek.isEmpty) return const [];
    final weeks = byWeek.keys.toList()..sort();
    final result = <WeeklyCoherencePoint>[];
    for (var w = weeks.first; !w.isAfter(weeks.last); w = AnalyticsService.weekStart(w.add(const Duration(days: 8)))) {
      final xs = byWeek[w] ?? const [];
      result.add(
        WeeklyCoherencePoint(
          w,
          Estimate.mean([for (final x in xs) x.a]),
          Estimate.mean([for (final x in xs) x.p]),
          xs.length,
        ),
      );
    }
    return result;
  }

  /// Semanas con datos (para comparar con los mínimos).
  static int weeksWithData(List<WeeklyCoherencePoint> w) => w.where((p) => p.n > 0).length;

  /// Gráfico 6: correlación de la alineación semanal con la paz semanal, rezagos −2…+2.
  /// Rezago +k: la alineación de una semana frente a la paz k semanas después.
  static Map<int, Correlation?> lagged(List<WeeklyCoherencePoint> w) => CoherenceStatistics.laggedCorrelation(
    [for (final p in w) p.alignment?.value],
    [for (final p in w) p.peace?.value],
    minN: 6,
  );

  /// N-of-1 por creencia con corrección de Benjamini-Hochberg: (creencia, correlación, q).
  static List<({Belief belief, Correlation correlation, double q})> perBelief(CoherenceDataset d) {
    final rows = <({Belief belief, Correlation correlation})>[];
    for (final b in d.beliefs) {
      final xs = [
        for (final x in d.confirmedPraxis)
          if (x.link.beliefId == b.id) x,
      ];
      final c = CoherenceStatistics.spearman(
        [for (final x in xs) x.link.alignment.value.toDouble()],
        [for (final x in xs) x.action.peace!.toDouble()],
      );
      if (c != null) rows.add((belief: b, correlation: c));
    }
    final q = CoherenceStatistics.benjaminiHochberg([for (final r in rows) r.correlation.p]);
    return [for (var i = 0; i < rows.length; i++) (belief: rows[i].belief, correlation: rows[i].correlation, q: q[i])]
      ..sort((a, b) => a.q.compareTo(b.q));
  }

  /// Gráfico 7: Creencia → acción (alineada / neutral / contraria) → banda de paz.
  static const alluviumStages = ['Creencia', 'Acción', 'Paz'];

  static SankeyDiagram alluvium(CoherenceDataset d, {double height = 420, int maxBeliefs = 6}) {
    final top = beliefMap(d).take(maxBeliefs).map((r) => r.belief.id).toSet();
    final nodes = <String, SankeyNode>{};
    final flows = <(String, String), double>{};
    SankeyNode node(String id, String label, int stage) => nodes.putIfAbsent(id, () => SankeyNode(id, label, stage));
    for (final x in d.confirmedPraxis) {
      final b = d.beliefById[x.link.beliefId];
      if (b == null) continue;
      final belief = top.contains(b.id) ? node('b:${b.id}', b.proposition, 0) : node('b:otras', 'Otras creencias', 0);
      final action = node('f:${x.link.alignment.name}', x.link.alignment.shortLabel, 1);
      final band = SankeyBuilder.peaceBand(x.action.peace!);
      final peace = node('p:$band', band, 2);
      flows.update((belief.id, action.id), (v) => v + 1, ifAbsent: () => 1);
      flows.update((action.id, peace.id), (v) => v + 1, ifAbsent: () => 1);
    }
    final diagram = SankeyBuilder.layout(nodes.values.toList(), [
      for (final MapEntry(key: (a, b), value: v) in flows.entries) SankeyLink(a, b, v),
    ], height: height);
    return SankeyDiagram(stages: alluviumStages, nodes: diagram.nodes, links: diagram.links, total: diagram.total);
  }
}
