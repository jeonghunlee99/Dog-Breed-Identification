import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'custom_snackbar.dart';
import 'dog_health_record_dialog.dart';


class HealthRecordWidget extends StatefulWidget {
  const HealthRecordWidget({super.key});

  @override
  State<HealthRecordWidget> createState() => _HealthRecordWidgetState();
}

enum SortOption { byAdded, byNewest, byOldest }

class _HealthRecordWidgetState extends State<HealthRecordWidget> {
  DateTime? selectedDate;
  String dateText = '${DateTime.now().year}-${DateTime.now().month}-${DateTime.now().day}'; // 오늘 날짜로 초기화
  String? errorText;
  SortOption _sortOption = SortOption.byAdded;

  Stream<List<Map<String, String>>> _getHealthRecords() {
    final User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return Stream.value([]);
    }

    return FirebaseFirestore.instance
        .collection('dogs')
        .doc(user.uid)
        .snapshots()
        .map((snapshot) {
      if (snapshot.exists) {
        var data = snapshot.data();
        var healthRecords = data?['health'] as List<dynamic>? ?? [];

        return healthRecords.map((record) {
          return {
            'date': record['date']?.toString() ?? '',
            'memo': record['memo']?.toString() ?? '',
          };
        }).toList();
      } else {
        return [];
      }
    });
  }

  DateTime parseDate(String dateStr) {
    try {
      // 'yyyy-MM-dd' 형식으로 날짜를 변환
      return DateFormat('yyyy-MM-dd').parse(dateStr);
    } catch (e) {
      // 오류가 발생하면 기본 현재 날짜로 처리
      return DateTime.now();
    }
  }

  List<Map<String, String>> _sortRecords(
      List<Map<String, String>> records, SortOption sortOption) {
    switch (sortOption) {
      case SortOption.byNewest:
        records.sort((a, b) {
          DateTime dateA = parseDate(a['date']!); // 날짜 포맷 처리
          DateTime dateB = parseDate(b['date']!); // 날짜 포맷 처리
          return dateB.compareTo(dateA); // 최신 순으로 비교
        });
        break;
      case SortOption.byOldest:
        records.sort((a, b) {
          DateTime dateA = parseDate(a['date']!); // 날짜 포맷 처리
          DateTime dateB = parseDate(b['date']!); // 날짜 포맷 처리
          return dateA.compareTo(dateB); // 오래된 순으로 비교
        });
        break;
      case SortOption.byAdded:
        break; // 추가된 순서는 그대로 두기
    }
    return records;
  }


  Future<void> _deleteHealthRecord(String date, String memo) async {
    final User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      CustomSnackBar.show(
        context,
        message: '로그인이 필요합니다.',
        backgroundColor: Colors.red,
        icon: Icons.error,
      );
      return;
    }

    try {
      final userDocRef =
      FirebaseFirestore.instance.collection('dogs').doc(user.uid);

      await userDocRef.update({
        'health': FieldValue.arrayRemove([
          {'date': date, 'memo': memo},
        ]),
      });
      CustomSnackBar.show(
        context,
        message: '건강 기록이 삭제되었습니다.',
        backgroundColor: Colors.red,
        icon: Icons.check_circle,
      );
    } catch (e) {
      CustomSnackBar.show(
        context,
        message: '오류가 발생했습니다: $e',
        backgroundColor: Colors.red,
        icon: Icons.error,
      );
      print('$e');
    }
  }

  Future<void> _saveHealthRecord(String date, String memo) async {
    final User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      CustomSnackBar.show(
        context,
        message: '로그인이 필요합니다.',
        backgroundColor: Colors.red,
        icon: Icons.error,
      );
      return;
    }

    try {
      final userDocRef =
      FirebaseFirestore.instance.collection('dogs').doc(user.uid);

      await userDocRef.update({
        'health': FieldValue.arrayUnion([
          {'date': date, 'memo': memo},
        ]),
      });
      CustomSnackBar.show(
        context,
        message: '건강 기록이 저장되었습니다.',
        backgroundColor: Colors.green,
        icon: Icons.check_circle,
      );
    } catch (e) {
      CustomSnackBar.show(
        context,
        message: '오류가 발생했습니다: $e',
        backgroundColor: Colors.red,
        icon: Icons.error,
      );
      print('$e');
    }
  }


  @override
  Widget build(BuildContext context) {
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
            style: ButtonStyle(
              backgroundColor: WidgetStateProperty.all(Colors.white),
            ),
            onPressed: () {
              setState(() {
                errorText = null;
              });

              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return HealthRecordDialog(
                    onSave: (date, memo) {
                      _saveHealthRecord(date, memo);
                    },
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
                value: _sortOption,
                onChanged: (SortOption? newOption) {
                  if (newOption != null) {
                    setState(() {
                      _sortOption = newOption;
                    });
                  }
                },
                items: const [
                  DropdownMenuItem(
                    value: SortOption.byAdded,
                    child: Text('추가된 순서'),
                  ),
                  DropdownMenuItem(
                    value: SortOption.byNewest,
                    child: Text('최신 날짜 순'),
                  ),
                  DropdownMenuItem(
                    value: SortOption.byOldest,
                    child: Text('오래된 날짜 순'),
                  ),
                ],
                style: const TextStyle(color: Colors.black),
                dropdownColor: Colors.white,
              ),
            ],
          ),
          const SizedBox(height: 10),
          StreamBuilder<List<Map<String, String>>>(
            stream: _getHealthRecords(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const CircularProgressIndicator();
              }

              if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}');
              }

              var records = snapshot.data ?? [];
              records = _sortRecords(records, _sortOption);

              return ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: records.length,
                itemBuilder: (context, index) {
                  final record = records[index];
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
                          child: Text('${record['date']}: ${record['memo']}'),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () {
                            _deleteHealthRecord(
                                record['date']!, record['memo']!);
                          },
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}
