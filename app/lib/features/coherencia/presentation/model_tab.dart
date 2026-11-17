import 'dart:math';
import 'dart:ui' as ui;

import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/config/env.dart';
import '../../../infrastructure/ml/system_one_loader.dart';
import '../../../shared/widgets/common_widgets.dart';
import '../domain/coherence_charts.dart';
import '../domain/labeling.dart';
import '../domain/thought_prototypes.dart';
import 'coherence_providers.dart';

/// System One local (§11.1): instalación opcional, transparencia (gráfico 8) y catálogo de patrones.
class ModelTab extends ConsumerStatefulWidget {
  const ModelTab({super.key});

  @override
  ConsumerState<ModelTab> createState() => _ModelTabState();
}

class _ModelTabState extends ConsumerState<ModelTab> {
  double? _progress;

  Future<void> _install(Future<(String, String)> Function() action) async {
    setState(() => _progress = 0);
    try {
      final (kind, version) = await action();
      final big = kind == 'nli-judge';
      ref.invalidate(big ? nliJudgeProvider : systemOneProvider);
      if (mounted) showMessage(context, '${big ? 'Juez grande' : 'System One'} $version instalado.');
    } catch (e) {
      if (mounted) showError(context, e);
    } finally {
      if (mounted) setState(() => _progress = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final model = ref.watch(systemOneProvider);
    final feedback = ref.watch(judgeFeedbackProvider).value ?? const <JudgeFeedbackEntry>[];
    final muted = theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant);
    final m = model.value;
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 900),
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 96),
          children: [
            SectionCard(
              title: 'Juez local (System One)',
              subtitle: m == null
                  ? 'Sin modelo: todo se etiqueta a mano (O4). El modelo es opcional y corre solo en tu teléfono.'
                  : 'Versión ${m.version}. Corre en tu teléfono: el texto no sale de aquí.',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (model.isLoading) const LinearProgressIndicator(),
                  if (model.hasError) Text('No se pudo abrir el modelo: ${model.error}', style: muted),
                  if (_progress != null) LinearProgressIndicator(value: _progress == 0 ? null : _progress),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      OutlinedButton.icon(
                        key: const Key('import-model'),
                        icon: const Icon(Icons.folder_zip_outlined),
                        label: const Text('Importar paquete (.zip)'),
                        onPressed: _progress != null
                            ? null
                            : () async {
                                final file = await openFile(
                                  acceptedTypeGroups: const [
                                    XTypeGroup(label: 'Modelo', extensions: ['zip']),
                                  ],
                                );
                                if (file != null) await _install(() => installModelZip(file.path));
                              },
                      ),
                      if (Env.modelBundleUrl.isNotEmpty)
                        FilledButton.tonalIcon(
                          icon: const Icon(Icons.download),
                          label: const Text('Descargar (~150 MB)'),
                          onPressed: _progress != null
                              ? null
                              : () => _install(
                                  () async => (
                                    'system-one',
                                    await downloadSystemOne(
                                      Uri.parse(Env.modelBundleUrl),
                                      onProgress: (p) => setState(() => _progress = p),
                                    ),
                                  ),
                                ),
                        ),
                      if (m != null)
                        TextButton.icon(
                          icon: const Icon(Icons.delete_outline),
                          label: const Text('Quitar modelo'),
                          onPressed: () async {
                            await uninstallSystemOne();
                            ref.invalidate(systemOneProvider);
                          },
                        ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Lo fácil se sugiere solo con confianza calibrada ≥ ${m == null ? 'umbral' : '${(m.routeThreshold * 100).round()} %'}; '
                    'lo incierto lo decides tú. Toda sugerencia se confirma antes de contar.',
                    style: muted,
                  ),
                ],
              ),
            ),
            _DeepJudgeCard(
              busy: _progress != null,
              onDownload: () => _install(
                () async => (
                  'nli-judge',
                  await downloadNliJudge(Uri.parse(Env.nliBundleUrl), onProgress: (p) => setState(() => _progress = p)),
                ),
              ),
            ),
            SectionCard(
              key: const Key('chart-transparency'),
              title: '8 · Transparencia del modelo',
              subtitle: '¿Cuánto puedes confiar en las sugerencias automáticas?',
              child: _Transparency(card: m?.card ?? const {}, feedback: feedback),
            ),
            SectionCard(
              title: 'Patrones de pensamiento',
              subtitle: 'Catálogo de cadenas de razonamiento con su patrón antagónico (§11.2).',
              child: _Prototypes(catalog: ref.watch(prototypeCatalogProvider).value),
            ),
          ],
        ),
      ),
    );
  }
}

