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
      body: Center(),
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
