import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../widget/custom_snackbar.dart';
import 'edit_profile_data.dart';


class EditProfileDialog extends ConsumerStatefulWidget {
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
  ConsumerState<EditProfileDialog> createState() => _EditProfileDialogState();
}

class _EditProfileDialogState extends ConsumerState<EditProfileDialog> {
  late TextEditingController _nameController;
  late TextEditingController _breedController;
  late TextEditingController _ageController;

  final _formKey = GlobalKey<FormState>();

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
                  widget.onNameChanged(value);
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
                  widget.onBreedChanged(value);
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
                  widget.onAgeChanged(value);
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
            if (_formKey.currentState?.validate() ?? false) {
              final model = ProfileModel();
              try {
                await model.saveProfile(
                  _nameController.text,
                  _breedController.text,
                  _ageController.text,
                );

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
