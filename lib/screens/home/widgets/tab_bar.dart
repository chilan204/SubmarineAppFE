import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:submarine_flutter/theme.dart';
import '../../../providers/app_provider.dart';

class HomeTabBar extends StatelessWidget {
  const HomeTabBar({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final t = provider.t;

    final tabs = [
      (icon: Icons.mic_outlined, label: t.control),
      (icon: Icons.map_outlined, label: t.map),
      (icon: Icons.history, label: t.history),
    ];

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF0a1628).withValues(alpha: 0.7),
        border: const Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        children: [
          for (var i = 0; i < tabs.length; i++)
            Expanded(
              child: _HomeTabBarItem(
                icon: tabs[i].icon,
                label: tabs[i].label,
                isActive: provider.activeTab == i,
                onTap: () => context.read<AppProvider>().setActiveTab(i),
              ),
            ),
        ],
      ),
    );
  }
}

class _HomeTabBarItem extends StatelessWidget {
  const _HomeTabBarItem({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  Color get _foreground =>
      isActive ? AppColors.accent : AppColors.muted;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isActive
              ? AppColors.accent.withValues(alpha: 0.05)
              : Colors.transparent,
          border: Border(
            bottom: BorderSide(
              color: isActive ? AppColors.accent : Colors.transparent,
              width: 2,
            ),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: _foreground, size: 20),
            const SizedBox(height: 3),
            Text(
              label.toUpperCase(),
              style: TextStyle(
                color: _foreground,
                fontSize: 9,
                letterSpacing: 0.8,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
