import 'package:flutter/material.dart';

import '../history_filter_type.dart';
import '../../../../../theme.dart';

class HistoryFilterTab extends StatelessWidget {
  final HistoryFilterType type;
  final HistoryFilterType selectedFilter;
  final String label;
  final int count;
  final Color activeColor;
  final ValueChanged<HistoryFilterType> onTap;

  const HistoryFilterTab({
    super.key,
    required this.type,
    required this.selectedFilter,
    required this.label,
    required this.count,
    required this.activeColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isActive = selectedFilter == type;

    return Expanded(
      child: GestureDetector(
        onTap: () => onTap(type),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isActive
                  ? activeColor.withValues(alpha: 0.4)
                  : AppColors.border.withValues(alpha: 0.3),
            ),
            color: isActive
                ? activeColor.withValues(alpha: 0.1)
                : Colors.transparent,
          ),
          child: Column(
            children: [
              Text(
                '$count',
                style: TextStyle(
                  color: isActive ? activeColor : AppColors.muted,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                label,
                style: TextStyle(
                  color: isActive ? activeColor : AppColors.muted,
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}