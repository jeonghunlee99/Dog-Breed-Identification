import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../widget/custom_snackbar.dart';
import 'homepage.dart';


class DogStartProfilePage extends StatefulWidget {
  const DogStartProfilePage({super.key});

  @override
  State<DogStartProfilePage> createState() => _DogStartProfileState();
}

class _DogStartProfileState extends State<DogStartProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _dogNameController = TextEditingController();
  final TextEditingController _dogBreedController = TextEditingController();
  final TextEditingController _dogAgeController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> _submitProfile() async {
    if (_formKey.currentState!.validate()) {
      try {
        final user = _auth.currentUser;
        if (user != null) {
          await _firestore.collection('dogs').doc(user.uid).set({
            'name': _dogNameController.text,
            'breed': _dogBreedController.text,
            'age': _dogAgeController.text,
          });

          CustomSnackBar.show(
            context,
            message: '프로필이 저장되었습니다.',
            backgroundColor: Colors.green,
            icon: Icons.check_circle,
          );

          // 다음 화면으로 이동 또는 폼 초기화
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (context) => HomePage(),
            ),
            ModalRoute.withName('/'), // 루트 페이지를 제외한 모든 화면을 제거
          );
        } else {
          CustomSnackBar.show(
            context,
            message: '로그인이 필요합니다.',
            backgroundColor: Colors.red,
            icon: Icons.error,
          );
        }
      } catch (e) {
        CustomSnackBar.show(
          context,
          message: '오류가 발생했습니다: $e',
          backgroundColor: Colors.red,
          icon: Icons.error,
        );
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text('강아지 프로필 설정'),
        leading: SizedBox(), // 뒤로가기 버튼 비활성화
        centerTitle: true, // 타이틀을 가운데 정렬
      ),
      body: Center(
        child: Container(
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(30), // 둥근 모서리
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 10,
                offset: Offset(0, 4), // 그림자 위치 조정
              ),
            ],
          ),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min, // 화면에 맞게 크기 조정
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  controller: _dogNameController,
                  decoration: InputDecoration(
                    labelText: '강아지 이름',
                    labelStyle: TextStyle(color: Colors.brown), // 레이블 색상 갈색으로 변경
                    border: OutlineInputBorder(),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.brown), // 선택 시 경계선 색상 변경
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.brown), // 비활성화 상태 경계선 색상 변경
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return '강아지 이름을 입력해주세요.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 15),
                TextFormField(
                  controller: _dogBreedController,
                  decoration: InputDecoration(
                    labelText: '강아지 품종',
                    labelStyle: TextStyle(color: Colors.brown), // 레이블 색상 갈색으로 변경
                    border: OutlineInputBorder(),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.brown), // 선택 시 경계선 색상 변경
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.brown), // 비활성화 상태 경계선 색상 변경
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return '강아지 품종을 입력해주세요.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 15),
                TextFormField(
                  controller: _dogAgeController,
                  decoration: InputDecoration(
                    labelText: '강아지 나이',
                    labelStyle: TextStyle(color: Colors.brown), // 레이블 색상 갈색으로 변경
                    border: OutlineInputBorder(),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.brown), // 선택 시 경계선 색상 변경
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.brown), // 비활성화 상태 경계선 색상 변경
                    ),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return '강아지 나이를 입력해주세요.';
                    }
                    if (int.tryParse(value) == null) {
                      return '숫자만 입력해주세요.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: _submitProfile,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.brown[400],
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text(
                    '프로필 저장',
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }


}