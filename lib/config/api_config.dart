import 'package:flutter/foundation.dart';

/// Base URL của backend Speech_to_Text (Spring Boot, mặc định port 8080).
///
/// - Android emulator: `10.0.2.2` trỏ tới localhost máy host.
/// - Windows / iOS simulator / web: `localhost`.
/// - Thiết bị thật: đổi thành IP LAN của máy chạy backend, ví dụ `http://192.168.1.10:8080`.
class ApiConfig {
  static const int serverPort = 8080;

  static String get baseUrl {
    if (kIsWeb) {
      return 'http://localhost:$serverPort';
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return 'http://10.0.2.2:$serverPort';
      default:
        return 'http://localhost:$serverPort';
    }
  }

  static String get passwordLogin => '$baseUrl/api/auth/password-login';
  static String get voiceLogin => '$baseUrl/api/auth/voice-login';
  static String get mySessions => '$baseUrl/api/user-session/me';
}
