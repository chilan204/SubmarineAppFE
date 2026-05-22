import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import '../l10n/translations.dart';
import '../providers/app_provider.dart';
import '../theme.dart';
import '../widgets/background_wrapper.dart';
import '../widgets/lang_toggle.dart';

// BackgroundWrapper is applied in main.dart — login adds grid/sonar overlay only.

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

enum _LoginMode { select, password, voice }

class _LoginScreenState extends State<LoginScreen>
    with TickerProviderStateMixin {
  _LoginMode _mode = _LoginMode.select;
  String _username = '';
  String _password = '';
  bool _showPassword = false;
  String _error = '';
  bool _isListening = false;
  String _transcript = '';
  String _voiceStatus = '';

  late AnimationController _pulseCtrl;
  late stt.SpeechToText _speech;
  bool _speechAvailable = false;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );
    _speech = stt.SpeechToText();
    _initSpeech();
  }

  Future<void> _initSpeech() async {
    _speechAvailable = await _speech.initialize();
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    _speech.stop();
    super.dispose();
  }

  void _handlePasswordLogin(AppTranslations t) {
    if (_username.trim() == 'admin' && _password == 'SUBMARINE2024') {
      setState(() => _error = '');
      context.read<AppProvider>().login();
    } else {
      setState(() => _error = t.wrongCreds);
    }
  }

  Future<void> _startVoiceRecognition(AppTranslations t, Lang lang) async {
    if (!_speechAvailable) {
      setState(() => _voiceStatus = t.voiceNotSupported);
      return;
    }
    setState(() {
      _isListening = true;
      _voiceStatus = t.listening;
      _transcript = '';
      _error = '';
    });
    _pulseCtrl.repeat();

    await _speech.listen(
      localeId: lang == Lang.vi ? 'vi_VN' : 'en_US',
      onResult: (result) {
        setState(() => _transcript = result.recognizedWords);
        if (result.finalResult) {
          final text = result.recognizedWords.toLowerCase();
          final isValid = lang == Lang.vi
              ? (text.contains('kích hoạt') || text.contains('tàu ngầm'))
              : (text.contains('activate') || text.contains('submarine'));
          if (isValid) {
            setState(() => _voiceStatus = t.authSuccess);
            Future.delayed(const Duration(milliseconds: 800), () {
              if (mounted) context.read<AppProvider>().login();
            });
          } else {
            setState(() {
              _error = t.authFailed;
              _voiceStatus = t.voiceVerifyFailed;
            });
          }
          _stopListening(t);
        }
      },
    );
  }

  void _stopListening(AppTranslations t) {
    _speech.stop();
    _pulseCtrl.stop();
    _pulseCtrl.reset();
    setState(() {
      _isListening = false;
      _voiceStatus = t.pressmic;
    });
  }

  void _resetToSelect() {
    _speech.stop();
    _pulseCtrl.stop();
    _pulseCtrl.reset();
    setState(() {
      _mode = _LoginMode.select;
      _error = '';
      _password = '';
      _username = '';
      _transcript = '';
      _isListening = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final appProvider = context.watch<AppProvider>();
    final t = appProvider.t;
    final lang = appProvider.lang;

    if (_voiceStatus.isEmpty) _voiceStatus = t.pressmic;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          const LoginBackdrop(),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              child: Column(
                children: [
                  // Header
                  _buildHeader(t),
                  const SizedBox(height: 32),

                  // Card
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.surface.withOpacity(0.85),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.border),
                    ),
                    padding: const EdgeInsets.all(24),
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 250),
                      child: _buildModeContent(t, lang),
                    ),
                  ),

                  const SizedBox(height: 24),
                  Text(
                    t.classified,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: AppColors.muted,
                      fontSize: 9,
                      letterSpacing: 2,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Language toggle (top right)
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

  Widget _buildHeader(AppTranslations t) {
    return Column(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.accentDim,
            border: Border.all(color: AppColors.accent.withOpacity(0.5), width: 2),
          ),
          child: const Icon(Icons.security, color: AppColors.accent, size: 40),
        ),
        const SizedBox(height: 16),
        const Text(
          'NAUTICOM',
          style: TextStyle(
            color: AppColors.accent,
            fontSize: 24,
            fontWeight: FontWeight.w700,
            letterSpacing: 6,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          t.loginSubtitle,
          style: const TextStyle(
            color: AppColors.muted,
            fontSize: 11,
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.accent,
              ),
            ),
            const SizedBox(width: 6),
            Text(
              t.online,
              style: const TextStyle(color: AppColors.accent, fontSize: 11),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildModeContent(AppTranslations t, Lang lang) {
    switch (_mode) {
      case _LoginMode.select:
        return _buildSelect(t);
      case _LoginMode.password:
        return _buildPassword(t);
      case _LoginMode.voice:
        return _buildVoice(t, lang);
    }
  }

  Widget _buildSelect(AppTranslations t) {
    return Column(
      key: const ValueKey('select'),
      children: [
        Text(
          t.selectAuth,
          style: const TextStyle(color: AppColors.muted, fontSize: 13),
        ),
        const SizedBox(height: 20),
        _authCard(
          icon: Icons.mic,
          title: t.voiceAuth,
          subtitle: t.voiceAuthDesc,
          color: AppColors.accent,
          onTap: () => setState(() => _mode = _LoginMode.voice),
        ),
        const SizedBox(height: 12),
        _authCard(
          icon: Icons.lock_outline,
          title: t.passwordAuth,
          subtitle: t.passwordAuthDesc,
          color: AppColors.blue,
          onTap: () => setState(() => _mode = _LoginMode.password),
        ),
      ],
    );
  }

  Widget _authCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.05),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: color.withOpacity(0.1),
                border: Border.all(color: color.withOpacity(0.3)),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 14),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(color: color, fontSize: 14)),
                const SizedBox(height: 2),
                Text(subtitle,
                    style: const TextStyle(
                        color: AppColors.muted, fontSize: 11)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPassword(AppTranslations t) {
    return Column(
      key: const ValueKey('password'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: _resetToSelect,
          child: Text(t.back,
              style: const TextStyle(color: AppColors.muted, fontSize: 12)),
        ),
        const SizedBox(height: 18),

        // Username
        Text(t.usernameLabel,
            style: const TextStyle(
                color: AppColors.blue, fontSize: 11, letterSpacing: 1)),
        const SizedBox(height: 6),
        _buildTextField(
          hintText: 'admin',
          icon: Icons.person_outline,
          onChanged: (v) => setState(() => _username = v),
          onSubmit: () => _handlePasswordLogin(t),
        ),
        const SizedBox(height: 12),

        // Password
        Text(t.passwordLabel,
            style: const TextStyle(
                color: AppColors.blue, fontSize: 11, letterSpacing: 1)),
        const SizedBox(height: 6),
        _buildTextField(
          hintText: '••••••••••••',
          icon: Icons.lock_outline,
          obscureText: !_showPassword,
          suffixIcon: IconButton(
            icon: Icon(
              _showPassword ? Icons.visibility_off : Icons.visibility,
              color: AppColors.blue.withOpacity(0.5),
              size: 20,
            ),
            onPressed: () => setState(() => _showPassword = !_showPassword),
          ),
          onChanged: (v) => setState(() => _password = v),
          onSubmit: () => _handlePasswordLogin(t),
        ),

        if (_error.isNotEmpty) ...[
          const SizedBox(height: 10),
          Row(
            children: [
              const Icon(Icons.error_outline, color: AppColors.red, size: 14),
              const SizedBox(width: 6),
              Flexible(
                child: Text(_error,
                    style: const TextStyle(
                        color: AppColors.red, fontSize: 12)),
              ),
            ],
          ),
        ],
        const SizedBox(height: 16),

        // Login button
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.blue,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () => _handlePasswordLogin(t),
            child: Text(
              t.authenticate,
              style: const TextStyle(
                  color: Colors.white,
                  letterSpacing: 2,
                  fontSize: 13),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Center(
          child: Text(t.hint,
              style: const TextStyle(
                  color: AppColors.muted, fontSize: 10)),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required String hintText,
    required IconData icon,
    bool obscureText = false,
    Widget? suffixIcon,
    required ValueChanged<String> onChanged,
    required VoidCallback onSubmit,
  }) {
    return TextField(
      obscureText: obscureText,
      style: const TextStyle(color: Colors.white, fontSize: 13),
      decoration: InputDecoration(
        hintText: hintText,
        prefixIcon: Icon(icon, color: AppColors.blue.withOpacity(0.5), size: 18),
        suffixIcon: suffixIcon,
      ),
      onChanged: onChanged,
      onSubmitted: (_) => onSubmit(),
    );
  }

  Widget _buildVoice(AppTranslations t, Lang lang) {
    return Column(
      key: const ValueKey('voice'),
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: GestureDetector(
            onTap: _resetToSelect,
            child: Text(t.back,
                style: const TextStyle(color: AppColors.muted, fontSize: 12)),
          ),
        ),
        const SizedBox(height: 16),
        Text(t.sayPhrase,
            style: const TextStyle(color: AppColors.muted, fontSize: 13)),
        const SizedBox(height: 4),
        Text(t.voicePhrase,
            style: const TextStyle(
                color: AppColors.accent,
                fontSize: 15,
                fontStyle: FontStyle.italic)),
        const SizedBox(height: 28),

        // Mic button
        _buildMicButton(t, lang),
        const SizedBox(height: 16),
        Text(_voiceStatus,
            style: const TextStyle(color: AppColors.muted, fontSize: 12)),

        if (_transcript.isNotEmpty) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.surfaceAlt,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.border),
            ),
            child: Text(
              '"$_transcript"',
              style: const TextStyle(
                  color: AppColors.accent,
                  fontSize: 13,
                  fontStyle: FontStyle.italic),
            ),
          ),
        ],

        if (_error.isNotEmpty) ...[
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: AppColors.red, size: 14),
              const SizedBox(width: 6),
              Flexible(
                child: Text(_error,
                    style: const TextStyle(
                        color: AppColors.red, fontSize: 12)),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildMicButton(AppTranslations t, Lang lang) {
    return SizedBox(
      width: 96,
      height: 96,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Pulse rings when listening
          if (_isListening)
            AnimatedBuilder(
              animation: _pulseCtrl,
              builder: (_, __) {
                return Stack(
                  alignment: Alignment.center,
                  children: [
                    for (int i = 0; i < 3; i++)
                      Opacity(
                        opacity:
                            (1 - (_pulseCtrl.value + i * 0.33) % 1.0).clamp(0, 0.5),
                        child: SizedBox(
                          width: 96 + ((_pulseCtrl.value + i * 0.33) % 1.0) * 60,
                          height: 96 + ((_pulseCtrl.value + i * 0.33) % 1.0) * 60,
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                  color: AppColors.accent.withOpacity(0.4),
                                  width: 1.5),
                            ),
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),

          // Main button
          GestureDetector(
            onTap: _isListening
                ? () => _stopListening(t)
                : () => _startVoiceRecognition(t, lang),
            child: Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _isListening
                    ? AppColors.accent.withOpacity(0.2)
                    : AppColors.accentDim,
                border: Border.all(
                  color: _isListening
                      ? AppColors.accent
                      : AppColors.accent.withOpacity(0.3),
                  width: 2,
                ),
              ),
              child: Icon(
                _isListening ? Icons.mic_off : Icons.mic,
                color: AppColors.accent,
                size: 40,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
