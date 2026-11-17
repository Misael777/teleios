import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/utils/text_normalizer.dart';
import '../../../infrastructure/ai/topic_suggester.dart';
import '../../../infrastructure/stt/speech_service.dart';
import '../../../shared/domain/entities/prayer_entry.dart';
import '../../../shared/domain/entities/topic.dart';
import '../../../shared/domain/entities/topic_draft.dart';
import '../../../shared/providers.dart';
import '../../../shared/widgets/common_widgets.dart';
import '../../bitacora/domain/praxis.dart';
import '../../bitacora/presentation/bitacora_providers.dart';
import '../../estudio/presentation/widgets/topic_assignment_section.dart';
import '../domain/prayer.dart';
import 'altar_providers.dart';
import 'waveform.dart';

/// Dictar (o escribir) una oración, revisar la transcripción y clasificarla.
class PrayerComposerScreen extends ConsumerStatefulWidget {
  const PrayerComposerScreen({super.key, this.prayerId});

  final String? prayerId;

  @override
  ConsumerState<PrayerComposerScreen> createState() => _PrayerComposerScreenState();
}

class _PrayerComposerScreenState extends ConsumerState<PrayerComposerScreen> {
  static const praxisWindow = Duration(days: 7);
  static const _classifier = PrayerIntentClassifier();
  static const _maxDictation = Duration(minutes: 10);

  /// Sesiones seguidas sin texto antes de dejar de reanudar (silencio prolongado).
  static const _maxEmptySessions = 3;

  final _text = TextEditingController();
  DateTime _date = DateTime.now();

  SpeechAvailability? _availability;
  bool _listening = false;
  DictationBuffer _dictation = DictationBuffer();
  bool _sessionHadText = false;
  int _emptySessions = 0;
  final _levels = <double>[];
  final _normalizer = LevelNormalizer();
  Duration _elapsed = Duration.zero;
  Timer? _ticker;

  PrayerIntent? _intent;
  bool _intentChosenByUser = false;
  ({PrayerIntent intent, double confidence, List<String> reasons})? _suggestedIntent;

  List<TopicDraft> _topics = [];
  List<TopicSuggestion> _suggestions = [];
  final Set<String> _dismissed = {};
  List<PraxisRecord> _recentPraxis = [];
  Set<String> _linkedPraxis = {};

  bool _saving = false;
  bool _dirty = false;
  Timer? _debounce;

