import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; // FirebaseAuth 사용

class TimerWidget extends StatefulWidget {
  final void Function(Duration duration) onWalkComplete;

  const TimerWidget({super.key, required this.onWalkComplete});

  @override
  State<TimerWidget> createState() => _TimerWidgetState();
}

class _TimerWidgetState extends State<TimerWidget> {
  Duration _duration = Duration.zero;
  bool _isRunning = false;
  bool _isWalkCompleted = false;
  late final Stopwatch _stopwatch;

  @override
  void initState() {
    super.initState();
    _stopwatch = Stopwatch();
  }

  // FirebaseAuth 인스턴스를 사용하여 로그인 상태 확인
  void _checkLoginStatus() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      // 로그인이 안 되어 있으면 커스텀 SnackBar로 메시지 표시
      _showCustomSnackBar("로그인 후 타이머 기능을 사용할 수 있습니다.", Colors.red);
    }
  }

  void _startTimer() {
    _checkLoginStatus(); // 로그인 상태 체크

    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        _isRunning = true;
        _stopwatch.start();
        _isWalkCompleted = false;
      });
      Future.delayed(const Duration(milliseconds: 100), _updateTimer);
    }
  }

  void _stopTimer() {
    setState(() {
      _isRunning = false;
      _stopwatch.stop();
      _isWalkCompleted = true;
    });
  }

  void _updateTimer() {
    if (_isRunning) {
      setState(() {
        _duration = _stopwatch.elapsed;
      });
      Future.delayed(const Duration(milliseconds: 100), _updateTimer);
    }
  }

  void _resetTimer() {
    _checkLoginStatus(); // 로그인 상태 체크

    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        _duration = Duration.zero;
        _stopwatch.reset();
        _isWalkCompleted = false;
      });
    }
  }

  void _completeWalk() {
    widget.onWalkComplete(_duration);
    setState(() {
      _isWalkCompleted = false;
      _resetTimer();
    });
    _showCustomSnackBar("산책이 완료되었습니다!", Colors.green);
  }

  void _showCustomSnackBar(String message, Color backgroundColor) {
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
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "산책 시간: ${_duration.inMinutes}:${(_duration.inSeconds % 60).toString().padLeft(2, '0')}",
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
              onPressed: _isRunning ? _stopTimer : _startTimer,
              child: Text(
                _isRunning ? '중지' : '시작',
                style: const TextStyle(color: Colors.white),
              ),
            ),
            const SizedBox(width: 16),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.brown[400],
              ),
              onPressed: _resetTimer,
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
            backgroundColor: _isWalkCompleted ? Colors.green : Colors.grey,
          ),
          onPressed: _isRunning ? null : (_isWalkCompleted ? _completeWalk : null), // 시작 중이거나 완료되지 않으면 비활성화
          child: Text(
            _isWalkCompleted ? '산책 완료' : '산책 완료',
            style: const TextStyle(color: Colors.white),
          ),
        ),
      ],
    );
  }
}
