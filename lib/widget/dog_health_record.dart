import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

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
  DateTime? selectedDate;
  String dateText = '날짜 선택';
  String? errorText;

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
                  TextEditingController memoController = TextEditingController();

                  return StatefulBuilder(
                    builder: (BuildContext context, StateSetter setDialogState) {
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
                                // 날짜 선택 캘린더
                                SfCalendar(
                                  todayHighlightColor: Colors.transparent,
                                  todayTextStyle: TextStyle(
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
                                    labelStyle: const TextStyle(color: Colors.black),
                                    errorText: errorText, // 오류 메시지 표시
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
                                // 메모가 비어 있을 때 오류 메시지 처리
                                setDialogState(() {
                                  setState(() {
                                    errorText = '메모를 입력해주세요.';
                                  });
                                });
                              } else {
                                widget.onAddRecord({
                                  'date': dateText,
                                  'memo': memoController.text,
                                });
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
