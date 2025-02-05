import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dog_information_data.dart';

class DogInformationPage extends ConsumerStatefulWidget {
  final String category;

  const DogInformationPage({super.key, required this.category});

  @override
  ConsumerState<DogInformationPage> createState() => _DogInformationPageState();
}

class _DogInformationPageState extends ConsumerState<DogInformationPage> {
  @override
  Widget build(BuildContext context) {
    final dogsAsyncValue = ref.watch(dogsProvider);
    final selectedOrigin = ref.watch(selectedOriginProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          '${widget.category} 강아지',
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // 검색 기능 추가 예정
            },
          ),
        ],
      ),
      body: dogsAsyncValue.when(
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
                    child: DropdownButton<String>(
                      value: selectedOrigin,
                      hint: const Text('나라 선택'),
                      items: origins.map((origin) {
                        return DropdownMenuItem<String>(
                          value: origin,
                          child: Text(origin),
                        );
                      }).toList(),
                      onChanged: (value) {
                        ref.read(selectedOriginProvider.notifier).state = value;
                      },
                    ),
                  ),
                ),
              Expanded(
                child: filteredDogs.isEmpty
                    ? const Center(child: Text('해당 카테고리에 데이터가 없습니다.'))
                    : PageView.builder(
                  itemCount: filteredDogs.length,
                  itemBuilder: (context, index) {
                    final dog = filteredDogs[index];
                    return Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        elevation: 5,
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Center(
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: dog.imageUrl.isNotEmpty
                                      ? Image.asset(
                                    dog.imageUrl,
                                    width: 200,
                                    height: 200,
                                    fit: BoxFit.cover,
                                  )
                                      : const Icon(Icons.pets, size: 100, color: Colors.grey),
                                ),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                dog.name,
                                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                dog.description,
                                style: const TextStyle(fontSize: 16),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                '출신 나라: ${dog.origin}',
                                style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                              ),
                              Text(
                                'IQ 순위: ${dog.iqRank}위',
                                style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                              ),
                            ],
                          ),
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
