import '../../../shared/domain/catalogs/bible_books.dart';
import '../../../shared/domain/catalogs/historical_catalog.dart';
import '../../../shared/domain/entities/passage_ref.dart';
import 'devotional.dart';
import 'guided_reflection.dart';

/// Un hilo de la red: el devocional [source] citó [target] con `{…}` en la sección [section]
/// de su reflexión (`null`: notas libres).
class PassageLink {
  const PassageLink(this.source, this.target, this.section);

  final DevotionalEntry source;
  final PassageRef target;
  final ReflectionSection? section;

  String? get sectionId => section?.id;
}

/// Un versículo citado desde uno o más devocionales: un nodo del riel de pasajes vinculados.
class LinkedPassage {
  const LinkedPassage(this.ref, this.links);

  final PassageRef ref;
  final List<PassageLink> links;

  String get key => ref.encode();

  /// Devocionales distintos que lo citan.
  Set<String> get sourceIds => {for (final l in links) l.source.id};

  /// Sección desde la que más se citó (desempate: el orden de la guía).
  String? get dominantSectionId {
    final counts = <String?, int>{};
    for (final l in links) {
      counts[l.sectionId] = (counts[l.sectionId] ?? 0) + 1;
    }
    return counts.entries.reduce((a, b) => b.value > a.value ? b : a).key;
  }
}

/// La red de interconexión de pasajes que el usuario va tejiendo al vincular versículos.
class PassageNetwork {
  PassageNetwork._(this.links, this.passages);

  factory PassageNetwork.build(Iterable<DevotionalEntry> entries) {
    final links = <PassageLink>[
      for (final e in entries)
        for (final c in GuidedReflection.parse(e.content).citations) PassageLink(e, c.ref, c.section),
    ];
    final byKey = <String, List<PassageLink>>{};
    for (final l in links) {
      byKey.putIfAbsent(l.target.encode(), () => []).add(l);
    }
    final passages = [for (final group in byKey.values) LinkedPassage(group.first.target, group)]
      ..sort((a, b) => b.links.length.compareTo(a.links.length));
    return PassageNetwork._(links, passages);
  }

  final List<PassageLink> links;

  /// Versículos citados, del más citado al menos citado.
  final List<LinkedPassage> passages;

  bool get isEmpty => links.isEmpty;

  LinkedPassage? passage(String key) => passages.where((p) => p.key == key).firstOrNull;

  List<PassageLink> linksFrom(String devotionalId) => [
    for (final l in links)
      if (l.source.id == devotionalId) l,
  ];

  /// sectionId (null: notas) → cantidad de hilos.
  Map<String?, int> get countBySection {
    final counts = <String?, int>{};
    for (final l in links) {
      counts[l.sectionId] = (counts[l.sectionId] ?? 0) + 1;
    }
    return counts;
  }

  /// Año aproximado para ubicar un pasaje en la línea de tiempo: la época del libro (o del capítulo,
  /// en Génesis 1-11), repartiendo los libros de una misma época en orden canónico dentro de ella.
  static int yearOf(PassageRef ref) {
    final byChapter = HistoricalCatalog.periodForChapter(ref.bookCode, ref.chapter);
    final period = HistoricalCatalog.period(byChapter ?? ref.book.periodId) ?? HistoricalCatalog.periods.last;
    var fraction = 0.5;
    if (byChapter == null) {
      final peers = [
        for (final b in BibleBooks.all)
          if (b.periodId == period.id) b.code,
      ];
      final rank = peers.indexOf(ref.bookCode);
      if (rank >= 0) fraction = (rank + 0.5) / peers.length;
    }
    return period.startYear + ((period.endYear - period.startYear) * fraction).floor();
  }

  /// Devocionales que estudiaron ese mismo capítulo: el vínculo une dos estudios tuyos.
  static List<DevotionalEntry> studying(Iterable<DevotionalEntry> entries, PassageRef ref) => [
    for (final e in entries)
      if (e.passage.bookCode == ref.bookCode && e.passage.chapter == ref.chapter) e,
  ];
}
