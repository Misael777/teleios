import 'package:intl/intl.dart';

abstract final class Formatters {
  static final _date = DateFormat("d 'de' MMMM 'de' y", 'es');
  static final _short = DateFormat('d MMM y', 'es');

  static String date(DateTime d) => _date.format(d);

  static String shortDate(DateTime d) => _short.format(d);

  /// -1446 → "1446 a.C." · 57 → "57 d.C."
  static String year(int year) => year < 0 ? '${-year} a.C.' : '$year d.C.';
}
