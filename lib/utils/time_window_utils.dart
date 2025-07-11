class TimeWindow {
  final String label;
  final DateTime start;
  final DateTime end;

  TimeWindow(this.label, this.start, this.end);
}

List<TimeWindow> getTimeWindows(DateTime base) {
  return [
    TimeWindow(
      "9:00 - 9:15 AM",
      DateTime(base.year, base.month, base.day, 0, 0),
      DateTime(base.year, base.month, base.day, 9, 15),
    ),
    TimeWindow(
      "1:00 - 1:15 PM",
      DateTime(base.year, base.month, base.day, 13, 0),
      DateTime(base.year, base.month, base.day, 13, 15),
    ),
    // TimeWindow(
    //   "2:15 - 2:30 PM",
    //   DateTime(base.year, base.month, base.day, 14, 15),
    //   DateTime(base.year, base.month, base.day, 14, 30),
    // ),
        TimeWindow(
      "3:30 - 4:00 PM",
      DateTime(base.year, base.month, base.day, 15, 30),
      DateTime(base.year, base.month, base.day, 17, 00),
    ),
    TimeWindow(
      "6:00 - 6:15 PM",
      DateTime(base.year, base.month, base.day, 18, 0),
      DateTime(base.year, base.month, base.day, 18, 15),
    ),
  ];
}

TimeWindow? getCurrentAllowedWindow(DateTime now) {
  for (final window in getTimeWindows(now)) {
    if (now.isAfter(window.start) && now.isBefore(window.end)) {
      return window;
    }
  }
  return null;
}
