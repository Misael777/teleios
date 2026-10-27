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
import 'estudio_providers.dart';
import 'passage_picker.dart';
import 'widgets/historical_context_form.dart';
import 'widgets/topic_assignment_section.dart';

class DevotionalEditorScreen extends ConsumerStatefulWidget {
  const DevotionalEditorScreen({super.key, this.devotionalId, this.initialPassage});

  final String? devotionalId;
  final PassageRef? initialPassage;

  @override
  ConsumerState<DevotionalEditorScreen> createState() => _DevotionalEditorScreenState();
}

class _DevotionalEditorScreenState extends ConsumerState<DevotionalEditorScreen> {
  final _content = TextEditingController();
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
    _load();
  }

  Future<void> _load() async {
    if (_isEdit) {
      final entry = await ref.read(devotionalRepositoryProvider).getById(widget.devotionalId!);
      if (entry != null) {
        _date = entry.date;
        _passage = entry.passage;
        _context = entry.context;
        _content.text = entry.content;
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
    _content.dispose();
    super.dispose();
  }

  void _markDirty() => _dirty = true;

  void _onTextChanged(String _) {
    _markDirty();
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
          text: _content.text,
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
      periodId: _context.periodId == null ? () => passage.book.periodId : null,
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
    setState(() => _saving = true);
    try {
      final id = await ref.read(saveDevotionalProvider)(
        DevotionalDraft(
          id: widget.devotionalId,
          date: _date,
          passage: passage,
          content: _content.text,
          context: _context,
          topics: _topics,
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
                      SectionCard(
                        title: 'Reflexión',
                        subtitle: '¿Qué te enseña el texto? ¿Qué revela de Dios? ¿Qué vas a aplicar?',
                        child: TextField(
                          key: const Key('devotional-content'),
                          controller: _content,
                          minLines: 6,
                          maxLines: null,
                          textCapitalization: TextCapitalization.sentences,
                          decoration: const InputDecoration(hintText: 'Escribe libremente…'),
                          onChanged: _onTextChanged,
                        ),
                      ),
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
