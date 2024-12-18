import 'package:flutter/material.dart';

class TimerWidget extends StatefulWidget {
  final void Function(Duration duration) onWalkComplete; // Duration으로 변경

  const TimerWidget({super.key, required this.onWalkComplete});

  @override
  State<TimerWidget> createState() => _TimerWidgetState();
}

class _TimerWidgetState extends State<TimerWidget> {
  Duration _duration = Duration.zero;
  bool _isRunning = false;
  late final Stopwatch _stopwatch;

  @override
  void initState() {
    super.initState();
    _stopwatch = Stopwatch();
  }

  void _startTimer() {
    setState(() {
      _isRunning = true;
      _stopwatch.start();
    });

    Future.delayed(const Duration(milliseconds: 100), _updateTimer);
  }

  void _stopTimer() {
    setState(() {
      _isRunning = false;
      _stopwatch.stop();
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
    setState(() {
      _duration = Duration.zero;
      _stopwatch.reset();
    });
  }

  void _completeWalk() {
    widget.onWalkComplete(_duration); // 걸린 시간을 전달
    _resetTimer();
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
              style:ElevatedButton.styleFrom(
                  backgroundColor: Colors.brown[400]
              ),
              onPressed: _isRunning ? _stopTimer : _startTimer,
              child: Text(
                _isRunning ? '중지' : '시작',
                style: const TextStyle(color: Colors.white), // 텍스트 색상
              ),
            ),
            const SizedBox(width: 16),
            ElevatedButton(
              style:ElevatedButton.styleFrom(
                backgroundColor: Colors.brown[400]
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
          style:ElevatedButton.styleFrom(
              backgroundColor: Colors.brown[400]
          ),
          onPressed: _isRunning ? null : _completeWalk,
          child: const Text(
            '산책 완료',
            style: TextStyle(color: Colors.white),
          ),
        ),
      ],
    );
  }
}





