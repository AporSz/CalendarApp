import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../utils/date_utils.dart';
import '../viewmodel/calendar_viewmodel.dart';
import 'calendar_grid.dart';

class CalendarWidget extends StatelessWidget {
  const CalendarWidget({super.key, required this.days, required this.month});
  final List<List<CalendarDay>> days;
  final String month;

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<CalendarViewmodel>();

    return
      Column(
        children: [
          const SizedBox(height: 40),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Stack(
              children: [
                Align(
                  alignment: Alignment.center,
                  child: TextButton(
                      onPressed: () {
                        final viewModel = context.read<CalendarViewmodel>();
                        viewModel.goToToday();
                      },
                      child: Text(month,
                          style: Theme.of(context).textTheme.headlineLarge)),
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: IconButton(
                  iconSize: 40.0,
                  icon: const Icon(Icons.add),
                  onPressed: () {
                    Navigator.of(
                      context,
                      ).pushNamed('/add', arguments: viewModel.selectedDate);
                    },
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: CalendarGrid(
              days: days,
              selectedDate: viewModel.selectedDate,
              onDateSelected: context.read<CalendarViewmodel>().dateSelected,
              getColorForDay: context.read<CalendarViewmodel>().getColorForDay,
            ),
          )
        ],
      );
  }
}