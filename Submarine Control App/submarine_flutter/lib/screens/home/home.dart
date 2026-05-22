import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:submarine_flutter/screens/home/widgets/top_bar.dart';
import '../../l10n/translations.dart';
import '../../providers/app_provider.dart';
import '../../theme.dart';
import '../voice_control_screen.dart';
import '../gps_map_screen.dart';
import '../history_screen.dart';

class MainShell extends StatelessWidget {
  const MainShell({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final t = provider.t;

    const screens = [
      VoiceControlScreen(),
      GpsMapScreen(),
      HistoryScreen(),
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          // ── Top bar
          const TopBar(),

          // ── Tab bar
          _buildTabBar(context, provider, t),

          // ── Screen content (IndexedStack keeps state alive)
          Expanded(
            child: IndexedStack(
              index: provider.activeTab,
              children: screens,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar(
      BuildContext ctx, AppProvider provider, AppTranslations t) {
    final tabs = [
      (icon: Icons.mic_outlined, label: t.control),
      (icon: Icons.map_outlined, label: t.map),
      (icon: Icons.history, label: t.history),
    ];

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF0a1628).withOpacity(0.7),
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        children: List.generate(tabs.length, (i) {
          final isActive = provider.activeTab == i;
          return Expanded(
            child: GestureDetector(
              onTap: () => ctx.read<AppProvider>().setActiveTab(i),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: isActive
                      ? AppColors.accent.withOpacity(0.05)
                      : Colors.transparent,
                  border: Border(
                    bottom: BorderSide(
                      color: isActive ? AppColors.accent : Colors.transparent,
                      width: 2,
                    ),
                  ),
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          tabs[i].icon,
                          color: isActive ? AppColors.accent : AppColors.muted,
                          size: 20,
                        ),
                        const SizedBox(height: 3),
                        Text(
                          tabs[i].label.toUpperCase(),
                          style: TextStyle(
                            color: isActive
                                ? AppColors.accent
                                : AppColors.muted,
                            fontSize: 9,
                            letterSpacing: 0.8,
                          ),
                        ),
                      ],
                    ),

                    // History badge
                    if (i == 2 && provider.commandHistory.isNotEmpty)
                      Positioned(
                        top: 0,
                        right: 24,
                        child: Container(
                          width: 16,
                          height: 16,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.accent,
                          ),
                          child: Center(
                            child: Text(
                              provider.commandHistory.length > 9
                                  ? '9+'
                                  : '${provider.commandHistory.length}',
                              style: const TextStyle(
                                color: AppColors.background,
                                fontSize: 9,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
