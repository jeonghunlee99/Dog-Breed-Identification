import 'dart:convert';
import 'package:dog_breed_identification/class/dog.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final dogsProvider = FutureProvider<List<Dog>>((ref) async {
  final String response = await rootBundle.loadString('asset/dog_information.json');
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
        backgroundColor: Colors.white,
        title: Text('${widget.category} 강아지'),
        centerTitle: true,
      ),
      body: Container(
        color: Colors.white,
        child: dogsAsyncValue.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stackTrace) => const Center(child: Text('데이터를 불러오지 못했습니다.')),
          data: (dogs) {
            final List<String> origins = dogs.map((dog) => dog.origin).toSet().toList();
            origins.sort();

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
                  Align(
                    alignment: Alignment.centerRight,
                    child: Padding(
                      padding: const EdgeInsets.only(right: 16.0, top: 10.0),
                      child: SizedBox(
                        height: 40,
                        child: MenuBar(
                          style: MenuStyle(
                            backgroundColor: WidgetStateProperty.all(Colors.white),
                          ),
                          children: [
                            SubmenuButton(
                              alignmentOffset: const Offset(-3, 10),
                              menuStyle: MenuStyle(
                                backgroundColor: WidgetStateProperty.all(Colors.white),
                                padding: WidgetStateProperty.all<EdgeInsets>(
                                  const EdgeInsets.only(top: 10.0),
                                ),
                              ),
                              menuChildren: origins.map((origin) {
                                return MenuItemButton(
                                  style: ButtonStyle(
                                    backgroundColor: WidgetStateProperty.all(Colors.white),
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      selectedOrigin = origin;
                                    });
                                  },
                                  child: SizedBox(
                                    width: 100,
                                    child: Text(
                                      origin,
                                      style: const TextStyle(fontSize: 16, color: Colors.black),
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                      softWrap: false,
                                    ),
                                  ),
                                );
                              }).toList(),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(5),
                                  border: Border.all(color: Colors.black54),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      selectedOrigin ?? '나라 선택',
                                      style: const TextStyle(fontSize: 16, color: Colors.black),
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                      softWrap: false,
                                    ),
                                    const SizedBox(width: 5),
                                    const Icon(Icons.arrow_drop_down, size: 24, color: Colors.black),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
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
                        color: Colors.white, // 🔹 카드 배경 흰색
                        margin: const EdgeInsets.all(10),
                        child: ListTile(
                          tileColor: Colors.white, // 🔹 ListTile 배경 흰색
                          leading: SizedBox(
                            width: 50,
                            height: 100,
                            child: dog.imageUrl.isNotEmpty
                                ? Image.asset(
                              dog.imageUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                              const Icon(Icons.error),
                            )
                                : const Icon(Icons.pets, size: 50),
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
      ),
    );
  }
}
