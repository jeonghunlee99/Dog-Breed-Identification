import 'package:dog_breed_identification/navigator.dart';
import 'package:flutter/material.dart';

class DogPhotoPage extends StatefulWidget {
  const DogPhotoPage({super.key});

  @override
  State<DogPhotoPage> createState() => _DogPhotoPageState();
}

class _DogPhotoPageState extends State<DogPhotoPage> {
  int _currentIndex = 2;  // AlbumPage에 해당하는 index

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('강아지 앨범')),
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
