import 'package:calendarapp/homescreen/viewmodel/calendar_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/event.dart';
import '../utils/date_utils.dart';

class EventWidget extends StatelessWidget {
  const EventWidget({super.key, required this.event});
  final Event event;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.of(
          context,
        ).pushNamed('/update', arguments: event);
      },
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        clipBehavior: Clip.antiAlias,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 12.0,
                    height: 12.0,
                    decoration: BoxDecoration(
                      color: event.color,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 12.0),
                  Expanded(
                    child: Text(
                      event.title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),

                  const SizedBox(width: 16),

                  if (event.repeating)
                    Icon(
                      Icons.repeat,
                      size: 20,
                      color: Theme.of(context).colorScheme.outline,
                    ),

                  if (event.repeating && event.notifyMe)
                    const SizedBox(width: 8),

                  if (event.notifyMe)
                    Icon(
                      Icons.notifications_active,
                      size: 20,
                      color: Theme.of(context).colorScheme.outline,
                    ),

                  const SizedBox(width: 8),
                  IconButton(
                    icon: Icon(Icons.delete_outline),
                    iconSize: 20,
                    color: Theme.of(context).colorScheme.error,
                    tooltip: 'Delete Event',
                    onPressed: () async {
                      final bool? shouldDelete = await showDialog<bool>(
                        context: context,
                        builder: (BuildContext dialogContext) {
                          return AlertDialog(
                            title: const Text('Confirm Deletion'),
                            content: Text(
                                "Are you sure you want to delete the event '${event.title}'?"),
                            actions: <Widget>[
                              TextButton(
                                child: const Text('Cancel'),
                                onPressed: () {
                                  Navigator.of(dialogContext).pop(false);
                                },
                              ),
                              TextButton(
                                style: TextButton.styleFrom(
                                  foregroundColor: Theme.of(context).colorScheme.error,
                                ),
                                onPressed: () {
                                  Navigator.of(dialogContext).pop(true);
                                },
                                child: const Text('Delete'),
                              ),
                            ],
                          );
                        },
                      );

                      if (!context.mounted) return;
                      if (shouldDelete == true) {
                        final viewModel = context.read<CalendarViewmodel>();

                        viewModel.deleteEvent(event.id);
                      }
                    },
                  ),
                ],
              ),
              Text(
                event.description,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: Theme.of(context).colorScheme.outline,
                ),
                maxLines: 2,
              ),
              const SizedBox(width: 16),
              Row(
                children: [
                  Icon(
                    Icons.calendar_today_outlined,
                    size: 16,
                    color: Theme.of(context).colorScheme.outline,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    formatDateRange(event.startDate, event.endDate),
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ],
          )
        )
      ),
    );
  }
}