  bool get _isEdit => widget.prayerId != null;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    if (_isEdit) {
      final r = await ref.read(prayerRepositoryProvider).getById(widget.prayerId!);
      if (r != null) {
        _date = r.entry.date;
        _text.text = r.entry.transcript;
        _intent = r.entry.intent;
        _intentChosenByUser = true;
        _topics = [for (final t in r.topics) TopicDraft(name: t.name, dimensionId: t.dimensionId, existingId: t.id)];
        _linkedPraxis = r.entry.praxisLinkedIds.toSet();
      }
    }
    final recent = await ref.read(praxisRepositoryProvider).since(DateTime.now().subtract(praxisWindow));
    if (!mounted) return;
    setState(() => _recentPraxis = recent);
    await _analyze();
  }

  @override
  void dispose() {
    _ticker?.cancel();
    _debounce?.cancel();
    if (_listening) ref.read(speechServiceProvider).stop();
    _text.dispose();
    super.dispose();
  }

  // ─── Voz ────────────────────────────────────────────────────────────────

  Future<void> _toggleListening() async {
    final speech = ref.read(speechServiceProvider);
    if (_listening) {
      _listening = false; // antes de stop(): el "done" que llega después no debe reanudar
      await speech.stop();
      _stopped(null);
      return;
    }
    _availability ??= await speech.initialize();
    if (_availability != SpeechAvailability.available) {
      setState(() {});
      return;
    }
    _emptySessions = 0;
    setState(() {
      _listening = true;
      _elapsed = Duration.zero;
      _levels.clear();
    });
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) => setState(() => _elapsed += const Duration(seconds: 1)));
    await _listenSession();
  }

  /// Android corta la escucha tras unos segundos de silencio: mientras el usuario no pulse detener,
  /// se abre otra sesión que continúa el texto (dictados largos).
  Future<void> _listenSession() async {
    _dictation = DictationBuffer(_text.text);
    _sessionHadText = false;
    await ref
        .read(speechServiceProvider)
        .start(
          onResult: (words, isFinal) {
            if (!mounted || !_listening) return;
            if (words.trim().isNotEmpty) _sessionHadText = true;
            final text = _dictation.add(words, isFinal: isFinal);
            _text.value = TextEditingValue(
              text: text,
              selection: TextSelection.collapsed(offset: text.length),
            );
            _dirty = true;
            _scheduleAnalysis();
          },
          onLevel: (level) {
            if (!mounted) return;
            setState(() {
              _levels.add(_normalizer.add(level));
              if (_levels.length > 240) _levels.removeAt(0);
            });
          },
          onDone: _sessionDone,
        );
  }

  void _sessionDone(SpeechAvailability? problem) {
    if (!mounted || !_listening) return;
    _emptySessions = _sessionHadText ? 0 : _emptySessions + 1;
    final resume = problem == null && _elapsed < _maxDictation && _emptySessions < _maxEmptySessions;
    if (!resume) {
      _stopped(problem);
      return;
    }
    // Pequeña espera: el reconocedor rechaza una nueva escucha mientras termina la anterior.
    Future<void>.delayed(const Duration(milliseconds: 300), () {
      if (mounted && _listening) _listenSession();
    });
  }

  void _stopped(SpeechAvailability? problem) {
    _ticker?.cancel();
    if (!mounted) return;
    setState(() {
      _listening = false;
      if (problem != null) _availability = problem;
    });
    _analyze();
  }

  // ─── Análisis ───────────────────────────────────────────────────────────

  void _scheduleAnalysis() {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 700), _analyze);
  }

  Future<void> _analyze() async {
    final text = _text.text;
    final suggestion = _classifier.classify(text);
    final userTopics = await ref.read(topicRepositoryProvider).getAll();
    final recent = await ref
        .read(praxisRepositoryProvider)
        .recentlyStudiedTopics(DateTime.now().subtract(const Duration(days: 14)));
    if (!mounted) return;
    setState(() {
      _suggestedIntent = suggestion;
      if (!_intentChosenByUser && suggestion != null) _intent = suggestion.intent;
      _suggestions = text.trim().isEmpty
          ? const []
          : ref
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

  void _addTopic(TopicDraft d) {
    final key = TextNormalizer.key(d.name);
    if (_topics.any((t) => t.dimensionId == d.dimensionId && TextNormalizer.key(t.name) == key)) return;
    setState(() {
      _topics = [..._topics, d];
      _suggestions = _suggestions.where((s) => s.key != '${d.dimensionId}::$key').toList();
      _dirty = true;
    });
  }

  Future<void> _save() async {
    if (_listening) {
      _listening = false;
      _ticker?.cancel();
      await ref.read(speechServiceProvider).stop();
    }
    if (_intent == null) {
      if (mounted) showMessage(context, 'Elige la intención de tu oración.');
      return;
    }
    setState(() => _saving = true);
    try {
      final id = await ref.read(savePrayerProvider)(
        PrayerDraft(
          id: widget.prayerId,
          date: _date,
          transcript: _text.text,
          intent: _intent!,
          topics: _topics,
          praxisIds: _linkedPraxis.toList(),
        ),
      );
      _dirty = false;
      if (!mounted) return;
      _isEdit ? context.pop() : context.pushReplacement(Routes.oracion(id));
    } catch (e) {
      if (mounted) showError(context, e);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  // ─── UI ─────────────────────────────────────────────────────────────────

  String? get _availabilityMessage => switch (_availability) {
    SpeechAvailability.onDeviceUnavailable =>
      'Tu dispositivo no ofrece dictado sin conexión en español. Para no enviar tu voz a servidores, '
          'el dictado queda desactivado: puedes escribir tu oración.',
    SpeechAvailability.permissionDenied => 'Sin permiso de micrófono. Puedes concederlo en los ajustes del sistema.',
    SpeechAvailability.unsupported => 'El dictado no está disponible en esta plataforma. Escribe tu oración.',
    _ => null,
  };

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final userTopics = ref.watch(allTopicsProvider).value ?? const <Topic>[];
    final micDisabled =
        !DeviceSpeechService.platformAllowed ||
        (_availability != null && _availability != SpeechAvailability.available);
    return PopScope(
      canPop: !_dirty,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        final discard = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('¿Descartar la oración?'),
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
          title: Text(_isEdit ? 'Editar oración' : 'Altar'),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: FilledButton.icon(
                key: const Key('save-prayer'),
                onPressed: _saving ? null : _save,
                icon: const Icon(Icons.check),
                label: const Text('Guardar'),
              ),
            ),
          ],
        ),
        body: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 760),
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
                    child: Column(
                      children: [
                        Waveform(levels: List.of(_levels), active: _listening),
                        const SizedBox(height: 16),
                        SizedBox.square(
                          dimension: 84,
                          child: FilledButton(
                            key: const Key('mic-button'),
                            style: FilledButton.styleFrom(
                              shape: const CircleBorder(),
                              padding: EdgeInsets.zero,
                              backgroundColor: _listening ? theme.colorScheme.error : null,
                            ),
                            onPressed: micDisabled ? null : _toggleListening,
                            child: Icon(_listening ? Icons.stop : Icons.mic, size: 36),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          _listening
                              ? 'Escuchando… ${_elapsed.inMinutes}:${(_elapsed.inSeconds % 60).toString().padLeft(2, '0')}'
                              : 'Toca para dictar · el audio no se guarda',
                          style: theme.textTheme.bodySmall,
                        ),
                        if (_availabilityMessage != null) ...[
                          const SizedBox(height: 10),
                          Text(
                            _availabilityMessage!,
                            textAlign: TextAlign.center,
                            style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.error),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                SectionCard(
                  title: 'Tu oración',
                  subtitle: Formatters.date(_date),
                  child: TextField(
                    key: const Key('prayer-text'),
                    controller: _text,
                    minLines: 6,
                    maxLines: null,
                    textCapitalization: TextCapitalization.sentences,
                    style: context.scripture.body.copyWith(fontSize: 18),
                    decoration: const InputDecoration(hintText: 'Derrama tu corazón… (Salmo 62:8)'),
                    onChanged: (_) {
                      _dirty = true;
                      _scheduleAnalysis();
                    },
                  ),
                ),
                SectionCard(
                  title: 'Intención',
                  subtitle: _suggestedIntent == null
                      ? null
                      : 'Sugerida: ${_suggestedIntent!.intent.label} (${_suggestedIntent!.reasons.take(3).join(', ')})',
                  child: Wrap(
                    key: const Key('prayer-intent'),
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final i in PrayerIntent.values)
                        ChoiceChip(
                          label: Text(i.label),
                          selected: _intent == i,
                          onSelected: (on) => setState(() {
                            _intent = on ? i : null;
                            _intentChosenByUser = true;
                            _dirty = true;
                          }),
                        ),
                    ],
                  ),
                ),
                SectionCard(
                  title: 'Tópicos de tu oración',
                  child: TopicAssignmentSection(
                    selected: _topics,
                    suggestions: _suggestions,
                    userTopics: userTopics,
                    onAdd: _addTopic,
                    onRemove: (d) => setState(() => _topics = _topics.where((t) => t != d).toList()),
                    onMove: (d, dim) {
                      setState(() => _topics = _topics.where((t) => t != d).toList());
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
                  ),
                ),
                if (_recentPraxis.isNotEmpty)
                  SectionCard(
                    title: '¿Ora por algo que viviste?',
                    subtitle: 'Vincula registros de tu bitácora de los últimos 7 días',
                    child: Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: [
                        for (final p in _recentPraxis)
                          FilterChip(
                            label: ConstrainedBox(
                              constraints: const BoxConstraints(maxWidth: 260),
                              child: Text(p.entry.circumstance, overflow: TextOverflow.ellipsis),
                            ),
                            selected: _linkedPraxis.contains(p.id),
                            onSelected: (on) => setState(() {
                              _linkedPraxis = on ? {..._linkedPraxis, p.id} : ({..._linkedPraxis}..remove(p.id));
                              _dirty = true;
                            }),
                          ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
