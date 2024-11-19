import 'dart:convert'; // JSON 변환을 위한 패키지
import 'package:flutter/services.dart'; // 로컬 파일 로드를 위한 패키지

class Dog {
  final String name;
  final String imageUrl;
  final String description;
  final String size;
  final String temperament;
  final String lifeSpan;

  Dog({
    required this.name,
    required this.imageUrl,
    required this.description,
    required this.size,
    required this.temperament,
    required this.lifeSpan,
  });

  factory Dog.fromJson(Map<String, dynamic> json) {
    return Dog(
      name: json['name'],
      imageUrl: json['image_url'],
      description: json['description'],
      size: json['characteristics']['size'],
      temperament: json['characteristics']['temperament'],
      lifeSpan: json['characteristics']['life_span'],
    );
  }
}

Future<List<Dog>> loadDogs() async {
  try {
    // assets 폴더의 JSON 파일 읽기
    final String response = await rootBundle.loadString('asset/dog_information.json');
    final List<dynamic> data = json.decode(response);

    // JSON 데이터를 Dog 객체로 변환
    return data.map((json) => Dog.fromJson(json)).toList();
  } catch (e) {
    print("Error loading dogs: $e"); // 에러 로그 출력
    rethrow;
  }
}