/// Juez grande opcional (§12.5): segundo nivel de la cascada para lo que el System One no resuelve.
class _DeepJudgeCard extends ConsumerWidget {
  const _DeepJudgeCard({required this.busy, required this.onDownload});

  final bool busy;
  final VoidCallback onDownload;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final muted = theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant);
    final judge = ref.watch(nliJudgeProvider);
    final j = judge.value;
    final mp = j?.card['minimal_pairs'] as Map<String, dynamic>?;
    String pct(Object? v) => v == null ? '—' : '${((v as num) * 100).round()} %';
    return SectionCard(
      key: const Key('deep-judge'),
      title: 'Juez grande (opcional)',
      subtitle: j == null
          ? 'Revisa lo que el System One no tiene claro. Más preciso, pero ocupa ~140 MB y ~260 MB de memoria al usarse.'
          : 'Versión ${j.version}. También corre solo en tu teléfono.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (judge.isLoading) const LinearProgressIndicator(),
          if (judge.hasError) Text('No se pudo abrir el juez grande: ${judge.error}', style: muted),
          if (mp != null)
            Text(
              'Pares mínimos: junta paráfrasis ${pct(mp['paraphrase_join'])}, separa opuestos ${pct(mp['opposite_separation'])} · '
              '${mp['passes'] == true ? 'CUMPLE' : 'NO CUMPLE'} el criterio de 90 %',
              key: const Key('deep-judge-card'),
            ),
          if (j != null)
            Text(
              'Decide solo con confianza ≥ ${(j.routeThreshold * 100).round()} %; lo demás sigue siendo tuyo.',
              style: muted,
            ),
          const SizedBox(height: 6),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              if (j == null) Text('Se instala con «Importar paquete (.zip)» de arriba.', style: muted),
              if (j == null && Env.nliBundleUrl.isNotEmpty)
                FilledButton.tonalIcon(
                  icon: const Icon(Icons.download),
                  label: const Text('Descargar (~140 MB)'),
                  onPressed: busy ? null : onDownload,
                ),
              if (j != null)
                TextButton.icon(
                  icon: const Icon(Icons.delete_outline),
                  label: const Text('Quitar juez grande'),
                  onPressed: () async {
                    await uninstallNliJudge();
                    ref.invalidate(nliJudgeProvider);
                  },
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Transparency extends StatelessWidget {
  const _Transparency({required this.card, required this.feedback});

  final Map<String, dynamic> card;
  final List<JudgeFeedbackEntry> feedback;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final muted = theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant);
    final mp = card['minimal_pairs'] as Map<String, dynamic>?;
    final lab = card['calibration'] as Map<String, dynamic>?;
    final report = CalibrationReport.of(feedback);
    String pct(Object? v) => v == null ? '—' : '${((v as num) * 100).round()} %';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('En el laboratorio', style: theme.textTheme.titleSmall),
        if (mp == null)
          Text('Instala el modelo para ver su tarjeta de evaluación.', style: muted)
        else ...[
          Text(
            'Test de pares mínimos (300 pares fijos, nunca usados para entrenar): junta paráfrasis ${pct(mp['paraphrase_join'])}, '
            'separa opuestos ${pct(mp['opposite_separation'])} · criterio 90 % · '
            '${mp['passes'] == true ? 'CUMPLE' : 'NO CUMPLE'}',
            key: const Key('minimal-pairs-card'),
          ),
          if (card['baseline'] case final Map<String, dynamic> b)
            Text(
              'Línea base sin ajustar: ${pct(b['paraphrase_join'])} / ${pct(b['opposite_separation'])}',
              style: muted,
            ),
          if (lab != null)
            Text(
              'Calibración (validación separada): ECE ${(lab['ece'] as num).toStringAsFixed(3)}, Brier ${(lab['brier'] as num).toStringAsFixed(3)}',
              style: muted,
            ),
        ],
        const Divider(height: 24),
        Text('Contra tus confirmaciones', style: theme.textTheme.titleSmall),
        if (report.n < ChartMinimums.calibration)
          Text(
            'Aún no hay suficientes datos (n = ${report.n} de ${ChartMinimums.calibration} confirmaciones). '
            'Cada vez que revisas una sugerencia del juez se suma aquí.',
            style: muted,
          )
        else ...[
          Text(
            'Acierto ${(report.accuracy * 100).round()} % · ECE ${report.ece.toStringAsFixed(3)} · Brier ${report.brier.toStringAsFixed(3)} · n = ${report.n}',
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 200,
            width: double.infinity,
            child: CustomPaint(
              painter: _ReliabilityPainter(
                report,
                theme.colorScheme.primary,
                theme.colorScheme.outlineVariant,
                theme.textTheme.labelSmall!.copyWith(color: theme.colorScheme.onSurfaceVariant),
              ),
            ),
          ),
          const SizedBox(height: 8),
          _ConfusionTable(report: report),
        ],
      ],
    );
  }
}

