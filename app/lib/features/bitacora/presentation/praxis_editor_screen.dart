import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_router.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/utils/text_normalizer.dart';
import '../../../infrastructure/ai/topic_suggester.dart';
import '../../../shared/domain/entities/passage_ref.dart';
import '../../../shared/domain/entities/praxis_entry.dart';
import '../../../shared/domain/entities/topic.dart';
import '../../../shared/domain/entities/topic_draft.dart';
import '../../../shared/providers.dart';
import '../../../shared/widgets/common_widgets.dart';
import '../../estudio/presentation/passage_picker.dart';
import '../../estudio/presentation/widgets/topic_assignment_section.dart';
import '../domain/praxis.dart';
import 'bitacora_providers.dart';
import 'widgets/attachments_field.dart';
import 'widgets/emotion_picker.dart';

/// Registro A-B-C. [quick] = registro express (< 30 s): sin acción ni coherencia.
class PraxisEditorScreen extends ConsumerStatefulWidget {
  const PraxisEditorScreen({super.key, this.praxisId, this.quick = false});

  final String? praxisId;
  final bool quick;

  @override
  ConsumerState<PraxisEditorScreen> createState() => _PraxisEditorScreenState();
}

class _PraxisEditorScreenState extends ConsumerState<PraxisEditorScreen> {
  static const studyWindow = Duration(days: 14);

  final _circumstance = TextEditingController();
  final _foundation = TextEditingController();
  final _worldview = TextEditingController();
  final _action = TextEditingController();

  DateTime _date = DateTime.now();
  Set<String> _emotions = {};
  int _intensity = 5;
  FilterType? _filter;
  PassageRef? _passage;
  Set<String> _triggers = {};
  List<TopicDraft> _topics = [];
  List<TopicSuggestion> _suggestions = [];
  final Set<String> _dismissed = {};
  int _peace = 5;
  int _coherence = 5;
  late bool _evaluateCoherence = !widget.quick;
  List<Attachment> _existing = [];
  List<PendingImage> _pending = [];
  Set<String> _removed = {};

  int _step = 0;
  bool _loading = true;
  bool _saving = false;
  bool _dirty = false;
  Timer? _debounce;

