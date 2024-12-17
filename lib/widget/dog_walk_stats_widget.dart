import 'package:flutter/material.dart';

class StatsWidget extends StatelessWidget {
  final Map<DateTime, Duration> walkStats; // 시간 기록
  final Map<DateTime, List<String>> walkEvents; // 일반 기록

  const StatsWidget({
    super.key,
    required this.walkStats,
    required this.walkEvents,
  });

  @override
  Widget build(BuildContext context) {
    // 날짜 기준으로 walkStats와 walkEvents를 통합
    final combinedEntries = <DateTime, Map<String, dynamic>>{};

    // walkStats에 시간 데이터 추가
    walkStats.forEach((date, duration) {
      combinedEntries[date] = {"duration": duration, "events": []};
    });

    // walkEvents에 일반 기록 추가
    walkEvents.forEach((date, events) {
      if (combinedEntries[date] != null) {
        combinedEntries[date]!["events"] = events;
      } else {
        combinedEntries[date] = {"duration": null, "events": events};
      }
    });

    // 날짜를 정렬해서 리스트화
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