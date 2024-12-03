import 'dart:convert';
import 'package:flutter/services.dart';

class Dog {
  final String name;
  final String imageUrl;
  final String description;
  final String size;
  final String temperament;
  final String lifeSpan;
  final String coat;
  final int iqRank;
  Dog({
    required this.name,
    required this.imageUrl,
    required this.description,
    required this.size,
    required this.temperament,
    required this.lifeSpan,
    required this.coat,
    required this.iqRank
  });

  factory Dog.fromJson(Map<String, dynamic> json) {
    return Dog(
      name: json['name'] ?? '이름 없음',
      imageUrl: json['image_url'] ?? '',
      description: json['description'] ?? '설명이 없습니다.',
      size: json['characteristics']['size'] ?? '크기 정보 없음',
      temperament: json['characteristics']['temperament'] ?? '성격 정보 없음',
      lifeSpan: json['characteristics']['life_span'] ?? '수명 정보 없음',
      coat: json['characteristics']['Coat'] ?? '코트 정보 없음',
      iqRank: json['characteristics']['iqRank'] ?? 'iq 정보 없음'
    );
  }
}



Future<List<Dog>> loadDogs() async {
  try {

    final String response = await rootBundle.loadString('asset/dog_information.json');
    final List<dynamic> data = json.decode(response);


    return data.map((json) => Dog.fromJson(json)).toList();
  } catch (e) {
    print("Error loading dogs: $e");
    rethrow;
  }
}
