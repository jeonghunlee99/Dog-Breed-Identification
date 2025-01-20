import 'package:dog_breed_identification/screen/profile_page/profile_edit_dialog/edit_profile_page.dart';
import 'package:dog_breed_identification/screen/profile_page/profile_screen/profile_controller.dart';
import 'package:dog_breed_identification/screen/profile_page/profile_screen/profile_data.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../widget/custom_snackbar.dart';
import '../../../widget/navigator.dart';
import '../login_screen/login_page.dart';

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLoggedInAsync = ref.watch(isLoggedInProvider);
    final dogName = ref.watch(dogNameProvider);
    final dogBreed = ref.watch(dogBreedProvider);
    final dogAge = ref.watch(dogAgeProvider);
    final controller = ProfileController();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text('강아지 프로필'),
      ),
      body: isLoggedInAsync.when(
        data: (isLoggedIn) {
          if (isLoggedIn) {
            // 로그인된 상태에서만 강아지 프로필을 가져옴
            controller.fetchDogProfile(ref, context);
          }

          // 상태에 맞는 UI 업데이트
          return ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              GestureDetector(
                onTap: () {
                  if (!isLoggedIn) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const LoginScreen()),
                    );
                  } else {
                    _showEditProfileDialog(context, ref);
                  }
                },
                child: _buildProfileCard(dogName, dogBreed, dogAge, isLoggedIn),
              ),
              _buildSettingsCard(),
              _buildAuthButton(context, isLoggedIn, ref, controller),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Text('오류 발생: $error', style: const TextStyle(color: Colors.red)),
        ),
      ),
      bottomNavigationBar: const CustomBottomNavBar(),
    );
  }


  Widget _buildProfileCard(String name, String breed, String age, bool isLoggedIn) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.black, width: 1.0),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(30),
        child: Stack(
          children: [
            Image.asset(
              'asset/dog_profile_card.png',
              height: 150,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
            if (!isLoggedIn)
              const Center(
                child: Text(
                  "로그인을 하고 프로필을 설정하세요!",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                    color: Colors.black,
                  ),
                ),
              )
            else
              Positioned(
                bottom: 35,
                left: 16,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "강아지 이름: $name",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                        color: Colors.black,
                      ),
                    ),
                    Text(
                      "품종: $breed\n나이: $age",
                      style: const TextStyle(
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
    );
  }

  // 나머지 코드는 그대로 유지
  Widget _buildSettingsCard() {
    return Card(
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
    );
  }

  Widget _buildAuthButton(BuildContext context, bool isLoggedIn, WidgetRef ref, ProfileController controller) {
    return ElevatedButton(
      onPressed: () {
        if (!isLoggedIn) {
          Navigator.push(context, MaterialPageRoute(builder: (context) => const LoginScreen()));
        } else {
          controller.logout(
            ref,
                () {
              CustomSnackBar.show(
                context,
                message: '로그아웃 되었습니다.',
                backgroundColor: Colors.red,
                icon: Icons.check_circle,
              );
            },
                (error) {
              CustomSnackBar.show(
                context,
                message: '로그아웃 실패: $error',
                backgroundColor: Colors.red,
                icon: Icons.error,
              );
            },
          );
        }
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 150),
        elevation: 10,
      ),
      child: Text(
        isLoggedIn ? '로그아웃' : '간편 로그인',
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
      ),
    );
  }

  void _showEditProfileDialog(BuildContext context, WidgetRef ref) {
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
