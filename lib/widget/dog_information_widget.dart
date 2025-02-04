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

class DogInformationPage extends ConsumerStatefulWidget {
  final String category;

  const DogInformationPage({super.key, required this.category});

  @override
  ConsumerState<DogInformationPage> createState() => _DogInformationPageState();
}

class _DogInformationPageState extends ConsumerState<DogInformationPage> {
  String? selectedOrigin = "러시아";

  @override
  Widget build(BuildContext context) {
    final dogsAsyncValue = ref.watch(dogsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.category} 강아지'),
        centerTitle: true,
      ),
      body: dogsAsyncValue.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) =>
        const Center(child: Text('데이터를 불러오지 못했습니다.')),
        data: (dogs) {
          // 중복 제거한 나라 목록 가져오기
          final List<String> origins = dogs.map((dog) => dog.origin).toSet().toList();
          origins.sort(); // 나라 정렬

          // 선택된 나라에 따라 필터링
          final filteredDogs = dogs.where((dog) {
            if (widget.category == '소형' || widget.category == '중형' || widget.category == '대형') {
              return dog.size.contains(widget.category);
            } else if (widget.category == '장모종' || widget.category == '단모종') {
              return dog.coat.contains(widget.category);
            } else if (widget.category == 'IQ 순위') {
              return true;
            } else if (widget.category == '나라별' && selectedOrigin != null) {
              return dog.origin == selectedOrigin;
            }
            return false;
          }).toList();

          if (widget.category == 'IQ 순위') {
            filteredDogs.sort((a, b) => a.iqRank.compareTo(b.iqRank));
          }

          return Column(
            children: [
              if (widget.category == '나라별')
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: DropdownButton<String>(
                    value: selectedOrigin, // 기본값 적용됨
                    isExpanded: true,
                    items: origins.map((origin) {
                      return DropdownMenuItem<String>(
                        value: origin,
                        child: Text(origin),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedOrigin = value;
                      });
                    },
                  ),
                ),
              Expanded(
                child: filteredDogs.isEmpty
                    ? const Center(child: Text('해당 카테고리에 데이터가 없습니다.'))
                    : ListView.builder(
                  itemCount: filteredDogs.length,
                  itemBuilder: (context, index) {
                    final dog = filteredDogs[index];
                    return Card(
                      margin: const EdgeInsets.all(10),
                      child: ListTile(
                        leading: SizedBox(
                          width: 50,
                          height: 100,
                          child: dog.imageUrl.isNotEmpty
                              ? Image.asset(
                            dog.imageUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => const Icon(Icons.error),
                          )
                              : const Icon(Icons.pets, size: 50), // 기본 아이콘 추가
                        ),
                        title: Text(
                          dog.name,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          '${dog.description}\n출신 나라: ${dog.origin}\nIQ 순위: ${dog.iqRank.toString()}위',
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
