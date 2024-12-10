import 'dart:io';
import 'package:flutter/material.dart';

class AlbumPage extends StatefulWidget {
  final List<File> photos;
  final Function(File) onBackgroundSet;

  const AlbumPage({super.key, required this.photos, required this.onBackgroundSet});

  @override
  _AlbumPageState createState() => _AlbumPageState();
}

class _AlbumPageState extends State<AlbumPage> {
  void _showImageDialog(BuildContext context, File photo, int index) {
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
                child: Image.file(
                  photo,
                  fit: BoxFit.cover,
                  height: 300,
                  width: double.infinity,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () {
                        widget.onBackgroundSet(photo);
                        Navigator.pop(context);
                      },
                      icon: const Icon(Icons.wallpaper),
                      label: const Text('배경 설정'),
                    ),
                    ElevatedButton.icon(
                      onPressed: () {
                        setState(() {
                          widget.photos.removeAt(index);
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
      body: widget.photos.isEmpty
          ? const Center(child: Text('사진이 없습니다.'))
          : GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 4,
          mainAxisSpacing: 4,
        ),
        itemCount: widget.photos.length,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () {
              _showImageDialog(context, widget.photos[index], index);
            },
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.file(
                widget.photos[index],
                fit: BoxFit.cover,
              ),
            ),
          );
        },
      ),
    );
  }
}
