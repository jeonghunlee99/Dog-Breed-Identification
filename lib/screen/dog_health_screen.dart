import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:geolocator/geolocator.dart';
import '../widget/dog_health_hospital_map.dart';
import '../widget/dog_health_record.dart';
import '../widget/navigator.dart';

class DogHealthPage extends StatefulWidget {
  const DogHealthPage({super.key});

  @override
  State<DogHealthPage> createState() => _DogHealthPageState();
}

class _DogHealthPageState extends State<DogHealthPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final Completer<NaverMapController> mapControllerCompleter = Completer();
  double? latitude;
  double? longitude;
  int _currentIndex = 1;
  final List<Map<String, String>> _records = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _getCurrentLocation();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return;

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.deniedForever) return;
    }

    if (permission == LocationPermission.whileInUse ||
        permission == LocationPermission.always) {
      Position position = await Geolocator.getCurrentPosition(
        // ignore: deprecated_member_use
        desiredAccuracy: LocationAccuracy.high,
      );

      setState(() {
        latitude = position.latitude;
        longitude = position.longitude;
      });
    }
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
            records: _records,
            onAddRecord: (record) {
              setState(() {
                _records.add(record);
              });
            },
          ),
          HospitalMap(
            latitude: latitude,
            longitude: longitude,
            mapControllerCompleter: mapControllerCompleter,
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
