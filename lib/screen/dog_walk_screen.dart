import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'data/dog_walk_data.dart';
import '../widget/dog_walk_record_widget.dart';
import '../widget/dog_walk_stats_widget.dart';
import '../widget/dog_walk_timer_widget.dart';
import '../widget/navigator.dart';


class DogWalkPage extends ConsumerStatefulWidget {
  const DogWalkPage({super.key});

  @override
  ConsumerState<DogWalkPage> createState() => _DogWalkPageState();
}

class _DogWalkPageState extends ConsumerState<DogWalkPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    ref.read(walkStatsProvider.notifier).fetchWalkStats();
    ref.read(walkEventsProvider.notifier).fetchWalkEvents();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final walkStats = ref.watch(walkStatsProvider);
    final walkEvents = ref.watch(walkEventsProvider);
    final selectedDay = ref.watch(selectedDayProvider);

    return Scaffold(
      backgroundColor: Colors.white,
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
      body: TabBarView(
        controller: _tabController,
        children: [
          BuildRecordWidget(
            selectedDay: selectedDay,
            walkEvents: walkEvents,
            onDaySelected: (selectedDay, focusedDay) {
              ref.read(selectedDayProvider.notifier).state = selectedDay;
            },
            onAddWalkRecord: (date) =>
                ref.read(walkEventsProvider.notifier).addWalkRecord(date),
          ),
          StatsWidget(
            walkStats: walkStats,
            walkEvents: walkEvents,
          ),
          TimerWidget(
            onWalkComplete: (duration) => ref
                .read(walkStatsProvider.notifier)
                .addWalkTime(DateTime.now(), duration),
          ),
        ],
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
