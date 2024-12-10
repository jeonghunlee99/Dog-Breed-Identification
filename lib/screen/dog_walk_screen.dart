import 'package:flutter/material.dart';
import '../widget/dog_walk_record_widget.dart';
import '../widget/dog_walk_stats_widget.dart';
import '../widget/dog_walk_timer_widget.dart';


class DogWalkPage extends StatefulWidget {
  const DogWalkPage({super.key});

  @override
  State<DogWalkPage> createState() => _DogWalkPageState();
}

class _DogWalkPageState extends State<DogWalkPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final Map<DateTime, List<String>> _walkEvents = {};
  final Map<DateTime, int> _walkStats = {};

  DateTime _selectedDay = DateTime.now();


  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _addWalkRecord(DateTime date) {
    // 시간 부분을 00:00:00으로 설정하여 날짜만 비교하도록 함
    final normalizedDate = DateTime(date.year, date.month, date.day);

    setState(() {
      // 이미 기록이 존재하면 새로운 기록을 추가하지 않음
      if (_walkEvents[normalizedDate] == null) {
        _walkEvents[normalizedDate] = [];
      }

      // 이벤트 기록 추가
      if (!_walkEvents[normalizedDate]!.contains("산책 기록")) {
        _walkEvents[normalizedDate]!.add("산책 기록");
      }

      // 통계 값 누적 (산책 횟수)
      _walkStats[normalizedDate] = (_walkStats[normalizedDate] ?? 0) + 1;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('강아지 산책'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.calendar_today), text: '기록'),
            Tab(icon: Icon(Icons.bar_chart), text: '통계'),
            Tab(icon: Icon(Icons.timer), text: '타이머'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          BuildRecordWidget(
            selectedDay: _selectedDay,
            walkEvents: _walkEvents,
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;

              });
            },
          ),
          StatsWidget(walkStats: _walkStats),
          TimerWidget(onWalkComplete: _addWalkRecord),
        ],
      ),
    );
  }


}