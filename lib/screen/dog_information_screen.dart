import 'package:flutter/material.dart';

import '../widget/navigator.dart';

class DogInformationPage extends StatefulWidget {
  const DogInformationPage({super.key});

  @override
  State<DogInformationPage> createState() => _DogInformationPageState();
}

class _DogInformationPageState extends State<DogInformationPage> {
  int _currentIndex = 1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('강아지 건강')),
      body: Text("1.강아지에게 주는약 날짜 기록, \n2.병원 방문기록,진료예약날짜 기록, \n3.지도와 연동하여 가까운 동물병원 표시"),
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

