import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cached_network_image/cached_network_image.dart';

class AlbumPage extends StatefulWidget {
  final Function(File) onBackgroundSet;

  const AlbumPage({super.key, required this.onBackgroundSet});

  @override
  _AlbumPageState createState() => _AlbumPageState();
}

class _AlbumPageState extends State<AlbumPage> {
  List<String> _imageUrls = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadImageUrls();
  }


  Future<void> _loadImageUrls() async {
    try {
      final User? user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        print('사용자가 로그인되지 않았습니다.');
        return;
      }

      final storageRef = FirebaseStorage.instance.ref();
      final listResult = await storageRef.child('dog_photos/${user.uid}').listAll();

      List<String> imageUrls = [];
      for (var item in listResult.items) {
        String url = await item.getDownloadURL();
        imageUrls.add(url);
      }

      setState(() {
        _imageUrls = imageUrls;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading image URLs: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }


  void _showImageDialog(BuildContext context, String imageUrl, int index) {
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
                child: CachedNetworkImage(  // Firebase Storage에서 캐시된 이미지를 로드
                  imageUrl: imageUrl,
                  fit: BoxFit.cover,
                  height: 300,
                  width: double.infinity,
                  placeholder: (context, url) => const CircularProgressIndicator(),  // 로딩 중 표시
                  errorWidget: (context, url, error) => const Icon(Icons.error),  // 에러 발생 시 표시
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () {
                        widget.onBackgroundSet(File(imageUrl));  // 배경 설정
                        Navigator.pop(context);
                      },
                      icon: const Icon(Icons.wallpaper),
                      label: const Text('배경 설정'),
                    ),
                    ElevatedButton.icon(
                      onPressed: () {
                        setState(() {
                          _imageUrls.removeAt(index);  // 이미지 삭제
                        });
                        Navigator.pop(context);
                      },
                      icon: const Icon(Icons.delete),
                      label: const Text('삭제'),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('앨범')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _imageUrls.isEmpty
          ? const Center(child: Text('사진이 없습니다.'))
          : GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 4,
          mainAxisSpacing: 4,
        ),
        itemCount: _imageUrls.length,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () {
              _showImageDialog(context, _imageUrls[index], index);
            },
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: CachedNetworkImage(
                imageUrl: _imageUrls[index],
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
}
