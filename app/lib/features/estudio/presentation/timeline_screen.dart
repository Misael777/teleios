import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/formatters.dart';
import '../../../shared/domain/catalogs/historical_catalog.dart';
import '../../../shared/domain/entities/dimension.dart';
import '../../../shared/domain/entities/passage_ref.dart';
import '../../../shared/widgets/common_widgets.dart';
import '../domain/devotional.dart';
import '../domain/passage_network.dart';
import '../domain/timeline_layout.dart';
import 'estudio_providers.dart';
import 'widgets/scripture_text.dart';
import 'widgets/section_style.dart';

enum _ScaleMode { byPeriod, linear }

/// Lo seleccionado en el lienzo: un devocional (sus hilos salientes) o un pasaje vinculado
/// (los hilos que llegan a él).
sealed class _Selection {
  const _Selection();
}

class _DevotionalSelection extends _Selection {
  const _DevotionalSelection(this.id);
  final String id;

  @override
  bool operator ==(Object other) => other is _DevotionalSelection && other.id == id;

  @override
  int get hashCode => id.hashCode;
}

class _PassageSelection extends _Selection {
  const _PassageSelection(this.key);
  final String key;

  @override
  bool operator ==(Object other) => other is _PassageSelection && other.key == key;

  @override
  int get hashCode => key.hashCode;
}

class TimelineScreen extends ConsumerStatefulWidget {
  const TimelineScreen({super.key});

  @override
  ConsumerState<TimelineScreen> createState() => _TimelineScreenState();
}

class _TimelineScreenState extends ConsumerState<TimelineScreen> {
  _ScaleMode _mode = _ScaleMode.byPeriod;
  double _zoom = 1;

  /// Secciones cuyos hilos el usuario ocultó (null: notas).
  final Set<String?> _hidden = {};
  _Selection? _selection;

  final _hScroll = ScrollController();
  final _canvasKey = GlobalKey();
  bool _centeredOnRecent = false;

  @override
  void dispose() {
    _hScroll.dispose();
    super.dispose();
  }

