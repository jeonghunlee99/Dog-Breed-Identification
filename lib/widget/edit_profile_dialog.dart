import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'custom_snackbar.dart';

class EditProfileDialog extends StatefulWidget {
  final String initialDogName;
  final String initialDogBreed;
  final String initialDogAge;
  final ValueChanged<String> onNameChanged;
  final ValueChanged<String> onBreedChanged;
  final ValueChanged<String> onAgeChanged;

  const EditProfileDialog({
    Key? key,
    required this.initialDogName,
    required this.initialDogBreed,
    required this.initialDogAge,
    required this.onNameChanged,
    required this.onBreedChanged,
    required this.onAgeChanged,
  }) : super(key: key);

  @override
  _EditProfileDialogState createState() => _EditProfileDialogState();
}

class _EditProfileDialogState extends State<EditProfileDialog> {
  late TextEditingController _nameController;
  late TextEditingController _breedController;
  late TextEditingController _ageController;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final _formKey = GlobalKey<FormState>(); // 폼 키 추가

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialDogName);
    _breedController = TextEditingController(text: widget.initialDogBreed);
    _ageController = TextEditingController(text: widget.initialDogAge);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _breedController.dispose();
    _ageController.dispose();
    super.dispose();
  }

  Future<void> _saveToFirestore() async {
    // 유효성 검사 실행
    if (!_formKey.currentState!.validate()) {
      return; // 입력이 올바르지 않으면 저장하지 않음
    }

    final User? currentUser = _auth.currentUser;
    if (currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('사용자가 로그인되어 있지 않습니다.')),
      );
      return;
    }

    final String uid = currentUser.uid;
    final data = {
      'name': _nameController.text,
      'breed': _breedController.text,
      'age': _ageController.text,
    };

    try {
      await _firestore.collection('dogs').doc(uid).get().then((doc) {
        if (doc.exists) {
          // update >> 현재 정보에 업데이트
          _firestore.collection('dogs').doc(uid).update(data);
        } else {
          // set >> 문서가 없으면 dogs 컬렉션에 현재 uid로 된 문서 추가
          _firestore.collection('dogs').doc(uid).set(data);
        }
      });


      CustomSnackBar.show(
        context,
        message: '저장 완료!',
        backgroundColor: Colors.green,
        icon: Icons.check_circle,
      );


      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('저장 실패: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }

  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('프로필 수정'),
      content: SingleChildScrollView( // 추가
        child: Form( // 폼 위젯 추가
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: '강아지 이름',
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.black), // 포커스 시 경계선 색상
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.black), // 비활성화 상태 경계선 색상
                  ),
                  labelStyle: TextStyle(color: Colors.black), // 레이블 색상
                  focusColor: Colors.black, // 포커스 색상
                ),
                cursorColor: Colors.black, // 커서 색상 설정
                onChanged: widget.onNameChanged,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '강아지 이름을 입력해주세요.';
                  }
                  return null;
                },
              ),
              SizedBox(height: 5),
              TextFormField(
                controller: _breedController,
                decoration: InputDecoration(
                  labelText: '품종',
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.black), // 포커스 시 경계선 색상
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.black), // 비활성화 상태 경계선 색상
                  ),
                  labelStyle: TextStyle(color: Colors.black), // 레이블 색상
                  focusColor: Colors.black, // 포커스 색상
                ),
                cursorColor: Colors.black, // 커서 색상 설정
                onChanged: widget.onBreedChanged,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '강아지 품종을 입력해주세요.';
                  }
                  return null;
                },
              ),
              SizedBox(height: 5),
              TextFormField(
                controller: _ageController,
                decoration: InputDecoration(
                  labelText: '나이',
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.black), // 포커스 시 경계선 색상
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.black), // 비활성화 상태 경계선 색상
                  ),
                  labelStyle: TextStyle(color: Colors.black), // 레이블 색상
                  focusColor: Colors.black, // 포커스 색상
                ),
                cursorColor: Colors.black, // 커서 색상 설정
                keyboardType: TextInputType.number,
                onChanged: widget.onAgeChanged,
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
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () async {
            await _saveToFirestore(); // 유효성 검사 후 저장
          },
          child: const Text('저장', style: TextStyle(color: Colors.black)),
        ),
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text('취소', style: TextStyle(color: Colors.black)),
        ),
      ],
    );
  }
}
