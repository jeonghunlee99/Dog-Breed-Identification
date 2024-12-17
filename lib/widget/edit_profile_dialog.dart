import 'package:flutter/material.dart';

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
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(labelText: '강아지 이름'),
            onChanged: widget.onNameChanged,
          ),
          TextField(
            controller: _breedController,
            decoration: const InputDecoration(labelText: '품종'),
            onChanged: widget.onBreedChanged,
          ),
          TextField(
            controller: _ageController,
            decoration: const InputDecoration(labelText: '나이'),
            onChanged: widget.onAgeChanged,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text('저장',style: TextStyle(color: Colors.black)),
        ),
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text('취소',style: TextStyle(color: Colors.black)),
        ),
      ],
    );
  }
}
