import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:submarine_flutter/screens/home/widgets/tab_bar.dart';
import 'package:submarine_flutter/screens/home/widgets/top_bar.dart';
import '../../providers/app_provider.dart';
import '../../theme.dart';
import 'package:submarine_flutter/screens/home/widgets/control/voice_control_screen.dart';
import 'widgets/map/gps_map_screen.dart';
import 'widgets/history/history_screen.dart';

class MainShell extends StatelessWidget {
  const MainShell({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();

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
          const HomeTopBar(),

          // ── Tab bar
          const HomeTabBar(),

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
}
