/// Formulario cronológico estructurado de un devocional (alimenta la línea de tiempo).
class HistoricalContext {
  const HistoricalContext({this.periodId, this.empireId, this.regionId, this.author, this.approxYear});

  final String? periodId;
  final String? empireId;
  final String? regionId;
  final String? author;

  /// Año aproximado; negativo = a.C.
  final int? approxYear;

  bool get isEmpty =>
      periodId == null &&
      empireId == null &&
      regionId == null &&
      (author == null || author!.isEmpty) &&
      approxYear == null;

  HistoricalContext copyWith({
    String? Function()? periodId,
    String? Function()? empireId,
    String? Function()? regionId,
    String? Function()? author,
    int? Function()? approxYear,
  }) => HistoricalContext(
    periodId: periodId == null ? this.periodId : periodId(),
    empireId: empireId == null ? this.empireId : empireId(),
    regionId: regionId == null ? this.regionId : regionId(),
    author: author == null ? this.author : author(),
    approxYear: approxYear == null ? this.approxYear : approxYear(),
  );

  @override
  bool operator ==(Object other) =>
      other is HistoricalContext &&
      other.periodId == periodId &&
      other.empireId == empireId &&
      other.regionId == regionId &&
      other.author == author &&
      other.approxYear == approxYear;

  @override
  int get hashCode => Object.hash(periodId, empireId, regionId, author, approxYear);
}
