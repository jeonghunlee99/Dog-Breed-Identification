import 'dart:convert';

import 'package:dog_breed_identification/class/dog.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final dogsProvider = FutureProvider<List<Dog>>((ref) async {
  final String response =
      await rootBundle.loadString('asset/dog_information.json');
  final List<dynamic> data = json.decode(response);
  return data.map((json) => Dog.fromJson(json)).toList();
});

class DogInformationPage extends ConsumerWidget {
  final String category;

  const DogInformationPage({super.key, required this.category});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dogsAsyncValue = ref.watch(dogsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('$category 강아지'),
        centerTitle: true,
      ),
      body: dogsAsyncValue.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) =>
            const Center(child: Text('데이터를 불러오지 못했습니다.')),
        data: (dogs) {
          final filteredDogs = dogs.where((dog) {
            if (category == '소형' || category == '중형' || category == '대형') {
              return dog.size.contains(category);
            } else if (category == '장모종' || category == '단모종') {
              return dog.coat.contains(category);
            } else if (category == 'IQ 순위') {
              return true;
            }
            return false;
          }).toList();

          if (category == 'IQ 순위') {
            filteredDogs.sort((a, b) {
              return a.iqRank.compareTo(b.iqRank);
            });
          }

          if (filteredDogs.isEmpty) {
            return const Center(child: Text('해당 카테고리에 데이터가 없습니다.'));
          }

          return ListView.builder(
            itemCount: filteredDogs.length,
            itemBuilder: (context, index) {
              final dog = filteredDogs[index];
              return Card(
                margin: EdgeInsets.all(10),
                child: ListTile(
                  leading: Image.network(dog.imageUrl,
                      width: 50, height: 50, fit: BoxFit.cover),
                  title: Text(dog.name,
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(
                      '${dog.description}\nIQ 순위:  ${dog.iqRank.toString()}위'),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
