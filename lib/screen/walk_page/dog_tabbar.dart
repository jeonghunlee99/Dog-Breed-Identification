import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_calendar/table_calendar.dart';
import 'dog_walk_controller.dart';
import 'dog_walk_data.dart';

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
          }, // 오늘 이후에는 날짜 선택 비활성화 시키기
        ),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: InkWell(
            onTap: () {
              LoginStatus.checkLoginStatus(
                context,
                    () => onAddWalkRecord(selectedDay),  // 로그인된 경우 산책 기록 추가
              );
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

class StatsWidget extends StatelessWidget {
  final Map<DateTime, Duration> walkStats;
  final Map<DateTime, List<String>> walkEvents;

  const StatsWidget({
    super.key,
    required this.walkStats,
    required this.walkEvents,
  });

  @override
  Widget build(BuildContext context) {
    final combinedEntries = <DateTime, Map<String, dynamic>>{};
    walkStats.forEach((date, duration) {
      combinedEntries[date] = {"duration": duration, "events": []};
    });
    walkEvents.forEach((date, events) {
      if (combinedEntries[date] != null) {
        combinedEntries[date]!["events"] = events;
      } else {
        combinedEntries[date] = {"duration": null, "events": events};
      }
    });
    final sortedEntries = combinedEntries.entries.toList()
      ..sort((a, b) => b.key.compareTo(a.key)); // 최신 날짜가 위에 오도록 정렬

    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: sortedEntries.length,
      itemBuilder: (context, index) {
        final entry = sortedEntries[index];
        final date = entry.key;
        final duration = entry.value["duration"] as Duration?;
        final events = entry.value["events"] as List<String>;

        return Card(
          margin: const EdgeInsets.symmetric(vertical: 8.0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          elevation: 3,
          child: ListTile(
            title: Text(
              "${date.toLocal()}".split(' ')[0], // 날짜 표시
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (duration != null) // 시간 기록이 있을 경우
                  Text(
                    "산책 시간: ${duration.inMinutes}분 ${duration.inSeconds % 60}초",
                    style: const TextStyle(fontSize: 14, color: Colors.blue),
                  ),
                if (events.isNotEmpty) // 일반 기록이 있을 경우
                  ...events.map((event) => Text(
                    event,
                    style: const TextStyle(fontSize: 14),
                  )),
              ],
            ),
          ),
        );
      },
    );
  }
}

class TimerWidget extends ConsumerWidget {
  final void Function(Duration duration) onWalkComplete;

  const TimerWidget({super.key, required this.onWalkComplete});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final duration = ref.watch(durationProvider);
    final isRunning = ref.watch(isRunningProvider);
    final isWalkCompleted = ref.watch(isWalkCompletedProvider);

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "산책 시간: ${duration.inMinutes}:${(duration.inSeconds % 60).toString().padLeft(2, '0')}",
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.brown[400],
              ),
              onPressed: isRunning
                  ? () => TimerController.stopTimer(ref)
                  : () => TimerController.startTimer(context, ref),
              child: Text(
                isRunning ? '중지' : '시작',
                style: const TextStyle(color: Colors.white),
              ),
            ),
            const SizedBox(width: 16),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.brown[400],
              ),
              onPressed: () => TimerController.resetTimer(context, ref),
              child: const Text(
                '초기화',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: isWalkCompleted ? Colors.green : Colors.grey,
          ),
          onPressed: isRunning
              ? null
              : (isWalkCompleted
              ? () =>
              TimerController.completeWalk(context, ref, onWalkComplete)
              : null),
          child: Text(
            isWalkCompleted ? '산책 완료' : '산책 완료',
            style: const TextStyle(color: Colors.white),
          ),
        ),
      ],
    );
  }
}
