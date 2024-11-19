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
              return dog.size.contains(category);
            }).toList();

            return ListView.builder(
              itemCount: filteredDogs.length,
              itemBuilder: (context, index) {
                final dog = filteredDogs[index];
                return Card(
                  margin: EdgeInsets.all(10),
                  child: ListTile(
                    leading: Image.network(dog.imageUrl, width: 50, height: 50, fit: BoxFit.cover),
                    title: Text(dog.name, style: TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(dog.description),
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
