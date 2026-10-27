import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/domain/catalogs/bible_books.dart';
import '../../../shared/domain/entities/passage_ref.dart';
import '../../../shared/providers.dart';
import '../../../shared/widgets/common_widgets.dart';
import '../domain/repositories.dart';

class BibleReaderScreen extends ConsumerStatefulWidget {
  const BibleReaderScreen({super.key});

  @override
  ConsumerState<BibleReaderScreen> createState() => _BibleReaderScreenState();
}

class _BibleReaderScreenState extends ConsumerState<BibleReaderScreen> {
  final _search = TextEditingController();
  Timer? _debounce;
  String _bookCode = 'JOH';
  int _chapter = 1;
  int _chapterCount = 21;
  int? _highlight;
  Future<List<BibleSearchHit>>? _results;

  BibleRepository get _bible => ref.read(bibleRepositoryProvider);

  @override
  void dispose() {
    _debounce?.cancel();
    _search.dispose();
    super.dispose();
  }

  Future<void> _open(String book, int chapter, {int? highlight}) async {
    final count = await _bible.chapterCount(book);
    setState(() {
      _bookCode = book;
      _chapterCount = count;
      _chapter = chapter.clamp(1, count);
      _highlight = highlight;
    });
  }

  void _onSearch(String text) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      final ref = PassageRef.tryParse(text);
      if (ref != null) {
        _search.clear();
        setState(() => _results = null);
        _open(ref.bookCode, ref.chapter, highlight: ref.verseStart);
        return;
      }
      setState(() => _results = text.trim().length < 3 ? null : _bible.search(text));
    });
  }

  void _studyVerse(BibleVerse v) => context.push(
    Routes.nuevoDevocional,
    extra: PassageRef(bookCode: v.bookCode, chapter: v.chapter, verseStart: v.verse),
  );

  @override
  Widget build(BuildContext context) {
    final book = BibleBooks.byCode(_bookCode);
    return Scaffold(
      appBar: AppBar(title: Text('Biblia · ${_bible.translation}')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
            child: TextField(
              controller: _search,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search),
                hintText: 'Buscar palabras o ir a una cita (Ro 8:28)',
                isDense: true,
                suffixIcon: _search.text.isEmpty
                    ? null
                    : IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () => setState(() {
                          _search.clear();
                          _results = null;
                        }),
                      ),
              ),
              onChanged: _onSearch,
            ),
          ),
          if (_results == null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Row(
                children: [
                  Expanded(
                    child: DropdownButton<String>(
                      value: _bookCode,
                      isExpanded: true,
                      underline: const SizedBox.shrink(),
                      items: [for (final b in BibleBooks.all) DropdownMenuItem(value: b.code, child: Text(b.name))],
                      onChanged: (code) => _open(code!, 1),
                    ),
                  ),
                  IconButton(
                    tooltip: 'Capítulo anterior',
                    icon: const Icon(Icons.chevron_left),
                    onPressed: _chapter > 1 ? () => _open(_bookCode, _chapter - 1) : null,
                  ),
                  DropdownButton<int>(
                    value: _chapter,
                    underline: const SizedBox.shrink(),
                    items: [
                      for (var c = 1; c <= _chapterCount; c++) DropdownMenuItem(value: c, child: Text('Cap. $c')),
                    ],
                    onChanged: (c) => _open(_bookCode, c!),
                  ),
                  IconButton(
                    tooltip: 'Capítulo siguiente',
                    icon: const Icon(Icons.chevron_right),
                    onPressed: _chapter < _chapterCount ? () => _open(_bookCode, _chapter + 1) : null,
                  ),
                ],
              ),
            ),
          const Divider(height: 1),
          Expanded(
            child: _results != null
                ? _SearchResults(
                    results: _results!,
                    onTap: (hit) {
                      _search.clear();
                      setState(() => _results = null);
                      _open(hit.verse.bookCode, hit.verse.chapter, highlight: hit.verse.verse);
                    },
                  )
                : _ChapterView(
                    key: ValueKey('$_bookCode-$_chapter'),
                    book: book,
                    chapter: _chapter,
                    highlight: _highlight,
                    onStudy: _studyVerse,
                  ),
          ),
        ],
      ),
    );
  }
}

