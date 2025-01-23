import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../widget/navigator.dart';
import 'health_hospital_screen/helath_hospital_page.dart';
import 'health_memo_screen/health_memo_page.dart';

class DogHealthPage extends ConsumerStatefulWidget {
  const DogHealthPage({super.key});

  @override
  ConsumerState<DogHealthPage> createState() => DogHealthPageState();
}

class DogHealthPageState extends ConsumerState<DogHealthPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final Completer<NaverMapController> mapControllerCompleter = Completer();
  double? latitude;
  double? longitude;



  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(currentIndexProvider.notifier).state = 1;
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
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
            indicatorColor: Colors.black,
            labelColor: Colors.black,
            controller: _tabController,
            unselectedLabelColor: Colors.grey[400],
            tabs: const [
              Tab(icon: Icon(Icons.note), text: '건강 기록'),
              Tab(icon: Icon(Icons.map), text: '동물 병원 찾기'),
            ],
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          HealthRecordWidget(

          ),
          HospitalMap(),
        ],
      ),
      bottomNavigationBar: CustomBottomNavBar(),
    );
  }
}
