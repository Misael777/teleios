import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/utils/text_normalizer.dart';
import '../../../infrastructure/ai/topic_suggester.dart';
import '../../../shared/domain/catalogs/historical_catalog.dart';
import '../../../shared/domain/entities/historical_context.dart';
import '../../../shared/domain/entities/passage_ref.dart';
import '../../../shared/domain/entities/topic.dart';
import '../../../shared/providers.dart';
import '../../../shared/widgets/common_widgets.dart';
import '../domain/devotional.dart';
import '../domain/guided_reflection.dart';
import 'estudio_providers.dart';
import 'passage_picker.dart';
import 'widgets/historical_context_form.dart';
import 'widgets/scripture_text.dart';
import 'widgets/topic_assignment_section.dart';

class DevotionalEditorScreen extends ConsumerStatefulWidget {
  const DevotionalEditorScreen({super.key, this.devotionalId, this.initialPassage});

  final String? devotionalId;
  final PassageRef? initialPassage;

  @override
  ConsumerState<DevotionalEditorScreen> createState() => _DevotionalEditorScreenState();
}

class _DevotionalEditorScreenState extends ConsumerState<DevotionalEditorScreen> {
  final _answers = {for (final q in GuidedReflection.questions) q.id: ScriptureLinkController()};

  /// Reflexión libre escrita antes de la guía: se conserva y se puede editar.
  final _notes = ScriptureLinkController();
  bool _hasNotes = false;

  // Portada
  final _title = TextEditingController();
  PassageRef? _keyVerse;

  /// Secciones con la batería completa a la vista ("Profundizar").
  final Set<String> _expanded = {};
  DateTime _date = DateTime.now();
  PassageRef? _passage;
  HistoricalContext _context = const HistoricalContext();
  List<TopicDraft> _topics = [];
  List<TopicSuggestion> _suggestions = [];
  final Set<String> _dismissed = {};

  bool _loading = true;
  bool _saving = false;
  bool _dirty = false;
  Timer? _debounce;

  bool get _isEdit => widget.devotionalId != null;

  @override
  void initState() {
    super.initState();
    _passage = widget.initialPassage;
    for (final c in [..._answers.values, _notes]) {
      c.onBrace = (offset) {
        if (mounted) pickAndLinkPassage(context, c, braceOffset: offset);
      };
    }
    _load();
  }

  Future<void> _load() async {
    if (_isEdit) {
      final entry = await ref.read(devotionalRepositoryProvider).getById(widget.devotionalId!);
      if (entry != null) {
        _date = entry.date;
        _passage = entry.passage;
        _context = entry.context;
        final reflection = GuidedReflection.parse(entry.content);
        _notes.text = reflection.notes;
        _hasNotes = reflection.notes.isNotEmpty;
        for (final q in GuidedReflection.questions) {
          _answers[q.id]!.text = reflection.answer(q.id);
        }
        // Las preguntas de la batería ya respondidas quedan a la vista.
        for (final s in GuidedReflection.sections) {
          if (s.questions.any((q) => !q.key && reflection.answered(q.id))) _expanded.add(s.id);
        }
        _title.text = entry.title ?? '';
        _keyVerse = entry.keyVerse;
        _topics = [
          for (final t in entry.topics) TopicDraft(name: t.name, dimensionId: t.dimensionId, existingId: t.id),
        ];
      }
    } else if (_passage != null) {
      _prefillContext(_passage!);
    }
    if (!mounted) return;
    setState(() => _loading = false);
    unawaited(_refreshSuggestions());
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _notes.dispose();
    _title.dispose();
    for (final c in _answers.values) {
      c.dispose();
    }
    super.dispose();
  }

  void _markDirty() => _dirty = true;

  GuidedReflection get _reflection =>
      GuidedReflection(answers: {for (final e in _answers.entries) e.key: e.value.text}, notes: _notes.text);

