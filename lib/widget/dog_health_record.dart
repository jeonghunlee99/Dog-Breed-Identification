import 'package:flutter/material.dart';

class HealthRecordWidget extends StatefulWidget {
  final List<Map<String, String>> records;
  final Function(Map<String, String>) onAddRecord;

  const HealthRecordWidget({
    super.key,
    required this.records,
    required this.onAddRecord,
  });

  @override
  State<HealthRecordWidget> createState() => _HealthRecordWidgetState();
}

class _HealthRecordWidgetState extends State<HealthRecordWidget> {
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
              backgroundColor: MaterialStateProperty.all(Colors.white),
            ),
            onPressed: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  DateTime? selectedDate;
                  TextEditingController memoController = TextEditingController();
                  String dateText = '날짜 선택';
                  String? errorMessage;

                  return StatefulBuilder(
                    builder: (BuildContext context, StateSetter setDialogState) {
                      return AlertDialog(
                        title: const Text(
                          '날짜와 메모 추가',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                        content: SizedBox(
                          width: MediaQuery.of(context).size.width * 0.8, // 다이얼로그 폭 조정
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8.0),
                                    side: const BorderSide(color: Colors.grey),
                                  ),
                                ),
                                onPressed: () async {
                                  DateTime? picked = await showDatePicker(
                                    context: context,
                                    initialDate: DateTime.now(),
                                    firstDate: DateTime(2000),
                                    lastDate: DateTime(2100),
                                  );
                                  if (picked != null) {
                                    setDialogState(() {
                                      selectedDate = picked;
                                      dateText = '${picked.year}-${picked.month}-${picked.day}';
                                      errorMessage = null;
                                    });
                                  }
                                },
                                child: Text(
                                  dateText,
                                  style: const TextStyle(color: Colors.black, fontSize: 16),
                                ),
                              ),
                              if (errorMessage != null)
                                Padding(
                                  padding: const EdgeInsets.only(top: 8.0),
                                  child: Text(
                                    errorMessage!,
                                    style: const TextStyle(color: Colors.red),
                                  ),
                                ),
                              const SizedBox(height: 10),
                              TextField(
                                controller: memoController,
                                decoration: const InputDecoration(
                                  border: OutlineInputBorder(),
                                  labelText: '메모 입력',
                                ),
                                style: const TextStyle(fontSize: 16),
                              ),
                            ],
                          ),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: const Text(
                              '취소',
                              style: TextStyle(color: Colors.black, fontSize: 16),
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              if (selectedDate == null) {
                                setDialogState(() {
                                  errorMessage = '날짜를 선택하세요';
                                });
                              } else if (memoController.text.isNotEmpty) {
                                widget.onAddRecord({
                                  'date': dateText,
                                  'memo': memoController.text,
                                });
                                Navigator.of(context).pop();
                              }
                            },
                            child: const Text(
                              '확인',
                              style: TextStyle(color: Colors.black, fontSize: 16),
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
          const Text(
            '기록 리스트:',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          ...widget.records.map((record) => Container(
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
                    setState(() {
                      widget.records.remove(record);
                    });
                  },
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }
}