class _ChapterView extends ConsumerStatefulWidget {
  const _ChapterView({super.key, required this.book, required this.chapter, this.highlight, required this.onStudy});

  final BibleBook book;
  final int chapter;
  final int? highlight;
  final ValueChanged<BibleVerse> onStudy;

  @override
  ConsumerState<_ChapterView> createState() => _ChapterViewState();
}

class _ChapterViewState extends ConsumerState<_ChapterView> {
  late final Future<List<BibleVerse>> _verses = ref
      .read(bibleRepositoryProvider)
      .chapter(widget.book.code, widget.chapter);
  final _highlightKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _verses.then((_) {
      // Lleva el versículo buscado a la vista cuando ya está construido.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final ctx = _highlightKey.currentContext;
        if (ctx != null && ctx.mounted) Scrollable.ensureVisible(ctx, alignment: 0.2);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return FutureBuilder<List<BibleVerse>>(
      future: _verses,
      builder: (context, snap) {
        if (!snap.hasData) return const Center(child: CircularProgressIndicator());
        final verses = snap.data!.where((v) => v.text.isNotEmpty);
        // Lista no perezosa (máx. ~176 versículos) para que ensureVisible encuentre el destacado.
        return SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('${widget.book.name} ${widget.chapter}', style: theme.textTheme.headlineSmall),
                    Text(
                      'Mantén pulsado un versículo para escribir un devocional sobre él.',
                      style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.outline),
                    ),
                  ],
                ),
              ),
              for (final v in verses) _verse(theme, v),
            ],
          ),
        );
      },
    );
  }

  Widget _verse(ThemeData theme, BibleVerse v) {
    final highlighted = v.verse == widget.highlight;
    return InkWell(
      key: highlighted ? _highlightKey : null,
      onLongPress: () => widget.onStudy(v),
      child: Container(
        padding: const EdgeInsets.all(4),
        color: highlighted ? theme.colorScheme.primaryContainer.withValues(alpha: 0.5) : null,
        child: Text.rich(
          TextSpan(
            children: [
              TextSpan(text: '${v.verse}  ', style: context.scripture.verseNumber),
              TextSpan(text: v.text),
            ],
          ),
          style: context.scripture.body,
        ),
      ),
    );
  }
}

class _SearchResults extends StatelessWidget {
  const _SearchResults({required this.results, required this.onTap});

  final Future<List<BibleSearchHit>> results;
  final ValueChanged<BibleSearchHit> onTap;

  @override
  Widget build(BuildContext context) => FutureBuilder<List<BibleSearchHit>>(
    future: results,
    builder: (context, snap) {
      if (!snap.hasData) return const Center(child: CircularProgressIndicator());
      final hits = snap.data!;
      if (hits.isEmpty) return const EmptyState(icon: Icons.search_off, title: 'Sin coincidencias');
      return ListView.separated(
        itemCount: hits.length,
        separatorBuilder: (_, _) => const Divider(height: 1),
        itemBuilder: (_, i) {
          final hit = hits[i];
          return ListTile(
            title: Text(hit.verse.ref.label),
            subtitle: _Highlighted(hit.snippet),
            onTap: () => onTap(hit),
          );
        },
      );
    },
  );
}

/// Pinta en negrita los fragmentos marcados entre [ y ] por FTS5.
class _Highlighted extends StatelessWidget {
  const _Highlighted(this.snippet);

  final String snippet;

  @override
  Widget build(BuildContext context) {
    final spans = <TextSpan>[];
    final pattern = RegExp(r'\[([^\]]*)\]');
    var last = 0;
    for (final m in pattern.allMatches(snippet)) {
      spans.add(TextSpan(text: snippet.substring(last, m.start)));
      spans.add(
        TextSpan(
          text: m.group(1),
          style: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.primary),
        ),
      );
      last = m.end;
    }
    spans.add(TextSpan(text: snippet.substring(last)));
    return Text.rich(TextSpan(children: spans));
  }
}
