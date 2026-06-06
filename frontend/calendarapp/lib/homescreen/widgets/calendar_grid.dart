import 'package:flutter/material.dart';

import '../utils/date_utils.dart';

class CalendarGrid extends StatelessWidget {
  const CalendarGrid({
    super.key,
    required this.days,
    required this.selectedDate,
    required this.onDateSelected,
    required this.getColorForDay
  });
  final List<List<CalendarDay>> days;
  final DateTime selectedDate;
  final Function(DateTime) onDateSelected;
  final Color? Function(DateTime) getColorForDay;

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  @override
  Widget build(BuildContext context) {
    final primaryTextColor = Theme.of(context).colorScheme.onSurface;
    final dimmedTextColor = Theme.of(context).colorScheme.outline;
    final highlightColor = Theme.of(context).colorScheme.primaryContainer;
    final onHighlightColor = Theme.of(context).colorScheme.onPrimaryContainer;

    return
      Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            _buildDayNamesRow(context),
            ...days.map((week)  {
              return Row(
                children: week.map((day)  {
                  final isSelected = _isSameDay(day.date, selectedDate);
                  final Color? eventColor = getColorForDay(day.date);

                  return Expanded(
                    child: InkWell(
                      onTap: () => onDateSelected(day.date),
                      customBorder: const CircleBorder(),
                      child: Container(
                        height: 60,
                        decoration: BoxDecoration(
                          color: isSelected ? highlightColor : null,
                          border: Border.all(
                            color: Theme.of(context).colorScheme.outline,
                            width: 0.5,
                          ),
                        ),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Text(
                              day.date.day.toString(),
                              style: TextStyle(
                                color: isSelected
                                    ? onHighlightColor
                                    : day.isCurrentMonth
                                    ? primaryTextColor
                                    : dimmedTextColor,
                                fontSize: Theme.of(context)
                                    .textTheme
                                    .headlineSmall
                                    ?.fontSize,
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                              ),
                            ),

                            if (eventColor != null)
                              Positioned(
                                top: 5,
                                right: 5,
                                child: Container(
                                  width: 6,
                                  height: 6,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: eventColor,
                                  ),
                                ),
                              ),
                          ],
                        )
                      )
                    )
                  );
                }).toList(),
              );
            }).toList(),
          ]
        )
      );
  }

  Widget _buildDayNamesRow(BuildContext context) {
    final dayNames = ['Mon', 'Tue', 'Wen', 'Thu', 'Fri', 'Sat', 'Sun'];

    return Row(
      children: dayNames.map((name) {
        return Expanded(
          child: Center(
            child: Text(
              name,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.outline,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}