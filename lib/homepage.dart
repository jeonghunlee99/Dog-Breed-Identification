import 'package:flutter/material.dart';
import 'dog_category_page.dart';

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('강아지 백과사전'),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => DogCategoryPage()),
                );
              },
              child: ClipRRect(
                borderRadius: BorderRadius.circular(15), // 둥근 모서리
                child: Image.asset(
                  'asset/dog_image.png',
                  width: 70,
                  height: 70,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            SizedBox(height: 10), // 이미지와 텍스트 사이 간격
            Text(
              '강아지 카테고리',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
