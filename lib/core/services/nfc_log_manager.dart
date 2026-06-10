import 'dart:async';

class NfcLogManager {
  static final NfcLogManager _instance = NfcLogManager._internal();
  factory NfcLogManager() => _instance;
  NfcLogManager._internal();

  final StreamController<String> _logController = StreamController<String>.broadcast();
  Stream<String> get logStream => _logController.stream;

  void addLog(String message) {
    final timestamp = DateTime.now().toString().substring(11, 23);
    _logController.add('[$timestamp] $message');
  }

  void dispose() {
    _logController.close();
  }
}