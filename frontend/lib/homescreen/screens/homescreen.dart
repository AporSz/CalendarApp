import 'package:calendarapp/homescreen/viewmodel/calendar_viewmodel.dart';
import 'package:calendarapp/homescreen/widgets/calendar_widget.dart';
import 'package:calendarapp/homescreen/widgets/event_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Homescreen extends StatelessWidget{
  const Homescreen({super.key});

  @override
  Widget build(BuildContext context) {
    final calendarViewModel = context.watch<CalendarViewmodel>();
    final selectedDayEvents = calendarViewModel.getEventsForSelected();

    return Scaffold(
      body: Column(
        children: [
          SizedBox(
            height: MediaQuery
              .of(context)
              .size
              .height * 0.5,
            child: GestureDetector(
              onHorizontalDragEnd: (details) {
                final viewModel = context.read<CalendarViewmodel>();

                if (details.primaryVelocity! > 0) {
                  viewModel.goToPreviousMonth();
                } else if (details.primaryVelocity! < 0) {
                  viewModel.goToNextMonth();
                }
              },
              child: CalendarWidget(days: calendarViewModel.daysInMonth,
                month: calendarViewModel.monthYearString,),
            ),
          ),
          Expanded(
            child: calendarViewModel.isLoading
                ? const Center(
              // Show this while loading
              child: CircularProgressIndicator(),
            )
                : selectedDayEvents.isEmpty
                ? const Center(
              // Optional: Show this if no events found
              child: Text("No events for this day"),
            )
                : ListView.builder(
              // Show this when data is ready
              itemCount: selectedDayEvents.length,
              itemBuilder: (context, index) {
                final event = selectedDayEvents[index];
                return EventWidget(event: event);
              },
            ),
          ),
        ]
      )
    );
  }
}