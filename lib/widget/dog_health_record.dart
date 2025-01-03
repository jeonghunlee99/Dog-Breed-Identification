import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'custom_snackbar.dart';
import 'dog_health_record_dialog.dart';

enum SortOption { byAdded, byNewest, byOldest }

// SortOption 상태를 관리하기 위한 Riverpod StateProvider
final sortOptionProvider = StateProvider<SortOption>((ref) => SortOption.byAdded);

// HealthRecord 상태를 관리하기 위한 Riverpod StateProvider
final healthRecordProvider = StateProvider<List<HealthRecordState>>((ref) => []);

class HealthRecordState {
  final String date;
  final String memo;

  HealthRecordState({required this.date, required this.memo});
}

class HealthRecordWidget extends ConsumerStatefulWidget {
  const HealthRecordWidget({Key? key}) : super(key: key);

  @override
  _HealthRecordWidgetState createState() => _HealthRecordWidgetState();
}

class _HealthRecordWidgetState extends ConsumerState<HealthRecordWidget> {
  @override
  void initState() {
    super.initState();
    _loadHealthRecords();
  }

  Future<void> _loadHealthRecords() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      final userDoc = await FirebaseFirestore.instance.collection('dogs').doc(user.uid).get();
      if (userDoc.exists) {
        final data = userDoc.data();
        final healthRecords = data?['health'] as List<dynamic>? ?? [];
        final parsedRecords = healthRecords.map<HealthRecordState>((record) {
          return HealthRecordState(
            date: record['date']?.toString() ?? '',
            memo: record['memo']?.toString() ?? '',
          );
        }).toList();
        ref.read(healthRecordProvider.notifier).state = parsedRecords;
      }
    } catch (e) {
      debugPrint('Error loading health records: $e');
    }
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

  Future<void> _saveHealthRecord(BuildContext parentContext, String date, String memo) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      CustomSnackBar.show(
        parentContext,
        message: '로그인이 필요합니다.',
        backgroundColor: Colors.red,
        icon: Icons.error,
      );
      return;
    }

    try {
      final userDocRef = FirebaseFirestore.instance.collection('dogs').doc(user.uid);

      await userDocRef.update({
        'health': FieldValue.arrayUnion([
          {'date': date, 'memo': memo},
        ]),
      });

      ref.read(healthRecordProvider.notifier).state = [
        ...ref.read(healthRecordProvider),
        HealthRecordState(date: date, memo: memo),
      ];

      CustomSnackBar.show(
        parentContext,
        message: '건강 기록이 저장되었습니다.',
        backgroundColor: Colors.green,
        icon: Icons.check_circle,
      );
    } catch (e) {
      CustomSnackBar.show(
        parentContext,
        message: '오류가 발생했습니다: $e',
        backgroundColor: Colors.red,
        icon: Icons.error,
      );
    }
  }

  Future<void> _deleteHealthRecord(BuildContext context, String date, String memo) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      CustomSnackBar.show(context, message: '로그인이 필요합니다.', backgroundColor: Colors.red, icon: Icons.error);
      return;
    }

    try {
      final userDocRef = FirebaseFirestore.instance.collection('dogs').doc(user.uid);

      await userDocRef.update({
        'health': FieldValue.arrayRemove([
          {'date': date, 'memo': memo},
        ]),
      });

      ref.read(healthRecordProvider.notifier).state = ref
          .read(healthRecordProvider)
          .where((record) => record.date != date || record.memo != memo)
          .toList();

      CustomSnackBar.show(context, message: '건강 기록이 삭제되었습니다.', backgroundColor: Colors.red, icon: Icons.check_circle);
    } catch (e) {
      CustomSnackBar.show(context, message: '오류가 발생했습니다: $e', backgroundColor: Colors.red, icon: Icons.error);
    }
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
                  return HealthRecordDialog(
                    onSave: (date, memo) => _saveHealthRecord(context, date, memo),
                  );
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
              DropdownButton<SortOption>(
                value: sortOption,
                onChanged: (newOption) {
                  if (newOption != null) {
                    ref.read(sortOptionProvider.notifier).state = newOption;
                  }
                },
                items: const [
                  DropdownMenuItem(value: SortOption.byAdded, child: Text('추가된 순서')),
                  DropdownMenuItem(value: SortOption.byNewest, child: Text('최신 날짜 순')),
                  DropdownMenuItem(value: SortOption.byOldest, child: Text('오래된 날짜 순')),
                ],
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
                      onPressed: () => _deleteHealthRecord(context, record.date, record.memo),
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
}
