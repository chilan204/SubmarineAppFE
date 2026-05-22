import 'package:flutter/material.dart';
import '../theme.dart';

// Animated sound bars shown while mic is active — mirrors SoundBars() in React
class SoundBars extends StatefulWidget {
  const SoundBars({super.key});

  @override
  State<SoundBars> createState() => _SoundBarsState();
}

class _SoundBarsState extends State<SoundBars> with TickerProviderStateMixin {
  final List<double> _heights = [0.4, 0.8, 1.0, 0.6, 0.9, 0.5, 0.7];
  final List<AnimationController> _ctrls = [];
  final List<Animation<double>> _anims = [];

  @override
  void initState() {
    super.initState();
    for (int i = 0; i < _heights.length; i++) {
      final ctrl = AnimationController(
        vsync: this,
        duration: Duration(milliseconds: 400 + i * 70),
      )..repeat(reverse: true);
      _ctrls.add(ctrl);
      _anims.add(
        Tween<double>(begin: _heights[i] * 28, end: _heights[i] * 6)
            .animate(CurvedAnimation(parent: ctrl, curve: Curves.easeInOut)),
      );
    }
  }

  @override
  void dispose() {
    for (final c in _ctrls) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: List.generate(_heights.length, (i) {
        return AnimatedBuilder(
          animation: _anims[i],
          builder: (_, __) => Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2),
            child: Container(
              width: 4,
              height: _anims[i].value,
              decoration: BoxDecoration(
                color: AppColors.accent,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
        );
      }),
    );
  }
}
