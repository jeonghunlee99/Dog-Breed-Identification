import 'dart:io';
import 'package:dog_breed_identification/screen/dog_album_screen.dart';
import 'package:dog_breed_identification/widget/navigator.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

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
    }
  }

  void _openAlbum() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AlbumPage(photos: _photos, onBackgroundSet: _setBackground),
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
