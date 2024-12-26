import 'dart:io';
import 'package:dog_breed_identification/screen/dog_album_screen.dart';
import 'package:dog_breed_identification/widget/navigator.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

class DogPhotoPage extends StatefulWidget {
  const DogPhotoPage({super.key});

  @override
  State<DogPhotoPage> createState() => _DogPhotoPageState();
}

class _DogPhotoPageState extends State<DogPhotoPage> {
  int _currentIndex = 2;
  final List<File> _photos = [];
  final ImagePicker _picker = ImagePicker();
  File? _backgroundImage;

  Future<void> _takePhoto() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      setState(() {
        _photos.add(File(pickedFile.path));
      });

      await _uploadImageToStorage(File(pickedFile.path));
    }
  }

  Future<void> _uploadImageToStorage(File imageFile) async {
    try {
      final User? user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('로그인되지 않은 사용자')),
        );
        return;
      }

      final storageRef = FirebaseStorage.instance.ref();
      final fileName = 'dog_photos/${user.uid}/${DateTime.now().millisecondsSinceEpoch}.jpg';
      final ref = storageRef.child(fileName);

      await ref.putFile(imageFile);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('사진 업로드 완료!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('업로드 실패: $e')),
      );
    }
  }

  void _openAlbum() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AlbumPage( onBackgroundSet: _setBackground),
      ),
    );
  }

  void _setBackground(File photo) {
    setState(() {
      _backgroundImage = photo;
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
}
