import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
    fetchWalkDataFromFirestore(); // Firestore 데이터 가져오기
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> fetchWalkDataFromFirestore() async {
    try {
      // 현재 사용자 UID 가져오기
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception("로그인된 사용자가 없습니다.");
      }
      final uid = user.uid;

      // Firestore 참조 가져오기
      final firestore = FirebaseFirestore.instance;
      final userDoc = await firestore.collection('dogs').doc(uid).get();

      if (userDoc.exists) {
        final data = userDoc.data();

        // Firestore에서 walkStats 가져오기
        final Map<DateTime, Duration> fetchedWalkStats = {};
        if (data?['walkStats'] != null) {
          (data!['walkStats'] as Map<String, dynamic>).forEach((key, value) {
            fetchedWalkStats[DateTime.parse(key)] =
                Duration(seconds: value as int);
          });
        }

        // Firestore에서 walkEvents 가져오기
        final Map<DateTime, List<String>> fetchedWalkEvents = {};
        if (data?['walkEvents'] != null) {
          (data!['walkEvents'] as Map<String, dynamic>).forEach((key, value) {
            fetchedWalkEvents[DateTime.parse(key)] =
                List<String>.from(value as List);
          });
        }

        // 상태 업데이트
        setState(() {
          _walkStats.clear();
          _walkStats.addAll(fetchedWalkStats);
          _walkEvents.clear();
          _walkEvents.addAll(fetchedWalkEvents);
        });
      }
    } catch (e) {
      print("Firestore 데이터 가져오기 중 오류 발생: $e");
    }
  }

  Future<void> updateWalkDataToFirestore(
    Map<DateTime, Duration> walkStats,
    Map<DateTime, List<String>> walkEvents,
  ) async {
    try {
      // 현재 사용자 UID 가져오기
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception("로그인된 사용자가 없습니다.");
      }
      final uid = user.uid;

      // Firestore 참조 가져오기
      final firestore = FirebaseFirestore.instance;
      final userDocRef = firestore.collection('dogs').doc(uid);

      // 날짜를 String 형식으로 변환
      Map<String, int> walkStatsForFirestore = {};
      walkStats.forEach((date, duration) {
        walkStatsForFirestore[date.toIso8601String()] =
            duration.inSeconds; // 초 단위로 저장
      });

      Map<String, List<String>> walkEventsForFirestore = {};
      walkEvents.forEach((date, events) {
        walkEventsForFirestore[date.toIso8601String()] = events;
      });

      // Firestore 업데이트
      await userDocRef.set(
        {
          'walkStats': walkStatsForFirestore,
          'walkEvents': walkEventsForFirestore,
        },
        SetOptions(merge: true), // 기존 데이터에 병합
      );

      print("산책 데이터가 Firestore에 성공적으로 업데이트되었습니다!");
    } catch (e) {
      print("Firestore 업데이트 중 오류 발생: $e");
    }
  }

  void _addWalkRecord(DateTime date) {
    setState(() {
      final normalizedDate = DateTime(date.year, date.month, date.day);
      if (_walkEvents[normalizedDate] == null) {
        _walkEvents[normalizedDate] = ['산책 1회'];
      } else {
        _walkEvents[normalizedDate]!
            .add('산책 ${_walkEvents[normalizedDate]!.length + 1}회');
      }
    });

    // Firestore 업데이트 호출
    updateWalkDataToFirestore(_walkStats, _walkEvents);
  }

  void _addWalktime(Duration duration) {
    final currentDate = DateTime.now();
    final normalizedDate =
        DateTime(currentDate.year, currentDate.month, currentDate.day);

    setState(() {
      if (_walkStats[normalizedDate] == null) {
        _walkStats[normalizedDate] = duration;
      } else {
        _walkStats[normalizedDate] = _walkStats[normalizedDate]! + duration;
      }
      _addWalkRecord(normalizedDate); // 해당 날짜의 산책 횟수 증가
    });

    // Firestore 업데이트 후 데이터 가져오기
    updateWalkDataToFirestore(_walkStats, _walkEvents).then((_) {
      fetchWalkDataFromFirestore();
    });
  }

  @override
  Widget build(BuildContext context) {
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
        body: RefreshIndicator(
          onRefresh: fetchWalkDataFromFirestore,
          child: TabBarView(
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
        bottomNavigationBar: CustomBottomNavBar(
            currentIndex: _currentIndex,
            onTap: (index) {
              setState(() {
                _currentIndex = index;
              });
            }));
  }
}