  void _onTextChanged(String _) {
    _markDirty();
    setState(() {}); // contador de preguntas respondidas
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 600), _refreshSuggestions);
  }

  Set<String> get _excludedKeys => {
    ..._dismissed,
    for (final t in _topics) '${t.dimensionId}::${TextNormalizer.key(t.name)}',
  };

  Future<void> _refreshSuggestions() async {
    final passage = _passage;
    final topicsRepo = ref.read(topicRepositoryProvider);
    final userTopics = await topicsRepo.getAll();
    final history = passage == null ? <Topic>[] : await topicsRepo.topicsUsedWithBook(passage.bookCode);
    if (!mounted) return;
    final suggestions = ref
        .read(topicSuggesterProvider)
        .suggest(
          text: _reflection.plainText,
          userTopics: userTopics,
          bookHistory: history,
          bookName: passage?.book.name,
          exclude: _excludedKeys,
        );
    setState(() => _suggestions = suggestions);
  }

  void _prefillContext(PassageRef passage) {
    // Solo pre-llena lo vacío: nunca pisa lo que escribió el usuario.
    _context = _context.copyWith(
      periodId: _context.periodId == null
          ? () => HistoricalCatalog.periodForChapter(passage.bookCode, passage.chapter) ?? passage.book.periodId
          : null,
      author: (_context.author ?? '').isEmpty ? () => passage.book.author : null,
    );
  }

  Future<void> _pickPassage() async {
    final picked = await showPassagePicker(context, initial: _passage);
    if (picked == null) return;
    setState(() {
      _passage = picked;
      _prefillContext(picked);
      _markDirty();
    });
    unawaited(_refreshSuggestions());
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2000),
      lastDate: DateTime.now().add(const Duration(days: 1)),
    );
    if (picked != null) {
      setState(() {
        _date = DateTime(picked.year, picked.month, picked.day, _date.hour, _date.minute);
        _markDirty();
      });
    }
  }

  void _addTopic(TopicDraft draft) {
    final key = TextNormalizer.key(draft.name);
    final exists = _topics.any((t) => t.dimensionId == draft.dimensionId && TextNormalizer.key(t.name) == key);
    if (exists) return;
    setState(() {
      _topics = [..._topics, draft];
      _suggestions = _suggestions.where((s) => s.key != '${draft.dimensionId}::$key').toList();
      _markDirty();
    });
  }

  void _accept(TopicSuggestion s) => _addTopic(
    TopicDraft(
      name: s.name,
      dimensionId: s.dimensionId,
      existingId: s.existingTopicId,
      origin: s.existingTopicId == null ? TopicOrigin.sugerido : TopicOrigin.usuario,
      confidence: s.confidence,
    ),
  );

  void _dismiss(TopicSuggestion s) => setState(() {
    _dismissed.add(s.key);
    _suggestions = _suggestions.where((x) => x.key != s.key).toList();
  });

  void _remove(TopicDraft draft) => setState(() {
    _topics = _topics.where((t) => t != draft).toList();
    _markDirty();
  });

  void _move(TopicDraft draft, String dimensionId) {
    _remove(draft);
    _addTopic(draft.movedTo(dimensionId));
  }

  Future<void> _save() async {
    final passage = _passage;
    if (passage == null) {
      showMessage(context, 'Elige el pasaje que estudiaste.');
      return;
    }
    final reflection = _reflection;
    // Las reflexiones anteriores a la guía (con notas libres) no se obligan a reescribirse.
    if (reflection.notes.isEmpty && reflection.missing.isNotEmpty) {
      final names = reflection.missing.map((q) => GuidedReflection.sectionOf(q.id).name).join(', ');
      showMessage(context, 'Te falta responder la pregunta clave de: $names.');
      return;
    }
    setState(() => _saving = true);
    try {
      final id = await ref.read(saveDevotionalProvider)(
        DevotionalDraft(
          id: widget.devotionalId,
          date: _date,
          passage: passage,
          content: reflection.encode(),
          context: _context,
          topics: _topics,
          title: _title.text,
          keyVerse: _keyVerse,
        ),
      );
      _dirty = false;
      if (!mounted) return;
      if (_isEdit) {
        context.pop();
      } else {
        context.pushReplacement(Routes.devocional(id));
      }
    } catch (e) {
      if (mounted) showError(context, e);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<bool> _confirmDiscard() async =>
      await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('¿Descartar cambios?'),
          content: const Text('Tienes cambios sin guardar.'),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Seguir editando')),
            FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Descartar')),
          ],
        ),
      ) ??
      false;

  @override
  Widget build(BuildContext context) {
    final userTopics = ref.watch(allTopicsProvider).value ?? const <Topic>[];
    return PopScope(
      canPop: !_dirty,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        if (await _confirmDiscard() && context.mounted) {
          _dirty = false;
          context.pop();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(_isEdit ? 'Editar devocional' : 'Nuevo devocional'),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: FilledButton.icon(
                key: const Key('save-devotional'),
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
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      SectionCard(
                        title: 'Pasaje',
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            OutlinedButton.icon(
                              key: const Key('pick-passage'),
                              onPressed: _pickPassage,
                              icon: const Icon(Icons.menu_book_outlined),
                              label: Text(_passage?.label ?? 'Elegir pasaje'),
                            ),
                            if (_passage != null) _PassagePreview(passage: _passage!),
                            const SizedBox(height: 8),
                            TextButton.icon(
                              onPressed: _pickDate,
                              icon: const Icon(Icons.event_outlined),
                              label: Text(Formatters.date(_date)),
                            ),
                          ],
                        ),
                      ),
                      _coverCard(),
                      _reflectionSummary(),
                      for (final section in GuidedReflection.sections) _sectionCard(section),
                      SectionCard(
                        title: 'Tópicos por dimensión',
                        subtitle: 'Toca ✨ para aceptar una sugerencia; toca un tópico para moverlo.',
                        trailing: IconButton(
                          tooltip: 'Volver a sugerir',
                          icon: const Icon(Icons.auto_awesome_outlined),
                          onPressed: () {
                            _dismissed.clear();
                            _refreshSuggestions();
                          },
                        ),
                        child: TopicAssignmentSection(
                          selected: _topics,
                          suggestions: _suggestions,
                          userTopics: userTopics,
                          onAdd: _addTopic,
                          onRemove: _remove,
                          onMove: _move,
                          onAccept: _accept,
                          onDismiss: _dismiss,
                        ),
                      ),
                      Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: ExpansionTile(
                          title: const Text('Contexto histórico'),
                          subtitle: Text(_contextSummary),
                          shape: const Border(),
                          childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                          children: [
                            HistoricalContextForm(
                              value: _context,
                              onChanged: (c) => setState(() {
                                _context = c;
                                _markDirty();
                              }),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 48),
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  Widget _coverCard() => SectionCard(
    title: 'Portada',
    subtitle: 'Opcional: dale un título a tu estudio y elige su versículo lema.',
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          key: const Key('devotional-title'),
          controller: _title,
          maxLength: 120,
          textCapitalization: TextCapitalization.sentences,
          decoration: const InputDecoration(labelText: 'Título', hintText: 'Ej.: Trabajar como para el Señor'),
          onChanged: (_) => _markDirty(),
        ),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                key: const Key('pick-key-verse'),
                onPressed: () async {
                  final picked = await showPassagePicker(context, initial: _keyVerse ?? _passage);
                  if (picked != null) {
                    setState(() {
                      _keyVerse = picked;
                      _markDirty();
                    });
                  }
                },
                icon: const Icon(Icons.format_quote),
                label: Text(_keyVerse == null ? 'Versículo lema' : 'Lema: ${_keyVerse!.label}'),
              ),
            ),
            if (_keyVerse != null)
              IconButton(
                tooltip: 'Quitar versículo lema',
                icon: const Icon(Icons.close),
                onPressed: () => setState(() {
                  _keyVerse = null;
                  _markDirty();
                }),
              ),
          ],
        ),
      ],
    ),
  );

  Widget _reflectionSummary() {
    final reflection = _reflection;
    final required = GuidedReflection.sections.where((s) => !s.optional).length;
    final done = required - reflection.missing.length;
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 8, 4, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Reflexión guiada', style: theme.textTheme.titleLarge),
          const SizedBox(height: 4),
          Text(
            'Responde la pregunta clave de cada sección ($done de $required). '
            'Escribe { para vincular un versículo.',
            style: theme.textTheme.bodySmall,
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(value: done / required),
        ],
      ),
    );
  }

  Widget _questionField(ReflectionQuestion q, {required int number}) {
    final theme = Theme.of(context);
    final controller = _answers[q.id]!;
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('$number. ${q.text}', style: q.key ? theme.textTheme.titleMedium : theme.textTheme.titleSmall),
          const SizedBox(height: 8),
          TextField(
            key: Key('reflection-${q.id}'),
            controller: controller,
            minLines: q.key ? 3 : 2,
            maxLines: null,
            textCapitalization: TextCapitalization.sentences,
            decoration: InputDecoration(
              hintText: q.hint,
              hintMaxLines: 3,
              suffixIcon: IconButton(
                tooltip: 'Vincular versículo',
                icon: const Icon(Icons.add_link),
                onPressed: () => pickAndLinkPassage(context, controller),
              ),
            ),
            onChanged: _onTextChanged,
          ),
        ],
      ),
    );
  }

  Widget _sectionCard(ReflectionSection section) {
    final reflection = _reflection;
    final theme = Theme.of(context);
    final expanded = _expanded.contains(section.id);
    final extra = section.questions.where((q) => !q.key).toList();
    final answered = reflection.answeredIn(section);
    return SectionCard(
      title: section.name,
      subtitle: [
        section.purpose,
        [if (section.optional) 'Opcional', '$answered de ${section.questions.length} respondidas'].join(' · '),
      ].join('\n'),
      trailing: reflection.answered(section.keyQuestion.id)
          ? Icon(Icons.check_circle, color: theme.colorScheme.primary)
          : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _questionField(section.keyQuestion, number: 1),
          if (expanded)
            for (final (i, q) in extra.indexed) _questionField(q, number: i + 2),
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
              key: Key('deepen-${section.id}'),
              onPressed: () => setState(() => expanded ? _expanded.remove(section.id) : _expanded.add(section.id)),
              icon: Icon(expanded ? Icons.expand_less : Icons.expand_more),
              label: Text(expanded ? 'Menos preguntas' : 'Profundizar · ${extra.length} preguntas más'),
            ),
          ),
          if (section.id == GuidedReflection.sections.first.id && _hasNotes) ...[
            const SizedBox(height: 8),
            Text('Reflexión anterior', style: theme.textTheme.titleSmall),
            Text(
              'La escribiste antes de la guía. Puedes repartirla en las preguntas o dejarla aquí.',
              style: theme.textTheme.bodySmall,
            ),
            const SizedBox(height: 8),
            TextField(
              key: const Key('reflection-notes'),
              controller: _notes,
              minLines: 3,
              maxLines: null,
              textCapitalization: TextCapitalization.sentences,
              onChanged: _onTextChanged,
            ),
          ],
        ],
      ),
    );
  }

  String get _contextSummary {
    if (_context.isEmpty) return 'Alimenta tu línea de tiempo';
    return [
      ?HistoricalCatalog.period(_context.periodId)?.name,
      ?_context.author,
      if (_context.approxYear != null) Formatters.year(_context.approxYear!),
    ].join(' · ');
  }
}

class _PassagePreview extends ConsumerWidget {
  const _PassagePreview({required this.passage});

  final PassageRef passage;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final verses = ref.watch(passageTextProvider(passage));
    return verses.when(
      loading: () => const LinearProgressIndicator(),
      error: (e, _) => const SizedBox.shrink(),
      data: (list) => Padding(
        padding: const EdgeInsets.only(top: 12),
        child: Text(
          list.where((v) => v.text.isNotEmpty).map((v) => '${v.verse} ${v.text}').join(' '),
          maxLines: passage.isWholeChapter ? 4 : 10,
          overflow: TextOverflow.ellipsis,
          style: context.scripture.body.copyWith(fontSize: 17, fontStyle: FontStyle.italic),
        ),
      ),
    );
  }
}
