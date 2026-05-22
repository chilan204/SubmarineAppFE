import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../l10n/translations.dart';
import '../models/command.dart';
import '../providers/app_provider.dart';
import '../theme.dart';

enum _FilterType { all, successful, unsuccessful }

// Initial demo commands seeded to match HistoryScreen.tsx
List<Command> _initialCommands(Lang lang) {
  final now = DateTime.now();
  if (lang == Lang.vi) {
    return [
      Command(id: 'h1', text: 'Kiểm tra hệ thống', timestamp: now.subtract(const Duration(hours: 1)), status: CommandStatus.success, response: 'Tất cả hệ thống bình thường. Pin: 87%. Oxy: 94%'),
      Command(id: 'h2', text: 'Lặn xuống 50m', timestamp: now.subtract(const Duration(minutes: 53)), status: CommandStatus.success, response: 'Đang thực hiện lặn xuống. Độ sâu mục tiêu: -50m'),
      Command(id: 'h3', text: 'Tiến về phía trước', timestamp: now.subtract(const Duration(minutes: 46)), status: CommandStatus.success, response: 'Động cơ đẩy kích hoạt. Tốc độ 5 hải lý/h'),
      Command(id: 'h4', text: 'Phóng ngư lôi', timestamp: now.subtract(const Duration(minutes: 40)), status: CommandStatus.warning, response: 'CẢNH BÁO: Cần xác nhận từ chỉ huy cấp cao'),
      Command(id: 'h5', text: 'Quay trái 15 độ', timestamp: now.subtract(const Duration(minutes: 33)), status: CommandStatus.success, response: 'Bánh lái trái 15°. Đang điều hướng'),
      Command(id: 'h6', text: 'Chế độ tàng hình', timestamp: now.subtract(const Duration(minutes: 26)), status: CommandStatus.success, response: 'Hệ thống âm học tắt. Chế độ im lặng kích hoạt'),
      Command(id: 'h7', text: 'Khẩn cấp nổi lên', timestamp: now.subtract(const Duration(minutes: 20)), status: CommandStatus.error, response: 'KHẨN CẤP: Thổi két nước dằn. Nổi lên khẩn cấp!'),
      Command(id: 'h8', text: 'Kiểm tra sonar', timestamp: now.subtract(const Duration(minutes: 13)), status: CommandStatus.success, response: 'Sonar hoạt động bình thường. Không phát hiện mục tiêu'),
      Command(id: 'h9', text: 'Dừng lại', timestamp: now.subtract(const Duration(minutes: 6)), status: CommandStatus.success, response: 'Hệ thống đẩy dừng. Giữ vị trí hiện tại'),
      Command(id: 'h10', text: 'Nổi lên', timestamp: now.subtract(const Duration(minutes: 2)), status: CommandStatus.success, response: 'Đang nổi lên. Độ sâu mục tiêu: 0m'),
    ];
  } else {
    return [
      Command(id: 'h1', text: 'Check systems', timestamp: now.subtract(const Duration(hours: 1)), status: CommandStatus.success, response: 'All systems normal. Battery: 87%. Oxygen: 94%'),
      Command(id: 'h2', text: 'Dive to 50m', timestamp: now.subtract(const Duration(minutes: 53)), status: CommandStatus.success, response: 'Executing dive. Target depth: -50m'),
      Command(id: 'h3', text: 'Move forward', timestamp: now.subtract(const Duration(minutes: 46)), status: CommandStatus.success, response: 'Propulsion engaged. Speed: 5 knots'),
      Command(id: 'h4', text: 'Launch torpedo', timestamp: now.subtract(const Duration(minutes: 40)), status: CommandStatus.warning, response: 'WARNING: Requires senior command confirmation'),
      Command(id: 'h5', text: 'Turn left 15°', timestamp: now.subtract(const Duration(minutes: 33)), status: CommandStatus.success, response: 'Rudder left 15°. Navigating'),
      Command(id: 'h6', text: 'Stealth mode', timestamp: now.subtract(const Duration(minutes: 26)), status: CommandStatus.success, response: 'Acoustic systems off. Silent mode activated'),
      Command(id: 'h7', text: 'Emergency surface', timestamp: now.subtract(const Duration(minutes: 20)), status: CommandStatus.error, response: 'EMERGENCY: Blowing ballast tanks. Emergency ascent!'),
      Command(id: 'h8', text: 'Sonar check', timestamp: now.subtract(const Duration(minutes: 13)), status: CommandStatus.success, response: 'Sonar operating normally. No targets detected'),
      Command(id: 'h9', text: 'Stop', timestamp: now.subtract(const Duration(minutes: 6)), status: CommandStatus.success, response: 'Propulsion stopped. Holding position'),
      Command(id: 'h10', text: 'Surface', timestamp: now.subtract(const Duration(minutes: 2)), status: CommandStatus.success, response: 'Surfacing. Target depth: 0m'),
    ];
  }
}

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  _FilterType _filter = _FilterType.all;
  String _search = '';
  String? _expandedId;
  final TextEditingController _searchCtrl = TextEditingController();

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  bool _isSuccessful(Command cmd) => cmd.status == CommandStatus.success;
  bool _isUnsuccessful(Command cmd) =>
      cmd.status == CommandStatus.warning || cmd.status == CommandStatus.error;

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final t = provider.t;
    final lang = provider.lang;
    final initial = _initialCommands(lang);
    final all = [...initial, ...provider.commandHistory]
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));

    final filtered = all.where((cmd) {
      final matchSearch = _search.isEmpty ||
          cmd.text.toLowerCase().contains(_search.toLowerCase()) ||
          cmd.response.toLowerCase().contains(_search.toLowerCase());
      final matchFilter = _filter == _FilterType.all ||
          (_filter == _FilterType.successful && _isSuccessful(cmd)) ||
          (_filter == _FilterType.unsuccessful && _isUnsuccessful(cmd));
      return matchSearch && matchFilter;
    }).toList();

    final counts = (
      all: all.length,
      successful: all.where(_isSuccessful).length,
      unsuccessful: all.where(_isUnsuccessful).length,
    );

    return Column(
      children: [
        // ── Header
        _buildHeader(t, all.length, counts),

        // ── List
        Expanded(
          child: filtered.isEmpty
              ? _buildEmpty(t)
              : ListView.builder(
                  itemCount: filtered.length,
                  itemBuilder: (_, i) => _CommandRow(
                    cmd: filtered[i],
                    t: t,
                    lang: lang,
                    isExpanded: _expandedId == filtered[i].id,
                    onTap: () => setState(() {
                      _expandedId =
                          _expandedId == filtered[i].id ? null : filtered[i].id;
                    }),
                  ),
                ),
        ),

        // ── Footer
        _buildFooter(t, filtered.length, all.length),
      ],
    );
  }

  Widget _buildHeader(AppTranslations t, int total,
      ({int all, int successful, int unsuccessful}) counts) {
    return Container(
      color: AppColors.surface.withOpacity(0.7),
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 8),
      child: Column(
        children: [
          // Title row
          Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(t.historyTitle,
                      style: const TextStyle(
                          color: AppColors.accent, fontSize: 15)),
                  Text('$total ${t.historySubtitle}',
                      style: const TextStyle(
                          color: AppColors.muted, fontSize: 11)),
                ],
              ),
              const Spacer(),
              GestureDetector(
                onTap: () {/* export placeholder */},
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.download_outlined,
                          color: AppColors.accent, size: 14),
                      const SizedBox(width: 4),
                      Text(t.exportReport,
                          style: const TextStyle(
                              color: AppColors.accent, fontSize: 11)),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Filter tabs
          Row(
            children: [
              _filterTab(_FilterType.all, t.all, counts.all, AppColors.muted),
              const SizedBox(width: 8),
              _filterTab(_FilterType.successful, t.successful,
                  counts.successful, AppColors.accent),
              const SizedBox(width: 8),
              _filterTab(_FilterType.unsuccessful, t.unsuccessful,
                  counts.unsuccessful, AppColors.red),
            ],
          ),
          const SizedBox(height: 8),

          // Search field
          TextField(
            controller: _searchCtrl,
            style: const TextStyle(color: Colors.white, fontSize: 13),
            decoration: InputDecoration(
              hintText: t.searchPlaceholder,
              prefixIcon:
                  const Icon(Icons.search, color: AppColors.muted, size: 18),
              suffixIcon: _search.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.close,
                          color: AppColors.muted, size: 16),
                      onPressed: () {
                        _searchCtrl.clear();
                        setState(() => _search = '');
                      },
                    )
                  : null,
            ),
            onChanged: (v) => setState(() => _search = v),
          ),
        ],
      ),
    );
  }

  Widget _filterTab(
      _FilterType type, String label, int count, Color activeColor) {
    final isActive = _filter == type;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _filter = type),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isActive
                  ? activeColor.withOpacity(0.4)
                  : AppColors.border.withOpacity(0.3),
            ),
            color: isActive ? activeColor.withOpacity(0.1) : Colors.transparent,
          ),
          child: Column(
            children: [
              Text(
                '$count',
                style: TextStyle(
                  color: isActive ? activeColor : AppColors.muted,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                label,
                style: TextStyle(
                  color: isActive ? activeColor : AppColors.muted,
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmpty(AppTranslations t) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.search, size: 48, color: Color(0x338899aa)),
          const SizedBox(height: 12),
          Text(t.noCommands,
              style: const TextStyle(color: AppColors.muted, fontSize: 13)),
        ],
      ),
    );
  }

  Widget _buildFooter(AppTranslations t, int shown, int total) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      color: AppColors.surface.withOpacity(0.7),
      child: Row(
        children: [
          Text('${t.showing} $shown ${t.of} $total',
              style: const TextStyle(color: AppColors.muted, fontSize: 11)),
          const Spacer(),
          Row(
            children: [
              Container(
                width: 6,
                height: 6,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.accent,
                ),
              ),
              const SizedBox(width: 4),
              Text(t.autoRecord,
                  style: const TextStyle(
                      color: AppColors.muted, fontSize: 10)),
            ],
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// Single command row with expandable detail panel
// ─────────────────────────────────────────────────────────────────
class _CommandRow extends StatelessWidget {
  final Command cmd;
  final AppTranslations t;
  final Lang lang;
  final bool isExpanded;
  final VoidCallback onTap;

  const _CommandRow({
    required this.cmd,
    required this.t,
    required this.lang,
    required this.isExpanded,
    required this.onTap,
  });

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

  String get _statusLabel {
    switch (cmd.status) {
      case CommandStatus.success:
        return t.statusSuccess;
      case CommandStatus.warning:
        return t.statusWarning;
      case CommandStatus.error:
        return t.statusError;
    }
  }

  String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return t.timeJustNow;
    if (diff.inMinutes < 60) return '${diff.inMinutes} ${t.timeMinAgo}';
    if (diff.inHours < 24) return '${diff.inHours} ${t.timeHrAgo}';
    return '${diff.inDays} ${t.timeDayAgo}';
  }

  String _fullTime(DateTime dt) {
    return '${dt.day.toString().padLeft(2, '0')}/'
        '${dt.month.toString().padLeft(2, '0')}/'
        '${dt.year} '
        '${dt.hour.toString().padLeft(2, '0')}:'
        '${dt.minute.toString().padLeft(2, '0')}:'
        '${dt.second.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          border: Border(
              bottom: BorderSide(color: AppColors.accent.withOpacity(0.05))),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status icon
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: _color.withOpacity(0.05),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: _color.withOpacity(0.2)),
              ),
              child: Icon(_icon, color: _color, size: 16),
            ),
            const SizedBox(width: 12),

            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          cmd.text,
                          style: const TextStyle(
                              color: Colors.white, fontSize: 13),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Row(
                        children: [
                          const Icon(Icons.access_time,
                              color: AppColors.muted, size: 11),
                          const SizedBox(width: 3),
                          Text(_timeAgo(cmd.timestamp),
                              style: const TextStyle(
                                  color: AppColors.muted, fontSize: 10)),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    cmd.response,
                    style: const TextStyle(
                        color: AppColors.muted, fontSize: 11),
                    maxLines: isExpanded ? null : 1,
                    overflow:
                        isExpanded ? null : TextOverflow.ellipsis,
                  ),

                  // Expanded detail panel
                  AnimatedCrossFade(
                    firstChild: const SizedBox.shrink(),
                    secondChild: _buildDetail(),
                    crossFadeState: isExpanded
                        ? CrossFadeState.showSecond
                        : CrossFadeState.showFirst,
                    duration: const Duration(milliseconds: 200),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 8),
            Icon(
              isExpanded
                  ? Icons.keyboard_arrow_down
                  : Icons.chevron_right,
              color: AppColors.muted,
              size: 18,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetail() {
    return Container(
      margin: const EdgeInsets.only(top: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: _color.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: _detailField(t.timeLabel, _fullTime(cmd.timestamp), _color)),
              const SizedBox(width: 16),
              Expanded(child: _detailField(t.statusLabel, _statusLabel, _color)),
            ],
          ),
          const SizedBox(height: 8),
          _detailField(t.sysResponse, cmd.response, Colors.white70),
          const SizedBox(height: 6),
          _detailField(t.cmdId, '#${cmd.id.toUpperCase()}', AppColors.muted),
        ],
      ),
    );
  }

  Widget _detailField(String label, String value, Color valueColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
                color: AppColors.muted,
                fontSize: 9,
                letterSpacing: 1)),
        const SizedBox(height: 2),
        Text(value,
            style: TextStyle(
                color: valueColor,
                fontSize: 11,
                )),
      ],
    );
  }
}
