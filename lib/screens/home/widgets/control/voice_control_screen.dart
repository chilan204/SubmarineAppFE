import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:record/record.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import '../../../../l10n/translations.dart';
import '../../../../models/command.dart';
import '../../../../models/voice_command_response.dart';
import '../../../../providers/app_provider.dart';
import '../../../../services/telemetry_service.dart';
import '../../../../services/voice_command_service.dart';
import '../../../../theme.dart';
import '../../../../utils/audio_file.dart';
import '../../../../widgets/sound_bars.dart';
import '../../../../widgets/stat_tile.dart';

// Command parsing — mirrors parseCommand() in VoiceControlScreen.tsx
Map<String, dynamic> _parseCommand(String text, Lang lang) {
  final lower = text.toLowerCase();
  final cmdsVi = <String, Map<String, dynamic>>{
    'lặn xuống': {'response': 'Đang thực hiện lặn xuống. Độ sâu mục tiêu: -50m', 'status': CommandStatus.success},
    'nổi lên': {'response': 'Đang nổi lên. Độ sâu mục tiêu: 0m', 'status': CommandStatus.success},
    'tiến': {'response': 'Động cơ đẩy kích hoạt. Tốc độ 5 hải lý/h', 'status': CommandStatus.success},
    'dừng': {'response': 'Hệ thống đẩy dừng. Giữ vị trí hiện tại', 'status': CommandStatus.success},
    'quay trái': {'response': 'Bánh lái trái 15°. Đang điều hướng', 'status': CommandStatus.success},
    'quay phải': {'response': 'Bánh lái phải 15°. Đang điều hướng', 'status': CommandStatus.success},
    'phóng ngư lôi': {'response': 'CẢNH BÁO: Cần xác nhận từ chỉ huy cấp cao', 'status': CommandStatus.warning},
    'tàng hình': {'response': 'Hệ thống âm học tắt. Chế độ im lặng kích hoạt', 'status': CommandStatus.success},
    'kiểm tra': {'response': 'Tất cả hệ thống bình thường. Pin: 87%. Oxy: 94%', 'status': CommandStatus.success},
    'khẩn cấp': {'response': 'KHẨN CẤP: Thổi két nước dằn. Nổi lên khẩn cấp!', 'status': CommandStatus.error},
  };
  final cmdsEn = <String, Map<String, dynamic>>{
    'dive': {'response': 'Executing dive. Target depth: -50m', 'status': CommandStatus.success},
    'surface': {'response': 'Surfacing. Target depth: 0m', 'status': CommandStatus.success},
    'forward': {'response': 'Propulsion engaged. Speed: 5 knots', 'status': CommandStatus.success},
    'stop': {'response': 'Propulsion stopped. Holding current position', 'status': CommandStatus.success},
    'turn left': {'response': 'Rudder left 15°. Navigating', 'status': CommandStatus.success},
    'turn right': {'response': 'Rudder right 15°. Navigating', 'status': CommandStatus.success},
    'torpedo': {'response': 'WARNING: Requires senior command confirmation', 'status': CommandStatus.warning},
    'stealth': {'response': 'Acoustic systems off. Silent mode activated', 'status': CommandStatus.success},
    'check': {'response': 'All systems normal. Battery: 87%. Oxygen: 94%', 'status': CommandStatus.success},
    'emergency': {'response': 'EMERGENCY: Blowing ballast tanks. Emergency ascent!', 'status': CommandStatus.error},
  };

  final cmds = lang == Lang.vi ? cmdsVi : cmdsEn;
  for (final entry in cmds.entries) {
    if (lower.contains(entry.key)) return entry.value;
  }
  return lang == Lang.vi
      ? {'response': 'Lệnh nhận được: "$text". Đang xử lý...', 'status': CommandStatus.success}
      : {'response': 'Command received: "$text". Processing...', 'status': CommandStatus.success};
}

class VoiceControlScreen extends StatefulWidget {
  const VoiceControlScreen({super.key});

