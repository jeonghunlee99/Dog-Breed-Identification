import 'dart:io';
import 'package:dog_breed_identification/screen/album_page/photo_screen/photo_data.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../widget/custom_snackbar.dart';
import '../album_screen/album_data.dart';






class DogPhotoController {
  final WidgetRef ref;
  final BuildContext context;
  final ImagePicker _picker = ImagePicker();

  DogPhotoController(this.ref, this.context);

  // Login status check
  void checkLoginStatus(VoidCallback onSuccess) {
    final User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      _showCustomSnackBar('로그인 후 이용해주세요!', Colors.red);
    } else {
      onSuccess();
    }
  }

  // Take photo using camera
  Future<void> takePhoto() async {
    checkLoginStatus(() async {
      final pickedFile = await _picker.pickImage(source: ImageSource.camera);
      if (pickedFile != null) {
        final photoFile = File(pickedFile.path);

        // Add photo to StateProvider
        ref.read(photosProvider.notifier).update((state) => [...state, photoFile]);

        // Upload to Firebase Storage
        await _uploadImageToStorage(photoFile);
      }
    });
  }

  // Open album page
  void openAlbum(Widget albumPage) {
    checkLoginStatus(() {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => albumPage),
      );
    });
  }

  // Upload image to Firebase Storage
  Future<void> _uploadImageToStorage(File imageFile) async {
    try {
      final User? user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        _showCustomSnackBar('로그인되지 않은 사용자', Colors.red);
        return;
      }

      final storageRef = FirebaseStorage.instance.ref();
      final fileName =
          'dog_photos/${user.uid}/${DateTime.now().millisecondsSinceEpoch}.jpg';
      final storageChildRef = storageRef.child(fileName);

      await storageChildRef.putFile(imageFile);

      final photoUrl = await storageChildRef.getDownloadURL();
      await ref.read(photoListProvider.notifier).addPhoto(photoUrl);

      _showCustomSnackBar('사진 업로드 완료!', Colors.green);

      // Reload photo list
      await ref.read(photoListProvider.notifier).loadPhotos();
    } catch (e) {
      _showCustomSnackBar('업로드 실패: $e', Colors.red);
    }
  }

  // Show custom snackbar
  void _showCustomSnackBar(String message, Color backgroundColor) {
    final icon = backgroundColor == Colors.green ? Icons.check_circle : Icons.error;
    CustomSnackBar.show(
      context,
      message: message,
      backgroundColor: backgroundColor,
      icon: icon,
    );
  }
}