  /// Desplaza el lienzo para que [x] quede al centro (y, si [reveal], lo trae a la vista).
  void _centerOn(double x, {bool animate = true, bool reveal = false}) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_hScroll.hasClients) return;
      final position = _hScroll.position;
      final target = (x - position.viewportDimension / 2).clamp(0.0, position.maxScrollExtent);
      if (animate) {
        _hScroll.animateTo(target, duration: const Duration(milliseconds: 450), curve: Curves.easeInOutCubic);
      } else {
        _hScroll.jumpTo(target);
      }
      final canvas = _canvasKey.currentContext;
      if (reveal && canvas != null) {
        Scrollable.ensureVisible(canvas, duration: const Duration(milliseconds: 450), curve: Curves.easeInOutCubic);
      }
    });
  }

  TimelineScale get _scale => switch (_mode) {
    _ScaleMode.byPeriod => PeriodTimelineScale(periodWidth: 150 * _zoom),
    _ScaleMode.linear => LinearTimelineScale(
      minYear: TimelineLayout.defaultMinYear,
      maxYear: TimelineLayout.defaultMaxYear,
      pxPerYear: 0.8 * _zoom,
    ),
  };

  void _select(_Selection? s) => setState(() => _selection = s == _selection ? null : s);

  @override
  Widget build(BuildContext context) {
    final devotionals = ref.watch(allDevotionalsProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Línea de tiempo'),
        actions: [
          IconButton(
            tooltip: 'Alejar',
            icon: const Icon(Icons.zoom_out),
            onPressed: _zoom > 0.5 ? () => setState(() => _zoom /= 1.5) : null,
          ),
          IconButton(
            tooltip: 'Acercar',
            icon: const Icon(Icons.zoom_in),
            onPressed: _zoom < 6 ? () => setState(() => _zoom *= 1.5) : null,
          ),
        ],
      ),
      body: devotionals.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (entries) {
          final scale = _scale;
          final datable = TimelineLayout.datable(entries);
          final dots = TimelineLayout.placeInLanes(datable, scale, minGapPx: 18);
          final milestones = TimelineLayout.placeInLanes(
            [for (final m in HistoricalCatalog.milestones) (m, m.year)],
            scale,
            minGapPx: 110,
            maxLanes: 4,
          );
          final density = TimelineLayout.densityByPeriod(entries);
          final undated = entries.length - datable.length;
          final dotColors = {for (final d in dots) d.item.id: _colorFor(context, d.item)};

          // Red de pasajes: solo los hilos que salen de un devocional visible en la línea.
          final placedIds = {for (final d in dots) d.item.id};
          final network = PassageNetwork.build(entries.where((e) => placedIds.contains(e.id)));
          final nodes = TimelineLayout.placeInLanes(
            [for (final p in network.passages) (p, PassageNetwork.yearOf(p.ref))],
            scale,
            minGapPx: 58,
            maxLanes: _TimelinePainter.railLanes,
          );
          final sectionColors = {for (final id in SectionStyle.ids) id: SectionStyle.color(context, id)};

          // Al abrir, el lienzo arranca en el devocional más reciente y no en la Creación.
          if (!_centeredOnRecent && dots.isNotEmpty) {
            _centeredOnRecent = true;
            final recent = dots.reduce((a, b) => b.item.date.isAfter(a.item.date) ? b : a);
            _centerOn(recent.x, animate: false);
          }

          // Una selección que ya no existe (se borró o se filtró) se descarta.
          final selection = switch (_selection) {
            _DevotionalSelection(:final id) when placedIds.contains(id) => _selection,
            _PassageSelection(:final key) when network.passage(key) != null => _selection,
            _ => null,
          };

          return ListView(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                child: SegmentedButton<_ScaleMode>(
                  segments: const [
                    ButtonSegment(value: _ScaleMode.byPeriod, label: Text('Por épocas')),
                    ButtonSegment(value: _ScaleMode.linear, label: Text('Escala real')),
                  ],
                  selected: {_mode},
                  onSelectionChanged: (s) => setState(() => _mode = s.first),
                ),
              ),
              if (!network.isEmpty) _sectionFilters(context, network),
              SingleChildScrollView(
                key: _canvasKey,
                controller: _hScroll,
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: GestureDetector(
                  key: const Key('timeline-canvas'),
                  onTapUp: (details) => _select(_hitTest(dots, nodes, details.localPosition) ?? _selection),
                  child: CustomPaint(
                    size: Size(scale.width, network.isEmpty ? _TimelinePainter.compactHeight : _TimelinePainter.height),
                    painter: _TimelinePainter(
                      scale: scale,
                      dots: dots,
                      dotColors: dotColors,
                      milestones: milestones,
                      density: density,
                      nodes: network.isEmpty ? const [] : nodes,
                      links: [
                        for (final l in network.links)
                          if (!_hidden.contains(l.sectionId)) l,
                      ],
                      sectionColors: sectionColors,
                      selection: selection,
                      theme: Theme.of(context),
                    ),
                  ),
                ),
              ),
              if (selection != null)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                  child: switch (selection) {
                    _DevotionalSelection(:final id) => _DevotionalLinksCard(
                      entry: entries.firstWhere((e) => e.id == id),
                      links: network.linksFrom(id),
                      onClose: () => _select(null),
                    ),
                    _PassageSelection(:final key) => _PassageLinksCard(
                      passage: network.passage(key)!,
                      studiedIn: PassageNetwork.studying(entries, network.passage(key)!.ref),
                      onClose: () => _select(null),
                    ),
                  },
                ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  network.isEmpty
                      ? 'Arriba: hitos bíblicos · Abajo: tus devocionales (toca un punto para ver su detalle). '
                            'Fechas aproximadas según cronología conservadora.'
                      : 'Arriba: hitos bíblicos · Centro: tus devocionales · Abajo: los versículos que vinculaste '
                            'con { }, ubicados en su época. Cada hilo lleva el color de la sección donde lo citaste. '
                            'Toca un devocional o un versículo para resaltar sus conexiones.',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
              if (undated > 0)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                  child: Text(
                    '$undated devocional(es) sin contexto cronológico no aparecen en la línea.',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                child: SectionCard(
                  title: 'Red de pasajes',
                  subtitle: network.isEmpty
                      ? 'Escribe { en tu reflexión para vincular versículos; aquí verás cómo se conectan.'
                      : '${network.links.length} vínculo(s) hacia ${network.passages.length} pasaje(s). '
                            'Los más citados son los que sostienen tu estudio.',
                  child: network.isEmpty
                      ? const SizedBox.shrink()
                      : _NetworkSummary(
                          network: network,
                          onSelect: (p) {
                            _select(_PassageSelection(p.key));
                            final node = nodes.where((n) => n.item.key == p.key).firstOrNull;
                            if (node != null) _centerOn(node.x, reveal: true);
                          },
                        ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: SectionCard(
                  title: 'Densidad por época',
                  subtitle: 'Qué partes de la historia de la redención estás estudiando y cuáles no.',
                  child: _DensityList(density: density),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  /// Leyenda y filtro a la vez: un chip por sección con su color y cuántos hilos tiene.
  Widget _sectionFilters(BuildContext context, PassageNetwork network) {
    final counts = network.countBySection;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Vínculos por sección', style: Theme.of(context).textTheme.labelLarge),
          const SizedBox(height: 6),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              for (final id in SectionStyle.ids)
                if ((counts[id] ?? 0) > 0)
                  FilterChip(
                    key: Key('section-filter-${id ?? 'notas'}'),
                    avatar: Icon(SectionStyle.icon(id), size: 16, color: SectionStyle.color(context, id)),
                    label: Text('${SectionStyle.name(id)} · ${counts[id]}'),
                    selected: !_hidden.contains(id),
                    showCheckmark: false,
                    side: BorderSide(color: SectionStyle.color(context, id).withValues(alpha: 0.7)),
                    selectedColor: SectionStyle.color(context, id).withValues(alpha: 0.16),
                    onSelected: (on) => setState(() => on ? _hidden.remove(id) : _hidden.add(id)),
                  ),
            ],
          ),
        ],
      ),
    );
  }

  Color _colorFor(BuildContext context, DevotionalEntry entry) {
    if (entry.topics.isEmpty) return Theme.of(context).colorScheme.primary;
    // Color de la dimensión con más tópicos en ese devocional.
    final counts = <String, int>{};
    for (final t in entry.topics) {
      counts[t.dimensionId] = (counts[t.dimensionId] ?? 0) + 1;
    }
    final top = counts.entries.reduce((a, b) => a.value >= b.value ? a : b).key;
    return context.dimensionColor(top);
  }

  _Selection? _hitTest(List<PlacedItem<DevotionalEntry>> dots, List<PlacedItem<LinkedPassage>> nodes, Offset p) {
    for (final d in dots) {
      if ((Offset(d.x, _TimelinePainter.dotY(d.lane)) - p).distance <= 14) return _DevotionalSelection(d.item.id);
    }
    for (final n in nodes) {
      if ((Offset(n.x, _TimelinePainter.nodeY(n.lane)) - p).distance <= 14) return _PassageSelection(n.item.key);
    }
    return null;
  }
}

