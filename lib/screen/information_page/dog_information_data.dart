import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';


final dogsProvider = FutureProvider<List<Dog>>((ref) async {
  final String response = await rootBundle.loadString('asset/dog_information.json');
  final List<dynamic> data = json.decode(response);
  return data.map((json) => Dog.fromJson(json)).toList();
});
final selectedOriginProvider = StateProvider<String?>((ref) => "러시아");


class Dog {
  final String name;
  final String imageUrl;
  final String description;
  final String size;
  final String temperament;
  final String lifeSpan;
  final String coat;
  final int iqRank;
  final String origin;
  Dog({
    required this.name,
    required this.imageUrl,
    required this.description,
    required this.size,
    required this.temperament,
    required this.lifeSpan,
    required this.coat,
    required this.iqRank,
    required this.origin
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
        iqRank: json['characteristics']['iqRank'] ?? 'iq 정보 없음',
        origin: json['origin'] ?? '나라 정보 없음'
    );
  }
}




