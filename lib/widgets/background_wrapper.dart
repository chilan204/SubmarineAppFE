import 'package:flutter/material.dart';
import '../theme.dart';

/// Same background image + dark overlay as BackgroundWrapper.tsx
const _bgUrl =
    'https://vcdn1-vnexpress.vnecdn.net/2021/09/15/dh-bach-khoa-hn-1631681053-7873-1631681129.jpg?w=1200&h=0&q=100&dpr=1&fit=crop&s=k9j2tKkGTVtI12aYpD1mgA';

class BackgroundWrapper extends StatelessWidget {
  final Widget child;
  const BackgroundWrapper({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Image.network(
          _bgUrl,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => Container(color: AppColors.background),
        ),
        Container(color: AppColors.background.withValues(alpha: 0.8)),
        child,
      ],
    );
  }
}

/// Grid + sonar rings shown on the login screen (LoginScreen.tsx)
class LoginBackdrop extends StatelessWidget {
  const LoginBackdrop({super.key});

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Stack(
        children: [
          Positioned.fill(child: CustomPaint(painter: _LoginGridPainter())),
          Center(
            child: SizedBox(
              width: 600,
              height: 600,
              child: CustomPaint(painter: _StaticSonarPainter()),
            ),
          ),
        ],
      ),
    );
  }
}

class _LoginGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.accent.withValues(alpha: 0.1)
      ..strokeWidth = 1;
    const step = 50.0;
    for (double x = 0; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter _) => false;
}

class _StaticSonarPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final rings = [
      (300.0, 0.05),
      (200.0, 0.08),
      (100.0, 0.12),
    ];
    for (final (r, opacity) in rings) {
      canvas.drawCircle(
        Offset(cx, cy),
        r,
        Paint()
          ..color = AppColors.accent.withValues(alpha: opacity)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter _) => false;
}
