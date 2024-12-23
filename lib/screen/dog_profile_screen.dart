import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../widget/edit_profile_dialog.dart';
import '../widget/navigator.dart';
import 'login_screen.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  int _currentIndex = 3;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // 강아지 정보 //
  String dogName = "로딩 중...";
  String dogBreed = "로딩 중...";
  String dogAge = "로딩 중...";

  @override
  void initState() {
    super.initState();
    _fetchDogProfile();
  }

  Future<void> _fetchDogProfile() async {
    final user = _auth.currentUser;
    if (user != null) {
      try {
        final doc = await _firestore.collection('dogs').doc(user.uid).get();
        if (doc.exists) {
          setState(() {
            dogName = doc['name'] ?? '알 수 없음';
            dogBreed = doc['breed'] ?? '알 수 없음';
            dogAge = doc['age'] ?? '알 수 없음';
          });
        } else {
          // 문서가 없을 경우 기본값 표시
          setState(() {
            dogName = "정보 없음";
            dogBreed = "정보 없음";
            dogAge = "정보 없음";
          });
        }
      } catch (e) {
        print('Firestore 데이터 가져오기 실패: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final User? currentUser = _auth.currentUser;
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
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
                border: Border.all(color: Colors.black, width: 1.0),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(30),
                child: currentUser == null
                    ? Stack(
                  children: [
                    Image.asset(
                      'asset/dog_profile_card.png',
                      height: 150,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                    Center(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "로그인을 하고 프로필을 설정하세요!",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                              color: Colors.black,
                            ),
                          ),

                        ],
                      ),
                    ),
                  ],
                )
                    : Stack(
                        children: [
                          Image.asset(
                            'asset/dog_profile_card.png',
                            height: 150,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
                          Positioned(
                            bottom: 35,
                            left: 16,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "강아지 이름: $dogName",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20,
                                    color: Colors.black,
                                  ),
                                ),
                                Text(
                                  "품종: $dogBreed\n나이: $dogAge",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
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
          ),
          Card(
            margin: const EdgeInsets.symmetric(vertical: 8.0),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
            elevation: 10,
            shadowColor: Colors.black.withOpacity(0.3),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
                border: Border.all(color: Colors.black, width: 1.0),
              ),
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(bottom: 8.0),
                    child: Text(
                      '설정',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  ListTile(
                    title: const Text(
                      '개인정보처리방침',
                      style: TextStyle(fontSize: 16),
                    ),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () {
                      // 개인정보처리방침 페이지로 이동
                    },
                  ),
                  ListTile(
                    title: const Text(
                      '현재 버전',
                      style: TextStyle(fontSize: 16),
                    ),
                    trailing: const Text(
                      '1.0.0',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Center(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: Colors.black, width: 1.0),
              ),
              child: ElevatedButton(
                onPressed: () {
                  if (currentUser == null) {
                    // 로그인 화면으로 이동
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => LoginScreen(),
                      ),
                    );
                  } else {
                    // 로그아웃 수행
                    _auth.signOut().then((_) {
                      setState(() {});
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('로그아웃 되었습니다.')),
                      );
                    });
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  padding:
                      const EdgeInsets.symmetric(vertical: 14, horizontal: 150),
                  elevation: 10,
                ),
                child: Text(
                  currentUser == null ? '간편 로그인' : '로그아웃',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),
            ),
          )
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
