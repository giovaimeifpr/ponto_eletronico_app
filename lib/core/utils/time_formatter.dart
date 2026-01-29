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

  // Verifica se uma data ISO pertence ao mesmo dia, mês e ano de outra data
  static bool isSameDay(String? isoDate, DateTime comparison) {
    if (isoDate == null) return false;
    DateTime date = DateTime.parse(isoDate).toLocal();
    return date.year == comparison.year &&
        date.month == comparison.month &&
        date.day == comparison.day;
  }

  // Retorna o início da semana (segunda-feira) a partir de uma data
  static DateTime getStartOfWeek(DateTime date) {
    return DateTime(
      date.year,
      date.month,
      date.day,
    ).subtract(Duration(days: date.weekday - 1));
  }

  static DateTime get dateNow => DateTime.now();

  static DateTime get todayMidNight =>
      DateTime(dateNow.year, dateNow.month, dateNow.day);

  static DateTime get beginOfWeek {
    final agora = DateTime.now();
    // Zera as horas para garantir que pega desde o primeiro segundo da segunda-feira
    return DateTime(
      agora.year,
      agora.month,
      agora.day,
    ).subtract(Duration(days: agora.weekday - 1));
  }

  static DateTime get endOfWeek {
    final inicio = beginOfWeek;
    // Vai até o último segundo do domingo
    return DateTime(inicio.year, inicio.month, inicio.day + 6, 23, 59, 59);
  }

  // Útil para o saldo do mês anterior que você usa no loadHistory
  static DateTime get beginningOfPreviousMonth {
    return DateTime(dateNow.year, dateNow.month - 1, 1);
  }

  static DateTime get beginningOfNextMonth {
    return DateTime(dateNow.year, dateNow.month + 1, 1);
  }
}
