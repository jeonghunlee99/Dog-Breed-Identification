import 'package:flutter/material.dart';

import 'navigator.dart';

class DogWalkPage extends StatefulWidget {
  const DogWalkPage({super.key});

  @override
  State<DogWalkPage> createState() => _DogWalkPageState();
}

class _DogWalkPageState extends State<DogWalkPage> {
  int _currentIndex = 0;  // AlbumPage에 해당하는 index

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('강아지 산책')),
      body: Text("1.강아지 산책한 날짜 달력에 기록 \n2.산책 통계 페이지 \n3.할수있다면 타이머 추가하여 버튼눌러서 산책시간 저장하여 기록되는 형식 "),
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