  @override
  State<VoiceControlScreen> createState() => _VoiceControlScreenState();
}

class _VoiceControlScreenState extends State<VoiceControlScreen> {
  final List<Command> _commands = [];
  bool _isListening = false;
  bool _isSending = false;
  String _transcript = '';
  String _inputText = '';
  String _status = '';
  double _depth = -35;
  double _speed = 4.2;
  double _heading = 247;
  double _pressure = 3.5;

  late stt.SpeechToText _speech;
  bool _speechReady = false;
  final ScrollController _scrollCtrl = ScrollController();
  final TextEditingController _textCtrl = TextEditingController();

  // Audio recording for WAV capture
  final AudioRecorder _audioRecorder = AudioRecorder();
  String? _recordPath;
  final VoiceCommandService _voiceCommandService = VoiceCommandService();

  // WebSocket telemetry — shared data source with GpsMapScreen
  late final TelemetryService _telemetry;
  StreamSubscription<TelemetryData>? _telemetrySub;

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
    _initSpeech();

    // Connect to WebSocket for real-time telemetry
    _telemetry = TelemetryService();
    _telemetry.connect();
    _telemetrySub = _telemetry.stream.listen(_onTelemetryData);
  }

  Future<void> _initSpeech() async {
    _speechReady = await _speech.initialize();
  }

  /// Update metrics from WebSocket telemetry data.
  void _onTelemetryData(TelemetryData data) {
    if (!mounted) return;
    setState(() {
      _depth = data.depth;
      _speed = data.speed;
      _heading = data.heading;
      _pressure = data.pressure;
    });
  }

  @override
  void dispose() {
    _telemetrySub?.cancel();
    _telemetry.dispose();
    _speech.stop();
    _audioRecorder.dispose();
    _scrollCtrl.dispose();
    _textCtrl.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(
          _scrollCtrl.position.maxScrollExtent,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _addCommand(String text, AppProvider provider) {
    final lang = provider.lang;
    final result = _parseCommand(text, lang);
    final cmd = Command(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      text: text,
      timestamp: DateTime.now(),
      status: result['status'] as CommandStatus,
      response: result['response'] as String,
    );
    provider.addCommand(cmd);

    // Metrics are now driven by WebSocket telemetry — no local mutation
    setState(() {
      _commands.add(cmd);
    });
    _scrollToBottom();
  }

  Future<void> _startListening(AppProvider provider) async {
    if (_isSending) return;
    final lang = provider.lang;

    // Start WAV recording in parallel with speech-to-text
    if (!kIsWeb) {
      try {
        if (await _audioRecorder.hasPermission()) {
          final dir = await getTemporaryDirectory();
          final path =
              '${dir.path}/voice_cmd_${DateTime.now().millisecondsSinceEpoch}.wav';
          await _audioRecorder.start(
            const RecordConfig(
              encoder: AudioEncoder.wav,
              sampleRate: 16000,
              numChannels: 1,
            ),
            path: path,
          );
          _recordPath = path;
        }
      } catch (e) {
        debugPrint('[VoiceControl] Record start error: $e');
      }
    }

    setState(() {
      _isListening = true;
      _status = provider.t.listeningCmd;
    });

    if (_speechReady) {
      await _speech.listen(
        localeId: lang == Lang.vi ? 'vi_VN' : 'en_US',
        onResult: (result) {
          setState(() => _transcript = result.recognizedWords);
        },
      );
    }
  }

  Future<void> _stopListening(AppProvider provider) async {
    if (!_isListening || _isSending) return;

    _speech.stop();
    final recordedPath = await _audioRecorder.stop();
    final path = recordedPath ?? _recordPath;
    final capturedTranscript = _transcript;

    setState(() {
      _isListening = false;
      _isSending = true;
      _transcript = '';
      _status = provider.t.sendingAudio;
    });

    // If we have a WAV file AND an auth token, send to backend
    if (path != null && provider.authToken != null) {
      try {
        final bytes = await readAudioBytes(path);
        if (bytes.isNotEmpty) {
          setState(() => _status = provider.t.processingCmd);
          final result = await _voiceCommandService.sendVoiceCommand(
            audioBytes: bytes,
            token: provider.authToken!,
          );
          if (mounted) {
            _handleApiResponse(result, capturedTranscript, provider);
          }
        } else {
          // Empty audio file — fallback to local parsing
          if (capturedTranscript.isNotEmpty) {
            _addCommand(capturedTranscript, provider);
          }
        }
      } catch (e) {
        debugPrint('[VoiceControl] Send error: $e');
        // Fallback to local parsing on network error
        if (capturedTranscript.isNotEmpty && mounted) {
          _addCommand(capturedTranscript, provider);
        }
      } finally {
        await deleteAudioFile(path);
      }
    } else {
      // No recording or no token — fallback to local parsing
      if (capturedTranscript.isNotEmpty) {
        _addCommand(capturedTranscript, provider);
      }
    }

    if (mounted) {
      setState(() {
        _isSending = false;
        _status = provider.t.systemReady;
      });
    }
  }

  void _handleApiResponse(
    VoiceCommandResult result,
    String transcript,
    AppProvider provider,
  ) {
    final t = provider.t;
    final data = result.data;
    final status = data?.status ?? '';

    // Determine command status and response message
    CommandStatus cmdStatus;
    String response;

    if (result.success && status == 'EXECUTED') {
      cmdStatus = CommandStatus.success;
      final detail = data?.command;
      response = detail != null
          ? '${t.cmdExecuted}: ${detail.action ?? ''} ${detail.direction ?? ''} ${detail.value ?? ''}'
              .trim()
          : t.cmdExecuted;
    } else if (status == 'SPEAKER_VERIFICATION_FAILED') {
      cmdStatus = CommandStatus.error;
      response = t.speakerFailed;
    } else if (status == 'ROLE_DENIED') {
      cmdStatus = CommandStatus.warning;
      response = '${t.roleDenied} (${data?.role ?? ""})';
    } else if (status == 'INVALID_COMMAND') {
      cmdStatus = CommandStatus.warning;
      response = t.invalidCommand;
    } else {
      cmdStatus = CommandStatus.error;
      response = result.message ?? t.cmdRejected;
    }

    final cmd = Command(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      text: data?.text ?? transcript,
      timestamp: DateTime.now(),
      status: cmdStatus,
      response: response,
    );

    provider.addCommand(cmd);
    setState(() => _commands.add(cmd));
    _scrollToBottom();
  }

  void _sendTextCommand(AppProvider provider) {
    final text = _textCtrl.text.trim();
    if (text.isEmpty) return;
    _addCommand(text, provider);
    _textCtrl.clear();
    setState(() => _inputText = '');
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final t = provider.t;
    if (_status.isEmpty) _status = t.systemReady;

    return Column(
      children: [
        // ── Status bar (replaces COMBAT SYS v2.4)
        _buildStatusBar(t, provider),

        // ── 4-metric row
        _buildMetrics(t),

        // ── Command log
        Expanded(child: _buildCommandLog(_commands, t, provider)),

        // ── Input area
        _buildInputArea(t, provider),
      ],
    );
  }

  Widget _buildStatusBar(AppTranslations t, AppProvider provider) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      color: AppColors.surface.withValues(alpha: 0.7),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _isListening ? AppColors.accent : AppColors.muted,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              _status,
              style: const TextStyle(color: AppColors.muted, fontSize: 11),
            ),
          ),

        ],
      ),
    );
  }

  Widget _buildMetrics(AppTranslations t) {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: AppColors.accent.withOpacity(0.1)),
          bottom: BorderSide(color: AppColors.accent.withOpacity(0.1)),
        ),
      ),
      child: Row(
        children: [
          Expanded(
              child: StatTile(
                  icon: Icons.navigation,
                  label: t.depth,
                  value: '${_depth.toStringAsFixed(0)}m',
                  color: AppColors.blue)),
          _divider(),
          Expanded(
              child: StatTile(
                  icon: Icons.speed,
                  label: t.speed,
                  value: '${_speed.toStringAsFixed(1)} kn',
                  color: AppColors.accent)),
          _divider(),
          Expanded(
              child: StatTile(
                  icon: Icons.explore,
                  label: t.heading,
                  value: '${_heading.toStringAsFixed(0)}°',
                  color: AppColors.amber)),
          _divider(),
          Expanded(
              child: StatTile(
                  icon: Icons.waves,
                  label: t.pressure,
                  value: '${_pressure.toStringAsFixed(1)} atm',
                  color: AppColors.pink)),
        ],
      ),
    );
  }

  Widget _divider() => Container(width: 1, height: 48, color: AppColors.border);

  Widget _buildCommandLog(
      List<Command> commands, AppTranslations t, AppProvider provider) {
    if (commands.isEmpty) {
      return _buildEmptyState(t, provider);
    }

    return ListView.builder(
      controller: _scrollCtrl,
      padding: const EdgeInsets.all(16),
      itemCount: commands.length + (_transcript.isNotEmpty ? 1 : 0),
      itemBuilder: (ctx, i) {
        // Interim transcript bubble
        if (i == commands.length) {
          return Align(
            alignment: Alignment.centerRight,
            child: Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.surface.withOpacity(0.6),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.borderBlue),
              ),
              child: Text(
                '$_transcript...',
                style: const TextStyle(
                    color: AppColors.blue,
                    fontSize: 13,
                    fontStyle: FontStyle.italic),
              ),
            ),
          );
        }

        final cmd = commands[i];
        return _CommandBubble(cmd: cmd, t: t);
      },
    );
  }

  Widget _buildEmptyState(AppTranslations t, AppProvider provider) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.waves, size: 48, color: Color(0x3300ffaa)),
            const SizedBox(height: 16),
            Text(
              provider.lang == Lang.vi
                  ? 'Nhấn microphone hoặc nhập lệnh để điều khiển tàu ngầm'
                  : 'Press microphone or type a command to control the submarine',
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.muted, fontSize: 13),
            ),
            const SizedBox(height: 20),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              alignment: WrapAlignment.center,
              children: t.quickCmds.map((cmd) {
                return GestureDetector(
                  onTap: () => _addCommand(cmd, provider),
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Text(cmd,
                        style: const TextStyle(
                            color: AppColors.accent, fontSize: 12)),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputArea(AppTranslations t, AppProvider provider) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface.withOpacity(0.7),
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              // Mic button
              _MicButton(
                isListening: _isListening || _isSending,
                onTap: _isSending
                    ? null
                    : () => _isListening
                        ? _stopListening(provider)
                        : _startListening(provider),
              ),
              const SizedBox(width: 12),

              // Input field OR sound bars
              Expanded(
                child: _isListening
                    ? Container(
                        height: 44,
                        decoration: BoxDecoration(
                          color: AppColors.surfaceAlt.withOpacity(0.8),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: const Center(child: SoundBars()),
                      )
                    : TextField(
                        controller: _textCtrl,
                        style: const TextStyle(color: Colors.white, fontSize: 13),
                        decoration: InputDecoration(hintText: t.enterCmd),
                        onChanged: (v) => setState(() => _inputText = v),
                        onSubmitted: (_) => _sendTextCommand(provider),
                      ),
              ),
              const SizedBox(width: 12),

              // Send button
              GestureDetector(
                onTap: _isListening || _isSending || _inputText.trim().isEmpty
                    ? null
                    : () => _sendTextCommand(provider),
                child: Opacity(
                  opacity:
                      _isListening || _isSending || _inputText.trim().isEmpty ? 0.3 : 1.0,
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.accentDim,
                      border: Border.all(color: AppColors.border),
                    ),
                    child: const Icon(Icons.send,
                        color: AppColors.accent, size: 20),
                  ),
                ),
              ),
            ],
          ),

        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────
