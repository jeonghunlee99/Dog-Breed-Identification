import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

class HealthRecordDialog extends StatefulWidget {
  final void Function(String date, String memo) onSave;

  const HealthRecordDialog({Key? key, required this.onSave}) : super(key: key);

  @override
  State<HealthRecordDialog> createState() => _HealthRecordDialogState();
}

class _HealthRecordDialogState extends State<HealthRecordDialog> {
  DateTime? selectedDate = DateTime.now();
  String dateText =
      '${DateTime.now().year}-${DateTime.now().month}-${DateTime.now().day}';
  String? errorText;
  final TextEditingController memoController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text(
        '날짜와 메모 추가',
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
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
                  setState(() {
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
                      color: const Color.fromARGB(255, 68, 140, 255), width: 2),
                  borderRadius: const BorderRadius.all(Radius.circular(4)),
                  shape: BoxShape.rectangle,
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: memoController,
                decoration: InputDecoration(
                  border: const OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.black),
                  ),
                  focusedBorder: const OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.black),
                  ),
                  enabledBorder: const OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.black),
                  ),
                  labelText: '메모 입력',
                  labelStyle: const TextStyle(color: Colors.black),
                  errorText: errorText,
                ),
                style: const TextStyle(fontSize: 16, color: Colors.black),
                keyboardType: TextInputType.text,
                textInputAction: TextInputAction.done,
                cursorColor: Colors.black,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            if (memoController.text.isEmpty) {
              setState(() {
                errorText = '메모를 입력해주세요.';
              });
            } else {
              widget.onSave(dateText, memoController.text);
              Navigator.of(context).pop();
            }
          },
          child: const Text(
            '확인',
            style: TextStyle(color: Colors.black, fontSize: 16),
          ),
        ),
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text(
            '취소',
            style: TextStyle(color: Colors.black, fontSize: 16),
          ),
        ),
      ],
    );
  }
}
