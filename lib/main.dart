import 'package:flutter/material.dart';

void main() {
  runApp(DogEncyclopediaApp());
}

class DogEncyclopediaApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: '강아지 백과사전123',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: DogHomePage(),
    );
  }
}

class DogHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('강아지 백과사전'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 검색 바
              TextField(
                decoration: InputDecoration(
                  labelText: '강아지 품종 검색',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.search),
                ),
              ),
              SizedBox(height: 20),
              // 인기 품종 섹션
              Text(
                '인기 강아지 품종',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              SizedBox(
                height: 150,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    DogBreedCard(breedName: '골든 리트리버', imageUrl: 'https://via.placeholder.com/150'),
                    DogBreedCard(breedName: '시베리안 허스키', imageUrl: 'https://via.placeholder.com/150'),
                    DogBreedCard(breedName: '푸들', imageUrl: 'https://via.placeholder.com/150'),
                  ],
                ),
              ),
              SizedBox(height: 20),
              // 소개 섹션
              Text(
                '앱 소개',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              Text(
                '강아지 백과사전은 다양한 강아지 품종에 대한 정보를 제공하며, '
                    '강아지와의 생활을 더욱 즐겁게 만듭니다. 지금 바로 탐색해보세요!',
                style: TextStyle(fontSize: 16),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class DogBreedCard extends StatelessWidget {
  final String breedName;
  final String imageUrl;

  DogBreedCard({required this.breedName, required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 10.0),
      child: Column(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.network(
              imageUrl,
              height: 100,
              width: 100,
              fit: BoxFit.cover,
            ),
          ),
          SizedBox(height: 8),
          Text(
            breedName,
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}
