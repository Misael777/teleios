import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../../shared/domain/catalogs/bible_books.dart';
import '../../../shared/domain/entities/passage_ref.dart';
import '../../../shared/providers.dart';
import '../domain/repositories.dart';

/// Abre el selector de pasaje a pantalla completa. Devuelve null si se cancela.
Future<PassageRef?> showPassagePicker(BuildContext context, {PassageRef? initial}) => Navigator.of(
  context,
  rootNavigator: true,
).push<PassageRef>(MaterialPageRoute(fullscreenDialog: true, builder: (_) => PassagePickerScreen(initial: initial)));

class PassagePickerScreen extends ConsumerStatefulWidget {
  const PassagePickerScreen({super.key, this.initial});

  final PassageRef? initial;

  @override
  ConsumerState<PassagePickerScreen> createState() => _PassagePickerScreenState();
}

class _PassagePickerScreenState extends ConsumerState<PassagePickerScreen> {
  final _query = TextEditingController();
  BibleBook? _book;
  int? _chapter;
  int? _start;
  int? _end;

  @override
  void initState() {
    super.initState();
    final initial = widget.initial;
    if (initial != null) {
      _book = initial.book;
      _chapter = initial.chapter;
      _start = initial.verseStart;
      _end = initial.verseEnd;
    }
  }

  @override
  void dispose() {
    _query.dispose();
    super.dispose();
  }

  void _selectVerse(int verse) => setState(() {
    if (_start == null || _end != null || verse < _start!) {
      _start = verse;
      _end = null;
    } else if (verse == _start) {
      _start = null;
    } else {
      _end = verse;
    }
  });

  void _done() =>
      Navigator.pop(context, PassageRef(bookCode: _book!.code, chapter: _chapter!, verseStart: _start, verseEnd: _end));

  @override
  Widget build(BuildContext context) {
    final parsed = PassageRef.tryParse(_query.text);
    return Scaffold(
      appBar: AppBar(
        title: Text(_title),
        leading: _book == null
            ? const CloseButton()
            : BackButton(
                onPressed: () => setState(() {
                  if (_chapter != null) {
                    _chapter = _start = _end = null;
                  } else {
                    _book = null;
                  }
                }),
              ),
        actions: [
          if (_chapter != null)
            TextButton(onPressed: _done, child: Text(_start == null ? 'Usar capítulo' : 'Usar selección')),
        ],
      ),
      body: Column(
        children: [
          if (_book == null)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: TextField(
                controller: _query,
                autofocus: true,
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.search),
                  hintText: 'Cita (ej. Gá 5:22-23) o nombre del libro',
                ),
                onChanged: (_) => setState(() {}),
                onSubmitted: (_) {
                  if (parsed != null) Navigator.pop(context, parsed);
                },
              ),
            ),
          if (_book == null && parsed != null)
            ListTile(
              leading: const Icon(Icons.check_circle_outline),
              title: Text('Usar ${parsed.label}'),
              onTap: () => Navigator.pop(context, parsed),
            ),
          Expanded(
            child: switch ((_book, _chapter)) {
              (null, _) => _BookGrid(filter: _query.text, onSelected: (b) => setState(() => _book = b)),
              (final book?, null) => _ChapterGrid(book: book, onSelected: (c) => setState(() => _chapter = c)),
              (final book?, final chapter?) => _VerseSelector(
                book: book,
                chapter: chapter,
                start: _start,
                end: _end,
                onTap: _selectVerse,
              ),
            },
          ),
        ],
      ),
    );
  }

  String get _title {
    if (_book == null) return 'Elegir pasaje';
    if (_chapter == null) return _book!.name;
    final ref = PassageRef(bookCode: _book!.code, chapter: _chapter!, verseStart: _start, verseEnd: _end);
    return ref.label;
  }
}

class _BookGrid extends StatelessWidget {
  const _BookGrid({required this.filter, required this.onSelected});

  final String filter;
  final ValueChanged<BibleBook> onSelected;

  @override
  Widget build(BuildContext context) {
    final match = filter.trim().isEmpty ? null : BibleBooks.find(filter);
    final books = filter.trim().isEmpty || PassageRef.tryParse(filter) != null
        ? BibleBooks.all
        : BibleBooks.all
              .where((b) => b == match || b.name.toLowerCase().contains(filter.toLowerCase().trim()))
              .toList();
    Widget section(String title, Testament t) {
      final items = books.where((b) => b.testament == t).toList();
      if (items.isEmpty) return const SizedBox.shrink();
      return Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [for (final b in items) ActionChip(label: Text(b.name), onPressed: () => onSelected(b))],
            ),
          ],
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.only(bottom: 24),
      children: [section('Antiguo Testamento', Testament.antiguo), section('Nuevo Testamento', Testament.nuevo)],
    );
  }
}

class _ChapterGrid extends ConsumerWidget {
  const _ChapterGrid({required this.book, required this.onSelected});

  final BibleBook book;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context, WidgetRef ref) => FutureBuilder<int>(
    future: ref.read(bibleRepositoryProvider).chapterCount(book.code),
    builder: (context, snap) {
      if (!snap.hasData) return const Center(child: CircularProgressIndicator());
      return GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 64,
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
        ),
        itemCount: snap.data!,
        itemBuilder: (_, i) => OutlinedButton(
          style: OutlinedButton.styleFrom(padding: EdgeInsets.zero),
          onPressed: () => onSelected(i + 1),
          child: Text('${i + 1}'),
        ),
      );
    },
  );
}

class _VerseSelector extends ConsumerWidget {
  const _VerseSelector({
    required this.book,
    required this.chapter,
    required this.start,
    required this.end,
    required this.onTap,
  });

  final BibleBook book;
  final int chapter;
  final int? start;
  final int? end;
  final ValueChanged<int> onTap;

  bool _selected(int v) => start != null && v >= start! && v <= (end ?? start!);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    return FutureBuilder<List<BibleVerse>>(
      future: ref.read(bibleRepositoryProvider).chapter(book.code, chapter),
      builder: (context, snap) {
        if (!snap.hasData) return const Center(child: CircularProgressIndicator());
        final verses = snap.data!;
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              child: Text(
                'Toca el primer y el último versículo, o usa el capítulo completo.',
                style: theme.textTheme.bodySmall,
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: verses.length,
                itemBuilder: (_, i) {
                  final v = verses[i];
                  final selected = _selected(v.verse);
                  return ListTile(
                    dense: true,
                    selected: selected,
                    selectedTileColor: theme.colorScheme.primaryContainer.withValues(alpha: 0.4),
                    leading: Text('${v.verse}', style: theme.textTheme.labelLarge),
                    minLeadingWidth: 24,
                    title: Text(
                      v.text.isEmpty ? '(unido al versículo anterior en RV1909)' : v.text,
                      style: context.scripture.body.copyWith(fontSize: 17),
                    ),
                    onTap: () => onTap(v.verse),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}
