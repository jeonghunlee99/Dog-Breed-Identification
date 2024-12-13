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
                  TextEditingController memoController =
                  TextEditingController();
                  String dateText = '날짜 선택';

                  return StatefulBuilder(
                    builder: (BuildContext context, StateSetter setDialogState) {
                      return AlertDialog(
                        title: const Text('날짜와 메모 추가'),
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            ElevatedButton(
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
                                    dateText =
                                    '${picked.year}-${picked.month}-${picked.day}';
                                  });
                                }
                              },
                              child: Text(dateText),
                            ),
                            const SizedBox(height: 10),
                            TextField(
                              controller: memoController,
                              decoration: const InputDecoration(
                                border: OutlineInputBorder(),
                                labelText: '메모 입력',
                              ),
                            ),
                          ],
                        ),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: const Text('취소'),
                          ),
                          TextButton(
                            onPressed: () {
                              if (selectedDate != null &&
                                  memoController.text.isNotEmpty) {
                                widget.onAddRecord({
                                  'date': dateText,
                                  'memo': memoController.text,
                                });
                              }
                              Navigator.of(context).pop();
                            },
                            child: const Text('확인'),
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
          ...widget.records.map((record) => ListTile(
            title: Text('${record['date']}: ${record['memo']}'),
            trailing: IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () {
                setState(() {
                  widget.records.remove(record);
                });
              },
            ),
          )),
        ],
      ),
    );
  }
}
