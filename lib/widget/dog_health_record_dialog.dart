import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

// 상태 관리용 StateNotifier 및 Provider 정의
final healthRecordProvider =
StateNotifierProvider<HealthRecordNotifier, HealthRecordState>(
      (ref) => HealthRecordNotifier(),
);

class HealthRecordState {
  final String date;
  final String memo;
  final String? errorText;

  HealthRecordState({
    required this.date,
    required this.memo,
    this.errorText,
  });

  // 초기 상태를 반환하는 정적 메서드
  factory HealthRecordState.initial() {
    final now = DateTime.now();
    return HealthRecordState(
      date: '${now.year}-${now.month}-${now.day}',
      memo: '',
      errorText: null,
    );
  }
}

class HealthRecordNotifier extends StateNotifier<HealthRecordState> {
  HealthRecordNotifier() : super(HealthRecordState.initial());

  void updateDate(String newDate) {
    state = HealthRecordState(
      date: newDate,
      memo: state.memo,
      errorText: state.errorText,
    );
  }

  void updateMemo(String newMemo) {
    state = HealthRecordState(
      date: state.date,
      memo: newMemo,
      errorText: null, // 입력 시 에러 메시지 초기화
    );
  }

  void setError(String errorMessage) {
    state = HealthRecordState(
      date: state.date,
      memo: state.memo,
      errorText: errorMessage,
    );
  }

  void reset() {
    state = HealthRecordState.initial();
  }
}

// HealthRecordDialog 위젯
class HealthRecordDialog extends ConsumerWidget {
  final void Function(String date, String memo) onSave;

  const HealthRecordDialog({Key? key, required this.onSave}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final healthRecordState = ref.watch(healthRecordProvider);
    final healthRecordNotifier = ref.read(healthRecordProvider.notifier);

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
                    healthRecordNotifier.updateDate(newDate);
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
                onChanged: (value) => healthRecordNotifier.updateMemo(value),
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
                  errorText: healthRecordState.errorText,
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
            if (healthRecordState.memo.isEmpty) {
              // 에러 상태 업데이트
              healthRecordNotifier.setError('메모를 입력해주세요.');
            } else {
              onSave(healthRecordState.date, healthRecordState.memo);
              healthRecordNotifier.reset(); // 상태 초기화
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
            healthRecordNotifier.reset(); // 상태 초기화
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