/// "Jn 15:5": etiqueta corta para el riel.
String _shortLabel(PassageRef ref) => '${ref.book.shortName} ${ref.label.substring(ref.book.name.length + 1)}';

class _TimelinePainter extends CustomPainter {
  _TimelinePainter({
    required this.scale,
    required this.dots,
    required this.dotColors,
    required this.milestones,
    required this.density,
    required this.nodes,
    required this.links,
    required this.sectionColors,
    required this.selection,
    required this.theme,
  });

  final TimelineScale scale;
  final List<PlacedItem<DevotionalEntry>> dots;
  final Map<String, Color> dotColors;
  final List<PlacedItem<Milestone>> milestones;
  final Map<String, int> density;
  final List<PlacedItem<LinkedPassage>> nodes;
  final List<PassageLink> links;
  final Map<String?, Color> sectionColors;
  final _Selection? selection;
  final ThemeData theme;

  static const compactHeight = 380.0;
  static const height = 560.0;
  static const axisY = 190.0;
  static const railY = 418.0;
  static const railLanes = 4;

  static double dotY(int lane) => axisY + 30 + lane * 22;

  static double milestoneY(int lane) => axisY - 40 - lane * 30;

  static double nodeY(int lane) => railY + 22 + lane * 28;

  bool _linkActive(PassageLink l) => switch (selection) {
    null => true,
    _DevotionalSelection(:final id) => l.source.id == id,
    _PassageSelection(:final key) => l.target.encode() == key,
  };

