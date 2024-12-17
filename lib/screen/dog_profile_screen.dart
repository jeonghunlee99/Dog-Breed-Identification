import 'package:flutter/material.dart';
import '../widget/edit_profile_dialog.dart';
import '../widget/navigator.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  int _currentIndex = 3;

  // 예시 데이터 //
  String dogName = "멍멍이";
  String dogBreed = "시바견";
  String dogAge = "3년";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text('강아지 프로필'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          GestureDetector(
            onTap: _showEditProfileDialog,
            child: Card(
              margin: const EdgeInsets.symmetric(vertical: 8.0),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              elevation: 10,
              shadowColor: Colors.black.withOpacity(0.3),
              child: Stack(
                children: [
                  // 카드 배경 이미지
                  ClipRRect(
                    borderRadius: BorderRadius.circular(30),
                    child: Image.asset(
                      'asset/dog_profile_card.png',
                      height: 150,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Positioned(
                    left: 16,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "강아지 이름: $dogName",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: Colors.black,
                          ),
                        ),
                        Text(
                          "품종: $dogBreed\n나이: $dogAge",
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          // 나머지 카드들
          Card(
            margin: const EdgeInsets.symmetric(vertical: 8.0),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
            elevation: 10,
            shadowColor: Colors.black.withOpacity(0.3),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  ListTile(
                    title: const Text(''),
                  ),
                  ListTile(
                    title: const Text(''),
                  ),
                ],
              ),
            ),
          ),
          Card(
            margin: const EdgeInsets.symmetric(vertical: 8.0),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
            elevation: 10,
            shadowColor: Colors.black.withOpacity(0.3),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  ListTile(
                    title: const Text(''),
                  ),
                  ListTile(
                    title: const Text(''),
                  ),
                ],
              ),
            ),
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

  void _showEditProfileDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return EditProfileDialog(
          initialDogName: dogName,
          initialDogBreed: dogBreed,
          initialDogAge: dogAge,
          onNameChanged: (newName) {
            setState(() {
              dogName = newName;
            });
          },
          onBreedChanged: (newBreed) {
            setState(() {
              dogBreed = newBreed;
            });
          },
          onAgeChanged: (newAge) {
            setState(() {
              dogAge = newAge;
            });
          },
        );
      },
    );
  }
}
