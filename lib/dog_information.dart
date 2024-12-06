import 'package:flutter/material.dart';

import 'navigator.dart';

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
      appBar: AppBar(title: const Text('강아지 사전')),
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