  @override
  void paint(Canvas canvas, Size size) {
    final scheme = theme.colorScheme;

    // Bandas de épocas (alternadas) con nombre y conteo.
    for (final (i, period) in HistoricalCatalog.periods.indexed) {
      final left = scale.x(period.startYear);
      final right = scale.x(period.endYear);
      final band = Rect.fromLTRB(left, 0, right, size.height);
      canvas.drawRect(
        band,
        Paint()
          ..color = (i.isEven ? scheme.surfaceContainerHighest : scheme.surfaceContainerLow).withValues(alpha: 0.6),
      );
      final count = density[period.id] ?? 0;
      _text(
        canvas,
        '${period.name}${count > 0 ? ' · $count' : ''}',
        Offset(left + 6, 6),
        maxWidth: (right - left - 12).clamp(20, 400),
        style: theme.textTheme.labelSmall?.copyWith(
          color: count == 0 ? scheme.outline : scheme.onSurface,
          fontWeight: count > 0 ? FontWeight.bold : null,
        ),
      );
    }

    // Eje.
    final axis = Paint()
      ..color = scheme.outline
      ..strokeWidth = 2;
    canvas.drawLine(const Offset(0, axisY), Offset(size.width, axisY), axis);
    for (final period in HistoricalCatalog.periods) {
      final x = scale.x(period.startYear);
      canvas.drawLine(Offset(x, axisY - 6), Offset(x, axisY + 6), axis);
      _text(
        canvas,
        Formatters.year(period.startYear),
        Offset(x + 3, axisY + 8),
        style: theme.textTheme.labelSmall?.copyWith(color: scheme.outline, fontSize: 9),
      );
    }

    // Hitos bíblicos (arriba).
    final tick = Paint()
      ..color = scheme.tertiary
      ..strokeWidth = 1;
    for (final m in milestones) {
      final y = milestoneY(m.lane);
      canvas.drawLine(Offset(m.x, y + 14), Offset(m.x, axisY), tick);
      canvas.drawCircle(Offset(m.x, axisY), 3, Paint()..color = scheme.tertiary);
      _text(
        canvas,
        m.item.title,
        Offset(m.x - 50, y),
        maxWidth: 100,
        center: true,
        style: theme.textTheme.labelSmall?.copyWith(color: scheme.tertiary),
      );
    }

    if (nodes.isNotEmpty) _paintNetwork(canvas, size);

    // Devocionales (centro), encima de los hilos.
    final selectedId = switch (selection) {
      _DevotionalSelection(:final id) => id,
      _ => null,
    };
    final linkedIds = {
      for (final l in links)
        if (_linkActive(l)) l.source.id,
    };
    for (final d in dots) {
      final center = Offset(d.x, dotY(d.lane));
      final dimmed = selection != null && !linkedIds.contains(d.item.id) && d.item.id != selectedId;
      canvas.drawLine(Offset(d.x, axisY), center, Paint()..color = scheme.outlineVariant);
      canvas.drawCircle(center, 8, Paint()..color = dotColors[d.item.id]!.withValues(alpha: dimmed ? 0.3 : 1));
      canvas.drawCircle(
        center,
        8,
        Paint()
          ..style = PaintingStyle.stroke
          ..color = scheme.surface
          ..strokeWidth = 2,
      );
      if (d.item.id == selectedId) {
        canvas.drawCircle(
          center,
          12,
          Paint()
            ..style = PaintingStyle.stroke
            ..color = scheme.onSurface
            ..strokeWidth = 2,
        );
      }
    }
  }

