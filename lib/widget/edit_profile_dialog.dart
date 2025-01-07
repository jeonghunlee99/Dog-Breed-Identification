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
  late String _tempName;
  late String _tempBreed;
  late String _tempAge;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialDogName);
    _breedController = TextEditingController(text: widget.initialDogBreed);
    _ageController = TextEditingController(text: widget.initialDogAge);

    // 임시 상태 초기화
    _tempName = widget.initialDogName;
    _tempBreed = widget.initialDogBreed;
    _tempAge = widget.initialDogAge;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _breedController.dispose();
    _ageController.dispose();
    super.dispose();
  }

  Future<void> _saveToFirestore() async {
    if (!_formKey.currentState!.validate()) {
      return;
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
      'name': _tempName,
      'breed': _tempBreed,
      'age': _tempAge,
    };

    try {
      await _firestore.collection('dogs').doc(uid).get().then((doc) {
        if (doc.exists) {
          _firestore.collection('dogs').doc(uid).update(data);
        } else {
          _firestore.collection('dogs').doc(uid).set(data);
        }
      });

      // 상태 업데이트
      widget.onNameChanged(_tempName);
      widget.onBreedChanged(_tempBreed);
      widget.onAgeChanged(_tempAge);

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
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: '강아지 이름',
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.black),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.black),
                  ),
                  labelStyle: TextStyle(color: Colors.black),
                  focusColor: Colors.black,
                ),
                cursorColor: Colors.black,
                onChanged: (value) {
                  _tempName = value; // 임시 상태 업데이트
                },
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
                    borderSide: BorderSide(color: Colors.black),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.black),
                  ),
                  labelStyle: TextStyle(color: Colors.black),
                  focusColor: Colors.black,
                ),
                cursorColor: Colors.black,
                onChanged: (value) {
                  _tempBreed = value; // 임시 상태 업데이트
                },
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
                    borderSide: BorderSide(color: Colors.black),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.black),
                  ),
                  labelStyle: TextStyle(color: Colors.black),
                  focusColor: Colors.black,
                ),
                cursorColor: Colors.black,
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  _tempAge = value; // 임시 상태 업데이트
                },
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
            await _saveToFirestore();
          },
          child: const Text('저장', style: TextStyle(color: Colors.black)),
        ),
        TextButton(
          onPressed: () {
            Navigator.pop(context); // 다이얼로그 닫기
          },
          child: const Text('취소', style: TextStyle(color: Colors.black)),
        ),
      ],
    );
  }
}
