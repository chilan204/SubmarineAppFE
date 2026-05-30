import 'package:flutter/material.dart';
import '../../../../../theme.dart';

class MicButton extends StatefulWidget {
  final bool isListening;
  final VoidCallback? onTap;

  const MicButton({
    super.key,
    required this.isListening,
    this.onTap,
  });

  @override
  State<MicButton> createState() => _MicButtonState();
}

class _MicButtonState extends State<MicButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
  }

  @override
  void didUpdateWidget(covariant MicButton oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.isListening && !_ctrl.isAnimating) {
      _ctrl.repeat();
    } else if (!widget.isListening) {
      _ctrl.stop();
      _ctrl.reset();
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: SizedBox(
        width: 52,
        height: 52,
        child: Stack(
          alignment: Alignment.center,
          children: [
            if (widget.isListening)
              AnimatedBuilder(
                animation: _ctrl,
                builder: (_, __) => Stack(
                  alignment: Alignment.center,
                  children: List.generate(3, (i) {
                    final t = (_ctrl.value + i * 0.33) % 1.0;

                    return Opacity(
                      opacity: (1 - t).clamp(0, 0.6),
                      child: SizedBox(
                        width: 52 + t * 40,
                        height: 52 + t * 40,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppColors.accent.withOpacity(0.5),
                              width: 1.5,
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ),
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: widget.isListening
                    ? AppColors.accent.withOpacity(0.2)
                    : AppColors.accentDim,
                border: Border.all(
                  color: widget.isListening
                      ? AppColors.accent
                      : AppColors.accent.withOpacity(0.3),
                  width: 2,
                ),
              ),
              child: Icon(
                widget.isListening ? Icons.mic_off : Icons.mic,
                color: AppColors.accent,
                size: 22,
              ),
            ),
          ],
        ),
      ),
    );
  }
}