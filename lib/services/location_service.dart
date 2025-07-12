bool shouldEnforceTrackingNow(bool userDisabledToday) {
  final now = DateTime.now();
  final isSunday = now.weekday == DateTime.sunday;

  if (isSunday || userDisabledToday) return false;

  // final start = DateTime(now.year, now.month, now.day, 8, 45);
  // 9, 15
  // final end = DateTime(now.year, now.month, now.day, 18, 45);

  final start = DateTime(now.year, now.month, now.day, 8, 45);
  final end = DateTime(now.year, now.month, now.day, 18, 16);

  return now.isAfter(start) && now.isBefore(end);
}
