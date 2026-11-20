import 'package:flutter/material.dart';

/// Simple placeholder illustration drawn with code (no image files needed).
/// Replace with your real artwork later.
class SunsetIllustration extends StatelessWidget {
  const SunsetIllustration({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(painter: _SunsetPainter(), size: Size.infinite);
  }
}

class _SunsetPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Sky
    final sky = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFFB9A8FF), Color(0xFFFFB3C7), Color(0xFFFFE0A3)],
      ).createShader(Offset.zero & size);
    canvas.drawRect(Offset.zero & size, sky);

    // Sun
    canvas.drawCircle(
      Offset(w * 0.5, h * 0.62),
      w * 0.2,
      Paint()..color = const Color(0xFFFFD27D),
    );

    // Water (covers the lower part of the sun)
    canvas.drawRect(
      Rect.fromLTWH(0, h * 0.7, w, h * 0.3),
      Paint()..color = const Color(0xFF8E7CF0),
    );

    // Hills
    final hills = Paint()..color = const Color(0xFF6C5CE7);
    canvas.drawPath(
      Path()
        ..moveTo(0, h * 0.7)
        ..quadraticBezierTo(w * 0.18, h * 0.42, w * 0.4, h * 0.7)
        ..close(),
      hills,
    );
    canvas.drawPath(
      Path()
        ..moveTo(w * 0.55, h * 0.7)
        ..quadraticBezierTo(w * 0.8, h * 0.46, w, h * 0.7)
        ..close(),
      hills,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
