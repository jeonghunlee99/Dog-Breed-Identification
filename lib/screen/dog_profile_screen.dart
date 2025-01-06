import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../photoListProvider.dart';
import '../widget/custom_snackbar.dart';
import '../widget/edit_profile_dialog.dart';
import '../widget/navigator.dart';
import 'login_screen.dart';

final dogNameProvider = StateProvider<String>((ref) => '');
final dogBreedProvider = StateProvider<String>((ref) => '');
final dogAgeProvider = StateProvider<String>((ref) => '');

class ProfilePage extends ConsumerStatefulWidget { // 변경
  const ProfilePage({super.key});

  @override
  ConsumerState<ProfilePage> createState() => _ProfilePageState(); // 변경
}

class _ProfilePageState extends ConsumerState<ProfilePage> {
  int _currentIndex = 3;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

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
          ref.read(dogNameProvider.notifier).state = doc['name'] ?? '알 수 없음';
          ref.read(dogBreedProvider.notifier).state = doc['breed'] ?? '알 수 없음';
          ref.read(dogAgeProvider.notifier).state = doc['age'] ?? '알 수 없음';
        } else {
          ref.read(dogNameProvider.notifier).state = '정보 없음';
          ref.read(dogBreedProvider.notifier).state = '정보 없음';
          ref.read(dogAgeProvider.notifier).state = '정보 없음';
        }
      } catch (e) {
        print('Firestore 데이터 가져오기 실패: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final dogName = ref.watch(dogNameProvider);
    final dogBreed = ref.watch(dogBreedProvider);
    final dogAge = ref.watch(dogAgeProvider);
    final currentUser = _auth.currentUser;

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
            onTap: () {
              if (currentUser == null) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => LoginScreen(),
                  ),
                );
              } else {
                _showEditProfileDialog();
              }
            },
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
                      ref.read(photoListProvider.notifier).reset();
                      setState(() {});
                      CustomSnackBar.show(
                        context,
                        message: '로그아웃 되었습니다.',
                        backgroundColor: Colors.red,
                        icon: Icons.check_circle,
                      );
                    }).catchError((error) {
                      CustomSnackBar.show(
                        context,
                        message: '로그아웃 실패: $error',
                        backgroundColor: Colors.red,
                        icon: Icons.error,
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
          initialDogName: ref.read(dogNameProvider),
          initialDogBreed: ref.read(dogBreedProvider),
          initialDogAge: ref.read(dogAgeProvider),
          onNameChanged: (newName) {
            ref.read(dogNameProvider.notifier).state = newName;
          },
          onBreedChanged: (newBreed) {
            ref.read(dogBreedProvider.notifier).state = newBreed;
          },
          onAgeChanged: (newAge) {
            ref.read(dogAgeProvider.notifier).state = newAge;
          },
        );
      },
    );
  }
}