import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; // FirebaseAuth 사용
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

  // 커스텀 스낵바를 보여주는 함수
  void _showCustomSnackBar(BuildContext context, String message, Color backgroundColor) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              backgroundColor == Colors.green ? Icons.check_circle : Icons.error,
              color: Colors.white,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
        backgroundColor: backgroundColor,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.only(bottom: 50, left: 20, right: 20),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        duration: const Duration(seconds: 3), // 표시 시간
      ),
    );
  }

  // FirebaseAuth 인스턴스를 사용하여 로그인 상태 확인
  void _checkLoginStatus(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      // 로그인이 안 되어 있으면 커스텀 SnackBar로 메시지 표시
      _showCustomSnackBar(
        context,
        '로그인 후 산책 기록을 추가할 수 있습니다.',
        Colors.red,
      );
    } else {
      // 로그인 되어 있으면 산책 기록 추가 함수 호출
      onAddWalkRecord(selectedDay);
    }
  }

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
              _checkLoginStatus(context); // 로그인 상태 확인 후 처리
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
