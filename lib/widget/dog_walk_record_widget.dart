import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

class BuildRecordWidget extends StatelessWidget {
  final DateTime selectedDay;
  final Map<DateTime, List<String>> walkEvents;
  final Function(DateTime, DateTime) onDaySelected;

  const BuildRecordWidget({
    super.key,
    required this.selectedDay,
    required this.walkEvents,
    required this.onDaySelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TableCalendar(
          focusedDay: selectedDay,
          firstDay: DateTime(2020),
          lastDay: DateTime(2050),
          selectedDayPredicate: (day) => isSameDay(selectedDay, day),
          onDaySelected: onDaySelected,
          eventLoader: (day) {
            final normalizedDate = DateTime(day.year, day.month, day.day);
            return walkEvents[normalizedDate] ?? [];
          },
        ),
        Expanded(
          child: ListView(
            children: (walkEvents[selectedDay] ?? [])
                .map((event) => ListTile(title: Text(event)))
                .toList(),
          ),
        ),
      ],
    );
  }
}