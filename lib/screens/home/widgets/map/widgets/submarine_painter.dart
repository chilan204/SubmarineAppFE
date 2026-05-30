import 'package:flutter/material.dart';

import '../../../../../theme.dart';

class SubmarinePainter extends CustomPainter {
  const SubmarinePainter();

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;

    canvas.drawCircle(
      Offset(cx, cy),
      16,
      Paint()
        ..color = AppColors.accent.withValues(alpha: 0.3)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    );

    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(cx, cy + 2),
        width: 28,
        height: 12,
      ),
      Paint()..color = AppColors.accent.withValues(alpha: 0.9),
    );

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(cx, cy - 4),
          width: 8,
          height: 10,
        ),
        const Radius.circular(2),
      ),
      Paint()..color = const Color(0xFF00cc88),
    );

    canvas.drawCircle(
      Offset(cx, cy + 2),
      3,
      Paint()..color = AppColors.background,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}