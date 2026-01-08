import 'package:intl/intl.dart';

class TimeFormatter {
  // Transforma o timestamp do banco em "HH:mm"
  static String formatTimestamp(String? isoDate) {
    if (isoDate == null) return "--:--";
    DateTime date = DateTime.parse(isoDate).toLocal();
    return DateFormat('HH:mm').format(date);
  }

  // Calcula a diferença entre dois registros
  static double calculateDuration(String? startIso, String? endIso) {
    if (startIso == null || endIso == null) return 0;
    DateTime start = DateTime.parse(startIso);
    DateTime end = DateTime.parse(endIso);
    return end.difference(start).inMinutes / 60;
  }
}