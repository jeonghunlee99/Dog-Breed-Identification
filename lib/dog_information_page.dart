import 'package:dog_breed_identification/dog.dart';
import 'package:flutter/material.dart';

class DogInformationPage extends StatelessWidget {
  final String category;

  const DogInformationPage({super.key, required this.category});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('$category 강아지'),
        centerTitle: true,
      ),
      body: FutureBuilder<List<Dog>>(
        future: loadDogs(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return const Center(child: Text('데이터를 불러오지 못했습니다.'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('해당 카테고리에 데이터가 없습니다.'));
          } else {

            final filteredDogs = snapshot.data!.where((dog) {
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
              filteredDogs.sort((a, b) => a.iqRank.compareTo(b.iqRank));
            }

            if (filteredDogs.isEmpty) {
              return const Center(child: Text('해당 카테고리에 데이터가 없습니다.'));
            }
            print("Filtered dogs count: ${filteredDogs.length}");
            filteredDogs.forEach((dog) {
              print("Dog name: ${dog.name}, Category: $category");
            });

            return ListView.builder(
              itemCount: filteredDogs.length,
              itemBuilder: (context, index) {
                final dog = filteredDogs[index];
                return Card(
                  margin: EdgeInsets.all(10),
                  child: ListTile(
                    leading: Image.network(dog.imageUrl, width: 50, height: 50, fit: BoxFit.cover),
                    title: Text(dog.name, style: TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text('${dog.description}\nIQ 순위: ${dog.iqRank}위'),
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}
