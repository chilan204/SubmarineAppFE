import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../l10n/translations.dart';
import '../providers/app_provider.dart';
import '../theme.dart';
import '../widgets/lang_toggle.dart';
import 'voice_control_screen.dart';
import 'gps_map_screen.dart';
import 'history_screen.dart';

class MainShell extends StatelessWidget {
  const MainShell({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final t = provider.t;

    final screens = const [
      VoiceControlScreen(),
      GpsMapScreen(),
      HistoryScreen(),
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          // ── Top bar
          _buildTopBar(context, provider, t),

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

  Widget _buildTopBar(
      BuildContext ctx, AppProvider provider, AppTranslations t) {
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(ctx).padding.top + 6,
        left: 12,
        right: 12,
        bottom: 8,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFF050f1e).withOpacity(0.7),
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        children: [
          // Left: "Sĩ Quan" on narrow screens only (sm:hidden in React)
          if (MediaQuery.of(ctx).size.width < 640)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.accentDim,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.border),
              ),
              child: Text(
                provider.lang == Lang.vi ? 'Sĩ Quan' : 'Officer',
                style: const TextStyle(
                    color: AppColors.accent, fontSize: 11, letterSpacing: 1),
              ),
            )
          else
            const SizedBox(width: 32),

          // Center: mission timer
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  provider.formattedMissionTime,
                  style: const TextStyle(
                    color: AppColors.amber,
                    fontSize: 16,
                    letterSpacing: 2,
                  ),
                ),
                Text(
                  t.missionTime,
                  style: const TextStyle(
                      color: AppColors.muted, fontSize: 9, letterSpacing: 1),
                ),
              ],
            ),
          ),

          // Right: lang toggle + command count + logout
          Row(
            children: [
              LangToggle(
                lang: provider.lang,
                onChanged: (l) => ctx.read<AppProvider>().setLang(l),
              ),
              const SizedBox(width: 8),

              // Command counter badge
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.blueDim,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.borderBlue),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.sensors, color: AppColors.blue, size: 12),
                    const SizedBox(width: 4),
                    Text(
                      '${provider.commandHistory.length} ${t.commandCount}',
                      style: const TextStyle(
                          color: AppColors.blue, fontSize: 10),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),

              // Logout
              GestureDetector(
                onTap: () => ctx.read<AppProvider>().logout(),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 6),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                        color: AppColors.red.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.logout,
                          color: AppColors.red, size: 16),
                      if (MediaQuery.of(ctx).size.width >= 640) ...[
                        const SizedBox(width: 4),
                        Text(
                          t.logout,
                          style: TextStyle(
                            color: AppColors.red.withValues(alpha: 0.7),
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
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
