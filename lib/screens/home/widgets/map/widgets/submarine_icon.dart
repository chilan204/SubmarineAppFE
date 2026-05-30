import 'dart:math' as math;
import 'package:flutter/material.dart';

import 'submarine_painter.dart';

class SubmarineIcon extends StatelessWidget {
  final double heading;

  const SubmarineIcon({
    super.key,
    required this.heading,
  });

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: (heading - 90) * math.pi / 180,
      child: const SizedBox(
        width: 48,
        height: 48,
        child: CustomPaint(
          painter: SubmarinePainter(),
        ),
      ),
    );
  }
}