import 'package:dog_breed_identification/screen/album_page/photo_screen/photo_controller.dart';
import 'package:dog_breed_identification/screen/album_page/photo_screen/photo_data.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../widget/navigator.dart';
import '../album_screen/album_screen.dart';



class DogPhotoPage extends ConsumerWidget {
  const DogPhotoPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = DogPhotoController(ref, context);

    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Container(
          decoration: BoxDecoration(
            image: ref.watch(backgroundImageProvider) != null
                ? DecorationImage(
              image: FileImage(ref.watch(backgroundImageProvider)!),
              fit: BoxFit.cover,
            )
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
                    onTap: () => controller.takePhoto(),
                  ),
                  const SizedBox(width: 40),
                  _buildActionContainer(
                    label: '앨범 열기',
                    imagePath: 'asset/dog_album.jpeg',
                    onTap: () => controller.openAlbum(AlbumPage()),
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
}
