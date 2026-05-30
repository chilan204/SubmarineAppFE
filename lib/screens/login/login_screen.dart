import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:submarine_flutter/screens/login/widgets/header.dart';
import '../../providers/app_provider.dart';
import '../../theme.dart';
import '../../widgets/background_wrapper.dart';
import '../../widgets/lang_toggle.dart';
import 'widgets/login_mode_content.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  LoginMode _mode = LoginMode.select;

  void _resetToSelect() {
    setState(() => _mode = LoginMode.select);
  }

  @override
  Widget build(BuildContext context) {
    final appProvider = context.watch<AppProvider>();
    final lang = appProvider.lang;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          const LoginBackdrop(),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 32),
              child: Column(
                children: [
                  const Header(),
                  const SizedBox(height: 32),
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.surface.withOpacity(0.85),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.border),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 250),
                      child: LoginModeContent(
                        mode: _mode,
                        onBackToSelect: _resetToSelect,
                        onVoiceTap: () => setState(() => _mode = LoginMode.voice),
                        onPasswordTap: () => setState(() => _mode = LoginMode.password),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            top: MediaQuery.of(context).padding.top + 12,
            right: 16,
            child: LangToggle(
              lang: lang,
              onChanged: (l) => context.read<AppProvider>().setLang(l),
            ),
          ),
        ],
      ),
    );
  }
}
