import 'dart:async';
import 'package:flutter/foundation.dart';
import 'nfc_method_channel.dart';

class GlobalNfcListener {
  static final GlobalNfcListener _instance = GlobalNfcListener._internal();
  factory GlobalNfcListener() => _instance;
  GlobalNfcListener._internal();

  Function(String transactionId)? onTransactionReceived;
  bool _isListening = false;

  Future<void> startBackgroundListener({
    required Function(String transactionId) onTransactionReceived,
  }) async {
    this.onTransactionReceived = onTransactionReceived;
    nfcMethodChannel.onTransactionReceived = onTransactionReceived;
    debugPrint('Global NFC: Callback registered');

    if (_isListening) {
      debugPrint('Global NFC: Already listening');
      return;
    }

    _isListening = true;

    try {
      await nfcMethodChannel.startReaderMode();
      debugPrint('Global NFC: Reader mode started');
    } catch (e) {
      debugPrint('Global NFC ERROR: $e');
      _isListening = false;
    }
  }

  Future<void> stopBackgroundListener() async {
    if (!_isListening) return;

    _isListening = false;
    onTransactionReceived = null;
    nfcMethodChannel.onTransactionReceived = null;

    try {
      await nfcMethodChannel.stopReaderMode();
      debugPrint('Global NFC: Stopped');
    } catch (e) {
      debugPrint('Global NFC: Error stopping: $e');
    }
  }

  bool get isListening => _isListening;
}