import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../l10n/translations.dart';
import '../../../../models/user_session_record.dart';
import '../../../../providers/app_provider.dart';
import '../../../../theme.dart';

enum _FilterType { all, successful, unsuccessful }

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
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AppProvider>().fetchUserSessions();
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  bool _isSuccessful(UserSessionRecord cmd) => cmd.commandStatus == 'EXECUTED';
  bool _isUnsuccessful(UserSessionRecord cmd) =>
      cmd.commandStatus != 'EXECUTED';

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final t = provider.t;
    final lang = provider.lang;
    
    List<UserSessionRecord> all = List.from(provider.userSessions);
    all.sort((a, b) => (b.createdDate ?? DateTime.now()).compareTo(a.createdDate ?? DateTime.now()));

    final filtered = all.where((cmd) {
      final transcript = cmd.transcript ?? '';
      final action = cmd.action ?? '';
      
      final matchSearch = _search.isEmpty ||
          transcript.toLowerCase().contains(_search.toLowerCase()) ||
          action.toLowerCase().contains(_search.toLowerCase());
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
          child: provider.isLoadingSessions
              ? const Center(child: CircularProgressIndicator(color: AppColors.accent))
              : provider.sessionsError != null
                  ? Center(
                      child: Text(
                        'Error: ${provider.sessionsError}',
                        style: const TextStyle(color: AppColors.red, fontSize: 13),
                      ),
                    )
                  : filtered.isEmpty
                      ? _buildEmpty(t)
                      : RefreshIndicator(
                          onRefresh: () => provider.fetchUserSessions(),
                          color: AppColors.accent,
                          backgroundColor: AppColors.surface,
                          child: ListView.builder(
                            physics: const AlwaysScrollableScrollPhysics(),
                            itemCount: filtered.length,
                            itemBuilder: (_, i) => _CommandRow(
                              cmd: filtered[i],
                              t: t,
                              lang: lang,
                              isExpanded: _expandedId == filtered[i].id.toString(),
                              onTap: () => setState(() {
                                _expandedId =
                                    _expandedId == filtered[i].id.toString() ? null : filtered[i].id.toString();
                              }),
                            ),
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
  final UserSessionRecord cmd;
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
    final status = cmd.commandStatus;
    if (status == 'EXECUTED') return AppColors.accent;
    if (status == 'WARNING') return AppColors.amber;
    return AppColors.red;
  }

  IconData get _icon {
    final status = cmd.commandStatus;
    if (status == 'EXECUTED') return Icons.check_circle_outline;
    if (status == 'WARNING') return Icons.warning_amber_rounded;
    return Icons.warning_rounded;
  }

  String get _statusLabel {
    final status = cmd.commandStatus;
    if (status == 'EXECUTED') return t.statusSuccess;
    if (status == 'WARNING') return t.statusWarning;
    return t.statusError;
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
                          cmd.transcript ?? 'No transcript',
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
                          Text(cmd.createdDate != null ? _timeAgo(cmd.createdDate!) : '',
                              style: const TextStyle(
                                  color: AppColors.muted, fontSize: 10)),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    '${cmd.action ?? '-'} | ${cmd.direction ?? '-'} | ${cmd.value ?? '-'}',
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
              Expanded(child: _detailField(t.timeLabel, cmd.createdDate != null ? _fullTime(cmd.createdDate!) : '', _color)),
              const SizedBox(width: 16),
              Expanded(child: _detailField(t.statusLabel, _statusLabel, _color)),
            ],
          ),
          const SizedBox(height: 8),
          _detailField('Action Details', 'Action: ${cmd.action}\nDirection: ${cmd.direction}\nValue: ${cmd.value}', Colors.white70),
          const SizedBox(height: 6),
          _detailField(t.cmdId, '#${cmd.id}', AppColors.muted),
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
