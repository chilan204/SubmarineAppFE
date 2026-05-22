import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:submarine_flutter/theme.dart';
import 'package:submarine_flutter/widgets/lang_toggle.dart';
import '../../../l10n/translations.dart';
import '../../../providers/app_provider.dart';

class TopBar extends StatelessWidget {
  const TopBar({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final t = provider.t;

    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 6,
        left: 12,
        right: 12,
        bottom: 8,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFF050f1e).withOpacity(0.7),
        border: const Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        spacing: 10,
        children: [
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
          ),

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
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                  style: const TextStyle(
                      color: AppColors.muted, fontSize: 9, letterSpacing: 1),
                ),
              ],
            ),
          ),

          LangToggle(
            lang: provider.lang,
            onChanged: (l) => context.read<AppProvider>().setLang(l),
          ),

          GestureDetector(
            onTap: () => context.read<AppProvider>().logout(),
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
                  if (MediaQuery.of(context).size.width >= 640) ...[
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
    );
  }
}