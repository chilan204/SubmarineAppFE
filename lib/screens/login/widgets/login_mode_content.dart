import 'package:flutter/material.dart';

import 'select.dart';
import 'password/password.dart';
import 'voice/voice.dart';

enum LoginMode { select, password, voice }

class LoginModeContent extends StatelessWidget {
  final LoginMode mode;
  final VoidCallback onBackToSelect;
  final VoidCallback onVoiceTap;
  final VoidCallback onPasswordTap;

  const LoginModeContent({
    super.key,
    required this.mode,
    required this.onBackToSelect,
    required this.onVoiceTap,
    required this.onPasswordTap,
  });

  @override
  Widget build(BuildContext context) {
    switch (mode) {
      case LoginMode.select:
        return Select(
          onVoiceTap: onVoiceTap,
          onPasswordTap: onPasswordTap,
        );

      case LoginMode.password:
        return Password(onBack: onBackToSelect);

      case LoginMode.voice:
        return Voice(onBack: onBackToSelect);
    }
  }
}