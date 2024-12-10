import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

class BuildRecordWidget extends StatelessWidget {
  final DateTime selectedDay;
  final Map<DateTime, List<String>> walkEvents;
  final Function(DateTime, DateTime) onDaySelected;
  final Function(DateTime) onAddWalkRecord;

  const BuildRecordWidget({
    super.key,
    required this.selectedDay,
    required this.walkEvents,
    required this.onDaySelected,
    required this.onAddWalkRecord,
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
          headerStyle: const HeaderStyle(
            formatButtonVisible: false,
            titleCentered: true,
            titleTextStyle: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF5BDFE5),
            ),
          ),
          calendarStyle: CalendarStyle(
            selectedDecoration: BoxDecoration(
              border: Border.all(
                color: Colors.black,
                width: 1,
              ),
              shape: BoxShape.circle,
            ),
            selectedTextStyle: TextStyle(
              color: Colors.black,
            ),
            todayDecoration: BoxDecoration(
              border: Border.all(
                color: Colors.grey,
                width: 1,
              ),
              shape: BoxShape.circle,
            ),
            todayTextStyle: TextStyle(
              color: Colors.grey,
            ),
            markerDecoration: BoxDecoration(
              color: Color(0xFF5BDFE5),
              shape: BoxShape.circle,
            ),
          ),
          enabledDayPredicate: (day) {
            return day.isBefore(DateTime.now().add(Duration(days: 0)));
          },  // 오늘 이후에는 날짜 선택 비활성화 시키기
        ),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: InkWell(
            onTap: () {
              onAddWalkRecord(selectedDay);
            },
            child: ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: Image.asset(
                'asset/dog_walk_add.png',
                width: 150,
                height: 60,
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),
        Expanded(
          child: ListView(
            children: (walkEvents[selectedDay] ?? [])
                .map((event) => Card(
                      margin: const EdgeInsets.symmetric(
                          vertical: 8, horizontal: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      elevation: 3,
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(16),
                        title: Text(
                          event,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ))
                .toList(),
          ),
        ),
      ],
    );
  }
}