class _ReliabilityPainter extends CustomPainter {
  _ReliabilityPainter(this.report, this.color, this.grid, this.label);

  final CalibrationReport report;
  final Color color;
  final Color grid;
  final TextStyle label;

  @override
  void paint(Canvas canvas, Size size) {
    const pad = 26.0;
    final side = min(size.width, size.height) - pad;
    Offset at(double conf, double acc) => Offset(pad + conf * side, side - acc * side);
    final g = Paint()
      ..color = grid
      ..strokeWidth = 1;
    canvas.drawRect(Rect.fromPoints(at(0, 0), at(1, 1)), g..style = PaintingStyle.stroke);
    canvas.drawLine(at(0, 0), at(1, 1), g); // calibración perfecta
    for (final b in report.bins) {
      final w = side / 10;
      canvas.drawRect(
        Rect.fromLTWH(pad + b.lo * side + 1, side - b.accuracy * side, w - 2, b.accuracy * side),
        Paint()..color = color.withValues(alpha: 0.55),
      );
      canvas.drawCircle(at(b.meanConfidence, b.accuracy), 3, Paint()..color = color);
    }
    void text(String s, Offset o) => (TextPainter(
      text: TextSpan(text: s, style: label),
      textDirection: ui.TextDirection.ltr,
    )..layout()).paint(canvas, o);
    text('confianza →', Offset(pad + side - 60, side + 4));
    text('acierto', const Offset(0, 0));
  }

  @override
  bool shouldRepaint(covariant _ReliabilityPainter old) => old.report != report;
}

class _ConfusionTable extends StatelessWidget {
  const _ConfusionTable({required this.report});

  final CalibrationReport report;

  static const _names = {'entailment': 'Confirma', 'neutral': 'Neutral', 'contradiction': 'Contradice'};

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context).textTheme.labelSmall;
    return Table(
      border: TableBorder.all(color: Theme.of(context).colorScheme.outlineVariant),
      children: [
        TableRow(
          children: [
            Padding(
              padding: const EdgeInsets.all(4),
              child: Text('Tú \\ juez', style: style),
            ),
            for (final l in report.labels)
              Padding(
                padding: const EdgeInsets.all(4),
                child: Text(_names[l] ?? l, style: style),
              ),
          ],
        ),
        for (final (i, l) in report.labels.indexed)
          TableRow(
            children: [
              Padding(
                padding: const EdgeInsets.all(4),
                child: Text(_names[l] ?? l, style: style),
              ),
              for (final v in report.confusion[i]) Padding(padding: const EdgeInsets.all(4), child: Text('$v')),
            ],
          ),
      ],
    );
  }
}

class _Prototypes extends StatelessWidget {
  const _Prototypes({required this.catalog});

  final PrototypeCatalog? catalog;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final c = catalog;
    if (c == null || c.prototypes.isEmpty) {
      return Text(
        'El catálogo llega con el modelo. Se construye en el laboratorio con datos sintéticos e ítems compartidos.',
        style: theme.textTheme.bodySmall,
      );
    }
    final seen = <String>{};
    final rows = <Widget>[];
    for (final p in c.prototypes) {
      if (seen.contains(p.id)) continue;
      seen.add(p.id);
      final anti = c.antagonistOf(p);
      if (anti != null) seen.add(anti.id);
      rows.add(
        Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: _ProtoCell(p: p)),
                if (anti != null) ...[
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Icon(Icons.swap_horiz, color: theme.colorScheme.error),
                  ),
                  Expanded(child: _ProtoCell(p: anti)),
                ],
              ],
            ),
          ),
        ),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('Catálogo ${c.version} · ${c.prototypes.length} patrones', style: theme.textTheme.labelMedium),
        const SizedBox(height: 8),
        ...rows,
      ],
    );
  }
}

class _ProtoCell extends StatelessWidget {
  const _ProtoCell({required this.p});

  final ThoughtPrototype p;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(p.displayName, style: theme.textTheme.titleSmall),
        if (p.definition.isNotEmpty) Text(p.definition, style: theme.textTheme.bodySmall),
        if (p.examples.isNotEmpty)
          Text('«${p.examples.first}»', style: theme.textTheme.bodySmall?.copyWith(fontStyle: FontStyle.italic)),
        if (p.stability != null)
          Text('estabilidad ${p.stability!.toStringAsFixed(2)}', style: theme.textTheme.labelSmall),
      ],
    );
  }
}
