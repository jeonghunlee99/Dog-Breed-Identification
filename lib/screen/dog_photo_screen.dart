import 'dart:io';
import 'package:dog_breed_identification/screen/dog_album_screen.dart';
import 'package:dog_breed_identification/widget/navigator.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // Riverpod import 추가

import '../photoListProvider.dart';
import '../widget/custom_snackbar.dart';

final photosProvider = StateProvider<List<File>>((ref) => []);
final backgroundImageProvider = StateProvider<File?>((ref) => null);

class DogPhotoPage extends ConsumerStatefulWidget {
  const DogPhotoPage({super.key});

  @override
  ConsumerState<DogPhotoPage> createState() => _DogPhotoPageState();
}

class _DogPhotoPageState extends ConsumerState<DogPhotoPage> {
  final ImagePicker _picker = ImagePicker();
  File? _backgroundImage;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(currentIndexProvider.notifier).state = 2;
    });
  }

  // 로그인 상태 체크
  void _checkLoginStatus(VoidCallback onSuccess) {
    final User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      _showCustomSnackBar('로그인 후 이용해주세요!', Colors.red);
    } else {
      onSuccess();
    }
  }

  Future<void> _takePhoto() async {
    _checkLoginStatus(() async {
      final pickedFile = await _picker.pickImage(source: ImageSource.camera);
      if (pickedFile != null) {
        final photoFile = File(pickedFile.path);

        // StateProvider를 사용하여 사진 추가
        ref.read(photosProvider.notifier).update((state) => [...state, photoFile]);

        // Firebase Storage에 업로드
        await _uploadImageToStorage(ref, photoFile);
      }
    });
  }

  Future<void> _uploadImageToStorage(WidgetRef ref, File imageFile) async {
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

      await ref.read(photoListProvider.notifier).loadPhotos();
    } catch (e) {
      _showCustomSnackBar('업로드 실패: $e', Colors.red);
    }
  }

  void _openAlbum() {
    _checkLoginStatus(() {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => AlbumPage(),
        ),
      );
    });
  }

  Widget _buildActionContainer({
    required String label,
    required String imagePath,
    required VoidCallback onTap,
  }) {
    return Container(
      width: 100,
      height: 130,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            spreadRadius: 3,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      padding: const EdgeInsets.all(10),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          InkWell(
            onTap: onTap,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: Image.asset(
                imagePath,
                width: 80,
                height: 80,
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  void _showCustomSnackBar(String message, Color backgroundColor) {
    final icon = backgroundColor == Colors.green ? Icons.check_circle : Icons.error;

    CustomSnackBar.show(
      context,
      message: message,
      backgroundColor: backgroundColor,
      icon: icon,
    );
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Container(
          decoration: BoxDecoration(
            image: _backgroundImage != null
                ? DecorationImage(image: FileImage(_backgroundImage!), fit: BoxFit.cover)
                : null,
          ),
          child: Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 40),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildActionContainer(
                    label: '사진 찍기',
                    imagePath: 'asset/camera.png',
                    onTap: _takePhoto,
                  ),
                  const SizedBox(width: 40),
                  _buildActionContainer(
                    label: '앨범 열기',
                    imagePath: 'asset/dog_album.jpeg',
                    onTap: _openAlbum,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: const CustomBottomNavBar(),
    );
  }
}
