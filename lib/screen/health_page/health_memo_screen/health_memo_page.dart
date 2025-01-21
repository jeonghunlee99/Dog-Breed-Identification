import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../health_add_memo_dialog/health_memo_add_dialog_page.dart';
import 'health_memo_controller.dart';
import 'health_memo_data.dart';

class HealthRecordWidget extends ConsumerStatefulWidget {
  const HealthRecordWidget({super.key});

  @override
  HealthRecordWidgetState createState() => HealthRecordWidgetState();
}

class HealthRecordWidgetState extends ConsumerState<HealthRecordWidget> {
  late HealthMemoController healthMemoController;

  @override
  void initState() {
    super.initState();
    healthMemoController = HealthMemoController(ref: ref);
    healthMemoController.loadHealthRecords();
  }

  @override
  Widget build(BuildContext context) {
    final sortOption = ref.watch(sortOptionProvider);
    final healthRecords = _sortRecords(ref.watch(healthRecordProvider), sortOption);

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: ListView(
        children: [
          const Text(
            '강아지 건강 기록',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.white),
            onPressed: () {
              showDialog(
                context: context,
                builder: (dialogContext) {
                  return const HealthRecordDialog();
                },
              );
            },
            child: const Text(
              '건강 기록 하기',
              style: TextStyle(color: Colors.black),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                '기록 리스트:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              MenuAnchor(
                alignmentOffset: const Offset(20, 10),
                builder: (context, controller, child) {
                  return SizedBox(
                    width: 150,
                    child: ElevatedButton(
                      onPressed: () {
                        if (controller.isOpen) {
                          controller.close();
                        } else {
                          controller.open();
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        elevation: 1,
                        padding: const EdgeInsets.symmetric(vertical: 12), // 고정 높이 설정
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8), // 둥근 모서리
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // 정렬 텍스트
                          Text(
                            _getSortOptionText(sortOption).isEmpty
                                ? '정렬 기준 선택'
                                : _getSortOptionText(sortOption),
                            style: const TextStyle(color: Colors.black),
                          ),
                          const SizedBox(width: 8), // 텍스트와 아이콘 사이 여백
                          // 드롭다운 화살표 아이콘
                          AnimatedRotation(
                            turns: controller.isOpen ? 0.5 : 0, // 메뉴가 열리면 화살표가 아래로 회전
                            duration: const Duration(milliseconds: 200),
                            child: const Icon(Icons.arrow_drop_down, color: Colors.black),
                          ),
                        ],
                      ),
                    ),
                  );
                },
                menuChildren: [
                  MenuItemButton(
                    onPressed: () {
                      ref.read(sortOptionProvider.notifier).state = SortOption.byAdded;
                    },
                    child: const Text('추가된 순서'),
                  ),
                  MenuItemButton(
                    onPressed: () {
                      ref.read(sortOptionProvider.notifier).state = SortOption.byNewest;
                    },
                    child: const Text('최신 날짜 순'),
                  ),
                  MenuItemButton(
                    onPressed: () {
                      ref.read(sortOptionProvider.notifier).state = SortOption.byOldest;
                    },
                    child: const Text('오래된 날짜 순'),
                  ),
                ],
                style: MenuStyle(
                  backgroundColor: WidgetStateProperty.all(Colors.white),
                ),
              ),

            ],
          ),
          const SizedBox(height: 10),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: healthRecords.length,
            itemBuilder: (context, index) {
              final record = healthRecords[index];
              return Container(
                margin: const EdgeInsets.symmetric(vertical: 8.0),
                padding: const EdgeInsets.all(12.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text('${record.date}: ${record.memo}'),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () async {
                        await healthMemoController.deleteHealthRecord(
                          context: context,
                          date: record.memo,
                          memo: record.date,
                        );
                      },
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  DateTime _parseDate(String dateStr) {
    try {
      return DateFormat('yyyy-MM-dd').parse(dateStr);
    } catch (e) {
      return DateTime.now();
    }
  }

  List<HealthRecordState> _sortRecords(List<HealthRecordState> records, SortOption sortOption) {
    switch (sortOption) {
      case SortOption.byNewest:
        records.sort((a, b) => _parseDate(b.date).compareTo(_parseDate(a.date)));
        break;
      case SortOption.byOldest:
        records.sort((a, b) => _parseDate(a.date).compareTo(_parseDate(b.date)));
        break;
      case SortOption.byAdded:
        break; // 그대로 유지
    }
    return records;
  }

  String _getSortOptionText(SortOption sortOption) {
    switch (sortOption) {
      case SortOption.byAdded:
        return '추가된 순서';
      case SortOption.byNewest:
        return '최신 날짜 순';
      case SortOption.byOldest:
        return '오래된 날짜 순';
      default:
        return '정렬 기준 선택';
    }
  }
}