// Mic button with animated pulse rings
// ─────────────────────────────────────────────────────────
class _MicButton extends StatefulWidget {
  final bool isListening;
  final VoidCallback? onTap;
  const _MicButton({required this.isListening, this.onTap});

  @override
  State<_MicButton> createState() => _MicButtonState();
}

class _MicButtonState extends State<_MicButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1200));
  }

  @override
  void didUpdateWidget(_MicButton old) {
    super.didUpdateWidget(old);
    if (widget.isListening && !_ctrl.isAnimating) {
      _ctrl.repeat();
    } else if (!widget.isListening) {
      _ctrl.stop();
      _ctrl.reset();
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: SizedBox(
        width: 52,
        height: 52,
        child: Stack(
          alignment: Alignment.center,
          children: [
            if (widget.isListening)
              AnimatedBuilder(
                animation: _ctrl,
                builder: (_, __) => Stack(
                  alignment: Alignment.center,
                  children: List.generate(3, (i) {
                    final t = (_ctrl.value + i * 0.33) % 1.0;
                    return Opacity(
                      opacity: (1 - t).clamp(0, 0.6),
                      child: SizedBox(
                        width: 52 + t * 40,
                        height: 52 + t * 40,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                                color: AppColors.accent.withOpacity(0.5),
                                width: 1.5),
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ),
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: widget.isListening
                    ? AppColors.accent.withOpacity(0.2)
                    : AppColors.accentDim,
                border: Border.all(
                  color: widget.isListening
                      ? AppColors.accent
                      : AppColors.accent.withOpacity(0.3),
                  width: 2,
                ),
              ),
              child: Icon(
                widget.isListening ? Icons.mic_off : Icons.mic,
                color: AppColors.accent,
                size: 22,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────
// Command bubble pair (user message + system response)
// ─────────────────────────────────────────────────────────
class _CommandBubble extends StatelessWidget {
  final Command cmd;
  final AppTranslations t;
  const _CommandBubble({required this.cmd, required this.t});

  Color get _color {
    switch (cmd.status) {
      case CommandStatus.success:
        return AppColors.accent;
      case CommandStatus.warning:
        return AppColors.amber;
      case CommandStatus.error:
        return AppColors.red;
    }
  }

  IconData get _icon {
    switch (cmd.status) {
      case CommandStatus.success:
        return Icons.check_circle_outline;
      case CommandStatus.warning:
        return Icons.warning_amber_rounded;
      case CommandStatus.error:
        return Icons.warning_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // User message (right-aligned)
          Align(
            alignment: Alignment.centerRight,
            child: Container(
              constraints: const BoxConstraints(maxWidth: 280),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFF1a2a4a).withOpacity(0.8),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(4),
                  bottomLeft: Radius.circular(12),
                  bottomRight: Radius.circular(12),
                ),
                border: Border.all(color: AppColors.borderBlue),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(cmd.text,
                      style: const TextStyle(
                          color: Color(0xFF88aaff), fontSize: 13)),
                  const SizedBox(height: 2),
                  Text(
                    _formatTime(cmd.timestamp),
                    style: const TextStyle(
                        color: AppColors.muted, fontSize: 10),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 4),

          // System response (left-aligned)
          Align(
            alignment: Alignment.centerLeft,
            child: Container(
              constraints: const BoxConstraints(maxWidth: 300),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: _color.withOpacity(0.05),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(4),
                  topRight: Radius.circular(12),
                  bottomLeft: Radius.circular(12),
                  bottomRight: Radius.circular(12),
                ),
                border: Border.all(color: _color.withOpacity(0.2)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(_icon, color: _color, size: 12),
                      const SizedBox(width: 4),
                      Text(
                        t.systemLabel,
                        style: TextStyle(
                            color: _color,
                            fontSize: 10,
                            letterSpacing: 1),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(cmd.response,
                      style: const TextStyle(
                          color: Colors.white70, fontSize: 13)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime dt) {
    return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}:${dt.second.toString().padLeft(2, '0')}';
  }
}
