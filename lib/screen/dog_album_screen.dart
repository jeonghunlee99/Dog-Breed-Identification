import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../imageurlsprovider.dart';

// 이미지 목록을 로드하는 FutureProvider
final imageUrlsProvider = FutureProvider<List<String>>((ref) async {
  final User? user = FirebaseAuth.instance.currentUser;
  if (user == null) {
    throw Exception('사용자가 로그인되지 않았습니다.');
  }

  final storageRef = FirebaseStorage.instance.ref();
  final listResult = await storageRef.child('dog_photos/${user.uid}').listAll();

  List<String> imageUrls = [];
  for (var item in listResult.items) {
    String url = await item.getDownloadURL();
    imageUrls.add(url);
  }

  return imageUrls;
});

// 이미지 삭제하는 StateProvider
final imageDeleteProvider = StateProvider.family<void, String>((ref, imageUrl) async {
  try {
    final storageRef = FirebaseStorage.instance.refFromURL(imageUrl);
    await storageRef.delete();
  } catch (e) {
    throw Exception('이미지 삭제 실패: $e');
  }
});

final imageNotifierProvider = StateNotifierProvider<ImageNotifier, List<String>>((ref) {
  final notifier = ImageNotifier();
  notifier.loadImages(); // 초기 이미지 로드
  return notifier;
});


class AlbumPage extends ConsumerWidget {
  final Function(File) onBackgroundSet;

  const AlbumPage({super.key, required this.onBackgroundSet});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final imageUrls = ref.watch(imageNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('앨범'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () async {
              // 이미지 선택 및 추가
              final image = await _pickImage();
              if (image != null) {
                await ref.read(imageNotifierProvider.notifier).addImage(image);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('이미지가 추가되었습니다.')),
                );
              }
            },
          ),
        ],
      ),
      body: imageUrls.isEmpty
          ? const Center(child: Text('사진이 없습니다.'))
          : GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 4,
          mainAxisSpacing: 4,
        ),
        itemCount: imageUrls.length,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () {
              _showImageDialog(context, imageUrls[index], ref);
            },
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: CachedNetworkImage(
                imageUrl: imageUrls[index],
                fit: BoxFit.cover,
                placeholder: (context, url) => const CircularProgressIndicator(),
                errorWidget: (context, url, error) => const Icon(Icons.error),
              ),
            ),
          );
        },
      ),
    );
  }

  Future<File?> _pickImage() async {
    // 사용자가 이미지를 선택하는 로직 추가 (예: image_picker 사용)
    return null; // 예제에서는 파일 선택 로직을 구현하지 않았습니다.
  }

  void _showImageDialog(BuildContext context, String imageUrl, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
                child: CachedNetworkImage(
                  imageUrl: imageUrl,
                  fit: BoxFit.cover,
                  height: 300,
                  width: double.infinity,
                  placeholder: (context, url) => const CircularProgressIndicator(),
                  errorWidget: (context, url, error) => const Icon(Icons.error),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () {
                        ref.read(imageNotifierProvider.notifier).deleteImage(imageUrl);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('이미지가 삭제되었습니다.')),
                        );
                        Navigator.pop(context);
                      },
                      icon: const Icon(Icons.delete, color: Colors.white),
                      label: const Text('삭제', style: TextStyle(color: Colors.white)),
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
