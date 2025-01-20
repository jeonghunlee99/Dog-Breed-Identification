import 'package:flutter/material.dart';
import '../../../widget/custom_snackbar.dart';
import 'edit_profile_data.dart';

class EditProfileController {
  final ProfileModel profileModel;

  EditProfileController({required this.profileModel});

  Future<void> saveProfile(
      BuildContext context,
      String name,
      String breed,
      String age,
      ValueChanged<String> onNameChanged,
      ValueChanged<String> onBreedChanged,
      ValueChanged<String> onAgeChanged,
      ) async {
    try {
      await profileModel.saveProfile(name, breed, age);
      onNameChanged(name);
      onBreedChanged(breed);
      onAgeChanged(age);

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
}