import 'package:flutter/material.dart';
import 'dart:math' as math;

class CustomCircularIndicator extends StatefulWidget {
  @override
  _CustomCircularIndicatorState createState() => _CustomCircularIndicatorState();
}

class _CustomCircularIndicatorState extends State<CustomCircularIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          painter: CircularPainter(_controller.value),
          size: const Size(50, 50),
        );
      },
    );
  }
}


class CircularPainter extends CustomPainter {
  final double progress;

  CircularPainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..shader = const RadialGradient(
        colors: [Colors.blue, Colors.lightBlueAccent, Colors.white],
        radius: 1.5,
      ).createShader(Rect.fromCircle(
        center: size.center(Offset.zero),
        radius: size.width / 2,
      ))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6.0
      ..strokeCap = StrokeCap.round;

    final double startAngle = -math.pi / 2;
    final double sweepAngle = 2 * math.pi * progress;
    canvas.drawArc(Offset.zero & size, startAngle, sweepAngle, false, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
