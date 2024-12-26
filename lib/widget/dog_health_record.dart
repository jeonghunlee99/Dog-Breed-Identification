import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

class HealthRecordWidget extends StatefulWidget {
  const HealthRecordWidget({super.key});

  @override
  State<HealthRecordWidget> createState() => _HealthRecordWidgetState();
}

enum SortOption { byAdded, byNewest, byOldest }

class _HealthRecordWidgetState extends State<HealthRecordWidget> {
  DateTime? selectedDate;
  String dateText = '날짜 선택';
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

  List<Map<String, String>> _sortRecords(
      List<Map<String, String>> records, SortOption sortOption) {
    switch (sortOption) {
      case SortOption.byNewest:
        records.sort((a, b) => b['date']!.compareTo(a['date']!));
        break;
      case SortOption.byOldest:
        records.sort((a, b) => a['date']!.compareTo(b['date']!));
        break;
      case SortOption.byAdded:
        break;
    }
    return records;
  }

  Future<void> _deleteHealthRecord(String date, String memo) async {
    final User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('로그인이 필요합니다.')),
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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('건강 기록이 삭제되었습니다.')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('오류가 발생했습니다: $e')),
      );
      print('$e');
    }
  }

  Future<void> _saveHealthRecord(String date, String memo) async {
    final User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('로그인이 필요합니다.')),
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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('건강 기록이 저장되었습니다.')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('오류가 발생했습니다: $e')),
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
                  TextEditingController memoController =
                      TextEditingController();

                  return StatefulBuilder(
                    builder:
                        (BuildContext context, StateSetter setDialogState) {
                      return AlertDialog(
                        title: const Text(
                          '날짜와 메모 추가',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 20),
                        content: SingleChildScrollView(
                          child: SizedBox(
                            width: MediaQuery.of(context).size.width * 0.8,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                SfCalendar(
                                  todayHighlightColor: Colors.transparent,
                                  todayTextStyle: const TextStyle(
                                      color: Color.fromARGB(255, 68, 140, 255)),
                                  view: CalendarView.month,
                                  showNavigationArrow: true,
                                  initialSelectedDate: DateTime.now(),
                                  onTap: (details) {
                                    setDialogState(() {
                                      selectedDate = details.date;
                                      if (selectedDate != null) {
                                        dateText =
                                            '${selectedDate!.year}-${selectedDate!.month}-${selectedDate!.day}';
                                      }
                                    });
                                  },
                                  selectionDecoration: BoxDecoration(
                                    color: Colors.transparent,
                                    border: Border.all(
                                        color: const Color.fromARGB(
                                            255, 68, 140, 255),
                                        width: 2),
                                    borderRadius: const BorderRadius.all(
                                        Radius.circular(4)),
                                    shape: BoxShape.rectangle,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                TextField(
                                  controller: memoController,
                                  decoration: InputDecoration(
                                    border: const OutlineInputBorder(
                                      borderSide:
                                          BorderSide(color: Colors.black),
                                    ),
                                    focusedBorder: const OutlineInputBorder(
                                      borderSide:
                                          BorderSide(color: Colors.black),
                                    ),
                                    enabledBorder: const OutlineInputBorder(
                                      borderSide:
                                          BorderSide(color: Colors.black),
                                    ),
                                    labelText: '메모 입력',
                                    labelStyle:
                                        const TextStyle(color: Colors.black),
                                    errorText: errorText,
                                  ),
                                  style: const TextStyle(
                                      fontSize: 16, color: Colors.black),
                                  keyboardType: TextInputType.text,
                                  textInputAction: TextInputAction.done,
                                  cursorColor: Colors.black,
                                )
                              ],
                            ),
                          ),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () {
                              if (memoController.text.isEmpty) {
                                setDialogState(() {
                                  setState(() {
                                    errorText = '메모를 입력해주세요.';
                                  });
                                });
                              } else {
                                _saveHealthRecord(
                                    dateText, memoController.text);
                                Navigator.of(context).pop();
                              }
                            },
                            child: const Text(
                              '확인',
                              style:
                                  TextStyle(color: Colors.black, fontSize: 16),
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: const Text(
                              '취소',
                              style:
                                  TextStyle(color: Colors.black, fontSize: 16),
                            ),
                          ),
                        ],
                      );
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
