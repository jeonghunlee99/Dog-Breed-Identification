import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'health_memo_add_dialog_controller.dart';
import 'health_memo_add_dialog_data.dart';


class HealthRecordDialog extends ConsumerStatefulWidget {
  const HealthRecordDialog({super.key});

  @override
  ConsumerState<HealthRecordDialog> createState() => _HealthRecordDialogState();
}

class _HealthRecordDialogState extends ConsumerState<HealthRecordDialog> {
  late HealthMemoAddDialogController healthMemoAddDialogController;

  @override
  void initState() {
    super.initState();
    healthMemoAddDialogController = HealthMemoAddDialogController(ref: ref);
  }
  @override
  Widget build(BuildContext context) {
    String date = ref.watch(selectedDateProvider);
    String memo = ref.watch(memoProvider);
    String? errorText = ref.watch(errorTextProvider);

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
                  color: Color.fromARGB(255, 68, 140, 255),
                ),
                view: CalendarView.month,
                showNavigationArrow: true,
                initialSelectedDate: DateTime.now(),
                onTap: (details) {
                  if (details.date != null) {
                    final newDate =
                        '${details.date!.year}-${details.date!.month}-${details.date!.day}';
                    ref.read(selectedDateProvider.notifier).state = newDate;
                  }
                },
                selectionDecoration: BoxDecoration(
                  color: Colors.transparent,
                  border: Border.all(
                    color: const Color.fromARGB(255, 68, 140, 255),
                    width: 2,
                  ),
                  borderRadius: const BorderRadius.all(Radius.circular(4)),
                  shape: BoxShape.rectangle,
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                onChanged: (value) {
                  ref.read(memoProvider.notifier).state = value;
                  ref.read(errorTextProvider.notifier).state = null; // 에러 초기화
                },
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
                  errorBorder: const OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.red),
                  ),
                  focusedErrorBorder: const OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.red),
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
          onPressed: () async {
            if (date.isEmpty) {
              ref.read(errorTextProvider.notifier).state = '날짜를 선택해주세요.';
            } else if (memo.isEmpty) {
              ref.read(errorTextProvider.notifier).state = '메모를 입력해주세요.';
            } else {
              await healthMemoAddDialogController.saveHealthRecord(parentContext: context, date: ref.read(selectedDateProvider), memo:memo);
              resultValue();
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
            resultValue();
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

  void resultValue() {
    ref.read(selectedDateProvider.notifier).state = '';
    ref.read(memoProvider.notifier).state = '';
    ref.read(errorTextProvider.notifier).state = null;
  }
}