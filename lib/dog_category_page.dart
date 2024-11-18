import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class DogInformationLoader {
  static Future<List<dynamic>> loadDogs() async {
    final String response = await rootBundle.loadString('asset/dog_information.json');
    return json.decode(response);
  }
}

class DogCategoryPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('강아지 카테고리'),
        centerTitle: true,
      ),
      body: FutureBuilder<List<dynamic>>(
        future: DogInformationLoader.loadDogs(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('데이터 로드 중 오류가 발생했습니다.'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('강아지 정보를 찾을 수 없습니다.'));
          }

          final List<dynamic> dogData = snapshot.data!;
          return ListView.builder(
            itemCount: dogData.length,
            itemBuilder: (context, index) {
              final dog = dogData[index];
              return Card(
                margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  leading: Image.network(
                    dog['image_url'],
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                  ),
                  title: Text(dog['name']),
                  subtitle: Text(dog['description']),
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('${dog['name']} 선택됨')),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}