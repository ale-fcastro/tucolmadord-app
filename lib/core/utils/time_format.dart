/// Formatea horas sin depender de datos de locale de `intl` (que necesitan
/// inicialización aparte) — alcanza con un formato de 12 horas simple.
String timeLabel(DateTime dt) {
  final hour12 = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
  final minute = dt.minute.toString().padLeft(2, '0');
  final period = dt.hour < 12 ? 'AM' : 'PM';
  return '$hour12:$minute $period';
}

String relativeLabel(DateTime dt) {
  final diff = DateTime.now().difference(dt);
  if (diff.inMinutes < 1) return 'Ahora';
  if (diff.inMinutes < 60) return 'Hace ${diff.inMinutes} min';
  if (diff.inHours < 24) return 'Hace ${diff.inHours} h';
  return timeLabel(dt);
}

const _shortMonths = [
  'ene',
  'feb',
  'mar',
  'abr',
  'may',
  'jun',
  'jul',
  'ago',
  'sep',
  'oct',
  'nov',
  'dic',
];

/// "11 sep" — para encabezados de grupo en listas de historial.
String shortDateLabel(DateTime dt) => '${dt.day} ${_shortMonths[dt.month - 1]}';

/// "Hoy, 3:45 PM" / "Ayer, 3:45 PM" / "11 sep, 3:45 PM" — para filas de
/// historial donde solo la hora (timeLabel) no basta para saber cuándo fue.
String dateTimeLabel(DateTime dt) {
  final now = DateTime.now();
  bool sameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
  if (sameDay(dt, now)) return 'Hoy, ${timeLabel(dt)}';
  if (sameDay(dt, now.subtract(const Duration(days: 1))))
    return 'Ayer, ${timeLabel(dt)}';
  return '${shortDateLabel(dt)}, ${timeLabel(dt)}';
}
