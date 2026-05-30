import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:submarine_flutter/theme.dart';
import '../../../providers/app_provider.dart';

class Header extends StatelessWidget {
  const Header({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final t = provider.t;

    return Column(
      children: [
        const SizedBox(height: 30),
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.accentDim,
            border: Border.all(color: AppColors.accent.withValues(alpha: 0.5), width: 2),
          ),
          child: const Icon(Icons.security, color: AppColors.accent, size: 50),
        ),
        const SizedBox(height: 30),
        Text(
          t.loginSubtitle,
          style: const TextStyle(
            color: AppColors.accent,
            fontSize: 17,
          ),
        ),
      ],
    );
  }
}