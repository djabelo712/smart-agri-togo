import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';

DateFormat? _dateFormatFr;
DateFormat? _timeFormatFr;
DateFormat? _shortDateFr;

/// À appeler dans [main] avant [runApp].
Future<void> initializeFrenchLocale() async {
  await initializeDateFormatting('fr_FR');
  Intl.defaultLocale = 'fr_FR';
  _dateFormatFr = DateFormat('EEEE d MMMM', 'fr_FR');
  _timeFormatFr = DateFormat('HH:mm', 'fr_FR');
  _shortDateFr = DateFormat('d MMM', 'fr_FR');
}

/// Date du jour formatée pour l'AppBar (ex. « jeudi 21 mai »).
String formatDashboardDate(DateTime date) {
  final fmt = _dateFormatFr ?? DateFormat('EEEE d MMMM');
  final formatted = fmt.format(date);
  if (formatted.isEmpty) return '';
  return formatted[0].toUpperCase() + formatted.substring(1);
}

String formatTime(DateTime date) =>
    (_timeFormatFr ?? DateFormat('HH:mm')).format(date);

String formatShortDate(DateTime date) =>
    (_shortDateFr ?? DateFormat('d MMM')).format(date);

/// Durée relative en français (ex. « il y a 3 h »).
String formatRelativeDuration(Duration diff) {
  if (diff.inDays >= 1) {
    final d = diff.inDays;
    return 'il y a $d jour${d > 1 ? 's' : ''}';
  }
  if (diff.inHours >= 1) {
    final h = diff.inHours;
    final m = diff.inMinutes % 60;
    if (m > 0) return 'il y a ${h}h${m.toString().padLeft(2, '0')}';
    return 'il y a $h h';
  }
  if (diff.inMinutes >= 1) {
    return 'il y a ${diff.inMinutes} min';
  }
  return 'à l\'instant';
}

/// Jours abrégés français pour graphiques (L M M J V S D).
const List<String> weekDayLabelsShort = ['L', 'M', 'M', 'J', 'V', 'S', 'D'];

const List<String> weekDayLabelsFull = [
  'Lu',
  'Ma',
  'Me',
  'Je',
  'Ve',
  'Sa',
  'Di',
];
