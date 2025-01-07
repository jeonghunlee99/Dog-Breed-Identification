import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../screen/data/dog_walk_data.dart';



class TimerWidget extends ConsumerWidget {
  final void Function(Duration duration) onWalkComplete;

  const TimerWidget({super.key, required this.onWalkComplete});

  void _checkLoginStatus(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      _showCustomSnackBar(
        context,
        "로그인 후 타이머 기능을 사용할 수 있습니다.",
        Colors.red,
      );
    }
  }

  void _startTimer(BuildContext context, WidgetRef ref) {
    _checkLoginStatus(context);

    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      ref.read(isRunningProvider.notifier).state = true;
      _updateTimer(context, ref);
    }
  }

  void _stopTimer(WidgetRef ref) {
    ref.read(isRunningProvider.notifier).state = false;
    ref.read(isWalkCompletedProvider.notifier).state = true;
  }

  void _resetTimer(BuildContext context, WidgetRef ref) {
    _checkLoginStatus(context);

    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      ref.read(durationProvider.notifier).state = Duration.zero;
      ref.read(isWalkCompletedProvider.notifier).state = false;
    }
  }

  void _updateTimer(BuildContext context, WidgetRef ref) async {
    if (ref.read(isRunningProvider)) {
      final stopwatch = Stopwatch()..start();
      await Future.delayed(const Duration(milliseconds: 100));
      ref.read(durationProvider.notifier).state += stopwatch.elapsed;
      stopwatch.stop();
      _updateTimer(context, ref);
    }
  }

  void _completeWalk(BuildContext context, WidgetRef ref) {
    final duration = ref.read(durationProvider);
    onWalkComplete(duration);
    ref.read(isWalkCompletedProvider.notifier).state = false;
    _resetTimer(context, ref);
    _showCustomSnackBar(context, "산책이 완료되었습니다!", Colors.green);
  }

  void _showCustomSnackBar(BuildContext context, String message, Color backgroundColor) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              backgroundColor == Colors.green ? Icons.check_circle : Icons.error,
              color: Colors.white,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
        backgroundColor: backgroundColor,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.only(bottom: 50, left: 20, right: 20),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final duration = ref.watch(durationProvider);
    final isRunning = ref.watch(isRunningProvider);
    final isWalkCompleted = ref.watch(isWalkCompletedProvider);

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "산책 시간: ${duration.inMinutes}:${(duration.inSeconds % 60).toString().padLeft(2, '0')}",
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.brown[400],
              ),
              onPressed: isRunning ? () => _stopTimer(ref) : () => _startTimer(context, ref),
              child: Text(
                isRunning ? '중지' : '시작',
                style: const TextStyle(color: Colors.white),
              ),
            ),
            const SizedBox(width: 16),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.brown[400],
              ),
              onPressed: () => _resetTimer(context, ref),
              child: const Text(
                '초기화',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: isWalkCompleted ? Colors.green : Colors.grey,
          ),
          onPressed: isRunning ? null : (isWalkCompleted ? () => _completeWalk(context, ref) : null),
          child: Text(
            isWalkCompleted ? '산책 완료' : '산책 완료',
            style: const TextStyle(color: Colors.white),
          ),
        ),
      ],
    );
  }
}