  void _paintNetwork(Canvas canvas, Size size) {
    final scheme = theme.colorScheme;
    final dotByDevotional = {for (final d in dots) d.item.id: Offset(d.x, dotY(d.lane))};
    final nodeByKey = {for (final n in nodes) n.item.key: Offset(n.x, nodeY(n.lane))};

    // Riel de pasajes vinculados.
    final railPaint = Paint()
      ..color = scheme.outlineVariant
      ..strokeWidth = 1;
    for (var x = 0.0; x < size.width; x += 8) {
      canvas.drawLine(Offset(x, railY), Offset(x + 4, railY), railPaint);
    }
    _text(
      canvas,
      'VERSÍCULOS VINCULADOS',
      const Offset(8, railY - 16),
      maxWidth: 220,
      style: theme.textTheme.labelSmall?.copyWith(color: scheme.outline, letterSpacing: 1.5, fontSize: 9),
    );

    // Hilos: curvas en S del devocional al versículo. Varias secciones hacia el mismo versículo
    // se abren en abanico para que cada color se vea.
    final fan = <String, int>{};
    final ordered = [...links]..sort((a, b) => (_linkActive(a) ? 1 : 0).compareTo(_linkActive(b) ? 1 : 0));
    for (final l in ordered) {
      final from = dotByDevotional[l.source.id];
      final to = nodeByKey[l.target.encode()];
      if (from == null || to == null) continue;
      final pair = '${l.source.id}>${l.target.encode()}';
      final k = fan[pair] = (fan[pair] ?? -1) + 1;
      final spread = (k.isEven ? 1 : -1) * ((k + 1) ~/ 2) * 7.0;
      final dy = to.dy - from.dy;
      final path = Path()
        ..moveTo(from.dx, from.dy)
        ..cubicTo(from.dx + spread, from.dy + dy * 0.6, to.dx + spread, to.dy - dy * 0.6, to.dx, to.dy);
      final active = _linkActive(l);
      final emphasized = active && selection != null;
      canvas.drawPath(
        path,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round
          ..strokeWidth = emphasized ? 2.6 : 1.6
          ..color = sectionColors[l.sectionId]!.withValues(alpha: active ? (emphasized ? 0.95 : 0.6) : 0.07),
      );
    }

    // Nodos: rombos del color de la sección que más los citó; más grandes cuanto más citados.
    final selectedKey = switch (selection) {
      _PassageSelection(:final key) => key,
      _ => null,
    };
    final activeKeys = {
      for (final l in links)
        if (_linkActive(l)) l.target.encode(),
    };
    for (final n in nodes) {
      final c = nodeByKey[n.item.key]!;
      final visible = links.any((l) => l.target.encode() == n.item.key);
      final dimmed = !visible || (selection != null && !activeKeys.contains(n.item.key));
      final r = 5.0 + math.min(n.item.links.length - 1, 4) * 1.5;
      final diamond = Path()
        ..moveTo(c.dx, c.dy - r)
        ..lineTo(c.dx + r, c.dy)
        ..lineTo(c.dx, c.dy + r)
        ..lineTo(c.dx - r, c.dy)
        ..close();
      final color = sectionColors[n.item.dominantSectionId]!;
      canvas.drawPath(diamond, Paint()..color = color.withValues(alpha: dimmed ? 0.25 : 1));
      canvas.drawPath(
        diamond,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = n.item.key == selectedKey ? 2.5 : 1.2
          ..color = n.item.key == selectedKey ? scheme.onSurface : scheme.surface,
      );
      _text(
        canvas,
        _shortLabel(n.item.ref),
        Offset(c.dx - 30, c.dy + r + 2),
        maxWidth: 60,
        center: true,
        style: theme.textTheme.labelSmall?.copyWith(
          fontSize: 9,
          color: dimmed ? scheme.outline : scheme.onSurface,
          fontWeight: n.item.key == selectedKey ? FontWeight.bold : null,
        ),
      );
    }
  }

