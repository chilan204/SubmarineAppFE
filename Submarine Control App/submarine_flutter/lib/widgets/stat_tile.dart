import 'package:flutter/material.dart';
import '../theme.dart';

// Single metric tile used in the 4-metric row on VoiceControlScreen
class StatTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const StatTile({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.surface.withOpacity(0.7),
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 11, color: color),
              const SizedBox(width: 3),
              Text(
                label,
                style: TextStyle(
                  fontSize: 9,
                  letterSpacing: 0.5,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 3),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
