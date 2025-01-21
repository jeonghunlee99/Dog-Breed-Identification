import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'album_controller.dart';
import 'album_data.dart';


class AlbumPage extends ConsumerStatefulWidget {
  const AlbumPage({super.key});

  @override
  _AlbumPageState createState() => _AlbumPageState();
}

class _AlbumPageState extends ConsumerState<AlbumPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final photoList = ref.read(photoListProvider);
      if (photoList.isEmpty) {
        // 사진 리스트가 비어 있을 때만 로드
        ref.read(isLoadingProvider.notifier).state = true; // 로딩 시작
        await ref.read(photoListProvider.notifier).loadPhotos(); // 사진 로드
        ref.read(isLoadingProvider.notifier).state = false; // 로딩 종료
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final controller = AlbumController(ref);
    final photoList = ref.watch(photoListProvider);
    final isLoading = ref.watch(isLoadingProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('앨범')),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : photoList.isEmpty
          ? const Center(child: Text('사진이 없습니다.'))
          : GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 4,
          mainAxisSpacing: 4,
        ),
        itemCount: photoList.length,
        itemBuilder: (context, index) {
          final imageUrl = photoList[index];
          return GestureDetector(
            onTap: () => _showImageDialog(context, controller, imageUrl),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: CachedNetworkImage(
                imageUrl: imageUrl,
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

  void _showImageDialog(BuildContext context, AlbumController controller, String imageUrl) {
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
                child: ElevatedButton.icon(
                  onPressed: () async {
                    await controller.deletePhoto(imageUrl);
                    Navigator.pop(context);
                  },
                  icon: const Icon(Icons.delete, color: Colors.white),
                  label: const Text('삭제', style: TextStyle(color: Colors.white)),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
