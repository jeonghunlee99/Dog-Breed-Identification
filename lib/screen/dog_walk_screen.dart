import 'package:flutter/material.dart';
import '../widget/dog_walk_record_widget.dart';
import '../widget/dog_walk_stats_widget.dart';
import '../widget/dog_walk_timer_widget.dart';
import '../widget/navigator.dart';

class DogWalkPage extends StatefulWidget {
  const DogWalkPage({super.key});

  @override
  State<DogWalkPage> createState() => _DogWalkPageState();
}

class _DogWalkPageState extends State<DogWalkPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final Map<DateTime, List<String>> _walkEvents = {};
  final Map<DateTime, Duration> _walkStats = {};
  DateTime _selectedDay = DateTime.now();
  int _currentIndex = 0;

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
    final normalizedDate = DateTime(date.year, date.month, date.day);

    setState(() {
      if (_walkEvents[normalizedDate] == null) {
        _walkEvents[normalizedDate] = [];
      }

      int currentRecordNumber = _walkEvents[normalizedDate]!.isEmpty
          ? 1
          : int.parse(_walkEvents[normalizedDate]!.last.split(' ').last) + 1;

      _walkEvents[normalizedDate] = ["산책 횟수 : $currentRecordNumber"];
    });
  }

  void _addWalktime(Duration duration) {
    final normalizedDate = DateTime(
      DateTime.now().year,
      DateTime.now().month,
      DateTime.now().day,
    );

    setState(() {
      if (_walkStats[normalizedDate] == null) {
        _walkStats[normalizedDate] = duration;
      } else {
        _walkStats[normalizedDate] = _walkStats[normalizedDate]! + duration;
      }

      if (_walkEvents[normalizedDate] == null) {
        _walkEvents[normalizedDate] = [];
      }

      int currentRecordNumber = _walkEvents[normalizedDate]!.isEmpty
          ? 1
          : int.parse(_walkEvents[normalizedDate]!.last.split(' ').last) + 1;

      _walkEvents[normalizedDate] = ["산책 횟수 : $currentRecordNumber"];
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(74),
        child: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: Colors.white,
          elevation: 0,
          bottom: TabBar(
            controller: _tabController,
            indicatorColor: Colors.black,
            labelColor: Colors.black,
            unselectedLabelColor: Colors.grey[400],
            tabs: const [
              Tab(icon: Icon(Icons.calendar_today), text: '기록'),
              Tab(icon: Icon(Icons.bar_chart), text: '통계'),
              Tab(icon: Icon(Icons.timer), text: '타이머'),
            ],
          ),
        ),
      ),
      body: Container(
        margin: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              spreadRadius: 5,
              blurRadius: 15,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  // 산책 기록 페이지
                  BuildRecordWidget(
                    selectedDay: _selectedDay,
                    walkEvents: _walkEvents,
                    onDaySelected: (selectedDay, focusedDay) {
                      setState(() {
                        _selectedDay = selectedDay;
                      });
                    },
                    onAddWalkRecord: _addWalkRecord,
                  ),
                  StatsWidget(
                    walkStats: _walkStats,
                    walkEvents: _walkEvents,
                  ),
                  TimerWidget(onWalkComplete: _addWalktime),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }
}