  void _text(Canvas canvas, String text, Offset at, {TextStyle? style, double maxWidth = 200, bool center = false}) {
    final painter = TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: TextDirection.ltr,
      textAlign: center ? TextAlign.center : TextAlign.left,
      maxLines: 2,
      ellipsis: '…',
    )..layout(maxWidth: maxWidth);
    final dx = center ? at.dx + (maxWidth - painter.width) / 2 : at.dx;
    painter.paint(canvas, Offset(dx, at.dy));
  }

  @override
  bool shouldRepaint(_TimelinePainter old) =>
      old.scale != scale ||
      old.dots != dots ||
      old.theme != theme ||
      old.density != density ||
      old.nodes != nodes ||
      old.links != links ||
      old.selection != selection;
}

/// Un renglón: ícono y nombre de la sección en su color, y el contenido a la derecha.
class _SectionRow extends StatelessWidget {
  const _SectionRow({required this.sectionId, required this.child});

  final String? sectionId;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final color = SectionStyle.color(context, sectionId);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 112,
            child: Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Row(
                children: [
                  Icon(SectionStyle.icon(sectionId), size: 16, color: color),
                  const SizedBox(width: 6),
                  Flexible(
                    child: Text(
                      SectionStyle.name(sectionId),
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(color: color),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(child: child),
        ],
      ),
    );
  }
}

class _CardHeader extends StatelessWidget {
  const _CardHeader({required this.overline, required this.title, required this.onClose});

  final String overline;
  final String title;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                overline,
                style: theme.textTheme.labelSmall?.copyWith(color: theme.colorScheme.outline, letterSpacing: 1.2),
              ),
              Text(title, style: theme.textTheme.titleMedium),
            ],
          ),
        ),
        IconButton(tooltip: 'Cerrar', icon: const Icon(Icons.close), onPressed: onClose),
      ],
    );
  }
}

/// Lo que un devocional vinculó, agrupado por la sección donde lo citó.
class _DevotionalLinksCard extends StatelessWidget {
  const _DevotionalLinksCard({required this.entry, required this.links, required this.onClose});

