import 'dart:ui';

import 'package:intl/intl.dart';

class CalendarDay {
  final DateTime date;
  final bool isCurrentMonth;
  final Color? eventColor;

  CalendarDay({required this.date, required this.isCurrentMonth, this.eventColor});
}

List<List<CalendarDay>> generateDaysForMonth(DateTime date) {
  DateTime firstDayOfMonth = DateTime(date.year, date.month, 1);
  int firstWeekday = firstDayOfMonth.weekday;

  int daysInMonth = DateTime(date.year, date.month + 1, 0).day;

  int daysInPrevMonth = DateTime(date.year, date.month, 0).day;

  List<List<CalendarDay>> daysOfMonth = [];
  List<CalendarDay> currentWeek = [];

  for (int i = firstWeekday - 1; i > 0; i--) {
    currentWeek.add(CalendarDay(date: DateTime(date.year, date.month - 1, daysInPrevMonth - i + 1), isCurrentMonth: false));
  }

  for (int i = 1; i <= daysInMonth; i++) {
    currentWeek.add(CalendarDay(date: DateTime(date.year, date.month, i), isCurrentMonth: true));

    if (currentWeek.length == 7) {
      daysOfMonth.add(currentWeek);
      currentWeek = [];
    }
  }

  if (currentWeek.isNotEmpty) {
    int nextMonthDay = 1;
    while (currentWeek.length < 7) {
      currentWeek.add(CalendarDay(date: DateTime(date.year, date.month + 1, nextMonthDay), isCurrentMonth: false));
      nextMonthDay++;
    }
    daysOfMonth.add(currentWeek);
  }

  return daysOfMonth;
}

String getMonthByIndex(int index) {
  if (index == 1) return "January";
  if (index == 2) return "February";
  if (index == 3) return "March";
  if (index == 4) return "April";
  if (index == 5) return "May";
  if (index == 6) return "June";
  if (index == 7) return "July";
  if (index == 8) return "August";
  if (index == 9) return "September";
  if (index == 10) return "October";
  if (index == 11) return "November";
  if (index == 12) return "December";
  throw Exception("Invalid month index");
}

String formatDateRange(DateTime start, DateTime end) {
  if (start.year == end.year && start.month == end.month && start.day == end.day) {
    final dayFormat = DateFormat('MMM d, y');
    final timeFormat = DateFormat.jm(); // Localized time like '10:00 AM'
    return '${dayFormat.format(start)}, ${timeFormat.format(start)} - ${timeFormat.format(end)}';
  } else {
    final dateFormat = DateFormat('MMM d');
    if (start.year == end.year) {
      return '${dateFormat.format(start)} - ${dateFormat.format(end)}, ${start.year}';
    } else {
      final yearFormat = DateFormat('MMM d, y');
      return '${yearFormat.format(start)} - ${yearFormat.format(end)}';
    }
  }
}

