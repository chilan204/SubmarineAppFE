// Translations — Dart port of translations.ts
// Supports Vietnamese (vi) and English (en)

enum Lang { vi, en }

class AppTranslations {
  final Lang lang;
  const AppTranslations(this.lang);

  bool get isVi => lang == Lang.vi;

  // Login
  String get loginSubtitle => isVi
      ? 'Hệ thống điều khiển tàu ngầm v2.4.1'
      : 'Submarine Control System v2.4.1';
  String get selectAuth =>
      isVi ? 'Chọn phương thức xác thực' : 'Select authentication method';
  String get voiceAuth => isVi ? 'Xác thực giọng nói' : 'Voice Authentication';
  String get voiceAuthDesc =>
      isVi ? 'Nhận dạng cụm từ bí mật' : 'Secret phrase recognition';
  String get passwordAuth => isVi ? 'Mật khẩu bảo mật' : 'Secure Password';
  String get passwordAuthDesc =>
      isVi ? 'Nhập thông tin đăng nhập' : 'Enter credentials';
  String get usernameLabel => isVi ? 'TÊN ĐĂNG NHẬP' : 'USERNAME';
  String get passwordLabel => isVi ? 'MẬT KHẨU' : 'PASSWORD';
  String get authenticate => isVi ? 'XÁC THỰC' : 'AUTHENTICATE';
  String get back => isVi ? '← Quay lại' : '← Back';
  String get hint => isVi ? 'Gợi ý: admin / SUBMARINE2024' : 'Hint: admin / SUBMARINE2024';
  String get wrongCreds => isVi
      ? 'Thông tin không đúng. Vui lòng thử lại.'
      : 'Invalid credentials. Please try again.';
  String get sayPhrase => isVi ? 'Hãy nói cụm từ bí mật:' : 'Say the secret phrase:';
  String get voicePhrase =>
      isVi ? '"kích hoạt tàu ngầm"' : '"activate submarine"';
  String get pressmic =>
      isVi ? 'Nhấn microphone để bắt đầu' : 'Press microphone to begin';
  String get listening => isVi ? 'Đang lắng nghe...' : 'Listening...';
  String get authSuccess =>
      isVi ? 'Xác thực thành công!' : 'Authentication successful!';
  String get authFailed => isVi
      ? 'Cụm từ không khớp. Hãy nói: "kích hoạt tàu ngầm"'
      : 'Phrase not matched. Say: "activate submarine"';
  String get online =>
      isVi ? 'HỆ THỐNG TRỰC TUYẾN' : 'SYSTEM ONLINE';
  String get classified => isVi
      ? 'MẬT — CHỈ DÀNH CHO NHÂN SỰ ĐÃ ĐƯỢC PHÊ DUYỆT'
      : 'CLASSIFIED — AUTHORIZED PERSONNEL ONLY';
  String get voiceNotSupported =>
      isVi ? 'Không hỗ trợ nhận dạng giọng nói' : 'Voice recognition not supported';
  String get voiceError =>
      isVi ? 'Lỗi nhận dạng. Nhấn mic để thử lại.' : 'Recognition error. Tap mic to retry.';
  String get voiceVerifyFailed =>
      isVi ? 'Xác thực giọng nói thất bại' : 'Voice authentication failed';

  // Nav
  String get missionTime => isVi ? 'THỜI GIAN NHIỆM VỤ' : 'MISSION TIME';
  String get commandCount => isVi ? 'lệnh' : 'cmds';
  String get logout => isVi ? 'Đăng xuất' : 'Logout';
  String get control => isVi ? 'Điều Khiển' : 'Control';
  String get map => isVi ? 'Bản Đồ' : 'Map';
  String get history => isVi ? 'Lịch Sử' : 'History';

  // Voice Control
  String get systemReady => isVi ? 'Hệ thống sẵn sàng' : 'System ready';
  String get listeningCmd =>
      isVi ? 'Đang lắng nghe lệnh...' : 'Listening for commands...';
  String get cmdReceived => isVi
      ? 'Lệnh đã nhận. Đang chờ lệnh tiếp theo...'
      : 'Command received. Awaiting next...';
  String get enterCmd =>
      isVi ? 'Nhập lệnh điều khiển...' : 'Enter control command...';
  String get cmdHint => isVi
      ? 'Các lệnh: lặn xuống · nổi lên · tiến · dừng · quay trái/phải · khẩn cấp'
      : 'Commands: dive · surface · forward · stop · turn left/right · emergency';
  String get systemLabel => isVi ? 'HỆ THỐNG' : 'SYSTEM';
  String get depth => isVi ? 'ĐỘ SÂU' : 'DEPTH';
  String get speed => isVi ? 'TỐC ĐỘ' : 'SPEED';
  String get heading => isVi ? 'HƯỚNG' : 'HEADING';
  String get pressure => isVi ? 'ÁP SUẤT' : 'PRESSURE';
  List<String> get quickCmds => isVi
      ? ['Lặn xuống', 'Nổi lên', 'Tiến về phía trước', 'Dừng lại', 'Quay trái', 'Kiểm tra hệ thống']
      : ['Dive', 'Surface', 'Move Forward', 'Stop', 'Turn Left', 'Check Systems'];

  // GPS
  String get currentPos => isVi ? 'VỊ TRÍ HIỆN TẠI' : 'CURRENT POSITION';
  String get trackingLive => isVi ? 'ĐANG THEO DÕI' : 'TRACKING LIVE';

  // History
  String get historyTitle => isVi ? 'Lịch Sử Lệnh' : 'Command History';
  String get historySubtitle => isVi ? 'lệnh đã ghi lại' : 'commands recorded';
  String get exportReport => isVi ? 'Xuất báo cáo' : 'Export Report';
  String get searchPlaceholder =>
      isVi ? 'Tìm kiếm lệnh hoặc phản hồi...' : 'Search commands or responses...';
  String get all => isVi ? 'Tất cả' : 'All';
  String get successful => isVi ? 'Thành công' : 'Successful';
  String get unsuccessful => isVi ? 'Thất bại' : 'Unsuccessful';
  String get showing => isVi ? 'Hiển thị' : 'Showing';
  String get of => isVi ? '/' : 'of';
  String get autoRecord => isVi ? 'Ghi nhận tự động' : 'Auto recording';
  String get noCommands =>
      isVi ? 'Không tìm thấy lệnh nào' : 'No commands found';
  String get timeJustNow => isVi ? 'Vừa xong' : 'Just now';
  String get timeMinAgo => isVi ? 'phút trước' : 'min ago';
  String get timeHrAgo => isVi ? 'giờ trước' : 'hr ago';
  String get timeDayAgo => isVi ? 'ngày trước' : 'days ago';
  String get cmdId => isVi ? 'ID LỆNH' : 'COMMAND ID';
  String get sysResponse => isVi ? 'PHẢN HỒI HỆ THỐNG' : 'SYSTEM RESPONSE';
  String get statusLabel => isVi ? 'TRẠNG THÁI' : 'STATUS';
  String get timeLabel => isVi ? 'THỜI GIAN' : 'TIME';
  String get statusSuccess => isVi ? 'Thành công' : 'Success';
  String get statusWarning => isVi ? 'Cảnh báo' : 'Warning';
  String get statusError => isVi ? 'Khẩn cấp' : 'Emergency';
}