  final DevotionalEntry entry;
  final List<PassageLink> links;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final bySection = <String?, List<PassageLink>>{};
    for (final l in links) {
      bySection.putIfAbsent(l.sectionId, () => []).add(l);
    }
    return Card(
      key: const Key('timeline-selection'),
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 8, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _CardHeader(
              overline: 'DEVOCIONAL · ${entry.passage.label.toUpperCase()}',
              title: entry.title ?? entry.passage.label,
              onClose: onClose,
            ),
            const SizedBox(height: 4),
            if (links.isEmpty)
              Text(
                'Este devocional aún no vincula versículos. Escribe { en su reflexión para agregar.',
                style: Theme.of(context).textTheme.bodySmall,
              )
            else
              for (final id in SectionStyle.ids)
                if (bySection[id] case final group?)
                  _SectionRow(
                    sectionId: id,
                    child: Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      children: [
                        for (final l in group)
                          ActionChip(
                            visualDensity: VisualDensity.compact,
                            label: Text(l.target.label),
                            onPressed: () => showPassageSheet(context, l.target),
                          ),
                      ],
                    ),
                  ),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: () => context.go(Routes.devocional(entry.id)),
                icon: const Icon(Icons.open_in_new, size: 18),
                label: const Text('Abrir devocional'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Quién citó un versículo y desde qué sección.
class _PassageLinksCard extends StatelessWidget {
  const _PassageLinksCard({required this.passage, required this.studiedIn, required this.onClose});

  final LinkedPassage passage;
  final List<DevotionalEntry> studiedIn;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final period = HistoricalCatalog.periods
        .where(
          (p) => PassageNetwork.yearOf(passage.ref) >= p.startYear && PassageNetwork.yearOf(passage.ref) < p.endYear,
        )
        .firstOrNull;
    final sources = passage.sourceIds.length;
    final ownStudies = [
      for (final e in studiedIn)
        if (!passage.sourceIds.contains(e.id)) e,
    ];
    return Card(
      key: const Key('timeline-selection'),
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 8, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _CardHeader(
              overline: 'VERSÍCULO VINCULADO${period == null ? '' : ' · ${period.name.toUpperCase()}'}',
              title: passage.ref.label,
              onClose: onClose,
            ),
            Text(
              'Citado ${passage.links.length} ${passage.links.length == 1 ? 'vez' : 'veces'} '
              'desde $sources ${sources == 1 ? 'devocional' : 'devocionales'}.',
              style: theme.textTheme.bodySmall,
            ),
            const SizedBox(height: 4),
            for (final l in passage.links)
              _SectionRow(
                sectionId: l.sectionId,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: ActionChip(
                    visualDensity: VisualDensity.compact,
                    avatar: const Icon(Icons.menu_book_outlined, size: 16),
                    label: Text('desde ${l.source.title ?? l.source.passage.label}'),
                    onPressed: () => context.go(Routes.devocional(l.source.id)),
                  ),
                ),
              ),
            if (ownStudies.isNotEmpty) ...[
              const SizedBox(height: 6),
              Text('También estudiaste este capítulo en:', style: theme.textTheme.labelMedium),
              Wrap(
                spacing: 6,
                children: [
                  for (final e in ownStudies)
                    ActionChip(
                      visualDensity: VisualDensity.compact,
                      avatar: const Icon(Icons.link, size: 16),
                      label: Text(e.title ?? e.passage.label),
                      onPressed: () => context.go(Routes.devocional(e.id)),
                    ),
                ],
              ),
            ],
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: () => showPassageSheet(context, passage.ref),
                icon: const Icon(Icons.auto_stories_outlined, size: 18),
                label: const Text('Leer pasaje'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Los versículos más citados, con una barra segmentada por sección.
class _NetworkSummary extends StatelessWidget {
  const _NetworkSummary({required this.network, required this.onSelect});

  final PassageNetwork network;
  final ValueChanged<LinkedPassage> onSelect;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final top = network.passages.take(8).toList();
    final max = top.first.links.length;
    return Column(
      children: [
        for (final p in top)
          InkWell(
            key: Key('network-${p.key}'),
            borderRadius: BorderRadius.circular(8),
            onTap: () => onSelect(p),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                children: [
                  SizedBox(width: 130, child: Text(p.ref.label, style: theme.textTheme.bodySmall)),
                  Expanded(
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: FractionallySizedBox(
                        widthFactor: p.links.length / max,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: Row(
                            children: [
                              for (final id in SectionStyle.ids)
                                if (p.links.where((l) => l.sectionId == id).length case final n when n > 0)
                                  Expanded(
                                    flex: n,
                                    child: Container(height: 8, color: SectionStyle.color(context, id)),
                                  ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 32,
                    child: Text('${p.links.length}', textAlign: TextAlign.end, style: theme.textTheme.labelMedium),
                  ),
                ],
              ),
            ),
          ),
        if (network.passages.length > top.length)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              'y ${network.passages.length - top.length} más en la línea de tiempo.',
              style: theme.textTheme.bodySmall,
            ),
          ),
      ],
    );
  }
}

class _DensityList extends StatelessWidget {
  const _DensityList({required this.density});

  final Map<String, int> density;

  @override
  Widget build(BuildContext context) {
    final max = density.values.fold(0, (a, b) => a > b ? a : b);
    final theme = Theme.of(context);
    return Column(
      children: [
        for (final p in HistoricalCatalog.periods)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              children: [
                SizedBox(width: 170, child: Text(p.name, style: theme.textTheme.bodySmall)),
                Expanded(
                  child: LinearProgressIndicator(
                    value: max == 0 ? 0 : (density[p.id] ?? 0) / max,
                    minHeight: 8,
                    borderRadius: BorderRadius.circular(4),
                    color: context.dimensionColor(Dimension.contextoHistorico),
                  ),
                ),
                SizedBox(
                  width: 32,
                  child: Text('${density[p.id] ?? 0}', textAlign: TextAlign.end, style: theme.textTheme.labelMedium),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
