import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

// HealthRecordState 정의
class HealthRecordState {
  final String date;
  final String memo;

  HealthRecordState({
    required this.date,
    required this.memo,
  });
}

// 상태 관리용 StateProvider 정의
final selectedDateProvider = StateProvider<String>((ref) => '');
final memoProvider = StateProvider<String>((ref) => '');
final errorTextProvider = StateProvider<String?>((ref) => null);
final healthRecordProvider =
    StateProvider<List<HealthRecordState>>((ref) => []);

class HealthRecordDialog extends ConsumerStatefulWidget {
  final void Function(String date, String memo) onSave;

  const HealthRecordDialog({Key? key, required this.onSave}) : super(key: key);

  @override
  ConsumerState<HealthRecordDialog> createState() => _HealthRecordDialogState();
}

class _HealthRecordDialogState extends ConsumerState<HealthRecordDialog> {

  void resultValue() {
    ref.read(selectedDateProvider.notifier).state = '';
    ref.read(memoProvider.notifier).state = '';
  }

  @override
  Widget build(BuildContext context) {
    final selectedDate = ref.watch(selectedDateProvider);
    final memo = ref.watch(memoProvider);
    final errorText = ref.watch(errorTextProvider);

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
          onPressed: () {
            if (ref.read(selectedDateProvider).isEmpty) {
              ref.read(errorTextProvider.notifier).state = '날짜를 선택해주세요.';
            } else if (memo.isEmpty) {
              ref.read(errorTextProvider.notifier).state = '메모를 입력해주세요.';
            } else {
              final newRecord = HealthRecordState(
                date: selectedDate,
                memo: memo,
              );

              // 상태 업데이트
              ref.read(healthRecordProvider.notifier).state = [
                ...ref.read(healthRecordProvider),
                newRecord,
              ];
              resultValue();
              widget.onSave(selectedDate, memo);
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