  bool get _isEdit => widget.praxisId != null;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    if (_isEdit) {
      final r = await ref.read(praxisRepositoryProvider).getById(widget.praxisId!);
      if (r != null) {
        final e = r.entry;
        _date = e.date;
        _circumstance.text = e.circumstance;
        _emotions = e.emotionIds.toSet();
        _intensity = e.intensity;
        _filter = e.filter;
        _foundation.text = e.foundationDetail ?? '';
        _passage = e.passage;
        _triggers = e.triggerIds.toSet();
        _topics = [for (final t in r.topics) TopicDraft(name: t.name, dimensionId: t.dimensionId, existingId: t.id)];
        _action.text = e.action;
        _peace = e.peace;
        _evaluateCoherence = e.coherence != null;
        _coherence = e.coherence ?? 5;
        _existing = r.attachments;
      }
    }
    if (!mounted) return;
    setState(() => _loading = false);
    unawaited(_refreshSuggestions());
  }

  @override
  void dispose() {
    _debounce?.cancel();
    for (final c in [_circumstance, _foundation, _worldview, _action]) {
      c.dispose();
    }
    super.dispose();
  }

  void _changed([VoidCallback? fn]) => setState(() {
    fn?.call();
    _dirty = true;
  });

  void _onText(String _) {
    _dirty = true;
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 600), _refreshSuggestions);
  }

  Future<void> _refreshSuggestions() async {
    final userTopics = await ref.read(topicRepositoryProvider).getAll();
    final recent = await ref.read(praxisRepositoryProvider).recentlyStudiedTopics(DateTime.now().subtract(studyWindow));
    if (!mounted) return;
    final text = [_circumstance.text, _foundation.text, _action.text].join('. ');
    setState(() {
      _suggestions = ref
          .read(topicSuggesterProvider)
          .suggest(
            text: text,
            userTopics: userTopics,
            bookHistory: recent,
            historyReason: 'lo estudiaste en los últimos 14 días',
            exclude: {..._dismissed, for (final t in _topics) '${t.dimensionId}::${TextNormalizer.key(t.name)}'},
            perDimension: 2,
          );
    });
  }

  void _addTopic(TopicDraft draft) {
    final key = TextNormalizer.key(draft.name);
    if (_topics.any((t) => t.dimensionId == draft.dimensionId && TextNormalizer.key(t.name) == key)) return;
    _changed(() {
      _topics = [..._topics, draft];
      _suggestions = _suggestions.where((s) => s.key != '${draft.dimensionId}::$key').toList();
    });
  }

  Future<void> _addTrigger() async {
    // Sin controlador a propósito: ver EmotionPicker._addOwn.
    var typed = '';
    final name = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Nuevo detonante'),
        content: TextField(
          autofocus: true,
          onChanged: (v) => typed = v,
          textCapitalization: TextCapitalization.sentences,
          decoration: const InputDecoration(labelText: 'Nombre'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
          FilledButton(onPressed: () => Navigator.pop(context, typed), child: const Text('Agregar')),
        ],
      ),
    );
    if (name == null || name.trim().isEmpty) return;
    final trigger = await ref.read(praxisCatalogProvider).addTrigger(name);
    _changed(() => _triggers = {..._triggers, trigger.id});
  }

  Future<void> _save() async {
    if (_filter == null) {
      showMessage(context, '¿En qué te apoyaste? Elige un filtro.');
      if (!widget.quick) setState(() => _step = 1);
      return;
    }
    setState(() => _saving = true);
    try {
      final id = await ref.read(savePraxisProvider)(
        PraxisDraft(
          id: widget.praxisId,
          date: _date,
          circumstance: _circumstance.text,
          emotionIds: _emotions.toList(),
          intensity: _intensity,
          filter: _filter!,
          foundationDetail: _filter == FilterType.biblico ? _foundation.text : null,
          passage: _filter == FilterType.biblico ? _passage : null,
          triggerIds: _filter == FilterType.impulso ? _triggers.toList() : const [],
          topics: _topics,
          worldview: _filter == FilterType.cosmovision ? _worldview.text : null,
          action: _action.text,
          peace: _peace,
          coherence: _evaluateCoherence ? _coherence : null,
          newImages: _pending,
          removedAttachmentIds: _removed.toList(),
        ),
      );
      _dirty = false;
      if (!mounted) return;
      if (_isEdit) {
        context.pop();
      } else {
        context.pushReplacement(Routes.registro(id));
      }
    } catch (e) {
      if (mounted) showError(context, e);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _pickDateTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2000),
      lastDate: DateTime.now().add(const Duration(days: 1)),
    );
    if (date == null || !mounted) return;
    final time = await showTimePicker(context: context, initialTime: TimeOfDay.fromDateTime(_date));
    _changed(
      () => _date = DateTime(date.year, date.month, date.day, time?.hour ?? _date.hour, time?.minute ?? _date.minute),
    );
  }

  // ─── Secciones ──────────────────────────────────────────────────────────

  Widget _whatHappened() => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      TextField(
        key: const Key('praxis-circumstance'),
        controller: _circumstance,
        minLines: 2,
        maxLines: 6,
        textCapitalization: TextCapitalization.sentences,
        decoration: const InputDecoration(labelText: '¿Qué pasó?', hintText: 'La circunstancia, sin juzgarte'),
        onChanged: _onText,
      ),
      TextButton.icon(
        onPressed: _pickDateTime,
        icon: const Icon(Icons.schedule),
        label: Text('${Formatters.date(_date)} · ${TimeOfDay.fromDateTime(_date).format(context)}'),
      ),
      const SizedBox(height: 8),
      Text('¿Cómo te sentiste?', style: Theme.of(context).textTheme.titleSmall),
      const SizedBox(height: 8),
      EmotionPicker(selected: _emotions, onChanged: (s) => _changed(() => _emotions = s)),
      const SizedBox(height: 12),
      ScoreSlider(label: 'Intensidad', value: _intensity, onChanged: (v) => _changed(() => _intensity = v)),
    ],
  );

  Widget _filterSelector() => SegmentedButton<FilterType>(
    key: const Key('praxis-filter'),
    emptySelectionAllowed: true,
    showSelectedIcon: false,
    segments: [for (final f in FilterType.values) ButtonSegment(value: f, label: Text(f.shortLabel))],
    selected: {?_filter},
    onSelectionChanged: (s) => _changed(() => _filter = s.isEmpty ? null : s.first),
  );

  Widget _foundationSection() {
    final theme = Theme.of(context);
    final incubating =
        ref.watch(allTopicsProvider).value?.where((t) => t.status == TopicStatus.incubacion).toList() ?? [];
    final triggers = ref.watch(triggersProvider).value ?? const <CatalogEntry>[];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _filterSelector(),
        const SizedBox(height: 8),
        if (_filter != null)
          Text(switch (_filter!) {
            FilterType.biblico => 'Actuaste conscientemente desde un principio de la Escritura.',
            FilterType.cosmovision => 'Creíste que estaba bien, pero aún no conoces su fundamento bíblico.',
            FilterType.impulso => 'Reaccionaste desde la emoción del momento. Registrarlo es el primer paso.',
          }, style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
        const SizedBox(height: 12),
        if (_filter == FilterType.biblico) ...[
          TextField(
            controller: _foundation,
            minLines: 1,
            maxLines: 4,
            textCapitalization: TextCapitalization.sentences,
            decoration: const InputDecoration(labelText: '¿Qué principio aplicaste?'),
            onChanged: _onText,
          ),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: () async {
              final p = await showPassagePicker(context, initial: _passage);
              if (p != null) _changed(() => _passage = p);
            },
            icon: const Icon(Icons.menu_book_outlined),
            label: Text(_passage?.label ?? 'Versículo que usaste (opcional)'),
          ),
        ],
        if (_filter == FilterType.cosmovision) ...[
          TextField(
            key: const Key('praxis-worldview'),
            controller: _worldview,
            textCapitalization: TextCapitalization.sentences,
            decoration: const InputDecoration(
              labelText: '¿Qué creencia te guió?',
              helperText: 'Se guardará en Incubación para validarla o refutarla al estudiar.',
            ),
            onChanged: (_) => _dirty = true,
          ),
          if (incubating.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text('¿O es una que ya tienes en incubación?', style: theme.textTheme.labelMedium),
            const SizedBox(height: 6),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                for (final t in incubating.take(8))
                  ActionChip(
                    avatar: const Icon(Icons.hourglass_top, size: 16),
                    label: Text(t.name),
                    onPressed: () => _addTopic(TopicDraft(name: t.name, dimensionId: t.dimensionId, existingId: t.id)),
                  ),
              ],
            ),
          ],
        ],
        if (_filter == FilterType.impulso) ...[
          Text('¿Qué lo detonó?', style: theme.textTheme.titleSmall),
          const SizedBox(height: 6),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              for (final t in triggers)
                FilterChip(
                  label: Text(t.name),
                  selected: _triggers.contains(t.id),
                  onSelected: (on) =>
                      _changed(() => _triggers = on ? {..._triggers, t.id} : ({..._triggers}..remove(t.id))),
                ),
              ActionChip(avatar: const Icon(Icons.add, size: 18), label: const Text('Otro'), onPressed: _addTrigger),
            ],
          ),
        ],
      ],
    );
  }

  Widget _topicsSection(List<Topic> userTopics) => TopicAssignmentSection(
    selected: _topics,
    suggestions: _suggestions,
    userTopics: userTopics,
    onAdd: _addTopic,
    onRemove: (d) => _changed(() => _topics = _topics.where((t) => t != d).toList()),
    onMove: (d, dim) {
      _changed(() => _topics = _topics.where((t) => t != d).toList());
      _addTopic(d.movedTo(dim));
    },
    onAccept: (s) => _addTopic(
      TopicDraft(
        name: s.name,
        dimensionId: s.dimensionId,
        existingId: s.existingTopicId,
        origin: s.existingTopicId == null ? TopicOrigin.sugerido : TopicOrigin.usuario,
        confidence: s.confidence,
      ),
    ),
    onDismiss: (s) => setState(() {
      _dismissed.add(s.key);
      _suggestions = _suggestions.where((x) => x.key != s.key).toList();
    }),
  );

  Widget _consequence() => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      TextField(
        controller: _action,
        minLines: 1,
        maxLines: 5,
        textCapitalization: TextCapitalization.sentences,
        decoration: const InputDecoration(labelText: '¿Qué hiciste? ¿Cómo lo afrontaste?'),
        onChanged: _onText,
      ),
      const SizedBox(height: 12),
      ScoreSlider(label: 'Paz después', value: _peace, onChanged: (v) => _changed(() => _peace = v)),
      SwitchListTile(
        contentPadding: EdgeInsets.zero,
        value: _evaluateCoherence,
        onChanged: (v) => _changed(() => _evaluateCoherence = v),
        title: const Text('Evaluar coherencia'),
        subtitle: const Text('¿Tu reacción se alineó con tus principios?'),
      ),
      if (_evaluateCoherence)
        ScoreSlider(label: 'Coherencia', value: _coherence, onChanged: (v) => _changed(() => _coherence = v)),
    ],
  );

  Widget _photos() => AttachmentsField(
    existing: _existing,
    pending: _pending,
    removedIds: _removed,
    onChanged: (p, r) => _changed(() {
      _pending = p;
      _removed = r;
    }),
  );

  // ─── Build ──────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final userTopics = ref.watch(allTopicsProvider).value ?? const <Topic>[];
    final title = _isEdit ? 'Editar registro' : (widget.quick ? 'Registro rápido' : 'Nuevo registro');
    return PopScope(
      canPop: !_dirty,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        final discard = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('¿Descartar cambios?'),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Seguir')),
              FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Descartar')),
            ],
          ),
        );
        if (discard == true && context.mounted) {
          _dirty = false;
          context.pop();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(title),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: FilledButton.icon(
                key: const Key('save-praxis'),
                onPressed: _saving || _loading ? null : _save,
                icon: _saving
                    ? const SizedBox.square(dimension: 16, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Icon(Icons.check),
                label: const Text('Guardar'),
              ),
            ),
          ],
        ),
        body: _loading
            ? const Center(child: CircularProgressIndicator())
            : Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 760),
                  child: widget.quick ? _quickBody() : _fullBody(userTopics),
                ),
              ),
      ),
    );
  }

  Widget _quickBody() => ListView(
    padding: const EdgeInsets.all(16),
    children: [
      SectionCard(title: 'A · Acontecimiento', child: _whatHappened()),
      SectionCard(
        title: 'B · ¿En qué te apoyaste?',
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [_filterSelector()]),
      ),
      SectionCard(
        title: 'C · Paz después',
        child: ScoreSlider(label: 'Paz', value: _peace, onChanged: (v) => _changed(() => _peace = v)),
      ),
      Text(
        'Podrás completar la acción, la coherencia y los tópicos más tarde.',
        style: Theme.of(context).textTheme.bodySmall,
        textAlign: TextAlign.center,
      ),
    ],
  );

  Widget _fullBody(List<Topic> userTopics) => Stepper(
    currentStep: _step,
    onStepTapped: (s) => setState(() => _step = s),
    onStepContinue: () => _step < 3 ? setState(() => _step++) : _save(),
    onStepCancel: _step > 0 ? () => setState(() => _step--) : null,
    controlsBuilder: (context, details) => Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Row(
        children: [
          FilledButton.tonal(
            onPressed: details.onStepContinue,
            child: Text(details.stepIndex == 3 ? 'Guardar' : 'Siguiente'),
          ),
          const SizedBox(width: 8),
          if (details.onStepCancel != null) TextButton(onPressed: details.onStepCancel, child: const Text('Atrás')),
        ],
      ),
    ),
    steps: [
      Step(
        title: const Text('A · Acontecimiento'),
        subtitle: const Text('Qué pasó y cómo te sentiste'),
        isActive: _step >= 0,
        content: _whatHappened(),
      ),
      Step(
        title: const Text('B · Filtro'),
        subtitle: const Text('En qué te apoyaste'),
        isActive: _step >= 1,
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _foundationSection(),
            const Divider(height: 32),
            Text('Tópicos relacionados', style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 4),
            _topicsSection(userTopics),
          ],
        ),
      ),
      Step(
        title: const Text('C · Consecuencia'),
        subtitle: const Text('Qué hiciste, paz y coherencia'),
        isActive: _step >= 2,
        content: _consequence(),
      ),
      Step(
        title: const Text('Fotos (opcional)'),
        subtitle: const Text('Privadas y cifradas'),
        isActive: _step >= 3,
        content: _photos(),
      ),
    ],
  );
}
