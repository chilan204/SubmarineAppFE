import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/command.dart';
import '../l10n/translations.dart';

// Submarine position state for the GPS map
class SubPosition {
  final double lat;
  final double lng;
  final double depth;
  final double heading;
  final double speed;

  const SubPosition({
    required this.lat,
    required this.lng,
    required this.depth,
    required this.heading,
    required this.speed,
  });

  SubPosition copyWith({
    double? lat,
    double? lng,
    double? depth,
    double? heading,
    double? speed,
  }) {
    return SubPosition(
      lat: lat ?? this.lat,
      lng: lng ?? this.lng,
      depth: depth ?? this.depth,
      heading: heading ?? this.heading,
      speed: speed ?? this.speed,
    );
  }
}

class AppProvider extends ChangeNotifier {
  bool _isLoggedIn = false;
  int _activeTab = 0;
  List<Command> _commandHistory = [];
  int _missionSeconds = 0;
  Lang _lang = Lang.vi;
  Timer? _missionTimer;

  bool get isLoggedIn => _isLoggedIn;
  int get activeTab => _activeTab;
  List<Command> get commandHistory => _commandHistory;
  int get missionSeconds => _missionSeconds;
  Lang get lang => _lang;
  AppTranslations get t => AppTranslations(_lang);

  void login() {
    _isLoggedIn = true;
    _missionSeconds = 0;
    _missionTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      _missionSeconds++;
      notifyListeners();
    });
    notifyListeners();
  }

  void logout() {
    _isLoggedIn = false;
    _commandHistory = [];
    _missionSeconds = 0;
    _activeTab = 0;
    _missionTimer?.cancel();
    _missionTimer = null;
    notifyListeners();
  }

  void setActiveTab(int index) {
    _activeTab = index;
    notifyListeners();
  }

  void addCommand(Command cmd) {
    _commandHistory = [..._commandHistory, cmd];
    notifyListeners();
  }

  void setLang(Lang lang) {
    _lang = lang;
    notifyListeners();
  }

  String get formattedMissionTime {
    final h = (_missionSeconds ~/ 3600).toString().padLeft(2, '0');
    final m = ((_missionSeconds % 3600) ~/ 60).toString().padLeft(2, '0');
    final s = (_missionSeconds % 60).toString().padLeft(2, '0');
    return '$h:$m:$s';
  }

  @override
  void dispose() {
    _missionTimer?.cancel();
    super.dispose();
  }
}
